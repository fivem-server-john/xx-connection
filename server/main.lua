
UTILS = exports['xx-utils']:GetObject()

DATABASE = DATABASE()
QUEUE = QUEUE()

PLAYER_COUNT = 0
PLAYER_LIST = {}
REJOIN_LIST = {}
MAX_PLAYER_COUNT = GetConvarInt('sv_maxclients', 32)

Citizen.CreateThread(function()
    DATABASE.Init()

    while true do
        Citizen.Wait(1000)

        CheckRejoinList()
        CheckQueue()  
    end
end)

function CheckQueue()
    local queueLength = QUEUE.GetQueueLength()
    if queueLength <= 0 then
        return
    end

    local server_filled = PLAYER_COUNT >= MAX_PLAYER_COUNT
    if server_filled then
        return
    end

    local nextPlayer = QUEUE.GetNextPlayer()
    QUEUE.MakeNextPlayerJoin()

    PLAYER_LIST[nextPlayer.license] = true
    PLAYER_COUNT = PLAYER_COUNT + 1
end

function HandlePlayerConnection(name, setKickReason, deferrals)
    local src = source

    local license = UTILS.GetPlayerIdentifierOfType(src, 'license')

    deferrals.defer()
    deferrals.update(Config.Translations["fetching_data"])

    Citizen.Wait(500)

    local steam = UTILS.GetPlayerIdentifierOfType(src, 'steam')
    if steam.state == false then
        deferrals.update(Config.Translations["steam_not_running"])
        CancelEvent()
        return
    end

    local isPlayerWhitelisted = DATABASE.IsPlayerWhitelisted(src, license)
    if (not isPlayerWhitelisted) then
        deferrals.update(Config.Translations["not_whitelisted"])
        CancelEvent()
        return
    end

    local queuePriority = GetQueuePriority(license)

    -- Check if the queue is full and the player has no priority. If the player has priority, he will still be added to the queue.
    local queueLength = QUEUE.GetQueueLength()
    if (queueLength >= Config.MaxQueueLength and queuePriority <= 0) then
        deferrals.update(Config.Translations["queue_is_full"])
        CancelEvent()
        return
    end

    local license = UTILS.GetPlayerIdentifierOfType(src, 'license')
    
    local queueEntry = {
        source = src,
        license = license,
        defferls = deferrals,
        priority = queuePriority
    }

    QUEUE.AddConnectionToQueue(queueEntry)

    QUEUE.UpdateQueuePositionMessage()

end
AddEventHandler('playerConnecting', HandlePlayerConnection)

function GetQueuePriority(license)
    local queuePriority = DATABASE.GetQueuePriority(license)

    if REJOIN_LIST[license] ~= nil then
        if Config.RejoinPriority > queuePriority then
            queuePriority = Config.RejoinPriority
        end
    end

    return queuePriority
end

function HandlePlayerDropped()
    local license = UTILS.GetPlayerIdentifierOfType(source, 'license')

    QUEUE.RemoveFromQueue(license)

    if PLAYER_LIST[license] ~= nil then
        PLAYER_LIST[license] = nil
        PLAYER_COUNT = PLAYER_COUNT - 1

        AddPlayerToRejoinList(license)
    end

    QUEUE.UpdateQueuePositionMessage()
end
AddEventHandler('playerDropped', HandlePlayerDropped)

function AddPlayerToRejoinList(license)
    local timeout = Config.RejoinTimeout
    local rejoinEntry = {
        license = license,
        timeout = timeout
    }

    REJOIN_LIST[license] = rejoinEntry
    Debug('Added player to rejoin list: ' .. license)
end

function CheckRejoinList()
    for k, v in pairs(REJOIN_LIST) do
        if (v.timeout <= 0) then
            REJOIN_LIST[k] = nil
            Debug('Removed player from rejoin list: ' .. v.license)
        else
            v.timeout = v.timeout - 1
        end
    end
end

function Debug(message)
    if Config.Debug then
        print(message)
    end
end