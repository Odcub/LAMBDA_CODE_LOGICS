local collisionPly = GetConVar( "lambdaplayers_lambda_noplycollisions" )
local isentity = isentity
local IsValid = IsValid
local tracetbl2 = {}
local tracetable = {} -- Recycled table


local seatmodels = {
    [ "models/nova/airboat_seat.mdl" ] = true,
    [ "models/nova/jeep_seat.mdl" ] = true,
    [ "models/nova/chair_office01.mdl" ] = true,
    [ "models/nova/chair_office02.mdl" ] = true,
    [ "models/nova/chair_plastic01.mdl" ] = true,
    [ "models/nova/chair_wood01.mdl" ] = true,
    [ "models/props_phx/carseat2.mdl" ] = true,
    [ "models/nova/jalopy_seat.mdl" ] = true
}
local obstacleDetected = false
local allowsitting = CreateLambdaConvar( "lambdaplayers_seat_allowsitting", 1, true, false, false, "If Lambda players are allowed to sit on the ground and props", 0, 1, { type = "Bool", name = "Allow Sitting", category = "Lambda Server Settings" } )

-- Returns if the simfphys vehicle is open
local function IsSimfphysOpen( veh )
    if veh:OnFire() then return false end
    local driverseat = veh:GetDriverSeat()
    local passengerseats = veh:GetPassengerSeats()
    if IsValid( driverseat:GetDriver() ) or IsValid( veh.l_lambdaseated ) then return false end

    local opencount = 0

    for k, pod in pairs( passengerseats ) do
        if !IsValid( pod:GetDriver() ) and !IsValid( veh.l_lambdaseated ) then opencount = opencount + 1 end
    end

    if opencount == 0 then return false end

    return true
end

-- The Seat Module is a more advanced form of the Zeta's Vehicle System.
-- This module will allow Lambdas to sit on the ground, on entities, and drive vehicles.
-- I'll be honest this a bit messy but it works

local function Initialize( self )
    print("init'd")
    if CLIENT then return end 
    self.passengers = {} 
    self.l_currentseatsit = nil -- The current vehicle, seat, or spot we are sitting at
    self.l_wasseatsitting = false -- If we were sitting a tick ago
    self.l_isseatsitting = false -- If we are sitting

    function self:StopSitting() -- Makes the lambda stop sitting
        self.l_isseatsitting = false
    end

    function self:IsSitting() -- If the Lambda is sitting
        return self.l_isseatsitting
    end
    function self:AddPassenger(ply)

        print("passenger implemented")
        table.Add(self.passengers, ply, math.random(1,90))
        print("table utilized")
    end
    
    function self:RemovePassenger(ply)
        if self.passengers then
            for i, passenger in ipairs(self.passengers) do
                if passenger == ply then
                    table.remove(self.passengers, i)
                    break
                end
            end
        end
    end
    
    function self:GetVehicle() -- Returns the vehicle. Basically just whatever self.l_currentseatsit is
        return self.l_currentseatsit
    end

    function self:ExitVehicle()   
        
            self:ResetSitInfo() 


        
    end
    function self:EnterVehicle( ent ) if IsSimfphysOpen( ent ) then self:Sit( ent ) end end
  
    function self:ResetSitInfo()
    
        local newstate = self:GetState() == "SitState" and "Idle" or self:GetState() == "DriveState" and "Idle" or self:GetState()
        self.l_seatnormvector = nil
        self:SetParent()
        self:RemovePassenger(self)
        self:SetState(newstate)
        self:SetAngles(Angle(0, self:GetAngles()[2], 0))
        self:SetPoseParameter("vehicle_steer", 0)
        self.l_vehicleattachment = nil
        self.l_isseatsitting = false
        self.l_wasseatsitting = false
        self.l_UpdateAnimations = true
    
        self:SetMoveType(MOVETYPE_CUSTOM)
        self:SetSolidMask(MASK_PLAYERSOLID)
    
        self.loco:SetVelocity(Vector())
        self.l_FallVelocity = 0
    
        -- If we were in a vehicle or chair, find a place to exit if possible
        if isentity(self.l_currentseatsit) and IsValid(self.l_currentseatsit) then
            self.l_currentseatsit.l_lambdaseated = nil
            self.l_currentseatsit:SetSaveValue("m_hNPCDriver", NULL)
    
            if self:IsDrivingSimfphys() then
                -- Simfphys vehicle exit logic
                if IsValid(self.l_currentseatsit:GetDriverSeat()) then
                    self.l_currentseatsit:GetDriverSeat().l_lambdaseated = nil
                    self.l_currentseatsit.l_lambdaseated = nil
                    self.l_currentseatsit:GetDriverSeat():StartEngine()
              
                end
                self.l_currentseatsit:SetActive(false)
                self.l_currentseatsit:SetOwner(nil)
            elseif self.l_invehicle then
                -- Your original vehicle exit logic
                self.l_currentseatsit:SetThrottle(0)
                self.l_currentseatsit:SetSteering(0, 0)
            end
    
            self:SetPoseParameter("vehicle_steer", 0)
    
            if self.l_currentseatsit.l_seatmoduleexitfunc then
                self.GetVehicle_UseDriverSeat = true
                self.l_currentseatsit.l_seatmoduleexitfunc(self, self.l_currentseatsit)
                self.GetVehicle_UseDriverSeat = false
            else
              
                if self.l_currentseatsit.CheckExitPoint then
                    
                    if not exitpos then
                        local dirs = {
                            self.l_currentseatsit:GetRight() * 128,
                            self.l_currentseatsit:GetRight() * -750,
                            self.l_currentseatsit:GetForward() * 128,
                            self.l_currentseatsit:GetForward() * -128
                        }
                    
                        for i = 1, #dirs do
                            exitpos = self.l_currentseatsit:GetPos() + dirs[i]
                            tracetable.start = self.l_currentseatsit:GetPos()
                            tracetable.endpos = exitpos
                            tracetable.filter = { self, self.l_currentseatsit }
    
                            local tr = util.TraceLine(tracetable)
                            if not tr.Hit then
                                break
                            end
                        end
                    end
    
                    if exitpos then
                        self:SetPos(exitpos)
                    end
                end
            end
        end
 
        if not collisionPly:GetBool() then
            self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        else
            self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        end
    
    
    end
function self:Sit(sitarg, endtime)
    if isentity(sitarg) and IsValid(sitarg) then
        -- Prevent sitting in occupied simfphys or vehicles with a driver/npc already seated
        if (sitarg.IsSimfphyscar and not IsSimfphysOpen(sitarg)) or
           (not sitarg.IsSimfphyscar and sitarg:IsVehicle() and
            (IsValid(sitarg:GetDriver()) or IsValid(sitarg.l_lambdaseated) or IsValid(sitarg:GetInternalVariable("m_hNPCDriver")))) then
            return
        end
    end

    self:ResetSitInfo()

    self.l_currentseatsit = sitarg
    self.l_isseatsitting = true
    self.l_wasseatsitting = true
    self.l_sitendtime = endtime and CurTime() + endtime or nil
    self:AddPassenger(self)

    if isentity(sitarg) and IsValid(sitarg) then
        -- Simfphys vehicle special handling
        if sitarg.IsSimfphyscar then
            local enteredseat = false
            local driverseat = sitarg:GetDriverSeat()
            local passengerseats = sitarg:GetPassengerSeats()

            if IsValid(driverseat:GetDriver()) or IsValid(driverseat.l_lambdaseated) then
                for _, pod in pairs(passengerseats) do
                    if not IsValid(driverseat:GetDriver()) and not IsValid(driverseat.l_lambdaseated) then
                        enteredseat = true
                        self:SetParent(pod)
                        self.l_currentseatsit = pod
                        break
                    end
                end
            elseif not IsValid(driverseat:GetDriver()) and not IsValid(driverseat.l_lambdaseated) then
                enteredseat = true
            end

            if not enteredseat then
                self.l_currentseatsit = nil
                self.l_isseatsitting = false
                return
            end
        end

        -- Get seat position and angle
        local attach = sitarg:GetAttachment(sitarg:LookupAttachment("vehicle_feet_passenger0"))
        local pos = self:IsDrivingSimfphys() and IsValid(sitarg:GetDriverSeat()) and sitarg:GetDriverSeat():GetPos() or
                    attach and attach.Pos or sitarg:GetPos()
        local ang = self:IsDrivingSimfphys() and IsValid(sitarg:GetDriverSeat()) and sitarg:GetDriverSeat():GetAngles() + Angle(0, 90, 0) or
                    attach and attach.Ang or sitarg:GetAngles()

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolidMask(MASK_SOLID_BRUSHONLY)

        self.l_invehicle = self:IsDrivingSimfphys() or (sitarg:IsVehicle() and sitarg:GetMaxSpeed() > 0)

        -- **Set ownership references for proper damage crediting**
        sitarg:SetSaveValue("m_hNPCDriver", self) -- block NPC drivers on non-simfphys vehicles
        sitarg.l_lambdaseated = self

        -- THIS IS THE KEY: Store driver ref on vehicle for damage credit
        sitarg.l_lambdaDriver = self

        -- === FIX: Set the owner explicitly on vehicle and driver seat ===
        sitarg:SetOwner(self)  -- Set owner on vehicle entity

        if self:IsDrivingSimfphys() then
            local driverSeat = sitarg:GetDriverSeat()
            if IsValid(driverSeat) then
                driverSeat.l_lambdaseated = self
                driverSeat:SetOwner(self)  -- Set owner on driver seat entity too
            end
        end

        if not self.l_invehicle and not seatmodels[sitarg:GetModel()] then
            local traceData = {}
            traceData.start = sitarg:WorldSpaceCenter() + Vector(0, 0, (sitarg:GetModelRadius() / 2) + 10)
            traceData.endpos = sitarg:GetPos()
            traceData.filter = self
            local result = util.TraceLine(traceData)
            if result.Entity == sitarg then
                self.l_seatnormvector = sitarg:WorldToLocal(result.HitPos)
            end
        end

        if self:IsDrivingSimfphys() then
            sitarg:GetDriverSeat().l_lambdaseated = self

            if not sitarg.l_seatmoduleexitfunc then
                local hookTbl = hook.GetTable().PlayerLeaveVehicle
                if hookTbl and isfunction(hookTbl.simfphysVehicleExit) then
                    sitarg.l_seatmoduleexitfunc = hookTbl.simfphysVehicleExit
                end
            end
 
            sitarg:SetDriver(self)
            sitarg:SetActive(true)
            sitarg:StartEngine()
            self:AddPassenger(self)
        end

        self:AddPassenger(self)
        self:SetState(not self.l_invehicle and "SitState" or "DriveState")
    
        self:SetPos(pos)
        self:SetAngles(ang)
        self:SetParent(sitarg)
    else
        self:SetState("SitState")
    end

    self:CancelMovement()
