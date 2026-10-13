local VictoryPhase <const> = {}

function VictoryPhase:onEnter()
  print('Entered the victory phase')
  return {
    shouldEndWar = true,
  }
end

function VictoryPhase:onExit()
  print('Exited the victory phase')
end

return VictoryPhase
