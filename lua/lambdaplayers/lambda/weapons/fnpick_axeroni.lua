table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_axeroni = {
        model = "models/fortnite/w_fbr_axeroni.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Axeroni",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/axeroni_swing_*2*.ogg",
        hitsnd = "fortnite/axeroni_impact_*2*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/axeroni_deploy_1.ogg", 90)
       end,


        islethal = true,
    }

})