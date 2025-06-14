--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxBlips
---@field requestSync fun(): nil Request full sync from server
---@field getCategories fun(): table<string, BlipCategory> Get all categories
---@field getBlips fun(): table<number, BlipData> Get all blips
---@field getBlipsByCategory fun(categoryId: string): table<number, BlipData> Get blips by category
---@field setBlipCategory fun(blip: number, categoryName: string): boolean Set blip category
---@field createBlip fun(data: BlipCreateData): number? Create a blip manually
---@field removeBlip fun(blipHandle: number): boolean Remove a blip by handle
---@field getStats fun(): BlipStats Get blip statistics
---@field clearAll fun(): nil Clear all managed blips
lib.blips = {}

---@class BlipCategory
---@field id string Unique category identifier
---@field label string Display label for the category
---@field description string? Optional description
---@field restrictions BlipRestrictions? Access restrictions
---@field enabled boolean Whether the category is enabled
---@field created number Timestamp when created
---@field blipCount number Number of blips in this category

---@class BlipData
---@field id number Unique blip identifier
---@field coords vector3 Blip coordinates
---@field sprite number Blip sprite ID
---@field color number Blip color ID
---@field scale number Blip scale (default: 1.0)
---@field label string Blip display label
---@field shortRange boolean Whether blip is short range
---@field category string? Category ID this blip belongs to
---@field restrictions BlipRestrictions? Access restrictions
---@field enabled boolean Whether the blip is enabled
---@field created number Timestamp when created
---@field metadata table? Additional metadata
---@field alpha number? Blip transparency (0-255)
---@field rotation number? Blip rotation in degrees
---@field display number? Blip display type

---@class BlipRestrictions
---@field jobs string[]? List of allowed job names
---@field gangs string[]? List of allowed gang names
---@field minGrade number? Minimum job grade required

---@class BlipCreateData
---@field coords vector3 Blip coordinates
---@field sprite number? Blip sprite ID (default: 1)
---@field color number? Blip color ID (default: 0)
---@field scale number? Blip scale (default: 1.0)
---@field label string? Blip display label
---@field shortRange boolean? Whether blip is short range (default: false)
---@field category string? Category name for blip organization
---@field alpha number? Blip transparency (0-255)
---@field rotation number? Blip rotation in degrees
---@field display number? Blip display type

---@class BlipStats
---@field totalCategories number Total number of categories
---@field totalBlips number Total number of blips
---@field renderedBlips number Number of currently rendered blips
---@field usedCategoryIds number Number of used FiveM category IDs
---@field nextCategoryId number Next available category ID
---@field maxCategories number Maximum allowed categories
---@field categoriesEnabled boolean Whether FiveM categories are enabled

---@class BlipInternalData
---@field categories table<string, BlipCategory> Category storage
---@field blips table<number, BlipData> Blip storage
---@field renderedBlips table<number, number> Rendered blip handles

---@class CategoryManager
---@field busyCategories table<string, number> Category name to ID mapping
---@field categoryIndexes table<number, boolean> Used category ID tracking
---@field nextCategoryId number Next available category ID

---@class BlipConfig
---@field debug boolean Enable debug logging
---@field useFiveMCategories boolean Use FiveM's category system
---@field maxCategories number Maximum number of categories (12-133 range)

-- Internal storage for blip management
local blipData = {
    categories = {},
    blips = {},
    renderedBlips = {}
}

-- FiveM category management system
local categoryManager = {
    busyCategories = {},
    categoryIndexes = {},
    nextCategoryId = 12 -- Start from 12 as per FiveM documentation
}

-- Configuration loaded from convars
local config = {
    debug = GetConvarBool('ox:blips:debug', false),
    useFiveMCategories = GetConvarBool('ox:blips:categories', true),
    maxCategories = GetConvarInt('ox:blips:maxCategories', 121) -- 12-133 range
}

---Debug logging utility
---@param message string The debug message to log
---@param data table? Optional data to include in verbose logging
---@return nil
local function debugLog(message, data)
    if not config.debug then return end

    lib.print.debug(('[Blips] %s'):format(message))
    if data and lib.print.verbose then
        lib.print.verbose(json.encode(data, { indent = true }))
    end
end

