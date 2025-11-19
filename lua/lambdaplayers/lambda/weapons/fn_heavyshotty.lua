
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_heavyshotty = {
        model = "models/fortnite/w_fbr_heavyshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Heavy Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 200,
        attackrange = 230,
        damage = 7,
        rateoffire = 0.96,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
        killicon = "vgui/fortnite/heavyshotty",
        bulletcount = 10,
        tracername = "Tracer",
        attacksnd = "fortnite/heavyshotgun_shoot_*2*.ogg",
        clip = 7,
        spread = 0.2,
        bonemerge = true, 

        reloadtime = 2.50,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadsounds = { { 0.1, "fortnite/heavyshotgun_reload.ogg" }, { 0.45, "fortnite/heavyshotgun_shellinsert_1.ogg" }, { 0.95, "fortnite/heavyshotgun_shellinsert_1.ogg" }, { 1.60, "fortnite/heavyshotgun_shellinsert_1.ogg" }, { 2.28, "fortnite/heavyshotgun_deploy.ogg" } },

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/heavyshotgun_deploy.ogg", 90)
           end,



        islethal = true,
    }

})