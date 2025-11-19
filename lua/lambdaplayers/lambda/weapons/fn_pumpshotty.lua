
table.Merge( _LAMBDAPLAYERSWEAPONS, {
 
    fn_pumpshotty = {
        model = "models/fortnite/w_fbr_pumpshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Pump Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 350,
        attackrange = 400,
        damage = 12,
        rateoffire = 1.85,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
        killicon = "vgui/fortnite/pumpshotty",
        bulletcount = 20,
        tracername = "Tracer",
        attacksnd = "fortnite/pumpshotty_fire_*2*.ogg",
        clip = 5,
        spread = 0.2,
        bonemerge = true, 

        reloadtime = 2.50,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadsounds = { { 0.1, "fortnite/pumpshotty_reload.ogg" }, { 0.45, "fortnite/pumpshotty_shellinsert_1.ogg" }, { 0.95, "fortnite/pumpshotty_shellinsert_1.ogg" }, { 1.60, "fortnite/pumpshotty_shellinsert_1.ogg" }, { 2.28, "fortnite/pumpshotty_deploy.ogg" } },

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/pumpshotty_deploy.ogg", 90)
           end,


        OnAttack = function( self, wepent, target )
        self:SimpleWeaponTimer(0.85, function()
        self:EmitSound("fortnite/pumpshotty_deploy.ogg", 90)
        end)
        end,



        islethal = true,
    }

})