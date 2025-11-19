local EffectData = EffectData
local util_Effect = util.Effect


local VectorRand = VectorRand

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    fn_chugjug = {
        model = "models/fortnite/w_fbr_chugjug.mdl",
        origin = "Fortnite",
        prettyname = "Chug Jug",
        holdtype = "melee2",
        keepdistance = 400,
        attackrange = 900,
        islethal = false,
        bonemerge = true,

        OnHolster = function( self, wepent )
            self:StopSound("fortnite/chugjug_drink.ogg")
            end,


        OnThink = function( self, wepent, dead )
            if !dead and LambdaRNG( 3 ) != 1 then
                self:LookTo( self:EyePos() + VectorRand( -400, 400 ), 1.25 )
                self:SimpleWeaponTimer( 0.8, function() self:UseWeapon() end )
            end

            return LambdaRNG( 0.55, 10, true )
        end,

        OnAttack = function( self, wepent )
            self:EmitSound( "fortnite/chugjug_drink.ogg", 90)
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
           self:SimpleWeaponTimer( 13.00, function()
                self:ApplyEffect("Energized", 0.2, 100, 1, 100)
                self:ApplyEffect("Healing", 0.2, 100, 1)
                self:StopSound("fortnite/chugjug_drink.ogg")
                self:EmitSound("fortnite/chugjug_drinkcomplete.ogg", 90)
           end)
          self.l_WeaponUseCooldown = ( CurTime() + 13.00 )

   
            return true
        end
    }
} )