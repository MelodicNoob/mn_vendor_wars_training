local BaseManager <const> = require 'client.managers.base_manager'
local TeamManager <const> = require 'client.managers.team_manager'

local PLAYER_MAXIMUM_HEALTH <const> = 250

---@class PrivatePlayerSpawnManager
local private <const> = {
  isFirstSpawn = true,
}

---@param teamClient TeamClient
local function onPlayerSpawned(teamClient)
  cache.ped = PlayerPedId()
  teamClient:applyOutfit()
  SetPedMaxHealth(cache.ped, PLAYER_MAXIMUM_HEALTH)
  SetEntityHealth(cache.ped, PLAYER_MAXIMUM_HEALTH)
end

local PlayerSpawnManager <const> = {}

function PlayerSpawnManager:spawnPlayer()
  CreateThread(function()
    while not BaseManager:isSetupFinished() and not TeamManager:getIsPlayerTeamSynced() do
      Wait(100)
    end

    local playerTeam <const> = TeamManager:getPlayerTeam()
    local base <const> = BaseManager:getBaseByTeam(playerTeam)

    if not base then
      error(('Missing base for player team: %s'):format(tostring(playerTeam)))
    end

    local teamClient <const> = TeamManager:getTeamClient(playerTeam)
    if not teamClient then
      error(('Missing teamClient for player team: %s'):format(tostring(playerTeam)))
    end

    local spawnCoords <const> = base and base.spawnCoords or nil
    if not spawnCoords then
      error(('Missing spawnCoords for base: %s'):format(tostring(base)))
    end

    if private.isFirstSpawn then
      exports.spawnmanager:spawnPlayer({
        x = spawnCoords.x,
        y = spawnCoords.y,
        z = spawnCoords.z,
        heading = spawnCoords.w,
        skipFade = true,
        model = 'mp_m_freemode_01',
      }, function()
        onPlayerSpawned(teamClient)
      end)
      private.isFirstSpawn = false
      return
    end

    exports.spawnmanager:spawnPlayer({
      x = spawnCoords.x,
      y = spawnCoords.y,
      z = spawnCoords.z,
      heading = spawnCoords.w,
      skipFade = true,
    }, function()
      onPlayerSpawned(teamClient)
    end)
  end)
end

return PlayerSpawnManager
