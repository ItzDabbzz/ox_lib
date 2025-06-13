--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxDraw
lib.draw = {}

---@class DrawTextOptions
---@field coords vector3 World coordinates for the text
---@field text string Text content to display
---@field font? number Font ID (default: 0)
---@field scale? number Text scale multiplier (default: 1.0)
---@field color? number[] RGBA color array (default: {255, 255, 255, 255})
---@field outline? boolean Enable text outline (default: true)
---@field center? boolean Center the text (default: true)
---@field distance? number Maximum render distance (default: 5000)
---@field onScreen? boolean Only render when on screen (default: true)
---@field background? DrawTextBackground Optional background configuration
---@field visible? fun(): boolean Optional visibility check function

---@class DrawTextBackground
---@field enabled boolean Enable background rendering
---@field color number[] RGBA background color
---@field padding? number Background padding (default: 0.01)

---@class Draw2DOptions
---@field text string Text content to display
---@field x? number Screen X position (0.0-1.0, default: 0.5)
---@field y? number Screen Y position (0.0-1.0, default: 0.5)
---@field font? number Font ID (default: 4)
---@field scale? number Text scale (default: 0.35)
---@field color? number[] RGBA color array (default: {255, 255, 255, 220})
---@field outline? boolean Enable text outline (default: true)
---@field shadow? boolean Enable drop shadow (default: true)
---@field center? boolean Center the text (default: false)

---@class DrawLineOptions
---@field startCoords vector3 Line start coordinates
---@field endCoords vector3 Line end coordinates
---@field color? number[] RGBA color array (default: {255, 255, 255, 255})
---@field width? number Line width (default: 1.0)

---@class DrawMarkerOptions
---@field coords vector3 Marker coordinates
---@field type? number Marker type ID (default: 1)
---@field size? vector3 Marker size (default: vector3(1.0, 1.0, 1.0))
---@field rotation? vector3 Marker rotation (default: vector3(0.0, 0.0, 0.0))
---@field color? number[] RGBA color array (default: {255, 255, 255, 100})
---@field bobUpAndDown? boolean Enable bobbing animation (default: false)
---@field faceCamera? boolean Face camera (default: false)
---@field rotate? boolean Enable rotation (default: false)
---@field textureDict? string Texture dictionary
---@field textureName? string Texture name

---@class DrawSpriteOptions
---@field textureDict string Texture dictionary name
---@field textureName string Texture name
---@field x number Screen X position (0.0-1.0)
---@field y number Screen Y position (0.0-1.0)
---@field width number Sprite width (0.0-1.0)
---@field height number Sprite height (0.0-1.0)
---@field heading? number Sprite rotation in degrees (default: 0.0)
---@field color? number[] RGBA color array (default: {255, 255, 255, 255})

local DEFAULT_TEXT_OPTIONS = {
    font = 0,
    scale = 1.0,
    color = { 255, 255, 255, 255 },
    outline = true,
    center = true,
    distance = 5000,
    onScreen = true
}

local DEFAULT_2D_OPTIONS = {
    x = 0.5,
    y = 0.5,
    font = 4,
    scale = 0.35,
    color = { 255, 255, 255, 220 },
    outline = true,
    shadow = true,
    center = false
}

local DEFAULT_LINE_OPTIONS = {
    color = { 255, 255, 255, 255 },
    width = 1.0
}

local DEFAULT_MARKER_OPTIONS = {
    type = 1,
    size = vector3(1.0, 1.0, 1.0),
    rotation = vector3(0.0, 0.0, 0.0),
    color = { 255, 255, 255, 100 },
    bobUpAndDown = false,
    faceCamera = false,
    rotate = false
}

local DEFAULT_SPRITE_OPTIONS = {
    heading = 0.0,
    color = { 255, 255, 255, 255 }
}

--- Active 3D text renders
local activeText3D = {}
local textIdCounter = 0

--- Merges user options with defaults
---@param userOptions table?
---@param defaultOptions table
---@return table
local function mergeOptions(userOptions, defaultOptions)
    if not userOptions then
        return lib.table.deepclone(defaultOptions)
    end

    return lib.table.merge(lib.table.deepclone(defaultOptions), userOptions)
end

