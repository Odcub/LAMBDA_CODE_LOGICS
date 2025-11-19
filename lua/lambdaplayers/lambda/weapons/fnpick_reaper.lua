table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_needmorecowbell = {
        model = "models/fortnite/w_fbr_reaper.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Reaper",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/scythe_swing_*2*.ogg",
        hitsnd = "fortnite/scythe_impact_*2*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/scythe_deploy.ogg", 90)
       end,


        islethal = true,
    }

})