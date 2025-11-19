table.Merge( _LAMBDAPLAYERSWEAPONS, {
    CaseOhBreaksHisPhoneWithAPressureWasherdotmp4 = {
        model = "models/weapons/w_annabelle.mdl",
        origin = "Memes",
        prettyname = "Pressure Washer",
        holdtype = "crossbow",
        bonemerge = true,
        keepdistance = 250,
        attackrange = 450,
        islethal = true,

        damage = 10,
        rateoffire = 0.01,
        tracername = "Ar2Tracer",
        killicon = "vgui/goofylambdas/pressure",
        bonemerge = true,
        spread = 0.001,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW,
        attacksnd = "weapons/rpg/rocketfire1.wav",

       OnDeploy = function(self, wepent)
       self:EmitSound("goofylambdas/pressuredraw.mp3", 90)
       end,



    }
} )