end

 function self:SitState()
    local enemy = self.CurrentEnemy -- replace with how you track the enemy target
    
    -- Check if currently seated in a vehicle with turret aiming support
    if isentity(self.l_currentseatsit) and IsValid(self.l_currentseatsit) then

        if IsValid(self.l_currentseatsit) or self.l_currentseatsit ~= nil and self.l_invehicle then
        local weapon = self.l_currentseatsit:GetNWEntity("WeaponEntity") 
        
        -- If weapon supports AimWeapon function and enemy exists
        if weapon and weapon.AimWeapon and IsValid(enemy) then
            -- Calculate angle to enemy from driver's eye position
            local eyePos = self:GetShootPos() -- or self:EyePos()
            local enemyPos = enemy:WorldSpaceCenter()
            local dir = (enemyPos - eyePos):GetNormalized()
            local targetAng = dir:Angle()
            
            -- Make Lambda look at enemy smoothly (adjust smoothing speed as needed)
            self:SetEyeAngles( LerpAngle(0.15, self:EyeAngles(), targetAng) )
            
            return -- Early exit, no random looking
        end
    end
    end
    
    -- Fallback: random look around behavior (existing)
    self.l_nextseatlook = self.l_nextseatlook or CurTime() + math.Rand( 0.5, 6 )
    if CurTime() > self.l_nextseatlook then
        self:LookTo( self:GetPos() + VectorRand( -400, 400 ), 3, isentity( self.l_currentseatsit ) )
        self.l_nextseatlook = CurTime() + math.Rand( 0.5, 6 )
    end
end
    function self:GetInfoNum()
        return 0
    end
 self.RamSettings = {
    commitTime = 1.5,        -- seconds to stay committed to a ram direction
    adjustThreshold = 100^2, -- squared distance to enemy before adjusting
    barrierDuration = 0.4,   -- seconds barrier stays active on impact zone
    barrierSize = Vector(40, 60, 40), -- size of the kill barrier
    barrierOffset = Vector(100, 0, 20) -- position offset from vehicle origin
}

-- Track ramming state
self.ramTarget = nil
self.ramCommitEnd = 0



-- Steer precisely toward target
function self:CommitSteerTo(goalpos, throttleDir)
    -- throttleDir: 1 = forward, -1 = reverse, 0 = no throttle
    throttleDir = throttleDir or 1

    local loca = self:WorldToLocalAngles((goalpos - self:GetPos()):Angle())
    local steerMath = math.Clamp(-loca.y / 5, -1, 1)

    if self:IsDrivingSimfphys() then
        -- Clear both throttle keys first
        self.l_currentseatsit.PressedKeys["W"] = false
        self.l_currentseatsit.PressedKeys["S"] = false

        if throttleDir > 0 then
            self.l_currentseatsit.PressedKeys["W"] = true
        elseif throttleDir < 0 then
            self.l_currentseatsit.PressedKeys["S"] = true
        end

        self.l_currentseatsit:PlayerSteerVehicle(
            self,
            (steerMath < 0 and -steerMath or 0),
            (steerMath > 0 and steerMath or 0)
        )
    else
        self.l_currentseatsit:SetThrottle(math.abs(throttleDir))
        self.l_currentseatsit:SetSteering(steerMath, 0)
    end

    self:SetPoseParameter("vehicle_steer", steerMath)
end


-- New ramming behavior
-- Backup / stuck detection extracted from DriveState so we can use it in combat too
function self:CheckAndRecoverFromStuck()
    if not self.lastPosCheck or not self.lastPosTime then
        self.lastPosCheck = self:GetPos()
        self.lastPosTime = CurTime()
        return
    end

    if CurTime() - self.lastPosTime > 1 then
        local movedDistSqr = self:GetPos():DistToSqr(self.lastPosCheck)
        if movedDistSqr < 25 then -- basically stuck
            -- Reverse a bit
            if self:IsDrivingSimfphys() then
                self.l_currentseatsit.PressedKeys["S"] = true
            else
                self.l_currentseatsit:SetThrottle(-1)
            end

            -- Safely check and set steering
            if IsValid(self.l_currentseatsit) and
               type(self.l_currentseatsit.SetSteering) == "function" then
                if math.random() < 0.5 then
                    self.l_currentseatsit:SetSteering(1, 0)
                else
                    self.l_currentseatsit:SetSteering(-1, 0)
                end
            end

            -- Give time to clear before moving forward again
            self.stuckRecoverEnd = CurTime() + 1.5
        else
            self.lastPosCheck = self:GetPos()
        end
        self.lastPosTime = CurTime()
    end
end


-- Updated Ramming with integrated obstacle recovery
function self:DriveCombatBehavior(enemy)
    if not IsValid(enemy) then return end
    local enemyPos = enemy:GetPos() or enemy:WorldSpaceCenter()

    -- Start / commit to ram target
    if not self.ramTarget or self.ramTarget ~= enemy then
        self.ramTarget = enemy
        self.ramCommitEnd = CurTime() + self.RamSettings.commitTime
    end

    -- Reset commit if enemy has moved far during chase
    if CurTime() < self.ramCommitEnd then
        if self.lastRamPos and enemyPos:DistToSqr(self.lastRamPos) > self.RamSettings.adjustThreshold then
            self.ramCommitEnd = CurTime() + self.RamSettings.commitTime
        end
    end

    -- If we are recovering from being stuck, reverse instead of pushing forward
    if self.stuckRecoverEnd and CurTime() < self.stuckRecoverEnd then
        return -- skip normal ram steering until unstuck
    end

    -- Steer toward enemy
   local recovering, throttleDir = self:CheckAndRecoverFromStuck() 
-- throttleDir should be 1 (forward), -1 (reverse), or 0

-- Steer toward enemy
self:CommitSteerTo(enemyPos, throttleDir)

-- If not recovering, apply normal attack logic
if not recovering and self:IsDrivingSimfphys() then
    self.l_currentseatsit.PressedKeys["W"] = true
elseif not recovering then
    self.l_currentseatsit:SetThrottle(1)
