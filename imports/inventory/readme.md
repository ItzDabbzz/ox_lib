# Inventory System Integration

A comprehensive inventory system wrapper that provides unified access to multiple popular FiveM inventory resources through a single, consistent API.

## Supported Inventory Systems

- **ox_inventory** - Modern, feature-rich inventory system
- **qb-inventory** - QBCore's default inventory system
- **qs-inventory** - Quasar Store's inventory solution
- **codem-inventory** - CodeM's inventory system
- **origen_inventory** - Origen's inventory implementation
- **tgiann-inventory** - TGiann's inventory system

## Features

- **Automatic Detection** - Automatically detects and initializes the active inventory system
- **Unified API** - Single interface for all inventory operations across different systems
- **Framework Integration** - Works seamlessly with ESX, QBCore, and QBX frameworks
- **Client & Server Support** - Full functionality on both client and server sides
- **Error Handling** - Comprehensive validation and error reporting
- **Backwards Compatibility** - Maintains compatibility with existing code

## Quick Start

### Server-Side Usage

```lua
-- Check if player has an item
local count = lib.inventory.hasItem(source, 'bread')
print('Player has', count, 'bread')

-- Add item to player
local success = lib.inventory.addItem(source, 'water', 5)
if success then
    print('Added 5 water to player')
end

-- Remove item from player
local removed = lib.inventory.removeItem(source, 'bread', 2)
if removed then
    print('Removed 2 bread from player')
end

-- Check if player can carry item
local canCarry = lib.inventory.canCarry(source, 'phone', 1)
if canCarry then
    lib.inventory.addItem(source, 'phone', 1)
end

-- Get player's full inventory
local inventory, systemName = lib.inventory.getPlayerInventory(source)
print('Using inventory system:', systemName)
```

### Client-Side Usage

```lua
-- Check items in player's inventory
local breadCount = lib.inventory.hasItem('bread')
print('I have', breadCount, 'bread')

-- Check multiple items
local items = lib.inventory.hasItem({'bread', 'water', 'phone'})
print('Bread:', items.bread, 'Water:', items.water, 'Phone:', items.phone)

-- Get inventory weight
local currentWeight, maxWeight = lib.inventory.getWeight()
print('Weight:', currentWeight, '/', maxWeight)

-- Open/close inventory
lib.inventory.open()
lib.inventory.close()

-- Open a stash
lib.inventory.openStash('my_stash', {
    slots = 50,
    weight = 100000
})

-- Check if inventory is open
if lib.inventory.isOpen() then
    print('Inventory is currently open')
end
```

## Advanced Features

### Creating Stashes

```lua
-- Server-side stash creation
lib.inventory.createStash('police_evidence', 'Evidence Locker', 100, 500000, nil, {'police'})

-- Client-side stash opening
lib.inventory.openStash('police_evidence')
```

### Creating Shops

```lua
-- Server-side shop creation
local shopItems = {
    {name = 'bread', price = 5, amount = 50},
    {name = 'water', price = 3, amount = 100}
}

lib.inventory.createShop('general_store', 'General Store', shopItems)
```

### Registering Usable Items

```lua
-- Server-side usable item registration
lib.inventory.registerUsableItem('phone', function(source, item, inventory, slot, data)
    print('Player', source, 'used their phone')
    -- Your phone logic here
end)
```

### Inventory Statistics

```lua
-- Get detailed inventory stats
local stats = lib.inventory.getStats(source) -- Server
local stats = lib.inventory.getStats() -- Client

print('Current Weight:', stats.currentWeight)
print('Max Weight:', stats.maxWeight)
print('Weight Percentage:', stats.weightPercentage .. '%')
print('Free Slots:', stats.freeSlots)
print('Total Items:', stats.totalItems)
print('System:', stats.system)
```

## System Information

### Get Current System

```lua
-- Get information about the active inventory system
local system = lib.inventory.getCurrentSystem()
if system then
    print('Active System:', system.name)
    print('Resource Name:', system.resource)
end

-- Check if a specific system is available
local isOxAvailable = lib.inventory.isSystemAvailable('ox')
print('OX Inventory Available:', isOxAvailable)

-- Get all available systems
local available = lib.inventory.getAvailableResources()
for name, resource in pairs(available) do
    print(name, '->', resource)
end
```

## Error Handling

The system includes comprehensive error handling and validation:

```lua
-- All functions return appropriate values on failure
local success = lib.inventory.addItem(source, 'invalid_item', -5) -- Returns false
local count = lib.inventory.hasItem(source, nil) -- Returns 0
local inventory = lib.inventory.getPlayerInventory('invalid_source') -- Returns nil
```

## Callbacks

The system registers several callbacks for cross-script communication:

- `ox_lib:inventory:hasItem`
- `ox_lib:inventory:hasItems`
- `ox_lib:inventory:getPlayerInventory`
- `ox_lib:inventory:canCarry`
- `ox_lib:inventory:getStats`

## Backwards Compatibility

Legacy function exports are maintained:

```lua
-- These still work for backwards compatibility
local count = HasItem(source, 'bread')
local success = AddItem(source, 'water', 5)
local removed = RemoveItem(source, 'bread', 2)
```

## Installation

1. Ensure you have one of the supported inventory systems installed and running
2. Add the inventory files to your ox_lib imports
3. The system will automatically detect and initialize the active inventory system
4. Start using the unified API in your scripts

## Notes

- The system automatically detects the active inventory system on startup
- If no supported inventory system is found, an error will be thrown
- Some features may not be available in all inventory systems
- The system gracefully handles missing functionality with appropriate warnings
