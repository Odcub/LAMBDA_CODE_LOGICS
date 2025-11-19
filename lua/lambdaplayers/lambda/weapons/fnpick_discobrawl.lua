table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_discobrawl = {
        model = "models/fortnite/w_fbr_discobrawl.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Disco Brawl",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/discobrawl_swing_*3*.ogg",
        hitsnd = "fortnite/discobrawl_impact_*5*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/discobrawl_deploy.ogg", 90)
       end,


        islethal = true,
    }

})