end

    -- Apply throttle
    if self:IsDrivingSimfphys() then
        self.l_currentseatsit.PressedKeys["W"] = true
    else
        self.l_currentseatsit:SetThrottle(1)
    end

    -- Get the vehicle entity safely
    local vehicle =  self.l_currentseatsit

    if self.l_currentseatsit:GetPos():DistToSqr(enemyPos) < 300^2 and self.l_invehicle ~= false then
        print("DEATH.")

        local attacker = vehicle.l_lambdaseated or self -- fallback to self if no driver reference found

      local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(100)
    dmgInfo:SetAttacker(attacker)
        dmgInfo:SetInflictor(vehicle)
        dmgInfo:SetDamageType(DMG_CRUSH)

            enemy:TakeDamageInfo(dmgInfo)
        
    end

    -- Run stuck / obstacle recovery check
    self:CheckAndRecoverFromStuck()

    self.lastRamPos = enemyPos
end


    function self:VehiclePathGenerator()
        local jumpPenalty = 30
        local stepHeight = 70
        local jumpHeight = 0
        local deathHeight = -self.loco:GetDeathDropHeight()
        local visitedAreas = {} -- Keep track of visited areas to prevent loops
    
        return function(area, fromArea, ladder, elevator, length)
            if not IsValid(fromArea) then return 0 end
            if not self.loco:IsAreaTraversable(area) or bit.band(area:GetAttributes(), NAV_MESH_AVOID) == NAV_MESH_AVOID then return -1 end
            if area:GetSizeX() < 90 or area:GetSizeY() < 90 then
                return -1 -- Penalize small areas
            end
            
    
            -- Prevent loop paths by checking if the area was already visited
            if visitedAreas[area:GetID()] then return -1 end
            visitedAreas[area:GetID()] = true
    
            local dist = (length > 0 and length or fromArea:GetCenter():Distance(area:GetCenter()))
            local cost = (fromArea:GetCostSoFar() + dist)
    
            -- Adjust costs based on vertical changes
            local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)
            if deltaZ > jumpHeight or deltaZ < deathHeight then return -1 end
            if deltaZ > stepHeight then cost = cost + (dist * jumpPenalty) end
    
            return cost
        end
    end
    
    function self:IsDrivingSimfphys()
        return isentity( self.l_currentseatsit ) and IsValid( self.l_currentseatsit ) and self.l_currentseatsit.IsSimfphyscar
    end

    local function ReplaceZ( self, vector )
        vector[ 3 ] = self:GetPos()[ 3 ]
        return vector
    end
    function self:DriveToOFFNAV(pos)
        local driveTimeout = CurTime() + 30 -- Prevent infinite loops
        local collisionAvoidCooldown = 0 -- Cooldown for collision avoidance adjustments
        local stuckCounter = 0 -- Count stuck instances
        local maxStuckAttempts = 5 -- Limit retries for stuck detection
        local collisionCooldown = 0

        while true do
            if self:GetRangeSquaredTo(ReplaceZ(self, pos)) <= (800 * 800) then break end
            if not IsValid(self.l_currentseatsit) or CurTime() > driveTimeout then break end
            if self.loco:IsStuck() then
                self.loco:ClearStuck()
                stuckCounter = stuckCounter + 1
            
                if stuckCounter >= maxStuckAttempts then
                    break
                end
            
                coroutine.yield() -- pause and try again in next cycle
            end
            
            self.loco:Approach(pos, 1)
  
            local trace = util.TraceHull({
                start = self:GetPos(),
                endpos = pos + self:GetForward() * 250,
                mins = self:OBBMins(),
                maxs = self:OBBMaxs(),
                    filter = {self, self.l_currentseatsit, self:GetEnemy()},
                mask = MASK_SOLID_BRUSHONLY,
               
            })
          
            if trace.Hit and  !trace.Entity.IsLambdaPlayer or !trace.Entity:IsPlayer() or !trace.Entity:IsNPC() and !trace.Entity:IsNextBot() then
                if CurTime() > collisionCooldown then
                    collisionCooldown = CurTime() + 3 -- 2-second cooldown
                    self.loco:ClearStuck()
                    self.l_currentseatsit:SetThrottle(0)
                    coroutine.yield()
                    continue
                end
            end
        
            self.l_currentseatsit:SetThrottle(1)
            self.l_currentseatsit:PlayerSteerVehicle(self, steeringAdjust, 0)
        
            coroutine.yield()
        end
    end
    
    function self:DriveTo(pos)
        local path = Path("Follow")
        path:SetGoalTolerance(200)
        path:Compute(self, (not isvector(pos) and pos:GetPos() or pos), self:VehiclePathGenerator())
        self.ReverseTimer = 0
    
        if not path:IsValid() then
            self:DriveToOFFNAV(pos)
            return
        end
    
        if self.loco:IsStuck() then
            self.loco:ClearStuck()
            return
        end
    
        while path:IsValid() and IsValid(self) and IsValid(self.l_currentseatsit) do
            path:Update(self)
            local curSegment = path:GetCurrentGoal()
            if not curSegment then break end
    
            local goalPos = curSegment.pos
            local localAngle = self:WorldToLocalAngles((goalPos - self:GetPos()):Angle())
            local steerDirection = math.Clamp(-localAngle.y / 5, -1, 1)
    
            self.ReverseTimer = self.ReverseTimer or 0
            if self.loco:IsStuck() then self.loco:ClearStuck() end
    
            -- Obstacle Detection (Cleaned, Only One Version)
            local forwardTrace = util.TraceHull({
                start = self:GetPos(),
                endpos = goalPos + self:GetForward() * 100,
                mins = Vector(-20, -20, 0),
                maxs = Vector(20, 20, 60),
                filter = {self, self.l_currentseatsit, self:GetEnemy()},
                mask = MASK_SOLID_BRUSHONLY
            })
    
            local noGroundAhead = not util.TraceLine({
                start = self:GetPos() + Vector(0, 0, 10),
                endpos = goalPos + Vector(0, 0, -100),
                filter = {self, self.l_currentseatsit, self:GetEnemy()},
                mask = MASK_SOLID_BRUSHONLY,
            }).Hit
    
            -- Behavior Logic
          
if not self:InCombat() then
    local nearbyTeammates = self:FindNearbyTeammates(1600)
    local hasPassengers = self:HasTeamPassengers()
    local passengerseats = self.l_currentseatsit:GetPassengerSeats()
    local Driver = self.l_currentseatsit:GetDriverSeat()

    if #nearbyTeammates > 0 and not hasPassengers then
        self:StopVehicle()

        for _, teammate in ipairs(nearbyTeammates) do
            if IsValid(teammate) and teammate:Team() == self:Team() then
                for k, pod in pairs(passengerseats) do
                    if not IsValid(Driver:GetDriver()) and not IsValid(Driver.l_lambdaseated) then
                        enteredseat = true
                        teammate:SetParent(pod)
                        print("passenger added")
                        teammate:PlaySoundFile(teammate:GetVoiceLine("assist"))
                        self:PlaySoundFile(self:GetVoiceLine("conrespond"))
                        teammate.l_currentseatsit = pod
                        break
                    end
                end
            end
        end
    else
        self:DriveForward(steerDirection)
    end
else
    self:EngageRamming(self:GetEnemy(), steerDirection)
    if math.random(1, 3) == 3 and IsValid(self:GetEnemy()) then
        self:DriveCombatBehavior(self:GetEnemy())
    end
end

-- Debugging
if GetConVar("developer"):GetBool() then
    debugoverlay.Cross(goalPos, 40, 0.1, color_white, false)
    path:Draw()
end

coroutine.yield() -- Always yield to prevent freezing

        end
    end
    
