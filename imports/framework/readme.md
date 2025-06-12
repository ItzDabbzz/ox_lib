# ox_lib Framework System

A unified framework abstraction layer for FiveM that provides consistent access to player data and functionality across ESX, QBCore, and QBX frameworks. This system automatically detects the active framework and provides a standardized API for interacting with player data.

## Features

- 🔄 **Multi-Framework Support**: ESX, QBCore, and QBX compatibility
- 🚀 **Automatic Detection**: Framework detection with intelligent fallbacks
- ⚡ **Performance Optimized**: Built-in caching for player objects
- 🔧 **Client & Server**: Unified API for both client and server environments
- 🛡️ **Error Handling**: Comprehensive validation and graceful error handling
- 📊 **Statistics**: Built-in monitoring and statistics
- 🔄 **Hot Refresh**: Dynamic framework detection refresh capability

## Installation

The framework system is automatically available as part of ox_lib. No additional installation required.

## Dependencies

- **Required**: `ox_lib`
- **Framework**: One of the following:
  - `es_extended` (ESX)
  - `qb-core` (QBCore) 
  - `qbx_core` (QBX)

## Framework Detection Priority

The system detects frameworks in this order:
1. **QBX Core** (`qbx_core`) - Highest priority
2. **QBCore** (`qb-core`) - Medium priority  
3. **ESX** (`es_extended`) - Lowest priority

> **Note**: QBX is checked first as it may have QBCore as a dependency.

---

## Server-Side API

### Core Functions

#### `lib.framework.getFramework()`
Gets the detected framework name.

```lua
local framework = lib.framework.getFramework()
print('Active framework:', framework) -- "esx", "qb", "qbx", or nil
```

**Returns:**
- `string?`: Framework name or `nil` if none detected

---

#### `lib.framework.getFrameworkObject()`
Gets the raw framework object for advanced usage.

```lua
local frameworkObj = lib.framework.getFrameworkObject()
if frameworkObj then
    -- Direct framework access if needed
end
```

**Returns:**
- `table?`: Framework object or `nil`

---

#### `lib.framework.getPlayer(source)`
Gets a player object from any framework with automatic caching.

```lua
local player = lib.framework.getPlayer(source)
if player then
    -- Framework-agnostic player object
    print('Player loaded successfully')
end
```

**Parameters:**
- `source` (number): Player's server ID

**Returns:**
- `table?`: Player object or `nil` if not found

**Caching:**
- Player objects are cached for 5 seconds
- Automatic cache cleanup on player disconnect

---

#### `lib.framework.getAllPlayers()`
Gets all online players from the active framework.

```lua
local players = lib.framework.getAllPlayers()
for _, player in ipairs(players) do
    local source = player.source or player.PlayerData?.source
    print('Player online:', source)
end
```

**Returns:**
- `table`: Array of player objects (empty table if no framework)

---

#### `lib.framework.getPlayerIdentifier(source, identifierType?)`
Gets a player identifier (license, steam, discord, etc.).

```lua
local license = lib.framework.getPlayerIdentifier(source, 'license')
local steam = lib.framework.getPlayerIdentifier(source, 'steam')
local discord = lib.framework.getPlayerIdentifier(source, 'discord')
```

**Parameters:**
- `source` (number): Player's server ID
- `identifierType` (string, optional): Type of identifier (default: 'license')

**Returns:**
- `string?`: Player identifier or `nil` if not found

**Supported Identifiers:**
- `license` (default)
- `steam`
- `discord`
- Any other identifier type supported by the framework

---

### System Management

#### `lib.framework.isAvailable()`
Checks if any framework is available.

```lua
if lib.framework.isAvailable() then
    -- Framework is loaded and ready
    local players = lib.framework.getAllPlayers()
else
    print('No framework available')
end
```

**Returns:**
- `boolean`: Whether a framework is available

---

#### `lib.framework.refresh()`
Refreshes framework detection (useful for dynamic loading).

```lua
local success = lib.framework.refresh()
if success then
    print('Framework refreshed:', lib.framework.getFramework())
else
    print('No framework found after refresh')
end
```

**Returns:**
- `boolean`: Whether refresh was successful

---

#### `lib.framework.getStats()`
Gets comprehensive statistics about the framework system.

```lua
local stats = lib.framework.getStats()
print(json.encode(stats, {indent = true}))
```

**Returns:**
```lua
{
    framework = "qb",           -- Active framework
    available = true,           -- Framework availability
    cachedPlayers = 5,          -- Number of cached players
    onlinePlayers = 25          -- Total online players
}
```

---

## Client-Side API

### Core Functions

#### `lib.framework.getFramework()`
Gets the detected framework name (client-side).

