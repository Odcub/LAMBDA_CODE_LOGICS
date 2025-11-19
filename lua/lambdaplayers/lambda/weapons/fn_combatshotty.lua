
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_combatshotty = {
        model = "models/fortnite/w_fbr_combatshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Combat Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 350,
        attackrange = 400,
        damage = 4,
        rateoffire = 0.65,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
        killicon = "vgui/fortnite/combatshotty",
        bulletcount = 10,
        tracername = "Tracer",
        attacksnd = "fortnite/combatshotgun_fire.ogg",
        clip = 10,
        spread = 0.2,
        bonemerge = true, 

        reloadtime = 2.50,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadsounds = { { 0.1, "fortnite/combatshotgun_reload.ogg" }, { 0.45, "fortnite/combatshotgun_shellinsert.ogg" }, { 0.95, "fortnite/combatshotgun_shellinsert.ogg" }, { 1.60, "fortnite/combatshotgun_shellinsert.ogg" }, { 2.28, "fortnite/combatshotgun_deploy.ogg" } },

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/combatshotgun_deploy.ogg", 90)
           end,


        islethal = true,
    }

})