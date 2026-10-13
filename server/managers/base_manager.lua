local Base <const> = require 'server.classes.base'
local basesConfig <const> = require 'server.configs.bases'

local BaseManager <const> = {
    bases = {},
}

function BaseManager:buildBaseData()
    local dtos <const> = {}

    for team, base in pairs(self.bases) do
        dtos[team] = base:toDto()
    end

    return dtos
end

function BaseManager:sync()
    GlobalState.baseData = self:buildBaseData()
    print('Synced baseData to GlobalState')
end

function BaseManager:setUp()
    for team, baseConfig in pairs(basesConfig) do
        local base = Base:new(team, baseConfig.coords, baseConfig.spawnCoords, baseConfig.vehicleSpawnCoords)
        self.bases[team] = base
    end

    self:sync()
end

function BaseManager:getBases()
    return self.bases
end

return BaseManager
