# lib.target

A simple wrapper for FiveM target systems (qb-target, qtarget, ox_target). Automatically detects which target resource you have and provides a unified API.

## Quick Start

```lua
-- The system initializes automatically when loaded
-- Check if it's working:
if lib.target.isAvailable() then
    print('Target system ready!')
end
```

## Basic Usage

### Box Zone
```lua
lib.target.addBoxZone('my_shop', vector3(100, 200, 30), 2.0, 2.0, {
    options = {
        {
            label = 'Open Shop',
            icon = 'fas fa-shopping-cart',
            action = function()
                print('Shop opened!')
            end
        }
    },
    distance = 3.0
})
```

### Circle Zone
```lua
lib.target.addCircleZone('atm', vector3(150, 250, 30), 1.5, {
    options = {
        {
            label = 'Use ATM',
            icon = 'fas fa-credit-card',
            action = function()
                -- ATM logic here
            end
        }
    }
})
```

### Target All Vehicles
```lua
lib.target.addGlobalVehicle({
    options = {
        {
            label = 'Enter Vehicle',
            icon = 'fas fa-car',
            action = function(data)
                local vehicle = data.entity
                -- Enter vehicle logic
            end
        }
    }
})
```

### Target Specific Models
```lua
lib.target.addTargetModel('prop_atm_01', {
    options = {
        {
            label = 'Use ATM',
            action = function()
                -- ATM logic
            end
        }
    }
})
```

## All Functions

### Zones
- `lib.target.addBoxZone(id, coords, width, length, data, debug?)`
- `lib.target.addCircleZone(id, coords, radius, data, debug?)`
- `lib.target.addPolyZone(id, points, data, debug?)`
- `lib.target.removeZone(id)`

### Entities
- `lib.target.addTargetEntity(entityId, data)`
- `lib.target.addTargetModel(models, data)`
- `lib.target.addTargetBone(bones, data)`
- `lib.target.removeTargetEntity(entityId)`

### Global Targets
- `lib.target.addGlobalPed(data)`
- `lib.target.addGlobalVehicle(data)`
- `lib.target.addGlobalObject(data)`
- `lib.target.addGlobalPlayer(data)`
- `lib.target.removeGlobalPed(label?)`
- `lib.target.removeGlobalVehicle(label?)`
- `lib.target.removeGlobalObject(label?)`
- `lib.target.removeGlobalPlayer(label?)`

### Utility
- `lib.target.isAvailable()` - Check if system is ready
- `lib.target.getActiveResource()` - Get which target resource is being used
- `lib.target.refresh()` - Reinitialize the system

## Option Properties

```lua
{
    label = 'Action Name',
    icon = 'fas fa-icon',
    action = function(data)
        -- data.entity = the targeted entity
        -- data.coords = target coordinates
    end,
    
    -- Optional restrictions
    job = 'police',
    item = 'keycard',
    canInteract = function(entity, distance, coords)
        return true -- or false
    end
}
```

## Coordinates

Accepts multiple formats:
```lua
vector3(100, 200, 30)           -- Recommended
{x = 100, y = 200, z = 30}      -- Table format
{100, 200, 30}                  -- Array format
```

## Debug Mode

Add `true` as the last parameter to see zone outlines:
```lua
lib.target.addBoxZone('test', coords, 2, 2, data, true) -- Shows debug outline
```

That's it! The system handles all the complexity for you.