```lua
local framework = lib.framework.getFramework()
```

#### `lib.framework.getFrameworkObject()`
Gets the framework object (client-side).

```lua
local frameworkObj = lib.framework.getFrameworkObject()
```

#### `lib.framework.getPlayerData()`
Gets the current player's data from the framework.

```lua
local playerData = lib.framework.getPlayerData()
if playerData then
    print('Player data loaded')
    -- Access player information
end
```

**Returns:**
- `table?`: Player data object or `nil` if not loaded

**Framework Mapping:**
- **ESX**: `ESX.GetPlayerData()`
- **QBCore/QBX**: `QBCore.Functions.GetPlayerData()`

---

#### `lib.framework.isPlayerLoaded()`
Checks if the player is fully loaded.

```lua
if lib.framework.isPlayerLoaded() then
    -- Player is ready
    local playerData = lib.framework.getPlayerData()
else
    print('Player not loaded yet')
end
```

**Returns:**
- `boolean`: Whether player is loaded

---

#### `lib.framework.waitForPlayerLoaded(timeout?)`
Waits for the player to be loaded with optional timeout.

```lua
-- Wait with default timeout (30 seconds)
local success = lib.framework.waitForPlayerLoaded()
if success then
    print('Player loaded successfully')
else
    print('Player failed to load within timeout')
end

-- Wait with custom timeout (10 seconds)
local success = lib.framework.waitForPlayerLoaded(10000)
```

**Parameters:**
- `timeout` (number, optional): Timeout in milliseconds (default: 30000)

**Returns:**
- `boolean`: Whether player loaded within timeout

---

### System Management (Client)

#### `lib.framework.isAvailable()`
Checks if framework is available (client-side).

```lua
if lib.framework.isAvailable() then
    -- Framework ready on client
end
```

#### `lib.framework.refresh()`
Refreshes framework detection (client-side).

```lua
local success = lib.framework.refresh()
```

---

## Framework-Specific Behavior

### ESX Integration
```lua
-- Server-side ESX player object structure
local player = lib.framework.getPlayer(source)
if player then
    local identifier = player.identifier
    local money = player.getMoney()
    local job = player.job
end

-- Client-side ESX player data
local playerData = lib.framework.getPlayerData()
if playerData then
    local job = playerData.job
    local money = playerData.money
end
```

### QBCore Integration
```lua
-- Server-side QBCore player object
local player = lib.framework.getPlayer(source)
if player then
    local citizenid = player.PlayerData.citizenid
    local money = player.PlayerData.money
    local job = player.PlayerData.job
end

-- Client-side QBCore player data
local playerData = lib.framework.getPlayerData()
if playerData then
    local citizenid = playerData.citizenid
    local job = playerData.job
end
```

### QBX Integration
```lua
-- Server-side QBX player object
local player = lib.framework.getPlayer(source)
if player then
    local citizenid = player.PlayerData.citizenid
    local money = player.PlayerData.money
end

-- Client-side QBX player data
local playerData = lib.framework.getPlayerData()
if playerData then
    local citizenid = playerData.citizenid
end
```

---

## Usage Examples

### Basic Framework Detection
```lua
-- Check what framework is running
local framework = lib.framework.getFramework()
if framework then
    print(('Running on %s framework'):format(framework))
else
    print('No framework detected')
end
```

### Player Management
```lua
-- Get player safely
local function getPlayerSafely(source)
    if not lib.framework.isAvailable() then
        return nil, 'No framework available'
    end
    
    local player = lib.framework.getPlayer(source)
    if not player then
        return nil, 'Player not found'
    end
    
    return player, nil
end

-- Usage
local player, error = getPlayerSafely(source)
if player then
    -- Work with player object
else
    print('Error:', error)
end
```

### Batch Player Processing
```lua
-- Process all online players
local function processAllPlayers()
    local players = lib.framework.getAllPlayers()
    local processed = 0
    
    for _, player in ipairs(players) do
        -- Get source ID based on framework
        local source = player.source or player.PlayerData?.source or player.playerId
        
        if source then
            -- Process player
            processed = processed + 1
        end
    end
    
    print(('Processed %d players'):format(processed))
end
```

### Client-Side Player Loading
```lua
-- Wait for player to load before proceeding
CreateThread(function()
    if lib.framework.waitForPlayerLoaded() then
        local playerData = lib.framework.getPlayerData()
        
        -- Player is loaded, safe to access data
        print('Player loaded successfully')
        
        -- Framework-agnostic data access
        if playerData then
            print('Player data available')
        end
    else
        print('Player failed to load')
    end
end)
```

