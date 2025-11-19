local EffectData = EffectData
local util_Effect = util.Effect


local VectorRand = VectorRand

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    fn_bandages = {
        model = "models/fortnite/w_fbr_bandage.mdl",
        origin = "Fortnite",
        prettyname = "Bandages",
        holdtype = "slam",
        keepdistance = 400,
        attackrange = 900,
        islethal = false,
        bonemerge = true,

        OnHolster = function( self, wepent )
            self:StopSound("fortnite/bandage_apply.ogg")
            end,


        OnThink = function( self, wepent, dead )
            if !dead and LambdaRNG( 3 ) != 1 then
                self:LookTo( self:EyePos() + VectorRand( -400, 400 ), 1.25 )
                self:SimpleWeaponTimer( 0.8, function() self:UseWeapon() end )
            end

            return LambdaRNG( 0.55, 10, true )
        end,

        OnAttack = function( self, wepent )
            self:EmitSound( "fortnite/bandage_apply.ogg", 90)
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            -- FIXED CODE
            self:SimpleWeaponTimer( 3, function()
                local target = self:GetEnemy()
                
                -- Add this check:
                if IsValid( target ) and target.ApplyEffect then
                    target:ApplyEffect( "healing" )
                end
            end)
            self.l_WeaponUseCooldown = ( CurTime() + 3.60 )

   
            return true
        end
    }
} )