
local CurTime = CurTime
local IsValid = IsValid
local random = math.random

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    AR_duckthisone = {
        model = "models/hunter/plates/plate.mdl",
        origin = "Asylum Rejects",
        prettyname = "Old School",
        killicon = "vgui/goofylambdas/doc",
        holdtype = "normal",
        ismelee = true,
        bonemerge = true,
        dropondeath = false,
        nodraw = true,
        keepdistance = 65,
        attackrange = 185,

       OnDealDamage = function(lambda, wepent, target, dmginfo, dealtDamage, lethal)
            if dealtDamage then
                target:ApplyEffect("Wither", 2.5, 100, 0.1)
            end
        end,


        OnAttack = function( self, wepent, target )
            self.l_WeaponUseCooldown = CurTime() + LambdaRNG( 5, 5, true )
            self.l_HoldType = "fist"
            wepent:EmitSound("goofylambdas/doc_swing.wav", 90)
        
            local shootPos = ( isvector( target ) and target or target:WorldSpaceCenter() )
            local muzzlePos = wepent:GetPos()
            local shootAng = self:GetAimVector():Angle()
            shootPos = ( shootPos + shootAng:Right() * random( -8, 8 ) + ( shootAng:Up() * ( random( -8, 8 )  ) ) )

    
   
            self:SimpleWeaponTimer( 0.60, function()
                if !IsValid( target ) or !self:IsInRange( target, 115 ) then return end
                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST )
                local gestAttack = self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST )
                self:SetLayerPlaybackRate( gestAttack, 0.8 )
                local dmg = LambdaRNG( 250 , 250 )
                local attackAng = ( target:WorldSpaceCenter() - self:EyePos() ):Angle()
                local attackForce = ( attackAng:Forward() * ( dmg * 1250 ) + attackAng:Up() * ( dmg * 1250 ) )
                local dmginfo = DamageInfo()
                local aimDir = self:GetAimVector()
                local pos = self:GetPos()
                pos = pos + aimDir * 1 + aimDir * -4
                dmginfo:SetDamage( dmg )
                dmginfo:SetAttacker( self )
                dmginfo:SetInflictor( wepent )
                dmginfo:SetDamageType( bit.bor( DMG_DISSOLVE, DMG_DISSOLVE ) )
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

                wepent:EmitSound("goofylambdas/doc_kill.wav", 90)
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