function self:DriveState()
    if not navmesh.IsLoaded() or navmesh.IsGenerating() then
        local fallback = self:FindNearbyValidPosition()
        if fallback then self:DriveToOFFNAV(fallback) end
        return
    end

    self.recentGoals = self.recentGoals or {}
    self.failedAttempts = self.failedAttempts or {}
    self.lastStuckTime = self.lastStuckTime or 0
    self.stuckCounter = self.stuckCounter or 0

    local MAX_ATTEMPTS = 60000
    local MIN_DIST_SQR = 25600 -- 160^2 units
    local STUCK_LIMIT = 3 -- how many consecutive fails before forcing backup

    local function isTooCloseToRecent(pos)
        for _, recent in ipairs(self.recentGoals) do
            if recent:DistToSqr(pos) < MIN_DIST_SQR then
                return true
            end
        end
        return false
    end

    local function isBlacklisted(pos)
        for _, bad in ipairs(self.failedAttempts) do
            if bad:DistToSqr(pos) < 100 then
                return true
            end
        end
        return false
    end

    local targetPos
    for i = 1, MAX_ATTEMPTS do
        local pos = self:ChooseNavPosition()
        if pos and not isTooCloseToRecent(pos) and not isBlacklisted(pos) then
            targetPos = pos
            break
        end
    end

    if not targetPos then
        self.stuckCounter = self.stuckCounter + 1
        if self.stuckCounter >= STUCK_LIMIT then
            self:ForceBackupManeuver()
            -- Do NOT reset stuckCounter here - wait for successful move
            -- Instead record when backup started
            self.lastBackupTime = CurTime()
        else
            local fallback = self:FindNearbyValidPosition()
            if fallback then
                self:DriveToOFFNAV(fallback)
            end
        end
        return
    end

    -- Check if enough time has passed since last backup to reset stuckCounter
    if self.lastBackupTime and CurTime() - self.lastBackupTime > 2 then
        -- If bot moved enough, reset stuckCounter
        if self.lastPosCheck and self:GetPos():DistToSqr(self.lastPosCheck) > 100 then
            self.stuckCounter = 0
            self.lastBackupTime = nil
        end
    end

    -- Store current position for next check
    self.lastPosCheck = self:GetPos()

    -- Store goal
    table.insert(self.recentGoals, 1, targetPos)
    if #self.recentGoals > 6 then table.remove(self.recentGoals) end

    -- Attempt drive
    local success = self:DriveTo(targetPos)
    if not success then
        table.insert(self.failedAttempts, targetPos)
        if #self.failedAttempts > 10 then table.remove(self.failedAttempts, 1) end
        self.stuckCounter = self.stuckCounter + 1
        if self.stuckCounter >= STUCK_LIMIT then
            self:ForceBackupManeuver()
            self.lastBackupTime = CurTime()
            -- Do NOT reset stuckCounter here either
        end
    else
        -- Reset stuckCounter if successfully driving to a position
        self.stuckCounter = 0
    end
end

-- Force the vehicle to reverse a bit to unstick
function self:ForceBackupManeuver()
    if self.isBackingUp then return end -- prevent overlap
    local veh = self.l_currentseatsit
    if not IsValid(veh) or not veh.PressedKeys then return end

    self.isBackingUp = true

    local turnLeft = math.random(0, 1) == 1

    -- Reverse
    veh.PressedKeys["S"] = true
    veh.PressedKeys["W"] = false
    veh.PressedKeys["A"] = turnLeft
    veh.PressedKeys["D"] = not turnLeft

    timer.Simple(1.2, function()
        if not IsValid(veh) or not veh.PressedKeys then
            self.isBackingUp = false
            return
        end

        veh.PressedKeys["S"] = false
        veh.PressedKeys["W"] = true

        timer.Simple(0.5, function()
            if not IsValid(veh) or not veh.PressedKeys then
                self.isBackingUp = false
                return
            end

            veh.PressedKeys["A"] = false
            veh.PressedKeys["D"] = false
            self.isBackingUp = false
        end)
    end)
