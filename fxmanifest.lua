author "helmimarif"
description "Ownable properties for Ayseframework"
version "1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
    "ui/**"
}
ui_page "ui/index.html"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**"
}
client_scripts {
    "client/main.lua",
    "client/elevators.lua"
}

dependencies {
    "oxmysql",
    "ox_lib",
    "Ayse_Core",
    "Ayse_Doorlocks"
}