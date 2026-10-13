local ClothingUtils <const> = {}

---@param ped number?
function ClothingUtils.applyComponent(component, ped)
    ped = ped or cache.ped

    if not DoesEntityExist(ped) then
        ped = PlayerPedId()
    end

    if not DoesEntityExist(ped) then
        return -- For some unknown reason the player's ped does not exist
    end

    component.paletteId = component.paletteId or 0

    if component.collection then
        SetPedCollectionComponentVariation(ped, component.id, component.collection, component.drawableId, component.textureId, component.paletteId)
        return
    end

    SetPedComponentVariation(ped, component.id, component.drawableId, component.textureId, component.paletteId)
end

return ClothingUtils
