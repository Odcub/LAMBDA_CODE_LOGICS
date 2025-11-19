local warningcolor = Color( 114, 24, 24 )
local kickbanreasoncolor = Color( 51, 255, 0)
local normalcolor = Color( 152, 175, 199)
local color_white = color_white
local player_GetAll = player.GetAll
local team_GetColor = team.GetColor
local string_NiceTime = string.NiceTime
local timer_Simple = timer.Simple
local hook_Run = hook.Run
local table_HasValue = table.HasValue
local IsValid = IsValid
local random = math.random
local table_RemoveByValue = table.RemoveByValue
local Color = Color
local pairs = pairs
local ipairs = ipairs
local string_find = string.find
local ents_Create = ents and ents.Create or nil
local table_insert = table.insert
local string_lower = string.lower
local file_Exists = file.Exists
local bannedwords_file = "lambdaplayers/admin-bannedwords.json"

local jailmdl = Model( "models/props_building_details/Storefront_Template001a_Bars.mdl" )
local jailpositions = {
	{ Vector( 0, 0, -5 ), Angle( 90, 0, 0 ) },
	{ Vector( 0, 0, 97 ), Angle( 90, 0, 0 ) },
	{ Vector( 21, 31, 46 ), Angle( 0, 90, 0 ) },
	{ Vector( 21, -31, 46 ), Angle( 0, 90, 0 ) },
	{ Vector( -21, 31, 46 ), Angle( 0, 90, 0 ) },
	{ Vector( -21, -31, 46), Angle( 0, 90, 0 ) },
	{ Vector( -52, 0, 46 ), Angle( 0, 0, 0 ) },
	{ Vector( 52, 0, 46 ), Angle( 0, 0, 0 ) },
}

local BannedLambdas = {}

-- baddy bad
local bannedwords = {
	"fuck",
	"shit",
	"bitch",
	"dick",
	"damn",
--	"damnit",
	"piss",
	"pussy",
	"cunt",
	"dumbass",
	" ass ",
	" ass.",
--	" ass,",
	" ass?",
	" ass!"
}

local bantimes = {
	60,
	120,
	300,
	600,
	900,
	1200,
	1800,
	2400,
	2700,
	3600,
	7200,
	10800,
	14400,
	21600,
	28800,
	43200,
	86400, --1 day
	172800, --2 days
	259200,
	604800,
	1209600,
	2592000,
	31557600 --1 year
}

