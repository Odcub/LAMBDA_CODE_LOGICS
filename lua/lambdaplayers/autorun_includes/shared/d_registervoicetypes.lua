local table_insert = table.insert
local file_Exists = file.Exists

LambdaValidVoiceTypes = {}

-- This allows the creation of new voice types

-- voicetypename    | String |  The name of the voice type. Should be lowercare letters only
-- defaultpath  | String |  The default directory for this voice type
-- voicetypedescription     | String |  The description of when this voice type is typically used
function LambdaRegisterVoiceType( voicetypename, defaultpath, voicetypedescription )
    CreateLambdaConvar( "lambdaplayers_voice_" .. voicetypename .. "dir", defaultpath, true, false, false, "The directory to get " .. voicetypename .. " voice lines from. " .. voicetypedescription .. " Make sure you update Lambda Data after you change this!", nil, nil, { type = "Text", name = voicetypename .. " Directory", category = "Voice Options" } )
    table_insert( LambdaValidVoiceTypes, { voicetypename, "lambdaplayers_voice_" .. voicetypename .. "dir" } )
end

-- Helper function: Only registers the voice type if the directory actually exists.
-- This prevents "Ghost" voice types if you haven't installed the sound files yet.
local function LambdaRegisterVoiceTypeIfFound( voicetypename, defaultpath, voicetypedescription )
    -- We check "sound/" + defaultpath because file.Exists checks relative to the game folder, 
    -- and audio files live in sound/.
    if file_Exists( "sound/" .. defaultpath, "GAME" ) then
        LambdaRegisterVoiceType( voicetypename, defaultpath, voicetypedescription )
        print( "[Lambda Players] Successfully registered optional voice type: " .. voicetypename )
    else
        -- Optional: Debug print to let you know it was skipped
        -- print( "[Lambda Players] Skipped voice type '" .. voicetypename .. "' because folder 'sound/" .. defaultpath .. "' was not found." )
    end
end

-- Default Voice Types (Always registered to ensure core functionality)
LambdaRegisterVoiceType( "idle", "lambdaplayers/vo/idle", "These are voice lines that play randomly. Input randomengine to randomly use sounds loaded in game. randomengine can work on any voice type" )
LambdaRegisterVoiceType( "taunt", "lambdaplayers/vo/taunt", "These are voice lines that play when a Lambda Player is about to attack something." )
LambdaRegisterVoiceType( "death", "lambdaplayers/vo/death", "These are voice lines that play when a Lambda Player dies." )
LambdaRegisterVoiceType( "kill", "lambdaplayers/vo/kill", "These are voice lines that play when a Lambda Player kills their enemy." )
LambdaRegisterVoiceType( "laugh", "lambdaplayers/vo/laugh", "These are voice lines that play when a Lambda Player laughs at someone." )
LambdaRegisterVoiceType( "fall", "lambdaplayers/vo/fall", "These are voice lines that play when a Lambda Player starts falling from deadly distance." )
LambdaRegisterVoiceType( "assist", "lambdaplayers/vo/assist", "These are voice lines that play when someone else kills Lambda Player's current enemy." )
LambdaRegisterVoiceType( "witness", "lambdaplayers/vo/witness", "These are voice lines that play when a Lambda Player sees someone get killed." )
LambdaRegisterVoiceType( "panic", "lambdaplayers/vo/panic", "These are voice lines that play when a Lambda Player is low on health and starts retreating." )

-- New Lambda Voice Types (Conditionally registered)
-- These will only appear if you have created the folders in 'garrysmod/sound/lambdaplayers/vo/'

LambdaRegisterVoiceTypeIfFound( "investigate", "lambdaplayers/vo/investigate", "Voice lines that are used when a Lambda investigates after hearing or noticing something odd." )

LambdaRegisterVoiceTypeIfFound( "escorting", "lambdaplayers/vo/escorting", "Voice lines that are used when a Lambda is following or protecting someone." )

LambdaRegisterVoiceTypeIfFound( "connected", "lambdaplayers/vo/connected", "Voice lines that are used when a Lambda joins the server." )

LambdaRegisterVoiceTypeIfFound( "disconnect", "lambdaplayers/vo/disconnect", "Voice lines that are used when a Lambda leaves the server." )

LambdaRegisterVoiceTypeIfFound( "domination", "lambdaplayers/vo/domination", "Voice lines that are used when a Lambda is dominating someone by killing or assist-killing them four times without retaliation." )

LambdaRegisterVoiceTypeIfFound( "blame", "lambdaplayers/vo/blame", "Used when the Lambda accuses someone for causing a disaster or making a bad decision." )