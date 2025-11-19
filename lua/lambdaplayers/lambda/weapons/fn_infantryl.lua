table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_infantryl = {
        model = "models/fortnite/w_fbr_heavyinfantryrifle.mdl", 
        origin = "Fortnite",
        prettyname = "Legendary Infantry Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 400,
        attackrange = 2000,
        damage = 42,
        rateoffire = 0.30,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/infantryl",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/heavyinfantryrifle_fire_*3*.ogg",
        clip = 8,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.0,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/heavyinfantryrifle_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/heavyinfantryrifle_reload.ogg",90)
        end,


        islethal = true,
    }

})