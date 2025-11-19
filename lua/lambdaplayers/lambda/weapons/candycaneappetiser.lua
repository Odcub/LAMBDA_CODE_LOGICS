table.Merge( _LAMBDAPLAYERSWEAPONS, {

    merrychrystler = {
        model = "models/lambdaplayers/tf2/weapons/w_candy_cane.mdl",
        origin = "Memes",
        prettyname = "The Appetizer",
        holdtype = "knife",

        ismelee = true,
        keepdistance = 22,
        attackrange = 25,

        damage = 3,
        rateoffiremin = 0.35,
        rateoffiremax = 0.36,
        killicon = "vgui/goofylambdas/appetiser",
        bonemerge = true,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE,
        attacksnd = "goofylambdas/appetiser/stab.mp3",
        hitsnd = "Weapon_Crowbar.Melee_Hit",

       OnDeploy = function(self, wepent)
       self:EmitSound("goofylambdas/appetiser/draw.mp3", 90)
       self:ApplyEffect("Healing", 2, 5, 0.3)
       end,

      OnDealDamage = function(lambda, wepent, target, dmginfo, dealtDamage, lethal)
            if dealtDamage then
                 target:ApplyEffect("Bleeding", 6, 5, 0.3, lambda)
            end
        end,




        islethal = true,
    }

})