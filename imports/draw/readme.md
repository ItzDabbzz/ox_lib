# ox_lib Draw Module

A comprehensive drawing utility module for FiveM that provides easy-to-use functions for rendering 2D/3D text, shapes, and visual elements in-game.

## Features

- **3D Text Rendering**: Single-frame, permanent, and timed 3D text with customizable styling
- **2D Text Rendering**: Screen-space text with full customization options
- **Shape Drawing**: Lines, rectangles, polygons, boxes, spheres, and markers
- **Sprite Support**: Texture-based sprite rendering with rotation and scaling
- **Background Support**: Optional backgrounds for 3D text with padding control
- **Distance Culling**: Automatic rendering optimization based on distance
- **Active Text Management**: Track and manage persistent 3D text renders

## Quick Start

```lua
-- Draw simple 3D text
lib.draw.text3d({
    coords = vector3(100.0, 200.0, 30.0),
    text = "Hello World!"
})

-- Draw 2D text on screen
lib.draw.text2d("Screen Text")

-- Draw a line between two points
lib.draw.line({
    startCoords = vector3(0, 0, 30),
    endCoords = vector3(10, 10, 30),
    color = {255, 0, 0, 255} -- Red line
})
```

## API Reference

### 3D Text Functions

#### `lib.draw.text3d(options)`
Draws 3D text at world coordinates for a single frame.

**Parameters:**
- `options` (DrawTextOptions): Text rendering options

**Example:**
```lua
lib.draw.text3d({
    coords = vector3(100.0, 200.0, 30.0),
    text = "Single Frame Text",
    font = 4,
    scale = 1.0,
    color = {255, 255, 255, 255},
    outline = true,
    center = true,
    distance = 10.0,
    background = {
        enabled = true,
        color = {0, 0, 0, 150},
        padding = 0.02
    }
})
```

#### `lib.draw.text3dPermanent(options)`
Draws 3D text permanently until manually removed.

**Returns:** `number` - Text ID for management

**Example:**
```lua
local textId = lib.draw.text3dPermanent({
    coords = vector3(100.0, 200.0, 30.0),
    text = "Permanent Text",
    color = {0, 255, 0, 255}
})

-- Later, remove the text
lib.draw.removeText3d(textId)
```

#### `lib.draw.text3dTimed(options, duration)`
Draws 3D text for a specified duration.

**Parameters:**
- `options` (DrawTextOptions): Text rendering options
- `duration` (number): Duration in milliseconds

**Returns:** `number` - Text ID

**Example:**
```lua
local textId = lib.draw.text3dTimed({
    coords = vector3(100.0, 200.0, 30.0),
    text = "This text will disappear in 5 seconds"
}, 5000)
```

#### `lib.draw.removeText3d(textId)`
Removes a permanent 3D text render.

**Parameters:**
- `textId` (number): Text ID returned by permanent functions

#### `lib.draw.updateText3d(textId, newText)`
Updates the text content of an existing 3D text render.

**Parameters:**
- `textId` (number): Text ID to update
- `newText` (string): New text content

**Returns:** `boolean` - Success status

**Example:**
```lua
local textId = lib.draw.text3dPermanent({
    coords = vector3(100.0, 200.0, 30.0),
    text = "Initial Text"
})

-- Update the text
lib.draw.updateText3d(textId, "Updated Text")
```

### 2D Text Functions

#### `lib.draw.text2d(options)`
Draws 2D text on screen.

**Parameters:**
- `options` (Draw2DOptions|string): Text options or simple text string

**Example:**
```lua
-- Simple text
lib.draw.text2d("Simple Screen Text")

-- Advanced options
lib.draw.text2d({
    text = "Advanced Screen Text",
    x = 0.5,
    y = 0.1,
    font = 4,
    scale = 0.5,
    color = {255, 255, 0, 255},
    outline = true,
    shadow = true,
    center = true
})
```

### Shape Drawing Functions

#### `lib.draw.line(options)`
Draws a line between two points.

**Example:**
```lua
lib.draw.line({
    startCoords = vector3(0, 0, 30),
    endCoords = vector3(10, 10, 30),
    color = {255, 0, 0, 255},
    width = 2.0
})
```

#### `lib.draw.rect(x, y, width, height, color)`
Draws a rectangle on screen.

