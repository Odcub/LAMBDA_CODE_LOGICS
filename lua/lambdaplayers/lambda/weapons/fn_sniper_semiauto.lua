table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_semiautosniper = {
        model = "models/fortnite/w_fbr_autosniper.mdl", 
        origin = "Fortnite",
        prettyname = "Semi-Automatic Sniper Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 850,
        attackrange = 500000000,
        damage = 34,
        rateoffire = 0.80,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/semiautosniper",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/autosniper_shoot_*4*.ogg",
        clip = 10,
        spread = 0.00000000000001,
        bonemerge = true, 

        reloadtime = 2.30,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/ar_deploy_generic.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/sniper_reload.ogg",90)
        end,


        islethal = true,
    }

})