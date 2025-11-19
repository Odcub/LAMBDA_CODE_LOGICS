local EffectData = EffectData
local util_Effect = util.Effect


local VectorRand = VectorRand

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    fn_fullpot = {
        model = "models/fortnite/w_fbr_shieldpotion.mdl",
        origin = "Fortnite",
        prettyname = "Shield Potion",
        holdtype = "slam",
        keepdistance = 400,
        attackrange = 900,
        islethal = false,
        bonemerge = true,

        OnHolster = function( self, wepent )
            self:StopSound("fortnite/shieldpotion_drink.ogg")
            self:RemoveEffect("Energized")
            end,


        OnThink = function( self, wepent, dead )
            if !dead and LambdaRNG( 3 ) != 1 then
                self:LookTo( self:EyePos() + VectorRand( -400, 400 ), 1.25 )
                self:SimpleWeaponTimer( 0.8, function() self:UseWeapon() end )
            end

            return LambdaRNG( 0.55, 10, true )
        end,

        OnAttack = function( self, wepent )
            self:EmitSound( "fortnite/shieldpotion_drink.ogg", 90)
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            self:ApplyEffect("Energized", 2.5, 10, 0.5, 100)
           self:SimpleWeaponTimer( 2.5, function()

                self:StopSound("fortnite/shieldpotion_drink.ogg")
                self:EmitSound("fortnite/slurpjuice_drinkcomplete.ogg", 90)
           end)
          self.l_WeaponUseCooldown = ( CurTime() + 3 )

   
            return true
        end
    }
} )