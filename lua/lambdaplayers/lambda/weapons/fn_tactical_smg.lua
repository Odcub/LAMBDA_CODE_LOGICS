table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_tacticalsmg = {
        model = "models/fortnite/w_fbr_tacsmg.mdl", 
        origin = "Fortnite",
        prettyname = "Tactical Submachine Gun",
        holdtype = "revolver",
        ismelee = false,

        keepdistance = 250,
        attackrange = 2000,
        damage = 9,
        rateoffire = 0.08,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
        killicon = "vgui/fortnite/tactical_smg",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/smg_shoot_*3*.ogg",
        clip = 35,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 1.75,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/smg_deploy_generic.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/smg_reload.ogg",90)
        end,


        islethal = true,
    }

})