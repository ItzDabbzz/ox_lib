# ox_lib Player Death Module

Cross-framework player death detection system that works with ESX, QBX, and QB-Core automatically.

## Features

- Automatic framework detection (ESX, QBX, QB-Core)
- Death and last stand status checking
- Bulk player death checking
- Admin functions for setting death status
- Server statistics and monitoring
- Client callbacks for death status
- Comprehensive logging integration

## Quick Start

```lua
-- Check if a player is dead
local isDead = lib.isPlayerDead.check(source)

-- Get detailed death status
local status = lib.isPlayerDead.getStatus(source)

-- Get all dead players
local deadPlayers = lib.isPlayerDead.getAllDead()

-- Admin: Revive a player
lib.isPlayerDead.revive(source, "Admin revive")
```

## API Reference

### `lib.isPlayerDead.check(source)`
Check if a player is dead or in last stand.

```lua
local isDead = lib.isPlayerDead.check(source)
if isDead then
    -- Player is dead or in last stand
end
```

**Parameters:**
- `source` (number): Player server ID

**Returns:** `boolean` - Whether the player is dead or in last stand

### `lib.isPlayerDead.getStatus(source)`
Get detailed death status information.

```lua
local status = lib.isPlayerDead.getStatus(source)
--[[
{
    isDead = false,
    inLastStand = false,
    framework = "qb",
    timestamp = 1640995200
}
--]]
```

**Parameters:**
- `source` (number): Player server ID

**Returns:** `table` - Detailed death status information

### `lib.isPlayerDead.checkMultiple(sources)`
Check death status for multiple players.

```lua
local results = lib.isPlayerDead.checkMultiple({1, 2, 3, 4})
--[[
{
    [1] = { isDead = false, status = {...} },
    [2] = { isDead = true, status = {...} },
    [3] = { isDead = false, status = {...} },
    [4] = { isDead = true, status = {...} }
}
--]]
```

**Parameters:**
- `sources` (number[]): Array of player server IDs

**Returns:** `table` - Results for each player

### `lib.isPlayerDead.getAllDead()`
Get all dead players on the server.

```lua
local deadPlayers = lib.isPlayerDead.getAllDead()
--[[
[
    {
        source = 5,
        name = "John Doe",
        isDead = true,
        inLastStand = false,
        framework = "qb",
        timestamp = 1640995200
    }
]
--]]
```

**Returns:** `table` - Array of dead player information

## Admin Functions

### `lib.isPlayerDead.set(source, isDead, reason?)`
Set player death status (admin function).

```lua
-- Kill a player
lib.isPlayerDead.set(source, true, "Admin punishment")

-- Revive a player
lib.isPlayerDead.set(source, false, "Admin revive")
```

**Parameters:**
- `source` (number): Player server ID
- `isDead` (boolean): Death status to set
- `reason` (string, optional): Reason for status change

**Returns:** `boolean` - Success status

### `lib.isPlayerDead.revive(source, reason?)`
Revive a player (shorthand for setting death status to false).

```lua
lib.isPlayerDead.revive(source, "Medical assistance")
```

**Parameters:**
- `source` (number): Player server ID
- `reason` (string, optional): Reason for revival

**Returns:** `boolean` - Success status

### `lib.isPlayerDead.kill(source, reason?)`
Kill a player (shorthand for setting death status to true).

```lua
lib.isPlayerDead.kill(source, "Admin action")
```

**Parameters:**
- `source` (number): Player server ID
- `reason` (string, optional): Reason for death

**Returns:** `boolean` - Success status

## Statistics

### `lib.isPlayerDead.getStats()`
Get server death statistics.

```lua
local stats = lib.isPlayerDead.getStats()
--[[
{
    totalPlayers = 25,
    deadPlayers = 3,
    alivePlayers = 22,
    inLastStand = 1,
    deadPlayersList = [
        { source = 5, name = "John Doe", inLastStand = false },
        { source = 12, name = "Jane Smith", inLastStand = true }
    ],
    timestamp = 1640995200
}
--]]
```

**Returns:** `table` - Server death statistics

## Client Callbacks

The module automatically registers callbacks for client-side requests:

```lua
-- Client side
local isDead = lib.callback.await('ox_lib:isPlayerDead', false)
local status = lib.callback.await('ox_lib:getPlayerDeathStatus', false)
```

## Framework Compatibility

| Framework | Death Check | Last Stand | Method |
|-----------|-------------|------------|---------|
| ESX | `isDead` metadata | Not supported | `player.get('isDead')` |
| QB-Core | `isdead` metadata | `inlaststand` metadata | `PlayerData.metadata` |
| QBX | `isdead` metadata | `inlaststand` metadata | `PlayerData.metadata` |

## Examples

### Basic Death Checking
```lua
-- Check before allowing actions
RegisterNetEvent('shop:buyItem', function(item)
    local source = source
    
    if lib.isPlayerDead.check(source) then
        return TriggerClientEvent('notify', source, 'You cannot shop while dead!', 'error')
    end
    
    -- Continue with purchase logic
end)

-- Prevent dead players from using commands
lib.addCommand('repair', {
    help = 'Repair vehicle'
}, function(source, args)
    if lib.isPlayerDead.check(source) then
        return TriggerClientEvent('chat:addMessage', source, {
            args = { 'ERROR', 'You cannot use this command while dead!' }
        })
    end
    
    -- Repair logic
end)
```