### Advanced Framework Usage
```lua
-- Multi-framework compatible function
local function getPlayerMoney(source)
    local player = lib.framework.getPlayer(source)
    if not player then
        return 0
    end
    
    local framework = lib.framework.getFramework()
    
    if framework == 'esx' then
        return player.getMoney and player.getMoney() or 0
    elseif framework == 'qb' or framework == 'qbx' then
        return player.PlayerData?.money?.cash or 0
    end
    
    return 0
end

-- Usage
local money = getPlayerMoney(source)
print(('Player has $%d'):format(money))
```

---

## Performance Considerations

### Caching System
- **Server**: Player objects cached for 5 seconds
- **Automatic Cleanup**: Cache cleared on player disconnect
- **Memory Efficient**: Only active players are cached

### Best Practices

1. **Check Availability**: Always check `lib.framework.isAvailable()` before using framework functions
2. **Use Caching**: The system automatically caches player objects - don't implement your own
3. **Batch Operations**: Use `getAllPlayers()` for bulk operations
4. **Error Handling**: Always handle `nil` returns gracefully

```lua
-- Good practice
if lib.framework.isAvailable() then
    local player = lib.framework.getPlayer(source)
    if player then
        -- Safe to use player object
    end
end

-- Avoid repeated calls - use caching
local players = lib.framework.getAllPlayers() -- Cached result
for _, player in ipairs(players) do
    -- Process each player
end
```

---

## Error Handling

The framework system includes comprehensive error handling:

### Input Validation
```lua
-- All functions validate inputs
local player = lib.framework.getPlayer("invalid") -- Returns nil
local player = lib.framework.getPlayer(-1)        -- Returns nil
```

### Graceful Failures
```lua
-- Functions return nil instead of throwing errors
local player = lib.framework.getPlayer(999) -- Non-existent player
if not player then
    print('Player not found') -- Handle gracefully
end
```

### Framework Unavailability
```lua
-- Check framework availability
if not lib.framework.isAvailable() then
    print('Framework not available')
    return
end
```

---

## Events and Lifecycle

### Automatic Initialization
```lua
-- Framework detection happens automatically
CreateThread(function()
    Wait(1000) -- Wait for frameworks to load
    detectAndInitFramework()
end)
```

### Player Disconnect Cleanup
```lua
-- Automatic cache cleanup
AddEventHandler('playerDropped', function()
    local source = source
    local cacheKey = ('player_%d'):format(source)
    playerCache[cacheKey] = nil
end)
```

---

## Troubleshooting

### Common Issues

1. **Framework Not Detected**
   ```lua
   -- Check resource states
   print('ESX:', GetResourceState('es_extended'))
   print('QBCore:', GetResourceState('qb-core'))
   print('QBX:', GetResourceState('qbx_core'))
   
   -- Refresh detection
   lib.framework.refresh()
   ```

2. **Player Not Found**
   ```lua
   -- Verify player exists
   local players = GetPlayers()
   local playerExists = false
   for _, playerId in ipairs(players) do
       if tonumber(playerId) == source then
           playerExists = true
           break
       end
   end
   
   if not playerExists then
       print('Player not connected')
   end
   ```

3. **Performance Issues**
   ```lua
   -- Check cache statistics
   local stats = lib.framework.getStats()
   print('Cached players:', stats.cachedPlayers)
   print('Online players:', stats.onlinePlayers)
   
   -- High cache miss ratio might indicate issues
   ```

### Debug Information
```lua
-- Get comprehensive system status
local function debugFrameworkSystem()
    local stats = lib.framework.getStats()
    
    print('=== Framework System Debug ===')
    print('Framework:', stats.framework or 'None')
    print('Available:', stats.available)
    print('Cached Players:', stats.cachedPlayers)
    print('Online Players:', stats.onlinePlayers)
    
    -- Test framework functions
    if stats.available then
        local testPlayer = lib.framework.getPlayer(GetPlayers()[1])
        print('Test Player Load:', testPlayer ~= nil)
    end
end

-- Run debug
debugFrameworkSystem()
```

---

## Migration Guide

### From Direct Framework Usage

**Before:**
```lua
-- Direct ESX usage
local xPlayer = ESX.GetPlayerFromId(source)

-- Direct QBCore usage  
local Player = QBCore.Functions.GetPlayer(source)
```

**After:**
```lua
-- Unified approach
local player = lib.framework.getPlayer(source)
-- Works with any framework automatically
```

### From Custom Framework Detection

**Before:**
```lua
local framework = nil
if GetResourceState('es_extended') == 'started' then
    framework = 'esx'
elseif GetResourceState('qb-core') == 'started' then
    framework = 'qb'
end
```

**After:**
```lua
local framework = lib.framework.getFramework()
-- Automatic detection with caching
```