--- Validates coordinates parameter
---@param coords any
---@param paramName string
---@return vector3?
local function validateCoords(coords, paramName)
    if not coords then
        lib.print.error(('%s is required'):format(paramName))
        return nil
    end

    if type(coords) == 'table' and not coords.x then
        -- Convert array-style coordinates to vector3
        if coords[1] and coords[2] and coords[3] then
            coords = vector3(coords[1], coords[2], coords[3])
        else
            lib.print.error(('%s must be vector3 or coordinate array'):format(paramName))
            return nil
        end
    elseif type(coords) ~= 'vector3' then
        lib.print.error(('%s must be vector3'):format(paramName))
        return nil
    end

    return coords
end

--- Validates color array
---@param color number[]?
---@param defaultColor number[]
---@return number[]
local function validateColor(color, defaultColor)
    if not color then
        return defaultColor
    end

    if type(color) ~= 'table' or #color < 3 then
        lib.print.warn('Invalid color array, using default')
        return defaultColor
    end

    -- Ensure we have RGBA values
    return {
        color[1] or 255,
        color[2] or 255,
        color[3] or 255,
        color[4] or 255
    }
end

--- Internal function to render 3D text
---@param options DrawTextOptions
local function renderText3D(options)
    if options.visible and not options.visible() then
        return
    end

    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(playerCoords - options.coords)

    if distance > options.distance then
        return
    end

    local onScreen, screenX, screenY = World3dToScreen2d(options.coords.x, options.coords.y, options.coords.z)

    if not onScreen and options.onScreen then
        return
    end

    -- Calculate scale based on distance
    local camCoords = GetFinalRenderedCamCoord()
    local camDistance = #(camCoords - options.coords)
    local scale = (1.0 / camDistance) * 2.0 * options.scale
    local fov = (1.0 / GetFinalRenderedCamFov()) * 100.0
    scale = scale * fov

    -- Draw background if enabled
    if options.background and options.background.enabled then
        local bgColor = validateColor(options.background.color, { 0, 0, 0, 100 })
        local padding = options.background.padding or 0.01
        local textLength = #options.text
        local width = (textLength * scale * 0.012) + (padding * 2)
        local height = (scale * 0.025) + (padding * 2)

        -- The text is drawn at screenY, so the background should also be centered at screenY
        DrawRect(screenX, screenY, width, height, bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    end

    -- Set text properties
    SetTextScale(0.0, scale)
    SetTextFont(options.font)
    SetTextProportional(true)
    SetTextColour(options.color[1], options.color[2], options.color[3], options.color[4])

    if options.outline then
        SetTextOutline()
    end

    SetTextCentre(options.center)
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(options.text)
    DrawText(screenX, screenY)
end


--- Draws 3D text at world coordinates for a single frame
---@param options DrawTextOptions
function lib.draw.text3d(options)
    if not options or not options.coords or not options.text then
        lib.print.error('text3d requires coords and text parameters')
        return
    end

    local coords = validateCoords(options.coords, 'coords')
    if not coords then return end

    local mergedOptions = mergeOptions(options, DEFAULT_TEXT_OPTIONS)
    mergedOptions.coords = coords
    mergedOptions.color = validateColor(options.color, DEFAULT_TEXT_OPTIONS.color)

    renderText3D(mergedOptions)
end

--- Draws 3D text permanently until stopped
---@param options DrawTextOptions
---@return number textId Unique identifier for the text render
function lib.draw.text3dPermanent(options)
    if not options or not options.coords or not options.text then
        lib.print.error('text3dPermanent requires coords and text parameters')
        return -1
    end

    local coords = validateCoords(options.coords, 'coords')
    if not coords then return -1 end

    textIdCounter = textIdCounter + 1
    local textId = textIdCounter

    local mergedOptions = mergeOptions(options, DEFAULT_TEXT_OPTIONS)
    mergedOptions.coords = coords
    mergedOptions.color = validateColor(options.color, DEFAULT_TEXT_OPTIONS.color)

    activeText3D[textId] = mergedOptions

    return textId
end

--- Draws 3D text for a specified duration
---@param options DrawTextOptions
---@param duration number Duration in milliseconds
---@return number textId Unique identifier for the text render
function lib.draw.text3dTimed(options, duration)
    if not duration or duration <= 0 then
        lib.print.error('text3dTimed requires a positive duration')
        return -1
    end

    local textId = lib.draw.text3dPermanent(options)

    if textId ~= -1 then
        SetTimeout(duration, function()
            lib.draw.removeText3d(textId)
        end)
    end

    return textId
end

--- Removes a permanent 3D text render
---@param textId number The text ID returned by text3dPermanent
function lib.draw.removeText3d(textId)
    if activeText3D[textId] then
        activeText3D[textId] = nil
    end
end

--- Updates the text content of an existing 3D text render
---@param textId number The text ID to update
---@param newText string The new text content
---@return boolean success Whether the update was successful
function lib.draw.updateText3d(textId, newText)
    if not activeText3D[textId] then
        lib.print.error('Invalid text ID: ' .. tostring(textId))
        return false
    end

    if type(newText) ~= 'string' then
        lib.print.error('New text must be a string')
        return false
    end

    activeText3D[textId].text = newText
    return true
end

--- Draws 2D text on screen
---@param options Draw2DOptions|string If string, uses default options with that text
function lib.draw.text2d(options)
    local mergedOptions

    if type(options) == 'string' then
        mergedOptions = mergeOptions({ text = options }, DEFAULT_2D_OPTIONS)
    else
        if not options or not options.text then
            lib.print.error('text2d requires text parameter')
            return
        end
        mergedOptions = mergeOptions(options, DEFAULT_2D_OPTIONS)
    end

    mergedOptions.color = validateColor(options and options.color, DEFAULT_2D_OPTIONS.color)

    SetTextFont(mergedOptions.font)
    SetTextProportional(true)
    SetTextScale(0.0, mergedOptions.scale)
    SetTextColour(mergedOptions.color[1], mergedOptions.color[2], mergedOptions.color[3], mergedOptions.color[4])

    if mergedOptions.shadow then
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
    end

    if mergedOptions.outline then
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextOutline()
    end

    SetTextCentre(mergedOptions.center)
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(mergedOptions.text)
    DrawText(mergedOptions.x, mergedOptions.y)
end

--- Draws a line between two points
---@param options DrawLineOptions
function lib.draw.line(options)
    if not options or not options.startCoords or not options.endCoords then
        lib.print.error('line requires startCoords and endCoords parameters')
        return
    end

    local startCoords = validateCoords(options.startCoords, 'startCoords')
    local endCoords = validateCoords(options.endCoords, 'endCoords')

    if not startCoords or not endCoords then return end

    local mergedOptions = mergeOptions(options, DEFAULT_LINE_OPTIONS)
    mergedOptions.color = validateColor(options.color, DEFAULT_LINE_OPTIONS.color)

    DrawLine(
        startCoords.x, startCoords.y, startCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        mergedOptions.color[1], mergedOptions.color[2], mergedOptions.color[3], mergedOptions.color[4]
    )
end

--- Draws a marker at specified coordinates
---@param options DrawMarkerOptions
function lib.draw.marker(options)
    if not options or not options.coords then
        lib.print.error('marker requires coords parameter')
        return
    end

    local coords = validateCoords(options.coords, 'coords')
    if not coords then return end

    local mergedOptions = mergeOptions(options, DEFAULT_MARKER_OPTIONS)
    mergedOptions.color = validateColor(options.color, DEFAULT_MARKER_OPTIONS.color)

    -- Ensure size is vector3
    if type(mergedOptions.size) == 'table' and not mergedOptions.size.x then
        mergedOptions.size = vector3(
            mergedOptions.size[1] or 1.0,
            mergedOptions.size[2] or 1.0,
            mergedOptions.size[3] or 1.0
        )
    end

    -- Ensure rotation is vector3
    if type(mergedOptions.rotation) == 'table' and not mergedOptions.rotation.x then
        mergedOptions.rotation = vector3(
            mergedOptions.rotation[1] or 0.0,
            mergedOptions.rotation[2] or 0.0,
            mergedOptions.rotation[3] or 0.0
        )
    end

    DrawMarker(
        mergedOptions.type,
        coords.x, coords.y, coords.z,
        mergedOptions.rotation.x, mergedOptions.rotation.y, mergedOptions.rotation.z,
        0.0, 0.0, 0.0,
        mergedOptions.size.x, mergedOptions.size.y, mergedOptions.size.z,
        mergedOptions.color[1], mergedOptions.color[2], mergedOptions.color[3], mergedOptions.color[4],
        mergedOptions.bobUpAndDown, mergedOptions.faceCamera, 2, mergedOptions.rotate,
        mergedOptions.textureDict, mergedOptions.textureName, false
    )
end

--- Draws a sprite on screen
---@param options DrawSpriteOptions
function lib.draw.sprite(options)
    if not options or not options.textureDict or not options.textureName then
        lib.print.error('sprite requires textureDict and textureName parameters')
        return
    end

    if not options.x or not options.y or not options.width or not options.height then
        lib.print.error('sprite requires x, y, width, and height parameters')
        return
    end

    local mergedOptions = mergeOptions(options, DEFAULT_SPRITE_OPTIONS)
    mergedOptions.color = validateColor(options.color, DEFAULT_SPRITE_OPTIONS.color)

    -- Request texture dictionary if not loaded
    if not HasStreamedTextureDictLoaded(mergedOptions.textureDict) then
        lib.requestStreamedTextureDict(mergedOptions.textureDict)
    end

    DrawSprite(
        mergedOptions.textureDict,
        mergedOptions.textureName,
        mergedOptions.x,
        mergedOptions.y,
        mergedOptions.width,
        mergedOptions.height,
        mergedOptions.heading,
        mergedOptions.color[1], mergedOptions.color[2], mergedOptions.color[3], mergedOptions.color[4]
    )
end

--- Draws a rectangle on screen
---@param x number Screen X position (0.0-1.0)
---@param y number Screen Y position (0.0-1.0)
---@param width number Rectangle width (0.0-1.0)
---@param height number Rectangle height (0.0-1.0)
---@param color? number[] RGBA color array (default: {255, 255, 255, 255})
function lib.draw.rect(x, y, width, height, color)
    if not x or not y or not width or not height then
        lib.print.error('rect requires x, y, width, and height parameters')
        return
    end

    color = validateColor(color, { 255, 255, 255, 255 })

    DrawRect(x, y, width, height, color[1], color[2], color[3], color[4])
end

--- Draws a polygon
---@param vertices vector3[] Array of world coordinates defining the polygon
---@param color? number[] RGBA color array (default: {255, 255, 255, 100})
function lib.draw.polygon(vertices, color)
    if not vertices or type(vertices) ~= 'table' or #vertices < 3 then
        lib.print.error('polygon requires at least 3 vertices')
        return
    end

    color = validateColor(color, { 255, 255, 255, 100 })

    -- Draw triangulated polygon
    for i = 2, #vertices - 1 do
        local v1 = validateCoords(vertices[1], 'vertex 1')
        local v2 = validateCoords(vertices[i], ('vertex %d'):format(i))
        local v3 = validateCoords(vertices[i + 1], ('vertex %d'):format(i + 1))

        if v1 and v2 and v3 then
            DrawPoly(
                v1.x, v1.y, v1.z,
                v2.x, v2.y, v2.z,
                v3.x, v3.y, v3.z,
                color[1], color[2], color[3], color[4]
            )
        end
    end
end

--- Draws a box outline
---@param coords vector3 Center coordinates
---@param size vector3 Box dimensions
---@param rotation? vector3 Box rotation (default: vector3(0, 0, 0))
---@param color? number[] RGBA color array (default: {255, 255, 255, 255})
function lib.draw.box(coords, size, rotation, color)
    coords = validateCoords(coords, 'coords')
    if not coords then return end

    if not size then
        lib.print.error('box requires size parameter')
        return
    end

    -- Convert size to vector3 if needed
    if type(size) == 'table' and not size.x then
        size = vector3(size[1] or 1.0, size[2] or 1.0, size[3] or 1.0)
    elseif type(size) ~= 'vector3' then
        lib.print.error('size must be vector3 or coordinate array')
        return
    end

    rotation = rotation or vector3(0.0, 0.0, 0.0)
    if type(rotation) == 'table' and not rotation.x then
        rotation = vector3(rotation[1] or 0.0, rotation[2] or 0.0, rotation[3] or 0.0)
    end

    color = validateColor(color, { 255, 255, 255, 255 })

    -- Calculate box corners
    local halfSize = size * 0.5
    local corners = {
        vector3(-halfSize.x, -halfSize.y, -halfSize.z),
        vector3(halfSize.x, -halfSize.y, -halfSize.z),
        vector3(halfSize.x, halfSize.y, -halfSize.z),
        vector3(-halfSize.x, halfSize.y, -halfSize.z),
        vector3(-halfSize.x, -halfSize.y, halfSize.z),
        vector3(halfSize.x, -halfSize.y, halfSize.z),
        vector3(halfSize.x, halfSize.y, halfSize.z),
        vector3(-halfSize.x, halfSize.y, halfSize.z)
    }

    -- Apply rotation if needed
    if rotation.x ~= 0 or rotation.y ~= 0 or rotation.z ~= 0 then
        local rotMatrix = lib.math.getRotationMatrix(rotation)
        for i, corner in ipairs(corners) do
            corners[i] = lib.math.rotateVector(corner, rotMatrix)
        end
    end

    -- Translate to world position
    for i, corner in ipairs(corners) do
        corners[i] = coords + corner
    end

    -- Draw box edges
    local edges = {
        { 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 }, -- Bottom face
        { 5, 6 }, { 6, 7 }, { 7, 8 }, { 8, 5 }, -- Top face
        { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 }  -- Vertical edges
    }

    for _, edge in ipairs(edges) do
        lib.draw.line({
            startCoords = corners[edge[1]],
            endCoords = corners[edge[2]],
            color = color
        })
    end
end

--- Draws a sphere outline
---@param coords vector3 Center coordinates
---@param radius number Sphere radius
---@param color? number[] RGBA color array (default: {255, 255, 255, 255})
---@param segments? number Number of segments for sphere detail (default: 16)
function lib.draw.sphere(coords, radius, color, segments)
    coords = validateCoords(coords, 'coords')
    if not coords then return end

    if not radius or type(radius) ~= 'number' or radius <= 0 then
        lib.print.error('sphere requires a positive radius')
        return
    end

    color = validateColor(color, { 255, 255, 255, 255 })
    segments = segments or 16

    local angleStep = (2 * math.pi) / segments

    -- Draw horizontal circles
    for ring = 0, segments do
        local y = math.sin((ring / segments) * math.pi - (math.pi / 2)) * radius
        local ringRadius = math.cos((ring / segments) * math.pi - (math.pi / 2)) * radius

        for i = 0, segments - 1 do
            local angle1 = i * angleStep
            local angle2 = (i + 1) * angleStep

            local x1 = math.cos(angle1) * ringRadius
            local z1 = math.sin(angle1) * ringRadius
            local x2 = math.cos(angle2) * ringRadius
            local z2 = math.sin(angle2) * ringRadius

            lib.draw.line({
                startCoords = coords + vector3(x1, y, z1),
                endCoords = coords + vector3(x2, y, z2),
                color = color
            })
        end
    end

    -- Draw vertical circles
    for i = 0, segments / 2 do
        local angle = i * angleStep

        for j = 0, segments - 1 do
            local angle1 = j * angleStep
            local angle2 = (j + 1) * angleStep

            local x1 = math.cos(angle1) * math.cos(angle) * radius
            local y1 = math.sin(angle1) * radius
            local z1 = math.cos(angle1) * math.sin(angle) * radius

            local x2 = math.cos(angle2) * math.cos(angle) * radius
            local y2 = math.sin(angle2) * radius
            local z2 = math.cos(angle2) * math.sin(angle) * radius

            lib.draw.line({
                startCoords = coords + vector3(x1, y1, z1),
                endCoords = coords + vector3(x2, y2, z2),
                color = color
            })
        end
    end
end

--- Gets all active 3D text renders
---@return table<number, DrawTextOptions>
function lib.draw.getActiveText3D()
    return activeText3D
end

--- Clears all active 3D text renders
function lib.draw.clearAllText3D()
    activeText3D = {}
end

--- Gets the number of active 3D text renders
---@return number
function lib.draw.getActiveText3DCount()
    local count = 0
    for _ in pairs(activeText3D) do
        count = count + 1
    end
    return count
end

--- Internal render loop for permanent 3D text
CreateThread(function()
    while true do
        local hasActiveText = false

        for textId, options in pairs(activeText3D) do
            hasActiveText = true
            renderText3D(options)
        end

        -- Optimize sleep time based on active renders
        Wait(hasActiveText and 0 or 100)
    end
end)

--- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == cache.resource then
        lib.draw.clearAllText3D()
    end
end)

return lib.draw
