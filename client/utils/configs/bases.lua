local baseConfigs <const> = require 'client.configs.bases'

local baseConfigUtils <const> = {}

function baseConfigUtils.getTeamBaseBlipColour(team)
  return baseConfigs[team].blip.colour or 0
end

function baseConfigUtils.getBaseZoneRadius()
  return baseConfigs.baseZoneRadius
end

return baseConfigUtils
