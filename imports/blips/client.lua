--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxBlips
lib.blips = {}

local blipData = {
    categories = {},
    blips = {},
    renderedBlips = {}
}

local categoryManager = {
    busyCategories = {},
    categoryIndexes = {},
    nextCategoryId = 12 -- Start from 12 as per FiveM documentation
}

local config = {
    debug = GetConvarBool('ox:blips:debug', false),
    useFiveMCategories = GetConvarBool('ox:blips:categories', true),
    maxCategories = GetConvarInt('ox:blips:maxCategories', 121) -- 12-133 range
}

--- Debug logging
---@param message string
---@param data? table
local function debugLog(message, data)
    if not config.debug then return end

    lib.print.debug(('[Blips] %s'):format(message))
    if data and lib.print.verbose then
        lib.print.verbose(json.encode(data, { indent = true }))
    end
end

--- Get next available category ID for FiveM categories
---@return number? categoryId
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

--- Set blip category using FiveM's category system
---@param blip number The blip handle
---@param categoryName string The category name
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

--- Create a blip on the map
---@param blipId number
---@param blipInfo table
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

    -- Set blip properties
    SetBlipSprite(blip, blipInfo.sprite or 1)
    SetBlipScale(blip, blipInfo.scale or 1.0)
    SetBlipColour(blip, blipInfo.color or 0)
    SetBlipAsShortRange(blip, blipInfo.shortRange or false)

    -- Set blip name
    if blipInfo.label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipInfo.label)
        EndTextCommandSetBlipName(blip)
    end

    -- Set category if available
    if blipInfo.category and blipData.categories[blipInfo.category] then
        setBlipCategory(blip, blipData.categories[blipInfo.category].label)
    end

    -- Set additional properties
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

    debugLog('Blip created', {
        blipId = blipId,
        handle = blip,
        category = blipInfo.category,
        label = blipInfo.label
    })

    return true
end

--- Remove a blip from the map
---@param blipId number
local function removeBlip(blipId)
    local blipHandle = blipData.renderedBlips[blipId]
    if blipHandle and DoesBlipExist(blipHandle) then
        RemoveBlip(blipHandle)
        blipData.renderedBlips[blipId] = nil

        debugLog('Blip removed', { blipId = blipId })
        return true
    end

    return false
end

--- Update a blip on the map
---@param blipId number
---@param blipInfo table
local function updateBlip(blipId, blipInfo)
    -- For updates, recreate the blip to ensure all properties are applied
    return createBlip(blipId, blipInfo)
end

--- Handle category creation
---@param categoryId string
---@param categoryInfo table
local function onCategoryCreated(categoryId, categoryInfo)
    if not lib.assert.type(categoryId, 'string', 'Category ID') then
        return
    end

    if not lib.assert.type(categoryInfo, 'table', 'Category info') then
        return
    end

    blipData.categories[categoryId] = categoryInfo

    debugLog('Category received', {
        categoryId = categoryId,
        info = categoryInfo
    })

    -- Update any existing blips in this category
    for blipId, blipInfo in pairs(blipData.blips) do
        if blipInfo.category == categoryId then
            updateBlip(blipId, blipInfo)
        end
    end
end

--- Handle category removal
---@param categoryId string
local function onCategoryRemoved(categoryId)
    if not categoryId then return end

    -- Remove all blips in this category
    for blipId, blipInfo in pairs(blipData.blips) do
        if blipInfo.category == categoryId then
            removeBlip(blipId)
            blipData.blips[blipId] = nil
        end
    end

    -- Clean up category data
    local category = blipData.categories[categoryId]
    if category then
        local categoryLabel = category.label

        -- Free up the FiveM category ID
        local categoryIdNum = categoryManager.busyCategories[categoryLabel]
        if categoryIdNum then
            categoryManager.categoryIndexes[categoryIdNum] = nil
            categoryManager.busyCategories[categoryLabel] = nil
        end

        blipData.categories[categoryId] = nil
    end

    debugLog('Category removed', { categoryId = categoryId })
end

--- Handle blip addition
---@param blipId number
---@param blipInfo table
local function onBlipAdded(blipId, blipInfo)
    if not blipId or not blipInfo then return end

    blipData.blips[blipId] = blipInfo
    createBlip(blipId, blipInfo)
end

