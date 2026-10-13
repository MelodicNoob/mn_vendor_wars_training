local TeamManager <const> = require 'client.managers.team_manager'

local BaseProtectionManager <const> = {}

---@param base Base
function BaseProtectionManager:onPlayerEnter(base)
  local playerTeam <const> = TeamManager:getPlayerTeam()

  if base.team ~= playerTeam then
    print('Ignoring base enter event for a non-team base')
    return
  end

  cache.ped = cache.ped or PlayerPedId()
  SetEntityProofs(
    cache.ped,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  )
end

---@param base Base
function BaseProtectionManager:onPlayerLeave(base)
  local playerTeam <const> = TeamManager:getPlayerTeam()

  if base.team ~= playerTeam then
    print('Ignoring base leave event for a non-team base')
    return
  end

  cache.ped = cache.ped or PlayerPedId()
  SetEntityProofs(
    cache.ped,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  )
end

return BaseProtectionManager
