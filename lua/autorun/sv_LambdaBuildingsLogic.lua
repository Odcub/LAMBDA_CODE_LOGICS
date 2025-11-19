if SERVER then
    
    local ValidBuildings = {
        heal_lambda = true, 
        sentry_lambda = true,
        wall_lambda = true
    }
    

    local function LambdaOnThinkHeal(lambda, weapon, isDead)
        if isDead then return end

            local quotesHeal = {
                ":point_up: I found enemy Healing Station!",
                ":point_up: Watch out! Enemies built there Healing Station!",
                ":point_up: Enemy Healing Station here.",
                ":point_up: Enemy Healing Station!"
            }

            local quoteIndex = math.random(1, #quotesHeal)

            local entities = ents.FindInSphere(lambda:GetPos(), 2000)
            local enemyStation = nil

            for _, ent in pairs(entities) do
                if ent:GetClass() == "heal_lambda" and lambda:CanSee(ent) and ent:GetNWString("Team") ~= lambda:Team() and (lambda:GetState() != "Combat" or not IsValid(lambda:GetEnemy())) then
                    lambda:AttackTarget(ent)
                    enemyStation = ent
                    break
                end
            end

            if not enemyStation then
                lambda.spokenQuoteHeal = false
            end

        local currentTime = CurTime()
        if not lambda.spokenQuoteHeal and enemyStation and (not lambda.lastQuoteTimeHeal or currentTime - lambda.lastQuoteTimeHeal >= 10) then
            lambda:Say(quotesHeal[quoteIndex], true)
            lambda.spokenQuoteHeal = true
            lambda.lastQuoteTimeHeal = currentTime
        end
    end

    local function LambdaOnBeginMoveHeal(lambda, goal, isonnavmesh)

        local entities = ents.FindByClass("heal_lambda")
        local minDistance = 9999999
        local closestHeal = nil


        for _, ent in pairs(entities) do
            if ent:GetNWString("Team") == lambda:Team() and (lambda:GetState() != "Combat" or !IsValid(lambda:GetEnemy())) and (lambda:Health() < lambda:GetMaxHealth()) and lambda:Alive() then
                local distance = lambda:GetPos():Distance(ent:GetPos())

                if distance < minDistance then
                    minDistance = distance
                    closestHeal = ent
                end
                
            end
        end

        if closestHeal then
            local random = math.random(-100, 100)
            local randPos = Vector(random, random, 0)
            lambda:SetRun( true )
            lambda:RecomputePath( closestHeal:GetPos() + randPos)

            if lambda:GetPos():Distance(closestHeal:GetPos()) <= 200 then
                if lambda:Health() < lambda:GetMaxHealth() then
                    lambda:SetRun( false )
                    lambda:RecomputePath( closestHeal:GetPos() + randPos)
                    lambda:LookTo(closestHeal:GetPos(), 1)
                end
            elseif lambda:GetPos():Distance(closestHeal:GetPos()) > 200 then
                if closestHeal:GetNWString("BuildBy") ~= lambda:Name() then
                    lambda:Say(":zap: I will heal myself at " .. closestHeal:GetNWString("BuildBy") .."'s Healing Station which is " .. math.Round(lambda:GetPos():Distance(closestHeal:GetPos()) / 10, 1) .. "m from me.", true)
                else
                    lambda:Say(":zap: I will heal myself at my own Healing Station which is " .. math.Round(lambda:GetPos():Distance(closestHeal:GetPos()) / 10, 1) .. "m from me.", true)
                end
            end
        end
    end

    local function LambdaOnThinkWall(lambda, weapon, isDead)
        if isDead then return end

        
        local entities = ents.FindInSphere(lambda:GetPos(), 2000)
            
        for _, ent in pairs(entities) do
            if ent:GetClass() == "wall_lambda" and lambda:CanSee(ent) and ent:GetNWString("Team") ~= lambda:Team() and (lambda:GetState() != "Combat" or !IsValid(lambda:GetEnemy())) then
                lambda:AttackTarget(ent)
            end
         end
    end
    
    local function LambdaCanTargetBuilding(lambda, ent)
        if ValidBuildings[ent:GetClass()] and ent:GetNWString("Team") == lambda:Team() then 
            return true
        end
    end

    local function LambdaOnThinkSentry(lambda, weapon, isDead)
        if isDead then return end

        local quotesSentry = {
            ":point_up: Ay! Enemy Sentry over there!",
            ":point_up: I spotted Enemy Sentry here!",
            ":point_up: Sentry ahead!",
            ":point_up: Somebody placed sentry here...",
            ":point_up: Be careful, sentry spotted!",
            ":point_up: Watch out for the enemy Sentry!",
            ":point_up: Enemy Sentry detected!",
            ":point_up: There's a Sentry up ahead.",
            ":point_up: Enemy Sentry deployed in this area.",
            ":point_up: Enemy Sentry! Stay alert!",
            ":point_up: Enemy Sentry located!",
            ":point_up: Sentry sighted! Take caution!"
            }


        local quoteIndex = math.random(1, #quotesSentry)

        local entities = ents.FindInSphere(lambda:GetPos(), 2000)
        local enemySentry = nil

        for _, ent in pairs(entities) do
            if ent:GetClass() == "sentry_lambda" and lambda:CanSee(ent) and ent:GetNWString("Team") ~= lambda:Team() and (lambda:GetState() != "Combat" or not IsValid(lambda:GetEnemy())) then
                lambda:AttackTarget(ent)
                enemySentry = ent
                break  
            end
        end

        if not enemySentry then
            lambda.spokenQuoteSentry = false
        end


        local currentTime = CurTime()
        if not lambda.spokenQuoteSentry and enemySentry and (not lambda.lastQuoteTimeSentry or currentTime - lambda.lastQuoteTimeSentry >= 10) then
            lambda:Say(quotesSentry[quoteIndex], true)
            lambda.spokenQuoteSentry = true 
            lambda.lastQuoteTimeSentry = currentTime  
        end
    end

    hook.Add("LambdaCanTarget", "StationAlly", LambdaCanTargetBuilding)
    hook.Add("LambdaOnBeginMove", "StationUsage", LambdaOnBeginMoveHeal)
    hook.Add("LambdaOnThink", "StationAttack", LambdaOnThinkHeal)
    hook.Add("LambdaOnThink", "AttackWall", LambdaOnThinkWall)
    hook.Add("LambdaOnThink", "AttackSentry", LambdaOnThinkSentry)

else
    
    local ValidBuildings = {
        heal_lambda = true, 
        sentry_lambda = true,
        wall_lambda = true
    }

    local function DrawHealthLabel(target, health)
        local targetPos = target:GetPos()
        local targetPosScreen = targetPos:ToScreen()
        local build = ValidBuildings
    
        if targetPosScreen.visible then
            cam.Start2D()
            draw.DrawText( language.GetPhrase(target:GetClass()) .. " HP: " .. health .. "\n Team: " .. target:GetNWString("TeamName") .. "\nOwner: " .. target:GetNWString("BuildBy"), "TargetIDSmall", targetPosScreen.x, targetPosScreen.y, Color(30, 255, 0), TEXT_ALIGN_CENTER)
            cam.End2D()
        end
    end
    
    hook.Add("HUDPaint", "DisplayStationHealth", function()
        local ply = LocalPlayer()
        local trace = ply:GetEyeTrace()
        local target = trace.Entity
    
        if IsValid(target) and ValidBuildings[target:GetClass()] and target:GetNWString("Team") == ply:Team() then
            DrawHealthLabel(target, target:Health())
        end
    end)
end