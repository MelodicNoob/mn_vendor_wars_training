local DefenderSetupPhase <const> = {}

function DefenderSetupPhase:onEnter()
  print('Entered the defender setup phase')
  return {
    unlockDefenderTeam = true,
  }
end

function DefenderSetupPhase:onExit()
  print('Exited the defender setup phase')
  return {
    unlockAttackerTeam = true,
    startReinforcementWaveThread = true,
  }
end

return DefenderSetupPhase
