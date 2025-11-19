table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_heavysniper = {
        model = "models/fortnite/w_fbr_heavysniper.mdl", 
        origin = "Fortnite",
        prettyname = "Heavy Sniper Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 850,
        attackrange = 500000000,
        damage = 300,
        rateoffire = 1.65,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/heavysniper",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/heavysniper_shoot_*2*.ogg",
        clip = 1,
        spread = 0.00000000000001,
        bonemerge = true, 

        reloadtime = 3.65,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/heavysniper_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/heavysniper_reload.ogg",90)
        end,


        islethal = true,
    }

})