end

    
    function self:IsPositionClear(pos)
        local tr = util.TraceHull({
            start = pos + Vector(0, 0, 10),
            endpos = pos + Vector(0, 0, 10),
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 64),
            mask = MASK_SOLID_BRUSHONLY,
            filter = self, self.l_currentseatsit, self:GetEnemy()
        })
        return not tr.Hit and !tr.Entity.IsLambdaPlayer or !tr.Entity:IsPlayer() or !tr.Entity:IsNPC() and !tr.Entity:IsNextBot()
    end
    

    function self:ChooseNavPosition()
        local navAreas = navmesh.GetAllNavAreas()
        if #navAreas == 0 then return nil end
    
        for i = 1, 10 do
            local nav = navAreas[math.random(#navAreas)]
            if nav and nav:IsValid() and not nav:IsUnderwater() then
                local pos = nav:GetRandomPoint()
                if pos and util.IsInWorld(pos) and self:IsPositionClear(pos) then
                    local tooClose = false
                    for _, prev in ipairs(self.recentGoals or {}) do
                        if pos:DistToSqr(prev) < 200^2 then
                            tooClose = true
                            break
                        end
                    end
                    if not tooClose then
                        return pos
                    end
                end
            end
        end
    
        return nil
    end
    
    function self:FindNearbyTeammates(radius)
        local teammates = {}
        for _, entity in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
            if  entity.IsLambdaPlayer  and entity:Team() == self:Team() and not entity.l_currentseatsit and !entity.l_isseatsitting  then
                table.insert(teammates, entity)
               
            end
        end
        return teammates
    end
    function self:HasTeamPassengers()
        if self:IsDrivingSimfphys() then
        if not IsValid(self.l_currentseatsit) then return false end
        local passengers = self.l_currentseatsit:GetPassengerSeats()
        for _, passenger in ipairs(passengers) do
            if IsValid(passenger) and  passenger.IsLambdaPlayer and passenger:Team() == self:Team()  then
                return true
            end
        end
        return false
    end
    end
    function self:StopVehicle(steerDirection)
        
   
        if not IsValid(self.l_currentseatsit) then return end
    
        if self:IsDrivingSimfphys() then
            self.l_currentseatsit.PressedKeys["W"] = false
            self.l_currentseatsit.PressedKeys["S"] = false
            self.l_currentseatsit.PressedKeys["A"] = false
            self.l_currentseatsit.PressedKeys["D"] = false
        else
       
            return
        end
    
       
    end
    
    
    function self:FindNearbyValidPosition()
        local maxAttempts = 10
        for i = 1, maxAttempts do
            local randomDirection = VectorRand():GetNormalized()
            local searchDistance = math.Rand(1, math.huge)
            local targetPos = self:GetPos() + randomDirection * searchDistance
    
            -- Trace to ensure the position is valid
            local trace = util.TraceLine({
                start = self:GetPos() + Vector(0, 0, 10),
                endpos = targetPos,
                filter = self,
                mask = MASK_SOLID
            })
    
            if not trace.Hit and util.IsInWorld(targetPos) then
                return targetPos
            end
        end
        return nil
    end
    
   
function self:EvadeObstacle()
    if self:IsDrivingSimfphys() then 
        self.l_currentseatsit.PressedKeys["S"] = true
        self.l_currentseatsit.PressedKeys["W"] = false
        self.l_currentseatsit:PlayerSteerVehicle(self, 1, 1)
    else
        self.l_currentseatsit:SetThrottle(-1)
        self.l_currentseatsit:SetSteering(1, 0)
    end
    self:SetPoseParameter("vehicle_steer", 1)
end


function self:ReverseAndSteer(steerDirection)
    if self:IsDrivingSimfphys() then 
        self.l_currentseatsit.PressedKeys["W"] = false
        self.l_currentseatsit.PressedKeys["S"] = true
        self.l_currentseatsit:PlayerSteerVehicle(self, 1, 1)
    else
        self.l_currentseatsit:SetThrottle(-1)
        self.l_currentseatsit:SetSteering(1, 0)
    end
end

function self:DriveForward(steerDirection)
    local function IsObstacleAhead(distance)
        local forward = self:GetForward()
        local startPos = self:GetPos() + Vector(0, 100, 80)
        local endPos = startPos + forward * distance

        local tr = util.TraceHull({
            start = startPos,
            endpos = endPos,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 64),
            mask = MASK_SOLID_BRUSHONLY,
            filter = self,
        })

        local isObstacle = tr.Hit and not (tr.Entity and (
            tr.Entity.IsLambdaPlayer or tr.Entity:IsPlayer() or
            tr.Entity:IsNPC() or tr.Entity:IsNextBot()
        ))

        return isObstacle, tr
    end

    if not self:IsDrivingSimfphys() or self.loco:IsStuck() then return end

    local hitWall, wallTrace = IsObstacleAhead(1200)
    if hitWall and wallTrace then
        local wallDistance = self:GetPos():Distance(wallTrace.HitPos)
        local forward = self:GetForward()
        local wallNormal = wallTrace.HitNormal
    
        -- Dot product to determine facing direction
        local facingWallDot = forward:Dot(-wallNormal)
        
        if facingWallDot > 0.6 then -- mostly facing the wall
            local reverseTime = math.Clamp((600 - wallDistance) / 60, 1.5, 3.5)
    
            -- Step 1: Begin reversing
            self.l_currentseatsit.PressedKeys["W"] = false
            self.l_currentseatsit.PressedKeys["S"] = true
    
            timer.Simple(reverseTime, function()
                if not IsValid(self) or not self:IsDrivingSimfphys() then return end
    
                -- Step 2: Stop reversing
                self.l_currentseatsit.PressedKeys["W"] = false
                self.l_currentseatsit.PressedKeys["S"] = false
    
                -- Step 3: Check for side clearance
                local function IsSideClear(offset)
                    local checkPos = self:GetPos() + self:GetRight() * offset
                    local tr = util.TraceHull({
                        start = checkPos + Vector(0, 0, 30),
                        endpos = checkPos + self:GetForward() * 80,
                        mins = Vector(-16, -16, 0),
                        maxs = Vector(16, 16, 64),
                        mask = MASK_SOLID_BRUSHONLY,
                        filter = self
                    })
                    return not tr.Hit
                end
    
                local leftClear = IsSideClear(-200)
                local rightClear = IsSideClear(200)
                local turnKey = nil
                local steerAmount = 0
    
                if leftClear and not rightClear then
                    turnKey = "A"
                    steerAmount = -1
                elseif rightClear and not leftClear then
                    turnKey = "D"
                    steerAmount = 1
                else
                    if math.random(0, 1) == 1 then
                        turnKey = "A"
                        steerAmount = -0.7
                    else
                        turnKey = "D"
                        steerAmount = 0.7
                    end
                end
    
                -- Step 4: Reverse + turn key + steer input
                self.l_currentseatsit.PressedKeys[turnKey] = true
                self.l_currentseatsit.PressedKeys["S"] = true
                self.l_currentseatsit:PlayerSteerVehicle(self,
                    turnKey == "A" and math.abs(steerAmount) or 0,
                    turnKey == "D" and math.abs(steerAmount) or 0
                )
    
                timer.Simple(1.5, function()
                    if not IsValid(self) or not self:IsDrivingSimfphys() then return end
                    local leftClear = IsSideClear(-100)
                    local rightClear = IsSideClear(100)
                    local turnKey = nil
                    local steerAmount = 0
        
                    if leftClear and not rightClear then
                        turnKey = "A"
                        steerAmount = -0.8
                    elseif rightClear and not leftClear then
                        turnKey = "D"
                        steerAmount = 0.8
                    else
                        if math.random(0, 1) == 1 then
                            turnKey = "A"
                            steerAmount = -0.7
                        else
                            turnKey = "D"
                            steerAmount = 0.7
                        end
                    end
        
                    -- Step 4: Reverse + turn key + steer input
                    self.l_currentseatsit.PressedKeys[turnKey] = true
                    self.l_currentseatsit.PressedKeys["S"] = true
                    self.l_currentseatsit:PlayerSteerVehicle(self,
                        turnKey == "A" and math.abs(steerAmount) or 0,
                        turnKey == "D" and math.abs(steerAmount) or 0
                    )
          
                    -- Step 5: Stop reverse & turn keys
                    self.l_currentseatsit.PressedKeys["A"] = false
                    self.l_currentseatsit.PressedKeys["D"] = false
                    self.l_currentseatsit.PressedKeys["S"] = false
    
                    -- Resume forward movement
                    self.l_currentseatsit.PressedKeys["W"] = true
    
                    -- Reset steering
                    self:SetPoseParameter("vehicle_steer", steerAmount)
                end)
            end)
    
            return
        end
    end

    -- Normal movement
    self.l_currentseatsit.PressedKeys["S"] = false
    self.l_currentseatsit.PressedKeys["W"] = true

    -- Steer logic
    if math.random(0, 14) == 3 then
        local steerAmount = math.Clamp(steerDirection * 0.5, -0.6, 0.6)
        self.l_currentseatsit:PlayerSteerVehicle(self,
            (steerAmount < 0) and -steerAmount or 0,
            (steerAmount > 0) and steerAmount or 0
        )
 
    elseif math.random(0, 7) == 2 then
        local steerAmount = math.Clamp(steerDirection * 0.4, -0.5, 0.5)
        self.l_currentseatsit:PlayerSteerVehicle(self, steerAmount, 0)
    end

    self:SetPoseParameter("vehicle_steer", math.Clamp(steerDirection * 0.5, -0.6, 0.6))
end


function self:EngageRamming(target, steerDirection)
    -- Play driver's kill line
    if not self:IsSpeaking() and IsValid(self) then
        self:PlaySoundFile(self:GetVoiceLine("kill"))

        -- Target reactions
        if IsValid(target) and target.IsLambdaPlayer and not target:IsSpeaking() then
            local panicLine = target:GetVoiceLine("panic")
            local witnessLine = target:GetVoiceLine("witness")

            if math.random(0, 4) == 4 and panicLine then
                target:PlaySoundFile(panicLine)
            elseif witnessLine then
                target:PlaySoundFile(witnessLine)
            end
        end

        -- Passengers join in taunting if they're not the driver
        local vehicle = self.l_currentseatsit

            -- Assume passenger seats can be fetched, e.g. simfphys GetPassengerSeats()
            local passengerSeats = {}

            -- For simfphys vehicles
            if self:IsDrivingSimfphys() and vehicle.IsSimfphyscar then
                passengerSeats = vehicle:GetPassengerSeats()
            else
                -- Fallback: find children seats with l_lambdaseated that aren't driver seat
                for _, child in ipairs(vehicle:GetPassengerSeats()) do
                    if child:IsVehicle() and child ~= self.l_currentseatsit then
                        table.insert(passengerSeats, child)
                    end
                end
            end

            for _, seat in ipairs(passengerSeats) do
              if IsValid(seat) and seat.l_lambdaseated and seat.l_lambdaseated ~= self then
                   local passenger = seat.l_lambdaseated

                    if IsValid(passenger) and not passenger:IsSpeaking() then
                        -- Play a taunt sound for the passenger; fallback to "mock" or similar voice line
                      
                       passenger:PlaySoundFile(passenger:GetVoiceLine("kill"))
                       print("MOCKERY.")
                    end
                end
            end
        end
    


    -- Passenger taunts (safe & optional)
    local vehicle = math.random( 1, 3 ) == 1 and self:GetClosestEntity( nil, 100, function( ent ) return ent:GetClass() == "prop_physics" and self:CanSee( ent ) end ) or nil
    if IsValid(vehicle) and vehicle.IsSimfphyscar then
        local passengers = vehicle:GetPassengerSeats()

        if istable(passengers) then
            for _, seat in pairs(passengers) do
                local passenger = IsValid(seat) and seat:GetDriver()
                if IsValid(passenger) and passenger.IsLambdaPlayer and not passenger:IsSpeaking() then


                    if tauntLine then
                        timer.Simple(0.6, function()
                       passenger:PlaySoundFile( passenger:GetVoiceLine("kill") )
                        end)
                    end
                end
            end
        end
    end
end




function self:CheckVehicleExitConditions()
   
end

function self:IsSafeToLeave()
    local enemiesNearby = self:GetEnemiesInRange(600)
    return #enemiesNearby == 0
end

-- Remove parent before it is removed
self:Hook("EntityRemoved", "sitmodule_vehicleremoved", function(ent)
    if ent == self.l_currentseatsit then
        self:SetParent()
    end
end, true)

end
local FLIP_COOLDOWN = 2 -- seconds before next flip attempt allowed

local function CheckAndRightVehicle(self)
    if not IsValid(self.l_currentseatsit) then return end

    local veh = self.l_currentseatsit:GetParent()
    if not IsValid(veh) or not veh:IsVehicle() then return end

    local ang = veh:GetAngles()
    local pitch = math.abs(ang.p)
    local roll = math.abs(ang.r)

    local isFlipped = (pitch > 90 or roll > 90)
    local curTime = CurTime()

    if isFlipped then
        -- If never flipped before or cooldown expired
        if not veh._wasFlipped or (veh._lastFlipTime and curTime - veh._lastFlipTime > FLIP_COOLDOWN) then
            veh._wasFlipped = true
            veh._lastFlipTime = curTime

            local vel = veh:GetVelocity()
            local uprightAng = Angle(0, ang.y, 0) -- completely upright

            local phys = veh:GetPhysicsObject()
            if IsValid(phys) then
           
                veh:SetAngles(uprightAng)
                veh:SetPos(veh:GetPos() + Vector(0, 0, 5))
        
                phys:Wake()
                phys:SetVelocity(vel)
            else
                veh:SetAngles(uprightAng)
                veh:SetPos(veh:GetPos() + Vector(0, 0, 5))
            end
        end
    else
        -- Reset once upright and cooldown expired
        if veh._wasFlipped and (not veh._lastFlipTime or curTime - veh._lastFlipTime > FLIP_COOLDOWN) then
            veh._wasFlipped = false
            veh._lastFlipTime = nil
        end
    end
end

-- Unified cleanup function
local function CleanupVehicleSeat(self)
    if isentity(self.l_currentseatsit) and IsValid(self.l_currentseatsit) then
        self.l_currentseatsit:SetSaveValue("m_hNPCDriver", NULL)
        self.l_currentseatsit.l_lambdaseated = nil
        self:RemoveEffects(EF_BONEMERGE)

        if self:IsDrivingSimfphys() then
            local driverSeat = self.l_currentseatsit:GetDriverSeat()
            if IsValid(driverSeat) then
                driverSeat.l_lambdaseated = nil
            end
            self.l_currentseatsit:SetActive(false)
                  self.l_currentseatsit:StartEngine()
            self.l_currentseatsit:SetDriver( NULL )

            if self.l_currentseatsit.PressedKeys then
                self.l_currentseatsit.PressedKeys["W"] = false
                self.l_currentseatsit.PressedKeys["S"] = false
            end
        elseif self.l_invehicle then
            self.l_currentseatsit:SetThrottle(0)
            self.l_currentseatsit:SetSteering(0, 0)
        end

        -- Run exit function if defined
        if self.l_currentseatsit.l_seatmoduleexitfunc then
            self.GetVehicle_UseDriverSeat = true
            self.l_currentseatsit.l_seatmoduleexitfunc(self, self.l_currentseatsit)
            self.GetVehicle_UseDriverSeat = false
        end

        -- Force seat detach
        self.l_currentseatsit = nil
        self.l_invehicle = false
        self.l_isseatsitting = false
      
    end
end

local function OnRemove(self)
    CleanupVehicleSeat(self)
end

local function OnKilled(self)
    CleanupVehicleSeat(self)
end
local function GetSimfphysWeaponForVehicle(vehicle)
    if not IsValid(vehicle) then return nil, nil end

    local weaponEnt = nil
    local controllingSeatIndex = nil

    -- 1. Check managed vehicles first
    if istable(simfphys.ManagedVehicles) then
        for _, data in pairs(simfphys.ManagedVehicles) do
            if IsValid(data.entity) and data.entity == vehicle then
                weaponEnt = data.func -- This could be a table/module instead of entity
                break
            end
        end
    end

    -- 2. Networked weapon entity
    if not IsValid(weaponEnt) then
        local nwWeapon = vehicle:GetNWEntity("WeaponEntity")
        if IsValid(nwWeapon) and nwWeapon.PrimaryAttack then
            weaponEnt = nwWeapon
        end
    end

    -- 3. Check common stored vars
    if not IsValid(weaponEnt) then
        if vehicle.weapon and IsValid(vehicle.weapon) and vehicle.weapon.PrimaryAttack then
            weaponEnt = vehicle.weapon
        elseif vehicle.WeaponEntity and IsValid(vehicle.WeaponEntity) and vehicle.WeaponEntity.PrimaryAttack then
            weaponEnt = vehicle.WeaponEntity
        end
    end

    -- 4. Search children for entity with PrimaryAttack
    if not IsValid(weaponEnt) then
        for _, ent in ipairs(vehicle:GetChildren()) do
            if IsValid(ent) and ent.PrimaryAttack then
                weaponEnt = ent
                break
            end
        end
    end

    -- --- Seat Detection ---
    if IsValid(weaponEnt) then
        -- Search all passenger seats to see which one the weapon is parented to or linked with
        for seatIndex, seat in ipairs(vehicle.pSeat or {}) do
            if IsValid(seat) then
                -- Check if weapon is directly parented to the seat
                if weaponEnt.Parent == seat then
                    controllingSeatIndex = seatIndex
                    break
                end
                -- Check if weapon is a child/grandchild of seat
                for _, child in ipairs(seat:GetChildren()) do
                    if child == weaponEnt then
                        controllingSeatIndex = seatIndex
                        break
                    end
                end
                if controllingSeatIndex then break end
            end
        end

        -- If no pSeat table exists, fallback to generic "Find the seat closest to weapon"
        if not controllingSeatIndex then
            local closestSeat, closestDist
            for seatIndex, seat in ipairs(vehicle.pSeat or {}) do
                if IsValid(seat) then
                    local dist = seat:GetPos():DistToSqr(weaponEnt:GetPos())
                    if not closestDist or dist < closestDist then
                        closestDist = dist
                        closestSeat = seatIndex
                    end
                end
            end
            controllingSeatIndex = closestSeat
        end
    end

    -- Returns:
    -- weaponEnt = entity/module that fires the weapon
    -- controllingSeatIndex = number index of seat that operates weapon, or nil if unknown
    return weaponEnt, controllingSeatIndex
end



local function IsTurretEntity(vehicle)
    -- Simple heuristic: if vehicle has no wheels or no engine power, treat as turret
    if vehicle.GetNumWheels and vehicle:GetNumWheels() > 0 then
        return false -- has wheels, probably a vehicle
    end

    if vehicle.GetEngineActive and vehicle:GetEngineActive() then
        return false -- engine running, vehicle
    end

    -- Otherwise, treat as turret
    return true
end

local function UniversalTurretAimAtEnemy(ply, vehicle, pod, enemy)
    if not (IsValid(vehicle) and IsValid(pod) and IsValid(enemy)) then return end


    
local weapon, allowedSeatIndex = GetSimfphysWeaponForVehicle(vehicle)
if not weapon then 
    print("[LambdaAimAndFire] No simfphys weapon found for vehicle!")
    return
end

    -- Determine current pod seat index
    local currentSeatIndex
    if vehicle.pSeat then
        for i, seat in ipairs(vehicle.pSeat) do
            if seat == pod then
                currentSeatIndex = i + 1 -- +1 since driver is seat 1
                break
            end
        end
    elseif pod.SeatIndex then
        currentSeatIndex = pod.SeatIndex
    end

    -- If seat index doesn't match, don't aim/fire
    if allowedSeatIndex and currentSeatIndex ~= allowedSeatIndex then
        print("[LambdaAimAndFire] Pod is not the controlling seat for this turret.")
        return
    end


    local attachments = {"cannon_muzzle", "mg_muzzle", "muzzle", "turret_muzzle"}
    local attachID, attachData

    for _, attName in ipairs(attachments) do
        local id = pod:LookupAttachment(attName)
        if id and id > 0 then
            attachID = id
            attachData = pod:GetAttachment(id)
            if attachData then break end
        end
    end

    if not attachData then
        attachData = {Pos = pod:GetPos(), Ang = pod:GetAngles()}
    end

    local poseSource = pod
    if poseSource:GetNumPoseParameters() == 0 then
        poseSource = vehicle
    end

    local poseParams = {}
    for i = 0, poseSource:GetNumPoseParameters() - 1 do
        local name = poseSource:GetPoseParameterName(i)
        poseParams[name] = i
    end

    local yawCandidates = {"cannon_aim_yaw", "mg_aim_yaw", "turret_yaw", "weapon_yaw", "yaw"}
    local pitchCandidates = {"cannon_aim_pitch", "mg_aim_pitch", "turret_pitch", "weapon_pitch", "pitch"}

    local yawParam, pitchParam

    for _, yName in ipairs(yawCandidates) do
        if poseParams[yName] then
            yawParam = yName
            break
        end
    end
    for _, pName in ipairs(pitchCandidates) do
        if poseParams[pName] then
            pitchParam = pName
            break
        end
    end

    local function ClampPoseParam(value)
        return math.Clamp(value, -90, 90)
    end

    local AimRate = 1500
    local turretModels = {
        ["models/snowysnowtime/vehicles/c_gun_turret.mdl"] = true,
        ["models/snowysnowtime/hawk/h2a/shade_turret.mdl"] = true,
    }

    local model = string.lower(vehicle:GetModel() or "")

    if turretModels[model] then
        local phys = vehicle:GetPhysicsObject()
        if IsValid(phys) and phys:IsMotionEnabled() then
            phys:EnableMotion(false) -- Anchor it (disable physics motion)
        end

        -- Calculate angle from entity base to enemy
        local enemyPos = enemy:WorldSpaceCenter()
        local basePos = vehicle:GetPos()
        local dir = (enemyPos - basePos):GetNormalized()
        local desiredAng = dir:Angle()

        -- Normalize angles to [-180,180]
        local currentAng = vehicle:GetAngles()
        local currentPitch = math.NormalizeAngle(currentAng.p)
        local currentYaw = math.NormalizeAngle(currentAng.y)
        local currentRoll = currentAng.r

        local targetPitch = math.NormalizeAngle(desiredAng.p)
        local targetYaw = math.NormalizeAngle(desiredAng.y)

        -- Clamp pitch to avoid flipping (usually between -89 and 89)
        targetPitch = math.Clamp(targetPitch, -89, 89)

        -- Smoothly rotate angles toward desired angles
        local newPitch = math.ApproachAngle(currentPitch, targetPitch, AimRate * FrameTime())
        local newYaw = math.ApproachAngle(currentYaw, targetYaw, AimRate * FrameTime())

        vehicle:SetAngles(Angle(newPitch, newYaw, currentRoll))
    end

    if yawParam and pitchParam then
        -- Pose parameter aiming mode
        local enemyPos = enemy:WorldSpaceCenter()
        local posePos = poseSource:GetPos()
        local toEnemyWorldVec = (enemyPos - posePos):GetNormalized()

        local poseForward = poseSource:GetForward()
        local poseRight = poseSource:GetRight()
        local poseUp = poseSource:GetUp()

        -- Calculate local pitch and yaw from toEnemyWorldVec
        local localPitch = math.asin(toEnemyWorldVec:Dot(poseUp)) * (180 / math.pi)
        local localYaw = math.atan2(toEnemyWorldVec:Dot(poseRight), toEnemyWorldVec:Dot(poseForward)) * (180 / math.pi)

        local currentYaw = poseSource.sm_pp_yaw or 0
        local currentPitch = poseSource.sm_pp_pitch or 0

        poseSource.sm_pp_yaw = math.ApproachAngle(currentYaw, localYaw, AimRate * FrameTime())
        poseSource.sm_pp_pitch = math.ApproachAngle(currentPitch, localPitch, AimRate * FrameTime())

        local clampedYaw = ClampPoseParam(poseSource.sm_pp_yaw)
        local clampedPitch = ClampPoseParam(poseSource.sm_pp_pitch)

        poseSource:SetPoseParameter(yawParam, clampedYaw)
        poseSource:SetPoseParameter(pitchParam, -clampedPitch)
    else
        -- If no pose params, see if we can aim just the weapon entity
        local weaponEntity = vehicle:GetNWEntity("WeaponEntity")
        if IsValid(weaponEntity) then
            local enemyPos = enemy:GetPos()
            local weaponPos = weaponEntity:GetPos()
            local dir = (enemyPos - weaponPos):GetNormalized()
            local desiredAng = dir:Angle()

            local currentAng = weaponEntity:GetAngles()
            local currentPitch = math.NormalizeAngle(currentAng.p)
            local currentYaw = math.NormalizeAngle(currentAng.y)
            local currentRoll = currentAng.r

            local targetPitch = math.Clamp(math.NormalizeAngle(desiredAng.p), -89, 89)
            local targetYaw = math.NormalizeAngle(desiredAng.y)

            local newPitch = math.ApproachAngle(currentPitch, targetPitch, AimRate * FrameTime())
            local newYaw = math.ApproachAngle(currentYaw, targetYaw, AimRate * FrameTime())

            weaponEntity:SetAngles(Angle(newPitch, newYaw, currentRoll))
        else
            -- Fallback: if no weapon entity, then angle the whole vehicle
        end
    end

    -- Use muzzle attachment pos for firing position
    local muzzleWorldPos = attachData.Pos

    -- Fire primary attack
    -- Determine actual muzzle position
    local finalMuzzlePos = muzzleWorldPos

    if not yawParam or not pitchParam then
        -- Params unsupported: aim directly at enemy
        if IsValid(enemy) then
            -- Fire from turret origin but aim toward enemy's center
            local turretPos = vehicle:GetPos()
            local enemyCenter = enemy:WorldSpaceCenter()
            local dir = (enemyCenter - turretPos):GetNormalized()

            -- Shift forward from turret to avoid firing from its origin
            finalMuzzlePos = turretPos + dir * 50
        end
    end

    -- Determine shooter: driver or passenger
    local shooter = ply
    if not shooter or not IsValid(shooter) then
        shooter = ply -- fallback, but should be valid
    end

    if (not yawParam or not pitchParam) and not ply:IsDrivingSimfphys() then
        local turretPos = pod:GetPos()
        local enemyPos = enemy:WorldSpaceCenter()
        local dir = (enemyPos - turretPos):GetNormalized()

        -- Aim weapon entity toward enemy
        local desiredAng = dir:Angle()
        local curAng = pod:GetAngles()
        local aimRate = 1500
        local newPitch = math.ApproachAngle(curAng.p, desiredAng.p, aimRate * FrameTime())
        local newYaw   = math.ApproachAngle(curAng.y, desiredAng.y, aimRate * FrameTime())

        -- Fire from updated aim direction
        local forward = pod:GetForward()
        local adjustedMuzzlePos = pod:GetPos() + forward * 50 -- offset from barrel
          if isfunction(weapon.AimWeapon) then
        weapon:AimWeapon(ply, vehicle, pod)
          end
             if isfunction(weapon.AimCannon) then
        weapon:AimCannon(ply, vehicle, pod, attachData)
          end
          if isfunction(weapon.AimMachinegun) then
        weapon:AimMachinegun(ply, vehicle, pod)
          end
           if isfunction(weapon.ControlMachinegun) then
            vehicle.smTmpMG = 0
        weapon:ControlMachinegun(ply, vehicle, pod)
          end
            if isfunction(weapon.Attack) then
        weapon:Attack(vehicle, ply, attachData.Pos, attachData)
          end
          if isfunction(weapon.PrimaryAttack) then
        weapon:PrimaryAttack(vehicle, shooter, enemy:GetPos(), attachData)
          end
          timer.Simple(math.random(0, 1.6), function()
            if isfunction(weapon.SecondaryAttack) then
                weapon:SecondaryAttack(vehicle, shooter, enemy:GetPos(), attachData)
            end
          end)
    else
        local turretPos = pod:GetPos()
        local enemyPos = enemy:WorldSpaceCenter()
        local dir = (enemyPos - turretPos):GetNormalized()

        -- Aim weapon entity toward enemy
        local desiredAng = dir:Angle()
        local curAng = pod:GetAngles()
        local aimRate = 1500
        local newPitch = math.ApproachAngle(curAng.p, desiredAng.p, aimRate * FrameTime())
        local newYaw   = math.ApproachAngle(curAng.y, desiredAng.y, aimRate * FrameTime())

        -- Fire from updated aim direction
        local forward = pod:GetForward()
        local adjustedMuzzlePos = pod:GetPos() + forward * 50 -- offset from barrel

        weapon:PrimaryAttack(pod, shooter, enemy:GetPos(), attachData)
    end

    -- Delay check for projectile entity creation
    timer.Simple(0, function()
        if not IsValid(weapon) then return end
        if not IsValid(shooter) then return end

        for _, proj in ipairs(ents.FindInSphere(muzzleWorldPos, math.huge)) do
            if proj:GetOwner() == vehicle or proj:GetOwner() == shooter then
                proj:SetOwner(shooter) -- Assign correct shooter
                proj.TargetEntity = enemy

                -- Override think for homing projectiles
                function proj:Think()
                    if not IsValid(self.TargetEntity) then return end

                    local targetPos = self.TargetEntity:WorldSpaceCenter()
                    local dir = (targetPos - self:GetPos()):GetNormalized()
                    local speed = self:GetVelocity():Length()

                    self:SetVelocity(dir * speed)
                    self:SetAngles(dir:Angle())
                    self:NextThink(CurTime())
                    return true
                end
            end
        end
    end)

    -- Optionally secondary attack after delay
    if turretModels[model] then
        timer.Simple(math.random(0.1, 1.6), function()
            if IsValid(weapon) and IsValid(shooter) then
                weapon:SecondaryAttack(vehicle, shooter, muzzleWorldPos, attachData)
            end
        end)
    end
end
local function GetVehicleFromSeat(seat)
    if not IsValid(seat) then return nil end

    -- If seat itself is a simfphys car (rare), return it
    if seat.IsSimfphyscar then return seat end

    local parent = seat:GetParent()
    if not IsValid(parent) then return nil end

    -- Parent must be a simfphys vehicle
    if not parent.IsSimfphyscar then return nil end

    -- Check if seat is driver's seat
    if parent:GetDriverSeat() == seat then
        return parent
    end

    -- Check passenger seats explicitly
    local passengerSeats = parent.GetPassengerSeats and parent:GetPassengerSeats() or {}
    for _, pseat in ipairs(passengerSeats) do
        if pseat == seat then
            return parent
        end
    end

    -- No match found, return nil
    return nil
end


local function Think(self)
    if CLIENT then return end
    CheckAndRightVehicle(self)

    -- Vehicle seating logic (your original code)
    if self.l_isseatsitting and self:Alive() then
        self.l_wasseatsitting = true
        self.l_UpdateAnimations = false

        if (not IsValid(self.l_currentseatsit)) or (self:IsDrivingSimfphys() and self.l_currentseatsit:OnFire()) or
           (self.l_sitendtime and CurTime() > self.l_sitendtime) then
            self.l_isseatsitting = false
            return
        end

        if self:IsDrivingSimfphys() and self.l_currentseatsit:GetDriverSeat() and self.l_currentseatsit:GetDriverSeat().l_lambdaseated == self then
            self:RemoveEffects(EF_BONEMERGE)
        end

      if self:IsDrivingSimfphys() and self.l_currentseatsit.l_lambdaseated == self then
    local seat = self.l_currentseatsit
    if IsValid(seat) then
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)


         self:SetLocalAngles(Angle(0, 0, 0))
        self.loco:SetVelocity(Vector())
    else
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:AddEffects(EF_BONEMERGE)



         self:SetLocalAngles(Angle(0, 0, 0))
        self.loco:SetVelocity(Vector())
    end
