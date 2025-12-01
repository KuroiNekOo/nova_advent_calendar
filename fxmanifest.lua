fx_version 'cerulean'
game 'gta5'

author 'Xam42'
description 'Calendrier de l\'avent pour Nova'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js'
}

lua54 'yes'
