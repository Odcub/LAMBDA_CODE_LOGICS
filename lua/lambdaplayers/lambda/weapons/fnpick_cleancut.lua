table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_cleancut = {
        model = "models/fortnite/w_fbr_cleancut.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Clean Cut",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/cleancut_swing_*2*.ogg",
        hitsnd = "fortnite/cleancut_impact_*2*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/cleancut_deploy.ogg", 90)
       end,


        islethal = true,
    }

})