if file_Exists( bannedwords_file, "DATA" ) then
	local addon = LAMBDAFS:ReadFile( bannedwords_file, "json" )
	if addon then
		for k, word in ipairs( addon ) do
			bannedwords[ #bannedwords + 1 ] = string_lower(word)
		end
	end
end

if SERVER and !file_Exists( bannedwords_file, "DATA" ) then
	LAMBDAFS:WriteFile( bannedwords_file, {}, "json" )
end


CreateLambdaConvar( "lambdaplayers_lambdaadmin_maxadmins", 2, true, false, false, "How many Lambda Admins can exist at once", 0, 100, { type = "Slider", decimals = 0, name = "Max Admin Count", category = "Admins" } )
CreateLambdaConvar( "lambdaplayers_lambdaadmin_adminchance", 50, true, false, false, "The chance a Lambda will spawn as an Admin", 0, 100, { type = "Slider", decimals = 0, name = "Admin Chance", category = "Admins" } )
CreateLambdaConvar( "lambdaplayers_lambdaadmin_ignoreplayers", 0, true, false, false, "If Admins should ignore real players that are breaking the rules", 0, 1, { type = "Bool", name = "Ignore Players", category = "Admins" } )
local donothurtplayers = CreateLambdaConvar( "lambdaplayers_lambdaadmin_ruledonothurtplayers", 1, true, false, false, "If Lambdas are not allowed to hurt real players", 0, 1, { type = "Bool", name = "Rule: Do not Hurt Players", category = "Admins" } )
local noswearing = CreateLambdaConvar( "lambdaplayers_lambdaadmin_rulenoswearing", 1, true, false, false, "If Lambdas are not allowed to say bad words on this minecraft christian server", 0, 1, { type = "Bool", name = "Rule: No Bad Words", category = "Admins" } )
local nordm = CreateLambdaConvar( "lambdaplayers_lambdaadmin_rulenordm", 0, true, false, false, "If Lambdas are not allowed to attack people", 0, 1, { type = "Bool", name = "Rule: No RDM", category = "Admins" } )
CreateLambdaColorConvar( "lambdaplayers_lambdaadmincolor", Color( 81, 255, 0 ), true, true, "The display color Admin Lambdas should have", { name = "Admin Display Color", category = "Admins" } )
LambdaRegisterVoiceType( "adminscold", "lambdaplayers/vo/adminscold", "These are voicelines that play when an admin questions a rule breaker" )
LambdaRegisterVoiceType( "sitrespond", "lambdaplayers/vo/sitrespond", "These are voicelines that play when a rule breaker responds to an admin" )

local function GetLambdaAdmins()
	local admins = {}
	for k, v in ipairs( GetLambdaPlayers() ) do
		if v.l_admin then admins[ #admins + 1 ] = v end
	end
	return admins
end


hook.Add( "PostEntityTakeDamage", "lambdaadmins_damagerules", function( ent, info, took )
	if !took then return end
	local attacker = info:GetAttacker()

	-- Do not hurt players rules
	if ent:IsPlayer() and attacker.IsLambdaPlayer and donothurtplayers:GetBool() then
		hook.Run( "LambdaAdminsRuleViolate", {
			offender = attacker,
			rule = "plyhurt",
			needsLOS = true
		} )
	elseif ( ent:IsPlayer() or ent.IsLambdaPlayer ) and ( attacker:IsPlayer() or attacker.IsLambdaPlayer ) and nordm:GetBool() then -- No RDM
		hook.Run( "LambdaAdminsRuleViolate", {
			offender = attacker,
			rule = "rdm",
			needsLOS = true
		} )
	end

end )

hook.Add( "PlayerSay", "lambdaadmins_nobadwords", function( ply, text )
	if !noswearing:GetBool() then return end
	local text_lower = string_lower(text)
	for k, v in ipairs( bannedwords ) do
		if string_find( text_lower, v ) then
			hook.Run( "LambdaAdminsRuleViolate", {
				offender = ply,
				rule = "badword",
				needsLOS = false
			} )
			break
		end
	end
end )

hook.Add( "LambdaPlayerSay", "lambdaadmins_nobadwords", function( self, text )
	if !noswearing:GetBool() then return end
	local text_lower = string_lower(text)
	for k, v in ipairs( bannedwords ) do
		if string_find( text_lower, v ) then
			hook.Run( "LambdaAdminsRuleViolate", {
				offender = self,
				rule = "badword",
				needsLOS = false
			} )
			break
		end
	end
end )

--[[hook.Add("LambdaPlayerSay", "lambdaadmins_offenderfix", function(self)
	if !self.l_admin then return end
	local offender = self.l_offendingplayer
	if self:GetIsDead() and IsValid(offender) then
		offender.l_activeadmin = nil
		self.l_offendingplayer = nil --Dunno if this will help
		print("offender.l_activeadmin of ", offender, " (", offender:Name(), ") set to nil") --Remove later
	end
end)]]

hook.Add( "EntityTakeDamage", "lambdaadmins_preventdamage", function( targ )
	if targ.l_isjailed then return true end
end )

hook.Add( "PlayerNoClip", "lambdaadmins_nonoclip", function( ply, desiredstate )
	if ply.l_isjailed then return false end
end )

hook.Add( "CanPlayerSuicide", "lambdaadmins_nokillbind", function( ply )
	if ply.l_isjailed then return false end
end )


local function Initialize( self )

	self.l_admin = false -- If we are a admin
	self.l_warningcount = 0 -- How many warnings we have
	self.l_offendingplayer = nil -- The Lambda/Player that broke a rule and are currently conducting a sit with
	self.l_activeadmin = nil -- The Admin Lambda that currently has us in a sit
	self.l_offendingrule = nil -- The rule the violator broke
	self.l_isjailed = false -- Returns if we are jailed or not
	self.l_adminallowspeak = false -- If we are allowed to speak during a admin sit
	self.l_jailedplayers = {} -- A table of tables of jailed players and the jail entities


	if SERVER and #GetLambdaAdmins() < GetConVar( "lambdaplayers_lambdaadmin_maxadmins" ):GetInt() and random( 1, 100 ) < GetConVar( "lambdaplayers_lambdaadmin_adminchance" ):GetInt() then
		self.l_admin = true
		self:SetNW2Bool( "lambda_isadmin", true )
	end

	-- Returns how many warnings we have
	function self:CheckWarnings()
		return self.l_warningcount
	end

	-- The way we handle typing commands is interesting to say the least. Threads <3

	-- Warns the Lambda/Player for the following reason
	function self:DispatchWarning( ent, reason )
		reason = reason or "No reason"
		local running = true

		if !IsValid( ent ) then
			running = false
			ent.l_activeadmin = nil
			return
		end
		self:TypeMessage( "!warn " .. ent:Name() .. " " .. reason )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do
--[[			if self:GetIsDead() then
				ent.l_activeadmin = nil
			end]]
			coroutine.yield()
		end

		if !IsValid( ent ) then return end

		ent.l_warningcount = ent.l_warningcount and ent.l_warningcount + 1 or 1

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent:Name()
			local werewas = ply == ent and " were" or " was"
			local entcolor = ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() )
			LambdaPlayers_ChatAdd( ply, entcolor, entname, color_white, werewas .. " warned by ",  self:GetDisplayColor( ply ), self:Name(), color_white, ": ", warningcolor, reason )
		end

		hook_Run( "LambdaAdminsOnWarn", self, ent, reason, ent.l_warningcount )
		running = false

		while running do coroutine.yield() end
	end

	-- Kick another lambda player from the game
	function self:KickLambda( lambda, reason )
		reason = reason or "No reason"
		local name = lambda:Name()
		local running = true

		if !IsValid( lambda ) then running = false return end
		self:TypeMessage( "!kick " .. name .. " " .. reason )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do
--[[			if self:GetIsDead() then
				offender.l_activeadmin = nil
			end]]
			coroutine.yield()
		end

		if !IsValid( lambda ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " kicked ", lambda:GetDisplayColor( ply ), name, normalcolor, " (", kickbanreasoncolor, reason, normalcolor, ")" )
		end

		hook_Run( "LambdaAdminsOnKick", self, lambda, reason )
		lambda:Remove()
		running = false

		while running do coroutine.yield() end
	end

	-- Bans another lambda player from the game for the specified duration
	function self:BanLambda( lambda, reason, seconds )
		reason = reason or "No reason"
		seconds = seconds or 3600
		local name = lambda:Name()
		local running = true

		if !IsValid( lambda ) then running = false return end
		self:TypeMessage( "!ban " .. name .. " " .. seconds .. " " .. reason )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do
--[[			if self:GetIsDead() then
				offender.l_activeadmin = nil
			end]]
			coroutine.yield()
		end

		if !IsValid( lambda ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			local lambdacolor = lambda:GetDisplayColor( ply )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " banned ", lambdacolor, name, normalcolor, " for ", kickbanreasoncolor, string_NiceTime( tonumber( seconds ) ), normalcolor, " (", kickbanreasoncolor, reason, normalcolor, ")" )
			timer_Simple( seconds, function()
				if table_HasValue( LambdaPlayerNames, name ) then return end
				LambdaPlayers_ChatAdd( ply, lambdacolor, name, normalcolor, " was unbanned" )
			end )
		end

		hook_Run( "LambdaAdminsOnBan", self, lambda, reason, seconds )

		table_insert( BannedLambdas, name )
		table_RemoveByValue( LambdaPlayerNames, name )

		if seconds < 65536 then
			timer_Simple( seconds, function()
				if table_HasValue( LambdaPlayerNames, name ) then return end
				table_insert( LambdaPlayerNames, name )
				table_RemoveByValue( BannedLambdas, name )
			end )
		end

		lambda:Remove()
		running = false

		while running do coroutine.yield() end
	end

	-- Teleports to a player
	function self:LGoto( ent )
		local running = true

		 if !IsValid( ent ) then running = false return end
		 self:TypeMessage( "!goto " .. ent:Name() )

		 self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			 if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		 end )

		 while self:IsTyping() do coroutine.yield() end

		 if !IsValid( ent ) then return end

		 for _, ply in ipairs( player_GetAll() ) do
			 local entname = ply == ent and "You" or ent:Name()
			 local entcolor = ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() )
			 LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " teleported to ", entcolor, entname )
		 end
		 hook_Run( "LambdaAdminsOnGoto", self, ent )

		 self.l_adminreturnpos = self:GetPos() + Vector( 0, 0, 5 )
		 local norm = self:GetNormalTo( ent ) * 50
		 self.l_noclipheight = 0
		 self.l_noclippos = ( ent:GetPos() - norm ) + Vector( 0, 0, 5 )
		 self:SetPos( ( ent:GetPos() - norm ) + Vector( 0, 0, 5 ) )
		 running = false

		while running do coroutine.yield() end
	end

	-- Teleports to a position
	function self:LTeleport( pos )
		local running = true

		self:TypeMessage( "!gotositarea ^" )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do coroutine.yield() end

		for _, ply in ipairs( player_GetAll() ) do
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " teleported somewhere" )
		end
		hook_Run( "LambdaAdminsOnTeleport", self, pos )

		self.l_adminreturnpos = self:GetPos() + Vector( 0, 0, 5 )
		self.l_noclipheight = 0
		self.l_noclippos = pos + Vector( 0, 0, 5 )
		self:SetPos( pos + Vector( 0, 0, 5 ) )
		running = false

		while running do coroutine.yield() end
	end

	-- Brings a player to ourselves
	function self:LBring( ent )
		local running = true

		if !IsValid( ent ) then running = false return end

		self:TypeMessage( "!bring " .. ent:Name() )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do coroutine.yield() end

		if !IsValid( ent ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent:Name()
			local entcolor = ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " brought ", entcolor, entname, normalcolor, " to themselves" )
		end

		hook_Run( "LambdaAdminsOnGoto", self, ent )

		ent.l_adminreturnpos = ent:GetPos() + Vector( 0, 0, 5 )
		ent.l_noclipheight = 0
		ent.l_noclippos = ( self:GetPos() + self:GetForward() * 80 ) + Vector( 0, 0, 5 )
		ent:SetPos( ( self:GetPos() + self:GetForward() * 80 ) + Vector( 0, 0, 5 ) )
		running = false

		while running do coroutine.yield() end
	end

	-- Kills a player
	function self:LKill( ent )
		local running = true

		if !IsValid( ent ) then running = false return end
		self:TypeMessage( "!slay " .. ent:Name() )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do
