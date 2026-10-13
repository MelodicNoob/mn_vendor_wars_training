---@diagnostic disable: undefined-global
-- Resource Metadata
fx_version 'cerulean'
game 'gta5'

author 'MelodicNoob <40186365+MelodicNoob@users.noreply.github.com>'
description 'Vendor Wars Training - A tight, fast-reset mode where gangs quickly drill core Vendor Wars mechanics to sharpen timing, coordination, and influence control'
version '1.0.0'

resource_type 'gametype' { name = 'Vendor Wars Training' }

dependencies {
  'mapmanager',
  'chat',
  'spawnmanager',
  'rconlog',
  'ox_lib',
}

-- Client files need to be added for ox_lib's require() to work on the client
files {
  -- Locales
  'locales/*.json',

  'shared/enums/*.lua',
  'shared/utils/*.lua',

  'client/managers/war_manager.lua',
  'client/managers/base_manager.lua',
  'client/managers/base_lock_manager.lua',
  'client/managers/team_manager.lua',
  'client/managers/vehicle_selection_manager.lua',
  'client/managers/capture_manager.lua',
  'client/managers/player_spawn_manager.lua',
  'client/managers/weapon_selection_manager.lua',
  'client/managers/base_protection_manager.lua',

  'client/classes/base.lua',
  'client/classes/base_spawn.lua',
  'client/classes/team.lua',

  'client/configs/bases.lua',
  'client/configs/teams.lua',
  'client/configs/vendor.lua',

  'client/utils/configs/bases.lua',
  'client/utils/configs/teams.lua',

  'client/utils/clothing.lua',
}

-- -- What to run
shared_scripts {
  '@ox_lib/init.lua',
}

server_scripts {
  'server/server.lua',
}

client_scripts {
  'client/client.lua',
}
