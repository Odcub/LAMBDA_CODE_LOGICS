-- Lambda Players: Extended Personality System
-- Implements: Independence, Playfulness, Confidence, Patience, Curiosity, Loyalty, Optimism
-- Keeps original personalities and styling conventions

local table_insert = table.insert
local table_sort = table.sort
local FindMetaTable = FindMetaTable
local math_random = math.random

local EntMeta = FindMetaTable( "Entity" ) or {}

if not EntMeta.BuildPersonalityTable then
    function EntMeta:BuildPersonalityTable( preset )
        -- Ensure container
        self.l_Personality = self.l_Personality or {}

        -- Default personality keys used across the addon (lightweight)
        local defaultKeys = {
            "Build", "Combat", "Tool", "Idle", "Follow", "Curiosity", "Confidence",
            "Independence", "Patience", "Playfulness", "Loyalty", "Optimism", "Voice", "Text"
        }

        -- If already populated and no preset request, keep existing
        if #self.l_Personality == 0 then
            for _, key in ipairs( defaultKeys ) do
                local val = math_random( 20, 60 )
                table_insert( self.l_Personality, { key, val } )

                -- create simple accessors on the entity for convenience
                self[ "Get" .. key .. "Chance" ] = function( s ) return s:GetNW2Int( "lambda_chance_" .. key, val ) end
                self[ "Set" .. key .. "Chance" ] = function( s, v ) s:SetNW2Int( "lambda_chance_" .. key, v or val ) end
            end
            table_sort( self.l_Personality, function( a, b ) return a[ 2 ] > b[ 2 ] end )
        end

        -- If a preset was passed and registered, apply it
        if preset and type( preset ) == "string" and LambdaPersonalityPresets and LambdaPersonalityPresets[ preset ] then
            local res = LambdaPersonalityPresets[ preset ]( LocalPlayer and LocalPlayer() or Entity(0), self ) -- protected call path
            if type( res ) == "table" then
                -- apply simple mapping
                for k, v in pairs( res ) do
                    self[ "Set" .. k .. "Chance" ] = self[ "Set" .. k .. "Chance" ] or function( s, val ) s:SetNW2Int( "lambda_chance_" .. k, val ) end
                    self[ "Set" .. k .. "Chance" ]( self, v )
                end
            end
        end
    end
end

local table_insert = table.insert

local RandomPairs = RandomPairs
local tonumber = tonumber

LambdaPersonalities = LambdaPersonalities or {}
LambdaPersonalityConVars = LambdaPersonalityConVars or {}
-- Creates a "Personality" type for the specific function. Every Personality gets created with a chance that will be tested with every other chances ordered from highest to lowest
-- Personalities are called when a Lambda Player is idle and wants to test a chance

local presettbl = {
    [ "Random" ] = "random",
    [ "Builder" ] = "builder",
    [ "Fighter" ] = "fighter",
    [ "Custom" ] = "custom",
    [ "Custom Random" ] = "customrandom"
}

CreateLambdaConvar( "lambdaplayers_personality_preset", "random", true, true, true, "The preset Lambda Personalities should use. Set this to Custom to make use of the chance sliders", nil, nil, { type = "Combo", options = presettbl, name = "Personality Preset", category = "Lambda Player Settings" } )

function LambdaCreatePersonalityType( personalityname, func )
    local convar = CreateLambdaConvar( "lambdaplayers_personality_" .. personalityname .. "chance", 30, true, true, true, "The chance " .. personalityname .. " will be executed. Personality Preset should be set to Custom for this slider to effect newly spawned Lambda Players!", 0, 100, { type = "Slider", decimals = 0, name = personalityname .. " Chance", category = "Lambda Player Settings" } )
    table_insert( LambdaPersonalities, { personalityname, func } )
    table_insert( LambdaPersonalityConVars, { personalityname, convar } )
end


