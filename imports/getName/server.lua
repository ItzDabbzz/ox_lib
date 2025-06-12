--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxName
lib.name = {}

local nameCache = {}

--- Extracts the full name from a player object, handling all supported frameworks
---@param player table The player object
---@return string? fullName The player's full name, or nil if not available
local function extractFullName(player)
    if not lib.assert.notNil(player, 'Player object') then
        return nil
    end

    local framework = lib.framework.getFramework()
    local firstName, lastName

    if framework == 'qb' or framework == 'qbx' then
        -- QB/QBX: player.PlayerData.charinfo.{firstname, lastname}
        if player.PlayerData and player.PlayerData.charinfo then
            firstName = player.PlayerData.charinfo.firstname or ""
            lastName = player.PlayerData.charinfo.lastname or ""
        end
    elseif framework == 'esx' then
        -- ESX: Try different methods
        if player.get and type(player.get) == 'function' then
            firstName = player.get('firstName') or ""
            lastName = player.get('lastName') or ""
        elseif player.firstname and player.lastname then
            firstName = player.firstname or ""
            lastName = player.lastname or ""
        end
    end

    if firstName and lastName and (firstName ~= "" or lastName ~= "") then
        return ('%s %s'):format(firstName, lastName):gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    end

    return nil
end

--- Extracts the first name from a player object
---@param player table The player object
---@return string? firstName The player's first name, or nil if not available
local function extractFirstName(player)
    if not lib.assert.notNil(player, 'Player object') then
        return nil
    end

    local framework = lib.framework.getFramework()

    if framework == 'qb' or framework == 'qbx' then
        if player.PlayerData and player.PlayerData.charinfo then
            return player.PlayerData.charinfo.firstname
        end
    elseif framework == 'esx' then
        if player.get and type(player.get) == 'function' then
            return player.get('firstName')
        elseif player.firstname then
            return player.firstname
        end
    end

    return nil
end

--- Extracts the last name from a player object
---@param player table The player object
---@return string? lastName The player's last name, or nil if not available
local function extractLastName(player)
    if not lib.assert.notNil(player, 'Player object') then
        return nil
    end

    local framework = lib.framework.getFramework()

    if framework == 'qb' or framework == 'qbx' then
        if player.PlayerData and player.PlayerData.charinfo then
            return player.PlayerData.charinfo.lastname
        end
    elseif framework == 'esx' then
        if player.get and type(player.get) == 'function' then
            return player.get('lastName')
        elseif player.lastname then
            return player.lastname
        end
    end

    return nil
end

