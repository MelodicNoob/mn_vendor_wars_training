local Team = require('shared.enums.team')
local TeamClass = require 'server.classes.team'
local EnumUtils <const> = require 'shared.utils.enum'

---@class TeamManager
---@field teams table<Team, TeamClass>
local TeamManager <const> = {
    teams = {},
}

function TeamManager:removePlayerFromAnyTeam(serverId)
    for k, v in pairs(self.teams) do
        local indexOfServerId = 0

        for index, data in ipairs(self.teams[k].serverIds) do
            if data == serverId then
                indexOfServerId = index
            end
        end

        if indexOfServerId > 0 then
            table.remove(self.teams[k].serverIds, indexOfServerId)
            print(('Removed server id of (%d) from team %d'):format(serverId, k))
            return -- Removed the server id from team, no need to continue
        end
    end
end

function TeamManager:isPlayerInTeam(serverId, team)
    if not self.teams[team] then
        print(('Invalid team %s'):format(tostring(team)))
        return false
    end

    for index, data in ipairs(self.teams[team].serverIds) do
        if data == serverId then
            return true
        end
    end

    return false
end

function TeamManager:addPlayerToTeam(serverId, team)
  if not self.teams[team] then
      print(('Invalid team %s'):format(tostring(team)))
      return
  end

  if self:isPlayerInTeam(serverId, team) then
      print(('Player\'s server id of (%d) is already on team %d'):format(serverId, team))
      return
  end

  self:removePlayerFromAnyTeam(serverId)

  table.insert(self.teams[team].serverIds, serverId)
  print(('Added server id of (%d) to team %d'):format(serverId, team))
end

---@param serverId number
function TeamManager:findTeam(serverId)
  if type(serverId) ~= 'number' then
    error('Server id must be a number')
  end

  for k, v in pairs(self.teams) do
    for index, teamServerId in ipairs(v.serverIds) do
      if teamServerId == serverId then
        return k
      end
    end
  end

  return Team.NONE
end

function TeamManager:syncPlayer(serverId)
  Player(serverId).state.team = self:findTeam(serverId)
end

function TeamManager:sync()
  ---@type TeamData
  local dtos <const> = {}

  for key, team in pairs(self.teams) do
    dtos[key] = team:toDto()
  end

  GlobalState.teamData = dtos
  print('Synced teamData to GlobalState')
end

function TeamManager:setUp()
  for _, v in pairs(Team) do
    self.teams[v] = TeamClass:new(v)
  end

  self:sync()
end

function TeamManager:getTeams()
  return self.teams
end

---@param team Team
---@return number[] 'Team\'s net ids'
function TeamManager:getTeamNetIds(team)
  if not EnumUtils.isValidEnumValue(Team, team) then
    error(('Invalid team enum: %s'):format(team))
  end

  if not self.teams[team] then
    error(('Missing team %s'):format(team))
  end

  return self.teams[team].serverIds
end

return TeamManager
