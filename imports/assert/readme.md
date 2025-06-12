# lib.assert

Safe assertion system that logs errors instead of crashing your server. Perfect for validation and debugging.

## Quick Start

```lua
-- Basic assertion
lib.assert.check(player ~= nil, 'Player cannot be nil')

-- Type checking
lib.assert.type(coords, 'vector3', 'Player coordinates')

-- Check if valid
if lib.assert.notNil(vehicle, 'Vehicle') then
    -- Vehicle exists, safe to use
end
```

## Basic Functions

### `lib.assert.check(condition, message, context?, source?)`
Main assertion function. Returns `true` if condition passes, `false` if it fails.

```lua
local isValid = lib.assert.check(amount > 0, 'Amount must be positive')
if isValid then
    -- Safe to proceed
end
```

### `lib.assert.notNil(value, name, context?, source?)`
Check if value is not nil.

```lua
lib.assert.notNil(player, 'Player object')
lib.assert.notNil(vehicle, 'Vehicle entity')
```

### `lib.assert.type(value, expectedType, name, context?, source?)`
Validate value type.

```lua
lib.assert.type(playerId, 'number', 'Player ID')
lib.assert.type(playerName, 'string', 'Player name')
lib.assert.type(coords, 'vector3', 'Coordinates')
```

### `lib.assert.notEmpty(value, name, context?, source?)`
Check if string is not empty.

```lua
lib.assert.notEmpty(playerName, 'Player name')
lib.assert.notEmpty(itemName, 'Item name')
```

### `lib.assert.positive(value, name, context?, source?)`
Check if number is positive.

```lua
lib.assert.positive(amount, 'Transaction amount')
lib.assert.positive(distance, 'Distance value')
```

## Advanced Functions

### `lib.assert.hasKey(table, key, name, context?, source?)`
Check if table contains key.

```lua
lib.assert.hasKey(playerData, 'money', 'Player data')
lib.assert.hasKey(config, 'database', 'Config')
```

### `lib.assert.range(value, min, max, name, context?, source?)`
Check if number is within range.

```lua
lib.assert.range(health, 0, 100, 'Player health')
lib.assert.range(speed, 0, 200, 'Vehicle speed')
```

### `lib.assert.vector3(value, name, context?, source?)`
Check if value is valid vector3.

```lua
lib.assert.vector3(spawnPoint, 'Spawn coordinates')
lib.assert.vector3(targetLocation, 'Target location')
```

### `lib.assert.entity(value, name, context?, source?)`
Check if value is valid entity.

```lua
lib.assert.entity(vehicle, 'Player vehicle')
lib.assert.entity(ped, 'Player ped')
```

### `lib.assert.playerSource(value, name, context?, source?)`
Check if value is valid player source.

```lua
lib.assert.playerSource(source, 'Player source')
```

## Batch Validation

### `lib.assert.multiple(conditions, source?)`
Validate multiple conditions at once.

```lua
local success, failed = lib.assert.multiple({
    {player ~= nil, 'Player required'},
    {type(amount) == 'number', 'Amount must be number'},
    {amount > 0, 'Amount must be positive'},
    {amount <= balance, 'Insufficient funds'}
})

if success then
    -- All validations passed
else
    print('Failed validations:', table.concat(failed, ', '))
end
```

## Scoped Assertions

### `lib.assert.createScoped(baseContext, source?)`
Create assertion function with preset context.

```lua
local bankAssert = lib.assert.createScoped({
    system = 'banking',
    operation = 'transfer'
})

-- Use scoped assertions
bankAssert(fromAccount ~= nil, 'Source account required')
bankAssert(toAccount ~= nil, 'Target account required')
bankAssert(amount > 0, 'Transfer amount must be positive')
```

## Real Examples

### Bank Transfer Validation
```lua
local function transferMoney(source, fromAccount, toAccount, amount)
    -- Validate all inputs
    local success, failed = lib.assert.multiple({
        {lib.assert.playerSource(source, 'Player source'), 'Invalid player'},
        {lib.assert.notEmpty(fromAccount, 'From account'), 'From account required'},
        {lib.assert.notEmpty(toAccount, 'To account'), 'To account required'},
        {lib.assert.positive(amount, 'Transfer amount'), 'Amount must be positive'}
    })
    
    if not success then
        lib.notify(source, {
            title = 'Transfer Failed',
            description = table.concat(failed, '\n'),
            type = 'error'
        })
        return false
    end
    
    -- Safe to proceed with transfer
    return processTransfer(fromAccount, toAccount, amount)
end
```

### Vehicle Spawn Validation
```lua
local function spawnVehicle(source, model, coords, heading)
    -- Create scoped assertion for vehicle spawning
    local vehicleAssert = lib.assert.createScoped({
        operation = 'vehicle_spawn',
        player = source
    })
    
    -- Validate inputs
    if not vehicleAssert(lib.assert.playerSource(source, 'Player'), 'Invalid player source') then
        return
    end
    
    if not vehicleAssert(lib.assert.notEmpty(model, 'Vehicle model'), 'Vehicle model required') then
        return
    end
    
    if not vehicleAssert(lib.assert.vector3(coords, 'Spawn coordinates'), 'Invalid spawn coordinates') then
        return
    end
    
    if not vehicleAssert(lib.assert.type(heading, 'number', 'Vehicle heading'), 'Invalid heading') then
        return
    end
    
    -- All validations passed, spawn vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    return vehicle
end
```

### Item Usage Validation
```lua
local function useItem(source, itemName, amount)
    local itemAssert = lib.assert.createScoped({
        operation = 'item_use',
        player = source,
        item = itemName
    }, source)
    
    -- Quick validation chain
    if not itemAssert(source > 0, 'Valid player required') then return end
    if not itemAssert(type(itemName) == 'string', 'Item name must be string') then return end
    if not itemAssert(itemName ~= '', 'Item name cannot be empty') then return end
    if not itemAssert(type(amount) == 'number', 'Amount must be number') then return end
    if not itemAssert(amount > 0, 'Amount must be positive') then return end
    
    -- Safe to use item
    return processItemUse(source, itemName, amount)
end
```

## Quick Reference

| Function | Purpose | Example |
|----------|---------|---------|
| `check()` | Basic assertion | `lib.assert.check(x > 0, 'X must be positive')` |
| `notNil()` | Not nil check | `lib.assert.notNil(player, 'Player')` |
| `type()` | Type validation | `lib.assert.type(id, 'number', 'Player ID')` |
| `notEmpty()` | String not empty | `lib.assert.notEmpty(name, 'Name')` |
| `positive()` | Positive number | `lib.assert.positive(amount, 'Amount')` |
| `hasKey()` | Table has key | `lib.assert.hasKey(data, 'money', 'Data')` |
| `range()` | Number in range | `lib.assert.range(health, 0, 100, 'Health')` |
| `vector3()` | Valid vector3 | `lib.assert.vector3(coords, 'Coordinates')` |
| `entity()` | Valid entity | `lib.assert.entity(vehicle, 'Vehicle')` |
| `playerSource()` | Valid player | `lib.assert.playerSource(source, 'Source')` |

All functions return `true` if validation passes, `false` if it fails. Failed assertions are automatically logged.
