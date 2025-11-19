table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_scopedar = {
        model = "models/fortnite/w_fbr_scopedrifle.mdl", 
        origin = "Fortnite",
        prettyname = "Scoped Assault Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 735,
        attackrange = 2000,
        damage = 23,
        rateoffire = 0.30,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/scopedar",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/scopedrifle_shoot_*6*.ogg",
        clip = 20,
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