**Example:**
```lua
lib.draw.rect(0.4, 0.4, 0.2, 0.2, {255, 0, 0, 100})
```

#### `lib.draw.marker(options)`
Draws a marker at specified coordinates.

**Example:**
```lua
lib.draw.marker({
    coords = vector3(100.0, 200.0, 30.0),
    type = 1,
    size = vector3(2.0, 2.0, 1.0),
    color = {255, 0, 0, 100},
    bobUpAndDown = false,
    faceCamera = true
})
```

#### `lib.draw.box(coords, size, rotation, color)`
Draws a box outline.

**Example:**
```lua
lib.draw.box(
    vector3(100.0, 200.0, 30.0),  -- Center coordinates
    vector3(4.0, 4.0, 2.0),       -- Size
    vector3(0, 0, 45),            -- Rotation (degrees)
    {255, 255, 0, 255}            -- Color
)
```

#### `lib.draw.sphere(coords, radius, color, segments)`
Draws a sphere outline.

**Example:**
```lua
lib.draw.sphere(
    vector3(100.0, 200.0, 30.0),  -- Center
    5.0,                          -- Radius
    {0, 255, 255, 255},          -- Color
    20                           -- Segments (detail level)
)
```

#### `lib.draw.polygon(vertices, color)`
Draws a polygon from vertices.

**Example:**
```lua
lib.draw.polygon({
    vector3(0, 0, 30),
    vector3(5, 0, 30),
    vector3(5, 5, 30),
    vector3(0, 5, 30)
}, {0, 255, 0, 100})
```

### Sprite Functions

#### `lib.draw.sprite(options)`
Draws a sprite on screen.

**Example:**
```lua
lib.draw.sprite({
    textureDict = "commonmenu",
    textureName = "gradient_bgd",
    x = 0.5,
    y = 0.5,
    width = 0.2,
    height = 0.1,
    heading = 45.0,
    color = {255, 255, 255, 200}
})
```

### Management Functions

#### `lib.draw.getActiveText3D()`
Gets all active 3D text renders.

**Returns:** `table<number, DrawTextOptions>`

#### `lib.draw.clearAllText3D()`
Clears all active 3D text renders.

#### `lib.draw.getActiveText3DCount()`
Gets the number of active 3D text renders.

**Returns:** `number`

## Configuration Options

### DrawTextOptions
```lua
{
    coords = vector3(x, y, z),        -- Required: World coordinates
    text = "Text content",            -- Required: Text to display
    font = 0,                         -- Font ID (0-8)
    scale = 1.0,                      -- Text scale multiplier
    color = {255, 255, 255, 255},     -- RGBA color array
    outline = true,                   -- Enable text outline
    center = true,                    -- Center the text
    distance = 5000,                  -- Maximum render distance
    onScreen = true,                  -- Only render when on screen
    background = {                    -- Optional background
        enabled = true,
        color = {0, 0, 0, 100},
        padding = 0.01
    },
    visible = function()              -- Optional visibility check
        return true
    end
}
```

### Draw2DOptions
```lua
{
    text = "Screen text",             -- Required: Text content
    x = 0.5,                         -- Screen X position (0.0-1.0)
    y = 0.5,                         -- Screen Y position (0.0-1.0)
    font = 4,                        -- Font ID
    scale = 0.35,                    -- Text scale
    color = {255, 255, 255, 220},    -- RGBA color
    outline = true,                  -- Enable outline
    shadow = true,                   -- Enable drop shadow
    center = false                   -- Center alignment
}
```

### DrawLineOptions
```lua
{
    startCoords = vector3(x1, y1, z1), -- Required: Line start
    endCoords = vector3(x2, y2, z2),   -- Required: Line end
    color = {255, 255, 255, 255},      -- RGBA color
    width = 1.0                        -- Line width
}
```

### DrawMarkerOptions
```lua
{
    coords = vector3(x, y, z),         -- Required: Marker position
    type = 1,                          -- Marker type (0-43)
    size = vector3(1.0, 1.0, 1.0),    -- Marker size
    rotation = vector3(0, 0, 0),       -- Marker rotation
    color = {255, 255, 255, 100},      -- RGBA color
    bobUpAndDown = false,              -- Bobbing animation
    faceCamera = false,                -- Face camera
    rotate = false,                    -- Enable rotation
    textureDict = nil,                 -- Optional texture dictionary
    textureName = nil                  -- Optional texture name
}
```