else
    local seat = self.l_currentseatsit
    if IsValid(seat) then
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)


    -- Optional: apply offset if needed (to fix alignment)
    -- pos = pos + seat:GetForward() * forwardOffset + seat:GetRight() * rightOffset + seat:GetUp() * upOffset

    -- Snap lambda to seat position and angle every tick

  local seatAng = seat:GetAngles()
-- Adjust angles so the lambda faces forward instead of sideways
local fixedAng = seatAng + Angle(0, 90, 0) -- Example offset, tune this value
--self:AddEffects(EF_BONEMERGE)

self:SetAngles(fixedAng)

                    self:SetMoveType( MOVETYPE_NONE )

 self:AddEffects(EF_BONEMERGE)

self:SetPos(seat:GetPos())
self:SetAngles(seat:GetAngles())

    end
end


        if self:IsDrivingSimfphys() and self.l_currentseatsit:GetDriverSeat() and self.l_currentseatsit:GetDriverSeat().l_lambdaseated == self then
            self:RemoveEffects(EF_BONEMERGE)
        end

     local attach
  local attachID = self.l_currentseatsit:LookupAttachment("vehicle_feet_passenger0")
if attachID and attachID > 0 then
    attach = self.l_currentseatsit:GetAttachment(attachID)
else
    attach = nil
