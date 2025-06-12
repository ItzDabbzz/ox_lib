# ox_lib Types System

A comprehensive type checking and validation system for FiveM Lua development. The types module provides robust type detection, validation, and conversion utilities with support for FiveM-specific data types.

## Features

- 🔍 **Comprehensive Type Detection**: Basic Lua types plus FiveM-specific types
- ✅ **Advanced Validation**: Multi-type validation with detailed error messages
- 🔄 **Type Conversion**: Safe type conversion utilities
- 🎯 **Entity Validation**: FiveM entity, player, vehicle, ped validation
- 📊 **Mathematical Checks**: Finite, NaN, infinity, positive/negative detection
- 🛠️ **Custom Validators**: Create reusable type checker functions
- 📋 **Table Utilities**: Array detection, empty checks, required key validation

---

## API Reference

### Basic Type Checking

#### `lib.types.isString(value)`
Checks if a value is a string.

```lua
print(lib.types.isString("hello"))     -- true
print(lib.types.isString(123))         -- false
print(lib.types.isString(nil))         -- false
```

#### `lib.types.isNumber(value)`
Checks if a value is a number (integer or float).

```lua
print(lib.types.isNumber(42))          -- true
print(lib.types.isNumber(3.14))        -- true
print(lib.types.isNumber("42"))        -- false
```

#### `lib.types.isInteger(value)`
Checks if a value is specifically an integer.

```lua
print(lib.types.isInteger(42))         -- true
print(lib.types.isInteger(3.14))       -- false
print(lib.types.isInteger("42"))       -- false
```

#### `lib.types.isFloat(value)`
Checks if a value is specifically a float.

```lua
print(lib.types.isFloat(3.14))         -- true
print(lib.types.isFloat(42))           -- false
print(lib.types.isFloat("3.14"))       -- false
```

#### `lib.types.isBoolean(value)`
Checks if a value is a boolean.

```lua
print(lib.types.isBoolean(true))       -- true
print(lib.types.isBoolean(false))      -- true
print(lib.types.isBoolean(1))          -- false
```

#### `lib.types.isFunction(value)`
Checks if a value is a function.

```lua
print(lib.types.isFunction(print))     -- true
print(lib.types.isFunction("print"))   -- false
```

#### `lib.types.isTable(value)`
Checks if a value is a table.

```lua
print(lib.types.isTable({}))           -- true
print(lib.types.isTable({1, 2, 3}))    -- true
print(lib.types.isTable("table"))      -- false
```

#### `lib.types.isNil(value)`
Checks if a value is nil.

```lua
print(lib.types.isNil(nil))            -- true
print(lib.types.isNil(false))          -- false
print(lib.types.isNil(0))              -- false
```

---

### Advanced Type Checking

#### `lib.types.isArray(value)`
Checks if a value is an array-like table (sequential integer keys starting at 1).

```lua
print(lib.types.isArray({1, 2, 3}))           -- true
print(lib.types.isArray({"a", "b", "c"}))     -- true
print(lib.types.isArray({a = 1, b = 2}))      -- false
print(lib.types.isArray({[1] = "a", [3] = "c"})) -- false (gap in sequence)
```

#### `lib.types.isEmpty(value)`
Checks if a table is empty.

```lua
print(lib.types.isEmpty({}))           -- true
print(lib.types.isEmpty({1}))          -- false
print(lib.types.isEmpty(""))           -- false (not a table)
```

#### `lib.types.isEmptyString(value)`
Checks if a string is empty or contains only whitespace.

```lua
print(lib.types.isEmptyString(""))     -- true
print(lib.types.isEmptyString("   "))  -- true
print(lib.types.isEmptyString("hello")) -- false
print(lib.types.isEmptyString(nil))    -- false (not a string)
```

#### `lib.types.isCallable(value)`
Checks if a value is callable (function or table with __call metamethod).

```lua
print(lib.types.isCallable(print))     -- true
print(lib.types.isCallable(function() end)) -- true

-- Table with __call metamethod
local callable_table = setmetatable({}, {
    __call = function() return "called" end
})
print(lib.types.isCallable(callable_table)) -- true
```

---

### Mathematical Type Checking

#### `lib.types.isPositive(value)`
Checks if a value is a positive number.

```lua
print(lib.types.isPositive(5))         -- true
print(lib.types.isPositive(-5))        -- false
print(lib.types.isPositive(0))         -- false
```

#### `lib.types.isNegative(value)`
Checks if a value is a negative number.

```lua
print(lib.types.isNegative(-5))        -- true
print(lib.types.isNegative(5))         -- false
print(lib.types.isNegative(0))         -- false
```

