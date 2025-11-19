table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_chocollama = {
        model = "models/fortnite/w_fbr_chocollama.mdl",
        origin = "Fortnite: Pickaxes",
        prettyname = "Chocollama",
        holdtype = "melee2",

        ismelee = true,
        bonemerge = true,
        keepdistance = 16,
        attackrange = 20,

        damage = 20,
        rateoffire = 0.50,
        killicon = "vgui/fortnite/pickaxe",
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
        attacksnd = "fortnite/chocollama_swing_*2*.ogg",
        hitsnd = "Weapon_Crowbar.Melee_Hit",


       OnDeploy = function(self, wepent)
       self:EmitSound("fortnite/chocollama_deploy.ogg", 90)
       end,


        islethal = true,
    }

})