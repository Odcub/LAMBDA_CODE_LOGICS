table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_autosniper = {
        model = "models/fortnite/w_fbr_automaticsniper.mdl", 
        origin = "Fortnite",
        prettyname = "Automatic Sniper Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 850,
        attackrange = 500000000,
        damage = 45,
        rateoffire = 0.25,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/autosniper",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/automaticsniper_fire_*2*.ogg",
        clip = 16,
        spread = 0.00000000000001,
        bonemerge = true, 

        reloadtime = 3.30,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/automaticsniper_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/automaticsniper_reload.ogg",90)
        end,


        islethal = true,
    }

})