## Usage Examples

### Interactive 3D Text with Visibility Control
```lua
local function createInteractiveText()
    local playerPed = PlayerPedId()
    
    local textId = lib.draw.text3dPermanent({
        coords = vector3(100.0, 200.0, 30.0),
        text = "Press [E] to interact",
        color = {0, 255, 0, 255},
        distance = 5.0,
        background = {
            enabled = true,
            color = {0, 0, 0, 150},
            padding = 0.015
        },
        visible = function()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - vector3(100.0, 200.0, 30.0))
            return distance < 3.0
        end
    })
    
    return textId
end
```

### Dynamic Text Updates
```lua
local function createCountdownText()
    local textId = lib.draw.text3dPermanent({
        coords = vector3(100.0, 200.0, 30.0),
        text = "Starting in 10...",
        color = {255, 255, 0, 255}
    })
    
    local countdown = 10
    local timer = SetInterval(function()
        if countdown > 0 then
            lib.draw.updateText3d(textId, ("Starting in %d..."):format(countdown))
            countdown = countdown - 1
        else
            lib.draw.updateText3d(textId, "GO!")
            ClearInterval(timer)
            
            -- Remove text after 2 seconds
            SetTimeout(2000, function()
                lib.draw.removeText3d(textId)
            end)
        end
    end, 1000)
end
```

### Drawing Complex Shapes
```lua
local function drawRaceCheckpoint()
    local coords = vector3(100.0, 200.0, 30.0)
    
    -- Draw checkpoint ring
    lib.draw.sphere(coords, 3.0, {255, 255, 0, 255}, 24)
    
    -- Draw checkpoint marker
    lib.draw.marker({
        coords = coords,
        type = 4, -- Ring marker
        size = vector3(6.0, 6.0, 3.0),
        color = {255, 255, 0, 100},
        bobUpAndDown = true
    })
    
    -- Draw checkpoint text
    lib.draw.text3d({
        coords = coords + vector3(0, 0, 4.0),
        text = "CHECKPOINT",
        scale = 1.5,
        color = {255, 255, 0, 255},
        center = true
    })
end
```

### HUD Elements with 2D Drawing
```lua
local function drawCustomHUD()
    -- Background panel
    lib.draw.rect(0.02, 0.02, 0.25, 0.15, {0, 0, 0, 150})
    
    -- Title
    lib.draw.text2d({
        text = "Player Stats",
        x = 0.145,
        y = 0.04,
        font = 4,
        scale = 0.4,
        color = {255, 255, 255, 255},
        center = true
    })
    
    -- Health bar background
    lib.draw.rect(0.04, 0.08, 0.21, 0.02, {100, 0, 0, 200})
    
    -- Health bar fill
    local health = GetEntityHealth(PlayerPedId()) / GetEntityMaxHealth(PlayerPedId())
    lib.draw.rect(0.04, 0.08, 0.21 * health, 0.02, {255, 0, 0, 255})
    
    -- Health text
    lib.draw.text2d({
        text = "Health",
        x = 0.05,
        y = 0.11,
        font = 0,
        scale = 0.3,
        color = {255, 255, 255, 255}
    })
end
```

### Performance Optimization
```lua
local function optimizedDrawing()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local drawDistance = 50.0
    
    -- Only draw if player is within range
    local targetCoords = vector3(100.0, 200.0, 30.0)
    local distance = #(playerCoords - targetCoords)
    
    if distance < drawDistance then
        -- Use distance-based scaling
        local scale = math.max(0.5, 2.0 - (distance / drawDistance))
        
        lib.draw.text3d({
            coords = targetCoords,
            text = "Optimized Text",
            scale = scale,
            distance = drawDistance,
            onScreen = true -- Only render when on screen
        })
    end
end
```

## Best Practices

### Performance
- Use `distance` parameter to limit rendering range
- Enable `onScreen` for 3D text to avoid rendering off-screen elements
- Use `visible` callback functions for conditional rendering
- Limit the number of permanent 3D text renders
- Use `lib.draw.getActiveText3DCount()` to monitor active renders
- Clear unused text with `lib.draw.removeText3d()` or `lib.draw.clearAllText3D()`

