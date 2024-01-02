function Database()
    local self = {}

    self.Init = function()
        exports.oxmysql:executeSync(
            [[
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT,
                    steam VARCHAR(255) NOT NULL,
                    license VARCHAR(255) NOT NULL,
                    

                    PRIMARY KEY (`id`),
                    KEY `citizenid` (`citizenid`)
                    
                );
            ]]
        )
    end

    return self
end