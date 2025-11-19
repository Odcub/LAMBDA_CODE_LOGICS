local distance = GetConVar( "lambdaplayers_force_radius" )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_forceconversation", function( ply ) 
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    local dist = distance:GetInt()
    for _, lambda in ipairs( GetLambdaPlayers() ) do
        if !lambda:IsInRange( ply, dist ) then continue end
        local npcs = lambda:FindInSphere( nil, math.huge, function( ent ) return ( lambda:CanTarget( ent ) ) end )
        if #npcs == 0 then continue end
        lambda:StartConversation( npcs[ LambdaRNG( #npcs ) ] )
    end
end, false, "Forces all Lambda Players in the given radius to start a conversation", { name = "Lambda Players Conversate Each Other", category = "Force Menu" } )
