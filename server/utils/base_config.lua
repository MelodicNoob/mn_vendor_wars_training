local basesConfig <const> = require 'server.configs.bases'
local EnumUtils <const> = require 'shared.utils.enum'
local Team <const> = require 'shared.enums.team'

local DEFAULT_VEHICLE_COLOUR_COMBINATION <const> = {
  primary = 0,
  secondary = 0,
}

local BaseConfigUtils <const> = {}

---@param team Team
---@param key string
---@return any
function BaseConfigUtils.getValueFromTeam(team, key)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  local teamConfig <const> = basesConfig[team]
  if not teamConfig then
    error(('Missing base config for team %s'):format(team))
  end

  return teamConfig[key]
end

---@param team Team
---@return vector3?
function BaseConfigUtils.getVehicleSelectionCoords(team)
  local value <const> = BaseConfigUtils.getValueFromTeam(team, 'vehicleSelectionCoords')
  return type(value) == 'vector3' and value or nil
end

---@param team Team
---@return vector4?
function BaseConfigUtils.getVehicleSpawnCoords(team)
  local value <const> = BaseConfigUtils.getValueFromTeam(team, 'vehicleSpawnCoords')
  return type(value) == 'vector4' and value or nil
end

---@class VehicleColourCombination
---@field primary number
---@field secondary number

---@param team Team
---@return VehicleColourCombination
function BaseConfigUtils.getVehicleColours(team)
  local vehicleConfig <const> = BaseConfigUtils.getValueFromTeam(team, 'vehicle')
  local colour <const> = vehicleConfig and vehicleConfig.colour

  if not colour then
    return DEFAULT_VEHICLE_COLOUR_COMBINATION
  end

  if type(colour.primary) ~= 'number' or type(colour.secondary) ~= 'number' then
    return DEFAULT_VEHICLE_COLOUR_COMBINATION
  end

  return colour
end

return BaseConfigUtils
