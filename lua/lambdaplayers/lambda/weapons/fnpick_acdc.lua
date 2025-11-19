table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_ACDC = {
        model = "models/fortnite/w_fbr_acdc.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "AC/DC",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/acdc_swing_*2*.ogg",
        hitsnd = "fortnite/acdc_impact_*2*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/acdc_deploy.ogg", 90)
       end,


        islethal = true,
    }

})