#### `lib.types.isZero(value)`
Checks if a value is exactly zero.

```lua
print(lib.types.isZero(0))             -- true
print(lib.types.isZero(0.0))           -- true
print(lib.types.isZero(1))             -- false
```

#### `lib.types.isFinite(value)`
Checks if a value is a finite number (not NaN or infinite).

```lua
print(lib.types.isFinite(42))          -- true
print(lib.types.isFinite(math.huge))   -- false
print(lib.types.isFinite(0/0))         -- false (NaN)
```

#### `lib.types.isNaN(value)`
Checks if a value is NaN (Not a Number).

```lua
print(lib.types.isNaN(0/0))            -- true
print(lib.types.isNaN(42))             -- false
print(lib.types.isNaN("NaN"))          -- false
```

#### `lib.types.isInfinite(value)`
Checks if a value is infinite.

```lua
print(lib.types.isInfinite(math.huge))  -- true
print(lib.types.isInfinite(-math.huge)) -- true
print(lib.types.isInfinite(42))         -- false
```

---

### Vector Type Checking

#### `lib.types.isVector2(value)`
Checks if a value is a vector2.

```lua
local vec2 = vector2(1.0, 2.0)
print(lib.types.isVector2(vec2))       -- true
print(lib.types.isVector2({x=1, y=2})) -- false
```

#### `lib.types.isVector3(value)`
Checks if a value is a vector3.

```lua
local vec3 = vector3(1.0, 2.0, 3.0)
print(lib.types.isVector3(vec3))       -- true
print(lib.types.isVector3(vec2))       -- false
```

#### `lib.types.isVector4(value)`
Checks if a value is a vector4.

```lua
local vec4 = vector4(1.0, 2.0, 3.0, 4.0)
print(lib.types.isVector4(vec4))       -- true
print(lib.types.isVector4(vec3))       -- false
```

#### `lib.types.isVector(value)`
Checks if a value is any vector type.

```lua
print(lib.types.isVector(vector2(1, 2)))    -- true
print(lib.types.isVector(vector3(1, 2, 3))) -- true
print(lib.types.isVector(vector4(1, 2, 3, 4))) -- true
print(lib.types.isVector({x=1, y=2}))       -- false
```

---

### FiveM Entity Validation

#### `lib.types.isEntity(value)`
Checks if a value is a valid entity ID.

```lua
local vehicle = CreateVehicle(GetHashKey('adder'), 0, 0, 0, 0, false, false)
print(lib.types.isEntity(vehicle))     -- true
print(lib.types.isEntity(999999))      -- false (if entity doesn't exist)
print(lib.types.isEntity("vehicle"))   -- false
```

#### `lib.types.isPlayer(value)`
Checks if a value is a valid player ID.

```lua
print(lib.types.isPlayer(1))           -- true (if player 1 exists)
print(lib.types.isPlayer(999))         -- false (if player doesn't exist)
print(lib.types.isPlayer(-1))          -- false
```

#### `lib.types.isVehicle(value)`
Checks if a value is a valid vehicle entity.

```lua
local vehicle = CreateVehicle(GetHashKey('adder'), 0, 0, 0, 0, false, false)
local ped = PlayerPedId()

print(lib.types.isVehicle(vehicle))    -- true
print(lib.types.isVehicle(ped))        -- false
```

#### `lib.types.isPed(value)`
Checks if a value is a valid ped entity.

```lua
local ped = PlayerPedId()
local vehicle = CreateVehicle(GetHashKey('adder'), 0, 0, 0, 0, false, false)

print(lib.types.isPed(ped))            -- true
print(lib.types.isPed(vehicle))        -- false
```

#### `lib.types.isObject(value)`
Checks if a value is a valid object entity.

```lua
local object = CreateObject(GetHashKey('prop_barrier_work05'), 0, 0, 0, false, false, false)
local ped = PlayerPedId()

print(lib.types.isObject(object))      -- true
print(lib.types.isObject(ped))         -- false
```

---

### Advanced Validation

#### `lib.types.getType(value)`
Gets the detailed type of a value, including custom types.

```lua
print(lib.types.getType(42))           -- "integer"
print(lib.types.getType(3.14))         -- "float"
print(lib.types.getType({1, 2, 3}))    -- "array"
print(lib.types.getType({}))           -- "empty_table"
print(lib.types.getType({a = 1}))      -- "table"
print(lib.types.getType("hello"))      -- "string"
```

#### `lib.types.validate(value, expectedTypes, valueName)`
Validates that a value matches one of the expected types.

