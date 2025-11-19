table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_tactical_ar = {
        model = "models/fortnite/w_fbr_tacticalar.mdl", 
        origin = "Fortnite",
        prettyname = "Tactical Assault Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 400,
        attackrange = 2000,
        damage = 23,
        rateoffire = 0.15,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/tactical_ar",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/tacticalar_fire_*2*.ogg",
        clip = 30,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.65,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/tacticalar_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/tacticalar_reload.ogg",90)
        end,


        islethal = true,
    }

})