-- Existing behavior implementations (kept mostly intact)
local function Chance_Build( self )
    self:PreventWeaponSwitch( true )

    for index, buildtable in RandomPairs( LambdaBuildingFunctions ) do
        if !buildtable[ 2 ]:GetBool() then continue end

        local name = buildtable[ 1 ]
        if LambdaRunHook( "LambdaOnUseBuildFunction", self, name ) == true then break end

        local result
        local ok, msg = pcall( function() result = buildtable[ 3 ]( self ) end )

        if !ok and name != "entity" and name != "npc" then ErrorNoHaltWithStack( name .. " Building function had a error! If this is from a addon, report it to the author!", msg ) end
        if result then self:DebugPrint( "Used a building function: " .. name ) break end
    end

    self:PreventWeaponSwitch( false )
end



local function Chance_Tool( self )
    self:SwitchWeapon( "toolgun" )
    if self.l_Weapon != "toolgun" then return end

    self.l_IsUsingTool = true
    self:PreventWeaponSwitch( true )

    local find = self:FindInSphere( nil, 400, function( ent ) if self:HasVPhysics( ent ) and self:CanSee( ent ) and self:HasPermissionToEdit( ent ) then return true end end )
    local target = find[ LambdaRNG( #find ) ]

    -- Loops through random tools and only stops if a tool tells us it actually got used by returning true
    for index, tooltable in RandomPairs( LambdaToolGunTools ) do
        if !tooltable[ 2 ]:GetBool() then continue end -- If the tool is allowed

        local name = tooltable[ 1 ]
        if LambdaRunHook( "LambdaOnToolUse", self, name ) == true then break end

        local result
        local ok, msg = pcall( function() result = tooltable[ 3 ]( self, target ) end )

        if !ok then ErrorNoHaltWithStack( name .. " Tool had a error! If this is from a addon, report it to the author!", msg ) end
        if result then self:DebugPrint( "Used " .. name .. " Tool" ) break end
    end

    self.l_IsUsingTool = false
    self:PreventWeaponSwitch( false )
end

local function Chance_Combat( self )
    local rndCombat = LambdaRNG( 3 )
    if rndCombat == 1 then
        self:SetState( "HealUp", "FindTarget" )
    elseif rndCombat == 2 then
        self:SetState( "ArmorUp", "FindTarget" )
    else
        self:SetState( "FindTarget" )
    end
end

local ignorePlys = GetConVar( "ai_ignoreplayers" )
local function Chance_Friendly( self )
    if self:InCombat() or self:IsPanicking() or !self:CanEquipWeapon( "gmod_medkit" ) then return end

    local nearbyEnts = self:FindInSphere( nil, 1000, function( ent )
        if !LambdaIsValid( ent ) or !ent.Health or !ent:IsNPC() and !ent:IsNextBot() and ( !ent:IsPlayer() or !ent:Alive() or ignorePlys:GetBool() ) then return false end
        return ( ent:Health() < ent:GetMaxHealth() and self:CanSee( ent ) )
    end )

    if #nearbyEnts == 0 then return end
    self:SetState( "HealSomeone", nearbyEnts[ LambdaRNG( #nearbyEnts ) ] )
end

-- New personality functions ------------------------------------------------

-- Independence: prefers solo vs team
local function Chance_Independence( self )
    -- If in combat or panicking, avoid changing behavior here
    if self:InCombat() or self:IsPanicking() then return end

    local chance = ( self.GetIndependenceChance and self:GetIndependenceChance() ) or 30
    -- Higher value -> more likely to patrol alone
    if LambdaRNG( 100 ) <= chance then
        -- prefer to patrol away from other lambdas
        self:DebugPrint( "Personality: Independence -> Patrolling alone" )
        self:SetState( "PatrolAlone" )
    else
        -- team-oriented action
        self:DebugPrint( "Personality: Independence -> Staying with team" )
        self:SetState( "FollowPlayer" )
    end
end

-- Playfulness: does silly idle actions or taunts
local function Chance_Playfulness( self )
    if self:InCombat() or self:IsPanicking() then return end

    local chance = ( self.GetPlayfulnessChance and self:GetPlayfulnessChance() ) or 30
    if LambdaRNG( 100 ) <= chance then
        -- Do a random playful idle action
        self:DebugPrint( "Personality: Playfulness -> Doing a playful action" )
        -- Set playful idle; addon state machine should have handlers for IdlePlay/Taunt
        self:SetState( "IdlePlay" )
    else
        -- calm / focused
        self:DebugPrint( "Personality: Playfulness -> Staying serious" )
        self:SetState( "Idle" )
    end
end

-- Confidence: brave vs cautious
local function Chance_Confidence( self )
    if self:IsPanicking() then return end

    local chance = ( self.GetConfidenceChance and self:GetConfidenceChance() ) or 30
    if LambdaRNG( 100 ) <= chance then
        self:DebugPrint( "Personality: Confidence -> Aggressive" )
        -- Aggressive behavior: seek target quickly
        self:SetState( "FindTarget" )
    else
        self:DebugPrint( "Personality: Confidence -> Cautious" )
        -- Cautious: take cover or avoid direct engagement
        self:SetState( "MovingToCover" )
    end
end

-- Patience: wait/ambush vs restless
local function Chance_Patience( self )
    if self:InCombat() or self:IsPanicking() then return end

    local chance = ( self.GetPatienceChance and self:GetPatienceChance() ) or 30
    if LambdaRNG( 100 ) <= chance then
        self:DebugPrint( "Personality: Patience -> Waiting / Ambush" )
        -- Hold position longer / guard
        self:SetState( "Wait" )
    else
        self:DebugPrint( "Personality: Patience -> Restless / Wandering" )
        self:SetState( "Wandering" )
    end
end

-- Curiosity: investigates noises or things around
local function Chance_Curiosity( self )
    if self:InCombat() or self:IsPanicking() then return end

    local chance = ( self.GetCuriosityChance and self:GetCuriosityChance() ) or 30
    if LambdaRNG( 100 ) <= chance then
        -- Try to find interesting nearby things: sounds, props, corpses, lights
        local found = self:FindInSphere( nil, 900, function( ent )
            if !LambdaIsValid( ent ) then return false end
            -- prefer interesting stuff: props, ragdolls, NPCs, lights
            if ent:IsNPC() or ent:IsPlayer() or ent:GetClass():find( "prop_" ) or ent:GetClass():find( "item_" ) or ent:GetClass():find( "light" ) then
                return self:CanSee( ent )
            end
            return false
        end )

        if #found > 0 then
            local target = found[ LambdaRNG( #found ) ]
            self:DebugPrint( "Personality: Curiosity -> Investigating " .. tostring( target:GetClass() or "object" ) )
            self:SetState( "Investigating", target )
            return
        end

        -- fallback: look around
        self:SetState( "IdleLookAround" )
    else
        -- ignore distractions
        self:DebugPrint( "Personality: Curiosity -> Ignoring distractions" )
        self:SetState( "Idle" )
    end
end

-- Loyalty: prioritizes allies and player
local function Chance_Loyalty( self )
    if self:InCombat() or self:IsPanicking() then return end

    local chance = ( self.GetLoyaltyChance and self:GetLoyaltyChance() ) or 30
    if LambdaRNG( 100 ) <= chance then
        -- Try to find allies that need help (players, NPCs)
        local nearbyAllies = self:FindInSphere( nil, 1000, function( ent )
            if !LambdaIsValid( ent ) then return false end
            if ent == self then return false end
            if ent:IsPlayer() and ent:Alive() and !ignorePlys:GetBool() then
                return ( ent:Health() < ent:GetMaxHealth() and self:CanSee( ent ) )
            end
            -- FIX: Changed (ent:GetMaxHealth and...) to (ent.GetMaxHealth and...)
            if ent.Health and ( ent.Health and ent:Health() < ( ent.GetMaxHealth and ent:GetMaxHealth() or 100 ) ) and ( ent:IsNPC() or ent:IsNextBot() ) and self:CanSee( ent ) then
                return true
            end
            return false
        end )

        if #nearbyAllies > 0 and self:CanEquipWeapon( "gmod_medkit" ) then
            self:DebugPrint( "Personality: Loyalty -> Healing/Defending ally" )
            self:SetState( "HealSomeone", nearbyAllies[ LambdaRNG( #nearbyAllies ) ] )
            return
        end

        -- If no heal need, prefer to stick to player / defend
        self:DebugPrint( "Personality: Loyalty -> Defend player / Assist" )
        self:SetState( "DefendAlly" )
    else
        self:DebugPrint( "Personality: Loyalty -> Self-preserve / Independent" )
        self:SetState( "Retreat" )
    end
end

-- Optimism: morale handling
local function Chance_Optimism( self )
    if self:IsPanicking() then return end

    local chance = ( self.GetOptimismChance and self:GetOptimismChance() ) or 30
    if LambdaRNG( 100 ) <= chance then
        -- optimistic: recover quicker, re-engage
        self:DebugPrint( "Personality: Optimism -> Encouraging / Re-engage" )
        -- Try to nudge out of panic or low morale states
        if self:IsPanicking() then
            self:SetState( "PanicRecovery" )
        else
            -- small morale boost action (cheer / encourage)
            self:SetState( "IdleChat" )
        end
    else
        -- pessimistic: complain, higher chance to give up
        self:DebugPrint( "Personality: Optimism -> Pessimistic -> Retreat or Complain" )
        self:SetState( "Panic" )
    end
end

-- Register personalities (existing ones retained)
LambdaCreatePersonalityType( "Build", Chance_Build )
LambdaCreatePersonalityType( "Tool", Chance_Tool )
LambdaCreatePersonalityType( "Combat", Chance_Combat )
LambdaCreatePersonalityType( "Friendly", Chance_Friendly )

-- Register new personalities
LambdaCreatePersonalityType( "Independence", Chance_Independence )
LambdaCreatePersonalityType( "Playfulness", Chance_Playfulness )
LambdaCreatePersonalityType( "Confidence", Chance_Confidence )
LambdaCreatePersonalityType( "Patience", Chance_Patience )
LambdaCreatePersonalityType( "Curiosity", Chance_Curiosity )
LambdaCreatePersonalityType( "Loyalty", Chance_Loyalty )
LambdaCreatePersonalityType( "Optimism", Chance_Optimism )

-- Keep the old 'Cowardly' placeholder if originally intended
LambdaCreatePersonalityType( "Cowardly" )

-- Existing voice/text convars
CreateLambdaConvar( "lambdaplayers_personality_voicechance", 30, true, true, true, "The chance Voice will be executed. Personality Preset should be set to Custom for this slider to effect newly spawned Lambda Players!", 0, 100, { type = "Slider", decimals = 0, name = "Voice Chance", category = "Lambda Player Settings" } )
CreateLambdaConvar( "lambdaplayers_personality_textchance", 30, true, true, true, "The chance Text will be executed. Personality Preset should be set to Custom for this slider to effect newly spawned Lambda Players!", 0, 100, { type = "Slider", decimals = 0, name = "Text Chance", category = "Lambda Player Settings" } )

-- Optional: Expand the custom personality preset panel to include new personalities (existing UI code will pick up new convars automatically)
CreateLambdaConsoleCommand( "lambdaplayers_cmd_opencustompersonalitypresetpanel", function( ply )
    local tbl = {}
    tbl[ "lambdaplayers_personality_voicechance" ] = 30
    tbl[ "lambdaplayers_personality_textchance" ] = 30
    for k, v in ipairs( LambdaPersonalityConVars ) do
        tbl[ v[ 2 ]:GetName() ] = ( tonumber( v[ 2 ]:GetDefault() ) or 30  )
    end
    LAMBDAPANELS:CreateCVarPresetPanel( "Custom Personality Preset Editor", tbl, "custompersonalities", true )
end, true, "Opens a panel to allow you to create custom preset personalities and load them", { name = "Custom Personality Presets", category = "Lambda Player Settings" } )