```lua
-- Single type validation
local valid, error = lib.types.validate("hello", "string", "username")
print(valid)  -- true

-- Multiple type validation
local valid, error = lib.types.validate(42, {"string", "number"}, "input")
print(valid)  -- true

-- Failed validation
local valid, error = lib.types.validate("hello", "number", "age")
print(valid)  -- false
print(error)  -- "age must be number (received string)"
```

#### `lib.types.assert(value, expectedTypes, valueName)`
Asserts that a value matches the expected type(s), throws error if not.

```lua
-- This will pass
local value = lib.types.assert("hello", "string", "username")
print(value)  -- "hello"

-- This will throw an error
local value = lib.types.assert("hello", "number", "age")
-- Error: age must be number (received string)
```

#### `lib.types.convert(value, targetType)`
Safely converts a value to the specified type if possible.

```lua
print(lib.types.convert(42, "string"))      -- "42"
print(lib.types.convert("42", "number"))    -- 42
print(lib.types.convert("true", "boolean"))  -- true
print(lib.types.convert("false", "boolean")) -- false
print(lib.types.convert(1, "boolean"))      -- true
print(lib.types.convert(0, "boolean"))      -- false
print(lib.types.convert("hello", "number")) -- nil (conversion failed)
```

---

### Table Utilities

#### `lib.types.hasRequiredKeys(tbl, requiredKeys)`
Checks if a table has all the required keys.

```lua
local data = {
    name = "John",
    age = 30,
    city = "Los Santos"
}

local valid, missing = lib.types.hasRequiredKeys(data, {"name", "age"})
print(valid)   -- true
print(#missing) -- 0

local valid, missing = lib.types.hasRequiredKeys(data, {"name", "age", "phone"})
print(valid)   -- false
print(missing[1]) -- "phone"
```

---

### Custom Validators

#### `lib.types.createChecker(expectedType)`
Creates a type checker function for a specific type.

```lua
local isString = lib.types.createChecker("string")
local isInteger = lib.types.createChecker("integer")

print(isString("hello"))  -- true
print(isString(42))       -- false
print(isInteger(42))      -- true
print(isInteger(3.14))    -- false
```

#### `lib.types.createValidator(expectedTypes)`
Creates a validator function for multiple types.

```lua
local validateInput = lib.types.createValidator({"string", "number"})

local valid, error = validateInput("hello", "user_input")
print(valid)  -- true

local valid, error = validateInput(true, "user_input")
print(valid)  -- false
print(error)  -- "user_input must be string or number (received boolean)"
```

---

## Usage Examples

### Function Parameter Validation
```lua
local function processUser(userData)
    -- Validate required structure
    local valid, missing = lib.types.hasRequiredKeys(userData, {"name", "age", "email"})
    if not valid then
        error("Missing required fields: " .. table.concat(missing, ", "))
    end
    
    -- Validate individual fields
    lib.types.assert(userData.name, "string", "name")
    lib.types.assert(userData.age, "integer", "age")
    lib.types.assert(userData.email, "string", "email")
    
    -- Additional validation
    if not lib.types.isPositive(userData.age) then
        error("Age must be positive")
    end
    
    print("Processing user:", userData.name)
end

-- Usage
processUser({
    name = "John Doe",
    age = 30,
    email = "john@example.com"
})
```

### Entity Validation System
```lua
local function teleportEntity(entity, coords)
    -- Validate entity
    if not lib.types.isEntity(entity) then
        lib.print.error("Invalid entity provided")
        return false
    end
        -- Validate coordinates
    if not lib.types.isVector3(coords) then
        lib.print.error("Coordinates must be a vector3")
        return false
    end
    
    -- Perform teleportation
    SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, true)
    return true
end

-- Usage
local playerPed = PlayerPedId()
local destination = vector3(100.0, 200.0, 30.0)

if teleportEntity(playerPed, destination) then
    print("Teleportation successful")
else
    print("Teleportation failed")
end
```

### Configuration Validation
```lua
local function validateConfig(config)
    -- Check if config is a table
    if not lib.types.isTable(config) then
        error("Configuration must be a table")
    end
    
    -- Define required configuration keys
    local requiredKeys = {"server_name", "max_players", "enable_pvp", "spawn_coords"}
    local valid, missing = lib.types.hasRequiredKeys(config, requiredKeys)
    
    if not valid then
        error("Missing configuration keys: " .. table.concat(missing, ", "))
    end
    
    -- Validate individual configuration values
    lib.types.assert(config.server_name, "string", "server_name")
    lib.types.assert(config.max_players, "integer", "max_players")
    lib.types.assert(config.enable_pvp, "boolean", "enable_pvp")
    lib.types.assert(config.spawn_coords, "vector3", "spawn_coords")
    
    -- Additional validation
    if not lib.types.isPositive(config.max_players) then
        error("max_players must be positive")
    end
    
    if config.max_players > 128 then
        error("max_players cannot exceed 128")
    end
    
    print("Configuration validated successfully")
    return true
end

-- Usage
local serverConfig = {
    server_name = "My FiveM Server",
    max_players = 32,
    enable_pvp = true,
    spawn_coords = vector3(-269.4, -955.3, 31.2)
}

validateConfig(serverConfig)
```

