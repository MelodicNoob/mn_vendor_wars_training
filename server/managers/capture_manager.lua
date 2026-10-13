local Team <const> = require 'shared.enums.team'
local EnumUtils <const> = require 'shared.utils.enum'
local vendorConfig <const> = require 'server.configs.vendor'
local PhaseManager <const> = require 'server.managers.phase_manager'
local Phase <const> = require 'shared.enums.phase'

local CaptureManager <const> = {
  vendorCoords = nil,
  scores = {},
  vendorControllingTeam = Team.NONE,
  canCapture = false,
}

---@param coords vector3
function CaptureManager:setUp(coords)
  self.vendorCoords = coords

  for _, teamValue in pairs(Team) do
    self.scores[teamValue] = 0
  end

  self:sync()
end

---@param team Team
---@param source number?
function CaptureManager:capture(team, source)
  source = source or 0

  if not self.canCapture then
    print(('Player %d attempted to capture while capturing is disabled'):format(source))
    return
  end

  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  if team == Team.NONE then
    print(('Player %d attempted to capture a vendor without being on a team'):format(source))
    return
  end

  if team == self.vendorControllingTeam then
    print(('Team %d attempted to capture a vendor controlled by team %d'):format(team, self.vendorControllingTeam))
    if source > 0 then
      -- lib.notify({
      --   title = 'Your team has capture',
      --   description = '',
      --   type = 'error',
      -- })
      TriggerClientEvent('ox_lib:notify', source, {
        title = 'Capture Failed',
        description = 'This vendor is already controlled by your team.',
        type = 'error'
      })
    end

    return
  end

  if source > 0 then
    local ped <const> = GetPlayerPed(source)
    local playerCoords <const> = GetEntityCoords(ped)
    if #(playerCoords.xyz - self.vendorCoords.xyz) > vendorConfig.captureDistance then
      print(('Player %d is too far away to capture a vendor'):format(source))
      return
    end
  end

  self.vendorControllingTeam = team
  self:sync()

  TriggerClientEvent('chat:addMessage', -1, {
    color = { 255, 0, 0 },
    multiline = true,
    args = { 'Capture', ('Team %d has captured'):format(team) }
  })
end

---@param onVictoryCallback fun(data: any): table
function CaptureManager:startCaptureThread(onVictoryCallback)
  if self.canCapture then
    return
  end

  if not self.vendorCoords then
    error('Cannot capture: vendor coordinates are missing')
  end

  self.canCapture = true

  CreateThread(function()
    while self.canCapture do
      Wait(vendorConfig.captureScoreInterval * 1000)

      if self.vendorControllingTeam ~= Team.NONE then
        self.scores[self.vendorControllingTeam] += 1

        exports.chat:addMessage(-1, {
          color = {255, 0, 0},
          args = { 'CAPTURE', ('Team %d is %d%% towards victory'):format(self.vendorControllingTeam, self.scores[self.vendorControllingTeam]) }
        })

        if self.scores[self.vendorControllingTeam] >= vendorConfig.scoreThreshold then
          print(('Team %d is the victor'):format(self.vendorControllingTeam))

          TriggerClientEvent('ox_lib:notify', -1, {
            title = ('Team %d has won control of the vendor'):format(self.vendorControllingTeam),
            description = ('Team %d now controls the vendor'):format(self.vendorControllingTeam),
            type = 'success',
          })

          exports.chat:addMessage(-1, {
            color = {255, 0, 0},
            args = { 'CAPTURE', ('Team %d is the victor'):format(self.vendorControllingTeam) }
          })

          self:sync()
          self.canCapture = false

          local result <const> = PhaseManager:changePhase(Phase.VICTORY)

          if onVictoryCallback then
            onVictoryCallback({
              changePhaseResult = result
            })
          end

          return
        end

        self:sync()

        print(('Current score for team %d is %d'):format(self.vendorControllingTeam, self.scores[self.vendorControllingTeam]))
      end
    end
  end)
end

---@class CaptureDto
---@field vendorCoords vector3
---@field scores table<Team, number>
---@field vendorControllingTeam Team

---@return CaptureDto
function CaptureManager:buildCaptureDto()
  local scores <const> = {}
  for team, score in pairs(self.scores) do
    scores[team] = score
  end

  ---@type CaptureDto
  local dto <const> = {
    scores = scores,
    vendorCoords = self.vendorCoords,
    vendorControllingTeam = self.vendorControllingTeam,
  }

  return dto
end

function CaptureManager:sync()
  GlobalState.captureData = self:buildCaptureDto()
end

function CaptureManager:reset()
  for _, teamValue in pairs(Team) do
    self.scores[teamValue] = 0
  end

  self.vendorControllingTeam = Team.NONE

  self:sync()
end

return CaptureManager
