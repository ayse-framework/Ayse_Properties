AyseCore = exports["Ayse_Core"]:GetCoreObject()

RegisterNetEvent("Ayse_Properties:getProperties", function()
    local src = source
    local info = {}
    local result = MySQL.query.await("SELECT * FROM ayse_properties")
    if result then
        local player = AyseCore.Functions.GetPlayer(src)
        for i = 1, #result do
            info[i] = {
                id = result[i].id,
                owner = false,
                hasAccess = false
            }
            if result[i].owner == player.id then
                info[i].owner = true
                info[i].hasAccess = true
            else
                local accessList = json.decode(result[i].access)
                for _, access in pairs(accessList) do
                    if access.character == player.id then
                        info[i].hasAccess = true
                    end
                end
            end
            local sale = result[i].sale
            if sale ~= nil or sale ~= 0 or sale ~= "0" then
                info[i].sale = tonumber(sale)
            end
        end
    end
    TriggerClientEvent("Ayse_Properties:returnProperties", src, info)
end)


function getPlayers(src)
    local players = {}
    for _, id in pairs(GetPlayers()) do
        local player_id = tonumber(id)
        if player_id ~= src then
            local player = AyseCore.Functions.GetPlayer(player_id)
            local key = #players + 1
            players[key] = {}
            players[key].name = player.firstName .. " " .. player.lastName
            players[key].id = player_id
            players[key].character = player.id
        end
    end
    return players
end

RegisterNetEvent("Ayse_Properties:purchaseProperty", function(propertyId)
    local src = source
    local propertyBuying
    for _, property in pairs(properties) do
        if property.propertyid == propertyId then
            propertyBuying = property
            break
        end
    end
    if not propertyBuying then return end
    local player = AyseCore.Functions.GetPlayer(src)
    if not player then return end
    if player.bank < propertyBuying.price then return end
    AyseCore.Functions.DeductMoney(propertyBuying.price, src, "bank")
    local result = MySQL.query.await("SELECT `id` FROM ayse_properties WHERE `id` = ? LIMIT 1", {propertyBuying.propertyid})
    if result and result[1] and result[1].id == propertyBuying.propertyid then return end
    MySQL.query("INSERT INTO ayse_properties (id, owner, address) VALUES (?, ?, ?)", {propertyBuying.propertyid, player.id, propertyBuying.address})
    propertyBuying.owner = true
    propertyBuying.hasAccess = true
    TriggerClientEvent("Ayse_Properties:updateDoors", src, propertyBuying)
    TriggerClientEvent("Ayse_Properties:updateUI", -1, propertyBuying.propertyid, src)
end)

RegisterNetEvent("Ayse_Properties:getOwnedProperties", function()
    local src = source
    local player = AyseCore.Functions.GetPlayer(src)
    local result = MySQL.query.await("SELECT * FROM ayse_properties WHERE `owner` = ?", {player.id})
    if not result then return end
    local players = getPlayers(src)
    TriggerClientEvent("Ayse_Properties:returnOwnedProperties", src, result, players)
end)

RegisterNetEvent("Ayse_Properties:grantAccess", function(grantTo, grantProperty)
    local src = source
    if not grantTo then return end if not grantProperty then return end

    local grantTo = tonumber(grantTo)
    local result = MySQL.query.await("SELECT * FROM ayse_properties WHERE `id` = ? LIMIT 1", {grantProperty})
    if not result then return end
    local access = json.decode(result[1].access)

    local player = AyseCore.Functions.GetPlayer(src)
    if result[1].owner ~= player.id then return end

    local user = AyseCore.Functions.GetPlayer(grantTo)
    if not user then return end
    for _, ply in pairs(access) do
        if ply.character == user.id then return end
    end

    access[#access + 1] = {
        character = user.id,
        name = user.firstName .. " " .. user.lastName
    }
    MySQL.query.await("UPDATE ayse_properties SET `access` = ? WHERE id = ?", {json.encode(access), grantProperty})
    TriggerClientEvent("Ayse_Properties:refresh", grantTo)

    local result = MySQL.query.await("SELECT * FROM ayse_properties WHERE `owner` = ?", {player.id})
    if not result then return end
    local players = getPlayers(src)
    TriggerClientEvent("Ayse_Properties:refreshAccess", src, result, players)
end)

RegisterNetEvent("Ayse_Properties:removeAccess", function(removeCharacter, removeProperty)
    local src = source
    if not removeCharacter then return end if not removeProperty then return end

    local removeCharacter = tonumber(removeCharacter)
    local result = MySQL.query.await("SELECT * FROM ayse_properties WHERE `id` = ? LIMIT 1", {removeProperty})
    if not result then return end
    local access = json.decode(result[1].access)

    local player = AyseCore.Functions.GetPlayer(src)
    if result[1].owner ~= player.id then return end

    local removeSrc
    local players = AyseCore.Functions.GetPlayers()
    for _, ply in pairs(players) do
        if ply.id == removeCharacter then
            removeSrc = ply.source
        end
    end

    for k, ply in pairs(access) do
        if ply.character == removeCharacter then
            access[k] = nil
        end
    end

    MySQL.query.await("UPDATE ayse_properties SET `access` = ? WHERE id = ?", {json.encode(access), removeProperty})
    if removeSrc then
        TriggerClientEvent("Ayse_Properties:refresh", removeSrc)
    end

    local result = MySQL.query.await("SELECT * FROM ayse_properties WHERE `owner` = ?", {player.id})
    if not result then return end
    local players = getPlayers(src)
    TriggerClientEvent("Ayse_Properties:refreshAccess", src, result, players)
end)