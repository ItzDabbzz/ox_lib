--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxDispatch
lib.dispatch = {}

---@class DispatchData
---@field code string Police code (e.g., "10-35", "Code 3")
---@field title string Alert title
---@field message string Alert message/description
---@field coords? vector3 Optional coordinates (defaults to player position)
---@field jobs? string[] Jobs that receive the alert (defaults to police)
---@field priority? 'low'|'normal'|'high' Alert priority
---@field blip? table Blip configuration
---@field sound? boolean Enable alert sound

--- Table of supported dispatch resources
local DISPATCH_RESOURCES = {
    'linden_outlawalert',
    'cd_dispatch',
    'ps-dispatch',
    'qs-dispatch',
    'core_dispatch',
    'origen_police',
    'codem-dispatch'
}

--- Current dispatch function
local dispatchFunction = nil

--- Gets street and zone information from coordinates
---@param coords vector3
---@return string
local function getLocation(coords)
    local streetName, crossingRoad = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local zoneName = GetNameOfZone(coords.x, coords.y, coords.z)

    local street = GetStreetNameFromHashKey(streetName)
    local zone = GetLabelText(zoneName)

    if crossingRoad and crossingRoad ~= 0 then
        local crossName = GetStreetNameFromHashKey(crossingRoad)
        if crossName and crossName ~= '' then
            street = street .. ' & ' .. crossName
        end
    end

    if zone and zone ~= 'NULL' and zone ~= '' then
        return street .. ', ' .. zone
    end

    return street
end

--- Creates dispatch function for linden_outlawalert
local function createLindenDispatch()
    return function(data, coords, location)
        TriggerServerEvent('wf-alerts:svNotify', {
            dispatchData = {
                displayCode = data.code,
                description = data.message,
                isImportant = data.priority == 'high' and 1 or 0,
                recipientList = data.jobs or { 'police' },
                length = '10000',
                infoM = 'fa-info-circle',
                info = data.message
            },
            caller = 'Citizen',
            coords = coords
        })
    end
end

--- Creates dispatch function for cd_dispatch
local function createCdDispatch()
    return function(data, coords, location)
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = data.jobs or { 'police' },
            coords = coords,
            title = data.title,
            message = ('%s on %s'):format(data.message, location),
            flash = data.priority == 'high' and 1 or 0,
            unique_id = math.random(999999999),
            sound = data.sound ~= false and 1 or 0,
            blip = {
                sprite = data.blip and data.blip.sprite or 161,
                scale = data.blip and data.blip.scale or 1.0,
                colour = data.blip and data.blip.color or 1,
                flashes = data.priority == 'high',
                text = data.title,
                time = 5,
                radius = 0
            }
        })
    end
end

--- Creates dispatch function for ps-dispatch
local function createPsDispatch()
    return function(data, coords, location)
        -- Convert ox_lib format to ps-dispatch format
        local dispatchData = {
            message = data.title or data.message,
            codeName = data.title and data.title:lower():gsub('%s+', '') or 'drugactivity',
            code = data.code or '10-17',
            icon = 'fas fa-pills', -- Drug related icon
            priority = data.priority == 'high' and 1 or 2,
            coords = coords,
            street = location,
            gender = nil, -- Will be set by ps-dispatch
            jobs = data.jobs or { 'leo' },
            alert = {
                radius = data.blip and data.blip.radius or 0,
                recipientList = data.jobs or { 'leo' },
                sprite = data.blip and data.blip.sprite or 51,
                color = data.blip and data.blip.color or 1,
                scale = data.blip and data.blip.scale or 0.8,
                length = 5, -- 5 minutes on map
                sound = data.sound ~= false and 'Lose_1st' or nil,
                sound2 = 'GTAO_FM_Events_Soundset',
                offset = data.offset or false,
                flash = data.priority == 'high'
            }
        }

        TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
    end
end


--- Creates dispatch function for qs-dispatch
local function createQsDispatch()
    return function(data, coords, location)
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = data.jobs or { 'police' },
            callLocation = coords,
            callCode = {
                code = data.code,
                snippet = data.message
            },
            message = ('%s on %s'):format(data.message, location),
            flashes = data.priority == 'high',
            blip = {
                sprite = data.blip and data.blip.sprite or 161,
                scale = data.blip and data.blip.scale or 1.0,
                colour = data.blip and data.blip.color or 1,
                flashes = data.priority == 'high',
                text = data.title,
                time = 6 * 60 * 1000
            }
        })
    end
end

--- Creates dispatch function for core_dispatch
local function createCoreDispatch()
    return function(data, coords, location)
        TriggerServerEvent('core_dispatch:addCall',
            data.code,
            data.message,
            { { icon = 'fa-info-circle', info = data.message } },
            { coords.x, coords.y, coords.z },
            data.jobs or { 'police' },
            10000,
            data.blip and data.blip.sprite or 161,
            data.blip and data.blip.color or 1
        )
    end
end

