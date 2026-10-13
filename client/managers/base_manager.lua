local TeamEnum <const> = require 'shared.enums.team'
local Base <const> = require 'client.classes.base'

local private <const> = {
  isSetupFinished = false,
}

local BaseManager <const> = {
  bases = {},
  enemyBases = {},
  hasNotifiedEnemyTerritory = false,
  hasEnteredEnemyTerritory = false,
}

function BaseManager:sync(baseData)
  for team, baseDto in pairs(baseData) do
    print(team, baseDto)
    local base <const> = Base:new(team, baseDto.coords, baseDto.spawnCoords, baseDto.vehicleSpawnCoords)
    self.bases[team] = base
    base:setUp()
  end

  private.isSetupFinished = true
end

function BaseManager:getBaseByTeam(team)
  return self.bases[team]
end

function BaseManager:notifyPlayerInEnemyTerritory()
  self.hasNotifiedEnemyTerritory = true

  print('Notified the player that they are in an enemy territory')
end

---@param base table
function BaseManager:onPlayerEnterEnemyTerritory(base)
  if not self.hasNotifiedEnemyTerritory then
    self:notifyPlayerInEnemyTerritory()
  end
end

function BaseManager:checkEnemyTerritories()
  local playerCoords <const> = GetEntityCoords(cache.ped)

  local isInEnemyBase = false
  for i = 1, #self.enemyBases do
    local enemyBase <const> = self.enemyBases[i]
    if enemyBase then
      -- Check if inside enemy territory
      if #(playerCoords.xy - enemyBase.coords.xy) <= Base.getBaseRadius() then
        isInEnemyBase = true

        if not self.hasEnteredEnemyTerritory then
          self.hasEnteredEnemyTerritory = true

          self:onPlayerEnterEnemyTerritory(enemyBase)
        end

        break
      end
    end
  end

  if not isInEnemyBase then
    self.hasEnteredEnemyTerritory = false
    self.hasNotifiedEnemyTerritory = false
  end
end

function BaseManager:updatedPlayerTeam(team)
  self.enemyBases = {}

  if team == TeamEnum.NONE then
    return -- No team assigned, so there are no enemy bases.
  end

  print('BaseManager:updatedPlayerTeam: ', team)

  for baseTeam, base in pairs(self.bases) do
    if baseTeam ~= TeamEnum.NONE and baseTeam ~= team then
      self.enemyBases[#self.enemyBases + 1] = base
    end
  end

  self:checkEnemyTerritories()
end

function BaseManager:startEnemyTerritoriesThread()
  CreateThread(function()
    while true do
      self:checkEnemyTerritories()
      Wait(1000)
    end
  end)
end

function BaseManager:isSetupFinished()
  return private.isSetupFinished
end

return BaseManager
