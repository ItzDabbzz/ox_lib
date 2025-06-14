--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxTarget
lib.target = {}

local targetResource = nil

--- Initialize the target system by checking available resources and setting the target module.
local function initialize()
    local resources = { 'sleepless_interact', 'ox_target', 'qb-target', 'qtarget' }

    for _, resource in ipairs(resources) do
        if GetResourceState(resource) == 'started' then
            targetResource = resource
            break
        end
    end

    if not targetResource then
        lib.print.error('No target resource found or started')
        return false
    end

    lib.print.info(('Target system initialized with %s'):format(targetResource))
    return true
end

-- Initialize the target system
if not initialize() then
    return
end

--- Convert ox_lib option format to sleepless_interact format
---@param options table[] Array of ox_lib format options
---@return InteractOption[] sleeplessOptions Array of sleepless_interact format options
local function convertToSleeplessOptions(options)
    local sleeplessOptions = {}

    for i, option in ipairs(options) do
        local sleeplessOption = {
            label = option.label or 'Interact',
            icon = option.icon,
            iconColor = option.iconColor,
            distance = option.distance or 2.0,
            holdTime = option.holdTime,
            name = option.name or ('option_' .. i),
            resource = GetInvokingResource(),
            bones = option.bones,
            allowInVehicle = option.allowInVehicle,
            cooldown = option.cooldown,
            color = option.color
        }

        -- Handle different action types
        if option.onSelect then
            sleeplessOption.onSelect = option.onSelect
        elseif option.action then
            sleeplessOption.onSelect = option.action
        elseif option.event then
            if option.type == 'server' or option.serverEvent then
                sleeplessOption.serverEvent = option.event or option.serverEvent
            else
                sleeplessOption.event = option.event
            end
        elseif option.command then
            sleeplessOption.command = option.command
        elseif option.export then
            sleeplessOption.export = option.export
        end

        -- Handle canInteract function
        if option.canInteract then
            sleeplessOption.canInteract = option.canInteract
        end

        -- Handle active/inactive callbacks
        if option.onActive then
            sleeplessOption.onActive = option.onActive
        end
        if option.onInactive then
            sleeplessOption.onInactive = option.onInactive
        end
        if option.whileActive then
            sleeplessOption.whileActive = option.whileActive
        end

        table.insert(sleeplessOptions, sleeplessOption)
    end

    return sleeplessOptions
end

--- Add a sphere zone.
---@param name string The name/identifier for the zone.
---@param coords vector3 Coordinates where the zone is centered.
---@param radius number The radius of the sphere zone.
---@param data table Additional data such as options and distance.
---@param debugPoly? boolean Whether to debug the polygon.
---@return any handler The handle to the created zone.
function lib.target.addSphereZone(name, coords, radius, data, debugPoly)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if type(coords) == 'table' and not coords.x then
        coords = vector3(coords[1] or coords.x or 0, coords[2] or coords.y or 0, coords[3] or coords.z or 0)
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format - add as coordinate zone
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})

        -- Set distance for all options if not set
        for _, option in ipairs(sleeplessOptions) do
            if not option.distance then
                option.distance = radius
            end
        end

        local handler = exports[targetResource]:addCoords(coords, sleeplessOptions)
        return handler
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        local handler = exports[targetResource]:addSphereZone({
            coords = coords,
            radius = radius,
            name = name,
            debug = debugPoly or false,
            drawSprite = true,
            options = data.options or {}
        })
        return handler
    else
        -- Use qb-target/qtarget format (legacy)
        local handler = exports[targetResource]:AddCircleZone(name, coords, radius, {
            name = name,
            useZ = data.useZ ~= false,
            debugPoly = debugPoly or false,
        }, {
            options = data.options or {},
            distance = data.distance or 2.0,
        })
        return handler
    end
end

