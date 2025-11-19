
local CurTime = CurTime
local IsValid = IsValid
local random = math.random

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    AR_whatanicetree = {
        model = "models/props_foliage/tree_poplar_01.mdl",
        origin = "Asylum Rejects",
        prettyname = "Birch Tree",
        holdtype = "melee2",
        killicon = "vgui/goofylambdas/birchtree",
        ismelee = true,
        bonemerge = false,
        deploydelay = 2.65,
        keepdistance = 65,
        attackrange = 185,

       OnDeploy = function(self, wepent)
       self:EmitSound("GoofyLambdas/treedraw.wav", 90)
       end,

        OnAttack = function( self, wepent, target )
            self.l_WeaponUseCooldown = CurTime() + LambdaRNG( 5, 5, true )
            self.l_HoldType = "melee2"
            wepent:EmitSound("GoofyLambdas/treeswing.wav",110,100)
        
            local shootPos = ( isvector( target ) and target or target:WorldSpaceCenter() )
            local muzzlePos = wepent:GetPos()
            local shootAng = self:GetAimVector():Angle()
            shootPos = ( shootPos + shootAng:Right() * random( -8, 8 ) + ( shootAng:Up() * ( random( -8, 8 )  ) ) )

    
   
            self:SimpleWeaponTimer( 1.88, function()
                if !IsValid( target ) or !self:IsInRange( target, 115 ) then return end
                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
                local gestAttack = self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
                self:SetLayerPlaybackRate( gestAttack, 0.8 )
                local dmg = LambdaRNG( 150 , 151 )
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
                self.l_HoldType = "melee2"
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

                wepent:EmitSound("GoofyLambdas/treekill.wav",110,100)
            end )
            if IsValid(self) or IsValid(wepent) then
            timer.Simple(2, function()
                 self.l_HoldType = "melee2"
            end)
        end
            return true
        end,

        islethal = true,
    }

} )