local Team <const> = require 'shared.enums.team'
local EnumUtils <const> = require 'shared.utils.enum'
local TeamManager <const> = require 'server.managers.team_manager'

local privateState <const> = {
  lockedTeams = {
    [Team.NONE] = false,
    [Team.ATTACKER] = false,
    [Team.DEFENDER] = false,
  },
}

local LOCK_PLAYER_STATE_KEY <const> = 'baseLock:isLocked'

---@param netId number
local function lockPlayer(netId)
  local player <const> = lib.player:new(netId)

  player:sets(LOCK_PLAYER_STATE_KEY, true)
end

---@param netId number
local function unlockPlayer(netId)
  local player <const> = lib.player:new(netId)
  player:sets(LOCK_PLAYER_STATE_KEY, false)
end

---@param netId number
local function isPlayerLocked(netId)
  local player <const> = lib.player:new(netId)
  return player:get(LOCK_PLAYER_STATE_KEY) or false
end

local BaseLockManager <const> = {}

---@param team Team
function BaseLockManager:lockTeam(team)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  if privateState.lockedTeams[team] then
    error(('Team %s is already locked'):format(team))
  end

  privateState.lockedTeams[team] = true

  CreateThread(function()
    local netIds <const> = TeamManager:getTeamNetIds(team)
    for _, netId in ipairs(netIds) do
      lockPlayer(netId)
    end
  end)
end

---@param team Team
function BaseLockManager:unlockTeam(team)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  if not privateState.lockedTeams[team] then
    error(('Team %s is already unlocked'):format(team))
  end

  privateState.lockedTeams[team] = false

  CreateThread(function()
    local netIds <const> = TeamManager:getTeamNetIds(team)
    for _, netId in ipairs(netIds) do
      unlockPlayer(netId)
    end
  end)
end

---@param team Team
function BaseLockManager:isTeamLocked(team)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  if privateState.lockedTeams[team] == nil then
    error(('Missing lock state for team %d'):format(team))
  end

  return privateState.lockedTeams[team]
end

---@param playerTeam Team
---@param netId number
function BaseLockManager:sync(playerTeam, netId)
  local shouldBeLocked <const> = self:isTeamLocked(playerTeam)
  local isLocked <const> = isPlayerLocked(netId)

  if shouldBeLocked == isLocked then
    return
  end

  if shouldBeLocked then
    lockPlayer(netId)
  else
    unlockPlayer(netId)
  end
end

---@param netId number
function BaseLockManager:unlockPlayer(netId)
  unlockPlayer(netId)
end

---@param netId number
function BaseLockManager:lockPlayer(netId)
  lockPlayer(netId)
end

return BaseLockManager
