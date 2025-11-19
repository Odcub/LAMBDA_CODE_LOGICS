-- State functions will now be called according to the self:GetState() variable.
-- For example, if Lambda Player's self:GetState() is equal to "Idle" then it will call the Idle() function
-- Definitely a lot more cleaner this way

local CurTime = CurTime


local ceil = math.ceil
local IsValid = IsValid
local bit_band = bit.band
local coroutine_wait = coroutine.wait
local table_insert = table.insert
local ignoreLambdas = GetConVar( "lambdaplayers_combat_dontrdmlambdas" )
local spawnEntities = GetConVar( "lambdaplayers_building_allowentity" )
local unlimiteddistance = GetConVar( "lambdaplayers_lambda_infwanderdistance" )

local wandertbl = { autorun = true }
function ENT:Idle()
    if LambdaRNG( 100 ) < 70 then
        self:ComputeChance()
        return
    end

    local pos
    if LambdaRNG( 3 ) == 1 then
        local triggers = self:FindInSphere( nil, 2000, function( ent )
            return ( ent:GetClass() == "trigger_teleport" and !ent:GetInternalVariable( "StartDisabled" ) and bit_band( ent:GetInternalVariable( "spawnflags" ), 2 ) == 2 and self:CanSee( ent ) )
        end )

        if #triggers == 0 then return end
        pos = triggers[ LambdaRNG( #triggers ) ]:WorldSpaceCenter()
    end

    self:MoveToPos( ( pos or self:GetRandomPosition( nil, unlimiteddistance:GetBool() ) ), wandertbl )
end

local combattbl = { update = 0.33, run = true, tol = 10 }
local meleetbl = { update = 0.1, run = true, tol = 0 }
function ENT:Combat()
    if !LambdaIsValid( self:GetEnemy() ) then self:SetEnemy( NULL ) return true end
    if !self:HasLethalWeapon() then self:SwitchToLethalWeapon() end
    self:MoveToPos( self:GetEnemy(), ( self.l_HasMelee and meleetbl or combattbl ) )
end

local spawnMedkits = GetConVar( "lambdaplayers_combat_spawnmedkits" )
-- Heal ourselves when hurt
function ENT:HealUp( failState )
    if !spawnEntities:GetBool() or !spawnMedkits:GetBool() or self:Health() >= self:GetMaxHealth() then
        return ( failState or true )
    end
    if !self.l_isswimming and !self:IsInNoClip() and !self.loco:IsOnGround() then
        return
    end

    local rndVec = ( self:GetForward() * LambdaRNG( 16, 24 ) + self:GetRight() * LambdaRNG( -24, 24 ) - vector_up * 8 )
    if !self:Trace( ( self:GetPos() + rndVec ), self:EyePos() ).Hit then
        self:MoveToPos( self:GetRandomPosition( nil, 100 ) )
        if !self:GetState( "HealUp" ) then return true end
    end

    local spawnRate = LambdaRNG( 0.15, 0.4, true )
    coroutine_wait( spawnRate )

    local spawnCount = ceil( ( self:GetMaxHealth() - self:Health() ) / 25 )
    for i = 1, LambdaRNG( ( spawnCount / 2 ), spawnCount ) do
        if self:InCombat() or self:IsPanicking() or !self:IsUnderLimit( "Entity" ) then break end
        if self:Health() >= self:GetMaxHealth() then break end

        local lookPos = ( self:GetPos() + rndVec )
        self:LookTo( lookPos, spawnRate * 2 )

        local healthkit = LambdaSpawn_SENT( self, "item_healthkit", self:Trace( lookPos, self:EyePos() ) )
        if !IsValid( healthkit ) then break end

        self:DebugPrint( "spawned an entity item_healthkit" )
        self:ContributeEntToLimit( healthkit, "Entity" )
        table_insert( self.l_SpawnedEntities, 1, healthkit )

        coroutine_wait( spawnRate )
    end

    return true
end

local spawnBatteries = GetConVar( "lambdaplayers_combat_spawnbatteries" )
-- Armor ourselves for better chance at surviving in combat
function ENT:ArmorUp( failState )
    if !spawnEntities:GetBool() or !spawnBatteries:GetBool() or self:Armor() >= self:GetMaxArmor() then
        return ( failState or true )
    end
    if !self.l_isswimming and !self:IsInNoClip() and !self.loco:IsOnGround() then
        return
    end

    local rndVec = ( self:GetForward() * LambdaRNG( 16, 24 ) + self:GetRight() * LambdaRNG( -24, 24 ) - vector_up * 8 )
    if !self:Trace( ( self:GetPos() + rndVec ), self:EyePos() ).Hit then
        self.l_noclipheight = 0
        self:MoveToPos( self:GetRandomPosition( nil, 100 ) )
        if !self:GetState( "ArmorUp" ) then return true end
    end

    local spawnRate = LambdaRNG( 0.15, 0.4, true )
    coroutine_wait( spawnRate )

    local spawnCount = ceil( ( self:GetMaxArmor() - self:Armor() ) / 15 )
    for i = 1, LambdaRNG( ( spawnCount / 3 ), spawnCount ) do
        if self:InCombat() or self:IsPanicking() or !self:IsUnderLimit( "Entity" ) then break end
        if self:Armor() >= self:GetMaxArmor() then break end

        local lookPos = ( self:GetPos() + rndVec )
        self:LookTo( lookPos, spawnRate * 2 )

        local battery = LambdaSpawn_SENT( self, "item_battery", self:Trace( lookPos, self:EyePos() ) )
        if !IsValid( battery ) then break end

        self:DebugPrint( "spawned an entity item_battery" )
        self:ContributeEntToLimit( battery, "Entity" )
        table_insert( self.l_SpawnedEntities, 1, battery )

        coroutine_wait( spawnRate )
    end

    return true
end

function ENT:CombatSpawnBehavior( target )
    if LambdaRNG( 3 ) == 1 then self:ArmorUp() end
    if !IsValid( target ) or !self:CanTarget( target ) then return true end
    self:AttackTarget( target )
end

-- Wander around until we find someone to jump
local ft_options = { cbTime = 0.5, callback = function( lambda )
    if lambda:InCombat() or !lambda:GetState( "FindTarget" ) then return false end

    local ene = lambda:GetEnemy()
    if LambdaIsValid( ene ) and lambda:CanTarget( ene ) then
        lambda:AttackTarget( ene )
        return false
    end
    lambda:SetEnemy( NULL )

    local dontRDMLambdas = ignoreLambdas:GetBool()
    local findTargets = lambda:FindInSphere( nil, 2000, function( ent )
        if ent.IsLambdaPlayer and dontRDMLambdas then return false end
        return ( lambda:CanTarget( ent ) and lambda:CanSee( ent ) )
    end )
    if #findTargets != 0 then
        local rndTarget = findTargets[ LambdaRNG( #findTargets ) ]
        if rndTarget.IsLambdaPlayer and rndTarget:IsPanicking() and LambdaRNG( 3 ) == 1 and LambdaRNG( 100 ) <= lambda:GetCombatChance() and LambdaIsValid( rndTarget:GetEnemy() ) then
            rndTarget = rndTarget:GetEnemy()
        end

        lambda:AttackTarget( rndTarget )
        return false
    end
end }
function ENT:FindTarget()
    if !self:HasLethalWeapon() then self:SwitchToLethalWeapon() end
    ft_options.walk = ( LambdaRNG( 8 ) == 1 )
    self:MoveToPos( self:GetRandomPosition( nil, 2000 ), ft_options )
    return ( LambdaRNG( 100 ) > self:GetCombatChance() )
end

-- We look for a button and press it
function ENT:PushButton( button )
    if IsValid( button ) then
        self:LookTo( button, 1 )
        coroutine_wait( 1 )

        if IsValid( button ) then
            local pos = button:GetPos()
            self:MoveToPos( pos + self:GetNormalTo( pos ) * -60 )

            if IsValid( button ) then
                local class = button:GetClass()
                if class == "func_button" then
                    button:Fire( "Press" )
                elseif class == "gmod_button" then
                    button:Toggle( !button:GetOn(), self )
                elseif class == "gmod_wire_button" then
                    button:Switch( !button:GetOn() )
                end

                button:EmitSound( "HL2Player.Use" )
            end
        end
    end

    return true
end

function ENT:Laughing( args )
    if !args or !istable( args ) then return true end

    local target = args[ 1 ]
    if isentity( target ) and !IsValid( target ) then return true end

    if target.IsLambdaPlayer or target:IsPlayer() then
        local ragdoll = target:GetRagdollEntity()
        if IsValid( ragdoll ) then target = ragdoll end
    end
    self:LookTo( target, 1, false, 3 )

    local laughDelay = ( LambdaRNG( 1, 6 ) * 0.1 )
    self:PlaySoundFile( "laugh", laughDelay )

    local movePos = args[ 2 ]
    local actTime = ( laughDelay * LambdaRNG( 0.8, 1.2, true ) )
    if !movePos then
        coroutine_wait( actTime )
    else
        self:MoveToPos( movePos, { run = false, cbTime = actTime, callback = function( self ) return false end } )
    end

    if !self.l_preventdefaultspeak and !self:IsSpeaking( "laugh" ) then self:PlaySoundFile( "laugh", false ) end
    if self:GetState( "Laughing" ) then self:PlayGestureAndWait( ACT_GMOD_TAUNT_LAUGH ) end

    return self:GetLastState()
end

local acts = { ACT_GMOD_TAUNT_DANCE, ACT_GMOD_TAUNT_ROBOT, ACT_GMOD_TAUNT_MUSCLE, ACT_GMOD_TAUNT_CHEER }
function ENT:UsingAct()
    self:PlayGestureAndWait( acts[ LambdaRNG( #acts ) ] )
    return true
end

-- MW2/Halo lives in us forever
local t_options = { run = true, callback = function( lambda )
    if !lambda:GetState( "TBaggingPosition" ) then return false end
end }
function ENT:TBaggingPosition( pos )
    self:MoveToPos( pos, t_options )

    for i = 1, LambdaRNG( 3, 10 ) do
        if !self:GetState( "TBaggingPosition" ) then return end

        self:SetCrouch( true )
        coroutine_wait( 0.2 )

        self:SetCrouch( false )
        coroutine_wait( 0.2 )
    end

    return true
end

local retreatOptions = { run = true, callback = function( lambda )
    local target = lambda:GetEnemy()
    if CurTime() >= lambda.l_retreatendtime or IsValid( target ) and ( ( target.IsLambdaPlayer or target:IsPlayer() ) and !target:Alive() or !lambda:IsInRange( target, 3000 ) ) then
        lambda.l_retreatendtime = 0
    end
end }
function ENT:Retreat()
    if CurTime() >= self.l_retreatendtime then return true end

    local rndPos = self:GetRandomPosition( nil, 2500, function( selfPos, area, rndPoint )
        if !IsValid( target ) then return end

        local targetPos = target:GetPos()
        if rndPoint:DistToSqr( targetPos ) > 250000 and ( targetPos - selfPos ):GetNormalized():Dot( ( rndPoint - selfPos ):GetNormalized() ) <= 0.2 then return end

        return true
    end )
    self:MoveToPos( rndPos, retreatOptions )
end

function ENT:HealSomeone( target )
    if !LambdaIsValid( target ) or target:Health() >= target:GetMaxHealth() or target.GetEnemy and target:GetEnemy() == self then
        return true
    end

    if self.l_Weapon != "gmod_medkit" then
        if !self:CanEquipWeapon( "gmod_medkit" ) then return true end
        self:SwitchWeapon( "gmod_medkit" )
    end

    if self:IsInRange( target, 64 ) then
        self:LookTo( target, 1 )
        self:UseWeapon( target )

        if target.IsLambdaPlayer and !target.l_preventdefaultspeak and target:Health() >= target:GetMaxHealth() then
            target:LookTo( self, 1 )
            target:PlaySoundFile( "assist" )
        end
    else
        local cancelled = false
        self:PreventWeaponSwitch( true )

        self:MoveToPos( target, { run = true, update = 0.2, tol = 48, callback = function()
            if !self:GetState( "HealSomeone" ) or self:Health() < self:GetMaxHealth() then cancelled = true return false end
            if !LambdaIsValid( target ) then cancelled = true return false end
            if target:Health() >= target:GetMaxHealth() then cancelled = true return false end
            if target.IsLambdaPlayer and target:GetEnemy() == self then cancelled = true return false end
            if self:IsInRange( target, 64 ) then return false end
        end } )

        self:PreventWeaponSwitch( false )
        if cancelled then return true end
    end
end

-- ======================================================
-- New states implemented from "LambdaPlayers New States (Concept)"
-- Investigating, Hiding, MovingToCover, Distracting
-- These are deliberately lightweight but integrate with the
-- existing movement/behavior helpers in this file.
-- ======================================================

-- Investigating: walk toward suspicious position and look around
local investigateOptions = { run = false, update = 0.5, tol = 32 }
function ENT:Investigating( pos )
    -- pos can be provided by the caller (e.g. a sound location). If not, pick a nearby random
    if !pos or pos == vector_huge then
        pos = self:GetRandomPosition( nil, 400 )
    end

    -- Walk slowly to the suspicious location
    self:MoveToPos( pos, investigateOptions )

    -- Look around for a short time
    if !self:GetState( "Investigating" ) then return true end
    self:PlaySoundFile( "notice", 0.2 )

    -- perform look-around gestures (if available)
    for i = 1, LambdaRNG( 2, 4 ) do
        if !self:GetState( "Investigating" ) then return true end
        self:LookTo( pos + Vector( LambdaRNG( -64, 64 ), LambdaRNG( -64, 64 ), LambdaRNG( -8, 16 ) ), 0.7 )
        coroutine_wait( LambdaRNG( 0.6, 1.2, true ) )

        -- Re-check for enemies while investigating
        local found = self:FindInSphere( nil, 1500, function( ent )
            return ( not ent.IsLambdaPlayer or ( not ignoreLambdas:GetBool() ) ) and self:CanTarget( ent ) and self:CanSee( ent )
        end )
        if #found > 0 then
            local target = found[ LambdaRNG( #found ) ]
            -- if threat is detected, decide between combat or hiding based on panic/odds
            if self:IsPanicking() or LambdaRNG( 100 ) > self:GetCombatChance() then
                self:SetEnemy( target )
                self:SetState( "Hiding" )
                return true
            else
                self:AttackTarget( target )
                return true
            end
        end
    end

    -- nothing found, shrug it off
    self:PlaySoundFile( "idle", false )
    return true
end

-- Hiding: find a dark corner, crouch and stay still to reduce detection
local hidingOptions = { run = false, update = 0.5, tol = 32 }
function ENT:Hiding()
    -- Try to find a nearby position to hide
    local hidePos = self:GetRandomPosition( nil, 600 )
    if !hidePos then return true end

    -- Move to the chosen hide spot (walk or jog depending on panic)
    local runToHide = self:IsPanicking() or ( LambdaRNG( 100 ) <= ( 100 - self:GetCombatChance() ) )
    self:MoveToPos( hidePos, { run = runToHide, update = 0.3, tol = 28 } )

    if !self:GetState( "Hiding" ) then return true end

    -- Crouch and reduce movement/detection behavior
    self:SetCrouch( true )
    self.l_IsHiding = true
    if !self.l_preventdefaultspeak then self:PlaySoundFile( "shush", false ) end

    local hideStart = CurTime()
    local hideDuration = LambdaRNG( 4, 10 )
    while CurTime() - hideStart < hideDuration do
        if !self:GetState( "Hiding" ) then break end

        -- If enemy no longer present near the area, stop hiding
        local enemy = self:GetEnemy()
        if !LambdaIsValid( enemy ) or ( enemy and !self:IsInRange( enemy, 2000 ) ) then
            break
        end

        -- If spotted while hiding, try to move to cover or panic-run
        if LambdaIsValid( enemy ) and self:CanSee( enemy ) and self:VisibleTo( enemy ) then
            -- prefer moving to cover if available
            if self:CanEquipWeapon( "gmod_pistol" ) and LambdaRNG( 2 ) == 1 then
                self:SetState( "MovingToCover" )
            else
                self.l_Panicking = true
                self:SetState( "Retreat" )
            end
            return true
        end

        coroutine_wait( 0.5 )
    end

    -- done hiding
    self.l_IsHiding = false
    self:SetCrouch( false )
    return true
end

-- MovingToCover: sprint to nearest cover, peek and use weapons from safety
local coverOptions = { run = true, update = 0.2, tol = 24 }
function ENT:MovingToCover( target )
    -- If there's a specific target (enemy), try to pick a position away from them, else just find close cover
    local coverPos
    if LambdaIsValid( target ) then
        -- attempt to pick a point opposite the target direction
        local dir = ( self:GetPos() - target:GetPos() ):GetNormalized()
        coverPos = self:GetRandomPosition( nil, 400, function( selfPos, area, rndPoint )
            return ( rndPoint - selfPos ):Dot( dir ) > 0.2
        end )
    end

    coverPos = coverPos or self:GetRandomPosition( nil, 400 )
    if !coverPos then return true end

    self:MoveToPos( coverPos, coverOptions )

    if !self:GetState( "MovingToCover" ) then return true end

    -- peek and fire small bursts if we have a weapon
    local peekTimes = LambdaRNG( 1, 3 )
    for i = 1, peekTimes do
        if !self:GetState( "MovingToCover" ) then return true end
        local ene = self:GetEnemy()
        if LambdaIsValid( ene ) and self:CanSee( ene ) then
            -- look at enemy and fire a few shots
            self:LookTo( ene, 0.3 )
            if self:HasLethalWeapon() then
                self:UseWeapon( ene )
                coroutine_wait( LambdaRNG( 0.2, 0.6, true ) )
            end
        else
            -- peek around
            self:LookTo( coverPos + Vector( LambdaRNG( -64, 64 ), LambdaRNG( -64, 64 ), LambdaRNG( -8, 16 ) ), 0.6 )
            coroutine_wait( 0.6 )
        end
    end

    -- decide next state: go back to combat if enemy still present or hide
    local ene = self:GetEnemy()
    if LambdaIsValid( ene ) and self:CanSee( ene ) then
        if LambdaRNG( 100 ) <= self:GetCombatChance() then
            self:SetState( "Combat" )
        else
            self:SetState( "Hiding" )
        end
        return true
    end

    return true
end

-- Distracting: try to draw enemy attention by shooting/throwing or making noise
local distractOptions = { run = true, update = 0.25, tol = 40 }
function ENT:Distracting( ally )
    -- ally: optional entity the lambda is trying to distract for
    local ene = self:GetEnemy()

    -- If no enemy, attempt to find one to distract
    if !LambdaIsValid( ene ) then
        local find = self:FindInSphere( nil, 2000, function( ent )
            return ( not ent.IsLambdaPlayer or ( not ignoreLambdas:GetBool() ) ) and self:CanTarget( ent ) and self:CanSee( ent )
        end )
        if #find > 0 then ene = find[ LambdaRNG( #find ) ] end
    end

    if !LambdaIsValid( ene ) then return true end

    -- Move towards the enemy to draw attention, but keep a safe distance
    local distractPos = ( ene:GetPos() + ( ( self:GetPos() - ene:GetPos() ):GetNormalized() * 200 ) )
    self:MoveToPos( distractPos, distractOptions )

    if !self:GetState( "Distracting" ) then return true end

    -- Make noise / taunt
    if !self.l_preventdefaultspeak then
        self:PlaySoundFile( "taunt", false )
    end

    -- If we have a throwable/weapon, attempt to fire or use it erratically to pull aggro
    if self:HasLethalWeapon() then
        for i = 1, LambdaRNG( 2, 5 ) do
            if !self:GetState( "Distracting" ) then break end
            if !LambdaIsValid( ene ) then break end
            self:LookTo( ene, 0.2 )
            self:UseWeapon( ene )
            coroutine_wait( LambdaRNG( 0.25, 0.6, true ) )
        end
    else
        -- Make prop-noise or run and shout
        for i = 1, LambdaRNG( 1, 3 ) do
            if !self:GetState( "Distracting" ) then break end
            self:PlaySoundFile( "distract", 0.1 )
            coroutine_wait( LambdaRNG( 0.5, 1.0, true ) )
        end
    end

    -- After distraction attempt, retreat to ally or safe location
    if ally and IsValid( ally ) then
        self:MoveToPos( ally, { run = true, update = 0.25, tol = 48 } )
    else
        local retreatPos = self:GetRandomPosition( nil, 300 )
        if retreatPos then self:MoveToPos( retreatPos, { run = true, update = 0.25, tol = 48 } ) end
    end

    return true
end

-- End of added states