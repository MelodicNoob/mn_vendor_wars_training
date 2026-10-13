local Team <const> = require 'shared.enums.team'

local BaseLockManager <const> = require 'server.managers.base_lock_manager'

local InitialPhase <const> = {}

function InitialPhase:onEnter()
    print('Entered the initial phase')

    if not BaseLockManager:isTeamLocked(Team.NONE) then
        BaseLockManager:lockTeam(Team.NONE)
    end

    if not BaseLockManager:isTeamLocked(Team.ATTACKER) then
        BaseLockManager:lockTeam(Team.ATTACKER)
    end

    if not BaseLockManager:isTeamLocked(Team.DEFENDER) then
        BaseLockManager:lockTeam(Team.DEFENDER)
    end
end

return InitialPhase
