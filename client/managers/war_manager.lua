local WarManager <const> = {
  captureCoords = nil,
  hasStarted = false,
  isSetUp = false,
}

function WarManager:setUp(captureCoords)
  self.captureCoords = captureCoords
  self.isSetUp = true
end

function WarManager:start()
  if not self.captureCoords then
    print('WarManager: Cannot start war, captureCoords is nil')
    return
  end

  self.hasStarted = true
end

function WarManager:sync(warDto)
  print('Client:WarManager:sync() called with warDto:', warDto)

  if not self.isSetUp and warDto.captureCoords then
    self:setUp(warDto.captureCoords)
  end

  if warDto.hasStarted and not self.hasStarted then
    self:start()
  end
end

return WarManager
