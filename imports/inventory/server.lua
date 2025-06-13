--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxInventoryServer : OxInventory
lib.inventory = lib.inventory or {}

--- Internal: Validate parameters for inventory functions
---@param source number Player source ID
---@param item string Item name
---@param count? number Item count
---@return boolean valid Whether parameters are valid
local function validateParams(source, item, count)
    if not lib.assert.type(source, 'number', 'Source') then
        return false
    end

    if not lib.assert.type(item, 'string', 'Item') then
        return false
    end

    if count ~= nil then
        if type(count) ~= 'number' or count < 0 then
            lib.print.error('Count must be a non-negative number')
            return false
        end
    end

    return true
end

--- Internal: Get player object from framework
---@param source number Player source ID
---@return table? player Player object or nil if not found
local function getPlayer(source)
    if not lib.framework.isAvailable() then
        lib.print.error('Framework not available')
        return nil
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.error(('Player not found for source %s'):format(source))
        return nil
    end

    return player
end

--- Checks if a player has the specified items in their inventory
---@param items table|string Table of item names (with required amounts) or a single item name
---@param amount? number Required quantity (default 1, ignored if items is a table)
---@param source number Player source ID
---@return boolean hasAll True if all items are present, false otherwise
---@return table details Details table: { [item] = { hasItem = bool, count = number } }
function lib.inventory.hasItems(items, amount, source)
    if not lib.assert.type(source, 'number', 'Source') then
        return false, {}
    end

    if not items then
        lib.print.error('Items parameter is required')
        return false, {}
    end

    local required = {}

    if type(items) == 'table' then
        for k, v in pairs(items) do
            if type(k) == 'number' then
                required[v] = 1
            else
                required[k] = v
            end
        end
    elseif type(items) == 'string' then
        required[items] = amount or 1
    else
        lib.print.error('Items must be a table or string')
        return false, {}
    end

    local inventory, systemName = lib.inventory.getPlayerInventory(source)
    if not inventory then
        lib.print.error('Could not retrieve inventory')
        return false, {}
    end

    local details = {}
    local hasAll = true

    for item, requiredAmount in pairs(required) do
        local count = 0

        for _, entry in pairs(inventory) do
            if entry and entry.name == item then
                count = count + (entry.amount or entry.count or 1)
            end
        end

        details[item] = {
            hasItem = count >= requiredAmount,
            count = count,
            required = requiredAmount
        }

        if count < requiredAmount then
            hasAll = false
        end
    end

    return hasAll, details
end

--- Retrieves a player's inventory and system name
---@param source number Player source ID
---@return table? inventory Player's inventory items
---@return string? systemName Current inventory system name
function lib.inventory.getPlayerInventory(source)
    if not lib.assert.type(source, 'number', 'Source') then
        return nil, nil
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return nil, nil
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return exports[resource]:GetInventoryItems(source), system
    elseif system == 'qs' then
        return exports[resource]:GetInventory(source), system
    elseif system == 'origen' then
        return exports[resource]:getInventory(source), system
    elseif system == 'codem' then
        local player = getPlayer(source)
        if not player then
            return nil, system
        end
        return exports[resource]:GetInventory(player.citizenId, source), system
    elseif system == 'tg' then
        return exports[resource]:GetPlayerItems(source), system
    elseif system == 'qb' then
        local player = getPlayer(source)
        if not player then
            return nil, system
        end
        return player.PlayerData.items or {}, system
    end

    lib.print.error(('Unsupported inventory system: %s'):format(system))
    return nil, system
end

