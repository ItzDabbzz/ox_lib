--[[
    https://github.com/overextended/ox_lib
    https://github.com/ITzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxPed
lib.ped = {}

local activePeds = {} -- Active peds tracked by the system

--- Creates and spawns a ped at a specified location.
---@param modelHash number|string The hash or name of the ped model.
---@param coords vector3|vector4 The coordinates to spawn the ped.
---@param freeze? boolean If true, freezes the ped in place.
---@param scenario? string The scenario for the ped to enact.
---@param targetOptions? table The options for the target interaction.
---@param interactionType? string The type of interaction ('target' or 'textui').
---@return number? ped The created ped entity, or nil if failed
local function createPed(modelHash, coords, freeze, scenario, targetOptions, interactionType)
    -- Validate inputs
    if not lib.assert.notNil(modelHash, 'Model hash') then
        return nil
    end

    if not lib.assert.notNil(coords, 'Coordinates') then
        return nil
    end

    -- Convert string model to hash if needed
    if type(modelHash) == 'string' then
        modelHash = joaat(modelHash)
    end

    -- Ensure we have a vector4 for heading
    local pedCoords = coords
    local heading = 0.0

    if type(coords) == 'vector4' then
        heading = coords.w
        pedCoords = vector3(coords.x, coords.y, coords.z)
    elseif type(coords) == 'table' and coords.w then
        heading = coords.w
        pedCoords = vector3(coords.x, coords.y, coords.z)
    elseif type(coords) == 'table' and coords[4] then
        heading = coords[4]
        pedCoords = vector3(coords[1], coords[2], coords[3])
    end

    -- Load the model
    if not lib.requestModel(modelHash, 5000) then
        lib.print.error(('Failed to load ped model: %s'):format(modelHash))
        return nil
    end

    -- Create the ped
    local ped = CreatePed(4, modelHash, pedCoords.x, pedCoords.y, pedCoords.z, heading, false, false)

    if not DoesEntityExist(ped) then
        lib.print.error('Failed to create ped entity')
        SetModelAsNoLongerNeeded(modelHash)
        return nil
    end

    -- Configure ped properties
    if freeze then
        FreezeEntityPosition(ped, true)
    end

    if scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end

    SetEntityVisible(ped, true)
    SetEntityInvincible(ped, true)
    PlaceObjectOnGroundProperly(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Add target interaction if specified
    if targetOptions and lib.target and lib.target.isAvailable() then
        if interactionType == 'target' then
            lib.target.addTargetEntity(ped, {
                options = targetOptions,
                distance = targetOptions.distance or 2.0
            })
        end
    end

    -- Clean up the ped on resource stop
    AddEventHandler('onResourceStop', function(resource)
        if resource == cache.resource then
            if DoesEntityExist(ped) then
                if lib.target and lib.target.isAvailable() then
                    lib.target.removeTargetEntity(ped)
                end
                DeleteEntity(ped)
            end
        end
    end)

    -- Clean up model
    SetModelAsNoLongerNeeded(modelHash)

    return ped
end

--- Public function to create a ped using a 'data' table with all necessary parameters.
---@param data table A table containing all necessary data for ped creation.
---@return number? pedId The ID of the created ped, or nil if failed.
function lib.ped.create(data)
    if not lib.assert.type(data, 'table', 'Ped data') then
        return nil
    end

    if not lib.assert.notNil(data.model, 'Ped model') then
        return nil
    end

    if not lib.assert.notNil(data.coords, 'Ped coordinates') then
        return nil
    end

    -- Convert coordinates if needed
    local coords = data.coords
    if type(coords) == 'table' and not coords.x then
        if coords[1] and coords[2] and coords[3] then
            coords = vector4(coords[1], coords[2], coords[3], coords[4] or 0.0)
        else
            lib.print.error('Invalid coordinate format')
            return nil
        end
    end

    local ped = createPed(
        data.model,
        coords,
        data.freeze,
        data.scenario,
        data.targetOptions,
        data.interactionType
    )

    if not ped then
        return nil
    end

    local id = #activePeds + 1
    activePeds[id] = {
        entity = ped,
        data = data,
        created = GetGameTimer()
    }

    lib.print.info(('Created ped with ID: %d'):format(id))
    return id
end

--- Get information about a specific ped
---@param pedId number The ID of the ped
---@return table? pedInfo Information about the ped, or nil if not found
function lib.ped.get(pedId)
    if not lib.assert.type(pedId, 'number', 'Ped ID') then
        return nil
    end

    local pedData = activePeds[pedId]
    if not pedData then
        return nil
    end

    return {
        id = pedId,
        entity = pedData.entity,
        exists = DoesEntityExist(pedData.entity),
        coords = GetEntityCoords(pedData.entity),
        heading = GetEntityHeading(pedData.entity),
        health = GetEntityHealth(pedData.entity),
        data = pedData.data,
        created = pedData.created
    }
end

--- Get all active peds
---@return table activePeds Array of ped information
function lib.ped.getAll()
    local peds = {}

    for id, pedData in pairs(activePeds) do
        if DoesEntityExist(pedData.entity) then
            peds[#peds + 1] = {
                id = id,
                entity = pedData.entity,
                coords = GetEntityCoords(pedData.entity),
                heading = GetEntityHeading(pedData.entity),
                data = pedData.data,
                created = pedData.created
            }
        else
            -- Clean up invalid peds
            activePeds[id] = nil
        end
    end

    return peds
end

--- Update ped scenario
---@param pedId number The ID of the ped
---@param scenario string The new scenario
---@return boolean success Whether the scenario was updated
function lib.ped.setScenario(pedId, scenario)
    if not lib.assert.type(pedId, 'number', 'Ped ID') then
        return false
    end

    if not lib.assert.type(scenario, 'string', 'Scenario') then
        return false
    end

    local pedData = activePeds[pedId]
    if not pedData or not DoesEntityExist(pedData.entity) then
        lib.print.warn(('Ped ID %d not found or invalid'):format(pedId))
        return false
    end

    ClearPedTasks(pedData.entity)
    TaskStartScenarioInPlace(pedData.entity, scenario, 0, true)
    pedData.data.scenario = scenario

    return true
end

--- Update ped target options
---@param pedId number The ID of the ped
---@param targetOptions table The new target options
---@return boolean success Whether the target options were updated
function lib.ped.setTargetOptions(pedId, targetOptions)
    if not lib.assert.type(pedId, 'number', 'Ped ID') then
        return false
    end

    if not lib.assert.type(targetOptions, 'table', 'Target options') then
        return false
    end

    local pedData = activePeds[pedId]
    if not pedData or not DoesEntityExist(pedData.entity) then
        lib.print.warn(('Ped ID %d not found or invalid'):format(pedId))
        return false
    end

    if lib.target and lib.target.isAvailable() then
        -- Remove existing target
        lib.target.removeTargetEntity(pedData.entity)

        -- Add new target options
        lib.target.addTargetEntity(pedData.entity, {
            options = targetOptions,
            distance = targetOptions.distance or 2.0
        })

        -- Update stored data
        pedData.data.targetOptions = targetOptions

        return true
    end

    lib.print.warn('Target system not available')
    return false
end

--- Integrates the Points module for ped handling.
---@param data table A table with ped data and point behaviors.
---@return table? point The created point, or nil if failed
function lib.ped.createAtPoint(data)
    if not lib.assert.type(data, 'table', 'Point data') then
        return nil
    end

    if not lib.assert.notNil(data.coords, 'Point coordinates') then
        return nil
    end

    if not lib.points then
        lib.print.error('lib.points is not available')
        return nil
    end

    -- Convert coordinates to vector3 for points
    local pointCoords = data.coords
    if type(pointCoords) == 'vector4' then
        pointCoords = vector3(pointCoords.x, pointCoords.y, pointCoords.z)
    elseif type(pointCoords) == 'table' and pointCoords.x then
        pointCoords = vector3(pointCoords.x, pointCoords.y, pointCoords.z)
    elseif type(pointCoords) == 'table' and pointCoords[1] then
        pointCoords = vector3(pointCoords[1], pointCoords[2], pointCoords[3])
    end

    local point = lib.points.new({
        coords = pointCoords,
        distance = data.distance or 50.0,
        onEnter = function()
            if not data.pedId or not activePeds[data.pedId] or not DoesEntityExist(activePeds[data.pedId].entity) then
                data.pedId = lib.ped.create(data)
            end

            if data.onEnter then
                data.onEnter(data.pedId)
            end
        end,
        onExit = function()
            if data.pedId then
                lib.ped.remove(data.pedId)
                data.pedId = nil
            end

            if data.onExit then
                data.onExit()
            end
        end,
        debug = data.debug or false,
    })

    return point
end

--- Create a ped with a box zone target area
---@param data table Ped data with zone configuration
---@return number? pedId The created ped ID, or nil if failed
function lib.ped.createWithBoxZone(data)
    if not lib.assert.type(data, 'table', 'Ped data') then
        return nil
    end

    if not lib.assert.notNil(data.coords, 'Ped coordinates') then
        return nil
    end

    if not lib.assert.type(data.zone, 'table', 'Zone data') then
        return nil
    end

    if not lib.target or not lib.target.isAvailable() then
        lib.print.error('Target system not available for box zone')
        return nil
    end

    -- Create the ped first
    local pedId = lib.ped.create(data)
    if not pedId then
        return nil
    end

    -- Create box zone around the ped
    local zoneId = ('ped_zone_%d'):format(pedId)
    local zoneCoords = data.coords
    if type(zoneCoords) == 'vector4' then
        zoneCoords = vector3(zoneCoords.x, zoneCoords.y, zoneCoords.z)
    end

    lib.target.addBoxZone(zoneId, zoneCoords,
        data.zone.width or 2.0,
        data.zone.length or 2.0,
        {
            heading = data.zone.heading or (type(data.coords) == 'vector4' and data.coords.w or 0.0),
            options = data.zone.options or data.targetOptions,
            distance = data.zone.distance or 2.0,
            minZ = data.zone.minZ,
            maxZ = data.zone.maxZ
        },
        data.zone.debug or false
    )

    -- Store zone info with ped data
    local pedData = activePeds[pedId]
    if pedData then
        pedData.zoneId = zoneId
        pedData.hasZone = true
    end

    return pedId
end

--- Create a ped with a circle zone target area
---@param data table Ped data with zone configuration
---@return number? pedId The created ped ID, or nil if failed
function lib.ped.createWithCircleZone(data)
    if not lib.assert.type(data, 'table', 'Ped data') then
        return nil
    end

    if not lib.assert.notNil(data.coords, 'Ped coordinates') then
        return nil
    end

    if not lib.assert.type(data.zone, 'table', 'Zone data') then
        return nil
    end

    if not lib.target or not lib.target.isAvailable() then
        lib.print.error('Target system not available for circle zone')
        return nil
    end

    -- Create the ped first
    local pedId = lib.ped.create(data)
    if not pedId then
        return nil
    end

    -- Create circle zone around the ped
    local zoneId = ('ped_circle_zone_%d'):format(pedId)
    local zoneCoords = data.coords
    if type(zoneCoords) == 'vector4' then
        zoneCoords = vector3(zoneCoords.x, zoneCoords.y, zoneCoords.z)
    end

    lib.target.addCircleZone(zoneId, zoneCoords,
        data.zone.radius or 2.0,
        {
            options = data.zone.options or data.targetOptions,
            distance = data.zone.distance or 2.0,
            useZ = data.zone.useZ
        },
        data.zone.debug or false
    )

    -- Store zone info with ped data
    local pedData = activePeds[pedId]
    if pedData then
        pedData.zoneId = zoneId
        pedData.hasZone = true
    end

    return pedId
end

--- Create a ped with a polygon zone target area
---@param data table Ped data with zone configuration
---@return number? pedId The created ped ID, or nil if failed
function lib.ped.createWithPolyZone(data)
    if not lib.assert.type(data, 'table', 'Ped data') then
        return nil
    end

    if not lib.assert.notNil(data.coords, 'Ped coordinates') then
        return nil
    end

    if not lib.assert.type(data.zone, 'table', 'Zone data') then
        return nil
    end

    if not lib.assert.type(data.zone.points, 'table', 'Zone points') then
        return nil
    end

    if not lib.target or not lib.target.isAvailable() then
        lib.print.error('Target system not available for polygon zone')
        return nil
    end

    -- Create the ped first
    local pedId = lib.ped.create(data)
    if not pedId then
        return nil
    end

    -- Create polygon zone around the ped
    local zoneId = ('ped_poly_zone_%d'):format(pedId)

    lib.target.addPolyZone(zoneId, data.zone.points,
        {
            options = data.zone.options or data.targetOptions,
            distance = data.zone.distance or 2.0,
            minZ = data.zone.minZ,
            maxZ = data.zone.maxZ
        },
        data.zone.debug or false
    )

    -- Store zone info with ped data
    local pedData = activePeds[pedId]
    if pedData then
        pedData.zoneId = zoneId
        pedData.hasZone = true
    end

    return pedId
end

--- Remove all active peds
---@return number count Number of peds removed
function lib.ped.removeAll()
    local count = 0

    for id, pedData in pairs(activePeds) do
        if DoesEntityExist(pedData.entity) then
            -- Remove target interaction
            if lib.target and lib.target.isAvailable() then
                lib.target.removeTargetEntity(pedData.entity)

                -- Remove zone if it exists
                if pedData.hasZone and pedData.zoneId then
                    lib.target.removeZone(pedData.zoneId)
                end
            end

            DeleteEntity(pedData.entity)
            count = count + 1
        end
        activePeds[id] = nil
    end

    lib.print.info(('Removed %d peds'):format(count))
    return count
end

--- Remove a specific ped (updated to handle zones)
function lib.ped.remove(pedId)
    if not lib.assert.type(pedId, 'number', 'Ped ID') then
        return false
    end

    local pedData = activePeds[pedId]
    if not pedData then
        lib.print.warn(('Ped ID %d not found'):format(pedId))
        return false
    end

    local ped = pedData.entity
    if DoesEntityExist(ped) then
        -- Remove target interaction if it exists
        if lib.target and lib.target.isAvailable() then
            lib.target.removeTargetEntity(ped)

            -- Remove zone if it exists
            if pedData.hasZone and pedData.zoneId then
                lib.target.removeZone(pedData.zoneId)
            end
        end

        DeleteEntity(ped)
        lib.print.info(('Removed ped with ID: %d'):format(pedId))
    end

    activePeds[pedId] = nil
    return true
end

--- Check if a ped ID is valid and exists
---@param pedId number The ID to check
---@return boolean valid Whether the ped ID is valid
function lib.ped.exists(pedId)
    if type(pedId) ~= 'number' then
        return false
    end

    local pedData = activePeds[pedId]
    return pedData ~= nil and DoesEntityExist(pedData.entity)
end

--- Get statistics about active peds
---@return table stats Statistics about active peds
function lib.ped.getStats()
    local stats = {
        total = 0,
        valid = 0,
        invalid = 0,
        withTargets = 0,
        withScenarios = 0,
        withZones = 0,
        frozen = 0
    }

    for id, pedData in pairs(activePeds) do
        stats.total = stats.total + 1

        if DoesEntityExist(pedData.entity) then
            stats.valid = stats.valid + 1

            if pedData.data.targetOptions then
                stats.withTargets = stats.withTargets + 1
            end

            if pedData.data.scenario then
                stats.withScenarios = stats.withScenarios + 1
            end

            if pedData.hasZone then
                stats.withZones = stats.withZones + 1
            end

            if IsEntityPositionFrozen(pedData.entity) then
                stats.frozen = stats.frozen + 1
            end
        else
            stats.invalid = stats.invalid + 1
            -- Clean up invalid ped
            activePeds[id] = nil
        end
    end

    return stats
end

--- Get the active target resource being used
---@return string? targetResource The name of the active target resource
function lib.ped.getTargetResource()
    if lib.target and lib.target.getActiveResource then
        return lib.target.getActiveResource()
    end
    return nil
end

--- Check if target system is available
---@return boolean available Whether the target system is available
function lib.ped.isTargetAvailable()
    return lib.target and lib.target.isAvailable() or false
end

--- Refresh the target system
---@return boolean success Whether the refresh was successful
function lib.ped.refreshTargetSystem()
    if lib.target and lib.target.refresh then
        return lib.target.refresh()
    end
    return false
end

-- Clean up all peds when resource stops
AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        lib.ped.removeAll()
    end
end)

return lib.ped
