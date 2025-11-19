local random = math.random
local CurTime = CurTime
local IsValid = IsValid
local isvector = isvector
local Rand = math.Rand
local util_Effect = util.Effect
table.Merge( _LAMBDAPLAYERSWEAPONS, {
    ohitwasjustacough = {
        model = "models/hunter/plates/plate.mdl",
        origin = "Memes",
        prettyname = "CURSE YOU!!!",
        holdtype = "normal",
        killicon = "",
        nodraw = true,
        bonemerge = true,
        dropentity = "",

        clip = math.huge,
        deploydelay = 1,
        islethal = true,
        keepdistance = 400,
        attackrange = 1000,

        OnDeploy = function( lambda, wepent )
         wepent:EmitSound( "GoofyLambdas/curseyou_draw.mp3", 350, 100, CHAN_WEAPON )   
        end,

        OnDeath = function(self, wepent)
            checked = false
           self:SetWalkSpeed(200)  
           self:SetRunSpeed(400) 
       end,

        OnAttack = function( lambda, wepent, target )
            local lamwalkspeed = lambda:GetWalkSpeed()
            local lamsprinspeed = lambda:GetRunSpeed()
            local muzzlePos = wepent:GetPos()
            local shootPos = ( isvector( target ) and target or target:WorldSpaceCenter() )

   

            lambda:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER )
            lambda:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER, true )

            lambda.l_WeaponUseCooldown = ( CurTime() + Rand( 12, 12 ) )
            wepent:EmitSound( "GoofyLambdas/curseyou_cast.mp3", 350, 100, CHAN_WEAPON ) 
            lambda.l_HoldType = "magic"
            lambda:SetWalkSpeed(30)
            lambda:SetRunSpeed(30)
            if lambda:Health() <= 25 then
                lambda:SetWalkSpeed(lamwalkspeed)
                lambda:SetRunSpeed(lamsprinspeed)
            else

            end
            local effectData = EffectData()
            effectData:SetOrigin( lambda:GetPos() * 10 )
            effectData:SetRadius( 200 )
            util_Effect( "cball_explode", effectData, true, true )
            local muzzleEffect2 = ents.Create("light_dynamic")
            muzzleEffect2:SetColor(Color(88, 136, 128))
            muzzleEffect2:SetKeyValue("brightness", "8")
            muzzleEffect2:SetKeyValue("distance", "160")
            muzzleEffect2:SetPos(wepent:GetPos())
            muzzleEffect2:SetParent(lambda)
            muzzleEffect2:Spawn()
            muzzleEffect2:Activate()
            muzzleEffect2:Fire("TurnOn", "", 0)
            muzzleEffect2:Fire("TurnOff", "", 0.95)
            muzzleEffect2:Fire("Kill", "", 0.97)

            
            lambda:SimpleWeaponTimer( 0.97, function()

                local pullAnim = lambda:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
                lambda:SetLayerCycle( pullAnim, 0.66 )
                lambda:SetLayerPlaybackRate( pullAnim, 1.25 )
                local muzzleEffect = ents.Create("light_dynamic")
                muzzleEffect:SetColor(Color(255,75,40,255))
                muzzleEffect:SetKeyValue("brightness", "10")
                muzzleEffect:SetKeyValue("distance", "200")
                muzzleEffect:SetPos(wepent:GetPos())
                muzzleEffect:SetParent(lambda)
                muzzleEffect:Spawn()
                muzzleEffect:Activate()
                muzzleEffect:Fire("TurnOn", "", 0)
                muzzleEffect:Fire("TurnOff", "", 0.15)
                muzzleEffect:Fire("Kill", "", 0.17)

               

                target:ApplyEffect("Wither", 10, 10, 0.1, lambda)
                lambda.l_HoldType = "normal"
                lambda:SetWalkSpeed(lamwalkspeed)
                lambda:SetRunSpeed(lamsprinspeed)
            end )

           
            return true
        end
    }
} )