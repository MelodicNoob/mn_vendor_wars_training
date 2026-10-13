local baseConfigUtils = require 'client.utils.configs.bases'

local BaseSpawn <const> = require 'client.classes.base_spawn'

local BaseLockManager <const> = require 'client.managers.base_lock_manager'

local BaseProtectionManager <const> = require 'client.managers.base_protection_manager'

local BASE_BLIP_SPRITE_ID <const> = 40
local BASE_ZONE_RADIUS <const> = baseConfigUtils.getBaseZoneRadius()

---@class Base : OxClass
---@field team Team
---@field coords vector3
---@field blip integer?
---@field zoneRadiusBlip integer?
---@field spawn BaseSpawn?
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

function Base:createBlip()
  local blip <const> = AddBlipForCoord(self.coords.x, self.coords.y, self.coords.z)
  SetBlipSprite(blip, BASE_BLIP_SPRITE_ID)
  SetBlipColour(blip, baseConfigUtils.getTeamBaseBlipColour(self.team) or 0)
  self.blip = blip
end

function Base:createZoneRadiusBlip()
  local blip <const> = AddBlipForRadius(
		self.coords.x,
    self.coords.y,
    self.coords.z,
		BASE_ZONE_RADIUS
	)
  SetBlipColour(blip, baseConfigUtils.getTeamBaseBlipColour(self.team) or 0)
  self.zoneRadiusBlip = blip
end

function Base:setUpPoint()
  local point <const> = lib.points.new({
    coords = self.coords,
    distance = BASE_ZONE_RADIUS,
  })

  local function onExit()
    BaseLockManager:onPlayerLeave(self)
    BaseProtectionManager:onPlayerLeave(self)
  end

  function point:onExit()
    onExit()
  end

  local function onEnter()
    BaseProtectionManager:onPlayerEnter(self)
  end

  function point:onEnter()
    onEnter()
  end
end

function Base:setUp()
  self:createBlip()
  self:createZoneRadiusBlip()

  self.spawn = BaseSpawn:new(self.spawnCoords, self.vehicleSpawnCoords)
  self:setUpPoint()
end

function Base:getSpawn()
  return self.spawn
end

---@param playerCoords vector3
---@return boolean
function Base:isInBase(playerCoords)
  return #(playerCoords.xy - self.coords.xy) <= BASE_ZONE_RADIUS
end

function Base.getBaseRadius()
  return BASE_ZONE_RADIUS
end

return Base
