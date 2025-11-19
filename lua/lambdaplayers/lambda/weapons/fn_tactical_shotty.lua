
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_tactical_shotty = {
        model = "models/fortnite/w_fbr_tacticalshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Tactical Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 350,
        attackrange = 400,
        damage = 7,
        rateoffire = 0.96,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
        killicon = "vgui/fortnite/tactical_shotty",
        bulletcount = 9,
        tracername = "Tracer",
        attacksnd = "fortnite/tacticalshotty_shoot_*3*.ogg",
        clip = 8,
        spread = 0.3,
        bonemerge = true, 

        reloadtime = 2.50,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadsounds = { { 0.1, "fortnite/tacticalshotty_reload.ogg" }, { 0.45, "fortnite/tacticalshotty_shellinsert_1.ogg" }, { 0.95, "fortnite/tacticalshotty_shellinsert_1.ogg" }, { 1.60, "fortnite/tacticalshotty_shellinsert_1.ogg" }, { 2.28, "fortnite/tacticalshotty_deploy.ogg" } },

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/tacticalshotty_deploy.ogg", 90)
           end,



        islethal = true,
    }

})