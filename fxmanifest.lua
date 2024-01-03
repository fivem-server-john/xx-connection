fx_version 'cerulean'
game 'gta5'

description 'Connection'
version '0.9'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    'server/database.lua',
    'server/queue.lua',
	'server/main.lua',
}



lua54 'yes'