--- Add a circle zone (alias for sphere zone for backwards compatibility).
---@param identifier string The identifier for the zone.
---@param coords vector3 Coordinates where the zone is centered.
---@param radius number The radius of the circle zone.
---@param data table Additional data such as options and distance.
---@param debugPoly? boolean Whether to debug the polygon.
---@return any handler The handle to the created zone.
function lib.target.addCircleZone(identifier, coords, radius, data, debugPoly)
    return lib.target.addSphereZone(identifier, coords, radius, data, debugPoly)
end

--- Add a box zone.
---@param identifier string The identifier for the zone.
---@param coords vector3 Coordinates where the zone is centered.
---@param width number The width of the box zone.
---@param length number The length of the box zone.
---@param data table Additional data such as heading, options, and distance.
---@param debugPoly? boolean Whether to debug the polygon.
---@return any handler The handle to the created zone.
function lib.target.addBoxZone(identifier, coords, width, length, data, debugPoly)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if type(coords) == 'table' and not coords.x then
        coords = vector3(coords[1] or coords.x or 0, coords[2] or coords.y or 0, coords[3] or coords.z or 0)
    end

    if targetResource == 'sleepless_interact' then
        -- sleepless_interact doesn't have box zones, use coordinate with distance
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})

        -- Calculate approximate radius from box dimensions
        local radius = math.max(width, length) / 2

        for _, option in ipairs(sleeplessOptions) do
            if not option.distance then
                option.distance = radius
            end
        end

        local handler = exports[targetResource]:addCoords(coords, sleeplessOptions)
        return handler
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        local handler = exports[targetResource]:addBoxZone({
            coords = coords,
            size = vector3(width, length, data.height or 2.0),
            rotation = data.heading or 0.0,
            name = identifier,
            debug = debugPoly or false,
            drawSprite = true,
            options = data.options or {}
        })
        return handler
    else
        -- Use qb-target/qtarget format (legacy)
        local handler = exports[targetResource]:AddBoxZone(identifier, coords, width, length, {
            name = identifier,
            heading = data.heading or 0.0,
            debugPoly = debugPoly or false,
            minZ = coords.z - (data.minZ or 1.2),
            maxZ = coords.z + (data.maxZ or 1.2),
        }, {
            options = data.options or {},
            distance = data.distance or 2.0,
        })
        return handler
    end
end

--- Add a polygon zone.
---@param identifier string The identifier for the zone.
---@param points vector3[] Array of points defining the polygon.
---@param data table Additional data such as options, distance, thickness.
---@param debugPoly? boolean Whether to debug the polygon.
---@return any handler The handle to the created zone.
function lib.target.addPolyZone(identifier, points, data, debugPoly)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- sleepless_interact doesn't have poly zones, calculate center and use coordinate
        local centerX, centerY, centerZ = 0, 0, 0
        local pointCount = #points

        for _, point in ipairs(points) do
            centerX = centerX + (point.x or point[1] or 0)
            centerY = centerY + (point.y or point[2] or 0)
            centerZ = centerZ + (point.z or point[3] or 0)
        end

        local center = vector3(centerX / pointCount, centerY / pointCount, centerZ / pointCount)
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})

        -- Set a reasonable distance if not provided
        for _, option in ipairs(sleeplessOptions) do
            if not option.distance then
                option.distance = data.distance or 5.0
            end
        end

        local handler = exports[targetResource]:addCoords(center, sleeplessOptions)
        return handler
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        local handler = exports[targetResource]:addPolyZone({
            points = points,
            name = identifier,
            thickness = data.thickness or 4.0,
            debug = debugPoly or false,
            drawSprite = true,
            options = data.options or {}
        })
        return handler
    else
        -- Convert points to proper format for legacy targets
        local formattedPoints = {}
        for i, point in ipairs(points) do
            if type(point) == 'table' and not point.x then
                formattedPoints[i] = vector2(point[1] or point.x or 0, point[2] or point.y or 0)
            else
                formattedPoints[i] = vector2(point.x, point.y)
            end
        end

        local handler = exports[targetResource]:AddPolyZone(identifier, formattedPoints, {
            name = identifier,
            minZ = data.minZ,
            maxZ = data.maxZ,
            debugPoly = debugPoly or false,
        }, {
            options = data.options or {},
            distance = data.distance or 2.0,
        })
        return handler
    end
