table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_revolver = {
        model = "models/fortnite/w_fbr_357.mdl", 
        origin = "Fortnite",
        prettyname = "Revolver",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 32,
        rateoffire = 1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        killicon = "vgui/fortnite/revolver",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/revolver_shoot.ogg",
        clip = 6,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.15,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/revolver_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/revolver_reload.ogg",90)
        end,


        islethal = true,
    }

})