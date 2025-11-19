table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_huntingrifle = {
        model = "models/fortnite/w_fbr_huntingrifle.mdl", 
        origin = "Fortnite",
        prettyname = "Hunting Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 450,
        attackrange = 500000000,
        damage = 75,
        rateoffire = 1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/huntingrifle",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/hunter_shoot_*2*.ogg",
        clip = 1,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.50,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/hunter_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/hunter_reload.ogg",90)
        end,


        islethal = true,
    }

})