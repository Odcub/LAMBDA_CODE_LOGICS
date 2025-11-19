ENT.Type 			= "anim"  
ENT.PrintName			= "M202 rocket"  
ENT.Author			= "M9K + Fluffiest Floofers"
ENT.Contact			= ""  
ENT.Purpose			= ""  
ENT.Instructions		= ""  
 
ENT.Spawnable = false
ENT.AdminOnly = true 
ENT.DoNotDuplicate = true 
ENT.DisableDuplicator = true

if CLIENT then
    killicon.Add( "m202_rocket", "lambdaplayers/killicons/icon_jb3_quadrpg", Color( 255, 80, 0, 255 ) )
end

if SERVER then

    AddCSLuaFile( "shared.lua" )

    function ENT:Initialize()   
        self.CanTool = false
        self.flightvector = self.Entity:GetForward() * ((115*10)/66)
        self.timeleft = CurTime() + 15
        self.Owner = self:GetOwner()
        self.Entity:SetModel( "models/Weapons/W_missile.mdl" )
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
        self.Entity:SetMoveType( MOVETYPE_NONE )
        self.Entity:SetSolid( SOLID_VPHYSICS )

        glow = ents.Create("env_sprite")
        glow:SetKeyValue("model","orangecore2.vmt")
        glow:SetKeyValue("rendercolor","255 150 100")
        glow:SetKeyValue("scale","0.2")
        glow:SetPos(self.Entity:GetPos())
        glow:SetParent(self.Entity)
        glow:Spawn()
        glow:Activate()

        self.Entity:SetNWBool("smoke", true)
    end

    function ENT:Think()
        
        if not IsValid(self) then return end
        if not IsValid(self.Entity) then return end

            if self.timeleft < CurTime() then
            self.Entity:Remove()				
            end

        Table	={}
        Table[1]	=self.Owner
        Table[2]	=self.Entity

        local trace = {}
            trace.start = self.Entity:GetPos()
            trace.endpos = self.Entity:GetPos() + self.flightvector
            trace.filter = Table
        local tr = util.TraceLine( trace )
        

            if tr.HitSky then
                self.Entity:Remove()
                return true
            end
        
            if tr.Hit then
                if not IsValid(self.Owner) then
                    self.Entity:Remove()
                    return
                end
                
                util.BlastDamage(self.Entity, self:OwnerGet(), tr.HitPos, 200, 75)
                self.Entity:SetNWBool("smoke", false)
                self:Explosion()
                self.Entity:Remove()	
            end
        
        self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
        self.flightvector = self.flightvector - (self.flightvector/500)  + Vector(math.Rand(-0.5,0.5), math.Rand(-0.5,0.5),math.Rand(-0.5,0.5))
        self.Entity:SetAngles(self.flightvector:Angle() + Angle(0,0,0))
        self.Entity:NextThink( CurTime() )
        return true
        
    end
 
    function ENT:Explosion()
        if not IsValid(self.Owner) then
            self.Entity:Remove()
            return
        end

        local effectdata = EffectData()
            effectdata:SetOrigin(self.Entity:GetPos())
        util.Effect("Explosion", effectdata)
    end

    function ENT:OwnerGet()
        if IsValid(self.Owner) then
            return self.Owner
        else
            return self.Entity
        end
    end

end

if CLIENT then
    function ENT:Draw()             
        self.Entity:DrawModel()
    end

    function ENT:Initialize()
        pos = self:GetPos()
        self.emitter = ParticleEmitter( pos )
    end

    function ENT:Think()
        if (self.Entity:GetNWBool("smoke")) then
        pos = self:GetPos()
            for i=1, (1) do
                local particle = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + (self:GetForward() * -50 * i))
                if (particle) then
                    particle:SetVelocity((self:GetForward() * -1800)+(VectorRand()* 100) )
                    particle:SetDieTime( math.Rand( 1, 2 ) )
                    particle:SetStartAlpha( math.Rand( 7, 10 ) )
                    particle:SetEndAlpha( 0 )
                    particle:SetStartSize( math.Rand( 30, 40 ) )
                    particle:SetEndSize( math.Rand( 90, 120 ) )
                    particle:SetRoll( math.Rand(0, 360) )
                    particle:SetRollDelta( math.Rand(-1, 1) )
                    particle:SetColor( 200 , 200 , 200 ) 
                    particle:SetAirResistance( 500 ) 
                    particle:SetGravity( Vector( 100, 0, 0 ) ) 	
                end
            end
        end
    end
end