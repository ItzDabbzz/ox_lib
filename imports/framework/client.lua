--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class OxFrameworkClient
lib.framework = {}

local detectedFramework = nil
local frameworkObject = nil

--- Framework detection and initialization
local function detectAndInitFramework()
    if detectedFramework then
        return detectedFramework, frameworkObject
    end

    -- Check for QBX
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

--- Get player data from framework
---@return table? playerData The player data
function lib.framework.getPlayerData()
    local framework, frameworkObj = detectAndInitFramework()
    if not framework or not frameworkObj then
        return nil
    end

    if framework == 'esx' then
        return frameworkObj.GetPlayerData and frameworkObj.GetPlayerData() or nil
    elseif framework == 'qb' or framework == 'qbx' then
        return frameworkObj.Functions and frameworkObj.Functions.GetPlayerData() or nil
    end

    return nil
end

--- Check if player is loaded
---@return boolean loaded
function lib.framework.isPlayerLoaded()
    local playerData = lib.framework.getPlayerData()
    return playerData ~= nil
end

--- Wait for player to be loaded
---@param timeout? number Timeout in milliseconds (default: 30000)
---@return boolean success Whether player loaded within timeout
function lib.framework.waitForPlayerLoaded(timeout)
    timeout = timeout or 30000

    return lib.waitFor(function()
        return lib.framework.isPlayerLoaded()
    end, 'Player failed to load', timeout)
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

    local framework, _ = detectAndInitFramework()
    return framework ~= nil
end

-- Initialize framework detection
CreateThread(function()
    Wait(1000) -- Wait for frameworks to load
    detectAndInitFramework()
end)

return lib.framework
