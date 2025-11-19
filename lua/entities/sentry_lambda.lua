AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Sentry"
ENT.Author = "Aaron"
ENT.Spawnable = true
ENT.Category = "Lambda Buildings"
ENT.Building = true

if CLIENT then
    language.Add("sentry_lambda", "Sentry")
    killicon.Add("sentry_lambda", "killicons/sentry_lambda", Color(250, 80, 0))
end

function ENT:Initialize()
    if SERVER then
        local Creator = self:GetCreator()
        self:SetModel("models/props_combine/combine_light001a.mdl")
        self:SetModelScale(1)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetHealth(300)
        self:SetColor(team.GetColor(Creator:Team()))
        self:AddFlags(FL_AIMTARGET + FL_NPC)
        self:SetNWString("Team", Creator:Team())
        self:SetNWString("TeamName", team.GetName(Creator:Team()))
        self:SetNWString("BuildBy", Creator:Nick())
        self.Enemy = nil
        self.LastEnemy = nil
        PrintMessage(HUD_PRINTTALK, Creator:Nick() .. " has placed Sentry (".. self:GetNWString("TeamName") .. ")")
    end
end


local function DrawHealthLabel(target, health)
    local targetPos = target:GetPos()
    local targetPosScreen = targetPos:ToScreen()

    if targetPosScreen.visible then
        cam.Start2D()
        draw.DrawText("Sentry HP: " .. health .. "\n Team: " .. target:GetNWString("TeamName") .. "\nOwner: " .. target:GetNWString("BuildBy"), "TargetIDSmall", targetPosScreen.x, targetPosScreen.y, Color(30, 255, 0), TEXT_ALIGN_CENTER)
        cam.End2D()
    end
end

hook.Add("HUDPaint", "DisplaySentryHealth", function()
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if IsValid(target) and target:GetClass() == "sentry_lambda" and target:GetNWString("Team") == ply:Team() then
        DrawHealthLabel(target, target:Health())
    end
end)

function ENT:OnTakeDamage(dmginfo)
    if self:Health() <= 0 then return end

    if dmginfo:GetAttacker():Team() ~= self:GetNWString("Team") then
        self:SetHealth(self:Health() - dmginfo:GetDamage())
    else end
    
    local attacker = nil

    if IsValid(dmginfo:GetAttacker()) and (dmginfo:GetAttacker():IsPlayer() or dmginfo:GetAttacker().IsLambdaPlayer) then
        attacker = dmginfo:GetAttacker():Name()
    else
        attacker = dmginfo:GetAttacker():GetClass()
    end

    if self:Health() <= 0 then
        self:Explode()
        PrintMessage(HUD_PRINTTALK, attacker .. " has destroyed " .. self:GetCreator():Nick() ..  "'s Sentry (".. self:GetNWString("TeamName") .. ")")
    end
end

function ENT:Explode()
    if SERVER then
        local explosion = ents.Create("env_explosion")
        explosion:SetPos(self:GetPos())
        explosion:SetOwner(self)
        explosion:Spawn()
        explosion:SetKeyValue("iMagnitude", "0")
        explosion:Fire("Explode", 0, 0)
        
        self:Remove()

        for i = 1, 10 do
            local random = math.random(1, 3)
            local debris = ents.Create("prop_physics")
            debris:SetModel("models/combine_helicopter/bomb_debris_".. random ..".mdl")

            -- Losowanie pozycji "debris" wokół ściany
            local offset = Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(0, 10))
            local debrisPos = self:GetPos() + offset

            debris:SetPos(debrisPos)
            debris:Spawn()
            debris:SetCollisionGroup(COLLISION_GROUP_WORLD)

            -- Losowanie kierunku "debris"
            local direction = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 1)):GetNormalized()
            local force = 5000  -- Dostosuj siłę wybuchu
            local torque = Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-500, 500))

            debris:GetPhysicsObject():ApplyForceCenter(direction * force)
            debris:GetPhysicsObject():AddAngleVelocity(torque)
            debris:Ignite(10)

            local PhysObj = debris:GetPhysicsObject()
            PhysObj:SetMass(10)
            PhysObj:SetMaterial("superbouncy")

            -- Ustaw czas życia "debris" i zniknięcia
            timer.Simple(5, function()
                if IsValid(debris) then
                    debris:Remove()
                end
            end)
        end
    end
