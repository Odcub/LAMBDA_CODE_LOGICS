table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_stormsniper = {
        model = "models/fortnite/w_fbr_stormscoutsniper.mdl", 
        origin = "Fortnite",
        prettyname = "Storm Scout Sniper Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 850,
        attackrange = 500000000,
        damage = 90,
        rateoffire = 1.05,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/stormsniper",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/stormscoutsniper_fire_*2*.ogg",
        clip = 6,
        spread = 0.00000000000001,
        bonemerge = true, 

        reloadtime = 2.90,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/stormscoutsniper_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/stormscoutsniper_reload.ogg",90)
        end,


        islethal = true,
    }

})