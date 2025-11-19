table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_revolverl = {
        model = "models/fortnite/w_fbr_heavy357.mdl", 
        origin = "Fortnite",
        prettyname = "Legendary Revolver",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 43,
        rateoffire = 1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        killicon = "vgui/fortnite/revolverl",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/heavyrevolver_fire_*2*.ogg",
        clip = 6,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.15,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/heavyrevolver_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/heavyrevolver_reload.ogg",90)
        end,


        islethal = true,
    }

})