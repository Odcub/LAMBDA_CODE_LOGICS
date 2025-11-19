table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_ak47 = {
        model = "models/fortnite/w_fbr_ak47.mdl", 
        origin = "Fortnite",
        prettyname = "Heavy Assault Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 400,
        attackrange = 2000,
        damage = 43,
        rateoffire = 0.40,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/ak47",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/ak47_fire_*2*.ogg",
        clip = 25,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.25,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/ak47_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/ak47_reload.ogg",90)
        end,


        islethal = true,
    }

})