--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxFramework
lib.framework = {}

local detectedFramework = nil
local frameworkObject = nil
local playerCache = {}

--- Framework detection and initialization
local function detectAndInitFramework()
    if detectedFramework then
        return detectedFramework, frameworkObject
    end

    -- Check for QBX (check first as it might have qb-core as dependency)
    if GetResourceState('qbx_core') == 'started' then
        detectedFramework = 'qbx'
        frameworkObject = exports.qbx_core
        lib.print.info('Framework detected: QBX Core')
        return detectedFramework, frameworkObject
    end

    -- Check for QBCore
    if GetResourceState('qb-core') == 'started' then
        detectedFramework = 'qb'
        if QBCore then
            frameworkObject = QBCore
        else
            frameworkObject = exports['qb-core']:GetCoreObject()
        end
        lib.print.info('Framework detected: QBCore')
        return detectedFramework, frameworkObject
    end

    -- Check for ESX
    if GetResourceState('es_extended') == 'started' then
        detectedFramework = 'esx'
        if ESX then
            frameworkObject = ESX
        else
            frameworkObject = exports['es_extended']:getSharedObject()
        end
        lib.print.info('Framework detected: ESX')
        return detectedFramework, frameworkObject
    end

    lib.print.warn('No supported framework detected')
    return nil, nil
end

--- Get the detected framework name
---@return string? framework The framework name ('esx', 'qb', 'qbx')
function lib.framework.getFramework()
    local framework, _ = detectAndInitFramework()
    return framework
end

--- Get the framework object
---@return table? frameworkObj The framework object
function lib.framework.getFrameworkObject()
    local _, obj = detectAndInitFramework()
    return obj
end

--- Get a player object from any framework
---@param source number Player source ID
---@return table? player The player object
function lib.framework.getPlayer(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    -- Check cache first
    local cacheKey = ('player_%d'):format(source)
    if playerCache[cacheKey] then
        return playerCache[cacheKey]
    end

    local framework, frameworkObj = detectAndInitFramework()
    if not framework or not frameworkObj then
        return nil
    end

    local player = nil

    if framework == 'esx' then
        player = frameworkObj.GetPlayerFromId(source)
    elseif framework == 'qb' then
        player = frameworkObj.Functions.GetPlayer(source)
    elseif framework == 'qbx' then
        player = frameworkObj:GetPlayer(source)
    end

    -- Cache the player for 5 seconds
    if player then
        playerCache[cacheKey] = player
        SetTimeout(5000, function()
            playerCache[cacheKey] = nil
        end)
    end

    return player
end

--- Get all online players
---@return table players Array of player objects
function lib.framework.getAllPlayers()
    local framework, frameworkObj = detectAndInitFramework()
    if not framework or not frameworkObj then
        return {}
    end

    local players = {}

    if framework == 'esx' then
        players = frameworkObj.GetPlayers()
    elseif framework == 'qb' then
        players = frameworkObj.Functions.GetPlayers()
    elseif framework == 'qbx' then
        for _, player in pairs(frameworkObj:GetPlayers()) do
            players[#players + 1] = player
        end
    end

    return players or {}
end

--- Get player identifier (license, steam, etc.)
---@param source number Player source ID
---@param identifierType? string Type of identifier ('license', 'steam', 'discord', etc.)
---@return string? identifier The player identifier
function lib.framework.getPlayerIdentifier(source, identifierType)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    identifierType = identifierType or 'license'

    local player = lib.framework.getPlayer(source)
    if not player then
        return nil
    end

    local framework = lib.framework.getFramework()

    if framework == 'esx' then
        return player.getIdentifier and player.getIdentifier() or player.identifier
    elseif framework == 'qb' or framework == 'qbx' then
        if player.PlayerData and player.PlayerData.license then
            if identifierType == 'license' then
                return player.PlayerData.license
            elseif identifierType == 'steam' then
                return player.PlayerData.steam
            elseif identifierType == 'discord' then
                return player.PlayerData.discord
            end
        end
    end

    -- Fallback to native function
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and identifier:find(identifierType .. ':') then
            return identifier
        end
    end

    return nil
end

--- Check if framework is available
---@return boolean available
function lib.framework.isAvailable()
    local framework, _ = detectAndInitFramework()
    return framework ~= nil
end

--- Refresh framework detection
---@return boolean success
function lib.framework.refresh()
    detectedFramework = nil
    frameworkObject = nil
    playerCache = {}

    local framework, _ = detectAndInitFramework()
    return framework ~= nil
end

--- Get framework statistics
---@return table stats
function lib.framework.getStats()
    local framework, _ = detectAndInitFramework()

    local stats = {
        framework = framework,
        available = framework ~= nil,
        cachedPlayers = 0,
        onlinePlayers = 0
    }

    -- Count cached players
    for _ in pairs(playerCache) do
        stats.cachedPlayers = stats.cachedPlayers + 1
    end

    -- Count online players
    if framework then
        local players = lib.framework.getAllPlayers()
        stats.onlinePlayers = #players
    end

    return stats
end

-- Clear player cache when they disconnect
AddEventHandler('playerDropped', function()
    local source = source
    local cacheKey = ('player_%d'):format(source)
    playerCache[cacheKey] = nil
end)

-- Initialize framework detection
CreateThread(function()
    Wait(1000) -- Wait for frameworks to load
    detectAndInitFramework()
end)

return lib.framework
