
function HandlePlayerConnection(name, setKickReason, deferrals)
    local src = source

    deferrals.defer()
    
    exports.oxmysql:execute('SELECT * FROM players', {}, function(result)
        print(json.encode(result))
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            
            deferrals.update("connecting " .. math.random(1, 100) .. "%")
        end
    end)

    Citizen.Wait(5000)
    deferrals.done()
end
AddEventHandler('playerConnecting', HandlePlayerConnection)
