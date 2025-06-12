# ox_lib Name System

A comprehensive name management system for FiveM that provides unified access to player names across different frameworks (ESX, QBCore, QBX). Built with performance optimization, caching, and error handling in mind.

## Features

- 🔄 **Multi-Framework Support**: Works with ESX, QBCore, and QBX
- ⚡ **Performance Optimized**: Built-in caching system with configurable TTL
- 🛡️ **Error Handling**: Comprehensive validation and graceful error handling
- 📊 **Statistics & Monitoring**: Built-in stats tracking and monitoring
- 🔧 **Cache Management**: Advanced cache control and cleanup
- 📡 **Client Integration**: Full client-server callback system
- 🚀 **Batch Processing**: Efficient bulk name retrieval

## Installation

1. Ensure you have `ox_lib` installed and started
2. The name system is automatically available as part of ox_lib
3. No additional configuration required - framework detection is automatic

## Dependencies

- **Required**: `ox_lib`
- **Framework**: One of the following:
  - `es_extended` (ESX)
  - `qb-core` (QBCore)
  - `qbx_core` (QBX)

## API Reference

### Server-Side Functions

#### `lib.name.getFullName(source)`
Gets the full name of a player.

```lua
local fullName = lib.name.getFullName(source)
if fullName then
    print('Player name:', fullName)
end
```

**Parameters:**
- `source` (number): Player's server ID

**Returns:**
- `string?`: Full name or `nil` if not found

---

#### `lib.name.getFirstName(source)`
Gets the first name of a player.

```lua
local firstName = lib.name.getFirstName(source)
```

**Parameters:**
- `source` (number): Player's server ID

**Returns:**
- `string?`: First name or `nil` if not found

---

#### `lib.name.getLastName(source)`
Gets the last name of a player.

```lua
local lastName = lib.name.getLastName(source)
```

**Parameters:**
- `source` (number): Player's server ID

**Returns:**
- `string?`: Last name or `nil` if not found

---

#### `lib.name.getAllNames(source)`
Gets all name components for a player.

```lua
local nameData = lib.name.getAllNames(source)
if nameData then
    print('First:', nameData.firstName)
    print('Last:', nameData.lastName)
    print('Full:', nameData.fullName)
end
```

**Parameters:**
- `source` (number): Player's server ID

**Returns:**
- `table?`: Name data object or `nil` if not found
  ```lua
  {
      firstName = "John",
      lastName = "Doe", 
      fullName = "John Doe"
  }
  ```

---

#### `lib.name.hasName(source)`
Checks if a player has valid name data.

```lua
if lib.name.hasName(source) then
    -- Player has valid name data
    local name = lib.name.getFullName(source)
end
```

**Parameters:**
- `source` (number): Player's server ID

**Returns:**
- `boolean`: Whether the player has name data

---

#### `lib.name.getBatchNames(sources)`
Gets names for multiple players efficiently.

```lua
local playerSources = {1, 2, 3, 4, 5}
local names = lib.name.getBatchNames(playerSources)

for source, nameData in pairs(names) do
    if nameData then
        print(('Player %d: %s'):format(source, nameData.fullName))
    end
end
```

**Parameters:**
- `sources` (number[]): Array of player source IDs

**Returns:**
- `table`: Map of source ID to name data

---

### Cache Management

#### `lib.name.clearCache(source)`
Clears cached name data for a specific player.

```lua
lib.name.clearCache(source)
```

#### `lib.name.clearAllCache()`
Clears all cached name data.

```lua
lib.name.clearAllCache()
```

#### `lib.name.preloadNames()`
Preloads names for all online players for better performance.

```lua
local count = lib.name.preloadNames()
print(('Preloaded names for %d players'):format(count))
```

**Returns:**
- `number`: Number of names preloaded

---

### System Information

#### `lib.name.getFramework()`
Gets the detected framework name.

```lua
local framework = lib.name.getFramework()
print('Using framework:', framework) -- "esx", "qb", "qbx", or nil
```

#### `lib.name.getStats()`
Gets comprehensive statistics about the name system.

```lua
local stats = lib.name.getStats()
print(json.encode(stats, {indent = true}))
```

**Returns:**
```lua
{
    framework = "qb",
    frameworkAvailable = true,
    cachedNames = 15,
    onlinePlayers = 25,
    frameworkCachedPlayers = 8
}
```

#### `lib.name.refreshFramework()`
Refreshes framework detection (useful if frameworks load after this resource).

```lua
local framework = lib.name.refreshFramework()
```

---

### Client-Side Integration

The name system provides client-side callbacks for accessing player names:

