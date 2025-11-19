table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_lmg = {
        model = "models/fortnite/w_fbr_m249.mdl", 
        origin = "Fortnite",
        prettyname = "Light Machine Gun",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 230,
        attackrange = 2000,
        damage = 27,
        rateoffire = 0.05,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/lmg",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/m249_firestop.ogg",
        clip = 100,
        spread = 0.2,
        bonemerge = true, 

        reloadtime = 4.55,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/m249_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/m249_reload.ogg",90)
        end,


        islethal = true,
    }

})