--- Handle blip removal
---@param blipId number
local function onBlipRemoved(blipId)
    if not blipId then return end

    removeBlip(blipId)
    blipData.blips[blipId] = nil
end

--- Handle blip update
---@param blipId number
---@param blipInfo table
local function onBlipUpdated(blipId, blipInfo)
    if not blipId or not blipInfo then return end

    blipData.blips[blipId] = blipInfo
    updateBlip(blipId, blipInfo)
end

--- Handle full sync from server
---@param categories table
---@param blips table
local function onFullSync(categories, blips)
    -- Clear existing blips
    for blipId, blipHandle in pairs(blipData.renderedBlips) do
        if DoesBlipExist(blipHandle) then
            RemoveBlip(blipHandle)
        end
    end

    -- Reset data
    blipData.categories = categories or {}
    blipData.blips = blips or {}
    blipData.renderedBlips = {}

    -- Create all blips
    for blipId, blipInfo in pairs(blipData.blips) do
        createBlip(blipId, blipInfo)
    end

    debugLog('Full sync completed', {
        categoryCount = lib.table.count(blipData.categories),
        blipCount = lib.table.count(blipData.blips)
    })
end

--- Request sync from server
function lib.blips.requestSync()
    TriggerServerEvent('ox_lib:blips:requestSync')
end

--- Get all categories
---@return table categories
function lib.blips.getCategories()
    return blipData.categories
end

--- Get all blips
---@return table blips
function lib.blips.getBlips()
    return blipData.blips
end

--- Get blips by category
---@param categoryId string
---@return table blips
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

--- Set blip category (export function)
---@param blip number The blip handle
---@param categoryName string The category name
---@return boolean success
function lib.blips.setBlipCategory(blip, categoryName)
    if not lib.assert.type(blip, 'number', 'Blip handle') then
        return false
    end

    if not lib.assert.type(categoryName, 'string', 'Category name') then
        return false
    end

    return setBlipCategory(blip, categoryName)
end

--- Create a blip manually
---@param data table Blip data
---@return number? blipHandle The blip handle or nil if failed
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

    -- Apply properties
    if data.sprite then SetBlipSprite(blip, data.sprite) end
    if data.scale then SetBlipScale(blip, data.scale) end
    if data.color then SetBlipColour(blip, data.color) end
    if data.alpha then SetBlipAlpha(blip, data.alpha) end
    if data.rotation then SetBlipRotation(blip, data.rotation) end
    if data.display then SetBlipDisplay(blip, data.display) end
    if data.shortRange ~= nil then SetBlipAsShortRange(blip, data.shortRange) end

    if data.label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.label)
        EndTextCommandSetBlipName(blip)
    end

    if data.category then
        setBlipCategory(blip, data.category)
    end

    return blip
end

--- Remove a blip by handle
---@param blipHandle number The blip handle
---@return boolean success
function lib.blips.removeBlip(blipHandle)
    if not lib.assert.type(blipHandle, 'number', 'Blip handle') then
        return false
    end

    if DoesBlipExist(blipHandle) then
        RemoveBlip(blipHandle)
        return true
    end

    return false
end

--- Get blip statistics
---@return table stats
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

--- Clear all managed blips
function lib.blips.clearAll()
    for blipId in pairs(blipData.renderedBlips) do
        removeBlip(blipId)
    end

    blipData.categories = {}
    blipData.blips = {}
    blipData.renderedBlips = {}

    debugLog('All blips cleared')
end

-- Event handlers
RegisterNetEvent('ox_lib:blips:categoryCreated', onCategoryCreated)
RegisterNetEvent('ox_lib:blips:categoryRemoved', onCategoryRemoved)
RegisterNetEvent('ox_lib:blips:blipAdded', onBlipAdded)
RegisterNetEvent('ox_lib:blips:blipRemoved', onBlipRemoved)
RegisterNetEvent('ox_lib:blips:blipUpdated', onBlipUpdated)
RegisterNetEvent('ox_lib:blips:fullSync', onFullSync)

-- Initialize on resource start
CreateThread(function()
    Wait(1000) -- Wait for everything to load
    lib.blips.requestSync()
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        lib.blips.clearAll()
        categoryManager.categoryIndexes = {}
        categoryManager.busyCategories = {}
    end
end)

return lib.blips
