local TeamConfigUtils <const> = require 'client.utils.configs.teams'
local ClothingUtils <const> = require 'client.utils.clothing'

---@class TeamClient : OxClass
---@field id Team
---@field outfit table?
local TeamClient <const> = lib.class('TeamClient')

---@param id Team
function TeamClient:constructor(id)
  self.id = id
end

function TeamClient:applyOutfit()
  local outfit <const> = TeamConfigUtils.getOutfit(self.id)

  if not outfit then
    error(('Missing outfit for team %d'):format(self.id))
  end

  for k, v in pairs(outfit) do
    if k == 'components' then
      for _, component in pairs(v) do
        ClothingUtils.applyComponent(component)
      end
    end
  end
end

return TeamClient
