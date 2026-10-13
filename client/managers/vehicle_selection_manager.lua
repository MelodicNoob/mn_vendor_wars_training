local TeamManager <const> = require 'client.managers.team_manager'
local EnumUtils <const> = require 'shared.utils.enum'
local Team <const> = require 'shared.enums.team'

local VEHICLE_SELECTION_MENU_ID <const> = 'vehicle_selection_menu'

local SHOW_MENU_DISTANCE_REQUIRED <const> = 5.0

local VehicleSelectionManager <const> = {
  vehicleSelectionCoords = {},
  vehicleSelectionMarker = nil,
  availableVehicles = {},
  vehicleSelectionMenuIds = {}
}

function VehicleSelectionManager:setUp()
  print('VehicleSelectionManager:setUp()')
  self:startDrawVehicleSelectionMarkerThread()
end

---@param team Team
---@param availableVehicles table
local function registerTeamMenu(team, availableVehicles)
  local vehicleSelectionMenuOptions <const> = {}

  for _, vehicleModel in ipairs(availableVehicles) do
    table.insert(vehicleSelectionMenuOptions, {
      label = vehicleModel,
      args = vehicleModel
    })
  end

  local menuId <const> = ('team_%s_vehicle_selection_menu'):format(team)

  lib.registerMenu({
    id = menuId,
    title = 'Vehicle Selection',
    position = 'top-right',
    options = vehicleSelectionMenuOptions,
  }, function(selected, scrollIndex, args)
    print(selected, scrollIndex, args)
    TriggerServerEvent('mn_vendor_wars_training:server:selectedVehicle', team, args)
  end)

  return menuId
end

---@param vehicleSelectionData VehicleSelectionDto
function VehicleSelectionManager:sync(vehicleSelectionData)
  print('VehicleSelectionManager:sync: ', vehicleSelectionData)

  for team, vehicleSelectionCoord in pairs(vehicleSelectionData.vehicleSelectionCoords) do
    self.vehicleSelectionCoords[team] = vehicleSelectionCoord
  end

  for team, teamVehicles in pairs(vehicleSelectionData.availableVehicles) do
    self.availableVehicles[team] = teamVehicles
    self.vehicleSelectionMenuIds[team] = registerTeamMenu(team, teamVehicles)
  end
end

---@param team Team
function VehicleSelectionManager:updatedPlayerTeam(team)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  print('VehicleSelectionManager:updatedPlayerTeam')

  if self.vehicleSelectionCoords[team] then
    self.vehicleSelectionMarker = lib.marker.new({
      type = 1,
      coords = self.vehicleSelectionCoords[team],
      color = { r = 255, g = 0, b = 0, a = 200 },
    })
  else
    self.vehicleSelectionMarker = nil
  end
end

function VehicleSelectionManager:startDrawVehicleSelectionMarkerThread()
  CreateThread(function()
    local waitTime = 0
    while true do
      if not self.vehicleSelectionMarker then
        waitTime = 1000
      else
        self.vehicleSelectionMarker:draw()
        waitTime = 0
      end

      Wait(waitTime)
    end
  end)
end

---@param team Team
function VehicleSelectionManager:showMenu(team)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  if not self.vehicleSelectionCoords[team] then
    print('Cannot show the menu there is no vehicle selection coords')
    return
  end

  if #(self.vehicleSelectionCoords[team].xyz - GetEntityCoords(cache.ped).xyz) > SHOW_MENU_DISTANCE_REQUIRED then
    return
  end

  lib.showMenu(self.vehicleSelectionMenuIds[team])
end


RegisterNetEvent('mn_vendor_wars_training:client:spawnedVehicle', function(vehicleNetId)
	CreateThread(function()
    while not NetworkDoesEntityExistWithNetworkId(vehicleNetId) do
      Wait(50)
    end

    local vehicle = NetToVeh(vehicleNetId)
    while not DoesEntityExist(vehicle) do
      Wait(50)
      vehicle = NetToVeh(vehicleNetId)
    end

    cache.ped = cache.ped or PlayerPedId()

    TaskEnterVehicle(
      cache.ped --[[ Ped ]], 
      vehicle --[[ Vehicle ]], 
      -1 --[[ integer ]], 
      -1 --[[ integer ]], 
      1.0 --[[ number ]], 
      16 --[[ integer ]], 
      0 --[[ Any ]]
    )
  end)
end)

return VehicleSelectionManager
