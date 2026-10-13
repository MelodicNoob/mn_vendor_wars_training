local enumUtils <const> = require('shared.utils.enum')
local Team <const> = require('shared.enums.team')
local TeamManager <const> = require('server.managers.team_manager')
local WarManager <const> = require('server.managers.war_manager')
local BaseManager <const> = require 'server.managers.base_manager'
local VehicleSelectionManager <const> = require 'server.managers.vehicle_selection_manager'
local CaptureManager <const> = require 'server.managers.capture_manager'
local BaseLockManager <const> = require 'server.managers.base_lock_manager'
local ReinforcementWaveManager <const> = require 'server.managers.reinforcement_wave_manager'
local WeaponSelectionManager <const> = require 'server.managers.weapon_selection_manager'

local CAPTURE_COORDS <const> = vector3(-580.497253, -1589.630249, 26.751125)

AddEventHandler('playerJoining', function()
  TeamManager:addPlayerToTeam(source, Team.NONE)
  TeamManager:syncPlayer(source)
  BaseLockManager:sync(Team.NONE, source)
end)

lib.addCommand('team', {
  help = 'Select a team',
  params = {
    {
      name = 'team',
      type = 'number',
      help = 'Team id value',
    },
  },
}, function(source, args, raw)
  local teamArg <const> = args.team
  -- Reject the request if the provided team enum is invalid and notify the player
  if not enumUtils.isValidEnumValue(Team, teamArg) then
    TriggerClientEvent('ox_lib:notify', source, {
      title = 'Invalid team',
      description = 'Notification description',
      type = 'error'
    })
    return
  end

  -- Reject the request if player is already on the team to join
  if TeamManager:isPlayerInTeam(source, teamArg) then
    print(('Player\'s server id of (%d) is already on team %d'):format(source, teamArg))
    return
  end

  TeamManager:addPlayerToTeam(source, teamArg)

  TeamManager:syncPlayer(source)

  TriggerClientEvent('ox_lib:notify', source, {
    title = 'Notification title',
    description = 'Notification description',
    type = 'success'
  })

  local player <const> = lib.player:new(source)
  if player:getRoutingBucket() ~= 0 then
    player:setRoutingBucket(0)
  end

  BaseLockManager:sync(teamArg, source)
end)

RegisterNetEvent('mn_vendor_wars_training:server:selectedVehicle', function(team, vehicle)
  print(('mn_vendor_wars_training:server:selectedVehicle: team (%d), vehicle (%s)'):format(team, vehicle))

  if not TeamManager:isPlayerInTeam(source, team) then
    print('Player is not on this team')
    return
  end

  if not VehicleSelectionManager:isVehicleAvailable(vehicle, team) then
    print(('Vehicle %s is not available'):format(vehicle))
    return
  end

  VehicleSelectionManager:selectVehicle({
    vehicleModel = vehicle,
    team = team,
    source = source,
  })
end)

RegisterNetEvent('mn_vendor_wars_training:server:captured', function()
  print(('Player %d has captured'):format(source))

  local team <const> = TeamManager:findTeam(source)

  CaptureManager:capture(team, source)
end)

local function setUpManagers()
  TeamManager:setUp()
  BaseManager:setUp()
  WarManager:setUp(CAPTURE_COORDS)
  VehicleSelectionManager:setUp()
end

setUpManagers()

RegisterCommand('startWar', function()
  WarManager:start()
end, true)

RegisterCommand('lockbase', function(source)
  local team <const> = TeamManager:findTeam(source)
  BaseLockManager:lockTeam(team)
  print('Team base locked')
end, true)

RegisterCommand('unlockbase', function(source)
  local team <const> = TeamManager:findTeam(source)
  BaseLockManager:unlockTeam(team)
  print('Team base unlocked')
end, true)

RegisterCommand('isbaselocked', function(source)
  local team <const> = TeamManager:findTeam(source)
  local isBaseLocked = BaseLockManager:isTeamLocked(team)
  print(('Base lock status for team %d: %s'):format(team, tostring(isBaseLocked)))
end, true)

AddEventHandler('onServerResourceStart', function(resource)
  if GetCurrentResourceName() ~= resource then
    return
  end

  local defaultTeam <const> = Team.NONE

  for _, playerId in ipairs(GetPlayers()) do
    local playerIdNum <const> = tonumber(playerId)
    if playerIdNum then
      TeamManager:addPlayerToTeam(playerIdNum, defaultTeam)
      TeamManager:syncPlayer(playerIdNum)
      BaseLockManager:sync(defaultTeam, playerIdNum)
    end
  end
end)

RegisterNetEvent('baseevents:onPlayerDied', function()
  local source = source
  ReinforcementWaveManager:onPlayerDeath(source)
end)

RegisterNetEvent('baseevents:onPlayerKilled', function()
  local source = source
  ReinforcementWaveManager:onPlayerDeath(source)
end)

RegisterNetEvent('baseevents:onPlayerWasted', function()
  local source = source
  ReinforcementWaveManager:onPlayerDeath(source)
end)

WeaponSelectionManager:sync()

lib.callback.register('mn_vendor_wars_training:server:weaponSelected', function(source, weaponModel)
  if type(weaponModel) ~= 'string' then
    return nil
  end

  return WeaponSelectionManager:selectWeapon(weaponModel)
end)
