local TeamManager <const> = require 'client.managers.team_manager'

local privateState <const> = {
  isLocked = false,
}

local BaseLockManager <const> = {}

---@param isLocked boolean
function BaseLockManager:sync(isLocked)
  print('BaseLockManager:sync')
  privateState.isLocked = isLocked
end

function BaseLockManager:isLocked()
  return privateState.isLocked
end

---@param leftBase Base
function BaseLockManager:onPlayerLeave(leftBase)
  if not self:isLocked() then
    print('Player is not base-locked')
    return
  end

  local currentTeam <const> = TeamManager:getPlayerTeam()
  if currentTeam ~= leftBase.team then
    print('Ignoring base leave event for a non-team base')
    return
  end

  print('Player attempted to leave a locked base')

  local baseSpawn <const> = leftBase:getSpawn()
  if baseSpawn then
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    if vehicle > 0 then
      print('Local player is in a vehicle!')
      if GetPedInVehicleSeat(vehicle, -1) == cache.ped then
        baseSpawn:teleportVehicle(vehicle)
      else
        baseSpawn:teleportPlayer()
      end
    else
      baseSpawn:teleportPlayer()
    end
  end
end

---@param base Base
function BaseLockManager:enforceBaseLock(base)
  if not self.isLocked then
    return
  end

  local playerCoords <const> = GetEntityCoords(cache.ped)
  if base:isInBase(playerCoords) then
    return
  end

  local baseSpawn <const> = base:getSpawn()
  if not baseSpawn then
    print('Base is missing a spawn')
    return
  end

  baseSpawn:teleportPlayer()
end

return BaseLockManager
