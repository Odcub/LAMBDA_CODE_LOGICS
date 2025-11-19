table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_scars = {
        model = "models/fortnite/w_fbr_scar2.mdl", 
        origin = "Fortnite",
        prettyname = "Suppressed Assault Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 35,
        rateoffire = 0.20,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/scars",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/scars_shoot_*4*.ogg",
        clip = 30,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.75,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/scar_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/scar_reload.ogg",90)
        end,


        islethal = true,
    }

})