
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_spas12 = {
        model = "models/fortnite/w_fbr_heavypumpshotgun.mdl", 
        origin = "Fortnite",
        prettyname = "Legendary Pump Shotgun",
        holdtype = "shotgun",
        ismelee = false,

        keepdistance = 350,
        attackrange = 400,
        damage = 15,
        rateoffire = 1.85,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
        killicon = "vgui/fortnite/spas12",
        bulletcount = 20,
        tracername = "Tracer",
        attacksnd = "fortnite/spas_fire_*2*.ogg",
        clip = 5,
        spread = 0.2,
        bonemerge = true, 

        reloadtime = 2.50,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadsounds = { { 0.1, "fortnite/pumpshotty_reload.ogg" }, { 0.45, "fortnite/pumpshotty_shellinsert_1.ogg" }, { 0.95, "fortnite/pumpshotty_shellinsert_1.ogg" }, { 1.60, "fortnite/pumpshotty_shellinsert_1.ogg" }, { 2.28, "fortnite/spas_deploy.ogg" } },

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/spas_deploy.ogg", 90)
           end,


        OnAttack = function( self, wepent, target )
        self:SimpleWeaponTimer(0.85, function()
        self:EmitSound("fortnite/spas_deploy.ogg", 90)
        end)
        end,



        islethal = true,
    }

})