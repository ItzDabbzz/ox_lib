--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxFramework
lib.framework = lib.framework or {}

local framework
local frameworkName
local sharedObject

--- Detects and initializes the framework
local function detectFramework()
    -- Check for QBX Core first (newer QB variant)
    if GetResourceState('qbx_core') == 'started' then
        framework = exports.qbx_core
        frameworkName = 'qbx'
        sharedObject = framework
        return true
    end

    -- Check for QB Core
    if GetResourceState('qb-core') == 'started' then
        framework = exports['qb-core']:GetCoreObject()
        frameworkName = 'qb'
        sharedObject = framework
        return true
    end

    -- Check for ESX
    if GetResourceState('es_extended') == 'started' then
        framework = exports.es_extended:getSharedObject()
        frameworkName = 'esx'
        sharedObject = framework
        return true
    end

    -- Check for legacy ESX
    if GetResourceState('esx_core') == 'started' then
        framework = exports.esx_core:getSharedObject()
        frameworkName = 'esx'
        sharedObject = framework
        return true
    end

    -- Check for other ESX variants
    local esxVariants = { 'esx-legacy', 'esx_legacy', 'extendedmode' }
    for _, variant in ipairs(esxVariants) do
        if GetResourceState(variant) == 'started' then
            framework = exports[variant]:getSharedObject()
            frameworkName = 'esx'
            sharedObject = framework
            return true
        end
    end

    return false
end

--- Initialize framework detection
CreateThread(function()
    if not detectFramework() then
        lib.print.warn('No supported framework detected')
    else
        lib.print.info(('Framework detected: %s'):format(frameworkName))
    end
end)

--- Checks if a framework is available
---@return boolean available Whether a framework is available
function lib.framework.isAvailable()
    return framework ~= nil
end

--- Gets the framework name
---@return string? name The framework name ('qb', 'qbx', 'esx') or nil if none detected
function lib.framework.getName()
    return frameworkName
end

--- Gets the shared object for the framework
---@return table? sharedObject The framework's shared object
function lib.framework.getSharedObject()
    return sharedObject
end

--- Gets player data for the current player
---@return table? playerData Player data or nil if not available
function lib.framework.getPlayerData()
    if not framework then
        return nil
    end

    if frameworkName == 'qbx' then
        return exports.qbx_core:GetPlayerData()
    elseif frameworkName == 'qb' then
        return framework.Functions.GetPlayerData()
    elseif frameworkName == 'esx' then
        return framework.GetPlayerData()
    end

    return nil
end

--- Gets the current player's job
---@return table? job Job information or nil if not found
function lib.framework.getPlayerJob()
    local playerData = lib.framework.getPlayerData()
    if not playerData then
        return nil
    end

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        return playerData.job
    elseif frameworkName == 'esx' then
        return playerData.job
    end

    return nil
end

--- Gets the current player's money amount
---@param moneyType? string Money type ('cash', 'bank', 'crypto', etc.)
---@return number amount Money amount
function lib.framework.getPlayerMoney(moneyType)
    local playerData = lib.framework.getPlayerData()
    if not playerData then
        return 0
    end

    moneyType = moneyType or 'cash'

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        return playerData.money[moneyType] or 0
    elseif frameworkName == 'esx' then
        if moneyType == 'cash' then
            return playerData.money or 0
        else
            local accounts = playerData.accounts
            if accounts then
                for _, account in ipairs(accounts) do
                    if account.name == moneyType then
                        return account.money
                    end
                end
            end
        end
    end

    return 0
end

-- Expose framework name for backwards compatibility
lib.framework.name = frameworkName

return lib.framework