--- Creates dispatch function for origen_police
local function createOrigenDispatch()
    return function(data, coords, location)
        TriggerServerEvent('SendAlert:police', {
            coords = coords,
            title = data.message,
            type = data.code,
            message = data.message,
            job = 'police'
        })
    end
end

--- Creates dispatch function for codem-dispatch
local function createCodemDispatch()
    return function(data, coords, location)
        exports['codem-dispatch']:CustomDispatch({
            type = 'Illegal',
            header = data.title,
            text = ('%s on %s'):format(data.message, location),
            code = data.code
        })
    end
end

--- Dispatch factory functions
local DISPATCH_FACTORIES = {
    ['linden_outlawalert'] = createLindenDispatch,
    ['cd_dispatch'] = createCdDispatch,
    ['ps-dispatch'] = createPsDispatch,
    ['qs-dispatch'] = createQsDispatch,
    ['core_dispatch'] = createCoreDispatch,
    ['origen_police'] = createOrigenDispatch,
    ['codem-dispatch'] = createCodemDispatch
}

--- Detects and initializes dispatch system
local function initialize()
    if dispatchFunction then return end

    for _, resource in ipairs(DISPATCH_RESOURCES) do
        if GetResourceState(resource) == 'started' then
            local factory = DISPATCH_FACTORIES[resource]
            if factory then
                dispatchFunction = factory()
                lib.print.info(('Dispatch system: %s'):format(resource))
                return
            end
        end
    end

    -- Fallback
    dispatchFunction = function(data, coords, location)
        lib.print.warn('No dispatch system found')
    end
end

--- Sends a dispatch alert
---@param data DispatchData|string Dispatch data or simple message
---@param code? string Police code (if data is string)
---@param title? string Alert title (if data is string)
---@return boolean success
function lib.dispatch.send(data, code, title)
    if not dispatchFunction then
        initialize()
    end

    -- Handle simple string input
    if type(data) == 'string' then
        data = {
            message = data,
            code = code or '10-35',
            title = title or 'Alert'
        }
    end

    -- Validate required fields
    if not data.message or not data.code or not data.title then
        lib.print.error('Dispatch requires message, code, and title')
        return false
    end

    -- Get coordinates
    local coords = data.coords or GetEntityCoords(cache.ped)
    if type(coords) == 'table' and not coords.x then
        coords = vector3(coords[1] or 0, coords[2] or 0, coords[3] or 0)
    end

    -- Get location info
    local location = getLocation(coords)

    -- Send dispatch
    local success, err = pcall(dispatchFunction, data, coords, location)
    if not success then
        lib.print.error(('Dispatch failed: %s'):format(err))
        return false
    end

    return true
end

--- Quick dispatch with minimal setup
---@param message string Alert message
---@param code? string Police code (default: "10-35")
---@param jobs? string[] Jobs to alert (default: police)
---@return boolean success
function lib.dispatch.alert(message, code, jobs)
    return lib.dispatch.send({
        message = message,
        code = code or '10-35',
        title = 'Alert',
        jobs = jobs
    })
end

--- High priority dispatch
---@param message string Alert message
---@param code? string Police code (default: "Code 3")
---@param jobs? string[] Jobs to alert
---@return boolean success
function lib.dispatch.urgent(message, code, jobs)
    return lib.dispatch.send({
        message = message,
        code = code or 'Code 3',
        title = 'URGENT',
        priority = 'high',
        jobs = jobs
    })
end

--- Vehicle-related dispatch
---@param message string Alert message
---@param plate? string Vehicle plate
---@param code? string Police code (default: "10-35")
---@return boolean success
function lib.dispatch.vehicle(message, plate, code)
    local fullMessage = plate and ('%s - Plate: %s'):format(message, plate) or message
    return lib.dispatch.send({
        message = fullMessage,
        code = code or '10-35',
        title = 'Vehicle Alert',
        blip = { sprite = 225, color = 5 }
    })
end

--- Weapon-related dispatch
---@param message string Alert message
---@param weapon? string Weapon name
---@param code? string Police code (default: "10-71")
---@return boolean success
function lib.dispatch.weapon(message, weapon, code)
    local fullMessage = weapon and ('%s - Weapon: %s'):format(message, weapon) or message
    return lib.dispatch.send({
        message = fullMessage,
        code = code or '10-71',
        title = 'SHOTS FIRED',
        priority = 'high',
        blip = { sprite = 110, color = 1 }
    })
end

--- Initialize on resource start
CreateThread(function()
    Wait(25000)
    initialize()
end)

--- Re-initialize when dispatch resources start/stop
AddEventHandler('onClientResourceStart', function(resource)
    if lib.table.contains(DISPATCH_RESOURCES, resource) then
        dispatchFunction = nil
        initialize()
    end
end)

AddEventHandler('onClientResourceStop', function(resource)
    if lib.table.contains(DISPATCH_RESOURCES, resource) then
        dispatchFunction = nil
    end
end)

return lib.dispatch
