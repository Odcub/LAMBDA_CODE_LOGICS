table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_marshmello = {
        model = "models/fortnite/w_fbr_marshmello.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Marshy Smasher",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/marshmello_swing_*2*.ogg",
        hitsnd = "fortnite/marshmello_impact_*8*.ogg",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/marshmello_deploy.ogg", 90)
       end,


        islethal = true,
    }

})