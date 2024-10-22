local ESX = exports['newESX']:getSharedObject() -- Importuj newESX sdílené objekty
local gifts = {} -- Lokální seznam dárků

-- Funkce pro sběr dárku
function collectGift(gift)
    TriggerServerEvent('ChristmasPresentHunt:collectGift') -- Odesíláme na server, že jsme sebrali dárek
    DeleteObject(gift)
end

-- Funkce pro teleportaci k nejbližšímu dárku
function teleportToNearestGift()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local nearestGift = nil
    local nearestDistance = 999999

    for _, gift in ipairs(gifts) do
        local distance = Vdist(coords, gift.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestGift = gift
        end
    end

    if nearestGift then
        SetEntityCoords(playerPed, nearestGift.coords)
        ESX.ShowNotification('Teleportováno k nejbližšímu dárku!')
    else
        ESX.ShowNotification('Žádné dárky poblíž.')
    end
end

-- Zpracování příchozích dárků
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        for _, gift in ipairs(gifts) do
            if DoesEntityExist(gift.object) then
                local playerPed = PlayerPedId()
                local distance = Vdist(GetEntityCoords(playerPed), gift.coords)

                if distance < 1.5 then
                    collectGift(gift.object)
                end
            end
        end
    end
end)

-- Příkaz pro teleportaci k nejbližšímu dárku
RegisterCommand('teleportToGift', function()
    teleportToNearestGift()
end)

-- Načtení leaderboardu
RegisterCommand('leaderboard', function()
    ESX.TriggerServerCallback('ChristmasPresentHunt:getLeaderboard', function(data)
        local message = 'Leaderboard sbírání dárků:\n'
        for i = 1, math.min(3, #data) do
            local playerId = data[i].player
            local count = data[i].count
            message = message .. 'Hráč ID: ' .. playerId .. ' - Dárky: ' .. count .. '\n'
        end
        ESX.ShowNotification(message)
    end)
end)
