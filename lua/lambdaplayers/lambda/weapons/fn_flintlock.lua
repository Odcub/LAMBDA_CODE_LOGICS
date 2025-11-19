table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_flintlock = {
        model = "models/fortnite/w_fbr_flintknock.mdl", 
        origin = "Fortnite",
        prettyname = "Flint-Knock",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 450,
        attackrange = 2000,
        damage = 35,
        rateoffire = 1.00,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        killicon = "vgui/fortnite/flintlock",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/flintknock_fire_*3*.ogg",
        clip = 1,
        spread = 0.00000000000001,
        bonemerge = true, 

        reloadtime = 2.05,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/magnum_spin.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/flintknock_reload.ogg",90)
        end,


        islethal = true,
    }

})