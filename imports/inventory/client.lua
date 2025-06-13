--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxInventoryClient : OxInventory
lib.inventory = lib.inventory or {}

---@class InventoryItem
---@field name string Item name
---@field amount number Item amount/count
---@field slot? number Item slot
---@field metadata? table Item metadata
---@field info? table Item info (QB legacy)

--- Locks or unlocks the player's inventory, freezing movement and toggling hotbar
---@param toggle boolean True to lock, false to unlock
function lib.inventory.lock(toggle)
    if not lib.assert.type(toggle, 'boolean', 'Toggle state') then
        return
    end

    FreezeEntityPosition(cache.ped, toggle)
    LocalPlayer.state:set('inv_busy', toggle, true)
    LocalPlayer.state:set('invBusy', toggle, true)

    -- Trigger various inventory busy events
    TriggerEvent('inventory:client:busy:status', toggle)
    TriggerEvent('canUseInventoryAndHotbar:toggle', not toggle)

    lib.print.debug(('Inventory %s'):format(toggle and 'locked' or 'unlocked'))
end

--- Checks if the player has the specified item(s)
---@param items string|table The item name or table of item names to check
---@return number|table The count for a single item, or a table of counts for multiple items
function lib.inventory.hasItem(items)
    if not items then
        lib.print.error('Items parameter is required')
        return type(items) == 'table' and {} or 0
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return type(items) == 'table' and {} or 0
    end

    local isTable = type(items) == 'table'
    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'codem' then
        local playerInventory = exports[resource]:getUserInventory()
        if not playerInventory then
            return isTable and {} or 0
        end

        if isTable then
            local result = {}
            for k in pairs(items) do
                result[k] = 0
            end

            for _, itemData in pairs(playerInventory) do
                local itemName = tostring(itemData.name)
                if items[itemName] then
                    result[itemName] = result[itemName] + (itemData.amount or 0)
                end
            end
            return result
        else
            local itemCount = 0
            for _, itemData in pairs(playerInventory) do
                if tostring(itemData.name) == items then
                    itemCount = itemCount + (itemData.amount or 0)
                end
            end
            return itemCount
        end
    elseif system == 'ox' then
        if isTable then
            local itemArray = {}
            for k in pairs(items) do
                itemArray[#itemArray + 1] = k
            end

            local returnedItems = exports[resource]:Search('count', itemArray)
            local result = {}
            for k in pairs(items) do
                result[k] = returnedItems[k] or 0
            end
            return result
        else
            return exports[resource]:Search('count', items) or 0
        end
    elseif system == 'origen' then
        local playerInventory = exports[resource]:GetInventory()
        if not playerInventory then
            return isTable and {} or 0
        end

        if isTable then
            local result = {}
            for k in pairs(items) do
                result[k] = 0
            end

            for _, itemData in pairs(playerInventory) do
                local itemName = tostring(itemData.name)
                if items[itemName] then
                    result[itemName] = result[itemName] + (itemData.amount or 0)
                end
            end
            return result
        else
            local itemCount = 0
            for _, itemData in pairs(playerInventory) do
                if tostring(itemData.name) == items then
                    itemCount = itemCount + (itemData.amount or 0)
                end
            end
            return itemCount
        end
    elseif system == 'qs' then
        local playerInventory = exports[resource]:getUserInventory()
        if not playerInventory then
            return isTable and {} or 0
        end

        if isTable then
            local result = {}
            for k in pairs(items) do
                result[k] = 0
            end

            for _, itemData in pairs(playerInventory) do
                local itemName = tostring(itemData.name)
                if items[itemName] then
                    result[itemName] = result[itemName] + (itemData.amount or 0)
                end
            end
            return result
        else
            local itemCount = 0
            for _, itemData in pairs(playerInventory) do
                if tostring(itemData.name) == items then
                    itemCount = itemCount + (itemData.amount or 0)
                end
            end
            return itemCount
        end
    elseif system == 'tg' then
        local playerInventory = exports[resource]:GetPlayerItems()
        if not playerInventory then
            return isTable and {} or 0
        end

        if isTable then
            local result = {}
            for k in pairs(items) do
                result[k] = 0
            end

            for _, itemData in pairs(playerInventory) do
                local itemName = tostring(itemData.name)
                if items[itemName] then
                    result[itemName] = result[itemName] + (itemData.amount or 0)
                end
            end
            return result
        else
            local itemCount = 0
            for _, itemData in pairs(playerInventory) do
                if tostring(itemData.name) == items then
                    itemCount = itemCount + (itemData.amount or 0)
                end
            end
            return itemCount
        end
    elseif system == 'qb' then
        if not lib.framework.isAvailable() then
            lib.print.error('Framework not available for QB inventory')
            return isTable and {} or 0
        end

        local PlayerData = lib.framework.getPlayerData()
        local inventory = PlayerData and PlayerData.items or {}

        if isTable then
            local result = {}
            for k in pairs(items) do
                result[k] = 0
            end

            for _, inventoryItem in ipairs(inventory) do
                if inventoryItem and items[inventoryItem.name] then
                    result[inventoryItem.name] = inventoryItem.amount or inventoryItem.count or 0
                end
            end
            return result
        else
            for _, inventoryItem in ipairs(inventory) do
                if inventoryItem and inventoryItem.name == items then
                    return inventoryItem.amount or inventoryItem.count or 0
                end
            end
            return 0
        end
    end

    lib.print.error(('Unsupported inventory system: %s'):format(system))
    return isTable and {} or 0
end

--- Checks if the player has the specified items in their inventory
---@param items table|string Table of item names (with required amounts) or a single item name
---@param amount? number Required quantity (default 1, ignored if items is a table)
---@return boolean hasAll True if all items are present, false otherwise
---@return table details Details table: { [item] = { hasItem = bool, count = number } }
function lib.inventory.hasItems(items, amount)
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

    local inventory = lib.inventory.getPlayerInventory()
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

--- Retrieves the current player's inventory
---@return table? inventory Player's inventory items
---@return string? systemName Current inventory system name
function lib.inventory.getPlayerInventory()
    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return nil, nil
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return exports[resource]:GetPlayerItems(), system
    elseif system == 'qs' or system == 'codem' then
        return exports[resource]:getUserInventory(), system
    elseif system == 'origen' then
        return exports[resource]:getInventory(), system
    elseif system == 'tg' then
        return exports[resource]:GetPlayerItems(), system
    elseif system == 'qb' then
        if not lib.framework.isAvailable() then
            lib.print.error('Framework not available for QB inventory')
            return nil, system
        end

        local PlayerData = lib.framework.getPlayerData()
        return PlayerData and PlayerData.items or {}, system
    end

    lib.print.error(('Unsupported inventory system: %s'):format(system))
    return nil, system
end

--- Checks if the inventory UI is currently open
---@return boolean isOpen Whether the inventory is open
function lib.inventory.isOpen()
    if not lib.inventory.system then
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return LocalPlayer.state.invBusy or false
    elseif system == 'qs' then
        return exports[resource]:inInventory() or false
    elseif system == 'origen' then
        return exports[resource]:IsInventoryOpen() or false
    elseif system == 'tg' then
        return exports[resource]:IsInventoryActive() or false
    elseif system == 'qb' then
        return LocalPlayer.state.inv_busy or false
    elseif system == 'codem' then
        return LocalPlayer.state.invBusy or false
    end

    return false
end

--- Returns the image path format for items, depending on the inventory system
---@return string pathFormat Image path format string
function lib.inventory.getImagePathFormat()
    if not lib.inventory.system then
        return ''
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'qs' then
        return ('nui://%s/html/images/%%s.png'):format(resource)
    elseif system == 'tg' then
        return 'nui://inventory_images/html/images/%s.webp'
    elseif system == 'codem' then
        return ('nui://%s/html/images/%%s.png'):format(resource)
    elseif system == 'origen' then
        return ('nui://%s/html/images/%%s.png'):format(resource)
    elseif system == 'ox' then
        return ('nui://%s/web/images/%%s.png'):format(resource)
    elseif system == 'qb' then
        return ('nui://%s/html/images/%%s.png'):format(resource)
    end

    return ''
end

--- Gets the NUI path for an item's image, based on the active inventory system
---@param item string Item name
---@return string imagePath Full image path for the item
function lib.inventory.getItemImage(item)
    if not lib.assert.type(item, 'string', 'Item name') then
        return ''
    end

    if item == '' then
        return ''
    end

    local pathFormat = lib.inventory.getImagePathFormat()
    if pathFormat == '' then
        return ''
    end

    return pathFormat:format(item)
end

--- Opens a stash by ID, using the appropriate inventory system
---@param stashId string Stash identifier
---@param data? table Additional stash data (slots, weight, etc.)
function lib.inventory.openStash(stashId, data)
    if not lib.assert.type(stashId, 'string', 'Stash ID') then
        return
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return
    end

    data = data or {}
    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'qs' then
        exports[resource]:RegisterStash(stashId, data.slots or 50, data.weight or 50000)
    elseif system == 'ox' then
        exports[resource]:openInventory('stash', stashId)
    elseif system == 'qb' then
        TriggerEvent('inventory:client:SetCurrentStash', stashId)
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashId, {
            maxweight = data.weight or 50000,
            slots = data.slots or 50,
        })
    elseif system == 'codem' then
        exports[resource]:OpenStash(stashId, data.slots or 50, data.weight or 50000)
    elseif system == 'origen' then
        exports[resource]:openStash(stashId, data)
    elseif system == 'tg' then
        exports[resource]:OpenStash(stashId, data)
    else
        lib.print.warn(('Stash opening not implemented for system: %s'):format(system))
    end
