local Phase <const> = require 'shared.enums.phase'
local EnumUtils <const> = require 'shared.utils.enum'
local InitialPhase <const> = require 'server.phases.initial_phase'
local DefenderSetupPhase <const> = require 'server.phases.defender_setup_phase'
local CapturePhase <const> = require 'server.phases.capture_phase'
local VictoryPhase <const> = require 'server.phases.victory_phase'

local phaseManagerPrivate <const> = {
  currentPhase = nil,
  phases = {
    [Phase.INITIAL] = InitialPhase,
    [Phase.DEFENDER_SETUP] = DefenderSetupPhase,
    [Phase.CAPTURE] = CapturePhase,
    [Phase.VICTORY] = VictoryPhase,
  }
}

local PhaseManager <const> = {}

---@param phase Phase
function PhaseManager:changePhase(phase)
  if not EnumUtils.isValidEnumValue(Phase, phase) then
    error(('Invalid phase enum: %s'):format(phase))
  end

  local onExitReturnedData = nil
  if phaseManagerPrivate.currentPhase and phase ~= phaseManagerPrivate.currentPhase then
    if type(phaseManagerPrivate.currentPhase.onExit) == 'function' then
      onExitReturnedData = phaseManagerPrivate.currentPhase:onExit()
    end
  end

  phaseManagerPrivate.currentPhase = phaseManagerPrivate.phases[phase]
  return {
    previousPhaseOnExit = onExitReturnedData,
    changedPhaseOnEnter = phaseManagerPrivate.currentPhase:onEnter()
  }
end

function PhaseManager:getCurrentPhase()
  return phaseManagerPrivate.currentPhase
end

return PhaseManager
