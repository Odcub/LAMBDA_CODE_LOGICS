table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_deagle = {
        model = "models/fortnite/w_fbr_deagle.mdl", 
        origin = "Fortnite",
        prettyname = "Hand Cannon",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 69,
        rateoffire = 1.45,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        killicon = "vgui/fortnite/deagle",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/deagle_fire.ogg ",
        clip = 7,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.05,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/pistol_deploy_generic.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/pistol_reload_generic.ogg",90)
        end,


        islethal = true,
    }

})