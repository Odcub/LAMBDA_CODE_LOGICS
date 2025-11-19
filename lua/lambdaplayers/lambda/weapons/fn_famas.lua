table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_famas = {
        model = "models/fortnite/w_fbr_famas.mdl", 
        origin = "Fortnite",
        prettyname = "Legendary Burst Assault Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 9,
        rateoffire = 0.75,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/famas",
        bulletcount = 3,
        tracername = "Tracer",
        attacksnd = "fortnite/famas_shoot_*3*.ogg",
        clip = 10,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.05,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/famas_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/famas_reload.ogg",90)
        end,


        islethal = true,
    }

})