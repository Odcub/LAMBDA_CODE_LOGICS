-- lua/lambdaplayers/extaddon/shared/lambdaplayers_disablelambda_collisions.lua
-- Disables collisions between Lambda Players when enabled, persistent across respawns.

local CreateLambdaConvar = CreateLambdaConvar
local GetConVar = GetConVar
local IsValid = IsValid
local COLLISION_GROUP_DEBRIS = COLLISION_GROUP_DEBRIS
local COLLISION_GROUP_NPC = COLLISION_GROUP_NPC
local timer_Simple = timer.Simple

-- Server toggle
CreateLambdaConvar(
    "lambdaplayers_disablelambda_collisions",
    0,
    true, false, false,
    "If enabled, Lambda Players will not collide with each other.",
    0, 1,
    { type = "Bool", name = "Disable Lambda Collisions", category = "Lambda Server Settings" }
)

-- Apply setting to a Lambda
local function ApplyCollisionSetting(self)
    if not IsValid(self) or not self.IsLambdaPlayer then return end

    local enabled = GetConVar("lambdaplayers_disablelambda_collisions"):GetBool()

    if enabled then
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self.l_nocollideflag = true
        self:SetNW2Bool("lambda_nocollide", true)
    else
        self:SetCollisionGroup(COLLISION_GROUP_NPC)
        self.l_nocollideflag = false
        self:SetNW2Bool("lambda_nocollide", false)
    end
end

-- Shared helper for both init and respawn
local function SetupNoCollide(self)
    self.l_nocollideflag = self.l_nocollideflag or false
    -- Delay one tick so base code can finish overriding stuff
    timer_Simple(0, function()
        if IsValid(self) then
            ApplyCollisionSetting(self)
        end
    end)
end

-- Initial spawn
hook.Add("LambdaOnInitialize", "lambdaplayers_disablelambda_collisions", SetupNoCollide)

-- Respawn (this is what you were missing)
hook.Add("LambdaOnRespawn", "lambdaplayers_disablelambda_collisions", SetupNoCollide)
