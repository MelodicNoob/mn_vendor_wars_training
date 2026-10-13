local Team <const> = require 'shared.enums.team'

return {
  [Team.NONE] = {
    coords = vector3(93.557716, 66.811317, 73.416702),
    spawnCoords = vector3(93.557716, 66.811317, 73.416702),
  },
  [Team.ATTACKER] = {
    coords = vector3(-82.834244, 303.222168, 106.918610),
    spawnCoords = vector3(-82.834244, 303.222168, 106.918610),
    vehicleSpawnCoords = vector4(-77.754723, 293.389862, 106.178902, 230.0),
    vehicleSelectionCoords = vector3(-87.863792, 297.490173, 106.738884),
    vehicle = {
      colour = {
        primary = 27,
        secondary = 0,
      },
    },
  },
  [Team.DEFENDER] = {
    coords = vector3(976.773682, -1487.673950, 31.434513),
    spawnCoords = vector3(976.773682, -1487.673950, 31.434513),
    vehicleSelectionCoords = vector3(971.096008, -1491.103149, 31.245846),
    vehicleSpawnCoords = vector4(969.832031, -1479.543335, 31.158430, 0.0),
    vehicle = {
      colour = {
        primary = 64,
        secondary = 0,
      },
    },
  },
}
