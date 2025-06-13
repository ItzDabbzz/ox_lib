--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxPlayerDead
lib.isPlayerDead = {}

--- Check if a player is dead or in last stand
---@param source number Player server ID
---@return boolean isDead Whether the player is dead or in last stand
function lib.isPlayerDead.check(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player %s not found'):format(source))
        return false
    end

    local framework = lib.framework.getFramework()

    if framework == 'esx' then
        -- ESX uses isDead in metadata
        return player.get('isDead') or false
    elseif framework == 'qb' or framework == 'qbx' then
        -- QB/QBX uses metadata for death states
        local metadata = player.PlayerData.metadata
        return (metadata.isdead or metadata.inlaststand) or false
    end

    return false
end

--- Get player death status with details
---@param source number Player server ID
---@return table status Death status information
function lib.isPlayerDead.getStatus(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return { isDead = false, inLastStand = false, error = 'Invalid source' }
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        return { isDead = false, inLastStand = false, error = 'Player not found' }
    end

    local framework = lib.framework.getFramework()
    local status = {
        isDead = false,
        inLastStand = false,
        framework = framework,
        timestamp = os.time()
    }

    if framework == 'esx' then
        status.isDead = player.get('isDead') or false
        status.inLastStand = false -- ESX doesn't typically have last stand
    elseif framework == 'qb' or framework == 'qbx' then
        local metadata = player.PlayerData.metadata
        status.isDead = metadata.isdead or false
        status.inLastStand = metadata.inlaststand or false
    end

    return status
end

--- Check if multiple players are dead
---@param sources number[] Array of player server IDs
---@return table results Results for each player
function lib.isPlayerDead.checkMultiple(sources)
    if not lib.assert.type(sources, 'table', 'Sources array') then
        return {}
    end

    local results = {}

    for i, source in ipairs(sources) do
        results[source] = {
            isDead = lib.isPlayerDead.check(source),
            status = lib.isPlayerDead.getStatus(source)
        }
    end

    return results
end

--- Get all dead players on the server
---@return table deadPlayers Array of dead player information
function lib.isPlayerDead.getAllDead()
    if not lib.framework.isAvailable() then
        return {}
    end

    local players = lib.framework.getAllPlayers()
    local deadPlayers = {}

    for _, player in pairs(players) do
        local source = type(player) == 'table' and player.source or player
        if source and lib.isPlayerDead.check(source) then
            local status = lib.isPlayerDead.getStatus(source)
            status.source = source
            status.name = GetPlayerName(source)
            deadPlayers[#deadPlayers + 1] = status
        end
    end

    return deadPlayers
end

--- Set player death status (admin function)
---@param source number Player server ID
---@param isDead boolean Death status to set
---@param reason? string Reason for status change
---@return boolean success Whether the operation was successful
function lib.isPlayerDead.set(source, isDead, reason)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    if not lib.assert.type(isDead, 'boolean', 'Death status') then
        return false
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player %s not found'):format(source))
        return false
    end

    local framework = lib.framework.getFramework()
    local success = false

    if framework == 'esx' then
        player.set('isDead', isDead)
        success = true
    elseif framework == 'qb' or framework == 'qbx' then
        player.Functions.SetMetaData('isdead', isDead)
        if not isDead then
            player.Functions.SetMetaData('inlaststand', false)
        end
        success = true
    end

    if success then
        lib.print.debug(('Set player %s death status to %s%s'):format(
            source, tostring(isDead), reason and (' - ' .. reason) or ''
        ))

        if lib.logger then
            lib.logger(source, 'player_death_status', 'Death Status Changed',
                'isDead:' .. tostring(isDead),
                'reason:' .. (reason or 'none'),
                'admin:true'
            )
        end

        -- Trigger event for other resources
        TriggerEvent('ox_lib:playerDeathStatusChanged', source, isDead, reason)
    end

    return success
end

--- Revive a player (admin function)
---@param source number Player server ID
---@param reason? string Reason for revival
---@return boolean success Whether the revival was successful
function lib.isPlayerDead.revive(source, reason)
    return lib.isPlayerDead.set(source, false, reason or 'Admin revive')
end

--- Kill a player (admin function)
---@param source number Player server ID
---@param reason? string Reason for death
---@return boolean success Whether the operation was successful
function lib.isPlayerDead.kill(source, reason)
    return lib.isPlayerDead.set(source, true, reason or 'Admin kill')
end

--- Get death statistics for the server
---@return table stats Death statistics
function lib.isPlayerDead.getStats()
    if not lib.framework.isAvailable() then
        return { error = 'Framework not available' }
    end

    local players = lib.framework.getAllPlayers()
    local stats = {
        totalPlayers = #players,
        deadPlayers = 0,
        alivePlayers = 0,
        inLastStand = 0,
        deadPlayersList = {},
        timestamp = os.time()
    }

    for _, player in pairs(players) do
        local source = type(player) == 'table' and player.source or player
        if source then
            local status = lib.isPlayerDead.getStatus(source)

            if status.isDead then
                stats.deadPlayers = stats.deadPlayers + 1
                stats.deadPlayersList[#stats.deadPlayersList + 1] = {
                    source = source,
                    name = GetPlayerName(source),
                    inLastStand = status.inLastStand
                }
            else
                stats.alivePlayers = stats.alivePlayers + 1
            end

            if status.inLastStand then
                stats.inLastStand = stats.inLastStand + 1
            end
        end
    end

    return stats
end

--- Register callback for client requests
lib.callback.register('ox_lib:isPlayerDead', function(source)
    return lib.isPlayerDead.check(source)
end)

lib.callback.register('ox_lib:getPlayerDeathStatus', function(source)
    return lib.isPlayerDead.getStatus(source)
end)

--- Export the main function for backwards compatibility
---@param source number Player server ID
---@return boolean isDead Whether the player is dead
function IsPlayerDead(source)
    return lib.isPlayerDead.check(source)
end

--- Wait for framework to be available
lib.waitFor(function()
    return lib.framework.isAvailable()
end, 'Framework not available for player death system', 30000)

return lib.isPlayerDead
