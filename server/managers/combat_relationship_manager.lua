local PROTECTED_PLAYER_STATE_KEY <const> = 'protectedPlayer:%d'

local CombatRelationshipManager <const> = {}

local privateState <const> = {
  protectedPlayerServerIds = {}
}

---@param serverId number
---@param isProtected boolean
local function logProtectedPlayerServerId(serverId, isProtected)
  print(('Player %d is now %s'):format(serverId, isProtected and 'protected' or 'unprotected'))
end

---@param serverId number
---@param isProtected boolean
local function syncProtectedPlayer(serverId, isProtected)
  GlobalState[PROTECTED_PLAYER_STATE_KEY:format(serverId)] = isProtected and true or nil
end

---@param serverId number
---@param isProtected boolean
local function handleProtectedPlayer(serverId, isProtected)
  local isProtectedAlready <const> = privateState.protectedPlayerServerIds[serverId] == true

  if isProtectedAlready == isProtected then
    return
  end

  privateState.protectedPlayerServerIds[serverId] = isProtected and true or nil

  logProtectedPlayerServerId(serverId, isProtected)

  syncProtectedPlayer(serverId, isProtected)
end

---@param serverId number
function CombatRelationshipManager:addProtectedPlayer(serverId)
  handleProtectedPlayer(serverId, true)
end

function CombatRelationshipManager:removeProtectedPlayer(serverId)
  handleProtectedPlayer(serverId, false)
end

return CombatRelationshipManager
