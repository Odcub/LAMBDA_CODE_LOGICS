if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)
ENT.Building = true  -- Add this to mark as building

-- Misc --
ENT.PrintName = "Lambda ReAnimen"
ENT.Category = "Lambda Builds"
ENT.Models = {"models/player/kill01/reanimen.mdl"}
ENT.Skins = {0}
ENT.ModelScale = 1.25
ENT.CollisionBounds = Vector(10, 10, 65)
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true

-- Stats --
ENT.SpawnHealth = 950 or 1200 or 1500 or 2000 or 2500
ENT.HealthRegen = 10 or 20 or 30 or 40 or 50

-- Custom Stats --
ENT.DamageImmunity = {
    DMG_ACID, 
    DMG_DISSOLVE, 
    DMG_BULLET, 
    DMG_SLASH, 
    DMG_POISON, 
}
ENT.DamageImmunityLevel = 95

-- AI --
ENT.Omniscient = false
ENT.SpotDuration = 30
ENT.RangeAttackRange = 750
ENT.MeleeAttackRange = 65
ENT.ReachEnemyRange = 65

-- Relationships --
ENT.Factions = {}
ENT.Frightening = true
ENT.AllyDamageTolerance = 0
ENT.AfraidDamageTolerance = 0
ENT.NeutralDamageTolerance = 0

-- Locomotion --
ENT.Acceleration = 1000
ENT.Deceleration = 1000
ENT.JumpHeight = 50
ENT.StepHeight = 20
ENT.MaxYawRate = 250
ENT.DeathDropHeight = 200

-- Animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.WalkAnimRate = 1
ENT.RunAnimation = ACT_HL2MP_RUN
ENT.RunAnimRate = 1
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.IdleAnimRate = 1
ENT.JumpAnimation = ACT_HL2MP_JUMP
ENT.JumpAnimRate = 1

-- Movements --
ENT.WalkSpeed = 100
ENT.RunSpeed = 300

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(0, 0, 0)
ENT.EyeAngle = Angle(0, 0, 0)
ENT.SightFOV = 150
ENT.SightRange = 15000
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
ENT.HearingCoefficient = 1

-- Weapons --
ENT.UseWeapons = false
ENT.AcceptPlayerWeapons = false

-- Possession --
ENT.PossessionEnabled = false
ENT.PossessionPrompt = false