--[[			if self:GetIsDead() then
				offender.l_activeadmin = nil
			end]]
			coroutine.yield()
		end

		if !IsValid( ent ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent:Name()
			local entcolor = ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " slayed ", entcolor, entname )
		end

		hook_Run( "LambdaAdminsOnKill", self, ent )

		ent:Kill()
		running = false

		while running do coroutine.yield() end
	end

	-- Returns a player or ourselves back their original position
	function self:LReturn( ent )
		local running = true
		ent = ent != nil and ent or self
		if !ent.l_adminreturnpos then return end

		if !IsValid( ent ) then running = false return end
		if ent == self then
			self:TypeMessage( "!return ^" )
		else
			self:TypeMessage( "!return " .. ent:Name() )
		end

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do coroutine.yield() end

		if !IsValid( ent ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent != self and ent:Name() or "themselves"
			local entcolor =  ent != self and ( ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() ) ) or self:GetDisplayColor( ply )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " returned ", entcolor, entname, normalcolor, " back to their original position" )
		end

		hook_Run( "LambdaAdminsOnReturn", self, ent )
		ent.l_noclipheight = 0
		ent.l_noclippos = ent.l_adminreturnpos
		ent:SetPos( ent.l_adminreturnpos )
		running = false

		while running do coroutine.yield() end
	end


	function self:CreateJail( ply )
		self.l_jailedplayers[ ply ] = {}

		if ply:IsPlayer() then
			ply:SetMoveType( MOVETYPE_WALK )
		end

		ply.l_isjailed = true

		for i = 1, #jailpositions do
			local ent = ents_Create( "prop_physics" )
			ent:SetModel( jailmdl )
			ent:SetPos( ply:GetPos() + jailpositions[i][1] )
			ent:SetAngles( jailpositions[i][2] )
			ent:Spawn()
			ent:GetPhysicsObject():EnableMotion( false )
			ent:SetMoveType( MOVETYPE_NONE )
			ent.IsLambdaJail = true
			table_insert( self.l_jailedplayers[ ply ], ent )
		end

	end

	function self:RemoveJail( ply )
		if self.l_jailedplayers[ ply ] then
			for k, v in ipairs( self.l_jailedplayers[ ply ] ) do
				if IsValid( v ) then v:Remove() end
			end
			ply.l_isjailed = false
		end
	end

	-- Teleports a player and jails them
	function self:LJailTP( ent )
		local running = true

		if !IsValid( ent ) then running = false return end
		self:TypeMessage( "!jailtp " .. ent:Name() )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do coroutine.yield() end

		if !IsValid( ent ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent:Name()
			local entcolor =  ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " teleported and jailed ", entcolor, entname )
		end

		hook_Run( "LambdaAdminsOnJail", self, ent )

		ent.l_adminreturnpos = ent:GetPos() + Vector( 0, 0, 5 )
		ent.l_noclipheight = 0
		ent.l_noclippos = ( self:GetPos() + self:GetForward() * 130 ) + Vector( 0, 0, 5 )
		ent:SetPos( ( self:GetPos() + self:GetForward() * 130 ) + Vector( 0, 0, 5 ) )
		self:CreateJail( ent )
		running = false

		while running do coroutine.yield() end
	end

	function self:LUnJail( ent )
		local running = true

		if !IsValid( ent ) then running = false return end
		self:TypeMessage( "!unjail " .. ent:Name() )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do coroutine.yield() end

		if !IsValid( ent ) then self:ClearJails() return end

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent:Name()
			local entcolor = ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, " unjailed ", entcolor, entname )
		end

		hook_Run( "LambdaAdminsOnUnJail", self, ent )

		self:RemoveJail( ent )
		running = false

		while running do coroutine.yield() end
	end

	-- Grants god mode to ourselves or to someone
	function self:LGod( ent, bool )
		if bool == self:HasGodMode() then return end
		ent = ent != nil and ent or self
		local msg = bool and " granted god mode upon " or " revoked god mode from "
		local running = true
		local offender = self.l_offendingplayer

		if !IsValid( ent ) then running = false return end
		self:TypeMessage( "!god" )

		self:Hook( "LambdaPlayerSay", "admincommandhide", function( lambda, text )
			if lambda == self then self:RemoveHook( "LambdaPlayerSay", "admincommandhide" ) return "" end
		end )

		while self:IsTyping() do
