table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_infinity = {
        model = "models/fortnite/w_fbr_infblade.mdl",
        origin = "Fortnite",
        prettyname = "Infinity Blade",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 25,
        attackrange = 30,

        damage = 75,
        rateoffire = 1,
        killicon = "vgui/fortnite/infinity",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/sword_swing_*4*.ogg",
        hitsnd = "fortnite/sword_impact_*4*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/sword_deploy.ogg", 90)
       self:EmitSound("fortnite/sword_loop.wav", 90)
       self:ApplyEffect("HealthBoost", math.huge, 100)
       self:ApplyEffect("Healing", math.huge, 5, 1)
       self:ApplyEffect("Energized", math.huge, 5, 1, 200)
       self:ApplyEffect("Endurance", math.huge)
       end,


       OnHolster = function( self, wepent )
            self:StopSound("fortnite/sword_loop.wav")
            self:RemoveEffect("Healing")
            self:RemoveEffect("HealthBoost")
            self:RemoveEffect("Energized")
            self:RemoveEffect("Endurance")
            self:ApplyEffect("Broken", 0.2, 100)
            end,


        islethal = true,
    }

})