### Dynamic Type Conversion
```lua
local function processInput(input, expectedType)
    local currentType = lib.types.getType(input)
    
    if currentType == expectedType then
        return input
    end
    
    -- Attempt conversion
    local converted = lib.types.convert(input, expectedType)
    
    if converted ~= nil then
        lib.print.info(("Converted %s from %s to %s"):format(
            tostring(input), currentType, expectedType
        ))
        return converted
    else
        lib.print.error(("Cannot convert %s from %s to %s"):format(
            tostring(input), currentType, expectedType
        ))
        return nil
    end
end

-- Usage examples
print(processInput("42", "number"))     -- 42 (converted)
print(processInput("true", "boolean"))  -- true (converted)
print(processInput(42, "number"))       -- 42 (no conversion needed)
print(processInput("hello", "number"))  -- nil (conversion failed)
```

### Vehicle System Integration
```lua
local function spawnVehicle(model, coords, heading)
    -- Validate model
    if lib.types.isString(model) then
        model = GetHashKey(model)
    elseif not lib.types.isInteger(model) then
        lib.print.error("Vehicle model must be string or integer")
        return nil
    end
    
    -- Validate coordinates
    if not lib.types.isVector3(coords) then
        lib.print.error("Coordinates must be vector3")
        return nil
    end
    
    -- Validate heading (optional)
    heading = heading or 0.0
    if not lib.types.isNumber(heading) then
        lib.print.error("Heading must be a number")
        return nil
    end
    
    -- Request model
    lib.requestModel(model)
    
    -- Create vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    
    -- Validate creation
    if not lib.types.isVehicle(vehicle) then
        lib.print.error("Failed to create vehicle")
        return nil
    end
    
    lib.print.info("Vehicle spawned successfully")
    return vehicle
end

-- Usage
local vehicle = spawnVehicle("adder", vector3(0, 0, 30), 90.0)
if vehicle then
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
end
```

### Player Data Validation
```lua
local function validatePlayerData(playerId, data)
    -- Validate player ID
    if not lib.types.isPlayer(playerId) then
        lib.print.error("Invalid player ID: " .. tostring(playerId))
        return false
    end
    
    -- Validate data structure
    if not lib.types.isTable(data) then
        lib.print.error("Player data must be a table")
        return false
    end
    
    -- Define validation rules
    local validationRules = {
        name = "string",
        level = "integer",
        money = {"integer", "float"},
        position = "vector3",
        is_admin = "boolean",
        inventory = "array"
    }
    
    -- Validate each field
    for field, expectedTypes in pairs(validationRules) do
        if data[field] ~= nil then
            local valid, error = lib.types.validate(data[field], expectedTypes, field)
            if not valid then
                lib.print.error("Player data validation failed: " .. error)
                return false
            end
        end
    end
    
    -- Additional business logic validation
    if data.level and not lib.types.isPositive(data.level) then
        lib.print.error("Player level must be positive")
        return false
    end
    
    if data.money and lib.types.isNegative(data.money) then
        lib.print.error("Player money cannot be negative")
        return false
    end
    
    return true
end

-- Usage
local playerData = {
    name = "John Doe",
    level = 25,
    money = 50000.50,
    position = vector3(-269.4, -955.3, 31.2),
    is_admin = false,
    inventory = {"weapon_pistol", "bread", "water"}
}

if validatePlayerData(1, playerData) then
    print("Player data is valid")
    -- Save to database or process further
else
    print("Player data validation failed")
end
```

