local teamsConfig <const> = require 'client.configs.teams'

local TeamConfigUtils <const> = {}

---@param team Team
function TeamConfigUtils.getOutfit(team)
  if not teamsConfig.TeamOutfits then
    return nil
  end

  local teamOutfits <const> = teamsConfig.TeamOutfits
  for teamKey, teamOutfit in pairs(teamOutfits) do
    if teamKey == team then
      if teamOutfit.male then
        return teamOutfit.male
      end
    end
  end

  return nil
end

return TeamConfigUtils
