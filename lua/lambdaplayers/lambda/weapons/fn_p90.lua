table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_p90 = {
        model = "models/fortnite/w_fbr_p90.mdl", 
        origin = "Fortnite",
        prettyname = "Compact SMG",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 260,
        attackrange = 2000,
        damage = 20,
        rateoffire = 0.06,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/p90",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/p90_firestop.ogg",
        clip = 50,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 2.35,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/mp6_draw.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/p90_reload.ogg",90)
        end,


        islethal = true,
    }

})