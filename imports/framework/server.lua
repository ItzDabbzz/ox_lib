--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxFramework
local frameworkModule = {}

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

    -- Check for legacy ESX
    if GetResourceState('esx_core') == 'started' then
        detectedFramework = 'esx'
        frameworkObject = exports['esx_core']:getSharedObject()
        lib.print.info('Framework detected: ESX Legacy')
        return detectedFramework, frameworkObject
    end

    -- Check for other ESX variants
    local esxVariants = { 'esx-legacy', 'esx_legacy', 'extendedmode' }
    for _, variant in ipairs(esxVariants) do
        if GetResourceState(variant) == 'started' then
            detectedFramework = 'esx'
            frameworkObject = exports[variant]:getSharedObject()
            lib.print.info(('Framework detected: %s'):format(variant))
            return detectedFramework, frameworkObject
        end
    end

    lib.print.warn('No supported framework detected')
    return nil, nil
end

--- Get the detected framework name
---@return string? framework The framework name ('esx', 'qb', 'qbx')
function frameworkModule.getFramework()
    local framework, _ = detectAndInitFramework()
    return framework
end

--- Get the framework name (alias for getFramework)
---@return string? name The framework name ('esx', 'qb', 'qbx')
function frameworkModule.getName()
    return frameworkModule.getFramework()
end

--- Get the framework object
---@return table? frameworkObj The framework object
function frameworkModule.getFrameworkObject()
    local _, obj = detectAndInitFramework()
    return obj
end

--- Get the shared object for the framework (alias for getFrameworkObject)
---@return table? sharedObject The framework's shared object
function frameworkModule.getSharedObject()
    return frameworkModule.getFrameworkObject()
end

--- Get a player object from any framework
---@param source number Player source ID
---@return table? player The player object
function frameworkModule.getPlayer(source)
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
function frameworkModule.getAllPlayers()
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
function frameworkModule.getPlayerIdentifier(source, identifierType)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    identifierType = identifierType or 'license'

    local player = frameworkModule.getPlayer(source)
    if not player then
        return nil
    end

    local framework = frameworkModule.getFramework()

    if framework == 'esx' then
        if identifierType == 'license' then
            return player.getIdentifier and player.getIdentifier() or player.identifier
        else
            return player.getIdentifier(identifierType)
        end
    elseif framework == 'qb' or framework == 'qbx' then
        if player.PlayerData then
            if identifierType == 'license' then
                return player.PlayerData.license
            elseif identifierType == 'steam' then
                return player.PlayerData.steam
            elseif identifierType == 'discord' then
                return player.PlayerData.discord
            elseif identifierType == 'citizenid' then
                return player.PlayerData.citizenid
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

--- Checks if a player has a specific job
---@param source number Player source ID
---@param jobName string Job name to check
---@param grade? number Minimum grade required
---@return boolean hasJob Whether the player has the job
function frameworkModule.hasJob(source, jobName, grade)
    local player = frameworkModule.getPlayer(source)
    if not player then
        return false
    end

    local framework = frameworkModule.getFramework()

    if framework == 'esx' then
        local playerJob = player.getJob()
        if not playerJob or playerJob.name ~= jobName then
            return false
        end

        if grade and playerJob.grade < grade then
            return false
        end

        return true
    elseif framework == 'qb' or framework == 'qbx' then
        local playerJob = player.PlayerData.job
        if not playerJob or playerJob.name ~= jobName then
            return false
        end

        if grade and playerJob.grade.level < grade then
            return false
        end

        return true
    end

    return false
end

--- Gets the player's current job
---@param source number Player source ID
---@return table? job Job information or nil if not found
function frameworkModule.getPlayerJob(source)
    local player = frameworkModule.getPlayer(source)
    if not player then
        return nil
    end

    local framework = frameworkModule.getFramework()

    if framework == 'esx' then
        return player.getJob()
    elseif framework == 'qb' or framework == 'qbx' then
        return player.PlayerData.job
    end

    return nil
end

--- Check if framework is available
---@return boolean available
function frameworkModule.isAvailable()
    local framework, _ = detectAndInitFramework()
    return framework ~= nil
end

--- Refresh framework detection
---@return boolean success
function frameworkModule.refresh()
    detectedFramework = nil
    frameworkObject = nil
    playerCache = {}

    local framework, _ = detectAndInitFramework()
    return framework ~= nil
end

--- Get framework statistics
---@return table stats
function frameworkModule.getStats()
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
        local players = frameworkModule.getAllPlayers()
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

-- Expose framework name for backwards compatibility
frameworkModule.name = detectedFramework

-- Update the name property when framework is detected
local originalDetect = detectAndInitFramework
detectAndInitFramework = function()
    local framework, obj = originalDetect()
    frameworkModule.name = framework
    return framework, obj
end

-- Set lib.framework to the module
lib.framework = frameworkModule

return frameworkModule