if SERVER then
    function ENT:CustomInitialize() 
        local Creator = self:GetCreator()
    
        self:SetDefaultRelationship(D_HT)
        self:SetPlayersRelationship(D_HT, 2)
    
        if IsValid(Creator) and Creator:IsPlayer() then
            self:SetColor(team.GetColor(Creator:Team()))
            self:SetNWString("Team", Creator:Team())
            self:SetNWString("TeamName", team.GetName(Creator:Team()))
            self:SetNWString("BuildBy", Creator:Nick())
            PrintMessage(HUD_PRINTTALK, Creator:Nick() .. " has spawned ReAnimen (".. self:GetNWString("TeamName") .. ")")
        else
            self:SetColor(Color(255, 255, 255)) -- Default color
            self:SetNWString("Team", "NoTeam")
            self:SetNWString("TeamName", "Unknown Team")
            self:SetNWString("BuildBy", "Unknown")
            PrintMessage(HUD_PRINTTALK, "An unknown source has spawned ReAnimen (Unknown Team)")
        end
    
        self.ZombieCrawl_Running = false
        self.RageMode = false
        self.LastLeap = 0
        self.LastFrenzy = 0
        self.LastMeleeAttack = 0
        self.MeleeAttackCooldown = 0.5
        self.RageMeleeCooldown = 0.2
    end    

    function ENT:CustomThink() 
        if self:Health() < self:GetMaxHealth() * 0.5 and not self.RageMode then
            self.RageMode = true
            self:EmitSound("npc/zombie/zombie_alert" .. math.random(1, 3) .. ".wav")
        end
        
        if math.random(1, 100) <= 30 and not self.ZombieCrawl_Running then
            self.ZombieCrawl_Running = true
        end

        -- Only target enemies
        local entities = ents.FindInSphere(self:GetPos(), 1000)
        for _, ent in pairs(entities) do
            if ((ent:IsPlayer() or ent.IsLambdaPlayer) and ent:Team() ~= self:GetNWString("Team")) then
                self:SpotEntity(ent)
            end
        end
    end

    function ENT:OnMeleeAttack(enemy) 
        if not IsValid(enemy) then return end
        
        local currentTime = CurTime()
        local cooldown = self.RageMode and self.RageMeleeCooldown or self.MeleeAttackCooldown
        
        if currentTime - self.LastMeleeAttack < cooldown then return end
        
        if self.RageMode then
            if currentTime - self.LastFrenzy > 5 then
                self:PlaySequence("zombie_attack_frenzy", -1)
                self.LastFrenzy = currentTime
                enemy:TakeDamage(math.random(80, 150), self, self)
            else
                local attack_seq = "zombie_attack_0" .. math.random(1, 7)
                self:PlaySequence(attack_seq)
                enemy:TakeDamage(math.random(60, 120), self, self)
            end
        else
            if math.random(1, 2) == 1 then
                self:PlaySequence("range_fists_l")
            else
                self:PlaySequence("range_fists_r")
            end
            enemy:TakeDamage(math.random(50, 100), self, self)
        end
        
        self.LastMeleeAttack = currentTime
        
        if math.random(1, 100) <= (self.RageMode and 60 or 40) then
            local pushForce = Vector(0, 0, 200) + (enemy:GetPos() - self:GetPos()):GetNormalized() * (self.RageMode and 700 or 500)
            enemy:SetVelocity(pushForce)
        end
    end

    function ENT:OnRangeAttack(enemy)
        if IsValid(enemy) and CurTime() - self.LastLeap > 3 then
            self:PlaySequence("zombie_leap_start")
            local dir = (enemy:GetPos() - self:GetPos())
            dir.z = 0
            dir:Normalize()
            local leapVel = dir * 600 + Vector(0, 0, 500)
            self:SetGroundEntity(nil)
            self:SetVelocity(leapVel)
            timer.Simple(0.2, function()
                if IsValid(self) then
                    self:PlaySequence("zombie_leap_mid")
                end
            end)
            self.LastLeap = CurTime()
        end
    end

    function ENT:OnNewEnemy(enemy) 
        self.WalkAnimation = ACT_HL2MP_WALK_FIST
        self.RunAnimation = ACT_HL2MP_RUN_FIST
        self.IdleAnimation = ACT_HL2MP_IDLE_FIST
        self.JumpAnimation = ACT_HL2MP_JUMP_FIST
    end

    function ENT:OnLastEnemy(enemy) 
        self.RageMode = false
        self.ZombieCrawl_Running = false
        self.WalkAnimation = ACT_HL2MP_WALK
        self.RunAnimation = ACT_HL2MP_RUN
        self.IdleAnimation = ACT_HL2MP_IDLE
        self.JumpAnimation = ACT_HL2MP_JUMP
    end

    function ENT:OnChaseEnemy(enemy) 
        self:RunAnimation_Type()
    end

    function ENT:RunAnimation_Type()
        if self.RageMode then
            self.RunAnimation = "zombie_run_fast"
            self.RunAnimRate = 1.2
            self.RunSpeed = 525
        elseif self.ZombieCrawl_Running then
            self.RunAnimation = "zombie_run_fast"
            self.RunAnimRate = 0.5
            self.RunSpeed = 500
        else
            self.RunAnimation = ACT_HL2MP_RUN
            self.RunAnimRate = 1
            self.RunSpeed = 300
        end
    end

    function ENT:OnReachedPatrol(pos)
        self:Wait(math.random(3, 7))
    end 

    function ENT:OnIdle()
        self:AddPatrolPos(self:RandomPos(1500))
    end

    function ENT:OnTakeDamage(dmg, hitgroup)
        if table.HasValue(self.DamageImmunity, dmg:GetDamageType()) then
            dmg:SetDamage(dmg:GetDamage() * (self.RageMode and 0.05 or 0.01))
        end
        
        -- Only take damage from enemies
        if dmg:GetAttacker():Team() == self:GetNWString("Team") then
            dmg:SetDamage(0)
        end
        
        if self:Health() <= 0 then
            local attacker = IsValid(dmg:GetAttacker()) and 
                (dmg:GetAttacker():IsPlayer() or dmg:GetAttacker().IsLambdaPlayer) and 
                dmg:GetAttacker():Name() or dmg:GetAttacker():GetClass()
            
            PrintMessage(HUD_PRINTTALK, attacker .. " has destroyed " .. self:GetCreator():Nick() .. "'s ReAnimen (".. self:GetNWString("TeamName") .. ")")
        end
        
        self:SpotEntity(dmg:GetAttacker())
    end
end

local function LambdaOnThink(lambda, weapon, isDead)
    if isDead then return end
    if SERVER then
        local entities = ents.FindInSphere(lambda:GetPos(), 2000)
        for _, ent in pairs(entities) do
            if ent:GetClass() == "lambda_npc_drg_reanimen" and lambda:CanSee(ent) and 
               ent:GetNWString("Team") ~= lambda:Team() and 
               (lambda:GetState() != "Combat" or !IsValid(lambda:GetEnemy())) then
                lambda:AttackTarget(ent)
            end
        end
    end
end

local function LambdaCanTarget(lambda, ent)
    if ent:GetClass() == "lambda_npc_drg_reanimen" and ent:GetNWString("Team") == lambda:Team() then 
        return true
    end
end

hook.Add("LambdaOnThink", "AttackReAnimen", LambdaOnThink)
hook.Add("LambdaCanTarget", "ReAninenAlly", LambdaCanTarget)

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)