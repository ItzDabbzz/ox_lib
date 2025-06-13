--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxFramework
local frameworkModule = {}

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
function frameworkModule.isAvailable()
    return framework ~= nil
end

--- Gets the framework name
---@return string? name The framework name ('qb', 'qbx', 'esx') or nil if none detected
function frameworkModule.getName()
    return frameworkName
end

--- Gets the shared object for the framework
---@return table? sharedObject The framework's shared object
function frameworkModule.getSharedObject()
    return sharedObject
end

--- Gets player data for the current player
---@return table? playerData Player data or nil if not available
function frameworkModule.getPlayerData()
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
function frameworkModule.getPlayerJob()
    local playerData = frameworkModule.getPlayerData()
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
function frameworkModule.getPlayerMoney(moneyType)
    local playerData = frameworkModule.getPlayerData()
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

--- Send notification to player (QBX specific with fallback)
---@param text table|string Notification text
---@param notifyType? string Notification type ('inform', 'error', 'success', 'warning')
---@param duration? number Duration in milliseconds
---@param subTitle? string Subtitle text
---@param notifyPosition? string Position ('top', 'top-right', etc.)
---@param notifyStyle? table Custom styling
---@param notifyIcon? string Font Awesome 6 icon name
---@param notifyIconColor? string Icon color
function frameworkModule.notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    if frameworkName == 'qbx' then
        exports.qbx_core:Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    elseif frameworkName == 'qb' then
        -- QB Core notification fallback
        local message = type(text) == 'table' and text.text or text
        framework.Functions.Notify(message, notifyType or 'primary', duration or 5000)
    elseif frameworkName == 'esx' then
        -- ESX notification fallback
        local message = type(text) == 'table' and text.text or text
        local esxType = notifyType == 'error' and 'error' or notifyType == 'success' and 'success' or 'info'
        framework.ShowNotification(message, esxType, duration or 5000)
    else
        -- Fallback to lib.notify if available
        if lib.notify then
            lib.notify({
                title = type(text) == 'table' and text.text or text,
                description = subTitle,
                type = notifyType or 'inform',
                duration = duration or 5000,
                position = notifyPosition,
                style = notifyStyle,
                icon = notifyIcon,
                iconColor = notifyIconColor
            })
        end
    end
end

--- Check if player has primary group (QBX specific)
---@param filter string|string[]|table<string, number> Group filter
---@return boolean success Whether player has the primary group
function frameworkModule.hasPrimaryGroup(filter)
    if frameworkName == 'qbx' then
        return exports.qbx_core:HasPrimaryGroup(filter)
    end

    -- Fallback for other frameworks
    local playerData = frameworkModule.getPlayerData()
    if not playerData then
        return false
    end

    if type(filter) == 'string' then
        if frameworkName == 'qb' then
            return playerData.job and playerData.job.name == filter
        elseif frameworkName == 'esx' then
            return playerData.job and playerData.job.name == filter
        end
    elseif type(filter) == 'table' then
        if frameworkName == 'qb' then
            local job = playerData.job
            if job then
                for jobName, minGrade in pairs(filter) do
                    if job.name == jobName and job.grade.level >= minGrade then
                        return true
                    end
                end
            end
        elseif frameworkName == 'esx' then
            local job = playerData.job
            if job then
                for jobName, minGrade in pairs(filter) do
                    if job.name == jobName and job.grade >= minGrade then
                        return true
                    end
                end
            end
        end
    end

    return false
end

--- Check if player has any group (QBX specific)
---@param filter string|string[]|table<string, number> Group filter
---@return boolean success Whether player has any of the groups
function frameworkModule.hasGroup(filter)
    if frameworkName == 'qbx' then
        return exports.qbx_core:HasGroup(filter)
    end

    -- For non-QBX frameworks, this is the same as hasPrimaryGroup since they typically only have one job
    return frameworkModule.hasPrimaryGroup(filter)
end

--- Get all groups for current player (QBX specific)
---@return table<string, number> groups Player's groups
function frameworkModule.getGroups()
    if frameworkName == 'qbx' then
        return exports.qbx_core:GetGroups()
    end

    -- Fallback for other frameworks
    local groups = {}
    local playerData = frameworkModule.getPlayerData()

    if playerData then
        if frameworkName == 'qb' then
            if playerData.job then
                groups[playerData.job.name] = playerData.job.grade.level
            end
            if playerData.gang and playerData.gang.name ~= 'none' then
                groups[playerData.gang.name] = playerData.gang.grade.level
            end
        elseif frameworkName == 'esx' then
            if playerData.job then
                groups[playerData.job.name] = playerData.job.grade
            end
        end
    end

    return groups
end

--- Get current player's gang (QB/QBX specific)
---@return table? gang Gang information or nil if not found
function frameworkModule.getPlayerGang()
    local playerData = frameworkModule.getPlayerData()
    if not playerData then
        return nil
    end

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        return playerData.gang
    end

    return nil
end

--- Check if player has specific gang (QB/QBX specific)
---@param gangName string Gang name to check
---@param grade? number Minimum grade required
---@return boolean hasGang Whether the player has the gang
function frameworkModule.hasGang(gangName, grade)
    local playerData = frameworkModule.getPlayerData()
    if not playerData then
        return false
    end

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        local playerGang = playerData.gang
        if not playerGang or playerGang.name ~= gangName then
            return false
        end

        if grade and playerGang.grade.level < grade then
            return false
        end

        return true
    end

    return false
end

--- Get player's citizenid (QB/QBX specific)
---@return string? citizenid Player's citizen ID
function frameworkModule.getCitizenId()
    local playerData = frameworkModule.getPlayerData()
    if not playerData then
        return nil
    end

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        return playerData.citizenid
    end

    return nil
end

--- Get player's license identifier
---@return string? license Player's license identifier
function frameworkModule.getLicense()
    local playerData = frameworkModule.getPlayerData()
    if not playerData then
        return nil
    end

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        return playerData.license
    elseif frameworkName == 'esx' then
        return playerData.identifier
    end

    return nil
end

--- Check if player is on duty
---@return boolean onDuty Whether player is on duty
function frameworkModule.isOnDuty()
    local playerData = frameworkModule.getPlayerData()
    if not playerData then
        return false
    end

    if frameworkName == 'qbx' or frameworkName == 'qb' then
        return playerData.job and playerData.job.onduty or false
    elseif frameworkName == 'esx' then
        -- ESX doesn't have built-in duty system, return true by default
        return true
    end

    return false
end

--- Refresh framework detection
---@return boolean success Whether refresh was successful
function frameworkModule.refresh()
    framework = nil
    frameworkName = nil
    sharedObject = nil

    return detectFramework()
end

--- Get framework statistics
---@return table stats Framework statistics
function frameworkModule.getStats()
    local playerData = frameworkModule.getPlayerData()

    return {
        framework = frameworkName,
        available = framework ~= nil,
        playerLoaded = playerData ~= nil,
        onDuty = frameworkModule.isOnDuty(),
        citizenId = frameworkModule.getCitizenId(),
        license = frameworkModule.getLicense()
    }
end

-- Expose framework name for backwards compatibility
frameworkModule.name = frameworkName

-- Update the name property when framework is detected
local originalDetect = detectFramework
detectFramework = function()
    local success = originalDetect()
    frameworkModule.name = frameworkName
    return success
end

-- Set lib.framework to the module
lib.framework = frameworkModule

return frameworkModule
