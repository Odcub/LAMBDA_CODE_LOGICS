table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_ar = {
        model = "models/fortnite/w_fbr_assaultrifle.mdl", 
        origin = "Fortnite",
        prettyname = "Assault Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 28,
        rateoffire = 0.20,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/ar",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/ar_shoot_*2*.ogg",
        clip = 30,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.75,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/ar_deploy_generic.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/ar_reload.ogg",90)
        end,


        islethal = true,
    }

})