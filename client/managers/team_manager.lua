local TeamEnum <const> = require 'shared.enums.team'
local TeamClient <const> = require 'client.classes.team'
local TeamDtoUtils <const> = require 'shared.utils.team_dto'

local private <const> = {
  isSynced = false,
  isPlayerTeamSynced = false,
}

local TeamManager <const> = {
  teams = {},
  playerTeam = TeamEnum.NONE --[[@as Team]],
}

---@param teamData TeamData
function TeamManager:sync(teamData)
  for team, teamDto in pairs(teamData) do
    if TeamDtoUtils.isValid(teamDto) then
      self.teams[team] = TeamClient:new(teamDto.id)
    end
  end
  private.isSynced = true
end

function TeamManager:syncPlayerTeam(team)
  self.playerTeam = team

  local playerTeamClient <const> = self.teams[team]
  if not playerTeamClient then
    print('Missing playerTeamClient')
    return
  end

  playerTeamClient:applyOutfit()

  private.isPlayerTeamSynced = true
end

---@return Team
function TeamManager:getPlayerTeam()
  return self.playerTeam
end

function TeamManager:getIsSynced()
  return private.isSynced
end

function TeamManager:getIsPlayerTeamSynced()
  return private.isPlayerTeamSynced
end

---@param team Team
---@return TeamClient?
function TeamManager:getTeamClient(team)
  return self.teams[team]
end

return TeamManager