```lua
-- Client-side usage
local fullName = lib.callback.await('ox_lib:getName:getFullName', false)
local firstName = lib.callback.await('ox_lib:getName:getFirstName', false)
local lastName = lib.callback.await('ox_lib:getName:getLastName', false)
local allNames = lib.callback.await('ox_lib:getName:getAllNames', false)
local hasName = lib.callback.await('ox_lib:getName:hasName', false)
local stats = lib.callback.await('ox_lib:getName:getStats', false)
```

## Framework Compatibility

### ESX
- Supports both legacy and modern ESX versions
- Handles `player.get('firstName')` and `player.firstname` patterns
- Compatible with different ESX initialization methods

### QBCore
- Full QBCore support via `player.PlayerData.charinfo`
- Handles both `QBCore` global and export methods
- Compatible with all QBCore versions

### QBX
- Native QBX support via exports
- Optimized for QBX's player data structure
- Full compatibility with QBX Core

## Performance Features

### Caching System
- **TTL**: 30-second cache duration for names
- **Automatic Cleanup**: Cache cleared on player disconnect
- **Memory Efficient**: Separate cache keys for different name types
- **Preloading**: Optional bulk preloading for high-traffic servers

### Optimization Tips

1. **Use Batch Processing**: For multiple players, use `getBatchNames()`
2. **Preload Names**: Call `preloadNames()` during server startup
3. **Monitor Cache**: Use `getStats()` to monitor cache efficiency
4. **Clear Cache**: Manually clear cache when player data changes

```lua
-- Optimal usage for multiple players
local sources = GetPlayers()
local names = lib.name.getBatchNames(sources)

-- Preload for better performance
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SetTimeout(5000, function()
            lib.name.preloadNames()
        end)
    end
end)
```

## Error Handling

The system includes comprehensive error handling:

- **Input Validation**: All inputs are validated using `lib.assert`
- **Graceful Failures**: Returns `nil` instead of throwing errors
- **Logging**: Detailed logging for debugging
- **Framework Detection**: Automatic fallback if framework unavailable

```lua
-- Safe usage pattern
local fullName = lib.name.getFullName(source)
if fullName then
    -- Name found, safe to use
    TriggerClientEvent('showName', source, fullName)
else
    -- Handle missing name gracefully
    TriggerClientEvent('showError', source, 'Name not available')
end
```

## Events

The system automatically handles these events:

- **playerDropped**: Clears cache for disconnected players
- **onResourceStart**: Initializes framework detection
- **Framework Loading**: Waits for frameworks to load before initialization

## Troubleshooting

### Common Issues

1. **Names Not Found**
   ```lua
   -- Check if framework is available
   if not lib.name.getFramework() then
       print('No framework detected')
   end
   
   -- Check if player exists
   if not lib.name.hasName(source) then
       print('Player has no name data')
   end
   ```

2. **Performance Issues**
   ```lua
   -- Check cache statistics
   local stats = lib.name.getStats()
   print('Cached names:', stats.cachedNames)
   
   -- Preload names for better performance
   lib.name.preloadNames()
   ```

3. **Framework Detection Issues**
   ```lua
   -- Refresh framework detection
   local framework = lib.name.refreshFramework()
   print('Framework after refresh:', framework)
   ```

### Debug Information

Enable debug logging to troubleshoot issues:

```lua
-- Check system status
local stats = lib.name.getStats()
print('Name System Status:')
print('Framework:', stats.framework)
print('Available:', stats.frameworkAvailable)
print('Cached Names:', stats.cachedNames)
print('Online Players:', stats.onlinePlayers)
```

## Examples

### Basic Usage
```lua
-- Get player name for chat message
RegisterCommand('greet', function(source, args)
    local playerName = lib.name.getFullName(source)
    if playerName then
        TriggerClientEvent('chat:addMessage', -1, {
            args = {playerName, 'Hello everyone!'}
        })
    end
end)
```

### Advanced Usage
```lua
-- Player management system
local function getPlayerInfo(source)
    local nameData = lib.name.getAllNames(source)
    if not nameData then
        return nil
    end
    
    return {
        source = source,
        name = nameData.fullName,
        firstName = nameData.firstName,
        lastName = nameData.lastName,
        identifier = lib.framework.getPlayerIdentifier(source)
    }
end

-- Batch player processing
local function getAllPlayerInfo()
    local sources = {}
    for _, playerId in ipairs(GetPlayers()) do
        sources[#sources + 1] = tonumber(playerId)
    end
    
    local names = lib.name.getBatchNames(sources)
    local players = {}
    
    for source, nameData in pairs(names) do
        if nameData then
            players[#players + 1] = {
                source = source,
                name = nameData.fullName,
                firstName = nameData.firstName,
                lastName = nameData.lastName
            }
        end
    end
    
    return players
end
```