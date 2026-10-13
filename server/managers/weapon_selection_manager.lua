local weaponsConfig <const> = require 'server.configs.weapons'
local weaponSelectionConfig <const> = require 'server.configs.weapon_selection'

local WeaponSelectionManager <const> = {}

---@param weaponModel string
---@return boolean
function WeaponSelectionManager:isAvailable(weaponModel)
  if type(weaponModel) ~= 'string' then
    error('Weapon model must be a string')
  end

  for _, availableWeaponModel in ipairs(weaponsConfig.availableWeaponHashes) do
    if availableWeaponModel == weaponModel then
      return true
    end
  end

  return false
end

function WeaponSelectionManager:getAvailableWeaponHashes()
  return weaponsConfig.availableWeaponHashes
end

---@class SelectedWeapon
---@field weaponModel string
---@field isMaxAmmoEnabled boolean?

---@return SelectedWeapon?
function WeaponSelectionManager:selectWeapon(weaponModel)
  if not self:isAvailable(weaponModel) then
    return nil
  end

  ---@type SelectedWeapon
  local selectedWeapon <const> = {
    weaponModel = weaponModel,
    isMaxAmmoEnabled = weaponSelectionConfig.isMaxAmmoEnabled
  }

  return selectedWeapon
end

function WeaponSelectionManager:sync()
  ---@type WeaponSelectionDto
  local weaponSelectionData <const> = {
    availableWeaponHashes = self:getAvailableWeaponHashes()
  }
  GlobalState.weaponSelectionData = weaponSelectionData
end

return WeaponSelectionManager