--- Returns the amount of a specific item a player has
---@param source number Player source ID
---@param item string Item name
---@return number count The amount of the specified item the player has
function lib.inventory.hasItem(source, item)
    if not validateParams(source, item) then
        return 0
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return 0
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'codem' then
        return exports[resource]:GetItemsTotalAmount(source, item) or 0
    elseif system == 'ox' then
        return exports[resource]:Search(source, 'count', item) or 0
    elseif system == 'qb' then
        return exports[resource]:GetItemCount(source, item) or 0
    elseif system == 'qs' or system == 'tg' then
        local itemData = exports[resource]:GetItemByName(source, item)
        return itemData and (itemData.amount or itemData.count or 0) or 0
    elseif system == 'origen' then
        return exports[resource]:getItemCount(source, item, false, false) or 0
    end

    -- Fallback to framework-based check
    local player = getPlayer(source)
    if not player then
        return 0
    end

    if lib.framework.name == 'esx' then
        local itemData = player.getInventoryItem(item)
        return itemData and (itemData.count or itemData.amount) or 0
    elseif lib.framework.name == 'qb' then
        local itemData = player.Functions.GetItemByName(item)
        return itemData and (itemData.amount or itemData.count) or 0
    end

    lib.print.error('Unsupported framework or inventory state for hasItem')
    return 0
end

--- Checks if a player can carry an item
---@param source number Player source ID
---@param item string Item name
---@param count number Amount of the item to check
---@param slot? number Inventory slot, if applicable
---@return boolean canCarry True if the player can carry the item, false otherwise
function lib.inventory.canCarry(source, item, count, slot)
    if not validateParams(source, item, count) then
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'codem' then
        return true -- Codem inventory doesn't have a canCarry check
    elseif system == 'ox' then
        return exports[resource]:CanCarryItem(source, item, count) or false
    elseif system == 'qb' then
        return exports[resource]:CanAddItem(source, item, count) or false
    elseif system == 'qs' or system == 'tg' then
        return exports[resource]:CanCarryItem(source, item, count) or false
    elseif system == 'origen' then
        return exports[resource]:CanCarryItem(source, item, count) or false
    end

    -- Fallback to framework-based check
    local player = getPlayer(source)
    if not player then
        return false
    end

    if lib.framework.name == 'esx' then
        local currentItem = player.getInventoryItem(item)
        if currentItem then
            local newWeight = player.getWeight() + (currentItem.weight * count)
            return newWeight <= player.getMaxWeight()
        end
        return false
    elseif lib.framework.name == 'qb' then
        local totalWeight = lib.framework.getSharedObject().Player.GetTotalWeight(player.PlayerData.items)
        local itemInfo = lib.framework.getSharedObject().Shared.Items[item:lower()]
        if not totalWeight or not itemInfo then
            return false
        end
        return (totalWeight + (itemInfo.weight * count)) <= 120000
    end

    lib.print.error('Unsupported framework for canCarry')
    return false
end

--- Adds an item to a player's inventory
---@param source number Player source ID
---@param item string Item name
---@param count number Amount of the item to add
---@param metadata? table Additional metadata for the item
---@param slot? number Inventory slot to add the item to
---@return boolean success Whether the item was successfully added
function lib.inventory.addItem(source, item, count, metadata, slot)
    if not validateParams(source, item, count) then
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'codem' then
        return exports[resource]:AddItem(source, item, count, slot or false, metadata or false) or false
    elseif system == 'ox' then
        return exports[resource]:AddItem(source, item, count, metadata or false, slot or false) or false
    elseif system == 'qb' then
        exports[resource]:AddItem(source, item, count, slot or false, metadata or false, 'ox_lib:addItem')
        TriggerClientEvent('qb-inventory:client:ItemBox', source, lib.framework.getSharedObject().Shared.Items[item], 'add', count)
        return true
    elseif system == 'qs' or system == 'tg' then
        return exports[resource]:AddItem(source, item, count, slot or false, metadata or false) or false
    elseif system == 'origen' then
        return exports[resource]:addItem(source, item, count, metadata, slot) or false
    end

    -- Fallback to framework-based add
    local player = getPlayer(source)
    if not player then
        return false
    end

    if lib.framework.name == 'esx' then
        return player.addInventoryItem(item, count, metadata, slot) or false
    elseif lib.framework.name == 'qb' then
        TriggerClientEvent('inventory:client:ItemBox', source, lib.framework.getSharedObject().Shared.Items[item], 'add', count)
        return player.Functions.AddItem(item, count, slot, metadata) or false
    end

    lib.print.error('Unsupported framework or inventory state for addItem')
    return false
end

