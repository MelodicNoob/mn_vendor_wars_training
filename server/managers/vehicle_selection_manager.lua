local BaseConfigUtils <const> = require 'server.utils.base_config'
local Team <const> = require 'shared.enums.team'
local EnumUtils <const> = require 'shared.utils.enum'

local VehicleSpawnManager <const> = require 'server.managers.vehicle_spawn_manager'

local availableVehiclesConfig <const> = require 'server.configs.available_vehicles'

local VehicleSelectionManager <const> = {
  vehicleSelectionCoords = {},
  vehicleCounts = {},
}

local INITIAL_VEHICLE_COUNT <const> = 0
local UNLIMITED_VEHICLE_LIMIT <const> = -1

function VehicleSelectionManager:setUp()
  for _, team in pairs(Team) do
    local vehicleSelectionCoords <const> = BaseConfigUtils.getVehicleSelectionCoords(team)
    if vehicleSelectionCoords then
      self.vehicleSelectionCoords[team] = vehicleSelectionCoords
    end
  
    -- Todo: initialise each team's vehicles count

    local vehicleCounts <const> = self.vehicleCounts

    VehicleSelectionManager.vehicleCounts[team] = vehicleCounts[team] or {}
    local teamVehicleCounts <const> = vehicleCounts[team]

    for vehicleModel, _ in pairs(availableVehiclesConfig.availableVehicles) do
      teamVehicleCounts[vehicleModel] = teamVehicleCounts[vehicleModel] or INITIAL_VEHICLE_COUNT
    end

    local teamAvailableVehicles <const> = availableVehiclesConfig.teamAvailableVehicles[team] or {}
    for vehicleModel, _ in pairs(teamAvailableVehicles) do
      teamVehicleCounts[vehicleModel] = teamVehicleCounts[vehicleModel] or INITIAL_VEHICLE_COUNT
    end
  end

  for team, teamVehicleCounts in pairs(self.vehicleCounts) do
    for vehicleModel, vehicleCount in pairs(teamVehicleCounts) do
      print(('Team %d\'s %s vehicle count is %d'):format(team, vehicleModel, vehicleCount))
    end
  end

  self:sync()
end

---@param vehicleModel string
---@param team Team
function VehicleSelectionManager:isVehicleAvailable(vehicleModel, team)
  if team and not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  local teamAvailableVehicles <const> = availableVehiclesConfig.teamAvailableVehicles[team] or {}
  local availableVehicles <const> = availableVehiclesConfig.availableVehicles or {}
  local availableVehicle <const> = teamAvailableVehicles[vehicleModel] or availableVehicles[vehicleModel]

  if availableVehicle then
    local vehicleLimit <const> = availableVehicle.limit or UNLIMITED_VEHICLE_LIMIT
    if vehicleLimit == UNLIMITED_VEHICLE_LIMIT then
      return true
    end

    local vehicleCounts <const> = self.vehicleCounts
    local teamVehicleCounts <const> = vehicleCounts[team] or {}

    local vehicleCount <const> = vehicleCounts[vehicleModel] or teamVehicleCounts[vehicleModel] or INITIAL_VEHICLE_COUNT
    if vehicleCount < vehicleLimit then
      return true
    end
  end

  return false
end

---@class SelectVehicleOptions
---@field vehicleModel string
---@field team Team
---@field source number?

---@param options SelectVehicleOptions
function VehicleSelectionManager:selectVehicle(options)
  if not options.source then
    options.source = 0
  end

  print(('Someone has selected a %s'):format(options.vehicleModel))

  if not self:isVehicleAvailable(options.vehicleModel, options.team) then
    print(('The selected vehicle model \'%s\' is not available'):format(options.vehicleModel))
    return false
  end

  local coords <const> = BaseConfigUtils.getVehicleSpawnCoords(options.team)
  if coords == nil then
    print(('No vehicle spawn coords for %s'):format(options.team))
    return false
  end

  local hasSpawned <const>, vehicle <const> = VehicleSpawnManager:spawn({
    team = options.team,
    vehicleModel = options.vehicleModel,
    coords = coords,
    source = options.source,
  })

  if hasSpawned == false then
    return false
  end

  if self.vehicleCounts[options.team] then
    local vehicleCount = self.vehicleCounts[options.team][options.vehicleModel] or 0
    self.vehicleCounts[options.team][options.vehicleModel] = vehicleCount + 1
    print(self.vehicleCounts[options.team][options.vehicleModel])
    print(('Incremented team %s\'s %s vehicle count'):format(options.team, options.vehicleModel))
    print(('Team %s\'s %s vehicle count: %d'):format(options.team, options.vehicleModel, self.vehicleCounts[options.team][options.vehicleModel]))
  end

  print(vehicle)
  local vehicleNetId <const> = NetworkGetNetworkIdFromEntity(vehicle)
  print(vehicleNetId)
  TriggerClientEvent('mn_vendor_wars_training:client:spawnedVehicle', options.source, vehicleNetId)
end

---@return VehicleSelectionDto
function VehicleSelectionManager:buildVehicleSelectionDto()
  ---@type VehicleSelectionDto
  local dto <const> = {
    vehicleSelectionCoords = {},
    availableVehicles = {
      [Team.ATTACKER] = {},
      [Team.DEFENDER] = {}
    },
  }

  for team, vehicleSelectionCoord in pairs(self.vehicleSelectionCoords) do
    dto.vehicleSelectionCoords[team] = vehicleSelectionCoord
  end

  for team, teamVehicleCounts in pairs(self.vehicleCounts) do
    for vehicleModel, _ in pairs(teamVehicleCounts) do
      if dto.availableVehicles[team] then
        table.insert(dto.availableVehicles[team], vehicleModel)
      end
    end
  end

  return dto
end

function VehicleSelectionManager:sync()
  GlobalState.vehicleSelectionData = self:buildVehicleSelectionDto()
  print('GlobalState.vehicleSelectionData: ', GlobalState.vehicleSelectionData)
  print('GlobalState.vehicleSelectionData.vehicleSelectionCoords', GlobalState.vehicleSelectionData.vehicleSelectionCoords)
  for team, vehicleSelectionCoord in pairs(GlobalState.vehicleSelectionData.vehicleSelectionCoords) do
    print(team, vehicleSelectionCoord)
  end
end

return VehicleSelectionManager
