-- lambdaplayers_friendsystem.lua
-- Upgraded friend system: affinity levels, roles, trauma bonds, revive assist, prop adoption, group dynamics
-- Merges creation-ID friend map (for legacy network/display) with new entity->affinity mapping

local IsValid = IsValid
local table_Count = table.Count
local pairs = pairs
local RandomPairs = RandomPairs
local random = math.random
local table_Add = table.Add
local VectorRand = VectorRand
local net = net
local string_find = string.find
local string_Explode = string.Explode
local player_GetAll = player.GetAll
local string_lower = string.lower
local table_IsEmpty = table.IsEmpty
local debugoverlay = debugoverlay
local dev = GetConVar( "developer" )
local uiscale = GetConVar( "lambdaplayers_uiscale" )

-- Friend System Convars
CreateLambdaConvar( "lambdaplayers_friend_enabled", 1, true, false, false, "Enables the friend system that will allow Lambda Players to be friends with each other or with players and treat them as such", 0, 1, { name = "Enable Friend System", type = "Bool", category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_friendlyfire", 0, true, false, false, "If friends can hurt each other or not", 0, 1, { name = "Allow Friendly Fire", type = "Bool", category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_drawhalo", 1, true, true, false, "If friends should have a halo around them", 0, 1, { name = "Draw Halos", type = "Bool", category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_friendcount", 3, true, false, false, "How many friends a Lambda/Real Player can have", 1, 30, { name = "Friend Count", type = "Slider", decimals = 0, category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_friendchance", 5, true, false, false, "The chance a Lambda Player will spawn as someone's friend", 1, 100, { name = "Friend Chance", type = "Slider", decimals = 0, category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_alwaysstaynearplayers", 0, true, false, false, "If Lambda Friends should favor following real players", 0, 1, { name = "Always Follow Real Players", type = "Bool", category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_alwaysstaynearfriends", 0, true, false, false, "If Friends should always stick together, rather than ocassionally following a frined", 0, 1, { name = "Stick Together", type = "Bool", category = "Friend System" } )

-- New tuning
CreateLambdaConvar( "lambdaplayers_friend_affinity_decay", 1, true, false, false, "How much affinity decays every minute (points)", 0, 10, { name = "Affinity Decay / min", type = "Slider", decimals = 0, category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_revive_chance", 50, true, false, false, "Chance (%) a friend will attempt a revive when nearby and able", 0, 100, { name = "Revive Chance", type = "Slider", decimals = 0, category = "Friend System" } )
CreateLambdaConvar( "lambdaplayers_friend_traumabond_bonus", 20, true, false, false, "Affinity bonus awarded for surviving dangerous events together", 0, 100, { name = "Trauma Bond Bonus", type = "Slider", decimals = 0, category = "Friend System" } )

-- Legacy helper
local function GetPlayers()
    local lambda = GetLambdaPlayers()
    local realplayers = player_GetAll()
    table_Add( lambda, realplayers )
    return lambda
end

-- Affinity -> level & color helper
local function AffinityToLevel( affinity )
    affinity = math.Clamp( tonumber(affinity) or 0, 0, 100 )
    if affinity >= 90 then
        return "Partner", Color( 160, 60, 220 )
    elseif affinity >= 70 then
        return "Best Friend", Color( 60, 140, 220 )
    elseif affinity >= 45 then
        return "Close Friend", Color( 255, 215, 0 )
    elseif affinity >= 20 then
        return "Friend", Color( 200, 180, 0 )
    else
        return "Acquaintance", Color( 200, 200, 200 )
    end
end

-- Roles enumeration
local FriendRoles = {
    GUARDIAN = "guardian", -- defend & protect buddy
    MEDIC = "medic",       -- try to heal friends
    SCOUT = "scout",       -- pokes ahead & pings threats
    SUPPLIER = "supplier", -- gives ammo/props
    BUDDY = "buddy"        -- stays close / social
}
local DefaultRole = FriendRoles.BUDDY

-- We'll keep two friend representations to be backward compatible:
-- 1) self.l_friends: map[ creationID ] = entity  (used for legacy network / client display)
-- 2) self.l_Friends: map[ entity ] = affinity     (new per-entity affinity map; EntMeta helpers handle this)

-- Make sure network strings exist
if SERVER then
    util.AddNetworkString( "lambdaplayerfriendsystem_addfriend" )
    util.AddNetworkString( "lambdaplayerfriendsystem_removefriend" )
    util.AddNetworkString( "lambdaplayerfriendsystem_updatefriend" ) -- contains affinity + role info
end

-- ---------------------------------------------------------------------------
-- Server-side Lambda Initialize, Think, and core friend behaviors
-- ---------------------------------------------------------------------------

local function Initialize( self, wepent )
    if CLIENT then return end

    -- legacy map (creationID -> entity) for HUD + halo compatibility
    self.l_friends = self.l_friends or {}
    -- new affinity map
    self.l_Friends = self.l_Friends or {} -- ent -> affinity (0..100)
    -- role assignments (ent -> role string)
    self.l_friendroles = self.l_friendroles or {}

    self.l_nearbycheck = CurTime() + 15
    self.l_friendupdate = CurTime() + 3
    self.l_lastAffinityDecay = CurTime() + 60

    -- New convenience wrappers using EntMeta functions if available
    function self:IsFriendsWith( ent )
        if not IsValid(ent) then return false end
        -- prefer affinity mapping
        if self.l_Friends and self.l_Friends[ent] ~= nil then return true end
        -- fallback to legacy table
        if ent.GetCreationID and self.l_friends and self.l_friends[ent:GetCreationID()] then return true end
        return false
    end

    function self:CanBeFriendsWith( ent )
        if not IsValid(ent) then return false end
        -- Must be a Lambda player or real player
        local friendcount = GetConVar( "lambdaplayers_friend_friendcount" ):GetInt()
        return ( ent.IsLambdaPlayer or ent:IsPlayer() )
            and table_Count( self.l_Friends or {} ) < friendcount
            and table_Count( ent.l_Friends or {} ) < friendcount
            and not self:IsFriendsWith( ent )
    end

    -- return random friend entity (prefers real players when asked)
    function self:GetRandomFriend( real_player_only )
        -- iterate affinity map
        if self.l_Friends then
            local keys = {}
            for ent, aff in pairs(self.l_Friends) do
                if not IsValid(ent) then continue end
                if real_player_only and not ent:IsPlayer() then continue end
                table.insert(keys, ent)
            end
            if #keys > 0 then return keys[ random(1,#keys) ] end
        end
        -- fallback legacy
        for k, v in RandomPairs( self.l_friends or {} ) do
            if real_player_only and v:IsPlayer() then
                return v
            elseif not real_player_only then
                return v
            end
        end
    end

    -- Send friend updates to clients (backwards-compatible plus affinity+role)
    function self:UpdateClientFriends()
        -- iterate new affinity map
        for ent, affinity in pairs( self.l_Friends or {} ) do
            if not IsValid(ent) then continue end
            local role = self.l_friendroles[ent] or DefaultRole
            -- legacy-style broadcast (addition id + ent + receiver)
            net.Start( "lambdaplayerfriendsystem_addfriend" )
                net.WriteUInt( self:GetCreationID(), 32 )
                net.WriteEntity( self )
                net.WriteEntity( ent )
            net.Broadcast()

            net.Start( "lambdaplayerfriendsystem_addfriend" )
                net.WriteUInt( ent:GetCreationID(), 32 )
                net.WriteEntity( ent )
                net.WriteEntity( self )
            net.Broadcast()

            -- new more detailed update (affinity + role)
            net.Start( "lambdaplayerfriendsystem_updatefriend" )
                net.WriteEntity( self )
                net.WriteEntity( ent )
                net.WriteUInt( math.Clamp( math.floor( affinity ), 0, 100 ), 8 ) -- affinity 0-100
                net.WriteString( tostring(role or DefaultRole) )
            net.Broadcast()
        end
    end

    -- Add ent to our friends list with affinity and optional role
    function self:AddFriend( ent, forceadd, affinity, role )
        if not IsValid(ent) then return end
        affinity = tonumber(affinity) or 50
        role = role or DefaultRole
        ent.l_friends = ent.l_friends or {}
        self.l_friends = self.l_friends or {}
        self.l_Friends = self.l_Friends or {}
        self.l_friendroles = self.l_friendroles or {}

        if self:IsFriendsWith( ent ) and not forceadd then return end
        if not forceadd and not self:CanBeFriendsWith(ent) then return end
        if not GetConVar( "lambdaplayers_friend_enabled" ):GetBool() then return end

        -- legacy map for clients
        self.l_friends[ ent:GetCreationID() ] = ent
        ent.l_friends = ent.l_friends or {}
        ent.l_friends[ self:GetCreationID() ] = self

        -- affinity map
        self.l_Friends[ ent ] = math.Clamp( tonumber(affinity) or 50, 0, 100 )
        ent.l_Friends = ent.l_Friends or {}
        ent.l_Friends[ self ] = ent.l_Friends[ self ] or math.Clamp( tonumber(affinity) or 50, 0, 100 )

        -- role
        self.l_friendroles[ ent ] = role
        ent.l_friendroles = ent.l_friendroles or {}
        ent.l_friendroles[ self ] = self.l_friendroles[ ent ]

        -- notify and broadcast
        net.Start( "lambdaplayerfriendsystem_addfriend" )
            net.WriteUInt( self:GetCreationID(), 32 )
            net.WriteEntity( self )
            net.WriteEntity( ent )
        net.Broadcast()

        net.Start( "lambdaplayerfriendsystem_addfriend" )
            net.WriteUInt( ent:GetCreationID(), 32 )
            net.WriteEntity( ent )
            net.WriteEntity( self )
        net.Broadcast()

        net.Start( "lambdaplayerfriendsystem_updatefriend" )
            net.WriteEntity( self )
            net.WriteEntity( ent )
            net.WriteUInt( math.Clamp( math.floor(self.l_Friends[ ent ] ), 0, 100 ), 8 )
            net.WriteString( tostring( self.l_friendroles[ ent ] or DefaultRole ) )
        net.Broadcast()

        LambdaRunHook( "LambdaOnAddFriend", self, ent, self.l_Friends[ ent ] )

        -- Become friends with ent's friends (group dynamics)
        for otherEnt, otherAff in pairs( ent.l_Friends or {} ) do
            if otherEnt == self or not IsValid(otherEnt) then continue end
            if not self:CanBeFriendsWith( otherEnt ) then continue end
            self:AddFriend( otherEnt, true, math.Clamp( (self.l_Friends[ent] + otherAff) / 2, 10, 80 ), DefaultRole )
        end
    end

    -- Remove ent from our friends list (keeps maps synced)
    function self:RemoveFriend( ent )
        if not IsValid(ent) then return end
        if not self:IsFriendsWith(ent) then return end

        -- broadcast legacy remove
        net.Start( "lambdaplayerfriendsystem_removefriend" )
            net.WriteUInt( self:GetCreationID(), 32 )
            net.WriteEntity( ent )
        net.Broadcast()

        net.Start( "lambdaplayerfriendsystem_removefriend" )
            net.WriteUInt( ent:GetCreationID(), 32 )
            net.WriteEntity( self )
        net.Broadcast()

        -- remove legacy map
        if self.l_friends then self.l_friends[ ent:GetCreationID() ] = nil end
        if ent.l_friends then ent.l_friends[ self:GetCreationID() ] = nil end

        -- remove affinity map and role
        if self.l_Friends then self.l_Friends[ ent ] = nil end
        if ent.l_Friends then ent.l_Friends[ self ] = nil end
        if self.l_friendroles then self.l_friendroles[ ent ] = nil end
        if ent.l_friendroles then ent.l_friendroles[ self ] = nil end

        LambdaRunHook( "LambdaOnRemoveFriend", self, ent )
    end

    -- Randomly set someone as our friend if it passes the chance (legacy behavior)
    if random( 0, 100 ) < GetConVar( "lambdaplayers_friend_friendchance" ):GetInt() then
        for k, v in RandomPairs( GetPlayers() ) do
            if v == self or self:IsFriendsWith( v ) or not self:CanBeFriendsWith( v ) then continue end
            self:AddFriend( v )
            break
        end
    end

    -- Quick helper to adjust affinity
    function self:AdjustFriendAffinity( ent, delta )
        if not IsValid(ent) or not self.l_Friends then return end
        local cur = self.l_Friends[ ent ] or 0
        cur = math.Clamp( cur + ( tonumber( delta ) or 0 ), 0, 100 )
        self.l_Friends[ ent ] = cur
        if ent.l_Friends then ent.l_Friends[ self ] = ent.l_Friends[ self ] or cur end
        LambdaRunHook( "LambdaOnFriendAffinityChanged", self, ent, cur )

        -- broadcast updated affinity
        net.Start( "lambdaplayerfriendsystem_updatefriend" )
            net.WriteEntity( self )
            net.WriteEntity( ent )
            net.WriteUInt( math.Clamp( math.floor(cur), 0, 100 ), 8 )
            net.WriteString( tostring( self.l_friendroles[ ent ] or DefaultRole ) )
        net.Broadcast()

        return cur
    end

end -- Initialize

-- ---------------------------------------------------------------------------
-- Think + periodic behaviors (server)
-- ---------------------------------------------------------------------------
local function Think( self, wepent )
    if CLIENT then return end
    if not GetConVar( "lambdaplayers_friend_enabled" ):GetBool() then return end

    -- Debug lines that visualizes friends
    if dev:GetBool() then
        for ent, aff in pairs( self.l_Friends or {} ) do
            if not IsValid(ent) then continue end
            debugoverlay.Line( self:WorldSpaceCenter(), ent:WorldSpaceCenter(), 0, self:GetPlyColor():ToColor(), true )
        end
    end

    -- broadcast client updates periodically
    if CurTime() > (self.l_friendupdate or 0) then
        self:UpdateClientFriends()
        self.l_friendupdate = CurTime() + 3
    end

    -- Nearby friend discovery + trauma-bond opportunities
    if CurTime() > (self.l_nearbycheck or 0) then
        if not self:InCombat() and random( 0, 100 ) <= 5 then
            local nearest = self:GetClosestEntity( nil, 200, function( ent ) return ent.IsLambdaPlayer or ent:IsPlayer() end )
            if IsValid( nearest ) then
                self:AddFriend( nearest )
            end
        end

        -- trauma bond: if near a friend during a big event (we'll approximate by seeing large damage or explosions)
        -- This is simplified: when a Lambda sees another Lambda take big damage and both survive we boost affinity.
        -- Hooked in OnOtherInjured below for discrete events.

        self.l_nearbycheck = CurTime() + 15
    end

    -- periodic affinity decay (per minute)
    if CurTime() > (self.l_lastAffinityDecay or 0) then
        local decay = GetConVar( "lambdaplayers_friend_affinity_decay" ):GetInt()
        if decay > 0 and self.l_Friends then
            for ent, aff in pairs( table.Copy(self.l_Friends) ) do
                if not IsValid(ent) then
                    self.l_Friends[ ent ] = nil
                else
                    -- reduce affinity for distant friends
                    local dist = self:GetRangeTo( ent ) or 9999
                    if dist > 2000 then
                        self:AdjustFriendAffinity( ent, -decay )
                    else
                        -- small passive decay if not interacting at all
                        self:AdjustFriendAffinity( ent, -math.max(0, decay / 3) )
                    end
                end
            end
        end
        self.l_lastAffinityDecay = CurTime() + 60
    end

end

-- Prevent damage from friends (legacy and new systems)
local function OnInjured( self, info )
    if not GetConVar( "lambdaplayers_friend_friendlyfire" ):GetBool() and self:IsFriendsWith( info:GetAttacker() ) then return true end
end

-- Move behavior: following friends / role-driven movement
local function OnMove( self, pos, isonnavmesh )
    if not GetConVar( "lambdaplayers_friend_enabled" ):GetBool() then return end

    if ( not GetConVar( "lambdaplayers_friend_alwaysstaynearfriends" ):GetBool() and random( 0, 100 ) < 30) then return end
    local friend = self:GetRandomFriend( GetConVar( "lambdaplayers_friend_alwaysstaynearplayers" ):GetBool() )

    if IsValid( friend ) then
        local navarea = navmesh.GetNavArea( friend:WorldSpaceCenter(), 500 )
        local targetpos = IsValid( navarea ) and navarea:GetClosestPointOnArea( friend:GetPos() + VectorRand( -1000, 1000 ) ) or friend:GetPos() + VectorRand( -1000, 1000 )

        -- Role behavior: Guardians prefer to be near friend and defend
        local role = (self.l_friendroles and self.l_friendroles[ friend ]) or DefaultRole
        if role == FriendRoles.GUARDIAN then
            targetpos = friend:GetPos() + (friend:GetForward() * -100) -- stay slightly behind/near
        elseif role == FriendRoles.SCOUT then
            targetpos = friend:GetPos() + (friend:GetForward() * 200) + VectorRand() * 100
        elseif role == FriendRoles.MEDIC then
            targetpos = friend:GetPos() + VectorRand() * 80
        end

        self:RecomputePath( targetpos )
    end
end

-- Defend our friends if we see the attacker; also attempt to form handshake when accidental hits are resolved
local function OnOtherInjured( self, victim, info, took )
    if not took or info:GetAttacker() == self then return end

    -- existing defend logic preserved
    if self:IsFriendsWith( victim ) and not LambdaIsValid( self:GetEnemy() ) and self:CanTarget( info:GetAttacker() ) and self:CanSee( info:GetAttacker() ) then
        self:AttackTarget( info:GetAttacker() )
    elseif self:IsFriendsWith( info:GetAttacker() ) and not LambdaIsValid( self:GetEnemy() ) and self:CanTarget( victim ) and self:CanSee( victim ) then
        self:AttackTarget( victim )
    end

    -- if victim was fighting the attacker and survives, there is a chance to add the attacker as a friend (for social bonding / respect)
    if victim == self:GetEnemy() and info:GetAttacker() ~= self and random( 0, 100 ) <= 10  then
        self:AddFriend( info:GetAttacker() )
    end

    -- Trauma bond logic: if two lambdas survive a dangerous event (big damage) and both near each other, increase affinity
    -- We'll treat any 'took' damage >= threshold as traumatic
    local damage = info:GetDamage() or 0
    local traumaThreshold = 35
    if damage >= traumaThreshold and IsValid( victim ) and victim.IsLambdaPlayer and self:IsFriendsWith( victim ) then
        local bonus = GetConVar( "lambdaplayers_friend_traumabond_bonus" ):GetInt()
        self:AdjustFriendAffinity( victim, bonus )
    end

    -- If a friend is critically downed (simulate with health <= 0 or a 'dead' flag), nearby friends may attempt revive
    if IsValid( victim ) and victim:IsPlayer() and victim:Health() <= 0 then
        -- search for friends nearby who can help
        for ent, aff in pairs( self.l_Friends or {} ) do
            if not IsValid(ent) then continue end
            local dist = ent:GetPos():Distance( victim:GetPos() )
            if dist <= 200 and random( 0, 100 ) <= GetConVar( "lambdaplayers_friend_revive_chance" ):GetInt() then
                -- simple revive action:
                if ent ~= victim and ent:Visible( victim ) then
                    -- attempt revive: set a small health, call a function if exists or directly set
                    if victim.SetHealth then
                        victim:SetHealth( math.max(1, math.min( 25, victim:Health() + 25 )) )
                    end
                    -- affinity increase for rescuing
                    ent:AdjustFriendAffinity( victim, 10 )
                    LambdaRunHook( "LambdaOnFriendRevived", ent, victim )
                end
            end
        end
    end
end

-- Hook for picking up items: friend adopting props & friend-making on healing gift
local ishealing = {
    [ "item_healthkit" ] = true,
    [ "item_healthvial" ] = true,
    [ "item_battery" ] = true,
    [ "sent_ball" ] = true
}

local function OnPickupEnt( self, ent )
    if not IsValid(ent) then return end
    -- heal-gift -> friend acknowledgement
    if ishealing[ ent:GetClass() ] and random( 0, 100 ) <= 5 and ( CurTime() - ent:GetCreationTime() ) < 5 and IsValid( ent:GetCreator() ) then
        self:AddFriend( ent:GetCreator() )
    end

    -- adoptive prop: small chance a lambda will adopt a prop and carry it around (adds personality)
    if random(0,100) <= 2 and not self.l_adoptedprop and not ent:IsPlayer() then
        self.l_adoptedprop = ent
        ent:SetNWBool( "LambdaAdopted", true )
        LambdaRunHook( "LambdaOnAdoptProp", self, ent )
    end
end

-- Register hooks
hook.Add( "LambdaOnPickupEnt", "lambdafriendsystemonpickupents", OnPickupEnt )
hook.Add( "LambdaOnProfileApplied", "lambdafriendsystemhandleprofiles", function(self, info)
    -- Keep original profile logic: permafriends string, but make it use the new AddFriend
    local permafriendsstring = self.l_permafriends
    if not permafriendsstring then return end
    local names = string_find( permafriendsstring, "," ) and string_Explode( ",", permafriendsstring ) or { permafriendsstring }

    for k, name in ipairs( names ) do
        local ply = GetPlayerByName( name )
        if IsValid( ply ) then
            self:AddFriend( ply, true )
        else
            ply = GetLambdaPlayerByName( name )
            if IsValid( ply ) then self:AddFriend( ply, true ) end
        end
    end
end )
hook.Add( "LambdaOnBeginMove", "lambdaplayersfriendsystemonbeginmove", OnMove )
hook.Add( "LambdaOnOtherInjured", "lambdaplayersfriendsystemonotherinjured", OnOtherInjured )
hook.Add( "LambdaOnInjured", "lambdaplayersfriendsystemoninjured", OnInjured )
hook.Add( "LambdaOnThink", "lambdaplayersfriendsystemthink", Think )
hook.Add( "LambdaOnInitialize", "lambdaplayersfriendsysteminit", Initialize )

-- Server-only event cleanup and damage blocking
if SERVER then
    -- Remove our friends on removal
    local function OnRemove( self )
        for ID, friend in pairs( self.l_friends or {} ) do
            if IsValid(friend) then
                self:RemoveFriend( friend )
            end
        end
    end

    local function CanTarget( self, target ) -- prevent attacking friends via CanTarget hook
        if self:IsFriendsWith( target ) then return true end
    end

    local function EntityTakeDamage( ent, info )
        local attacker = info:GetAttacker()
        if not GetConVar( "lambdaplayers_friend_friendlyfire" ):GetBool() and ent:IsPlayer() and attacker.IsLambdaPlayer then
            if attacker:IsFriendsWith( ent ) then return true end
        end
    end

    hook.Add("EntityTakeDamage", "lambdafriendsystemtakedamage", EntityTakeDamage )
    hook.Add( "LambdaOnRemove", "lambdafriendsystemOnRemove", OnRemove )
    hook.Add( "LambdaCanTarget", "lambdafriendsystemtarget",  CanTarget )

end

-- ---------------------------------------------------------------------------
-- Client side: halos, HUD, and network receivers (compat + new fields)
-- ---------------------------------------------------------------------------
if CLIENT then
    local AddHalo = halo.Add
    local tracetable = {}
    local Trace = util.TraceLine
    local DrawText = draw.DrawText
    local uiscale = GetConVar( "lambdaplayers_uiscale" )

    local function UpdateFont()
        surface.CreateFont( "lambdaplayers_friendfont", {
            font = "ChatFont",
            size = LambdaScreenScale( 7 + uiscale:GetFloat() ),
            weight = 0,
            shadow = true
        })
    end
    UpdateFont()
    cvars.AddChangeCallback( "lambdaplayers_uiscale", UpdateFont, "lambdafriendsystemfonts" )

    -- PreDrawHalos: halo color changes based on affinity level (read from ent.l_Friends map if available)
    hook.Add( "PreDrawHalos", "lambdafriendsystemhalos", function()
        if not GetConVar( "lambdaplayers_friend_drawhalo" ):GetBool() then return end
        local friends = LocalPlayer().l_friends
        if friends then
            for k, v in pairs( friends ) do
                if not LambdaIsValid( v ) or not v:IsBeingDrawn() then continue end
                local affinity = LocalPlayer().l_Friends and LocalPlayer().l_Friends[ v ] or 50
                local _, color = AffinityToLevel( affinity )
                AddHalo( { v }, color, 3, 3, 1, true, false )
            end
        end
    end )

    -- HUD: Draw friend tag & list with affinity
    hook.Add( "HUDPaint", "lambdafriendsystemhud", function()
        local friends = LocalPlayer().l_friends
        if friends then
            for k, v in pairs( friends ) do
                if not LambdaIsValid( v ) or not v:IsBeingDrawn() then continue end
                tracetable.start = LocalPlayer():EyePos()
                tracetable.endpos = v:WorldSpaceCenter()
                tracetable.filter = LocalPlayer()
                local result = Trace( tracetable )
                if result.Entity != v then continue end
                local vectoscreen = ( v:GetPos() + v:OBBCenter() * 2.5 ):ToScreen()
                if not vectoscreen.visible then continue end

                local affinity = LocalPlayer().l_Friends and LocalPlayer().l_Friends[v] or 50
                local levelName, _ = AffinityToLevel( affinity )
                DrawText( result.Entity:Name() .. " (" .. levelName .. ")", "lambdaplayers_friendfont", vectoscreen.x, vectoscreen.y, v:GetDisplayColor(), TEXT_ALIGN_CENTER )
            end
        end

        local sw, sh = ScrW(), ScrH()
        local traceent = LocalPlayer():GetEyeTrace().Entity

        if LambdaIsValid( traceent ) and traceent.IsLambdaPlayer then
            local name = traceent:GetLambdaName()
            local buildstring = "Friends With: "
            local friends = traceent.l_friends

            if friends and not table_IsEmpty( friends ) then
                local count = 0
                local others = 0
                for k, v in pairs( friends ) do
                    if not IsValid( v ) then friends[ k ] = nil continue end
                    count = count + 1

                    if count > 3 then others = others + 1 continue end

                    buildstring = buildstring .. (v:IsPlayer() and v:Nick() or v:GetLambdaName()) .. ( table_Count( friends ) > count and ", " or "" )
                end
                buildstring = others > 0 and buildstring .. " and " .. ( others ) .. ( others > 1 and " others" or " other") or buildstring
                DrawText( buildstring, "lambdaplayers_displayname", ( sw / 2 ), ( sh / 1.77 ) + LambdaScreenScale( 1 + uiscale:GetFloat() ), traceent:GetDisplayColor(), TEXT_ALIGN_CENTER)
            end
        end

    end )

    -- Net receiver for legacy addfriend (keeps legacy behavior)
    net.Receive( "lambdaplayerfriendsystem_addfriend", function()
        local id = net.ReadUInt( 32 )
        local lambda = net.ReadEntity()
        local receiver = net.ReadEntity()
        receiver.l_friends = receiver.l_friends or {}
        if not receiver.l_friends then return end
        receiver.l_friends[ id ] = lambda
    end )

    -- Net receiver for legacy removefriend
    net.Receive( "lambdaplayerfriendsystem_removefriend", function()
        local id = net.ReadUInt( 32 )
        local receiver = net.ReadEntity()
        if not receiver.l_friends then return end
        receiver.l_friends[ id ] = nil
    end )

    -- Net receiver for detailed friend updates (affinity + role)
    net.Receive( "lambdaplayerfriendsystem_updatefriend", function()
        local a = net.ReadEntity() -- sender
        local b = net.ReadEntity() -- friend
        local affinity = net.ReadUInt( 8 )
        local role = net.ReadString()

        if not IsValid(a) or not IsValid(b) then return end
        a.l_Friends = a.l_Friends or {}
        a.l_friendroles = a.l_friendroles or {}
        a.l_friends = a.l_friends or {}

        a.l_Friends[ b ] = affinity
        a.l_friendroles[ b ] = role
        a.l_friends[ b:GetCreationID() ] = b
    end )

end -- CLIENT

-- ---------------------------------------------------------------------------
-- Utility EntMeta helpers (affinity-based API)
-- ---------------------------------------------------------------------------
local table_insert = table.insert
local table_remove = table.RemoveByValue

-- Ensure globals for management
LambdaFriendSystem = LambdaFriendSystem or {}

local EntMeta = FindMetaTable( "Entity" ) or {}

-- Returns friend table { ent -> affinity }
function EntMeta:GetFriendsTable()
    self.l_Friends = self.l_Friends or {}
    return self.l_Friends
end

function EntMeta:IsFriend( ent )
    if not IsValid( ent ) then return false end
    local t = self:GetFriendsTable()
    return t[ ent ] ~= nil
end

-- Set friend with affinity (API for other modules)
function EntMeta:AddFriend( ent, affinity )
    if not IsValid( ent ) or ent == self then return end
    self.l_Friends = self.l_Friends or {}
    affinity = tonumber( affinity ) or 50
    self.l_Friends[ ent ] = math.Clamp( affinity, 0, 100 )
    LambdaRunHook( "LambdaOnAddFriend", self, ent, self.l_Friends[ ent ] )
end

function EntMeta:RemoveFriend( ent )
    if not IsValid( ent ) then return end
    if self.l_Friends then
        self.l_Friends[ ent ] = nil
        LambdaRunHook( "LambdaOnRemoveFriend", self, ent )
    end
end

function EntMeta:AdjustFriendAffinity( ent, delta )
    if not IsValid( ent ) or not self.l_Friends then return end
    local cur = self.l_Friends[ ent ] or 0
    cur = math.Clamp( cur + ( tonumber( delta ) or 0 ), 0, 100 )
    self.l_Friends[ ent ] = cur
    LambdaRunHook( "LambdaOnFriendAffinityChanged", self, ent, cur )
    return cur
end

-- Convenience: get highest affinity friend
function EntMeta:GetBestFriend()
    if not self.l_Friends then return nil end
    local best, bestAff
    for ent, aff in pairs( self.l_Friends ) do
        if not IsValid( ent ) then continue end
        if not best or aff > bestAff then best, bestAff = ent, aff end
    end
    return best, bestAff
end
