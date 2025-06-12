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
    local resources = { 'qb-target', 'qtarget', 'ox_target' }

    for _, resource in ipairs(resources) do
        if GetResourceState(resource) == 'started' then
            targetResource = resource == 'ox_target' and 'qtarget' or resource
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

--- Add a circle zone.
---@param identifier string The identifier for the zone.
---@param coords vector3 Coordinates where the zone is centered.
---@param radius number The radius of the circle zone.
---@param data table Additional data such as options and distance.
---@param debugPoly? boolean Whether to debug the polygon.
---@return any handler The handle to the created zone.
function lib.target.addCircleZone(identifier, coords, radius, data, debugPoly)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if type(coords) == 'table' and not coords.x then
        coords = vector3(coords[1] or coords.x or 0, coords[2] or coords.y or 0, coords[3] or coords.z or 0)
    end

    local handler = exports[targetResource]:AddCircleZone(identifier, coords, radius, {
        name = identifier,
        useZ = data.useZ ~= false,
        debugPoly = debugPoly or false,
    }, {
        options = data.options or {},
        distance = data.distance or 2.0,
    })

    return handler
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

    -- Convert points to proper format if needed
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

    exports[targetResource]:AddTargetEntity(entityId, {
        options = data.options or {},
        distance = data.distance or 2.0,
    })
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

    exports[targetResource]:AddTargetModel(models, {
        options = data.options or {},
        distance = data.distance or 2.0,
    })
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

    exports[targetResource]:AddTargetBone(bones, {
        options = data.options or {},
        distance = data.distance or 2.0,
    })
end

--- Remove a target entity.
---@param entity number The entity to remove from targeting.
function lib.target.removeTargetEntity(entity)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    exports[targetResource]:RemoveTargetEntity(entity)
end

--- Remove a zone.
---@param identifier string The identifier for the zone to remove.
function lib.target.removeZone(identifier)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    exports[targetResource]:RemoveZone(identifier)
end

--- Add a global ped target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalPed(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    exports[targetResource]:AddGlobalPed({
        options = data.options or {},
        distance = data.distance or 2.0,
    })
end

--- Add a global vehicle target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalVehicle(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    exports[targetResource]:AddGlobalVehicle({
        options = data.options or {},
        distance = data.distance or 2.0,
    })
end

--- Add a global object target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalObject(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    exports[targetResource]:AddGlobalObject({
        options = data.options or {},
        distance = data.distance or 2.0,
    })
end

--- Add a global player target.
---@param data table Additional data such as options and distance.
function lib.target.addGlobalPlayer(data)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    exports[targetResource]:AddGlobalPlayer({
        options = data.options or {},
        distance = data.distance or 2.0,
    })
end

--- Remove a global ped target.
---@param label? string The label for the global ped to remove (if supported).
function lib.target.removeGlobalPed(label)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if label then
        exports[targetResource]:RemoveGlobalPed(label)
    else
        exports[targetResource]:RemoveGlobalPed()
    end
end

--- Remove a global vehicle target.
---@param label? string The label for the global vehicle to remove (if supported).
function lib.target.removeGlobalVehicle(label)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if label then
        exports[targetResource]:RemoveGlobalVehicle(label)
    else
        exports[targetResource]:RemoveGlobalVehicle()
    end
end

--- Remove a global object target.
---@param label? string The label for the global object to remove (if supported).
function lib.target.removeGlobalObject(label)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if label then
        exports[targetResource]:RemoveGlobalObject(label)
    else
        exports[targetResource]:RemoveGlobalObject()
    end
end

--- Remove a global player target.
---@param label? string The label for the global player to remove (if supported).
function lib.target.removeGlobalPlayer(label)
    if not targetResource then
        lib.print.error('Target system not initialized')
        return
    end

    if label then
        exports[targetResource]:RemoveGlobalPlayer(label)
    else
        exports[targetResource]:RemoveGlobalPlayer()
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

--- Refresh the target system (re-initialize).
---@return boolean success Whether the refresh was successful.
function lib.target.refresh()
    targetResource = nil
    return initialize()
end

return lib.target