end

--- Add a target entity.
---@param entityId number The entity ID to target.
---@param data table Additional data such as options and distance.
function lib.target.addTargetEntity(entityId, data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if not DoesEntityExist(entityId) then
        lib.print.warn(('Entity %s does not exist'):format(entityId))
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format - add as networked entity
        local netId = NetworkGetNetworkIdFromEntity(entityId)
        if netId and NetworkDoesNetworkIdExist(netId) then
            local sleeplessOptions = convertToSleeplessOptions(data.options or {})
            exports[targetResource]:addEntity(netId, sleeplessOptions)
        else
            -- Use local entity if not networked
            local sleeplessOptions = convertToSleeplessOptions(data.options or {})
            exports[targetResource]:addLocalEntity(entityId, sleeplessOptions)
        end
    elseif targetResource == 'ox_target' then
        -- Use ox_target format - convert to network ID
        local netId = NetworkGetNetworkIdFromEntity(entityId)
        exports[targetResource]:addEntity(netId, data.options or {})
    else
        -- Use legacy format
        exports[targetResource]:AddTargetEntity(entityId, {
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Add a target model.
---@param models string|string[]|number|number[] Models to target.
---@param data table Additional data such as options and distance.
function lib.target.addTargetModel(models, data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    -- Ensure models is always a table
    if type(models) ~= 'table' then
        models = { models }
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})
        exports[targetResource]:addModel(models, sleeplessOptions)
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        exports[targetResource]:addModel(models, data.options or {})
    else
        -- Use legacy format
        exports[targetResource]:AddTargetModel(models, {
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Add a target bone.
---@param bones string|string[]|number|number[] Bones to target.
---@param data table Additional data such as options and distance.
function lib.target.addTargetBone(bones, data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    -- Ensure bones is always a table
    if type(bones) ~= 'table' then
        bones = { bones }
    end

    if targetResource == 'sleepless_interact' then
        -- sleepless_interact handles bones within options, not as separate targets
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})

        -- Add bones to each option
        for _, option in ipairs(sleeplessOptions) do
            option.bones = bones
        end

        -- Add to global peds (bones are typically for peds/vehicles)
        exports[targetResource]:addGlobalPed(sleeplessOptions)
        lib.print.warn('sleepless_interact: Added bone targeting as global ped options')
    elseif targetResource == 'ox_target' then
        -- ox_target doesn't have bone targeting, use model targeting instead
        lib.print.warn('ox_target does not support bone targeting, consider using model targeting')
    else
        -- Use legacy format
        exports[targetResource]:AddTargetBone(bones, {
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Remove a target entity.
---@param entity number The entity to remove from targeting.
function lib.target.removeTargetEntity(entity)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local netId = NetworkGetNetworkIdFromEntity(entity)
        if netId and NetworkDoesNetworkIdExist(netId) then
            exports[targetResource]:removeEntity(netId)
        else
            exports[targetResource]:removeLocalEntity(entity)
        end
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        local netId = NetworkGetNetworkIdFromEntity(entity)
        exports[targetResource]:removeEntity(netId)
    else
        -- Use legacy format
        exports[targetResource]:RemoveTargetEntity(entity)
    end
end

--- Remove a zone.
---@param identifier string|number The identifier for the zone to remove.
function lib.target.removeZone(identifier)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- sleepless_interact uses coordinate IDs for zones
        exports[targetResource]:removeCoords(identifier)
    else
        -- ox_target and legacy targets
        exports[targetResource]:removeZone(identifier)
    end
end

--- Add a global ped target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalPed(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})
        exports[targetResource]:addGlobalPed(sleeplessOptions)
    elseif targetResource == 'ox_target' then
        -- Use ox_target format - options should be passed directly
        exports[targetResource]:addGlobalPed(data.options or {})
    else
        -- Use legacy format
        exports[targetResource]:AddGlobalPed({
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Add a global vehicle target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalVehicle(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})
        exports[targetResource]:addGlobalVehicle(sleeplessOptions)
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        exports[targetResource]:addGlobalVehicle(data.options or {})
    else
        -- Use legacy format
        exports[targetResource]:AddGlobalVehicle({
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Add a global object target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalObject(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})
        exports[targetResource]:addGlobalObject(sleeplessOptions)
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        exports[targetResource]:addGlobalObject(data.options or {})
    else
        -- Use legacy format
        exports[targetResource]:AddGlobalObject({
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Add a global player target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalPlayer(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(data.options or {})
        exports[targetResource]:addGlobalPlayer(sleeplessOptions)
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        exports[targetResource]:addGlobalPlayer(data.options or {})
    else
        -- Use legacy format
        exports[targetResource]:AddGlobalPlayer({
            options = data.options or {},
            distance = data.distance or 2.0,
        })
    end
end

--- Remove a global ped target.
---@param optionNames? string|string[] The option names to remove.
function lib.target.removeGlobalPed(optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        if optionNames then
            exports[targetResource]:removeGlobalPed(optionNames)
        else
            -- Remove all - sleepless_interact requires option names
            lib.print.warn('sleepless_interact requires specific option names to remove')
        end
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        if optionNames then
            exports[targetResource]:removeGlobalPed(optionNames)
        else
            exports[targetResource]:removeGlobalPed({})
        end
    else
        -- Use legacy format
        if optionNames then
            exports[targetResource]:RemoveGlobalPed(optionNames)
        else
            exports[targetResource]:RemoveGlobalPed()
        end
    end
end

--- Remove a global vehicle target.
---@param optionNames? string|string[] The option names to remove.
function lib.target.removeGlobalVehicle(optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        if optionNames then
            exports[targetResource]:removeGlobalVehicle(optionNames)
        else
            lib.print.warn('sleepless_interact requires specific option names to remove')
        end
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        if optionNames then
            exports[targetResource]:removeGlobalVehicle(optionNames)
        else
            exports[targetResource]:removeGlobalVehicle({})
        end
    else
        -- Use legacy format
        if optionNames then
            exports[targetResource]:RemoveGlobalVehicle(optionNames)
        else
            exports[targetResource]:RemoveGlobalVehicle()
        end
    end
end

--- Remove a global object target.
---@param optionNames? string|string[] The option names to remove.
function lib.target.removeGlobalObject(optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        if optionNames then
            exports[targetResource]:removeGlobalObject(optionNames)
        else
            lib.print.warn('sleepless_interact requires specific option names to remove')
        end
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        if optionNames then
            exports[targetResource]:removeGlobalObject(optionNames)
        else
            exports[targetResource]:removeGlobalObject({})
        end
    else
        -- Use legacy format
        if optionNames then
            exports[targetResource]:RemoveGlobalObject(optionNames)
        else
            exports[targetResource]:RemoveGlobalObject()
        end
    end
end

--- Remove a global player target.
---@param optionNames? string|string[] The option names to remove.
function lib.target.removeGlobalPlayer(optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        if optionNames then
            exports[targetResource]:removeGlobalPlayer(optionNames)
        else
            lib.print.warn('sleepless_interact requires specific option names to remove')
        end
    elseif targetResource == 'ox_target' then
        -- Use ox_target format
        if optionNames then
            exports[targetResource]:removeGlobalPlayer(optionNames)
        else
            exports[targetResource]:removeGlobalPlayer({})
        end
    else
        -- Use legacy format
        if optionNames then
            exports[targetResource]:RemoveGlobalPlayer(optionNames)
        else
            exports[targetResource]:RemoveGlobalPlayer()
        end
    end
end

--- Disable/Enable targeting system.
---@param state boolean True to disable, false to enable.
function lib.target.disableTargeting(state)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        exports[targetResource]:disableInteract(state)
    elseif targetResource == 'ox_target' then
        exports[targetResource]:disableTargeting(state)
    else
        -- Legacy targets may not support this
        lib.print.warn('disableTargeting not supported by legacy target systems')
    end
end

--- Add a global option (ox_target/sleepless_interact specific).
---@param options table The options to add globally.
function lib.target.addGlobalOption(options)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- sleepless_interact doesn't have a single "global option" - need to specify type
        lib.print.warn('sleepless_interact requires specifying target type (ped, vehicle, object, player)')
    elseif targetResource == 'ox_target' then
        exports[targetResource]:addGlobalOption(options)
    else
        lib.print.warn('addGlobalOption only supported by ox_target and sleepless_interact')
    end
end

--- Remove a global option (ox_target/sleepless_interact specific).
---@param optionNames string|string[] The option names to remove.
function lib.target.removeGlobalOption(optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- sleepless_interact doesn't have a single "global option" - need to specify type
        lib.print.warn('sleepless_interact requires specifying target type (ped, vehicle, object, player)')
    elseif targetResource == 'ox_target' then
        exports[targetResource]:removeGlobalOption(optionNames)
    else
        lib.print.warn('removeGlobalOption only supported by ox_target and sleepless_interact')
    end
end

--- Add local entity targeting.
---@param entities number|number[] Entity handles to target.
---@param options table The targeting options.
function lib.target.addLocalEntity(entities, options)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    -- Ensure entities is always a table
    if type(entities) ~= 'table' then
        entities = { entities }
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(options)
        exports[targetResource]:addLocalEntity(entities, sleeplessOptions)
    elseif targetResource == 'ox_target' then
        exports[targetResource]:addLocalEntity(entities, options)
    else
        lib.print.warn('addLocalEntity only supported by ox_target and sleepless_interact')
    end
end

--- Remove local entity targeting.
---@param entities number|number[] Entity handles to remove.
---@param optionNames string|string[] Option names to remove.
function lib.target.removeLocalEntity(entities, optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    -- Ensure entities is always a table
    if type(entities) ~= 'table' then
        entities = { entities }
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        exports[targetResource]:removeLocalEntity(entities, optionNames)
    elseif targetResource == 'ox_target' then
        exports[targetResource]:removeLocalEntity(entities, optionNames)
    else
        lib.print.warn('removeLocalEntity only supported by ox_target and sleepless_interact')
    end
end

--- Remove model targeting.
---@param models string|string[]|number|number[] Models to remove targeting from.
---@param optionNames string|string[] Option names to remove.
function lib.target.removeModel(models, optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    -- Ensure models is always a table
    if type(models) ~= 'table' then
        models = { models }
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        exports[targetResource]:removeModel(models, optionNames)
    elseif targetResource == 'ox_target' then
        exports[targetResource]:removeModel(models, optionNames)
    else
        -- Use legacy format
        exports[targetResource]:RemoveTargetModel(models, optionNames)
    end
end

--- Add coordinate-based targeting (sleepless_interact specific).
---@param coords vector3|vector3[] Coordinates for the interaction.
---@param options table The interaction options.
---@return string|string[] coordIds The coordinate IDs.
function lib.target.addCoords(coords, options)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        local sleeplessOptions = convertToSleeplessOptions(options)
        return exports[targetResource]:addCoords(coords, sleeplessOptions)
    else
        lib.print.warn('addCoords only supported by sleepless_interact - use addSphereZone instead')
        return nil
    end
end

--- Remove coordinate-based targeting (sleepless_interact specific).
---@param coordId string The coordinate ID to remove.
---@param optionNames? string|string[] Specific option names to remove.
function lib.target.removeCoords(coordId, optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if targetResource == 'sleepless_interact' then
        -- Use sleepless_interact format
        exports[targetResource]:removeCoords(coordId, optionNames)
    else
        lib.print.warn('removeCoords only supported by sleepless_interact')
    end
end

--- Get the currently active target resource name.
---@return string? targetResource The name of the active target resource.
function lib.target.getActiveResource()
    return targetResource
end

--- Check if the target system is available.
---@return boolean available Whether the target system is available.
function lib.target.isAvailable()
    return targetResource ~= nil
end

--- Check if using ox_target specifically.
---@return boolean isOxTarget Whether using ox_target.
function lib.target.isOxTarget()
    return targetResource == 'ox_target'
end

--- Check if using sleepless_interact specifically.
---@return boolean isSleeplessInteract Whether using sleepless_interact.
function lib.target.isSleeplessInteract()
    return targetResource == 'sleepless_interact'
end

--- Check if using a legacy target system (qb-target/qtarget).
---@return boolean isLegacy Whether using a legacy target system.
function lib.target.isLegacy()
    return targetResource == 'qb-target' or targetResource == 'qtarget'
end

--- Get supported features for the current target system.
---@return table features Table of supported features.
function lib.target.getSupportedFeatures()
    local features = {
        sphereZone = true,
        circleZone = true,
        boxZone = true,
        polyZone = true,
        globalPed = true,
        globalVehicle = true,
        globalObject = true,
        globalPlayer = true,
        targetEntity = true,
        targetModel = true,
        disableTargeting = false,
        localEntity = false,
        coords = false,
        bones = false,
        offsets = false
    }

    if targetResource == 'sleepless_interact' then
        features.disableTargeting = true
        features.localEntity = true
        features.coords = true
        features.bones = true
        features.offsets = true
        features.polyZone = false -- Converted to coords
        features.boxZone = false  -- Converted to coords
    elseif targetResource == 'ox_target' then
        features.disableTargeting = true
        features.localEntity = true
        features.bones = false
    elseif targetResource == 'qb-target' or targetResource == 'qtarget' then
        features.bones = true
    end

    return features
end

--- Refresh the target system (re-initialize).
---@return boolean success Whether the refresh was successful.
function lib.target.refresh()
    targetResource = nil
    return initialize()
end

--- Add interaction with automatic system detection and conversion.
---@param interactionType string Type of interaction ('sphere', 'box', 'poly', 'coords', 'entity', 'model', 'globalPed', etc.)
---@param data table Interaction data
---@return any result The result from the target system
function lib.target.addInteraction(interactionType, data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    local interactionType = string.lower(interactionType)

    if interactionType == 'sphere' or interactionType == 'circle' then
        return lib.target.addSphereZone(data.name or data.id, data.coords, data.radius, data)
    elseif interactionType == 'box' then
        return lib.target.addBoxZone(data.name or data.id, data.coords, data.width, data.length, data)
    elseif interactionType == 'poly' or interactionType == 'polygon' then
        return lib.target.addPolyZone(data.name or data.id, data.points, data)
    elseif interactionType == 'coords' then
        if targetResource == 'sleepless_interact' then
            return lib.target.addCoords(data.coords, data.options)
        else
            -- Fallback to sphere zone
            return lib.target.addSphereZone(data.name or data.id, data.coords, data.radius or 2.0, data)
        end
    elseif interactionType == 'entity' then
        lib.target.addTargetEntity(data.entity, data)
    elseif interactionType == 'model' then
        lib.target.addTargetModel(data.models, data)
    elseif interactionType == 'globalped' then
        lib.target.addGlobalPed(data)
    elseif interactionType == 'globalvehicle' then
        lib.target.addGlobalVehicle(data)
    elseif interactionType == 'globalobject' then
        lib.target.addGlobalObject(data)
    elseif interactionType == 'globalplayer' then
        lib.target.addGlobalPlayer(data)
    elseif interactionType == 'localentity' then
        lib.target.addLocalEntity(data.entities, data.options)
    else
        lib.print.error(('Unknown interaction type: %s'):format(interactionType))
        return nil
    end
end

--- Remove interaction with automatic system detection.
---@param interactionType string Type of interaction to remove
---@param identifier string|number|table Identifier for the interaction
---@param optionNames? string|string[] Option names to remove (optional)
function lib.target.removeInteraction(interactionType, identifier, optionNames)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    local interactionType = string.lower(interactionType)

    if interactionType == 'zone' or interactionType == 'sphere' or interactionType == 'circle' or
        interactionType == 'box' or interactionType == 'poly' or interactionType == 'polygon' then
        lib.target.removeZone(identifier)
    elseif interactionType == 'coords' then
        lib.target.removeCoords(identifier, optionNames)
    elseif interactionType == 'entity' then
        lib.target.removeTargetEntity(identifier)
    elseif interactionType == 'model' then
        lib.target.removeModel(identifier, optionNames)
    elseif interactionType == 'globalped' then
        lib.target.removeGlobalPed(optionNames)
    elseif interactionType == 'globalvehicle' then
        lib.target.removeGlobalVehicle(optionNames)
    elseif interactionType == 'globalobject' then
        lib.target.removeGlobalObject(optionNames)
    elseif interactionType == 'globalplayer' then
        lib.target.removeGlobalPlayer(optionNames)
    elseif interactionType == 'localentity' then
        lib.target.removeLocalEntity(identifier, optionNames)
    else
        lib.print.error(('Unknown interaction type: %s'):format(interactionType))
    end
end

--- Create a universal option format that works across all target systems.
---@param label string The display label
---@param action function|string The action to perform (function, event name, etc.)
---@param actionType? string Type of action ('function', 'event', 'serverEvent', 'command', 'export')
---@param icon? string Icon for the option
---@param canInteract? function Function to check if interaction is available
---@param distance? number Interaction distance
---@param name? string Unique name for the option
---@return table option Universal option format
function lib.target.createOption(label, action, actionType, icon, canInteract, distance, name)
    local option = {
        label = label,
        icon = icon or 'fas fa-hand',
        distance = distance or 2.0,
        name = name or ('option_' .. GetGameTimer()),
        canInteract = canInteract
    }

    -- Handle different action types
    actionType = actionType or 'function'

    if actionType == 'function' and type(action) == 'function' then
        option.onSelect = action
        option.action = action -- For compatibility
    elseif actionType == 'event' then
        option.event = action
        option.type = 'client'
    elseif actionType == 'serverEvent' then
        option.serverEvent = action
        option.event = action
        option.type = 'server'
    elseif actionType == 'command' then
        option.command = action
    elseif actionType == 'export' then
        option.export = action
    else
        -- Default to function
        option.onSelect = action
        option.action = action
    end

    return option
end

--- Batch add multiple interactions at once.
---@param interactions table[] Array of interaction definitions
---@return table results Array of results from each interaction
function lib.target.addBatch(interactions)
    local results = {}

    for i, interaction in ipairs(interactions) do
        local result = lib.target.addInteraction(interaction.type, interaction.data)
        results[i] = {
            index = i,
            type = interaction.type,
            result = result,
            success = result ~= nil
        }
    end

    return results
end

--- Batch remove multiple interactions at once.
---@param interactions table[] Array of interaction removal definitions
function lib.target.removeBatch(interactions)
    for _, interaction in ipairs(interactions) do
        lib.target.removeInteraction(interaction.type, interaction.identifier, interaction.optionNames)
    end
end

--- Debug function to print current target system info.
function lib.target.debugInfo()
    if not targetResource then
        print('No target system initialized')
        return
    end

    print('=== TARGET SYSTEM DEBUG INFO ===')
    print(('Active Resource: %s'):format(targetResource))
    print(('Is Available: %s'):format(tostring(lib.target.isAvailable())))
    print(('Is ox_target: %s'):format(tostring(lib.target.isOxTarget())))
    print(('Is sleepless_interact: %s'):format(tostring(lib.target.isSleeplessInteract())))
    print(('Is Legacy: %s'):format(tostring(lib.target.isLegacy())))

    print('Supported Features:')
    local features = lib.target.getSupportedFeatures()
    for feature, supported in pairs(features) do
        print(('  %s: %s'):format(feature, tostring(supported)))
    end
    print('================================')
end

return lib.target