end

--- Gets item information by item name
---@param item string Item name
---@return table? itemInfo Item information or nil if not found
function lib.inventory.getItemInfo(item)
    if not lib.assert.type(item, 'string', 'Item name') then
        return nil
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return nil
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'qs' then
        local itemsLua = exports[resource]:GetItemList()
        return itemsLua and itemsLua[item] or nil
    elseif system == 'ox' then
        return exports[resource]:Items(item)
    elseif system == 'qb' then
        if not lib.framework.isAvailable() then
            lib.print.error('Framework not available for QB inventory')
            return nil
        end

        local sharedItems = lib.framework.getSharedObject().Items
        return sharedItems and sharedItems[item] or nil
    elseif system == 'codem' then
        local itemsLua = exports[resource]:GetItemList()
        return itemsLua and itemsLua[item] or nil
    elseif system == 'origen' then
        return exports[resource]:getItemData(item)
    elseif system == 'tg' then
        return exports[resource]:GetItemData(item)
    end

    lib.print.warn(('Item info retrieval not implemented for system: %s'):format(system))
    return nil
end

--- Closes the inventory UI
function lib.inventory.close()
    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        exports[resource]:closeInventory()
    elseif system == 'qs' then
        exports[resource]:closeInventory()
    elseif system == 'origen' then
        exports[resource]:CloseInventory()
    elseif system == 'tg' then
        exports[resource]:CloseInventory()
    elseif system == 'qb' then
        TriggerEvent('inventory:client:closeInventory')
    elseif system == 'codem' then
        exports[resource]:CloseInventory()
    else
        lib.print.warn(('Inventory closing not implemented for system: %s'):format(system))
    end