### Custom Type Validators
```lua
-- Create specialized validators
local isValidCoords = lib.types.createValidator({"vector3", "vector4"})
local isValidId = lib.types.createChecker("integer")
local isValidName = lib.types.createChecker("string")

-- Create a compound validator
local function validateSpawnPoint(spawnPoint)
    local valid, error = isValidCoords(spawnPoint.coords, "spawn coordinates")
    if not valid then
        return false, error
    end
    
    if not isValidId(spawnPoint.id) then
        return false, "Spawn point ID must be an integer"
    end
    
    if not isValidName(spawnPoint.name) then
        return false, "Spawn point name must be a string"
    end
    
    if spawnPoint.heading and not lib.types.isNumber(spawnPoint.heading) then
        return false, "Spawn point heading must be a number"
    end
    
    return true
end

-- Usage
local spawnPoints = {
    {
        id = 1,
        name = "Hospital",
        coords = vector3(-269.4, -955.3, 31.2),
        heading = 180.0
    },
    {
        id = 2,
        name = "Police Station",
        coords = vector3(425.1, -979.5, 30.7)
    }
}

for _, spawnPoint in ipairs(spawnPoints) do
    local valid, error = validateSpawnPoint(spawnPoint)
    if valid then
        print("Spawn point '" .. spawnPoint.name .. "' is valid")
    else
        print("Spawn point validation failed: " .. error)
    end
end
```

---

## Best Practices

### 1. **Early Validation**
```lua
-- Good: Validate at function entry
local function processTransaction(playerId, amount)
    lib.types.assert(playerId, "integer", "player ID")
    lib.types.assert(amount, "number", "transaction amount")
    
    if not lib.types.isPlayer(playerId) then
        error("Player does not exist")
    end
    
    if not lib.types.isPositive(amount) then
        error("Transaction amount must be positive")
    end
    
    -- Process transaction...
end

-- Avoid: Late validation
local function processTransaction(playerId, amount)
    -- ... lots of processing ...
    if type(amount) ~= "number" then  -- Too late!
        error("Invalid amount")
    end
end
```

### 2. **Use Descriptive Names**
```lua
-- Good: Descriptive parameter names
lib.types.assert(vehicleEntity, "integer", "vehicle entity")
lib.types.assert(playerCoords, "vector3", "player coordinates")

-- Avoid: Generic names
lib.types.assert(entity, "integer", "value")
lib.types.assert(coords, "vector3", "parameter")
```

### 3. **Combine Multiple Checks**
```lua
-- Good: Comprehensive validation
local function validateWeapon(weaponData)
    lib.types.assert(weaponData, "table", "weapon data")
    
    local required = {"name", "damage", "ammo_type"}
    local valid, missing = lib.types.hasRequiredKeys(weaponData, required)
    
    if not valid then
        error("Missing weapon data: " .. table.concat(missing, ", "))
    end
    
    lib.types.assert(weaponData.name, "string", "weapon name")
    lib.types.assert(weaponData.damage, "number", "weapon damage")
    
    if not lib.types.isPositive(weaponData.damage) then
        error("Weapon damage must be positive")
    end
end
```

### 4. **Use Type Conversion Safely**
```lua
-- Good: Check conversion result
local function setPlayerMoney(playerId, amount)
    -- Convert string input to number if possible
    amount = lib.types.convert(amount, "number")
    
    if amount == nil then
        error("Amount must be convertible to number")
    end
    
    lib.types.assert(playerId, "integer", "player ID")
    
    -- Set money...
end

-- Avoid: Assume conversion works
local function setPlayerMoney(playerId, amount)
    amount = tonumber(amount)  -- May return nil
    -- ... rest of function assumes amount is valid
end
```

### 5. **Create Reusable Validators**
```lua
-- Create common validators for your project
local Validators = {
    playerId = lib.types.createValidator({"integer"}),
    coordinates = lib.types.createValidator({"vector3", "vector4"}),
    entityId = lib.types.createChecker("integer"),
    playerName = lib.types.createChecker("string")
}

-- Use throughout your codebase
local function teleportPlayer(playerId, coords)
    local valid, error = Validators.playerId(playerId, "player ID")
    if not valid then
        error(error)
    end
    
    local valid, error = Validators.coordinates(coords, "coordinates")
    if not valid then
        error(error)
    end
    
    -- Teleport logic...
end
```

---

## Performance Considerations

### Type Checking Performance
- Basic type checks (`isString`, `isNumber`, etc.) are very fast
- Entity validation functions (`isEntity`, `isVehicle`, etc.) use FiveM natives and are slightly slower
- Vector type checking is fast but requires userdata inspection
- Use caching for repeated validations on the same data

### Validation Strategies
```lua
-- For frequently called functions, cache validators
local validateCoords = lib.types.createValidator({"vector3"})

local function updatePosition(entity, coords)
    -- Fast cached validation
    local valid = validateCoords(coords)
    if not valid then return false end
    
    -- Update position...
end

-- For one-time validations, use direct calls
local function initializeSystem(config)
    -- Direct validation for initialization
    lib.types.assert(config, "table", "configuration")
    lib.types.assert(config.name, "string", "system name")
end
```