--- Removes an item from a player's inventory
---@param source number Player source ID
---@param item string Item name
---@param count number Amount of the item to remove
---@param metadata? table Additional metadata for the item
---@param slot? number Inventory slot to remove the item from
---@return boolean success Whether the item was successfully removed
function lib.inventory.removeItem(source, item, count, metadata, slot)
    if not validateParams(source, item, count) then
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'codem' then
        return exports[resource]:RemoveItem(source, item, count, slot or false) or false
    elseif system == 'ox' then
        return exports[resource]:RemoveItem(source, item, count, metadata or false, slot or false) or false
    elseif system == 'qb' then
        exports[resource]:RemoveItem(source, item, count, slot or false, 'ox_lib:removeItem')
        TriggerClientEvent('qb-inventory:client:ItemBox', source, lib.framework.getSharedObject().Shared.Items[item], 'remove', count)
        return true
    elseif system == 'qs' then
        return exports[resource]:RemoveItem(source, item, count, slot or false, metadata or false) or false
    elseif system == 'tg' then
        return exports[resource]:RemoveItem(source, item, count, slot or false, metadata or false) or false
    elseif system == 'origen' then
        return exports[resource]:removeItem(source, item, count, metadata, slot) or false
    end

    -- Fallback to framework-based remove
    local player = getPlayer(source)
    if not player then
        return false
    end

    if lib.framework.name == 'esx' then
        return player.removeInventoryItem(item, count, metadata or false, slot or false) or false
    elseif lib.framework.name == 'qb' then
        TriggerClientEvent('inventory:client:ItemBox', source, lib.framework.getSharedObject().Shared.Items[item], 'remove', count)
        return player.Functions.RemoveItem(item, count, slot, metadata or false) or false
    end

    lib.print.error('RemoveItem function is not supported in the current framework')
    return false
end

--- Registers a function to be called when a player uses an item
---@param item string Item name
---@param callback function Callback function to execute when the item is used
---@return boolean success Whether the usable item was successfully registered
function lib.inventory.registerUsableItem(item, callback)
    if not lib.assert.type(item, 'string', 'Item') then
        return false
    end

    if not lib.assert.type(callback, 'function', 'Callback') then
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        local exportName = 'use' .. item:gsub("^%l", string.upper)
        exports(exportName, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                callback(inventory.id, item, inventory, slot, data)
            end
        end)
        return true
    elseif system == 'origen' then
        return exports[resource]:CreateUseableItem(item, callback) or false
    end
    -- Fallback to framework-based registration
    if lib.framework.name == 'esx' then
        lib.framework.getSharedObject().RegisterUsableItem(item, callback)
        return true
    elseif lib.framework.name == 'qb' then
        lib.framework.getSharedObject().Functions.CreateUseableItem(item, callback)
        return true
    end

    lib.print.error('Usable item registration not supported for current inventory system')
    return false
end

--- Creates a stash with specified parameters
---@param stashId string Unique stash identifier
---@param label string Display label for the stash
---@param slots number Number of slots in the stash
---@param maxWeight number Maximum weight capacity of the stash
---@param owner? string Owner identifier (optional)
---@param groups? table Groups that can access the stash (optional)
---@param coords? vector3 Coordinates for the stash (optional)
---@return boolean success Whether the stash was successfully created
function lib.inventory.createStash(stashId, label, slots, maxWeight, owner, groups, coords)
    if not lib.assert.type(stashId, 'string', 'Stash ID') then
        return false
    end

    if not lib.assert.type(label, 'string', 'Label') then
        return false
    end

    if type(slots) ~= 'number' or slots < 1 then
        lib.print.error('Slots must be a positive number')
        return false
    end

    if type(maxWeight) ~= 'number' or maxWeight < 1 then
        lib.print.error('Max weight must be a positive number')
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        exports[resource]:RegisterStash(stashId, label, slots, maxWeight, owner, groups, coords)
        return true
    elseif system == 'qs' then
        exports[resource]:RegisterStash(stashId, slots, maxWeight)
        return true
    elseif system == 'qb' then
        -- QB-Inventory doesn't have a direct register function, stashes are created on access
        return true
    elseif system == 'codem' then
        exports[resource]:RegisterStash(stashId, slots, maxWeight)
        return true
    elseif system == 'origen' then
        exports[resource]:registerStash(stashId, label, slots, maxWeight, owner, groups, coords)
        return true
    elseif system == 'tg' then
        exports[resource]:RegisterStash(stashId, label, slots, maxWeight, owner, groups, coords)
        return true
    end

    lib.print.warn(('Stash creation not implemented for system: %s'):format(system))
    return false