---Get the next available FiveM category ID
---@return number? categoryId The next available category ID, or nil if none available
local function getNextCategoryId()
    for i = categoryManager.nextCategoryId, config.maxCategories do
        if not categoryManager.categoryIndexes[i] then
            categoryManager.categoryIndexes[i] = true
            categoryManager.nextCategoryId = i + 1
            return i
        end
    end

    lib.print.warn('No available category IDs left')
    return nil
end

---Set blip category using FiveM's native category system
---@param blip number The blip handle to categorize
---@param categoryName string The category name to assign
---@return boolean success Whether the category was successfully set
local function setBlipCategory(blip, categoryName)
    if not config.useFiveMCategories or not DoesBlipExist(blip) then
        return false
    end

    local categoryId = categoryManager.busyCategories[categoryName]

    if not categoryId then
        categoryId = getNextCategoryId()
        if not categoryId then
            lib.print.error(('No available category IDs for category: %s'):format(categoryName))
            return false
        end

        categoryManager.busyCategories[categoryName] = categoryId
        AddTextEntry(('BLIP_CAT_%d'):format(categoryId), categoryName)

        debugLog('Created FiveM category', {
            name = categoryName,
            id = categoryId
        })
    end

    SetBlipCategory(blip, categoryId)
    return true
end

---Create a blip on the map with full property configuration
---@param blipId number The unique identifier for this blip
---@param blipInfo BlipData The blip configuration data
---@return boolean success Whether the blip was successfully created
local function createBlip(blipId, blipInfo)
    if not lib.assert.type(blipInfo, 'table', 'Blip info') then
        return false
    end

    if not lib.assert.type(blipInfo.coords, 'table', 'Blip coordinates') then
        return false
    end

    -- Remove existing blip if it exists
    if blipData.renderedBlips[blipId] then
        RemoveBlip(blipData.renderedBlips[blipId])
        blipData.renderedBlips[blipId] = nil
    end

    local coords = blipInfo.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z or 0.0)

    if not DoesBlipExist(blip) then
        lib.print.error(('Failed to create blip %d'):format(blipId))
        return false
    end

    -- Configure blip properties
    SetBlipSprite(blip, blipInfo.sprite or 1)
    SetBlipScale(blip, blipInfo.scale or 1.0)
    SetBlipColour(blip, blipInfo.color or 0)
    SetBlipAsShortRange(blip, blipInfo.shortRange or false)

    -- Set blip label if provided
    if blipInfo.label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipInfo.label)
        EndTextCommandSetBlipName(blip)
    end

    -- Apply category if available and valid
    if blipInfo.category and blipData.categories[blipInfo.category] then
        setBlipCategory(blip, blipData.categories[blipInfo.category].label)
    end

    -- Apply optional properties
    if blipInfo.alpha then
        SetBlipAlpha(blip, blipInfo.alpha)
    end

    if blipInfo.rotation then
        SetBlipRotation(blip, blipInfo.rotation)
    end

    if blipInfo.display then
        SetBlipDisplay(blip, blipInfo.display)
    end

    blipData.renderedBlips[blipId] = blip

    debugLog('Blip created successfully', {
        blipId = blipId,
        handle = blip,
        category = blipInfo.category,
        label = blipInfo.label
    })

    return true
end

---Remove a blip from the map and clean up resources
---@param blipId number The unique identifier of the blip to remove
---@return boolean success Whether the blip was successfully removed
local function removeBlip(blipId)
    local blipHandle = blipData.renderedBlips[blipId]
    if blipHandle and DoesBlipExist(blipHandle) then
        RemoveBlip(blipHandle)
        blipData.renderedBlips[blipId] = nil

        debugLog('Blip removed successfully', { blipId = blipId })
        return true
    end

    return false
end

---Update an existing blip by recreating it with new properties
---@param blipId number The unique identifier of the blip to update
---@param blipInfo BlipData The updated blip configuration data
---@return boolean success Whether the blip was successfully updated
local function updateBlip(blipId, blipInfo)
    -- For updates, recreate the blip to ensure all properties are applied correctly
    return createBlip(blipId, blipInfo)
end

