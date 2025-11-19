table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_thermalar = {
        model = "models/fortnite/w_fbr_thermalar.mdl", 
        origin = "Fortnite",
        prettyname = "Thermal Scoped Assault Rifle",
        holdtype = "smg",
        ismelee = false,

        keepdistance = 735,
        attackrange = 2000,
        damage = 31,
        rateoffire = 0.60,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/thermalar",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/thermalscopedar_fire_*3*.ogg",
        clip = 15,
        spread = 0.01,
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