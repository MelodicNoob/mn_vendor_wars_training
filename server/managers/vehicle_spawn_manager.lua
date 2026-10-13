local BaseConfigUtils <const> = require 'server.utils.base_config'
local EnumUtils <const> = require 'shared.utils.enum'
local Team <const> = require 'shared.enums.team'

local VehicleSpawnManager <const> = {}

---@param vehicle integer
---@param team Team
function VehicleSpawnManager:applyTeamColours(vehicle, team)
	if not DoesEntityExist(vehicle) then
		print(('Vehicle %d does not exist.'):format(vehicle))
		return
	end

	local teamColours <const> = BaseConfigUtils.getVehicleColours(team)
	TriggerClientEvent('ox_lib:setVehicleProperties', -1, NetworkGetNetworkIdFromEntity(vehicle), {
    color1 = teamColours.primary,
    color2 = teamColours.secondary,
  })
end

---@class VehicleSpawnOptions
---@field coords vector4
---@field source number
---@field vehicleModel string
---@field team Team

---@param options VehicleSpawnOptions
---@return boolean, number
function VehicleSpawnManager:spawn(options)
  if lib.getClosestVehicle(options.coords.xyz) then
    print(('Blocked vehicle spawn at %s coordinates'):format(tostring(options.coords.xyz)))
    if options.source > 0 then
      TriggerClientEvent('ox_lib:notify', options.source, {
        title = 'Blocked vehicle spawn',
        type = 'error'
      })
    end
    return false, 0
  end

  local vehicle <const> = CreateVehicleServerSetter(
		joaat(options.vehicleModel),
		'automobile',
		options.coords.x,
		options.coords.y,
		options.coords.z,
		options.coords.w
	)

	if vehicle == 0 then
		print('Vehicle failed to spawn')
		    return false, 0
	end

	if EnumUtils.isValidEnumValue(Team, options.team) then
		self:applyTeamColours(vehicle, options.team)
	end

	return true, vehicle
end

return VehicleSpawnManager
