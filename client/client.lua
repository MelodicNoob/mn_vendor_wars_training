---@diagnostic disable: param-type-mismatch

local WarManager <const> = require 'client.managers.war_manager'
local BaseManager <const> = require 'client.managers.base_manager'
local TeamManager <const> = require 'client.managers.team_manager'
local VehicleSelectionManager <const> = require 'client.managers.vehicle_selection_manager'
local CaptureManager <const> = require 'client.managers.capture_manager'
local BaseLockManager <const> = require 'client.managers.base_lock_manager'
local PlayerSpawnManager <const> = require 'client.managers.player_spawn_manager'
local WeaponSelectionManager <const> = require 'client.managers.weapon_selection_manager'

local Team <const> = require 'shared.enums.team'

local EnumUtils <const> = require 'shared.utils.enum'

exports.spawnmanager:setAutoSpawnCallback(function()
  PlayerSpawnManager:spawnPlayer()
end)
exports.spawnmanager:setAutoSpawn(true)
exports.spawnmanager:forceRespawn()

AddEventHandler('onClientResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end

  if GlobalState.warDto then
    WarManager:sync(GlobalState.warDto)
  end

  if GlobalState.baseData then
    BaseManager:sync(GlobalState.baseData)
  end

  if GlobalState.teamData then
    TeamManager:sync(GlobalState.teamData)
  end

  if LocalPlayer.state.team then
    VehicleSelectionManager:updatedPlayerTeam(LocalPlayer.state.team)
  end

  BaseManager:startEnemyTerritoriesThread()

  if GlobalState.vehicleSelectionData then
    VehicleSelectionManager:sync(GlobalState.vehicleSelectionData)
  end

  if GlobalState.captureData then
    CaptureManager:sync(GlobalState.captureData)
  end

  if LocalPlayer.state['baseLock:isLocked'] then
    BaseLockManager:sync(LocalPlayer.state['baseLock:isLocked'])
  end

    if GlobalState.weaponSelectionData then
    WeaponSelectionManager:sync(GlobalState.weaponSelectionData)
  end
end)

AddStateBagChangeHandler(
  'warDto',
  'global',
  function(bagName, key, value, reserved, replicated)
    WarManager:sync(value)
  end
)

AddStateBagChangeHandler(
  'warDto:captureCoords',
  'global',
  function(bagName, key, value, reserved, replicated)
    local previousWarDto = GlobalState.warDto
    if previousWarDto then
      previousWarDto.captureCoords = value
      WarManager:sync(previousWarDto)
    end
  end
)

AddStateBagChangeHandler(
  'teamData',
  'global',
  function(bagName, key, value, reserved, replicated)
    TeamManager:sync(value)
  end
)

AddStateBagChangeHandler(
  'team',
  ('player:%d'):format(cache.serverId),
  function(bagName, key, value, reserved, replicated)
    if not EnumUtils.isValidEnumValue(Team, value) then
      return
    end

    TeamManager:syncPlayerTeam(value)
    BaseManager:updatedPlayerTeam(value)
    VehicleSelectionManager:updatedPlayerTeam(value)
    local playerBase <const> = BaseManager:getBaseByTeam(value)
    if playerBase then
      BaseLockManager:enforceBaseLock(playerBase)
    end
  end
)


RegisterCommand('coords', function()
  local coords <const> = GetEntityCoords(cache.ped)
  print(coords)
end)

AddStateBagChangeHandler(
  'vehicleSelectionData',
  'global',
  function(bagName, key, value, reserved, replicated)
    VehicleSelectionManager:sync(value)
  end
)

VehicleSelectionManager:setUp()

RegisterCommand('vehicleSelectionMenu', function()
  VehicleSelectionManager:showMenu(TeamManager:getPlayerTeam())
end)

local openVehicleSelectionKeybind <const> = lib.addKeybind({
  name = 'vehicle_selection',
  description = 'Open the vehicle selection menu',
  defaultKey = 'G',
  allowInPauseMenu = true,
  onPressed = function(self)
    VehicleSelectionManager:showMenu(TeamManager:getPlayerTeam())
  end,
  onReleased = function(self) end,
})

AddStateBagChangeHandler(
  'captureData',
  'global',
  function(bagName, key, value, reserved, replicated)
    CaptureManager:sync(value)
  end
)

local captureVendorKeybind = lib.addKeybind({
  name = 'capture_vendor',
  description = 'Attempt to capture the vendor',
  defaultKey = 'G',
  allowInPauseMenu = true,
  onPressed = function()
    CaptureManager:attemptCapture()
  end,
})

AddStateBagChangeHandler(
  'baseLock:isLocked',
  ('player:%d'):format(cache.serverId),
  function(bagName, key, value, reserved, replicated)
    BaseLockManager:sync(value)

    local playerTeam <const> = TeamManager:getPlayerTeam()
    if playerTeam then
      local playerBase <const> = BaseManager:getBaseByTeam(playerTeam)
      if playerBase then
        BaseLockManager:enforceBaseLock(playerBase)
      end
    end
  end
)

AddStateBagChangeHandler(
  'weaponSelectionData',
  nil,
  function(bagName, key, value, reserved, replicated)
    WeaponSelectionManager:sync(value)
  end
)

RegisterCommand('weapons', function()
  WeaponSelectionManager:showMenu()
end)

NetworkSetFriendlyFireOption(true)

local PROTECTED_PLAYER_STATE_KEY <const> = 'protectedPlayer:%d'

AddStateBagChangeHandler(
  nil,
  nil,
  function(bagName, key, value, reserved, replicated)
    print(bagName, key, value, reserved, replicated)

    local matchedProtectedPlayerStateKey = string.match(key, PROTECTED_PLAYER_STATE_KEY)
    if matchedProtectedPlayerStateKey then
      print('Protected player state updated')
      local startIndex, endIndex = string.find(key, '%d')
      print(startIndex, endIndex)
      local protectedPlayerId = string.sub(key, startIndex, endIndex)
      if protectedPlayerId then
        local convertedPlayerId <const> = tonumber(protectedPlayerId)
        if convertedPlayerId then
          print(('Protected player id type: %s'):format(type(convertedPlayerId)))
          print(('Protected player id: %d'):format(convertedPlayerId))

          if convertedPlayerId ~= cache.serverId then
            if value then
              print('Protecting another player from being shot at by you')
            else
              print('You are allowed to shoot that player now')
            end
          end
        end
      end
    end
  end
)
