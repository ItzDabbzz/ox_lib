--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxBlips
lib.blips = {}

-- Blip storage and management
local blipData = {
    categories = {},
    blips = {},
    playerBlips = {}, -- Track which blips each player can see
    nextBlipId = 1
}

-- Configuration
local config = {
    debug = GetConvarBool('ox:blips:debug', false),
    syncInterval = GetConvarInt('ox:blips:syncInterval', 30000), -- 30 seconds
    maxBlipsPerCategory = GetConvarInt('ox:blips:maxPerCategory', 50),
    maxCategories = GetConvarInt('ox:blips:maxCategories', 20),
    useFiveMCategories = GetConvarBool('ox:blips:categories', true)
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

--- Validate blip data
---@param blipInfo table
---@return boolean success
---@return string? error
local function validateBlipData(blipInfo)
    if not lib.assert.type(blipInfo, 'table', 'Blip data') then
        return false, "Blip data must be a table"
    end

    -- Required fields
    local required = { 'coords', 'sprite', 'color', 'label' }
    for _, field in ipairs(required) do
        if not blipInfo[field] then
            return false, ('Missing required field: %s'):format(field)
        end
    end

    -- Validate coordinates
    if not lib.assert.type(blipInfo.coords, 'table', 'Coordinates') then
        return false, "Invalid coordinates format"
    end

    if not blipInfo.coords.x or not blipInfo.coords.y then
        return false, "Coordinates must have x and y values"
    end

    -- Validate sprite and color
    if not lib.assert.type(blipInfo.sprite, 'number', 'Sprite') then
        return false, "Sprite must be a number"
    end

    if not lib.assert.type(blipInfo.color, 'number', 'Color') then
        return false, "Color must be a number"
    end

    -- Validate label
    if not lib.assert.type(blipInfo.label, 'string', 'Label') then
        return false, "Label must be a string"
    end

    if lib.string.trim(blipInfo.label) == '' then
        return false, "Label cannot be empty"
    end

    return true
end

--- Validate access restrictions
---@param restrictions table?
---@return boolean success
---@return string? error
local function validateRestrictions(restrictions)
    if not restrictions then return true end

    if not lib.assert.type(restrictions, 'table', 'Restrictions') then
        return false, "Restrictions must be a table"
    end

    -- Validate jobs
    if restrictions.jobs then
        if not lib.assert.type(restrictions.jobs, 'table', 'Jobs restriction') then
            return false, "Jobs restriction must be a table"
        end

        for _, job in ipairs(restrictions.jobs) do
            if not lib.assert.type(job, 'string', 'Job name') then
                return false, "Job names must be strings"
            end
        end
    end

    -- Validate gangs
    if restrictions.gangs then
        if not lib.assert.type(restrictions.gangs, 'table', 'Gangs restriction') then
            return false, "Gangs restriction must be a table"
        end

        for _, gang in ipairs(restrictions.gangs) do
            if not lib.assert.type(gang, 'string', 'Gang name') then
                return false, "Gang names must be strings"
            end
        end
    end

    -- Validate grades
    if restrictions.minGrade and not lib.assert.type(restrictions.minGrade, 'number', 'Minimum grade') then
        return false, "Minimum grade must be a number"
    end

    return true
end

--- Get player job information based on framework
---@param playerId number
---@return table? jobInfo
local function getPlayerJobInfo(playerId)
    if not lib.framework.isAvailable() then
        debugLog('Framework not available')
        return nil
    end

    local player = lib.framework.getPlayer(playerId)
    if not player then
        debugLog('Player not found', { playerId = playerId })
        return nil
    end

    local framework = lib.framework.getName()

    if framework == 'esx' then
        local job = player.getJob()
        return {
            name = job.name,
            grade = job.grade,
            gang = nil -- ESX doesn't have gangs by default
        }
    elseif framework == 'qb' or framework == 'qbx' then
        return {
            name = player.PlayerData.job.name,
            grade = player.PlayerData.job.grade.level,
            gang = player.PlayerData.gang and player.PlayerData.gang.name or nil
        }
    end

    return nil
end

--- Check if player can see blip based on restrictions
---@param playerId number
---@param restrictions table?
---@return boolean canSee
local function canPlayerSeeBlip(playerId, restrictions)
    if not restrictions then return true end

    local jobInfo = getPlayerJobInfo(playerId)
    if not jobInfo then return false end

    -- Check job restrictions
    if restrictions.jobs then
        local hasJob = false
        for _, job in ipairs(restrictions.jobs) do
            if jobInfo.name == job then
                hasJob = true
                break
            end
        end
        if not hasJob then return false end
    end

    -- Check gang restrictions
    if restrictions.gangs and jobInfo.gang then
        local hasGang = false
        for _, gang in ipairs(restrictions.gangs) do
            if jobInfo.gang == gang then
                hasGang = true
                break
            end
        end
        if not hasGang then return false end
    end

    -- Check minimum grade
    if restrictions.minGrade and jobInfo.grade < restrictions.minGrade then
        return false
    end

    return true
end

--- Create a new blip category
---@param categoryId string Unique category identifier
---@param categoryInfo table Category information
---@return boolean success
---@return string? error
function lib.blips.createCategory(categoryId, categoryInfo)
    -- Validate category ID
    if not lib.assert.type(categoryId, 'string', 'Category ID') then
        return false, "Category ID must be a string"
    end

    if lib.string.trim(categoryId) == '' then
        return false, "Category ID cannot be empty"
    end

    -- Validate category info
    if not lib.assert.type(categoryInfo, 'table', 'Category info') then
        return false, "Category info must be a table"
    end

    if not categoryInfo.label or lib.string.trim(categoryInfo.label) == '' then
        return false, "Category must have a label"
    end

    -- Check limits
    local categoryCount = lib.table.count(blipData.categories)
    if categoryCount >= config.maxCategories then
        return false, ('Maximum categories limit reached (%d)'):format(config.maxCategories)
    end

    -- Check if category already exists
    if blipData.categories[categoryId] then
        return false, ('Category "%s" already exists'):format(categoryId)
    end

    -- Validate restrictions
    local isValid, error = validateRestrictions(categoryInfo.restrictions)
    if not isValid then return false, error end

    -- Create category
    blipData.categories[categoryId] = {
        id = categoryId,
        label = lib.string.trim(categoryInfo.label),
        description = categoryInfo.description or "",
        restrictions = categoryInfo.restrictions,
        enabled = categoryInfo.enabled ~= false,
        created = os.time(),
        blipCount = 0
    }

    debugLog('Category created', { categoryId = categoryId, info = categoryInfo })

    -- Sync with all players
    TriggerClientEvent('ox_lib:blips:categoryCreated', -1, categoryId, blipData.categories[categoryId])

    return true
end

--- Remove a blip category
---@param categoryId string
---@return boolean success
---@return string? error
function lib.blips.removeCategory(categoryId)
    if not blipData.categories[categoryId] then
        return false, ('Category "%s" does not exist'):format(categoryId)
    end

    -- Remove all blips in this category first
    local blipsToRemove = {}
    for blipId, blip in pairs(blipData.blips) do
        if blip.category == categoryId then
            blipsToRemove[#blipsToRemove + 1] = blipId
        end
    end

    for _, blipId in ipairs(blipsToRemove) do
        lib.blips.removeBlip(blipId)
    end

    -- Remove category
    blipData.categories[categoryId] = nil

    debugLog('Category removed', { categoryId = categoryId })

    -- Sync with all players
    TriggerClientEvent('ox_lib:blips:categoryRemoved', -1, categoryId)

    return true
end

--- Add a new blip
---@param blipInfo table Blip information
---@return number? blipId
---@return string? error
function lib.blips.addBlip(blipInfo)
    local isValid, error = validateBlipData(blipInfo)
    if not isValid then return nil, error end

    -- Validate category exists
    if blipInfo.category and not blipData.categories[blipInfo.category] then
        return nil, ('Category "%s" does not exist'):format(blipInfo.category)
    end

    -- Check category blip limit
    if blipInfo.category then
        local categoryBlipCount = 0
        for _, blip in pairs(blipData.blips) do
            if blip.category == blipInfo.category then
                categoryBlipCount = categoryBlipCount + 1
            end
        end

        if categoryBlipCount >= config.maxBlipsPerCategory then
            return nil, ('Category "%s" has reached maximum blips limit (%d)'):format(
                blipInfo.category, config.maxBlipsPerCategory)
        end
    end

    -- Validate restrictions
    isValid, error = validateRestrictions(blipInfo.restrictions)
    if not isValid then return nil, error end

    -- Generate unique blip ID
    local blipId = blipData.nextBlipId
    blipData.nextBlipId = blipData.nextBlipId + 1

    -- Create blip
    local blip = {
        id = blipId,
        coords = blipInfo.coords,
        sprite = blipInfo.sprite,
        color = blipInfo.color,
        scale = blipInfo.scale or 1.0,
        label = lib.string.trim(blipInfo.label),
        shortRange = blipInfo.shortRange or false,
        category = blipInfo.category,
        restrictions = blipInfo.restrictions,
        enabled = blipInfo.enabled ~= false,
        created = os.time(),
        metadata = blipInfo.metadata or {},
        alpha = blipInfo.alpha,
        rotation = blipInfo.rotation,
        display = blipInfo.display
    }

    blipData.blips[blipId] = blip

    -- Update category blip count
    if blip.category and blipData.categories[blip.category] then
        blipData.categories[blip.category].blipCount = blipData.categories[blip.category].blipCount + 1
    end

    debugLog('Blip added', { blipId = blipId, blip = blip })

    -- Sync with eligible players
    syncBlipToPlayers(blipId)

    return blipId
end

--- Remove a blip
---@param blipId number
---@return boolean success
---@return string? error
function lib.blips.removeBlip(blipId)
    local blip = blipData.blips[blipId]
    if not blip then
        return false, ('Blip %d does not exist'):format(blipId)
    end

    -- Update category blip count
    if blip.category and blipData.categories[blip.category] then
        blipData.categories[blip.category].blipCount = blipData.categories[blip.category].blipCount - 1
    end

    -- Remove from storage
    blipData.blips[blipId] = nil

    -- Remove from player tracking
    for playerId in pairs(blipData.playerBlips) do
        if blipData.playerBlips[playerId][blipId] then
            blipData.playerBlips[playerId][blipId] = nil
        end
    end

    debugLog('Blip removed', { blipId = blipId })

    -- Sync removal with all players
    TriggerClientEvent('ox_lib:blips:blipRemoved', -1, blipId)

    return true
end

--- Update a blip
---@param blipId number
---@param updates table
---@return boolean success
---@return string? error
function lib.blips.updateBlip(blipId, updates)
    local blip = blipData.blips[blipId]
    if not blip then
        return false, ('Blip %d does not exist'):format(blipId)
    end

    if not lib.assert.type(updates, 'table', 'Updates') then
        return false, "Updates must be a table"
    end

    -- Validate restrictions if being updated
    if updates.restrictions then
        local isValid, error = validateRestrictions(updates.restrictions)
        if not isValid then return false, error end
    end

    -- Apply updates
    for key, value in pairs(updates) do
        if key ~= 'id' and key ~= 'created' then -- Protect immutable fields
            blip[key] = value
        end
    end

    blip.updated = os.time()

    debugLog('Blip updated', { blipId = blipId, updates = updates })

    -- Re-sync with players (permissions might have changed)
    syncBlipToPlayers(blipId)

    return true
end

--- Sync a specific blip to eligible players
---@param blipId number
function syncBlipToPlayers(blipId)
    local blip = blipData.blips[blipId]
    if not blip or not blip.enabled then return end

    -- Check category enabled status
    if blip.category and blipData.categories[blip.category] and not blipData.categories[blip.category].enabled then
        return
    end

    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerIdNum = tonumber(playerId)
        if playerIdNum then
            local canSee = canPlayerSeeBlip(playerIdNum, blip.restrictions)

            -- Initialize player blip tracking if needed
            if not blipData.playerBlips[playerIdNum] then
                blipData.playerBlips[playerIdNum] = {}
            end

            local hadBlip = blipData.playerBlips[playerIdNum][blipId] ~= nil

            if canSee and not hadBlip then
                -- Player can see blip and doesn't have it yet
                blipData.playerBlips[playerIdNum][blipId] = true
                TriggerClientEvent('ox_lib:blips:blipAdded', playerIdNum, blipId, blip)
            elseif canSee and hadBlip then
                -- Player can see blip and already has it - update it
                TriggerClientEvent('ox_lib:blips:blipUpdated', playerIdNum, blipId, blip)
            elseif not canSee and hadBlip then
                -- Player can't see blip but has it - remove it
                blipData.playerBlips[playerIdNum][blipId] = nil
                TriggerClientEvent('ox_lib:blips:blipRemoved', playerIdNum, blipId)
            end
        end
    end
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

--- Get blip by ID
---@param blipId number
---@return table? blip
function lib.blips.getBlip(blipId)
    return blipData.blips[blipId]
end

--- Get category by ID
---@param categoryId string
---@return table? category
function lib.blips.getCategory(categoryId)
    return blipData.categories[categoryId]
end

--- Enable/disable a category
---@param categoryId string
---@param enabled boolean
---@return boolean success
---@return string? error
function lib.blips.setCategoryEnabled(categoryId, enabled)
    local category = blipData.categories[categoryId]
    if not category then
        return false, ('Category "%s" does not exist'):format(categoryId)
    end

    category.enabled = enabled
    category.updated = os.time()

    debugLog('Category enabled status changed', { categoryId = categoryId, enabled = enabled })

    -- Re-sync all blips in this category
    for blipId, blip in pairs(blipData.blips) do
        if blip.category == categoryId then
            syncBlipToPlayers(blipId)
        end
    end

    return true
end

--- Enable/disable a blip
---@param blipId number
---@param enabled boolean
---@return boolean success
---@return string? error
function lib.blips.setBlipEnabled(blipId, enabled)
    local blip = blipData.blips[blipId]
    if not blip then
        return false, ('Blip %d does not exist'):format(blipId)
    end

    blip.enabled = enabled
    blip.updated = os.time()

    debugLog('Blip enabled status changed', { blipId = blipId, enabled = enabled })

    -- Re-sync this blip
    syncBlipToPlayers(blipId)

    return true
end

--- Get blip statistics
---@return table stats
function lib.blips.getStats()
    local stats = {
        totalCategories = lib.table.count(blipData.categories),
        totalBlips = lib.table.count(blipData.blips),
        enabledCategories = 0,
        enabledBlips = 0,
        blipsByCategory = {},
        playersTracked = lib.table.count(blipData.playerBlips),
        nextBlipId = blipData.nextBlipId,
        config = config
    }

    -- Count enabled categories and blips
    for _, category in pairs(blipData.categories) do
        if category.enabled then
            stats.enabledCategories = stats.enabledCategories + 1
        end
        stats.blipsByCategory[category.id] = category.blipCount
    end

    for _, blip in pairs(blipData.blips) do
        if blip.enabled then
            stats.enabledBlips = stats.enabledBlips + 1
        end
    end

    return stats
end

--- Clear all blips and categories
---@return boolean success
function lib.blips.clearAll()
    blipData.categories = {}
    blipData.blips = {}
    blipData.playerBlips = {}
    blipData.nextBlipId = 1

    debugLog('All blips and categories cleared')

    -- Sync clear with all players
    TriggerClientEvent('ox_lib:blips:fullSync', -1, {}, {})

    return true
end

--- Sync player's visible blips (called when player joins or job changes)
---@param playerId number
local function syncPlayerBlips(playerId)
    if not blipData.playerBlips[playerId] then
        blipData.playerBlips[playerId] = {}
    end

    local visibleBlips = {}
    local visibleCategories = {}

    -- Collect categories the player can see
    for categoryId, category in pairs(blipData.categories) do
        if category.enabled and canPlayerSeeBlip(playerId, category.restrictions) then
            visibleCategories[categoryId] = category
        end
    end

    -- Collect blips the player can see
    for blipId, blip in pairs(blipData.blips) do
        if blip.enabled then
            local categoryOk = true
            if blip.category then
                categoryOk = visibleCategories[blip.category] ~= nil
            end

            if categoryOk and canPlayerSeeBlip(playerId, blip.restrictions) then
                visibleBlips[blipId] = blip
                blipData.playerBlips[playerId][blipId] = true
            end
        end
    end

    debugLog('Player blips synced', {
        playerId = playerId,
        categoriesCount = lib.table.count(visibleCategories),
        blipsCount = lib.table.count(visibleBlips)
    })

    -- Send full sync to player
    TriggerClientEvent('ox_lib:blips:fullSync', playerId, visibleCategories, visibleBlips)
end

--- Handle player requesting sync
---@param playerId number
local function onPlayerRequestSync(playerId)
    debugLog('Player requested sync', { playerId = playerId })
    syncPlayerBlips(playerId)
end

--- Handle player job change (if framework supports it)
---@param playerId number
local function onPlayerJobChanged(playerId)
    debugLog('Player job changed, re-syncing blips', { playerId = playerId })

    -- Clear current player blips
    blipData.playerBlips[playerId] = {}

    -- Re-sync with new permissions
    syncPlayerBlips(playerId)
end

--- Periodic sync for all players (in case of missed updates)
local function periodicSync()
    if config.syncInterval <= 0 then return end

    CreateThread(function()
        while true do
            Wait(config.syncInterval)

            local players = GetPlayers()
            for _, playerId in ipairs(players) do
                local playerIdNum = tonumber(playerId)
                if playerIdNum then
                    syncPlayerBlips(playerIdNum)
                end
            end

            debugLog('Periodic sync completed', { playerCount = #players })
        end
    end)
end

--- Initialize default categories
local function initializeDefaultCategories()
    -- Create some default categories if none exist
    if lib.table.count(blipData.categories) == 0 then
        lib.blips.createCategory('general', {
            label = 'General',
            description = 'General purpose blips'
        })

        lib.blips.createCategory('jobs', {
            label = 'Jobs',
            description = 'Job-related blips'
        })

        lib.blips.createCategory('shops', {
            label = 'Shops',
            description = 'Shopping locations'
        })

        debugLog('Default categories created')
    end
end

-- Event handlers
RegisterNetEvent('ox_lib:blips:requestSync', onPlayerRequestSync)

-- Framework-specific job change events
if lib.framework.isAvailable() then
    local framework = lib.framework.getName()

    if framework == 'esx' then
        RegisterNetEvent('esx:setJob', function(playerId)
            onPlayerJobChanged(playerId)
        end)
    elseif framework == 'qb' or framework == 'qbx' then
        RegisterNetEvent('QBCore:Server:OnJobUpdate', function(playerId)
            onPlayerJobChanged(playerId)
        end)

        RegisterNetEvent('QBCore:Server:OnGangUpdate', function(playerId)
            onPlayerJobChanged(playerId)
        end)
    end
end

-- Clean up player data when they disconnect
AddEventHandler('playerDropped', function()
    local playerId = source
    blipData.playerBlips[playerId] = nil
    debugLog('Player data cleaned up', { playerId = playerId })
end)

-- Initialize system
CreateThread(function()
    Wait(2000) -- Wait for framework to load

    initializeDefaultCategories()
    periodicSync()

    lib.print.info('Blips system initialized')
    debugLog('System initialized', {
        categories = lib.table.count(blipData.categories),
        blips = lib.table.count(blipData.blips),
        config = config
    })
end)

-- Callbacks for external scripts
lib.callback.register('ox_lib:blips:getCategories', function()
    return blipData.categories
end)

lib.callback.register('ox_lib:blips:getBlips', function()
    return blipData.blips
end)

lib.callback.register('ox_lib:blips:getStats', function()
    return lib.blips.getStats()
end)

-- Commands for debugging (only in debug mode)
if config.debug then
    lib.addCommand('blips_stats', {
        help = 'Show blips system statistics',
        restricted = 'group.admin'
    }, function(source)
        local stats = lib.blips.getStats()
        lib.print.info(('Blips Stats: %s'):format(json.encode(stats, { indent = true })))
    end)

    lib.addCommand('blips_sync', {
        help = 'Force sync blips for a player',
        restricted = 'group.admin',
        params = {
            { name = 'playerId', type = 'playerId', help = 'Player ID' }
        }
    }, function(source, args)
        syncPlayerBlips(args.playerId)
        lib.print.info(('Synced blips for player %d'):format(args.playerId))
    end)
end

return lib.blips
