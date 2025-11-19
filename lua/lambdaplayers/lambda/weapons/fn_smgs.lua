table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_smgs = {
        model = "models/fortnite/w_fbr_mp5.mdl", 
        origin = "Fortnite",
        prettyname = "Suppressed Submachine Gun",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 260,
        attackrange = 2000,
        damage = 14,
        rateoffire = 0.10,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/smgs",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/smg_specops_shoot_*2*.ogg",
        clip = 30,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.75,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/smg_deploy_generic.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/smg_reload.ogg",90)
        end,


        islethal = true,
    }

})