table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_smg = {
        model = "models/fortnite/w_fbr_smg.mdl", 
        origin = "Fortnite",
        prettyname = "Submachine Gun",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 260,
        attackrange = 2000,
        damage = 14,
        rateoffire = 0.06,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/smg",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/mp6_firestop.ogg",
        clip = 30,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.90,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/mp6_draw.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/mp6_reload.ogg",90)
        end,


        islethal = true,
    }

})