local TeamEnum = require 'shared.enums.team'

---@class TeamClass : OxClass
---@field id Team
---@field serverIds integer[]
local TeamClass <const> = lib.class('Team')

---@param id Team
function TeamClass:constructor(id)
  self.id = id
  self.serverIds = {}
end

---@return TeamDto
function TeamClass:toDto()
  return {
    id = self.id,
  }
end

return TeamClass
