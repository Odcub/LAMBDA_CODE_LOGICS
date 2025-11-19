table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_dublshotgun = {
        model = "models/fortnite/w_fbr_dublshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Double-Barrel Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 350,
        attackrange = 400,
        damage = 5,
        rateoffire = 0.45,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW,
        killicon = "vgui/fortnite/dublshotty",
        bulletcount = 10,
        tracername = "Tracer",
        attacksnd = "fortnite/dublshotgun_fire_*2*.ogg",
        clip = 2,
        spread = 0.3,
        bonemerge = true, 

        reloadtime = 2.40,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/dublshotgun_deploy_2.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/dublshotgun_reload.ogg",90)
        end,


        islethal = true,
    }

})