--[[			if self:GetIsDead() then
				offender.l_activeadmin = nil
			end]]
			coroutine.yield()
		end

		if !IsValid( ent ) then return end

		for _, ply in ipairs( player_GetAll() ) do
			local entname = ply == ent and "You" or ent != self and ent:Name() or "themselves"
			local entcolor =  ent != self and ( ent.IsLambdaPlayer and ent:GetDisplayColor( ply ) or team_GetColor( ent:Team() ) ) or self:GetDisplayColor( ply )
			LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:Name(), normalcolor, msg, entcolor, entname )
		end

		hook_Run( "LambdaAdminsOnGodmode", self, ent, bool )

		if bool then ent:GodEnable() else ent:GodDisable() end
		running = false

		while running do coroutine.yield() end
	end

	function self:ClearJails()
		for ply, jailtbl in pairs( self.l_jailedplayers ) do

			if IsValid( ply ) then ply.l_activeadmin = nil ply.l_isjailed = false end

			for k, ent in ipairs( jailtbl ) do
				if IsValid( ent ) then ent:Remove() end
			end

		end
	end

	self:Hook( "LambdaAdminsRuleViolate", "adminhandleproblem", function( violatedata )
		if !self.l_admin or self:GetState() == "AdminSitState" then return end
		local offender = violatedata.offender
		local brokenrule = violatedata.rule
		local needsLOS = violatedata.needsLOS

		if IsValid( offender ) and offender:IsPlayer() and GetConVar( "lambdaplayers_lambdaadmin_ignoreplayers" ):GetBool() then return end
		if !LambdaIsValid( offender ) or offender.l_admin or LambdaIsValid( offender.l_activeadmin ) or needsLOS and ( !self:CanSee( offender ) or self:GetRangeSquaredTo( offender ) > ( 2500 * 2500 ) ) then return end
		self.l_sawoffendingplayer = needsLOS and true or false
		self.l_offendingrule = brokenrule
		self.l_offendingplayer = offender
		offender.l_activeadmin = self
		self.l_adminallowspeak = true
		self:CancelMovement()
		self:SetState( "AdminSitState" )
	end, true )

	function self:InSit()

		self:LookTo( self.l_activeadmin )
		self:PreventDefaultComs( true )

		local usetextchat = GetConVar( "lambdaplayers_text_enabled" ):GetBool() and random( 1, 100 ) <= self:GetTextChance()
		while IsValid( self.l_activeadmin ) do

			while ( self:IsSpeaking() or self:IsTyping() ) do coroutine.yield() end

			if self.l_adminallowspeak then

				if !usetextchat then
					self:PlaySoundFile( self:GetVoiceLine( "sitrespond" ) )
				elseif usetextchat then
					self.l_keyentity = self.l_activeadmin
					self:TypeMessage( self:GetTextLine( "sitrespond" ) )
				end

				while ( self:IsSpeaking() or self:IsTyping() ) do coroutine.yield() end

				self.l_adminallowspeak = false

				coroutine.wait( 0.5 )
				if !IsValid( self.l_activeadmin ) then break end

				self.l_activeadmin.l_adminallowspeak = true
			end

			coroutine.yield()
		end

		self:LookTo( nil )
		self:PreventDefaultComs( false )
		self.l_adminallowspeak = false
		self:SetState( "Idle" )
	end



	function self:AdminSitState()
		local offender = self.l_offendingplayer
		local rule = self.l_offendingrule
		self.l_offenderdied = false
		offender.l_warningcount = offender.l_warningcount or 0
		local area
		local maxspeaktimes = random( 1, 10 )
		local speaktimes = 0
		local sit = random(0,1)

		self:PreventDefaultComs( true )

		if sit == 1 then
			self:LGod( self, true )

			for k, v in RandomPairs( navmesh.GetAllNavAreas() ) do
				if IsValid( v ) and v:GetSizeX() >= 60 and v:GetSizeY() >= 60 and !v:IsUnderwater() then area = v break end
			end

			self:LTeleport( area:GetRandomPoint() )

			self:LookTo( area:GetCenter() )

			if offender.l_warningcount and offender.l_warningcount > 1 then
				self:LJailTP( offender )
			else
				self:LBring( offender )
			end

			if offender.IsLambdaPlayer then offender:SetState( "InSit" ) offender:CancelMovement() end

			self:LookTo( offender )

			local nextspeakplayer = CurTime() + 10
			self:Hook( "PlayerSay", "adminplayerresponded", function( ply )
				if ply == offender and ply.l_adminallowspeak then
					self.l_adminallowspeak = true
					ply.l_adminallowspeak = false
					nextspeakplayer = CurTime() + 10
				end
			end )

			self:Hook( "LambdaOnRealPlayerEndVoice", "adminplayerresponded", function( ply )
				if ply == offender and ply.l_adminallowspeak then
					self.l_adminallowspeak = true
					ply.l_adminallowspeak = false
					nextspeakplayer = CurTime() + 10
				end
			end )


			local usetextchat = GetConVar( "lambdaplayers_text_enabled" ):GetBool() and random( 1, 100 ) <= self:GetTextChance()

			while LambdaIsValid( offender ) and offender:Alive() do
				if self.l_offenderdied then self.l_offenderdied = false break end
				if speaktimes >= maxspeaktimes then break end

				if offender:IsPlayer() and CurTime() > nextspeakplayer then
					self.l_adminallowspeak = true
					offender.l_adminallowspeak = false
					nextspeakplayer = CurTime() + 10
				end

				while ( self:IsSpeaking() or self:IsTyping() ) do coroutine.yield() end

				if self.l_adminallowspeak then


					if !usetextchat then
						self:PlaySoundFile( self:GetVoiceLine( "adminscold" ) )
					elseif usetextchat then
						self.l_keyentity = offender
						self:TypeMessage( self:GetTextLine( "adminscold" ) )
					end

					while self:IsSpeaking() do coroutine.yield() end

					speaktimes = speaktimes + 1
					self.l_adminallowspeak = false

					coroutine.wait( 0.5 )

					offender.l_adminallowspeak = true
				end

				coroutine.yield()
			end

			self:LookTo( nil )

			if IsValid( offender ) and offender.l_isjailed then self:LUnJail( offender ) end

		end
		if IsValid( offender ) and offender.l_warningcount < 2 then
			if sit == 0 and random(0,1) == 0 then
				self:LKill(offender)
			else
				self:DispatchWarning( offender, self:GetTextLine( "punishreason-" .. rule ) )
			end
		elseif IsValid( offender ) then
			if offender:IsPlayer() then
				choice = random(0,1)
				if choice == 1 then
					offender.l_warningcount = 0
				end
			else
				choice = random(0,3)
				--Choices only for Lambdas
				if choice == 2 then
					self:KickLambda( offender, self:GetTextLine( "punishreason-" .. rule ) )
				end
				if choice == 3 then
					self:BanLambda( offender, self:GetTextLine( "punishreason-" .. rule ), table.Random(bantimes) )
				end
			end
			--Choices for both real and Lambda players
			if choice == 0 then
				self:DispatchWarning( offender, self:GetTextLine( "punishreason-" .. rule ) )
			end
			if choice == 1 then
				self:LKill(offender)
			end
		end


		if IsValid( offender ) then
			offender.l_activeadmin = nil
			if choice != 1 and sit != 0 then
				self:LReturn( offender )
			end
		end

		if sit == 1 then
			self:LReturn( self )
			self:LGod( self, false )

			self:RemoveHook( "PlayerSay", "adminplayerresponded" )
			self:RemoveHook( "LambdaOnRealPlayerEndVoice", "adminplayerresponded" )
		end
		self:PreventDefaultComs( false )
		self.l_offendingplayer = nil
		self:SetState( "Idle" )
	end