### Medical System Integration
```lua
-- EMS job - find dead players
RegisterNetEvent('ems:findDeadPlayers', function()
    local source = source
    local deadPlayers = lib.isPlayerDead.getAllDead()
    
    if #deadPlayers == 0 then
        return TriggerClientEvent('notify', source, 'No dead players found', 'info')
    end
    
    for _, player in ipairs(deadPlayers) do
        local coords = GetEntityCoords(GetPlayerPed(player.source))
        TriggerClientEvent('ems:addBlip', source, {
            coords = coords,
            label = ('Dead Player: %s'):format(player.name),
            sprite = 153,
            color = 1
        })
    end
end)

-- Revive player
RegisterNetEvent('ems:revivePlayer', function(targetId)
    local source = source
    
    if not lib.isPlayerDead.check(targetId) then
        return TriggerClientEvent('notify', source, 'Player is not dead', 'error')
    end
    
    if lib.isPlayerDead.revive(targetId, 'EMS revive') then
        TriggerClientEvent('notify', source, 'Player revived successfully', 'success')
        TriggerClientEvent('notify', targetId, 'You have been revived by EMS', 'success')
    end
end)
```

### Admin Commands
```lua
-- Admin revive command
lib.addCommand('revive', {
    help = 'Revive a player',
    params = {
        { name = 'id', type = 'playerId', help = 'Player ID' }
    },
    restricted = 'group.admin'
}, function(source, args)
    if lib.isPlayerDead.revive(args.id, 'Admin revive') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'ADMIN', ('Revived player %d'):format(args.id) }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'ERROR', 'Failed to revive player' }
        })
    end
end)

-- Admin kill command
lib.addCommand('kill', {
    help = 'Kill a player',
    params = {
        { name = 'id', type = 'playerId', help = 'Player ID' }
    },
    restricted = 'group.admin'
}, function(source, args)
    if lib.isPlayerDead.kill(args.id, 'Admin kill') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'ADMIN', ('Killed player %d'):format(args.id) }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'ERROR', 'Failed to kill player' }
        })
    end
end)

-- Check death stats
lib.addCommand('deathstats', {
    help = 'View server death statistics',
    restricted = 'group.admin'
}, function(source, args)
    local stats = lib.isPlayerDead.getStats()
    
    TriggerClientEvent('chat:addMessage', source, {
        args = { 'STATS', ('Total Players: %d'):format(stats.totalPlayers) }
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = { 'STATS', ('Dead Players: %d'):format(stats.deadPlayers) }
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = { 'STATS', ('In Last Stand: %d'):format(stats.inLastStand) }
    })
end)
```

### Event-Based Monitoring
```lua
-- Monitor death status changes
AddEventHandler('ox_lib:playerDeathStatusChanged', function(source, isDead, reason)
    local playerName = GetPlayerName(source)
    
    if isDead then
        lib.print.info(('Player %s (%d) died - %s'):format(playerName, source, reason or 'Unknown'))
        
        -- Notify other players
        TriggerClientEvent('chat:addMessage', -1, {
            args = { 'DEATH', ('%s has died'):format(playerName) }
        })
    else
        lib.print.info(('Player %s (%d) revived - %s'):format(playerName, source, reason or 'Unknown'))
        
        -- Notify other players
        TriggerClientEvent('chat:addMessage', -1, {
            args = { 'REVIVE', ('%s has been revived'):format(playerName) }
        })
    end
end)

-- Periodic death monitoring
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        local stats = lib.isPlayerDead.getStats()
        if stats.deadPlayers > 0 then
            lib.print.info(('Death Monitor: %d dead players, %d in last stand'):format(
                stats.deadPlayers, stats.inLastStand
            ))
        end
    end
end)
```

### Job Restrictions
```lua
-- Prevent dead players from working
local jobEvents = {
    'police:duty',
    'ems:duty',
    'mechanic:duty'
}

for _, event in ipairs(jobEvents) do
    RegisterNetEvent(event, function()
        local source = source
        
        if lib.isPlayerDead.check(source) then
            return TriggerClientEvent('notify', source, 'You cannot go on duty while dead!', 'error')
        end
        
        -- Continue with duty logic
    end)
end
```

### Respawn System Integration
```lua
-- Custom respawn system
RegisterNetEvent('hospital:respawn', function()
    local source = source
    
    if not lib.isPlayerDead.check(source) then
        return TriggerClientEvent('notify', source, 'You are not dead!', 'error')
    end
    
    -- Respawn logic
    local respawnCoords = vector3(-1037.8, -2738.5, 20.2)
    
    if lib.isPlayerDead.revive(source, 'Hospital respawn') then
        SetEntityCoords(GetPlayerPed(source), respawnCoords.x, respawnCoords.y, respawnCoords.z)
        TriggerClientEvent('notify', source, 'You have respawned at the hospital', 'success')
    end
end)
```

## Events

### Server Events
- `ox_lib:playerDeathStatusChanged` - Triggered when a player's death status changes
  - Parameters: `source`, `isDead`, `reason`

## Logging

All death status changes are automatically logged if `lib.logger` is available:

```lua
-- Logged events:
-- player_death_status: When death status is changed by admin functions
```

## Backwards Compatibility

The module provides a global function for backwards compatibility:

```lua
-- Old way (still works)
local isDead = IsPlayerDead(source)

-- New way (recommended)
local isDead = lib.isPlayerDead.check(source)
```

## Error Handling

The system includes comprehensive error handling:

- Validates player existence
- Checks for valid source IDs
- Handles framework unavailability
- Provides detailed error messages
- Graceful fallbacks for missing data

## Performance

- Lightweight framework detection
- Efficient bulk checking operations
- Cached framework information
- Minimal server impact
- Optimized for high player counts
