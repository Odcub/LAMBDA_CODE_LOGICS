table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_drumshotgun = {
        model = "models/fortnite/w_fbr_drumshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Drum Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 350,
        attackrange = 400,
        damage = 8,
        rateoffire = 0.40,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW,
        killicon = "vgui/fortnite/drumshotty",
        bulletcount = 14,
        tracername = "Tracer",
        attacksnd = "fortnite/drumshotgun_fire_*2*.ogg",
        clip = 12,
        spread = 0.3,
        bonemerge = true, 

        reloadtime = 3.21,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/drumshotgun_deploy.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/drumshotgun_reload.ogg",90)
        end,


        islethal = true,
    }

})