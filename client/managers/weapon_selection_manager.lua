local WEAPON_SELECTION_MENU_ID <const> = 'WEAPON_SELECTION_MENU'

local private <const> = {}

local WeaponSelectionManager <const> = {}

---@param weaponModel string
local function selectedWeapon(weaponModel)
  if type(weaponModel) ~= 'string' then
    print('You must provide a weapon model')
    return
  end

   lib.callback('mn_vendor_wars_training:server:weaponSelected', false, function(selectedWeapon)
    if selectedWeapon and selectedWeapon.weaponModel then
      print(('You have selected weapon with the model of %s'):format(selectedWeapon.weaponModel))

      if type(selectedWeapon.isMaxAmmoEnabled) == 'boolean' then
        print(('Selected %s weapon model, and is max ammo enabled? %s'):format(selectedWeapon.weaponModel, selectedWeapon.isMaxAmmoEnabled))
      end

      local weaponHash <const> = joaat(selectedWeapon.weaponModel)

      if selectedWeapon.isMaxAmmoEnabled then
        local _ <const>, maxAmmo <const> =  GetMaxAmmo(
          cache.ped --[[ Ped ]], 
          weaponHash --[[ Hash ]]
        )

        GiveWeaponToPed(
          cache.ped, 
          weaponHash --[[ Hash ]], 
          maxAmmo --[[ integer ]], 
          false --[[ boolean ]], 
          true --[[ boolean ]]
        )
      end
    else
      print(('Cannot select a weapon with the model of %s'):format(weaponModel))
    end
  end, weaponModel)
end

---@param weaponHashes string[]
local function createWeaponSelectionMenu(weaponHashes)
  local menuOptions <const> = {}

  for i = 1, #weaponHashes do
    local weaponHash <const> = weaponHashes[i]
    if string.len(weaponHash) > 0 then
      menuOptions[#menuOptions + 1] = {
        label = weaponHash,
        args = weaponHash
      }
    end
  end

  local menuData <const> = {
    id = WEAPON_SELECTION_MENU_ID,
    title = 'Select a weapon',
    options = menuOptions
  }

  local function onMenuItemSelected(selected, scrollIndex, args)
    print(selected, scrollIndex, args)
    WeaponSelectionManager:selectedWeapon(args)
  end

  lib.registerMenu(menuData, onMenuItemSelected)
end

---@param weaponSelectionData WeaponSelectionDto
function WeaponSelectionManager:sync(weaponSelectionData)
  if type(weaponSelectionData.availableWeaponHashes) ~= 'table' then
    error('Invalid data type for availableWeaponHashes: expected a table')
  end

  print(('#weaponSelectionData.availableWeaponHashes %d'):format(#weaponSelectionData.availableWeaponHashes))

  if #weaponSelectionData.availableWeaponHashes > 0 and private.availableWeaponHashes == nil then
    private.availableWeaponHashes = {}
  end

  local availableWeaponHashes <const> = {}
  for i = 1, #weaponSelectionData.availableWeaponHashes do
    local availableHash <const> = weaponSelectionData.availableWeaponHashes[i]
    print(availableHash)
    availableWeaponHashes[#availableWeaponHashes + 1] = availableHash
  end

  createWeaponSelectionMenu(availableWeaponHashes)

  -- if private.availableWeaponHashes == nil then
  --   private.availableWeaponHashes = {}
  -- end

  -- local hasSyncedAvailableWeaponHash = false

  -- ---@type table<string, boolean>
  -- local matchingWeaponHashes <const> = {}

  -- for _, availableWeaponHash in ipairs(weaponSelectionData.availableWeaponHashes) do
  --   if type(availableWeaponHash) ~= 'string' then
  --     error('Expected type of string for %s available hash'):format(tostring(availableWeaponHash))
  --   end

  --   if #private.availableWeaponHashes > 0 then
  --     for index, privateAvailableWeaponHash in ipairs(private.availableWeaponHashes) do

  --       if string.len(privateAvailableWeaponHash) > 0 then
  --         if not matchingWeaponHashes[privateAvailableWeaponHash] then
  --           matchingWeaponHashes[privateAvailableWeaponHash] = false
  --         end

  --         if privateAvailableWeaponHash == availableWeaponHash then
  --           matchingWeaponHashes[privateAvailableWeaponHash] = true

  --           hasSyncedAvailableWeaponHash = true
  --           break
  --         end
  --       end
  --     end

  --     local indexesToRemove <const> = {}

  --     for matchingWeaponHashKey, _ in pairs(matchingWeaponHashes) do
  --       for weaponHashIndex, weaponHash in ipairs(private.availableWeaponHashes) do
  --         if weaponHash == matchingWeaponHashKey then
  --           indexesToRemove[#indexesToRemove + 1] = weaponHashIndex
  --         end
  --       end
  --     end

  --     for i=1, #indexesToRemove do
  --       local indexToRemove <const> = indexesToRemove[i]
  --       private.availableWeaponHashes[indexToRemove] = ''
  --     end

  --     if not hasSyncedAvailableWeaponHash then
  --       private.availableWeaponHashes[#private.availableWeaponHashes + 1] = availableWeaponHash
  --     end
  --   else
  --     private.availableWeaponHashes[#private.availableWeaponHashes + 1] = availableWeaponHash
  --   end
  -- end

  -- for i=1, #private.availableWeaponHashes do
  --   print(private.availableWeaponHashes[i])
  -- end
end

---@return string[] | nil
function WeaponSelectionManager:getAvailableWeapons()
  return private.availableWeaponHashes
end

function WeaponSelectionManager:showMenu()
  lib.showMenu(WEAPON_SELECTION_MENU_ID)
end

---@param weaponModel string
function WeaponSelectionManager:selectedWeapon(weaponModel)
  selectedWeapon(weaponModel)
end

return WeaponSelectionManager
