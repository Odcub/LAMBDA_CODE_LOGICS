local IsValid = IsValid
local CurTime = CurTime

local ents_Create = ents.Create

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    fn_pgl = {
        model = "models/fortnite/w_fbr_pgl.mdl",
        origin = "Fortnite",
        prettyname = "Proximity Grenade Launcher",
        holdtype = "ar2",
        killicon = "npc_grenade_frag",
        bonemerge = true,
        keepdistance = 1400,
        attackrange = 2000,

       OnDeploy = function(self, wepent)
           self:EmitSound("fortnite/famas_deploy.ogg", 90)
           end,


        OnAttack = function( self, wepent, target )
            local grenade = ents_Create( "npc_grenade_frag" )
            if !IsValid( grenade ) then return end

            self.l_WeaponUseCooldown = CurTime() + LambdaRNG( 1.8, 2.25, false )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )

            grenade:SetPos( self:GetPos() + self:GetUp() * 60 + self:GetForward() * 20 + self:GetRight() * -10 )
            grenade:Fire( "SetTimer", 0.75, 0 )
            grenade:SetSaveValue( "m_hThrower", self )
            grenade:SetOwner( self )
            grenade:Spawn()
            grenade:SetHealth( 120 )

            local throwForce = 2000
            local throwDir = self:GetForward()
            local throwSnd = "fortnite/pgl_fire_1.ogg"
            if IsValid( target ) then
                throwDir = ( target:GetPos() - grenade:GetPos() ):GetNormalized()
                if self:IsInRange( target, 350 ) then
                    throwForce = 2000
                    throwSnd = "fortnite/pgl_fire_2.ogg"
                end
            end
            wepent:EmitSound( throwSnd )

            local phys = grenade:GetPhysicsObject()
            if IsValid( phys ) then
                phys:ApplyForceCenter( throwDir * throwForce )
                phys:AddAngleVelocity( Vector( 600, LambdaRNG( -1200, 1200) ) )
            end

            return true
        end,

        islethal = true,
    }

})