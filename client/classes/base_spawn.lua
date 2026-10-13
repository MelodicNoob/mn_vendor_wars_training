---@class BaseSpawn : OxClass
---@param playerCoords vector3
---@param vehicleCoords vector4
local BaseSpawn <const> = lib.class('BaseSpawn')

---@param playerCoords vector3
---@param vehicleCoords vector4
function BaseSpawn:constructor(playerCoords, vehicleCoords)
  self.playerCoords = playerCoords
  self.vehicleCoords = vehicleCoords
end

function BaseSpawn:teleportPlayer()
  SetEntityCoords(cache.ped, self.playerCoords.x, self.playerCoords.y, self.playerCoords.z, false, false, false, false)
end

---@param vehicle number
function BaseSpawn:teleportVehicle(vehicle)
  if not DoesEntityExist(vehicle) then return end

  SetEntityCoords(vehicle, self.vehicleCoords.x, self.vehicleCoords.y, self.vehicleCoords.z, false, false, false, false)
end

return BaseSpawn
