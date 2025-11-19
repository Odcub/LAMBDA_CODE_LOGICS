table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_sixshooter = {
        model = "models/fortnite/w_fbr_sixshooter.mdl", 
        origin = "Fortnite",
        prettyname = "Six-Shooter",
        holdtype = "slam",
        ismelee = false,

        keepdistance = 450,
        attackrange = 2000,
        damage = 46,
        rateoffire = 0.20,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        killicon = "vgui/fortnite/sixshooter",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/magnum_fire_*2*.ogg",
        clip = 6,
        spread = 0.00000000000001,
        bonemerge = true, 

        reloadtime = 2.00,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/magnum_spin.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/magnum_reload.ogg",90)
        end,


        islethal = true,
    }

})