table.Merge( _LAMBDAPLAYERSWEAPONS, {

    ar_andhispalmugmanandhispalmugmanandhispalmugmanandhispalmugman = {
        model = "models/hunter/plates/plate.mdl", 
        origin = "Asylum Rejects",
        prettyname = "Peashooter",
        holdtype = "pistol",
        ismelee = false,

        keepdistance = 600,
        attackrange = 750,
        damage = 4,
        rateoffire = 0.10,
        killicon = "vgui/goofylambdas/yousomemf",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
        attacksnd = "GoofyLambdas/ps/shot*11*.mp3",
        bulletcount = 1,
        nodraw = true,
        dropondeath = false,
        tracername = "Tracer",
        spread = 0.0001,


        islethal = true,
    }

})