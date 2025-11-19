table.Merge( _LAMBDAPLAYERSWEAPONS, {

    GrunkleStunkleWinsTheFunkleBunkle = {
        model = "models/player/items/all_class/hwn_spellbook_diary.mdl",
        origin = "Memes",
        prettyname = "Grunkle Stunkle",
        holdtype = "melee",

        ismelee = true,
        keepdistance = 22,
        attackrange = 25,

        damage = 500,
        rateoffiremin = 0.35,
        rateoffiremax = 0.36,
        killicon = "vgui/goofylambdas/grunklestunkle",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
        attacksnd = "goofylambdas/grunkleswing.mp3",
        hitsnd = "Weapon_Crowbar.Melee_Hit",

       OnDeploy = function(self, wepent)
       self:EmitSound("goofylambdas/grunklestunkle.mp3", 90)
       end,

        OnHolster = function( self, wepent )
            self:StopSound("goofylambdas/grunklestunkle.mp3")
            end,

        islethal = true,
    }

})