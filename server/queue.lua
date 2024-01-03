function QUEUE()
    local self = {}

    self.QueueList = {}

    self.AddConnectionToQueue = function(entry)
        Debug('Adding player to queue: ' .. entry.license)
        Debug('Queue priority: ' .. entry.priority)
        table.insert(self.QueueList, entry)
        self.SortQueue()
    end

    self.SortQueue = function()
        table.sort(self.QueueList, function(a, b)
            return a.priority > b.priority
        end)
    end

    self.UpdateQueuePositionMessage = function()
        local queueLength = #self.QueueList
        for k, v in pairs(self.QueueList) do
            local position = k
            local message = Config.Translations["current_queue_position"]:format(position, queueLength, v.priority)
            v.defferls.update(message)
        end
    end

    self.GetNextPlayer = function()
        return self.QueueList[1]
    end

    self.MakeNextPlayerJoin = function()
        local nextPlayer = self.QueueList[1]

        nextPlayer.defferls.done()
        table.remove(self.QueueList, 1)

        return nextPlayer.steam
    end

    self.GetQueueLength = function()
        return #self.QueueList
    end
    
    self.RemoveFromQueue = function(steam)
        for k, v in pairs(self.QueueList) do
            if (v.steam == steam) then
                table.remove(self.QueueList, k)
                break
            end
        end
    end

    return self
end