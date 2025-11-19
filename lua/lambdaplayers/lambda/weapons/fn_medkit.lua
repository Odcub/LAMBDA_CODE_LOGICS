local EffectData = EffectData
local util_Effect = util.Effect


local VectorRand = VectorRand

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    fn_medkit = {
        model = "models/fortnite/w_fbr_medkit.mdl",
        origin = "Fortnite",
        prettyname = "Medkit",
        holdtype = "slam",
        keepdistance = 400,
        attackrange = 900,
        islethal = false,
        bonemerge = true,

        OnHolster = function( self, wepent )
            self:StopSound("fortnite/medkit_use.ogg")
            self:RemoveEffect("Healing")
            end,


        OnThink = function( self, wepent, dead )
            if !dead and LambdaRNG( 3 ) != 1 then
                self:LookTo( self:EyePos() + VectorRand( -400, 400 ), 1.25 )
                self:SimpleWeaponTimer( 0.8, function() self:UseWeapon() end )
            end

            return LambdaRNG( 0.55, 10, true )
        end,

        OnAttack = function( self, wepent )
            self:EmitSound( "fortnite/medkit_use.ogg", 90)
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
            
            -- Replaced self:ApplyEffect with a timed heal loop
            local heal_duration = 7.60
            local total_heal = 7
            local tick_interval = 0.5 -- Same as the last ApplyEffect argument
            
            -- Start the sound and the periodic healing
            self:SimpleWeaponTimer( 0, function()
                if not IsValid(self) or self:IsDead() then return end
                self:SetHealth( self:Health() + ( total_heal * tick_interval / heal_duration ) )
            end, tick_interval, math.ceil( heal_duration / tick_interval ) )
            
            -- Stop sound and play completion sound after full duration
           self:SimpleWeaponTimer( heal_duration, function()
                self:StopSound("fortnite/medkit_use.ogg")
                self:EmitSound("fortnite/bandage_applycomplete.ogg", 90)
           end)
           
          self.l_WeaponUseCooldown = ( CurTime() + heal_duration )
   
            return true
        end
    }
} )