end

--- Opens the player's inventory
function lib.inventory.open()
    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        exports[resource]:openInventory()
    elseif system == 'qs' then
        exports[resource]:openInventory()
    elseif system == 'origen' then
        exports[resource]:OpenInventory()
    elseif system == 'tg' then
        exports[resource]:OpenInventory()
    elseif system == 'qb' then
        TriggerEvent('inventory:client:openInventory')
    elseif system == 'codem' then
        exports[resource]:OpenInventory()
    else
        lib.print.warn(('Inventory opening not implemented for system: %s'):format(system))
    end
end

--- Opens a shop by ID
---@param shopId string Shop identifier
---@param data? table Additional shop data
function lib.inventory.openShop(shopId, data)
    if not lib.assert.type(shopId, 'string', 'Shop ID') then
        return
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return
    end

    data = data or {}
    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        exports[resource]:openInventory('shop', shopId)
    elseif system == 'qs' then
        exports[resource]:openShop(shopId)
    elseif system == 'qb' then
        TriggerServerEvent('inventory:server:OpenInventory', 'shop', shopId, data)
    elseif system == 'codem' then
        exports[resource]:OpenShop(shopId)
    elseif system == 'origen' then
        exports[resource]:openShop(shopId, data)
    elseif system == 'tg' then
        exports[resource]:OpenShop(shopId, data)
    else
        lib.print.warn(('Shop opening not implemented for system: %s'):format(system))
    end
end

--- Gets the current inventory weight and maximum weight
---@return number currentWeight Current inventory weight
---@return number maxWeight Maximum inventory weight
function lib.inventory.getWeight()
    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return 0, 0
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        local weight = exports[resource]:getCurrentWeight()
        local maxWeight = exports[resource]:getMaxWeight()
        return weight or 0, maxWeight or 0
    elseif system == 'qs' then
        local weight = exports[resource]:GetCurrentWeight()
        local maxWeight = exports[resource]:GetMaxWeight()
        return weight or 0, maxWeight or 0
    elseif system == 'qb' then
        if not lib.framework.isAvailable() then
            lib.print.error('Framework not available for QB inventory')
            return 0, 0
        end

        local PlayerData = lib.framework.getPlayerData()
        if PlayerData and PlayerData.metadata then
            return PlayerData.metadata.currentweight or 0, PlayerData.metadata.maxweight or 0
        end
        return 0, 0
    elseif system == 'codem' then
        local weight = exports[resource]:GetCurrentWeight()
        local maxWeight = exports[resource]:GetMaxWeight()
        return weight or 0, maxWeight or 0
    elseif system == 'origen' then
        local weight = exports[resource]:getCurrentWeight()
        local maxWeight = exports[resource]:getMaxWeight()
        return weight or 0, maxWeight or 0
    elseif system == 'tg' then
        local weight = exports[resource]:GetCurrentWeight()
        local maxWeight = exports[resource]:GetMaxWeight()
        return weight or 0, maxWeight or 0
    end

    lib.print.warn(('Weight retrieval not implemented for system: %s'):format(system))
    return 0, 0