### Memory Usage
- Type validators created with `createValidator` and `createChecker` are lightweight
- No persistent storage of validation results
- Minimal memory overhead for type checking operations

---

## Error Handling

### Validation Errors
```lua
-- Handle validation errors gracefully
local function safeProcessData(data)
    local valid, error = lib.types.validate(data, "table", "input data")
    
    if not valid then
        lib.print.error("Data validation failed: " .. error)
        return nil
    end
    
    -- Process data...
    return processedData
end
```

### Entity Validation Errors
```lua
-- Handle entity validation with fallbacks
local function getVehicleInfo(vehicleId)
    if not lib.types.isVehicle(vehicleId) then
        lib.print.warn("Invalid vehicle ID: " .. tostring(vehicleId))
        return nil
    end
    
    -- Get vehicle information...
    return vehicleInfo
end
```

### Type Conversion Errors
```lua
-- Handle conversion failures
local function parseUserInput(input, expectedType)
    local converted = lib.types.convert(input, expectedType)
    
    if converted == nil then
        lib.print.error(("Cannot convert '%s' to %s"):format(
            tostring(input), expectedType
        ))
        return nil
    end
    
    return converted
end
```

---

## Migration Guide

### From Manual Type Checking

**Before:**
```lua
local function oldValidation(data)
    if type(data) ~= "table" then
        error("Data must be table")
    end
    
    if type(data.name) ~= "string" then
        error("Name must be string")
    end
    
    if type(data.age) ~= "number" or data.age < 0 then
        error("Age must be positive number")
    end
end
```

**After:**
```lua
local function newValidation(data)
    lib.types.assert(data, "table", "data")
    lib.types.assert(data.name, "string", "name")
    lib.types.assert(data.age, "number", "age")
    
    if not lib.types.isPositive(data.age) then
        error("Age must be positive")
    end
end
```

### From Custom Validation Functions

**Before:**
```lua
local function isValidEntity(entity)
    return type(entity) == "number" and entity > 0 and DoesEntityExist(entity)
end

local function isValidPlayer(playerId)
    return type(playerId) == "number" and playerId >= 0 and GetPlayerPed(playerId) ~= 0
end
```

**After:**
```lua
-- Use built-in validators
local isValidEntity = lib.types.isEntity
local isValidPlayer = lib.types.isPlayer
```

---

## Troubleshooting

### Common Issues

1. **Entity Validation Fails**
   ```lua
   -- Check if entity exists before validation
   local entity = CreateVehicle(model, x
   -- Check if entity exists before validation
   local entity = CreateVehicle(model, x, y, z, heading, true, false)
   
   -- Wait for entity to be created
   while not DoesEntityExist(entity) do
       Wait(0)
   end
   
   -- Now validation will work
   print(lib.types.isVehicle(entity)) -- true
   ```

2. **Vector Type Detection Issues**
   ```lua
   -- Ensure you're using proper vector constructors
   local coords = vector3(100.0, 200.0, 30.0)  -- Correct
   print(lib.types.isVector3(coords)) -- true
   
   local coords = {x = 100, y = 200, z = 30}   -- This is a table, not vector3
   print(lib.types.isVector3(coords)) -- false
   
   -- Convert table to vector if needed
   if lib.types.isTable(coords) and coords.x and coords.y and coords.z then
       coords = vector3(coords.x, coords.y, coords.z)
   end
   ```

3. **Type Conversion Failures**
   ```lua
   -- Debug conversion issues
   local function debugConvert(value, targetType)
       local result = lib.types.convert(value, targetType)
       
       if result == nil then
           print(("Failed to convert '%s' (%s) to %s"):format(
               tostring(value), lib.types.getType(value), targetType
           ))
       else
           print(("Converted '%s' to '%s' (%s)"):format(
               tostring(value), tostring(result), targetType
           ))
       end
       
       return result
   end
   
   debugConvert("42", "number")     -- Success
   debugConvert("hello", "number")  -- Failure with debug info
   ```

4. **Array vs Table Detection**
   ```lua
   -- Understanding array detection
   local array = {1, 2, 3}           -- Array (sequential keys)
   local table = {a = 1, b = 2}      -- Table (named keys)
   local mixed = {1, 2, a = 3}       -- Table (mixed keys)
   local sparse = {[1] = "a", [3] = "c"} -- Table (sparse array)
   
   print(lib.types.isArray(array))   -- true
   print(lib.types.isArray(table))   -- false
   print(lib.types.isArray(mixed))   -- false
   print(lib.types.isArray(sparse))  -- false
   ```

### Debug Commands

