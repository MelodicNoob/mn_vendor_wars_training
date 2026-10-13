---@class Base : OxClass
---@field team Team
---@field coords vector3
---@field spawnCoords vector3
---@field vehicleSpawnCoords vector4
local Base = lib.class('Base')

---@param team Team
---@param coords vector3
---@param spawnCoords vector3
---@param vehicleSpawnCoords vector4
function Base:constructor(team, coords, spawnCoords, vehicleSpawnCoords)
  self.team = team
  self.coords = coords
  self.spawnCoords = spawnCoords
  self.vehicleSpawnCoords = vehicleSpawnCoords
end

function Base:toDto()
  return {
    team = self.team,
    coords = self.coords,
    spawnCoords = self.spawnCoords,
    vehicleSpawnCoords = self.vehicleSpawnCoords,
  }
end

return Base