end

--- Creates a shop with specified parameters
---@param shopId string Unique shop identifier
---@param label string Display label for the shop
---@param items table Items available in the shop
---@param locations? table Locations where the shop can be accessed (optional)
---@param groups? table Groups that can access the shop (optional)
---@return boolean success Whether the shop was successfully created
function lib.inventory.createShop(shopId, label, items, locations, groups)
    if not lib.assert.type(shopId, 'string', 'Shop ID') then
        return false
    end

    if not lib.assert.type(label, 'string', 'Label') then
        return false
    end

    if not lib.assert.type(items, 'table', 'Items') then
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        exports[resource]:RegisterShop(shopId, {
            name = label,
            inventory = items,
            locations = locations,
            groups = groups
        })
        return true
    elseif system == 'qs' then
        exports[resource]:CreateShop(shopId, items)
        return true
    elseif system == 'qb' then
        -- QB-Inventory shops are typically defined in config files
        lib.print.warn('QB-Inventory shops should be defined in config files')
        return false
    elseif system == 'codem' then
        exports[resource]:CreateShop(shopId, items)
        return true
    elseif system == 'origen' then
        exports[resource]:createShop(shopId, label, items, locations, groups)
        return true
    elseif system == 'tg' then
        exports[resource]:CreateShop(shopId, label, items, locations, groups)
        return true
    end

    lib.print.warn(('Shop creation not implemented for system: %s'):format(system))
    return false
end

--- Gets the current weight of a player's inventory
---@param source number Player source ID
---@return number currentWeight Current inventory weight
---@return number maxWeight Maximum inventory weight
function lib.inventory.getWeight(source)
    if not lib.assert.type(source, 'number', 'Source') then
        return 0, 0
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return 0, 0
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        local currentWeight = exports[resource]:GetWeight(source)
        local maxWeight = exports[resource]:GetMaxWeight(source)
        return currentWeight or 0, maxWeight or 0
    elseif system == 'qs' then
        local currentWeight = exports[resource]:GetCurrentWeight(source)
        local maxWeight = exports[resource]:GetMaxWeight(source)
        return currentWeight or 0, maxWeight or 0
    elseif system == 'qb' then
        local player = getPlayer(source)
        if not player then
            return 0, 0
        end

        local currentWeight = player.PlayerData.metadata.currentweight or 0
        local maxWeight = player.PlayerData.metadata.maxweight or 120000
        return currentWeight, maxWeight
    elseif system == 'codem' then
        local currentWeight = exports[resource]:GetCurrentWeight(source)
        local maxWeight = exports[resource]:GetMaxWeight(source)
        return currentWeight or 0, maxWeight or 0
    elseif system == 'origen' then
        local currentWeight = exports[resource]:getCurrentWeight(source)
        local maxWeight = exports[resource]:getMaxWeight(source)
        return currentWeight or 0, maxWeight or 0
    elseif system == 'tg' then
        local currentWeight = exports[resource]:GetCurrentWeight(source)
        local maxWeight = exports[resource]:GetMaxWeight(source)
        return currentWeight or 0, maxWeight or 0
    end

    -- Fallback to framework-based weight
    local player = getPlayer(source)
    if not player then
        return 0, 0
    end

    if lib.framework.name == 'esx' then
        return player.getWeight(), player.getMaxWeight()
    elseif lib.framework.name == 'qb' then
        local totalWeight = lib.framework.getSharedObject().Player.GetTotalWeight(player.PlayerData.items)
        return totalWeight or 0, 120000
    end

    lib.print.warn(('Weight retrieval not implemented for system: %s'):format(system))
    return 0, 0
end

