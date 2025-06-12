# lib.ped

Easy ped creation and management system for FiveM. Handles model loading, cleanup, and integrates with ox_target and ox_lib points.

## Quick Start

```lua
-- Create a simple ped
local pedId = lib.ped.create({
    model = 'a_m_y_business_01',
    coords = vector4(100, 200, 30, 90),
    freeze = true
})

-- Remove the ped later
lib.ped.remove(pedId)
```

## Basic Usage

### Simple Ped Creation
```lua
local shopKeeper = lib.ped.create({
    model = 'a_m_y_business_01',
    coords = vector4(25.7, -1347.3, 29.49, 90.0),
    freeze = true,
    scenario = 'WORLD_HUMAN_CLIPBOARD'
})
```

### Ped with Target Interaction
```lua
local mechanic = lib.ped.create({
    model = 's_m_y_construct_01',
    coords = vector4(-347.3, -133.6, 39.0, 340.0),
    freeze = true,
    scenario = 'WORLD_HUMAN_WELDING',
    targetOptions = {
        {
            label = 'Repair Vehicle',
            icon = 'fas fa-wrench',
            action = function()
                -- Repair logic here
                lib.notify({
                    title = 'Vehicle Repaired',
                    description = 'Your vehicle has been repaired!',
                    type = 'success'
                })
            end
        }
    },
    interactionType = 'target'
})
```

### Point-Based Ped (Spawns when player gets close)
```lua
local bankTeller = lib.ped.createAtPoint({
    model = 'ig_bankman',
    coords = vector4(150.266, -1040.203, 29.374, 340.0),
    distance = 30.0, -- Spawn when within 30 units
    freeze = true,
    scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
    targetOptions = {
        {
            label = 'Access Bank',
            icon = 'fas fa-university',
            action = function()
                -- Banking menu
            end
        }
    },
    interactionType = 'target'
})
```

## Functions

### Core Functions
- `lib.ped.create(data)` - Create a new ped
- `lib.ped.remove(pedId)` - Remove a ped
- `lib.ped.createAtPoint(data)` - Create ped that spawns near players

### Information Functions
- `lib.ped.get(pedId)` - Get ped information
- `lib.ped.getAll()` - Get all active peds
- `lib.ped.exists(pedId)` - Check if ped exists
- `lib.ped.getStats()` - Get statistics

### Utility Functions
- `lib.ped.setScenario(pedId, scenario)` - Change ped scenario
- `lib.ped.removeAll()` - Remove all peds

## Ped Data Structure

```lua
{
    model = 'a_m_y_business_01',           -- Ped model (string or hash)
    coords = vector4(x, y, z, heading),    -- Position and heading
    freeze = true,                         -- Freeze ped in place
    scenario = 'WORLD_HUMAN_CLIPBOARD',    -- Animation scenario
    
    -- Target interaction (requires ox_target)
    targetOptions = {
        {
            label = 'Talk',
            icon = 'fas fa-comments',
            action = function()
                -- Your code here
            end
        }
    },
    interactionType = 'target',
    
    -- Point-based spawning only
    distance = 50.0,                       -- Spawn distance
    debug = false,                         -- Show debug info
    onEnter = function(pedId) end,         -- Called when player enters
    onExit = function() end                -- Called when player exits
}
```

## Coordinate Formats

Supports multiple coordinate formats:
```lua
-- Vector4 (recommended)
coords = vector4(100, 200, 30, 90)

-- Vector3 (heading defaults to 0)
coords = vector3(100, 200, 30)

-- Table with named keys
coords = {x = 100, y = 200, z = 30, w = 90}

-- Array format
coords = {100, 200, 30, 90}
```

## Common Scenarios

```lua
-- Standing animations
'WORLD_HUMAN_STAND_IMPATIENT'
'WORLD_HUMAN_CLIPBOARD'
'WORLD_HUMAN_GUARD_STAND'

-- Working animations
'WORLD_HUMAN_WELDING'
'WORLD_HUMAN_HAMMERING'
'WORLD_HUMAN_AA_COFFEE'

-- Sitting animations
'WORLD_HUMAN_PICNIC'
'WORLD_HUMAN_DRINKING'
'WORLD_HUMAN_SMOKING'
```

## Real Examples

