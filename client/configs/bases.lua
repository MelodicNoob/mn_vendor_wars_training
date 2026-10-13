local Team <const> = require 'shared.enums.team'

return {
  [Team.NONE] = {
    blip = {
      colour = 0,
    },
  },
  [Team.ATTACKER] = {
    blip = {
      colour = 1,
    },
  },
  [Team.DEFENDER] = {
    blip = {
      colour = 3,
    },
  },
  baseZoneRadius = 80.0
}