```lua
-- Add debug command for type testing
RegisterCommand('typetest', function(source, args)
    local testValue = args[1]
    
    -- Try to convert to different types
    local asNumber = tonumber(testValue)
    local asBoolean = testValue == "true"
    
    print("Original value:", testValue)
    print("Type:", lib.types.getType(testValue))
    print("Is string:", lib.types.isString(testValue))
    print("Is number:", lib.types.isNumber(asNumber))
    print("Is boolean:", lib.types.isBoolean(asBoolean))
    
    -- Test conversions
    print("Convert to number:", lib.types.convert(testValue, "number"))
    print("Convert to boolean:", lib.types.convert(testValue, "boolean"))
end, false)

-- Usage: /typetest 42
-- Usage: /typetest true
-- Usage: /typetest hello
```

### Performance Testing

```lua
-- Performance comparison function
local function performanceTest()
    local testData = {
        "string",
        42,
        3.14,
        true,
        {},
        {1, 2, 3},
        vector3(1, 2, 3),
        PlayerPedId()
    }
    
    local iterations = 10000
    
    -- Test lib.types performance
    local startTime = GetGameTimer()
    for i = 1, iterations do
        for _, value in ipairs(testData) do
            lib.types.getType(value)
        end
    end
    local libTypesTime = GetGameTimer() - startTime
    
    -- Test native type() performance
    startTime = GetGameTimer()
    for i = 1, iterations do
        for _, value in ipairs(testData) do
            type(value)
        end
    end
    local nativeTypeTime = GetGameTimer() - startTime
    
    print("lib.types.getType():", libTypesTime, "ms")
    print("native type():", nativeTypeTime, "ms")
    print("Overhead:", libTypesTime - nativeTypeTime, "ms")
end

-- Run performance test
-- performanceTest()
```

---

## Advanced Usage

### Custom Type Definitions

```lua
-- Define custom type checkers for your domain
local CustomTypes = {}

-- Player data type checker
function CustomTypes.isPlayerData(value)
    if not lib.types.isTable(value) then
        return false
    end
    
    local required = {"id", "name", "position"}
    local valid, missing = lib.types.hasRequiredKeys(value, required)
    
    if not valid then
        return false
    end
    
    return lib.types.isInteger(value.id) and
           lib.types.isString(value.name) and
           lib.types.isVector3(value.position)
end

-- Vehicle configuration type checker
function CustomTypes.isVehicleConfig(value)
    if not lib.types.isTable(value) then
        return false
    end
    
    return lib.types.isString(value.model) and
           lib.types.isVector3(value.spawn_coords) and
           lib.types.isNumber(value.heading) and
           (value.color == nil or lib.types.isTable(value.color))
end

-- Usage
local playerData = {
    id = 1,
    name = "John Doe",
    position = vector3(100, 200, 30)
}

if CustomTypes.isPlayerData(playerData) then
    print("Valid player data")
end
```

### Type-Safe Configuration System

```lua
local ConfigValidator = {}

-- Define configuration schema
ConfigValidator.schema = {
    server = {
        name = "string",
        max_players = "integer",
        port = "integer"
    },
    gameplay = {
        enable_pvp = "boolean",
        respawn_time = "number",
        spawn_points = "array"
    },
    database = {
        host = "string",
        port = "integer",
        username = "string",
        password = "string"
    }
}

-- Validate configuration against schema
function ConfigValidator.validate(config, schema)
    schema = schema or ConfigValidator.schema
    
    for key, expectedType in pairs(schema) do
        local value = config[key]
        
        if value == nil then
            return false, ("Missing required config key: %s"):format(key)
        end
        
        if lib.types.isTable(expectedType) then
            -- Nested validation
            if not lib.types.isTable(value) then
                return false, ("Config key '%s' must be a table"):format(key)
            end
            
            local valid, error = ConfigValidator.validate(value, expectedType)
            if not valid then
                return false, ("Config section '%s': %s"):format(key, error)
            end
        else
            -- Type validation
            local valid, error = lib.types.validate(value, expectedType, key)
            if not valid then
                return false, error
            end
            
            -- Additional validation for specific types
            if expectedType == "integer" and key:find("port") then
                if value < 1 or value > 65535 then
                    return false, ("Port %s must be between 1 and 65535"):format(key)
                end
            end
        end
    end
    
    return true
end

-- Usage
local config = {
    server = {
        name = "My FiveM Server",
        max_players = 32,
        port = 30120
    },
    gameplay = {
        enable_pvp = true,
        respawn_time = 5.0,
        spawn_points = {
            vector3(-269.4, -955.3, 31.2),
            vector3(425.1, -979.5, 30.7)
        }
    },
    database = {
        host = "localhost",
        port = 3306,
        username = "fivem",
        password = "password123"
    }
}

local valid, error = ConfigValidator.validate(config)
if valid then
    print("Configuration is valid")
else
    print("Configuration error:", error)
end
```