### Memory Management
```lua
-- Good: Clean up when done
local textId = lib.draw.text3dPermanent({...})
-- Later...
lib.draw.removeText3d(textId)

-- Good: Use timed text for temporary displays
lib.draw.text3dTimed({...}, 5000) -- Auto-cleanup after 5 seconds

-- Bad: Creating permanent text without cleanup
-- This will accumulate and impact performance
for i = 1, 100 do
    lib.draw.text3dPermanent({...}) -- Memory leak!
end
```

### Coordinate Handling
```lua
-- Flexible coordinate input - all these work:
lib.draw.text3d({
    coords = vector3(100, 200, 30),           -- vector3
    coords = {100, 200, 30},                  -- Array format
    coords = {x = 100, y = 200, z = 30},      -- Table format
    text = "Flexible coords"
})
```

### Color Management
```lua
-- Define color constants for consistency
local COLORS = {
    WHITE = {255, 255, 255, 255},
    RED = {255, 0, 0, 255},
    GREEN = {0, 255, 0, 255},
    BLUE = {0, 0, 255, 255},
    YELLOW = {255, 255, 0, 255},
    TRANSPARENT_BLACK = {0, 0, 0, 150}
}

lib.draw.text3d({
    coords = vector3(100, 200, 30),
    text = "Consistent Colors",
    color = COLORS.GREEN
})
```

## Common Issues & Solutions

### Text Not Appearing
```lua
-- Issue: Text coordinates might be underground or too far
-- Solution: Check coordinates and distance
lib.draw.text3d({
    coords = vector3(100, 200, 35), -- Ensure Z is above ground
    text = "Visible Text",
    distance = 100 -- Increase if too far
})
```

### Performance Issues
```lua
-- Issue: Too many permanent texts
-- Solution: Monitor and clean up
CreateThread(function()
    while true do
        local count = lib.draw.getActiveText3DCount()
        if count > 50 then
            lib.print.warn(('High 3D text count: %d'):format(count))
        end
        Wait(5000)
    end
end)
```

### Text Scaling Issues
```lua
-- Issue: Text too small or large at different distances
-- Solution: Use dynamic scaling
local function drawScaledText(coords, text)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - coords)
    local scale = math.max(0.5, math.min(2.0, 10.0 / distance))
    
    lib.draw.text3d({
        coords = coords,
        text = text,
        scale = scale
    })
end
```

### Sprite Not Loading
```lua
-- Issue: Texture dictionary not loaded
-- Solution: The module handles this automatically, but you can preload:
lib.requestStreamedTextureDict('commonmenu')

lib.draw.sprite({
    textureDict = 'commonmenu',
    textureName = 'gradient_bgd',
    x = 0.5,
    y = 0.5,
    width = 0.2,
    height = 0.1
})
```

## Advanced Examples

### Interactive Zone with Multiple Elements
```lua
local function createInteractiveZone()
    local zoneCoords = vector3(100.0, 200.0, 30.0)
    local zoneRadius = 5.0
    
    -- Zone boundary
    lib.draw.sphere(zoneCoords, zoneRadius, {0, 255, 255, 100}, 20)
    
    -- Zone marker
    lib.draw.marker({
        coords = zoneCoords,
        type = 1,
        size = vector3(zoneRadius * 2, zoneRadius * 2, 1.0),
        color = {0, 255, 255, 50},
        bobUpAndDown = false
    })
    
    -- Interactive text
    local textId = lib.draw.text3dPermanent({
        coords = zoneCoords + vector3(0, 0, 3.0),
        text = "Safe Zone",
        color = {0, 255, 255, 255},
        scale = 1.5,
        background = {
            enabled = true,
            color = {0, 0, 0, 150}
        },
        visible = function()
            local playerCoords = GetEntityCoords(PlayerPedId())
            return #(playerCoords - zoneCoords) < zoneRadius * 2
        end
    })
    
    return textId
end
```

### Dynamic Progress Bar
```lua
local function createProgressBar(coords, progress, label)
    local barWidth = 0.2
    local barHeight = 0.02
    local screenX, screenY = 0.5, 0.8
    
    -- Background
    lib.draw.rect(screenX - barWidth/2, screenY, barWidth, barHeight, {0, 0, 0, 200})
    
    -- Progress fill
    local fillWidth = barWidth * (progress / 100)
    local color = progress > 66 and {0, 255, 0, 255} or 
                  progress > 33 and {255, 255, 0, 255} or 
                  {255, 0, 0, 255}
    
    lib.draw.rect(screenX - barWidth/2, screenY, fillWidth, barHeight, color)
    
    -- Progress text
    lib.draw.text2d({
        text = ('%s: %d%%'):format(label, progress),
        x = screenX,
        y = screenY - 0.03,
        center = true,
        color = {255, 255, 255, 255}
    })
end

-- Usage
CreateThread(function()
    local progress = 0
    while progress <= 100 do
        createProgressBar(vector3(0, 0, 0), progress, "Loading")
        progress = progress + 1
        Wait(50)
    end
end)
```