end
if attach then
    self:SetPos(attach.Pos)
    self:SetAngles(attach.Ang)
else
    self:SetPos(self.l_currentseatsit:GetPos())
    self:SetAngles(self.l_currentseatsit:GetAngles())
end

    local pos, ang
if isentity(self.l_currentseatsit) and IsValid(self.l_currentseatsit) then
    local seat = self.l_currentseatsit
    local vehicle = GetVehicleFromSeat(seat) or seat
    
    -- Get driver seat, if applicable
    local driverSeat = vehicle.GetDriverSeat and vehicle:GetDriverSeat()
    
    -- If lambda is driving, use driver seat pos/ang with facing adjustment
    if self:IsDrivingSimfphys() and IsValid(driverSeat) then
        pos = driverSeat:GetPos()
        ang = driverSeat:GetAngles() + Angle(0, 90, 0) -- Facing adjustment for driver seat
    else
        -- Otherwise for passengers, use attachment pos/ang if available, else seat pos/ang
        if attach then
            pos = attach.Pos
            ang = attach.Ang
        else
            pos = seat:GetPos()
            ang = seat:GetAngles()
        end
    end

    -- Apply seat normal vector offsets (optional custom offset)
    if self.l_seatnormvector then
        pos = pos 
            + seat:GetForward() * self.l_seatnormvector[1] 
            + seat:GetRight() * self.l_seatnormvector[2] 
            + seat:GetUp() * self.l_seatnormvector[3]
    end

    if not self.l_PoseOnly then
        self.Face = nil -- Prevent lambda facing overrides
    end

    self.loco:SetVelocity(Vector()) -- Stop residual velocity
