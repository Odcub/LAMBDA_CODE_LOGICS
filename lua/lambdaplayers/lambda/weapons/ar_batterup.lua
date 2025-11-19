
local CurTime = CurTime
local IsValid = IsValid
local random = math.random

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    ar_batterup = {
        model = "models/lambdaplayers/tf2/weapons/w_bonk_bat.mdl",
        origin = "Asylum Rejects",
        prettyname = "Home-Run Bat",
        holdtype = "normal",
        killicon = "vgui/goofylambdas/homerun",
        ismelee = true,
        bonemerge = true,
        keepdistance = 65,
        attackrange = 185,

       OnDeploy = function(self, wepent)
       self:EmitSound("GoofyLambdas/homerun/draw.mp3", 90)
       end,

       OnDealDamage = function(lambda, wepent, target, dmginfo, dealtDamage, lethal)
            if dealtDamage then
                target:ApplyEffect("Incapacitated", 5)
            end
        end,

        OnAttack = function( self, wepent, target )
            self.l_WeaponUseCooldown = CurTime() + LambdaRNG( 2.70, 2.71, true )
            self.l_HoldType = "melee2"
            wepent:EmitSound("GoofyLambdas/homerun/charge.mp3",110,100)
        
            local shootPos = ( isvector( target ) and target or target:WorldSpaceCenter() )
            local muzzlePos = wepent:GetPos()
            local shootAng = self:GetAimVector():Angle()
            shootPos = ( shootPos + shootAng:Right() * random( -8, 8 ) + ( shootAng:Up() * ( random( -8, 8 )  ) ) )

    
   
            self:SimpleWeaponTimer( 1.5, function()
                if !IsValid( target ) or !self:IsInRange( target, 115 ) then return end
                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE )
                local gestAttack = self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE )
                self:SetLayerPlaybackRate( gestAttack, 0.8 )
                local dmg = LambdaRNG( 70, 75 )
                local attackAng = ( target:WorldSpaceCenter() - self:EyePos() ):Angle()
                local attackForce = ( attackAng:Forward() * ( dmg * 1250 ) + attackAng:Up() * ( dmg * 1250 ) )
                local dmginfo = DamageInfo()
                local aimDir = self:GetAimVector()
                local pos = self:GetPos()
                pos = pos + aimDir * 1 + aimDir * -4
                dmginfo:SetDamage( dmg )
                dmginfo:SetAttacker( self )
                dmginfo:SetInflictor( wepent )
                dmginfo:SetDamageType( bit.bor( DMG_CLUB, DMG_CRUSH ) )
                self.l_HoldType = "normal"
                -- Doesn't send them flying if not done like this
                if target.IsLambdaPlayer then
              
                    target.loco:Jump()
                    target.loco:SetVelocity( target.loco:GetVelocity() + ( attackForce * 0.01 ) )
           
                    timer.Simple(0.1, function()
                        if !LambdaIsValid( target ) then return end
                        target:TakeDamageInfo( dmginfo )
                    end)
                else
                    dmginfo:SetDamageForce( attackForce )
                    target:TakeDamageInfo( dmginfo )
                end

                wepent:EmitSound("GoofyLambdas/homerun/hit.mp3",110,100)
                self.l_HoldType = "normal"
            end )
            if IsValid(self) or IsValid(wepent) then
            timer.Simple(2, function()
                 self.l_HoldType = "normal"
            end)
        end
            return true
        end,

        islethal = true,
    }

} )