end

function ENT:FindEnemy()
    local closestDist = 1000
    local closestEnemy = nil
    local enemy = self.Enemy

    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
        if (ent.IsLambdaPlayer and ent:Team() ~= self:GetNWString("Team") and ent:Alive()) or ent:IsNPC() or (ent:IsPlayer() and ent:Team() ~= self:GetNWString("Team") and ent:Alive()) then
            local dist = self:GetPos():DistToSqr(ent:GetPos())


            local tr = util.TraceLine({
                start = self:WorldSpaceCenter(),
                endpos = ent:WorldSpaceCenter(),
                filter = self
            })

            if not tr.Hit or tr.Entity == ent then
                if not closestEnemy or dist < closestDist then
                    closestEnemy = ent
                    closestDist = dist
                end
            end

            if self.LastEnemy ~= enemy then
                -- Odtwórz dźwięk tylko raz, gdy wrogim jest inny niż poprzedni
                self:EmitSound("npc/scanner/combat_scan1.wav", 100, 100, 1)
                self.LastEnemy = enemy
            end
        end
    end

    self.Enemy = closestEnemy

end


function ENT:FireBullet()
    local enemy = self.Enemy
    if not IsValid(enemy) then return end

    local bullet = {}
    bullet.Num = 1
    bullet.Src = self:GetPos() + Vector(0, 0, 30)
    bullet.Dir = (enemy:EyePos() - Vector(0, 0, 15) - bullet.Src):GetNormalized()
    bullet.Spread = Vector(0, 0, 0)
    bullet.Tracer = 1
    bullet.Force = 0
    bullet.Spread = Vector(0.03, 0.03, 0)
    bullet.Damage = 5
    bullet.Attacker = self:GetCreator() -- Określ twórcę sentry jako atakującego
    bullet.TracerName = "ToolTracer"
    bullet.Callback = function(attacker, tr, dmginfo)
        local effectData = EffectData()
        effectData:SetStart(self:GetPos())
        effectData:SetOrigin(self:GetPos() + Vector(-10, 0, 30))
        effectData:SetAngles(self:GetAngles())
        util.Effect("AR2Impact", effectData)
    end
    self:FireBullets(bullet)
    self:EmitSound("weapons/ar2/fire1.wav", 100, 100, 1)
end

function ENT:Think()
    if SERVER then
        self:FindEnemy()

        local enemy = self.Enemy
        if not IsValid(enemy) then return end

        if IsValid(enemy) then
            -- Obracaj model w poziomie w kierunku wroga
            local dirToEnemy = (enemy:EyePos() - self:GetPos()):GetNormalized()
            local newAng = dirToEnemy:Angle()
            newAng.p = 0  -- Zablokuj obrót w pionie
            newAng.y = newAng.y + 180
            self:SetAngles(newAng)

            if CurTime() >= (self.NextShootTime or 0) then
                self:FireBullet()
                self.NextShootTime = CurTime() + 0.15  -- Strzelaj co 0.4 sekundy
            end
        end

        self:NextThink(CurTime() + 0.01)  -- Ustaw częstotliwość Think
        return true
    end
end

local function LambdaOnThink(lambda, weapon, isDead)
    if isDead then return end
    if SERVER then
    
        local entities = ents.FindInSphere(lambda:GetPos(), 2000)
        
        for _, ent in pairs(entities) do
            if ent:GetClass() == "sentry_lambda" and lambda:CanSee(ent) and ent:GetNWString("Team") ~= lambda:Team() and (lambda:GetState() != "Combat" or !IsValid(lambda:GetEnemy())) then
                lambda:AttackTarget(ent)
            end
        end
    end
end

local function LambdaCanTarget(lambda, ent)
    if ent:GetClass() == "sentry_lambda" and ent:GetNWString("Team") == lambda:Team() then 
        return true
    end
end


hook.Add("LambdaOnThink", "AttackSentry", LambdaOnThink)
hook.Add("LambdaCanTarget", "SentryAlly", LambdaCanTarget)

scripted_ents.Register(ENT, "sentry_lambda")
