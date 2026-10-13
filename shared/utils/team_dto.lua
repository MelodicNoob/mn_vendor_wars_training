local EnumUtils <const> = require 'shared.utils.enum'
local Team <const> = require 'shared.enums.team'

local TeamDtoUtils <const> = {}

---@param dto TeamDto
function TeamDtoUtils.isValid(dto)
  if not dto.id or not EnumUtils.isValidEnumValue(Team, dto.id) then
    return false
  end

  return true
end

return TeamDtoUtils