### Runtime Type Checking Decorator

```lua
-- Function decorator for automatic type checking
local function typeCheck(paramTypes, returnType)
    return function(func)
        return function(...)
            local args = {...}
            
            -- Validate parameters
            for i, expectedType in ipairs(paramTypes) do
                if args[i] ~= nil then
                    local valid, error = lib.types.validate(args[i], expectedType, ("parameter %d"):format(i))
                    if not valid then
                        error(("Function call failed: %s"):format(error), 2)
                    end
                end
            end
            
            -- Call original function
            local results = {func(...)}
            
            -- Validate return value if specified
            if returnType and results[1] ~= nil then
                local valid, error = lib.types.validate(results[1], returnType, "return value")
                if not valid then
                    error(("Function return failed: %s"):format(error), 2)
                end
            end
            
            return table.unpack(results)
        end
    end
end

-- Usage example
local calculateDistance = typeCheck({"vector3", "vector3"}, "number")(
    function(pos1, pos2)
        return #(pos1 - pos2)
    end
)

-- This will work
local distance = calculateDistance(vector3(0, 0, 0), vector3(10, 0, 0))
print(distance) -- 10.0

-- This will throw an error
-- local distance = calculateDistance("invalid", vector3(10, 0, 0))
```

---

## Integration Examples

### With ox_lib Callback System

```lua
-- Server-side callback with type validation
lib.callback.register('getPlayerData', function(source, playerId)
    -- Validate input
    if not lib.types.isInteger(playerId) then
        return nil, "Player ID must be an integer"
    end
    
    if not lib.types.isPlayer(playerId) then
        return nil, "Player does not exist"
    end
    
    -- Get player data
    local playerData = {
        id = playerId,
        name = GetPlayerName(playerId),
        coords = GetEntityCoords(GetPlayerPed(playerId))
    }
    
    return playerData
end)

-- Client-side callback usage with validation
lib.callback.await('getPlayerData', false, 1, function(playerData, error)
    if error then
        lib.print.error("Callback error: " .. error)
        return
    end
    
    -- Validate received data
    if not lib.types.isTable(playerData) then
        lib.print.error("Invalid player data received")
        return
    end
    
    local required = {"id", "name", "coords"}
    local valid, missing = lib.types.hasRequiredKeys(playerData, required)
    
    if not valid then
        lib.print.error("Incomplete player data: " .. table.concat(missing, ", "))
        return
    end
    
    print("Player data:", json.encode(playerData))
end)
```

### With ox_lib Menu System

```lua
-- Menu with type-validated options
local function createVehicleMenu()
    local menuOptions = {}
    
    -- Validate vehicle data before creating menu
    local vehicles = {
        {name = "Adder", model = "adder", price = 1000000},
        {name = "Zentorno", model = "zentorno", price = 725000},
        {name = "T20", model = "t20", price = 2200000}
    }
    
    for _, vehicle in ipairs(vehicles) do
        -- Validate vehicle data structure
        local valid, missing = lib.types.hasRequiredKeys(vehicle, {"name", "model", "price"})
        
        if valid then
            lib.types.assert(vehicle.name, "string", "vehicle name")
            lib.types.assert(vehicle.model, "string", "vehicle model")
            lib.types.assert(vehicle.price, "number", "vehicle price")
            
            if lib.types.isPositive(vehicle.price) then
                menuOptions[#menuOptions + 1] = {
                    title = vehicle.name,
                    description = ("Price: $%s"):format(lib.math.groupDigits(vehicle.price)),
                    onSelect = function()
                        spawnVehicle(vehicle.model)
                    end
                }
            end
        else
            lib.print.warn("Invalid vehicle data, missing: " .. table.concat(missing, ", "))
        end
    end
    
    lib.registerContext({
        id = 'vehicle_menu',
        title = 'Vehicle Shop',
        options = menuOptions
    })
    
    lib.showContext('vehicle_menu')
end
```

---

## License

This module is part of ox_lib and is licensed under LGPL-3.0 or higher.

## Support

For issues and support:
- Check the troubleshooting section above
- Use the debug commands provided for testing
- Verify FiveM natives are available for entity validation
- Report issues to the ox_lib repository

---

## Changelog

### Version 1.0.0
- Initial release with comprehensive type checking
- Support for all basic Lua types
- FiveM entity validation
- Vector type detection
- Mathematical type checking
- Advanced validation and conversion utilities
- Custom validator creation
- Table utility functions
```