---Handle category creation event from server
---@param categoryId string The unique category identifier
---@param categoryInfo BlipCategory The category configuration data
---@return nil
local function onCategoryCreated(categoryId, categoryInfo)
    if not lib.assert.type(categoryId, 'string', 'Category ID') then
        return
    end

    if not lib.assert.type(categoryInfo, 'table', 'Category info') then
        return
    end

    blipData.categories[categoryId] = categoryInfo

    debugLog('Category received from server', {
        categoryId = categoryId,
        info = categoryInfo
    })

    -- Update any existing blips that belong to this category
    for blipId, blipInfo in pairs(blipData.blips) do
        if blipInfo.category == categoryId then
            updateBlip(blipId, blipInfo)
        end
    end
end

---Handle category removal event from server
---@param categoryId string The unique category identifier to remove
---@return nil
local function onCategoryRemoved(categoryId)
    if not categoryId then return end

    -- Remove all blips that belong to this category
    for blipId, blipInfo in pairs(blipData.blips) do
        if blipInfo.category == categoryId then
            removeBlip(blipId)
            blipData.blips[blipId] = nil
        end
    end

    -- Clean up category data and free FiveM category ID
    local category = blipData.categories[categoryId]
    if category then
        local categoryLabel = category.label

        -- Free up the FiveM category ID for reuse
        local categoryIdNum = categoryManager.busyCategories[categoryLabel]
        if categoryIdNum then
            categoryManager.categoryIndexes[categoryIdNum] = nil
            categoryManager.busyCategories[categoryLabel] = nil
        end

        blipData.categories[categoryId] = nil
    end

    debugLog('Category removed successfully', { categoryId = categoryId })
end

---Handle blip addition event from server
---@param blipId number The unique blip identifier
---@param blipInfo BlipData The blip configuration data
---@return nil
local function onBlipAdded(blipId, blipInfo)
    if not blipId or not blipInfo then return end

    blipData.blips[blipId] = blipInfo
    createBlip(blipId, blipInfo)
end

---Handle blip removal event from server
---@param blipId number The unique blip identifier to remove
---@return nil
local function onBlipRemoved(blipId)
    if not blipId then return end

    removeBlip(blipId)
    blipData.blips[blipId] = nil
end

---Handle blip update event from server
---@param blipId number The unique blip identifier
---@param blipInfo BlipData The updated blip configuration data
---@return nil
local function onBlipUpdated(blipId, blipInfo)
    if not blipId or not blipInfo then return end

    blipData.blips[blipId] = blipInfo
    updateBlip(blipId, blipInfo)
end

---Handle full synchronization event from server
---@param categories table<string, BlipCategory> All categories from server
---@param blips table<number, BlipData> All blips from server
---@return nil
local function onFullSync(categories, blips)
    -- Clean up existing blips before applying new data
    for blipId, blipHandle in pairs(blipData.renderedBlips) do
        if DoesBlipExist(blipHandle) then
            RemoveBlip(blipHandle)
        end
    end

    -- Reset internal data structures
    blipData.categories = categories or {}
    blipData.blips = blips or {}
    blipData.renderedBlips = {}

    -- Create all blips from server data
    for blipId, blipInfo in pairs(blipData.blips) do
        createBlip(blipId, blipInfo)
    end

    debugLog('Full synchronization completed', {
        categoryCount = lib.table.count(blipData.categories),
        blipCount = lib.table.count(blipData.blips)
    })
end

-- Public API Functions

---Request full synchronization from server
---@return nil
function lib.blips.requestSync()
    TriggerServerEvent('ox_lib:blips:requestSync')
end

---Get all available categories
---@return table<string, BlipCategory> categories All category data
function lib.blips.getCategories()
    return blipData.categories
end

---Get all available blips
---@return table<number, BlipData> blips All blip data
function lib.blips.getBlips()
    return blipData.blips
end

---Get all blips belonging to a specific category
---@param categoryId string The category identifier to filter by
---@return table<number, BlipData> blips Blips in the specified category
function lib.blips.getBlipsByCategory(categoryId)
    if not lib.assert.type(categoryId, 'string', 'Category ID') then
        return {}
    end

    local categoryBlips = {}
    for blipId, blip in pairs(blipData.blips) do
        if blip.category == categoryId then
            categoryBlips[blipId] = blip
        end
    end
    return categoryBlips
end

