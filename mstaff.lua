RegisterCommand("mstaff", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command.mstaff") then 
        local playerName = source == 0 and "CONSOLE" or GetPlayerName(source) 
        
        
        local groups = {
            ["staff"] = "^3[Staff]",
            ["remboursement"] = "^4[Remboursement]",
            ["anticheat"] = "^5[Anti Cheat]",
            ["resp_legal"] = "^2[Resp Legal]",
            ["resp_illegal"] = "^1[Resp Illegal]",
            ["gerant"] = "^6[Gerant]",
            ["staff_administration"] = "^9[Staff Administration]",
            ["fonda"] = "^8[Fonda]"
        }
        
        local playerGroup = "staff"
        if source ~= 0 then
            for group, _ in pairs(groups) do
                if IsPlayerAceAllowed(source, "group." .. group) then
                    playerGroup = group
                    break
                end
            end
        end
        
        local rank = groups[playerGroup] or "^3[Staff]" 
        local message = table.concat(args, " ")
        if message == "" then
            if source ~= 0 then
                TriggerClientEvent("chat:addMessage", source, { args = { "^1ERREUR", "Merci d'entrer un message." } })
            else
                print("ERREUR: Merci d'entrer un message.")
            end
            return
        end
        
        
        TriggerClientEvent("chat:addMessage", -1, { args = { rank, playerName .. ": " .. message } })
        
        
        local webhook = "VOTRE_WEBHOOK_DISCORD_ICI"
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "MStaff", content = "**[" .. string.gsub(rank, "%^%d", "") .. "]** " .. playerName .. ": " .. message}), { ['Content-Type'] = 'application/json' })
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "^1ERREUR", "Vous n'avez pas la permission d'utiliser cette commande." } })
    end
end, false)


RegisterNetEvent("mstaff:receiveMessage")
AddEventHandler("mstaff:receiveMessage", function(message)
    TriggerClientEvent("chat:addMessage", -1, { args = { "^3[Staff]", message } })
end)
