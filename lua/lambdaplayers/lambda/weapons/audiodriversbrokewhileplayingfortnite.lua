table.Merge( _LAMBDAPLAYERSWEAPONS, {

    audiodriversbrokewhileplayingfortnite = {
        model = "models/lambdaplayers/tf2/weapons/w_pomson.mdl", 
        origin = "Memes",
        prettyname = "Martian Rifle",
        holdtype = "ar2",
        ismelee = false,

        keepdistance = 300,
        attackrange = 2000,
        damage = 20,
        rateoffire = 0.40,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
        killicon = "vgui/goofylambdas/martianrifle",
        bulletcount = 1,
        tracername = "ToolTracer",
        attacksnd = "goofylambdas/martianshoot.mp3",
        clip = 25,
        spread = 0.1,
        bonemerge = true, 

        reloadtime = 3.5,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,

         OnDeploy = function(self, wepent)
           self:EmitSound("goofylambdas/martiandraw.mp3", 90)
           end,

       OnDealDamage = function(lambda, wepent, target, dmginfo, dealtDamage, lethal)
            if dealtDamage then
                target:ApplyEffect("Discharge", 3, 20, 0.2)
            end
        end,

        OnReload = function( self, wepent )
        self:EmitSound("goofylambdas/martianreload.mp3",90)
        end,


        islethal = true,
    }

})