--- Gets the number of free slots in a player's inventory
---@param source number Player source ID
---@return number freeSlots Number of free slots
function lib.inventory.getFreeSlots(source)
    if not lib.assert.type(source, 'number', 'Source') then
        return 0
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return 0
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return exports[resource]:GetEmptySlots(source) or 0
    elseif system == 'qs' then
        return exports[resource]:GetFreeSlots(source) or 0
    elseif system == 'qb' then
        local inventory = lib.inventory.getPlayerInventory(source)
        if not inventory then
            return 0
        end

        local usedSlots = 0
        for _ in pairs(inventory) do
            usedSlots = usedSlots + 1
        end

        -- Assuming max 40 slots for QB (configurable)
        return math.max(0, 40 - usedSlots)
    elseif system == 'codem' then
        return exports[resource]:GetFreeSlots(source) or 0
    elseif system == 'origen' then
        return exports[resource]:getFreeSlots(source) or 0
    elseif system == 'tg' then
        return exports[resource]:GetFreeSlots(source) or 0
    end

    lib.print.warn(('Free slots retrieval not implemented for system: %s'):format(system))
    return 0
end

--- Gets inventory statistics for a player
---@param source number Player source ID
---@return table stats Inventory statistics
function lib.inventory.getStats(source)
    if not lib.assert.type(source, 'number', 'Source') then
        return {}
    end

    local currentWeight, maxWeight = lib.inventory.getWeight(source)
    local freeSlots = lib.inventory.getFreeSlots(source)
    local inventory = lib.inventory.getPlayerInventory(source)

    local stats = {
        currentWeight = currentWeight,
        maxWeight = maxWeight,
        weightPercentage = maxWeight > 0 and math.floor((currentWeight / maxWeight) * 100) or 0,
        freeSlots = freeSlots,
        totalItems = inventory and #inventory or 0,
        system = lib.inventory.system,
        resource = lib.inventory.resource
    }

    return stats
end

--- Clears a player's inventory
---@param source number Player source ID
---@return boolean success Whether the inventory was successfully cleared
function lib.inventory.clearInventory(source)
    if not lib.assert.type(source, 'number', 'Source') then
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return exports[resource]:ClearInventory(source) or false
    elseif system == 'qs' then
        return exports[resource]:ClearInventory(source) or false
    elseif system == 'qb' then
        local player = getPlayer(source)
        if not player then
            return false
        end

        player.PlayerData.items = {}
        player.Functions.Save()
        return true
    elseif system == 'codem' then
        return exports[resource]:ClearInventory(source) or false
    elseif system == 'origen' then
        return exports[resource]:clearInventory(source) or false
    elseif system == 'tg' then
        return exports[resource]:ClearInventory(source) or false
    end

    -- Fallback to framework-based clear
    local player = getPlayer(source)
    if not player then
        return false
    end

    if lib.framework.name == 'esx' then
        local inventory = player.getInventory()
        for _, item in pairs(inventory) do
            if item.count > 0 then
                player.removeInventoryItem(item.name, item.count)
            end
        end
        return true
    elseif lib.framework.name == 'qb' then
        player.PlayerData.items = {}
        player.Functions.Save()
        return true
    end

    lib.print.warn(('Inventory clearing not implemented for system: %s'):format(system))
    return false
end

--- Register callback handlers for client requests
lib.callback.register('ox_lib:inventory:hasItem', function(source, items)
    return lib.inventory.hasItem(source, items)
end)

lib.callback.register('ox_lib:inventory:hasItems', function(source, items, amount)
    return lib.inventory.hasItems(items, amount, source)
end)

lib.callback.register('ox_lib:inventory:getPlayerInventory', function(source)
    return lib.inventory.getPlayerInventory(source)
end)

lib.callback.register('ox_lib:inventory:canCarry', function(source, item, count, slot)
    return lib.inventory.canCarry(source, item, count, slot)
end)

lib.callback.register('ox_lib:inventory:getStats', function(source)
    return lib.inventory.getStats(source)
end)

--- Export functions for backwards compatibility
HasItem = lib.inventory.hasItem
AddItem = lib.inventory.addItem
RemoveItem = lib.inventory.removeItem
CanCarry = lib.inventory.canCarry
GetPlayerInventory = lib.inventory.getPlayerInventory
CreateStash = lib.inventory.createStash
CreateShop = lib.inventory.createShop

return lib.inventory
