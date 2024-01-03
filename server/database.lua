function DATABASE()
    local self = {}

    self.Init = function()
        exports.oxmysql:executeSync(
            [[
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT,
                    steam VARCHAR(255) NOT NULL,
                    license VARCHAR(255) NOT NULL,

                    whitelisted BOOLEAN NOT NULL DEFAULT FALSE,
                    queue_priority INT NOT NULL DEFAULT 0,
                    `group` VARCHAR(255) NOT NULL DEFAULT "user",
                    
                    PRIMARY KEY (`id`)
                );
            ]]
        )
    end

    self.RegisterUser = function(source)
        local steam = CORE.GetPlayerIdentifier(source, 'steam')
        local license = CORE.GetPlayerIdentifier(source, 'license')

        exports.oxmysql:insert('INSERT INTO users (steam, license) VALUES (?,?)', { steam, license })
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