table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_crossbow = {
        model = "models/fortnite/w_fbr_crossbow.mdl", 
        origin = "Fortnite",
        prettyname = "Crossbow",
        holdtype = "crossbow",
        ismelee = false,

        keepdistance = 450,
        attackrange = 2000,
        damage = 90,
        rateoffire = 1.65,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW,
        killicon = "vgui/fortnite/crossbow",
        bulletcount = 1,
        tracername = "Tracer",
        attacksnd = "fortnite/crossbow_fire_*2*.ogg",
        clip = 5,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 3.05,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/crossbow_draw.ogg", 90)
           end,


        OnReload = function( self, wepent )
        self:EmitSound("fortnite/crossbow_reload.ogg",90)
        end,


        islethal = true,
    }

})