table.Merge( _LAMBDAPLAYERSWEAPONS, {

    ar_kitchengun = {
        model = "models/weapons/w_pistol.mdl", 
        origin = "Asylum Rejects",
        prettyname = "Kitchen Gun",
        holdtype = "pistol",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 48,
        rateoffire = 0.45,
        killicon = "vgui/goofylambdas/kitchengun",
        bonemerge = true, 
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
        attacksnd = "GoofyLambdas/KG/fire*3*.mp3",
        bulletcount = 1,
        tracername = "Tracer",
        clip = 3,
        spread = 0.0001,

       OnDeploy = function(self, wepent)
       self:EmitSound("goofylambdas/KG/draw.mp3", 90)
       end,

        OnHolster = function( self, wepent )
            self:StopSound("goofylambdas/KG/draw.mp3")
            end,

        OnAttack = function( self, wepent, target )
        self:StopSound("goofylambdas/KG/draw.mp3")
        end,

        OnReload = function( self, wepent )
        self:StopSound("goofylambdas/KG/draw.mp3")
        self:EmitSound("GoofyLambdas/KG/reload" .. math.random(1,5) .. ".mp3",90)
        end,

        reloadtime = 2.5,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,


        islethal = true,
    }

})