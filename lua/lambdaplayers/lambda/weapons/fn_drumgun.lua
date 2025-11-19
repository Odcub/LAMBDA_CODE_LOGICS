table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_drumgun = {
        model = "models/fortnite/w_fbr_drumgun.mdl", 
        origin = "Fortnite",
        prettyname = "Drum Gun",
        holdtype = "smg",
        ismelee = false,

        keepdistance = 260,
        attackrange = 2000,
        damage = 18,
        rateoffire = 0.10,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/drumgun",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/drumgun_fire_*3*.ogg",
        clip = 50,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.65,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/drumgun_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/drumgun_reload.ogg",90)
        end,


        islethal = true,
    }

})