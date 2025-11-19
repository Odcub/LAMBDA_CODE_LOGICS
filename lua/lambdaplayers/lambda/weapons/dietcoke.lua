local random = math.random
local ents_Create = ents.Create

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    dietcoke = {
        model = "models/lambdaplayers/tf2/weapons/w_energy_drink.mdl",
        origin = "Memes",
        prettyname = "Diet Coke",
        holdtype = "slam",
        bonemerge = true,
    
		islethal = true,
        deploydelay = 0.5,

        OnDeploy = function( self, wepent )
            LAMBDA_TF2:InitializeWeaponData( self, wepent )
            wepent:SetSkin( self.l_TF_TeamColor )
            wepent:EmitSound( "goofylambdas/dietcoke_draw.mp3", nil, nil, 0.5 )
        end,

        OnThink = function( self, wepent, isdead )
            if !isdead and ( self:IsPanicking() or self:InCombat() and self:IsInRange( self:GetEnemy(), 9999999999 ) ) then
                self:UseWeapon()
            end
        end,

        OnAttack = function( self, wepent )
            self.l_WeaponUseCooldown = ( CurTime() + 10 )
            self:EmitSound( "player/pl_scout_dodge_can_drink.wav", nil, self:GetVoicePitch(), nil, CHAN_VOICE )

            local useAnim, waitTime = self:LookupSequence( "scout_taunt_drink" )
            if useAnim > 0 then
                self:AddGestureSequence( useAnim, true )
            else
                waitTime = 1
            end

            self.l_TF_IsUsingItem = true
            self.l_TF_PreUseItemState = self:GetState()
            self:CancelMovement()
            self:SetState( "UseTFItem" )

            self:SimpleWeaponTimer( waitTime, function()
                self.l_TF_AtomicPunched = ( CurTime() + 1 )
                self:ApplyEffect("Energized", 3, 30, 0.3, 250)
                self:EmitSound("goofylambdas/dietcoke" .. math.random(1,6) .. ".mp3", 80)
                
                local usedCan = ents_Create( "prop_physics" )
                usedCan:SetPos( wepent:GetPos() )
                usedCan:SetAngles( wepent:GetAngles() )
                usedCan:SetModel( wepent:GetModel() )
                usedCan:SetSkin( wepent:GetSkin() )
                usedCan:Spawn()
                usedCan:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
                SafeRemoveEntityDelayed( usedCan, 10 )

                usedCan:EmitSound( "player/pl_scout_dodge_can_crush.wav", 65, nil, nil, CHAN_ITEM )
                usedCan.l_PlayedHitSound = false
                usedCan:AddCallback( "PhysicsCollide", function( can )
                    if !can.l_PlayedHitSound then
                        can.l_PlayedHitSound = true
                        can:EmitSound( "player/pl_scout_dodge_can_pitch.wav", 65, nil, nil, CHAN_ITEM )
                    end
                end )     

                self.l_TF_IsUsingItem = false
                LAMBDA_TF2:AddInventoryCooldown( self )
                self:SetState( self.l_TF_PreUseItemState )
                self:SwitchToLethalWeapon()
            end )

            return true 
        end
    }
} ) 