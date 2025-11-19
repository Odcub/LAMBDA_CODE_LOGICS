local EffectData = EffectData
local util_Effect = util.Effect


local VectorRand = VectorRand

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    fn_slurpjuice = {
        model = "models/fortnite/w_fbr_slurpjuice.mdl",
        origin = "Fortnite",
        prettyname = "Slurp Juice",
        holdtype = "slam",
        keepdistance = 400,
        attackrange = 900,
        islethal = false,
        bonemerge = true,

        OnHolster = function( self, wepent )
            self:StopSound("fortnite/slurpjuice_drink.ogg")
            end,


        OnThink = function( self, wepent, dead )
            if !dead and LambdaRNG( 3 ) != 1 then
                self:LookTo( self:EyePos() + VectorRand( -400, 400 ), 1.25 )
                self:SimpleWeaponTimer( 0.8, function() self:UseWeapon() end )
            end

            return LambdaRNG( 0.55, 10, true )
        end,

        OnAttack = function( self, wepent )
            self:EmitSound( "fortnite/slurpjuice_drink.ogg", 90)
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
           self:SimpleWeaponTimer( 2.30, function()
              self:ApplyEffect("Energized", 25, 5, 1, 100)
                self:ApplyEffect("Healing", 25, 5, 1)
                self:StopSound("fortnite/slurpjuice_drink.ogg")
                self:EmitSound("fortnite/slurpjuice_drinkcomplete.ogg", 90)
           end)
          self.l_WeaponUseCooldown = ( CurTime() + 27.30 )

   
            return true
        end
    }
} )