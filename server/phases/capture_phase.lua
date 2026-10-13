local CapturePhase <const> = {}

function CapturePhase:onEnter()
  print('Entered the capture phase')

  return {
    startCapture = true,
  }
end

function CapturePhase:onExit()
  print('Exited the capture phase')
end

return CapturePhase