### Shop Keeper
```lua
local function createShopKeeper()
    return lib.ped.create({
        model = 'mp_m_shopkeep_01',
        coords = vector4(25.7, -1347.3, 29.49, 270.0),
        freeze = true,
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        targetOptions = {
            {
                label = 'Browse Shop',
                icon = 'fas fa-shopping-cart',
                action = function()
                    -- Open shop menu
                    TriggerEvent('shop:open', 'general')
                end
            }
        },
        interactionType = 'target'
    })
end
```

### Bank Teller (Point-Based)
```lua
local function createBankTeller()
    return lib.ped.createAtPoint({
        model = 'ig_bankman',
        coords = vector4(150.266, -1040.203, 29.374, 340.0),
        distance = 25.0,
        freeze = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        targetOptions = {
            {
                label = 'Access ATM',
                icon = 'fas fa-credit-card',
                action = function()
                    TriggerEvent('bank:openATM')
                end
            },
            {
                label = 'Speak to Teller',
                icon = 'fas fa-user-tie',
                action = function()
                    TriggerEvent('bank:openTeller')
                end
            }
        },
        interactionType = 'target',
        onEnter = function(pedId)
            lib.notify({
                title = 'Bank',
                description = 'Welcome to the bank!',
                type = 'inform'
            })
        end
    })
end
```

### Mechanic with Multiple Services
```lua
local function createMechanic()
    return lib.ped.create({
        model = 's_m_y_construct_01',
        coords = vector4(-347.3, -133.6, 39.0, 340.0),
        freeze = true,
        scenario = 'WORLD_HUMAN_WELDING',
        targetOptions = {
            {
                label = 'Repair Vehicle',
                icon = 'fas fa-wrench',
                action = function()
                    local vehicle = GetVehiclePedIsIn(cache.ped, false)
                    if vehicle == 0 then
                        lib.notify({
                            title = 'Error',
                            description = 'You need to be in a vehicle!',
                            type = 'error'
                        })
                        return
                    end
                    
                    -- Repair logic
                    SetVehicleFixed(vehicle)
                    SetVehicleEngineHealth(vehicle, 1000.0)
                    
                    lib.notify({
                        title = 'Mechanic',
                        description = 'Vehicle repaired for $500',
                        type = 'success'
                    })
                end
            },
            {
                label = 'Upgrade Vehicle',
                icon = 'fas fa-cog',
                action = function()
                    -- Open upgrade menu
                    TriggerEvent('mechanic:openUpgrades')
                end
            }
        },
        interactionType = 'target'
    })
end
```

### Managing Multiple Peds
```lua
local peds = {}

-- Create multiple peds
peds.shopkeeper = lib.ped.create({...})
peds.mechanic = lib.ped.create({...})
peds.banker = lib.ped.createAtPoint({...})

-- Get information about all peds
local allPeds = lib.ped.getAll()
print('Active peds:', #allPeds)

-- Get statistics
local stats = lib.ped.getStats()
print(('Peds: %d total, %d valid, %d with targets'):format(
    stats.total, stats.valid, stats.withTargets
))

-- Clean up specific ped
lib.ped.remove(peds.shopkeeper)

-- Clean up all peds
lib.ped.removeAll()
```

## Tips

- **Models**: Use `lib.requestModel()` internally, so any valid ped model works
- **Cleanup**: Peds are automatically cleaned up when resource stops
- **Performance**: Point-based peds only exist when players are nearby
- **Target Integration**: Automatically integrates with ox_target when available
- **Error Handling**: All functions validate inputs and handle errors gracefully

## Quick Reference

| Function | Purpose | Returns |
|----------|---------|---------|
| `create(data)` | Create new ped | `pedId` or `nil` |
| `remove(pedId)` | Remove ped | `boolean` |
| `createAtPoint(data)` | Create point-based ped | `point` or `nil` |
| `get(pedId)` | Get ped info | `table` or `nil` |
| `getAll()` | Get all peds | `table` |
| `exists(pedId)` | Check if exists | `boolean` |
| `setScenario(pedId, scenario)` | Change animation | `boolean` |
| `removeAll()` | Remove all peds | `number` (count) |
| `getStats()` | Get statistics | `table` |

Perfect for shops, NPCs, quest givers, and any interactive characters in your server!
