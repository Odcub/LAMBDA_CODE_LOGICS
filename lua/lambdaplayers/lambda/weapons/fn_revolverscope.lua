table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_revolverscope = {
        model = "models/fortnite/w_fbr_scopedrevolver.mdl", 
        origin = "Fortnite",
        prettyname = "Scoped Revolver",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 500,
        attackrange = 2000,
        damage = 41,
        rateoffire = 0.95,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        killicon = "vgui/fortnite/revolverscope",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/scopedrevolver_shoot_*3*.ogg",
        clip = 6,
        spread = 0.01,
        bonemerge = true, 

        reloadtime = 2.40,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/scopedrevolver_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/scopedrevolver_reload.ogg",90)
        end,


        islethal = true,
    }

})