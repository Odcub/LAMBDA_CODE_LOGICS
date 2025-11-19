table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_pistol = {
        model = "models/fortnite/w_fbr_pistol.mdl", 
        origin = "Fortnite",
        prettyname = "Pistol",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 9,
        rateoffire = 0.20,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
        killicon = "vgui/fortnite/pistol",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/pistol_shoot_*3*.ogg",
        clip = 16,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.05,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/pistol_deploy_generic.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/pistol_reload_generic.ogg",90)
        end,


        islethal = true,
    }

})