end

-- Snap to the calculated position and angles
if pos then self:SetPos(pos) end
if ang then self:SetAngles(ang) end


        -- Set animations based on seat type


      if !self.l_currentseatsit and self:GetActivity() != ACT_GMOD_SHOWOFF_DUCK_02 then -- Sitting on ground
            self:SetActivity( ACT_GMOD_SHOWOFF_DUCK_02 )
        elseif isentity( self.l_currentseatsit ) and IsValid( self.l_currentseatsit ) and self.l_invehicle and self:GetActivity() != ACT_DRIVE_JEEP then -- Sitting in a vehicle
            self:SetActivity( ACT_DRIVE_JEEP )
        elseif isentity( self.l_currentseatsit ) and IsValid( self.l_currentseatsit ) and !self.l_invehicle and self:GetActivity() != ACT_GMOD_SIT_ROLLERCOASTER then -- Sitting in a chair
            self:SetActivity( ACT_GMOD_SIT_ROLLERCOASTER )
        end
        self.loco:SetVelocity(Vector(0, 0, 0)) -- Stop residual velocity

        -- ========== NEW WEAPON/TURRET PASSENGER/DRIVER LOGIC ==========

      local enemy = self:GetEnemy()
if IsValid(enemy) and IsValid(self.l_currentseatsit) then
    local curTime = CurTime()
if curTime < (self.NextTurretThink or 0) then return end
self.NextTurretThink = curTime + 0.05  -- run roughly every 0.15 seconds
 
    if IsValid(self.l_currentseatsit) and self.l_invehicle then
       UniversalTurretAimAtEnemy(ply, vehicle, pod, enemy)

        print("ENEMY!")
    end
end
local pod = self.l_currentseatsit
if not IsValid(pod) then return end

-- Get the vehicle related to this seat explicitly
local vehicle = GetVehicleFromSeat(pod)
if not IsValid(vehicle) or pod.l_invehicle then return end

-- Get all passenger seats of the vehicle
local passengerSeats = vehicle.GetPassengerSeats and vehicle:GetPassengerSeats() or {}

-- Check if the pod is a valid passenger seat of the vehicle
local isPodPassengerSeat = false
for _, seat in ipairs(passengerSeats) do
    if seat == pod then
        isPodPassengerSeat = true
        break
    end
end

-- Get the driver seat of the vehicle
local driverSeat = vehicle:GetDriverSeat()

-- Confirm the AI is in the exact pod seat or driving the vehicle
local occupantIsValid = false

if isPodPassengerSeat and pod == self.l_currentseatsit then
    occupantIsValid = true
elseif driverSeat == self.l_currentseatsit and self:IsDrivingSimfphys() then
    occupantIsValid = true
end

if occupantIsValid then
    local enemy = self:GetEnemy()
    if IsValid(enemy) then
        UniversalTurretAimAtEnemy(self, vehicle, pod, enemy)
    end
else
    -- This AI is not controlling the seat or driving, so no turret control here
    return
end


        -- ===========================================================

    elseif self.l_wasseatsitting then
        -- Reset when player stops sitting
        self:ResetSitInfo()
        self:RemoveEffects(EF_BONEMERGE)
    end
end

-- Hook properly
hook.Add("LambdaOnRemove", "lambdaseatmodulenew_remove", OnRemove)
hook.Add("LambdaOnKilled", "lambdaseatmodulenew_killed", OnKilled)
hook.Add("LambdaOnThink", "lambdaseatmodulenew_think", Think)
hook.Add("LambdaOnInitialize", "lambdaseatmodulenew_init", Initialize)

-- FIX START
local function RegisterSeatModuleFeatures()
    -- Register UAction if the system exists
    if AddUActionToLambdaUA then
        AddUActionToLambdaUA( function( self )
            if allowsitting:GetBool() and !self:InCombat() and !self:IsSitting() and math.random( 0, 100 ) < 50 then 
                local nearent = math.random( 1, 3 ) == 1 and self:GetClosestEntity( nil, 100, function( ent ) return ent:GetClass() == "prop_physics" and self:CanSee( ent ) end ) or nil
                self:Sit( nearent, math.Rand( 5, 60 ) ) 
            end
        end )
    end

    -- Register Vehicle Personality if the system exists
    if LambdaCreatePersonalityType then
        LambdaCreatePersonalityType( "Vehicle", function( self )
            local hassimfphys = false
            local nearent = self:GetClosestEntity( nil, 3000, function( ent ) 
                if ent.IsSimfphyscar and IsSimfphysOpen( ent ) and self:CanSee( ent ) then 
                    hassimfphys = true 
                    return true 
                end

                if not ent.IsSimfphyscar and not hassimfphys and ent:IsVehicle() and 
                   (not IsValid(ent:GetDriver()) or ent:GetDriver() == self) and
                   not IsValid(ent.l_lambdaseated) then
                    return true
                end
            end )

            if IsValid( nearent ) then
                self:MoveToPos( nearent:GetPos() + ( self:GetPos() - nearent:GetPos() ):GetNormalized() * 100, { autorun = true } )
                if not IsValid( nearent ) then return end
                if self:IsInRange( nearent, 200 ) then 
                    self:Sit( nearent, math.Rand( 360, 10000 ) )  
                end
            end
        end )
    end
end

if LambdaCreatePersonalityType then
    RegisterSeatModuleFeatures()
else
    hook.Add( "Initialize", "LambdaSeatModule_SafeRegister", RegisterSeatModuleFeatures )
end