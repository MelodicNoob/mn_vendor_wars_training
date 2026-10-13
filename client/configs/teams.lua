local TeamEnum <const> = require 'shared.enums.team'

return {
  TeamOutfits = {
    [TeamEnum.NONE] = {
      male = {
        components = {
          {
            id = 11,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 21,
            textureId = 9,
            paletteId = 0,
          },
          {
            id = 4,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 6,
            textureId = 9,
            paletteId = 0,
          },
          {
            id = 8,
            collection = '',
            drawableId = 15,
            textureId = 0,
            paletteId = 0,
          },
          {
            id = 3,
            collection = '',
            drawableId = 4,
            textureId = 0,
            paletteId = 0,
          },
          {
            id = 6,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 5,
            textureId = 9,
            paletteId = 0,
          }
        },
        props = {},
      }
    },
    [TeamEnum.ATTACKER] = {
      male = {
        components = {
          {
            id = 11,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 21,
            textureId = 5,
            paletteId = 0,
          },
          {
            id = 4,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 6,
            textureId = 5,
            paletteId = 0,
          },
          {
            id = 8,
            collection = '',
            drawableId = 15,
            textureId = 0,
            paletteId = 0,
          },
          {
            id = 3,
            collection = '',
            drawableId = 4,
            textureId = 0,
            paletteId = 0,
          },
          {
            id = 6,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 5,
            textureId = 5,
            paletteId = 0,
          }
        },
        props = {},
      }
    },
    [TeamEnum.DEFENDER] = {
      male = {
         components = {
          {
            id = 11,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 21,
            textureId = 3,
            paletteId = 0,
          },
          {
            id = 4,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 6,
            textureId = 3,
            paletteId = 0,
          },
          {
            id = 8,
            collection = '',
            drawableId = 15,
            textureId = 0,
            paletteId = 0,
          },
          {
            id = 3,
            collection = '',
            drawableId = 4,
            textureId = 0,
            paletteId = 0,
          },
           {
            id = 6,
            collection = 'mp_m_bikerdlc_01',
            drawableId = 5,
            textureId = 3,
            paletteId = 0,
          }
        },
        props = {},
      }
    }
  }
}
