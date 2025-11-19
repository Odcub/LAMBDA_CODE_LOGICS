table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_burstsmg = {
        model = "models/fortnite/w_fbr_krissvector.mdl", 
        origin = "Fortnite",
        prettyname = "Burst SMG",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 250,
        attackrange = 2000,
        damage = 6,
        rateoffire = 0.50,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/fortnite/burstsmg",
        bulletcount = 4,
        tracername = "Tracer",
        attacksnd = "fortnite/burst4.ogg",
        clip = 6,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.85,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/krissvector_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/krissvector_reload.ogg",90)
        end,


        islethal = true,
    }

})