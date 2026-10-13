local CaptureManager <const> = require 'server.managers.capture_manager'
local PhaseManager <const> = require 'server.managers.phase_manager'
local Phase <const> = require 'shared.enums.phase'
local warConfig <const> = require 'server.configs.war'
local BaseLockManager <const> = require 'server.managers.base_lock_manager'
local Team <const> = require 'shared.enums.team'
local ReinforcementWaveManager <const> = require 'server.managers.reinforcement_wave_manager'

local privateWarManagerState <const> = {
  isStarted = false,
  isSetup = false,
}

local WarManager <const> = {}

---@param captureCoords vector3
function WarManager:setUp(captureCoords)
  if privateWarManagerState.isSetup then
    print('WarManager is already set up')
    return
  end

  privateWarManagerState.isSetup = true

  CaptureManager:setUp(captureCoords)

  PhaseManager:changePhase(Phase.INITIAL)
end

---@class WarDataDto
---@field isStarted boolean
---@field isSetup boolean

---@return WarDataDto
local function buildWarDataDto()
  return {
    isStarted = privateWarManagerState.isStarted,
    isSetup = privateWarManagerState.isSetup,
  }
end

function WarManager:sync()
  print('Server:WarManager:sync() called')

  GlobalState.warData = buildWarDataDto()
end

function WarManager:endWar()
  CaptureManager:reset()
  privateWarManagerState.isStarted = false
  PhaseManager:changePhase(Phase.INITIAL)
  TriggerClientEvent('chat:addMessage', -1, {
    color = { 255, 0, 0 },
    multiline = true,
    args = { 'War', 'Ended' }
  })
end

local function startDefenderSetupTimer()
  CreateThread(function()
    Wait(warConfig.defenderSetupDuration * 1000)
    local result <const> = PhaseManager:changePhase(Phase.CAPTURE)
    if result and result.changedPhaseOnEnter and result.changedPhaseOnEnter.startCapture then

      ---@param data any
      local function onVictoryCallback(data)
        if data and data.changePhaseResult and data.changePhaseResult.changedPhaseOnEnter.shouldEndWar then
          WarManager:endWar()
        end
      end

      CaptureManager:startCaptureThread(onVictoryCallback)
    end

    if result and result.previousPhaseOnExit then
      if result.previousPhaseOnExit.unlockAttackerTeam then
        BaseLockManager:unlockTeam(Team.ATTACKER)
      end

      if result.previousPhaseOnExit.startReinforcementWaveThread then
        ReinforcementWaveManager:startThread()
      end
    end
  end)
end

function WarManager:start()
  if privateWarManagerState.isStarted then
    print('The war already started')
    return
  end

  if not privateWarManagerState.isSetup then
    print('The war is not set up')
    return
  end

  privateWarManagerState.isStarted = true

  self:sync()

  local result <const> = PhaseManager:changePhase(Phase.DEFENDER_SETUP)
  if result and result.changedPhaseOnEnter and result.changedPhaseOnEnter.unlockDefenderTeam then
    BaseLockManager:unlockTeam(Team.DEFENDER)
  end

  -- Start countdown until capture phase
  startDefenderSetupTimer()

  TriggerClientEvent('chat:addMessage', -1, {
    color = { 255, 0, 0 },
    multiline = true,
    args = { 'War', 'Started' }
  })
end

return WarManager