---Set blip category for an existing blip handle
---@param blip number The blip handle to categorize
---@param categoryName string The category name to assign
---@return boolean success Whether the category was successfully applied
function lib.blips.setBlipCategory(blip, categoryName)
    if not lib.assert.type(blip, 'number', 'Blip handle') then
        return false
    end

    if not lib.assert.type(categoryName, 'string', 'Category name') then
        return false
    end

    return setBlipCategory(blip, categoryName)
end

---Create a blip manually with full configuration options
---@param data BlipCreateData The blip configuration data
---@return number? blipHandle The created blip handle, or nil if creation failed
function lib.blips.createBlip(data)
    if not lib.assert.type(data, 'table', 'Blip data') then
        return nil
    end

    if not data.coords then
        lib.print.error('Blip coordinates are required')
        return nil
    end

    local coords = data.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z or 0.0)

    if not DoesBlipExist(blip) then
        lib.print.error('Failed to create manual blip')
        return nil
    end

    -- Apply all blip properties
    if data.sprite then SetBlipSprite(blip, data.sprite) end
    if data.scale then SetBlipScale(blip, data.scale) end
    if data.color then SetBlipColour(blip, data.color) end
    if data.alpha then SetBlipAlpha(blip, data.alpha) end
    if data.rotation then SetBlipRotation(blip, data.rotation) end
    if data.display then SetBlipDisplay(blip, data.display) end
    if data.shortRange ~= nil then SetBlipAsShortRange(blip, data.shortRange) end

    -- Set blip label if provided
    if data.label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.label)
        EndTextCommandSetBlipName(blip)
    end

    -- Apply category if specified
    if data.category then
        setBlipCategory(blip, data.category)
    end

    debugLog('Manual blip created successfully', {
        handle = blip,
        coords = data.coords,
        label = data.label,
        category = data.category
    })

    return blip
end

---Remove a blip by its handle
---@param blipHandle number The blip handle to remove
---@return boolean success Whether the blip was successfully removed
function lib.blips.removeBlip(blipHandle)
    if not lib.assert.type(blipHandle, 'number', 'Blip handle') then
        return false
    end

    if DoesBlipExist(blipHandle) then
        RemoveBlip(blipHandle)
        debugLog('Manual blip removed successfully', { handle = blipHandle })
        return true
    end

    return false
end

---Get comprehensive statistics about the blip system
---@return BlipStats stats Current system statistics
function lib.blips.getStats()
    return {
        totalCategories = lib.table.count(blipData.categories),
        totalBlips = lib.table.count(blipData.blips),
        renderedBlips = lib.table.count(blipData.renderedBlips),
        usedCategoryIds = lib.table.count(categoryManager.busyCategories),
        nextCategoryId = categoryManager.nextCategoryId,
        maxCategories = config.maxCategories,
        categoriesEnabled = config.useFiveMCategories
    }
end

---Clear all managed blips and reset the system
---@return nil
function lib.blips.clearAll()
    for blipId in pairs(blipData.renderedBlips) do
        removeBlip(blipId)
    end

    blipData.categories = {}
    blipData.blips = {}
    blipData.renderedBlips = {}

    debugLog('All managed blips cleared successfully')
end

-- Event Registration
RegisterNetEvent('ox_lib:blips:categoryCreated', onCategoryCreated)
RegisterNetEvent('ox_lib:blips:categoryRemoved', onCategoryRemoved)
RegisterNetEvent('ox_lib:blips:blipAdded', onBlipAdded)
RegisterNetEvent('ox_lib:blips:blipRemoved', onBlipRemoved)
RegisterNetEvent('ox_lib:blips:blipUpdated', onBlipUpdated)
RegisterNetEvent('ox_lib:blips:fullSync', onFullSync)

-- System Initialization
CreateThread(function()
    Wait(1000) -- Allow other systems to initialize first
    lib.blips.requestSync()
    debugLog('Blip system initialized and sync requested')
end)

-- Resource Cleanup Handler
AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        lib.blips.clearAll()

        -- Reset category management
        categoryManager.categoryIndexes = {}
        categoryManager.busyCategories = {}
        categoryManager.nextCategoryId = 12

        debugLog('Resource cleanup completed')
    end
end)

-- Export the blips module
return lib.blips