end

local function GetDisplayColor( self, ply )
	if self.l_admin then return Color( ply:GetInfoNum( "lambdaplayers_lambdaadmincolor_r", 81 ), ply:GetInfoNum( "lambdaplayers_lambdaadmincolor_g", 255 ), ply:GetInfoNum( "lambdaplayers_lambdaadmincolor_b", 0 ) ) end
end

local function CanTarget( self, ent )
	if self.l_admin and ent:IsPlayer() and donothurtplayers:GetBool() then return true end
	if self.l_admin and nordm:GetBool() then return true end
end

local function OnRemove( self )
	for ply, jailtbl in pairs( self.l_jailedplayers ) do

		if IsValid( ply ) then ply.l_activeadmin = nil ply.l_isjailed = false end

		for k, ent in ipairs( jailtbl ) do
			if IsValid( ent ) then ent:Remove() end
		end

	end
end

local function OnOtherKilled( self, other, info )
	if IsValid( self.l_offendingplayer ) then
		self.l_offenderdied = true
	end
end

hook.Add( "LambdaOnOtherKilled", "lambdaadmins_otherkilled", OnOtherKilled )
hook.Add( "LambdaCanTarget", "lambdaadmins_cantarget", CanTarget )
hook.Add( "LambdaOnRemove", "lambdaadmins_onremove", OnRemove )
hook.Add( "LambdaGetDisplayColor", "lambdaadmins_displaycolor", GetDisplayColor )
hook.Add( "LambdaOnInitialize", "lambdaadmins_init", Initialize )



if CLIENT then
	local DrawText = draw.DrawText

	LambdaCreateProfileSetting( "DCheckBox", "l_admin", "Admin Module", function( pnl, parent )
		local lbl = LAMBDAPANELS:CreateLabel( "[Is Admin]\nIf enabled, this profile will always be an admin regardless of the admin limit", parent, TOP )
		lbl:SetWrap( true )
		lbl:SetSize( 100, 70 )
		lbl:SetParent( parent )
		lbl:Dock( TOP )
		pnl:SetZPos( 100 )
	end )


	hook.Add( "HUDPaint", "lambdaplayers_admin_hud", function()
		local tr = LocalPlayer():GetEyeTrace()
		local ent = tr.Entity

		if IsValid( ent ) and ent.IsLambdaPlayer and ent:GetNW2Bool( "lambda_isadmin", false ) then
			local color = ent:GetDisplayColor()

			DrawText( "-ADMIN-", "lambdaplayers_displayname", ScrW() / 2, ScrH() / 2.1 , color, TEXT_ALIGN_CENTER )
		end

	end )

end