### Waypoint System
```lua
local Waypoints = {}

function Waypoints.create(coords, label, color)
    local waypoint = {
        coords = coords,
        label = label,
        color = color or {255, 255, 0, 255},
        textId = nil,
        active = true
    }
    
    waypoint.textId = lib.draw.text3dPermanent({
        coords = coords + vector3(0, 0, 2.0),
        text = label,
        color = waypoint.color,
        scale = 1.2,
        distance = 100.0,
        background = {
            enabled = true,
            color = {0, 0, 0, 150}
        }
    })
    
    -- Draw waypoint marker
    CreateThread(function()
        while waypoint.active do
            lib.draw.marker({
                coords = waypoint.coords,
                type = 1,
                size = vector3(2.0, 2.0, 1.0),
                color = waypoint.color,
                bobUpAndDown = true
            })
            
            -- Draw line to waypoint if close
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - waypoint.coords)
            
            if distance < 50.0 then
                lib.draw.line({
                    startCoords = playerCoords + vector3(0, 0, 1.0),
                    endCoords = waypoint.coords + vector3(0, 0, 1.0),
                    color = waypoint.color
                })
            end
            
            Wait(0)
        end
    end)
    
    return waypoint
end

function Waypoints.remove(waypoint)
    waypoint.active = false
    if waypoint.textId then
        lib.draw.removeText3d(waypoint.textId)
    end
end

-- Usage
local waypoint1 = Waypoints.create(vector3(100, 200, 30), "Objective A", {255, 0, 0, 255})
local waypoint2 = Waypoints.create(vector3(200, 300, 35), "Objective B", {0, 255, 0, 255})
```

## Font Reference

| Font ID | Description |
|---------|-------------|
| 0       | ChaletLondon |
| 1       | HouseScript |
| 2       | Monospace |
| 4       | ChaletComprimeCologne |
| 6       | $subtitles |
| 7       | $bodyCopy |

## Marker Types Reference

| Type | Description |
|------|-------------|
| 0    | Upside-down cone |
| 1    | Vertical cylinder |
| 2    | Thick chevron up |
| 3    | Thin chevron up |
| 4    | Checkered flag |
| 5    | Checkered cylinder |
| 6    | Curved arrow |
| 20   | Sphere |
| 28   | Floating ring |

## Troubleshooting

### Common Error Messages

**"text3d requires coords and text parameters"**
- Ensure you're passing both `coords` and `text` in the options table

**"coords must be vector3"**
- Use `vector3(x, y, z)` format or coordinate arrays `{x, y, z}`

**"Target system not initialized"**
- This error is from a different module, ignore if using only draw functions

**"Invalid text ID"**
- The text ID you're trying to update/remove doesn't exist or was already removed

### Performance Monitoring

```lua
-- Add this to monitor draw performance
CreateThread(function()
    while true do
        local activeCount = lib.draw.getActiveText3DCount()
        if activeCount > 0 then
            lib.print.debug(('Active 3D texts: %d'):format(activeCount))
        end
        Wait(10000) -- Check every 10 seconds
    end
end)
```

## License

This module is part of ox_lib and is licensed under LGPL-3.0 or higher.

## Support

For issues and support:
- Check the troubleshooting section above
- Ensure ox_lib is up to date
- Verify coordinate formats are correct
- Monitor active text count for performance issues
- Report issues to the ItzDabbzz/ox_lib repository

## Changelog

### Version 1.0.0
- Initial release with comprehensive drawing utilities
- 3D text rendering with permanent, timed, and single-frame options
- 2D text rendering with full customization
- Shape drawing: lines, rectangles, polygons, boxes, spheres
- Marker and sprite support
- Background support for 3D text
- Distance-based culling and optimization
- Active text management system
- Flexible coordinate input handling
- Comprehensive error handling and validation
