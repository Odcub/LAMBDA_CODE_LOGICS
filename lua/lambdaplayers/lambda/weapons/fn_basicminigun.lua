
local IsValid = IsValid
local CurTime = CurTime
local random = math.random
local Rand = math.Rand
local ents_Create = ents.Create
local CreateSound = CreateSound
local callbackTbl = { clipdrain = true, sound = true }
local secondaryTbl = { clipdrain = true, sound = true, damage = true, cooldown = true }
local bulletTbl = {
	Num = 6,
	TracerName = "tracer",
	Damage = 8,
	Force = 8,
	Spread = Vector( 0.233, 0.233, 0 )
}

local function KillSounds( wepent )
	if wepent.BeatSound then wepent.BeatSound:Stop(); wepent.BeatSound = nil end
	if wepent.LoopSound then wepent.LoopSound:Stop(); wepent.LoopSound = nil end
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    fn_minigun = {
        model = "models/fortnite/w_fbr_minigun.mdl",
        origin = "Fortnite",
        prettyname = "Minigun",
        killicon = "vgui/fortnite/minigun",
        holdtype = "crossbow",
        bonemerge = true,
        keepdistance = 400,
        attackrange = 1500,

        clip = 1,
        tracername = "tracer",
        damage = 14,
        spread = 0.133,
        rateoffire = 0.1,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW,
        deploydelay = 1,

        OnAttack = function( self, wepent, target )

			if wepent.LoopSound then
				wepent.LoopSound:ChangeVolume( 1, 0.1 )
			else
				wepent.LoopSound = CreateSound( wepent, "fortnite/minigun.wav" )
				if wepent.LoopSound then wepent.LoopSound:Play() end
			end
			if wepent.BeatSound then wepent.BeatSound:ChangeVolume( 0, 0.1 ) end

			wepent.LoopSoundPlayTime = ( CurTime() + 0.2 )
            return callbackTbl
        end,

        OnDeploy = function( self, wepent )
                        self:EmitSound("fortnite/minigun_deploy.ogg",90)
			wepent.BeatSound = CreateSound( wepent, "rapgod/literallynothing.wav" )
			if wepent.BeatSound then wepent.BeatSound:Play() end

			wepent.LoopSoundPlayTime = CurTime()
			wepent:CallOnRemove( "LambdaNyanGun_KillSoundsOnRemove_" .. wepent:EntIndex(), KillSounds )
        end,

        OnHolster = function( self, wepent )
        	KillSounds( wepent )

        	wepent.LoopSoundPlayTime = nil
        	wepent:RemoveCallOnRemove( "LambdaNyanGun_KillSoundsOnRemove_" .. wepent:EntIndex() )
        end,

        OnThink = function( self, wepent, isdead )
        	if isdead or wepent:GetNoDraw() then
				if wepent.LoopSound then wepent.LoopSound:ChangeVolume( 0, 0.1 ) end
				if wepent.BeatSound then wepent.BeatSound:ChangeVolume( 0, 0.1 ) end
        	elseif CurTime() > wepent.LoopSoundPlayTime then
				if wepent.LoopSound then wepent.LoopSound:ChangeVolume( 0, 0.1 ) end
				if wepent.BeatSound then wepent.BeatSound:ChangeVolume( 1, 0.1 ) end
			end
        end,

        islethal = true
    }
} )