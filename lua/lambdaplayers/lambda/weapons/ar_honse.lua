table.Merge( _LAMBDAPLAYERSWEAPONS, {

    ar_honse = {
        model = "models/props_c17/statue_horse.mdl",
        origin = "Asylum Rejects",
        prettyname = "Horse",
        holdtype = "melee2",

        ismelee = true,
        keepdistance = 16,
        attackrange = 25,

        damage = 40,
        rateoffire = 3,
        killicon = "vgui/goofylambdas/honse",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "GoofyLambdas/Honse.mp3",
        hitsnd = "Weapon_Crowbar.Melee_Hit",


        islethal = true,
    }

})