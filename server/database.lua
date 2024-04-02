function DATABASE()
    local self = {}

    self.Init = function()
        exports.oxmysql:executeSync(
            [[
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT,
                    steam VARCHAR(255) NOT NULL,
                    license VARCHAR(255) NOT NULL,
                    steamname VARCHAR(255) NOT NULL,

                    whitelisted BOOLEAN NOT NULL DEFAULT FALSE,
                    queue_priority INT NOT NULL DEFAULT 0,
                
                    PRIMARY KEY (`id`)
                );
            ]]
        )
    end

    self.RegisterUser = function(source)
        local steam = UTILS.GetPlayerIdentifierOfType(source, 'steam')
        local steamName = GetPlayerName(source)
        local license = UTILS.GetPlayerIdentifierOfType(source, 'license')

        exports.oxmysql:insert('INSERT INTO users (steam, license, steamname) VALUES (?,?,?)', { steam, license, steamName })
    end

    self.IsPlayerWhitelisted = function(source, license)
        local isWhitelisted = false

        local result = exports.oxmysql:executeSync('SELECT * FROM users WHERE license = ?',{ license })

        if result[1] ~= nil then
            isWhitelisted = result[1].whitelisted
        else
            self.RegisterUser(source)
        end

        return isWhitelisted
    end

    self.GetQueuePriority = function(license)
        local queuePriority = 0

        local result = exports.oxmysql:executeSync('SELECT * FROM users WHERE license = ?',{ license })

        if result[1] ~= nil then
            queuePriority = result[1].queue_priority
        end

        return queuePriority
    end

    return self
end