table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_pickaxe = {
        model = "models/fortnite/w_fbr_pickaxe.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Default",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/pickaxe_swing_*3*.ogg",
        hitsnd = "Weapon_Crowbar.Melee_Hit",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/pickaxe_deploy.ogg", 90)
       end,


        islethal = true,
    }

})