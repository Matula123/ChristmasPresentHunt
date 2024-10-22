ESX = exports['newESX']:getSharedObject() -- Importuj newESX sdílené objekty

local gifts = {} -- Pro uložení dárků
local giftCount = 1000 -- Počet dárků
local giftModel = 'prop_christmas_present_01' -- Model dárku
local playerCollection = {} -- Ukládá počet dárků pro jednotlivé hráče

-- Funkce pro spawn dárků na náhodných pozicích
local function spawnGifts()
    for i = 1, giftCount do
        local x = math.random(-2000, 2000) -- Náhodné souřadnice X
        local y = math.random(-2000, 2000) -- Náhodné souřadnice Y
        local z = math.random(30, 50) -- Výška

        local gift = CreateObject(GetHashKey(giftModel), x, y, z, true, true, true)
        SetEntityAsMissionEntity(gift, true, true)
        table.insert(gifts, {object = gift, coords = vector3(x, y, z)})
    end
    print(giftCount .. " dárků bylo spawnuto na mapě.")
end

-- Event pro sběr dárku
RegisterNetEvent('ChristmasPresentHunt:collectGift')
AddEventHandler('ChristmasPresentHunt:collectGift', function()
    local _source = source
    if not playerCollection[_source] then
        playerCollection[_source] = 0
    end
    playerCollection[_source] = playerCollection[_source] + 1
    TriggerClientEvent('esx:showNotification', _source, 'Sebral jsi dárek!')

    -- Odstraň dárek
    table.remove(gifts, 1)
end)

-- Funkce pro zobrazení leaderboardu
ESX.RegisterServerCallback('ChristmasPresentHunt:getLeaderboard', function(source, cb)
    local sortedCollection = {}
    for player, count in pairs(playerCollection) do
        table.insert(sortedCollection, {player = player, count = count})
    end

    -- Seřadíme hráče podle počtu dárků
    table.sort(sortedCollection, function(a, b)
        return a.count > b.count
    end)

    cb(sortedCollection)
end)

-- Automatický spawn dárků při spuštění zdroje
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        spawnGifts()
    end
end)