end

--- Checks if the inventory has enough space for an item
---@param item string Item name
---@param amount number Item amount
---@return boolean hasSpace Whether there's enough space
function lib.inventory.hasSpace(item, amount)
    if not lib.assert.type(item, 'string', 'Item name') then
        return false
    end

    if type(amount) ~= 'number' or amount < 1 then
        lib.print.error('Amount must be a positive number')
        return false
    end

    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return false
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return exports[resource]:CanCarryItem(item, amount) or false
    elseif system == 'qs' then
        return exports[resource]:CanCarryItem(item, amount) or false
    elseif system == 'qb' then
        -- For QB, we need to check weight and slots
        local itemInfo = lib.inventory.getItemInfo(item)
        if not itemInfo then
            return false
        end

        local currentWeight, maxWeight = lib.inventory.getWeight()
        local itemWeight = (itemInfo.weight or 0) * amount

        return (currentWeight + itemWeight) <= maxWeight
    elseif system == 'codem' then
        return exports[resource]:CanCarryItem(item, amount) or false
    elseif system == 'origen' then
        return exports[resource]:canCarryItem(item, amount) or false
    elseif system == 'tg' then
        return exports[resource]:CanCarryItem(item, amount) or false
    end

    lib.print.warn(('Space checking not implemented for system: %s'):format(system))
    return false
end

--- Gets the number of free slots in the inventory
---@return number freeSlots Number of free slots
function lib.inventory.getFreeSlots()
    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return 0
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        return exports[resource]:GetEmptySlots() or 0
    elseif system == 'qs' then
        return exports[resource]:GetFreeSlots() or 0
    elseif system == 'qb' then
        local inventory = lib.inventory.getPlayerInventory()
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
        return exports[resource]:GetFreeSlots() or 0
    elseif system == 'origen' then
        return exports[resource]:getFreeSlots() or 0
    elseif system == 'tg' then
        return exports[resource]:GetFreeSlots() or 0
    end

    lib.print.warn(('Free slots retrieval not implemented for system: %s'):format(system))
    return 0
end

--- Refreshes the inventory UI
function lib.inventory.refresh()
    if not lib.inventory.system then
        lib.print.error('Inventory system not initialized')
        return
    end

    local system = lib.inventory.system
    local resource = lib.inventory.resource

    if system == 'ox' then
        -- ox_inventory handles this automatically
        lib.print.debug('ox_inventory handles refresh automatically')
    elseif system == 'qs' then
        exports[resource]:RefreshInventory()
    elseif system == 'qb' then
        TriggerEvent('inventory:client:refreshInventory')
    elseif system == 'codem' then
        exports[resource]:RefreshInventory()
    elseif system == 'origen' then
        exports[resource]:refreshInventory()
    elseif system == 'tg' then
        exports[resource]:RefreshInventory()
    else
        lib.print.warn(('Inventory refresh not implemented for system: %s'):format(system))
    end
end

--- Gets inventory statistics
---@return table stats Inventory statistics
function lib.inventory.getStats()
    local currentWeight, maxWeight = lib.inventory.getWeight()
    local freeSlots = lib.inventory.getFreeSlots()
    local inventory = lib.inventory.getPlayerInventory()

    local stats = {
        currentWeight = currentWeight,
        maxWeight = maxWeight,
        weightPercentage = maxWeight > 0 and math.floor((currentWeight / maxWeight) * 100) or 0,
        freeSlots = freeSlots,
        totalItems = inventory and #inventory or 0,
        isOpen = lib.inventory.isOpen(),
        system = lib.inventory.system,
        resource = lib.inventory.resource
    }

    return stats
end

--- Register callback for server requests
lib.callback.register('ox_lib:inventory:hasItem', function(items)
    return lib.inventory.hasItem(items)
end)

lib.callback.register('ox_lib:inventory:hasItems', function(items, amount)
    return lib.inventory.hasItems(items, amount)
end)

lib.callback.register('ox_lib:inventory:getPlayerInventory', function()
    return lib.inventory.getPlayerInventory()
end)

lib.callback.register('ox_lib:inventory:hasSpace', function(item, amount)
    return lib.inventory.hasSpace(item, amount)
end)

lib.callback.register('ox_lib:inventory:getStats', function()
    return lib.inventory.getStats()
end)

--- Export functions for backwards compatibility
HasItem = lib.inventory.hasItem
GetPlayerInventory = lib.inventory.getPlayerInventory
OpenStash = lib.inventory.openStash

return lib.inventory
