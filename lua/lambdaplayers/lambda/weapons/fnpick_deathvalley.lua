table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_deathvalley = {
        model = "models/fortnite/w_fbr_deathvalley.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Death Valley",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/deathvalley_swing_*2*.ogg",
        hitsnd = "fortnite/deathvalley_impact_*2*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/deathvalley_deploy.ogg", 90)
       end,


        islethal = true,
    }

})