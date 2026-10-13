local Team <const> = require 'shared.enums.team'

local UNLIMITED <const> = -1

return {
  availableVehicles = {
    rebla = {
      limit = UNLIMITED,
    },
  },
  teamAvailableVehicles = {
    [Team.DEFENDER] = {
      benson = {
        limit = 5,
      }
    },
  },
}
