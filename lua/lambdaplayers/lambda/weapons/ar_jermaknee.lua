local random = math.random
local CurTime = CurTime
local IsValid = IsValid
local isvector = isvector
local Rand = math.Rand
local util_Effect = util.Effect
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    ar_jermaknee = {
        model = "models/hunter/plates/plate.mdl",
        origin = "Asylum Rejects",
        prettyname = "Jerma",
        holdtype = "magic",

        ismelee = true,
        keepdistance = 45,
        attackrange = 60,

        damage = 10,
        rateoffire = 0.80,
        killicon = "vgui/goofylambdas/jerma",
        bonemerge = true,
        nodraw = true,
        dropondeath = false,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
        attacksnd = "goofylambdas/jerma/attack*3*.mp3",
        hitsnd = "Weapon_Crowbar.Melee_Hit",


      OnDealDamage = function(lambda, wepent, target, dmginfo, dealtDamage, lethal)
            if dealtDamage then
                 target:ApplyEffect("Wither", 10, 5, 0.5, lambda)
                 target:Ignite()
            end
        end,

        OnAttack = function( lambda, wepent, target )
                local muzzleEffect = ents.Create("light_dynamic")
                muzzleEffect:SetColor(Color(255,75,40,255))
                muzzleEffect:SetKeyValue("brightness", "10")
                muzzleEffect:SetKeyValue("distance", "200")
                muzzleEffect:SetPos(wepent:GetPos())
                muzzleEffect:SetParent(lambda)
                muzzleEffect:Spawn()
                muzzleEffect:Activate()
                muzzleEffect:Fire("TurnOn", "", 0)
                muzzleEffect:Fire("TurnOff", "", 0.15)
                muzzleEffect:Fire("Kill", "", 0.17)
        end,


        islethal = true,
    }

})