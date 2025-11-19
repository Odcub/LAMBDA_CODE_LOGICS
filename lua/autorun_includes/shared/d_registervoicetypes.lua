local table_insert = table.insert

LambdaValidVoiceTypes = {}

-- This allows the creation of new voice types

-- voicetypename    | String |  The name of the voice type. Should be lowercare letters only
-- defaultpath  | String |  The default directory for this voice type
-- voicetypedescription     | String |  The description of when this voice type is typically used
function LambdaRegisterVoiceType( voicetypename, defaultpath, voicetypedescription )
    CreateLambdaConvar( "lambdaplayers_voice_" .. voicetypename .. "dir", defaultpath, true, false, false, "The directory to get " .. voicetypename .. " voice lines from. " .. voicetypedescription .. " Make sure you update Lambda Data after you change this!", nil, nil, { type = "Text", name = voicetypename .. " Directory", category = "Voice Options" } )
    table_insert( LambdaValidVoiceTypes, { voicetypename, "lambdaplayers_voice_" .. voicetypename .. "dir" } )
end

LambdaRegisterVoiceType( "idle", "lambdaplayers/vo/idle", "These are voice lines that play randomly. Input randomengine to randomly use sounds loaded in game. randomengine can work on any voice type" )
LambdaRegisterVoiceType( "taunt", "lambdaplayers/vo/taunt", "These are voice lines that play when a Lambda Player is about to attack something." )
LambdaRegisterVoiceType( "death", "lambdaplayers/vo/death", "These are voice lines that play when a Lambda Player dies." )
LambdaRegisterVoiceType( "kill", "lambdaplayers/vo/kill", "These are voice lines that play when a Lambda Player kills their enemy." )
LambdaRegisterVoiceType( "laugh", "lambdaplayers/vo/laugh", "These are voice lines that play when a Lambda Player laughs at someone." )
LambdaRegisterVoiceType( "fall", "lambdaplayers/vo/fall", "These are voice lines that play when a Lambda Player starts falling from deadly distance." )
LambdaRegisterVoiceType( "assist", "lambdaplayers/vo/assist", "These are voice lines that play when someone else kills Lambda Player's current enemy." )
LambdaRegisterVoiceType( "witness", "lambdaplayers/vo/witness", "These are voice lines that play when a Lambda Player sees someone get killed." )
LambdaRegisterVoiceType( "panic", "lambdaplayers/vo/panic", "These are voice lines that play when a Lambda Player is low on health and starts retreating." )

-- New voice types requested: investigatory, social, connection and duel related lines
LambdaRegisterVoiceType( "investigate", "lambdaplayers/vo/investigate", "Voice lines used when a Lambda investigates a suspicious sound or event." )
--LambdaRegisterVoiceType( "regroup", "lambdaplayers/vo/regroup", "Voice lines used when a Lambda calls or signals others to regroup." )
LambdaRegisterVoiceType( "escorting", "lambdaplayers/vo/escorting", "Voice lines used when a Lambda is escorting or protecting someone." )
LambdaRegisterVoiceType( "connected", "lambdaplayers/vo/connected", "Voice lines played when a Lambda joins the server." )
LambdaRegisterVoiceType( "disconnect", "lambdaplayers/vo/disconnect", "Voice lines played when a Lambda leaves the server." )
--LambdaRegisterVoiceType( "respawn", "lambdaplayers/vo/respawn", "Voice lines played when a Lambda respawns after death." )
LambdaRegisterVoiceType( "confused", "lambdaplayers/vo/confused", "Voice lines used when a Lambda is confused or disoriented." )
LambdaRegisterVoiceType( "domination", "lambdaplayers/vo/domination", "Voice lines used when a Lambda dominates an opponent repeatedly." )
--LambdaRegisterVoiceType( "duel_start", "lambdaplayers/vo/duel_start", "Voice lines used when requesting a duel with another Lambda." )
--LambdaRegisterVoiceType( "duel_accept", "lambdaplayers/vo/duel_accept", "Voice lines used when accepting a duel request." )
--LambdaRegisterVoiceType( "duel_reject", "lambdaplayers/vo/duel_reject", "Voice lines used when rejecting a duel request." )
LambdaRegisterVoiceType( "insult", "lambdaplayers/vo/insult", "Voice lines used for insulting or taunting others." )
LambdaRegisterVoiceType( "blame", "lambdaplayers/vo/blame", "Voice lines used when a Lambda blames someone for causing a problem." )

-- Register voice-type toggles and the master toggle.

local CreateConVar = CreateConVar
local GetConVar = GetConVar

-- Master toggle for all Lambda voice lines
CreateConVar( "lambdaplayers_voice_enabled", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Master toggle for Lambda voice lines" )

-- Voice types to register (common/desired types)
local voiceTypes = {
    "idle", "taunt", "panic", "kill", "death", "assist", "witness", "laugh", "fall", "response",
    "investigate", "escorting", "connected", "disconnect", "domination", "blame",
    -- Note: duel and some other types are blacklisted by default below
}

--[[
-- Types that should be disabled by default (blacklist)
local disabledByDefault = {
    insult = true,
    regroup = true,
    confused = true,
    respawn = true,
    duel_start = true,
    duel_accept = true,
    duel_reject = true
}
]]
-- Ensure a ConVar exists for each voice type (and register registry entry if present)
for _, vt in ipairs( voiceTypes ) do
    local conname = "lambdaplayers_voice_" .. vt .. "_enabled"
    CreateConVar( conname, "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable Lambda voice type: " .. vt )
    if LambdaVoiceTypes then LambdaVoiceTypes[ vt ] = true end
end

--[[
-- Create ConVars for blacklisted types as well, disabled by default
for vt, _ in pairs( disabledByDefault ) do
    local conname = "lambdaplayers_voice_" .. vt .. "_enabled"
    -- only create if not already created above
    if not GetConVar( conname ) then
        CreateConVar( conname, "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable Lambda voice type: " .. vt .. " (default: disabled)" )
    else
        -- force default disabled state when file is first loaded by setting to 0 if it was not previously defined
        -- NOTE: CreateConVar above would have created enabled; this line keeps control explicit
        -- (we do not Remove or Modify an existing ConVar value here to avoid unexpected runtime changes)
    end
    if LambdaVoiceTypes then LambdaVoiceTypes[ vt ] = true end
end
]]
-- Backwards-compatible helper to check master + per-type convar
function LambdaIsVoiceTypeEnabled( voicetype )
    if not voicetype or voicetype == "" then return false end
    local master = GetConVar( "lambdaplayers_voice_enabled" )
    if master and not master:GetBool() then return false end
    local cv = GetConVar( "lambdaplayers_voice_" .. voicetype .. "_enabled" )
    if cv then return cv:GetBool() end
    return true
end