local wavesConfig <const> = require 'server.configs.waves'

local BaseLockManager <const> = require 'server.managers.base_lock_manager'

local SERVER_NET_ID <const> = 0
local REMOVED_NET_ID <const> = -1

local NOTIFY_SECONDS_DELAY <const> = 5

---@class ReinforcementWavePrivateState
---@field currentWaveNetIds number[]
---@field nextWaveNetIds number[]
local privateState <const> = {
  currentWaveNetIds = {},
  nextWaveNetIds = {},
  isThreadCreated = false,
  countdown = wavesConfig.reinforcementWaveInterval
}

local ReinforcementWaveManager <const> = {}

---@param netIds number[]
---@param netId number
local function isInWave(netIds, netId)
  for _, reinforcementNetId in ipairs(netIds) do
    if reinforcementNetId == netId then
      return true
    end
  end

  return false
end

---@param netId number
function ReinforcementWaveManager:isInCurrentWave(netId)
  return isInWave(privateState.currentWaveNetIds, netId)
end

---@param netId number
function ReinforcementWaveManager:isInNextWave(netId)
  return isInWave(privateState.nextWaveNetIds, netId)
end

---@param netId number
---@return boolean
local function removePlayerFromCurrentWave(netId)
  for i, reinforcementNetId in ipairs(privateState.currentWaveNetIds) do
    if reinforcementNetId == netId then
      privateState.currentWaveNetIds[i] = REMOVED_NET_ID
      return true
    end
  end

  return false
end

---@param netId number
function ReinforcementWaveManager:onPlayerDeath(netId)
  if netId <= SERVER_NET_ID then
    print(('Net id of %d is not valid for reinforcement wave management'):format(netId))
    return
  end

  BaseLockManager:lockPlayer(netId)

  if privateState.countdown <= wavesConfig.reinforcementWaveLockoutDuration then
    if self:isInCurrentWave(netId) then
      print(('Removing player with netId %d from the current wave'):format(netId))
      removePlayerFromCurrentWave(netId)
    end

    if self:isInNextWave(netId) then
      print(('Player with netId %d is already in the next wave'):format(netId))
      return
    end

    privateState.nextWaveNetIds[#privateState.nextWaveNetIds + 1] = netId
    print(('Player with netId %d is added to the next wave'):format(netId))

    return
  end

  if self:isInCurrentWave(netId) then
    print(('Player with netId %d is already in the current wave'):format(netId))
    return
  end

  privateState.currentWaveNetIds[#privateState.currentWaveNetIds + 1] = netId
  print(('Player with netId %d is added to the current wave'):format(netId))
end

---@param netIds number[]
local function releaseWave(netIds)
  exports.chat:addMessage(-1, {
    color = {255, 0, 0},
    args = {'REINFORCEMENTS', 'Released'}
  })

  for _, netId in ipairs(netIds) do
    if netId > SERVER_NET_ID then
      print(('Releasing player with netId %d from the reinforcement wave lock'):format(netId))
      BaseLockManager:unlockPlayer(netId)
    end
  end
end

---@param countdown number
local function displayReinforcementCountdownNotification(countdown)
  exports.chat:addMessage(-1, {
    color = {255, 0, 0},
    args = {'REINFORCEMENTS', string.format('%d seconds', countdown)}
  })
end

local function displayReinforcementLockoutNotification()
  exports.chat:addMessage(-1, {
    color = {255, 0, 0},
    args = { 'REINFORCEMENTS', 'Die now, you will be locked out to next wave' }
  })
end

local function releaseCurrentWave()
  local currentWaveNetIds <const> = privateState.currentWaveNetIds

  privateState.currentWaveNetIds = privateState.nextWaveNetIds
  privateState.nextWaveNetIds = {}

  print('Releasing reinforcement wave')
  releaseWave(currentWaveNetIds)
end

local function startWaveReleaseThread()
  CreateThread(function()
    releaseCurrentWave()
  end)
end

---@param remainingLockoutNotifyDelay number
local function handleLockoutNotification(remainingLockoutNotifyDelay)
  if privateState.countdown > wavesConfig.reinforcementWaveLockoutDuration then
    return remainingLockoutNotifyDelay
  end

  if remainingLockoutNotifyDelay > 0 then
    return remainingLockoutNotifyDelay
  end

  print('REINFORCEMENTS: Die now, you will be locked out to next wave')

  displayReinforcementLockoutNotification()

  return NOTIFY_SECONDS_DELAY
end

local function processCountdown()
  privateState.countdown -= 1

  if privateState.countdown <= 0 then
    privateState.countdown = wavesConfig.reinforcementWaveInterval
    startWaveReleaseThread()
    return
  end

  print(('REINFORCEMENTS: %d seconds remaining'):format(privateState.countdown))

  displayReinforcementCountdownNotification(privateState.countdown)
end

function ReinforcementWaveManager:startThread()
  if privateState.isThreadCreated then
    return
  end

  privateState.isThreadCreated = true

  local remainingLockoutNotifyDelay = NOTIFY_SECONDS_DELAY
  CreateThread(function()
    while privateState.isThreadCreated do
      Wait(1000)

      if not privateState.isThreadCreated then
        break
      end

      remainingLockoutNotifyDelay -= 1
      remainingLockoutNotifyDelay = handleLockoutNotification(remainingLockoutNotifyDelay)

      processCountdown()
    end
  end)
end

function ReinforcementWaveManager:stopThread()
  privateState.isThreadCreated = false
end

return ReinforcementWaveManager
