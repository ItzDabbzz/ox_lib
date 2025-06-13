--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxInventory
lib.inventory = {}

---@class InventorySystem
---@field name string System name
---@field resource string Resource name

---@type table<string, string>
local INVENTORY_RESOURCES = {
    codem = 'codem-inventory',
    ox = 'ox_inventory',
    origen = 'origen_inventory',
    qs = 'qs-inventory',
    tg = 'tgiann-inventory',
    qb = 'qb-inventory'
}

--- Detects and returns the active inventory system and its resource name
---@return string? systemName The detected system name
---@return string? resourceName The detected resource name
local function detectInventorySystem()
    for name, resource in pairs(INVENTORY_RESOURCES) do
        if GetResourceState(resource) == 'started' then
            lib.print.debug(('Detected inventory system: %s (%s)'):format(name, resource))
            return name, resource
        end
    end

    lib.print.warn('No supported inventory resource found')
    return nil, nil
end

--- Get all available inventory resources
---@return table<string, string> resources Available inventory resources
function lib.inventory.getAvailableResources()
    return lib.table.deepclone(INVENTORY_RESOURCES)
end

--- Check if a specific inventory system is available
---@param systemName string System name to check
---@return boolean available Whether the system is available
function lib.inventory.isSystemAvailable(systemName)
    if not lib.assert.type(systemName, 'string', 'System name') then
        return false
    end

    local resource = INVENTORY_RESOURCES[systemName]
    if not resource then
        return false
    end

    return GetResourceState(resource) == 'started'
end

--- Get the current inventory system information
---@return InventorySystem? system Current inventory system info
function lib.inventory.getCurrentSystem()
    local systemName, resourceName = detectInventorySystem()

    if not systemName or not resourceName then
        return nil
    end

    return {
        name = systemName,
        resource = resourceName
    }
end

--- Initialize inventory system detection
local function initializeInventorySystem()
    local systemName, resourceName = detectInventorySystem()

    if not systemName or not resourceName then
        local availableResources = {}
        for name, resource in pairs(INVENTORY_RESOURCES) do
            availableResources[#availableResources + 1] = resource
        end

        error(('No supported inventory resource found! Please start one of: %s'):format(
            table.concat(availableResources, ', ')
        ))
    end

    lib.inventory.system = systemName
    lib.inventory.resource = resourceName

    lib.print.info(('Inventory system initialized: %s (%s)'):format(systemName, resourceName))

    return true
end

--- Wait for inventory system to be available
lib.waitFor(function()
    return initializeInventorySystem()
end, 'Inventory system initialization failed', 10000)

--- Export detection function for backwards compatibility
lib.inventory.detectInventorySystem = detectInventorySystem

return lib.inventory
