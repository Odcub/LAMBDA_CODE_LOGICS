table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_infantry = {
        model = "models/fortnite/w_fbr_infantryrifle.mdl", 
        origin = "Fortnite",
        prettyname = "Infantry Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 400,
        attackrange = 2000,
        damage = 35,
        rateoffire = 0.30,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/infantry",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/infantryrifle_fire_*3*.ogg",
        clip = 8,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.0,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/infantryrifle_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/infantryrifle_reload_1.ogg",90)
        end,


        islethal = true,
    }

})