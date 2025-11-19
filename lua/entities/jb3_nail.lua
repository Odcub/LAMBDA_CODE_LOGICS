AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false

if CLIENT then
    killicon.Add( "jb3_nail", "lambdaplayers/killicons/icon_jb3_nailgun", Color( 255, 80, 0, 255 ) )
end

function ENT:Draw()
    self.Entity:DrawModel()
end

function ENT:Initialize()
    if SERVER then
        self.CanTool = false
        self.Entity:SetModel( "models/lambdaplayers/nailgun/w_nail_proj.mdl" )
        self.Entity:SetMoveType( MOVETYPE_NONE )
        self.Entity:SetSolid( SOLID_VPHYSICS )
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
        self.Entity:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
        self.Entity:DrawShadow( false )
        self.Entity:SetColor(Color(100,100,100,255))
    end
end

function ENT:PhysicsCollide( data )
    local dmg = DamageInfo()
    local owner = self:GetOwner()
    
    if !IsValid( self ) then
        owner = self
    end
    
    if !IsValid(owner) then self.Entity:Remove() return end
    dmg:SetAttacker( owner )
    dmg:SetInflictor( self )
    dmg:SetDamage( 7 )
    dmg:SetDamageType( DMG_BULLET )
    data.HitEntity:TakeDamageInfo( dmg )
    
    if SERVER then
        self.Entity:Remove()
    end
end