--- Gets the full name of a player by their server ID
---@param source number The player's server ID
---@return string? fullName The player's full name, or nil if not found
function lib.name.getFullName(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    -- Check cache first
    local cacheKey = ('fullname_%d'):format(source)
    if nameCache[cacheKey] then
        return nameCache[cacheKey]
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player not found for source: %s'):format(source))
        return nil
    end

    local fullName = extractFullName(player)
    if not fullName then
        lib.print.warn(('Full name not found for source: %s'):format(source))
        return nil
    end

    -- Cache the result for 30 seconds
    nameCache[cacheKey] = fullName
    SetTimeout(30000, function()
        nameCache[cacheKey] = nil
    end)

    return fullName
end

--- Gets the first name of a player by their server ID
---@param source number The player's server ID
---@return string? firstName The player's first name, or nil if not found
function lib.name.getFirstName(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    -- Check cache first
    local cacheKey = ('firstname_%d'):format(source)
    if nameCache[cacheKey] then
        return nameCache[cacheKey]
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player not found for source: %s'):format(source))
        return nil
    end

    local firstName = extractFirstName(player)
    if not firstName then
        lib.print.warn(('First name not found for source: %s'):format(source))
        return nil
    end

    -- Cache the result for 30 seconds
    nameCache[cacheKey] = firstName
    SetTimeout(30000, function()
        nameCache[cacheKey] = nil
    end)

    return firstName
end

--- Gets the last name of a player by their server ID
---@param source number The player's server ID
---@return string? lastName The player's last name, or nil if not found
function lib.name.getLastName(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    -- Check cache first
    local cacheKey = ('lastname_%d'):format(source)
    if nameCache[cacheKey] then
        return nameCache[cacheKey]
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player not found for source: %s'):format(source))
        return nil
    end

    local lastName = extractLastName(player)
    if not lastName then
        lib.print.warn(('Last name not found for source: %s'):format(source))
        return nil
    end

    -- Cache the result for 30 seconds
    nameCache[cacheKey] = lastName
    SetTimeout(30000, function()
        nameCache[cacheKey] = nil
    end)

    return lastName
end

--- Gets all name components for a player
---@param source number The player's server ID
---@return table? nameData Table containing firstName, lastName, and fullName, or nil if not found
function lib.name.getAllNames(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    -- Check cache first
    local cacheKey = ('allnames_%d'):format(source)
    if nameCache[cacheKey] then
        return nameCache[cacheKey]
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player not found for source: %s'):format(source))
        return nil
    end

    local firstName = extractFirstName(player)
    local lastName = extractLastName(player)
    local fullName = extractFullName(player)

    if not firstName and not lastName and not fullName then
        lib.print.warn(('No name data found for source: %s'):format(source))
        return nil
    end

    local nameData = {
        firstName = firstName,
        lastName = lastName,
        fullName = fullName or (firstName and lastName and ('%s %s'):format(firstName, lastName)) or nil
    }

    -- Cache the result for 30 seconds
    nameCache[cacheKey] = nameData
    SetTimeout(30000, function()
        nameCache[cacheKey] = nil
    end)

    return nameData
end

--- Checks if a player has valid name data
---@param source number The player's server ID
---@return boolean hasName Whether the player has name data
function lib.name.hasName(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        return false
    end

    local fullName = extractFullName(player)
    return fullName ~= nil and fullName ~= "" and fullName ~= " "
end

--- Gets the detected framework
---@return string? framework The detected framework name
function lib.name.getFramework()
    return lib.framework.getFramework()
end

--- Refreshes framework detection (useful if frameworks load after this resource)
---@return string? framework The newly detected framework
function lib.name.refreshFramework()
    nameCache = {} -- Clear name cache when framework changes
    return lib.framework.refresh() and lib.framework.getFramework() or nil
end

--- Gets statistics about name system usage
---@return table stats Statistics about the name system
function lib.name.getStats()
    local frameworkStats = lib.framework.getStats()

    local stats = {
        framework = frameworkStats.framework,
        frameworkAvailable = frameworkStats.available,
        cachedNames = 0,
        onlinePlayers = frameworkStats.onlinePlayers,
        frameworkCachedPlayers = frameworkStats.cachedPlayers
    }

    -- Count cached names
    for _ in pairs(nameCache) do
        stats.cachedNames = stats.cachedNames + 1
    end

    return stats
end

--- Batch get names for multiple players
---@param sources number[] Array of player source IDs
---@return table results Table mapping source to name data
function lib.name.getBatchNames(sources)
    if not lib.assert.type(sources, 'table', 'Sources array') then
        return {}
    end

    local results = {}

    for _, source in ipairs(sources) do
        if type(source) == 'number' then
            results[source] = lib.name.getAllNames(source)
        end
    end

    return results
end

--- Clear name cache for a specific player
---@param source number The player's server ID
function lib.name.clearCache(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return
    end

    local keys = {
        ('fullname_%d'):format(source),
        ('firstname_%d'):format(source),
        ('lastname_%d'):format(source),
        ('allnames_%d'):format(source)
    }

    for _, key in ipairs(keys) do
        nameCache[key] = nil
    end
end

--- Clear all name cache
function lib.name.clearAllCache()
    nameCache = {}
    lib.print.info('Name cache cleared')
end

--- Preload names for all online players (useful for performance)
---@return number count Number of names preloaded
function lib.name.preloadNames()
    local players = lib.framework.getAllPlayers()
    local count = 0

    for _, player in ipairs(players) do
        local source = player.source or (type(player) == 'number' and player)
        if source then
            local nameData = lib.name.getAllNames(source)
            if nameData then
                count = count + 1
            end
        end
    end

    lib.print.info(('Preloaded names for %d players'):format(count))
    return count
end

--- Register callbacks for client-side name requests
lib.callback.register('ox_lib:getName:getFullName', function(source)
    return lib.name.getFullName(source)
end)

lib.callback.register('ox_lib:getName:getFirstName', function(source)
    return lib.name.getFirstName(source)
end)

lib.callback.register('ox_lib:getName:getLastName', function(source)
    return lib.name.getLastName(source)
end)

lib.callback.register('ox_lib:getName:getAllNames', function(source)
    return lib.name.getAllNames(source)
end)

lib.callback.register('ox_lib:getName:hasName', function(source)
    return lib.name.hasName(source)
end)

lib.callback.register('ox_lib:getName:getStats', function(source)
    return lib.name.getStats()
end)

-- Clear name cache when player disconnects
AddEventHandler('playerDropped', function()
    local source = source
    lib.name.clearCache(source)
end)

-- Initialize and preload names after frameworks load
CreateThread(function()
    Wait(2000) -- Wait for frameworks to fully initialize

    if lib.framework.isAvailable() then
        lib.print.info('Name system initialized with framework: ' .. lib.framework.getFramework())

        -- Optionally preload names for better performance
        SetTimeout(5000, function()
            lib.name.preloadNames()
        end)
    else
        lib.print.warn('Name system initialized but no framework detected')
    end
end)

return lib.name
