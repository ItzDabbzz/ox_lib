# ox_lib Dispatch Module

Simple dispatch system that automatically detects and works with popular FiveM dispatch resources.

## Supported Resources

- linden_outlawalert
- cd_dispatch
- ps-dispatch
- qs-dispatch
- core_dispatch
- origen_police
- codem-dispatch

## Quick Start

```lua
-- Simple alert
lib.dispatch.alert("Suspicious activity reported")

-- With custom code
lib.dispatch.alert("Vehicle theft in progress", "10-35")

-- Urgent alert
lib.dispatch.urgent("Officer needs assistance!")

-- Vehicle alert
lib.dispatch.vehicle("Stolen vehicle", "ABC123")

-- Weapon alert
lib.dispatch.weapon("Shots fired", "Pistol")
```

## API Reference

### `lib.dispatch.send(data)`
Send a custom dispatch alert.

```lua
lib.dispatch.send({
    message = "Bank robbery in progress",
    code = "10-90",
    title = "BANK ROBBERY",
    priority = "high",
    jobs = { "police", "sheriff" },
    coords = vector3(100, 200, 30), -- Optional, defaults to player position
    blip = {
        sprite = 161,
        color = 1,
        scale = 1.0
    }
})
```

### `lib.dispatch.alert(message, code?, jobs?)`
Quick alert with minimal setup.

```lua
lib.dispatch.alert("Disturbance at the pier")
lib.dispatch.alert("Traffic stop", "10-38")
lib.dispatch.alert("Medical emergency", "10-52", { "ems", "police" })
```

### `lib.dispatch.urgent(message, code?, jobs?)`
High priority alert with flashing and sound.

```lua
lib.dispatch.urgent("Officer down!")
lib.dispatch.urgent("Armed robbery", "Code 3")
```

### `lib.dispatch.vehicle(message, plate?, code?)`
Vehicle-related alert.

```lua
lib.dispatch.vehicle("Reckless driving")
lib.dispatch.vehicle("Hit and run", "XYZ789")
lib.dispatch.vehicle("Stolen vehicle", "ABC123", "10-37")
```

### `lib.dispatch.weapon(message, weapon?, code?)`
Weapon-related alert (automatically high priority).

```lua
lib.dispatch.weapon("Shots fired downtown")
lib.dispatch.weapon("Armed suspect", "Assault Rifle")
lib.dispatch.weapon("Drive-by shooting", "SMG", "10-71")
```

## Data Structure

```lua
{
    message = "Alert description",     -- Required
    code = "10-35",                   -- Required  
    title = "Alert Title",            -- Required
    priority = "normal",              -- "low", "normal", "high"
    jobs = { "police" },              -- Jobs to notify
    coords = vector3(x, y, z),        -- Coordinates (defaults to player)
    sound = true,                     -- Enable sound
    blip = {                          -- Blip configuration
        sprite = 161,
        color = 1,
        scale = 1.0
    }
}
```

## Examples

### Basic Usage
```lua
-- Simple notification
lib.dispatch.alert("Noise complaint at apartment complex")

-- With specific job
lib.dispatch.alert("Medical emergency", "10-52", { "ems" })
```

### Custom Alerts
```lua
-- Bank robbery
lib.dispatch.send({
    message = "Silent alarm triggered at Fleeca Bank",
    code = "10-90",
    title = "BANK ALARM",
    priority = "high",
    jobs = { "police", "sheriff" },
    blip = { sprite = 161, color = 1 }
})

-- Drug deal
lib.dispatch.send({
    message = "Suspicious activity reported in alley",
    code = "10-35",
    title = "Drug Activity",
    priority = "normal",
    coords = vector3(123.45, 678.90, 21.34)
})
```

### Event-Based Dispatching
```lua
-- On vehicle theft
RegisterNetEvent('vehicle:stolen', function(plate, model)
    lib.dispatch.vehicle(('Stolen %s reported'):format(model), plate, "10-37")
end)

-- On gunshot detection
RegisterNetEvent('weapon:fired', function(weapon)
    lib.dispatch.weapon("Gunshots detected in area", weapon)
end)

-- On store robbery
RegisterNetEvent('store:robbery', function(storeName)
    lib.dispatch.urgent(('Armed robbery at %s'):format(storeName), "10-90")
end)
```

### Location-Specific Alerts
```lua
-- Alert at specific coordinates
lib.dispatch.send({
    message = "Break-in reported",
    code = "10-35",
    title = "Burglary",
    coords = vector3(100.0, 200.0, 30.0)
})

-- Multiple locations
local locations = {
    { coords = vector3(100, 200, 30), name = "Bank" },
    { coords = vector3(300, 400, 25), name = "Store" }
}

for _, location in ipairs(locations) do
    lib.dispatch.send({
        message = ('Security check needed at %s'):format(location.name),
        code = "10-35",
        title = "Security Check",
        coords = location.coords
    })
end
```

## Notes

- The system automatically detects which dispatch resource you're using
- No configuration needed - just install and use
- Coordinates default to player position if not specified
- Jobs default to `{ "police" }` if not specified
- High priority alerts automatically enable flashing and sound effects
- The module handles all the complex resource-specific formatting internally

## Troubleshooting

**Dispatch not working?**
- Make sure you have one of the supported dispatch resources installed and started
- Check server console for any error messages

**Alerts not showing for certain jobs?**
- Verify the job names match your framework (e.g., "police" vs "leo")
- Some resources use different job formats

**Custom coordinates not working?**
- Ensure coordinates are in vector3 format: `vector3(x, y, z)`
- Check that coordinates are valid world positions
