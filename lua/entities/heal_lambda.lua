AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Healing Station"
ENT.Author = "Aaron"
ENT.Spawnable = true
ENT.Category = "Lambda Buildings"
ENT.Building = true


function ENT:Initialize()
    if SERVER then
        local Creator = self:GetCreator()
        self:SetModel("models/props_c17/utilityconnecter006c.mdl")
        self:SetModelScale(1)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetHealth(250)
        self:SetColor(team.GetColor(Creator:Team()))
        self:AddFlags(FL_AIMTARGET + FL_NPC)
        self:SetNWString("Team", Creator:Team())
        self:SetNWString("TeamName", team.GetName(Creator:Team()))
        self:SetNWString("BuildBy", Creator:Nick())
        PrintMessage(HUD_PRINTTALK, Creator:Nick() .. " has placed Healing Station (".. self:GetNWString("TeamName") .. ")")
    end

    if CLIENT then
        killicon.Add("sentry_lambda", "killicons/sentry_lambda", Color(250, 80, 0))
    end
end


local function DrawHealthLabel(target, health)
    local targetPos = target:GetPos()
    local targetPosScreen = targetPos:ToScreen()

    if targetPosScreen.visible then
        cam.Start2D()
        draw.DrawText("Station HP: " .. health .. "\n Team: " .. target:GetNWString("TeamName") .. "\nOwner: " .. target:GetNWString("BuildBy"), "TargetIDSmall", targetPosScreen.x, targetPosScreen.y, Color(30, 255, 0), TEXT_ALIGN_CENTER)
        cam.End2D()
    end
end

hook.Add("HUDPaint", "DisplayStationHealth", function()
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    local target = trace.Entity

    if IsValid(target) and target:GetClass() == "heal_lambda" and target:GetNWString("Team") == ply:Team() then
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
        PrintMessage(HUD_PRINTTALK, attacker .. " has destroyed " .. self:GetCreator():Nick() ..  "'s Heal Station (".. self:GetNWString("TeamName") .. ")")
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
            local debris = ents.Create("prop_physics")
            debris:SetModel("models/props_debris/concrete_spawnchunk001k.mdl")

            -- Losowanie pozycji "debris" wokół ściany
            local offset = Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(0, 10))
            local debrisPos = self:GetPos() + offset

            debris:SetPos(debrisPos)
            debris:Spawn()
            debris:SetCollisionGroup(COLLISION_GROUP_WORLD)

            -- Losowanie kierunku "debris"
            local direction = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 1)):GetNormalized()
            local force = 50000  -- Dostosuj siłę wybuchu
            local torque = Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-500, 500))

            debris:GetPhysicsObject():ApplyForceCenter(direction * force)
            debris:GetPhysicsObject():AddAngleVelocity(torque)
            debris:Ignite(10)

            local PhysObj = debris:GetPhysicsObject()
            PhysObj:SetMass(1)
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

function ENT:Healing()
    if not IsValid(self) then return end

    local allies = ents.FindInSphere(self:GetPos(), 200)

    if SERVER then
        for _, ent in pairs(allies) do
            if ent:IsPlayer() and ent:Team() == self:GetNWString("Team") or ent.IsLambdaPlayer and ent:Team() == self:GetNWString("Team") then
                local maxHealth = ent:GetMaxHealth()
                local currentHealth = ent:Health()
                local maxArmor = ent:GetMaxArmor()
                local currentArmor = ent:Armor()
                local healAmount = 3
                local armorAmount = 2

                if currentHealth < maxHealth and IsValid(ent) and ent:Alive() then
                    ent:SetHealth( currentHealth + healAmount  )
                    self:EmitSound("items/smallmedkit1.wav", 100, 100, 1)
                elseif currentHealth > maxHealth and IsValid(ent) and ent:Alive() then
                    ent:SetHealth( maxHealth )
                elseif currentHealth == maxHealth then
                    if maxArmor > currentArmor then
                        ent:SetArmor(currentArmor + armorAmount)
                    elseif currentArmor > maxArmor then
                        ent:SetArmor(maxArmor)
                    end
                end
            end
        end
    end
end

function ENT:DrawHealingBeams()
    local entities = ents.FindInSphere(self:GetPos(), 200)

    for _, ent in pairs(entities) do
        if (ent:IsPlayer() and ent:Team() == self:GetNWString("Team") or ent.IsLambdaPlayer and ent:Team() == self:GetNWString("Team")) then
            render.SetMaterial(Material("trails/plasma"))
            render.SetColorModulation(0, 1, 0) -- Zielona koloracja

            local startPos = self:GetPos() + Vector(0, 0, 25) -- Rozpocznij od pozycji stacji leczniczej
            local endPos = ent:GetPos() + Vector(0, 0, 20) -- Zakończ na pozycji sojusznika

            render.DrawBeam(startPos, endPos, 5, 0, 1, Color(0, 255, 0))

            render.SetColorModulation(1, 1, 1) -- Przywróć standardową kolorację
        end
    end
end

function ENT:Think()
    self:Healing()
    self:NextThink(CurTime() + 0.1)
end

function ENT:Draw()
    self:DrawModel() -- Narysuj model stacji leczniczej
    self:DrawHealingBeams() -- Narysuj zielone kreski
end

local function LambdaOnThink(lambda, weapon, isDead)
    if isDead then return end
    if SERVER then
        local entities = ents.FindInSphere(lambda:GetPos(), 2500)
        local targetHealLambda = nil

        for _, ent in pairs(entities) do
            if ent:GetClass() == "heal_lambda" and lambda:CanSee(ent) and ent:GetNWString("Team") ~= lambda:Team() and (lambda:GetState() != "Combat" or !IsValid(lambda:GetEnemy())) then
                lambda:AttackTarget(ent)
            elseif ent:GetClass() == "heal_lambda" and ent:GetNWString("Team") == lambda:Team() and (lambda:GetState() != "Combat" or !IsValid(lambda:GetEnemy())) and (lambda:Health() < lambda:GetMaxHealth()) and lambda:Alive() then
                targetHealLambda = ent
                if targetHealLambda then
                    local random = math.random(10, 40)
                    local distance = lambda:GetPos():Distance(targetHealLambda:GetPos())
                    local randPos = (targetHealLambda:GetPos() + Vector(random, random, 0))
        
                    if distance > 200 and !IsValid(lambda:GetEnemy()) then
                        lambda:SetRun( true )
                        lambda:RecomputePath( randPos )
                    end
                end
            end
        end
        
    end
end

local function LambdaCanTarget(lambda, ent)
    if ent:GetClass() == "heal_lambda" and (ent:GetNWString("Team") == lambda:Team() or ent:GetNWString("BuildBy") == lambda:Name()) then 
        return true
    end
end


hook.Add("LambdaOnThink", "StationBehavior", LambdaOnThink)
hook.Add("LambdaCanTarget", "StationAlly", LambdaCanTarget)

scripted_ents.Register(ENT, "heal_lambda")
