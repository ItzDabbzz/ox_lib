--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxTypes
lib.types = {}

--- Checks if a value is a table.
---@param value any The value to check.
---@return boolean Returns true if the value is a table, false otherwise.
function lib.types.isTable(value)
    return type(value) == "table"
end

--- Checks if a value is a string.
---@param value any The value to check.
---@return boolean Returns true if the value is a string, false otherwise.
function lib.types.isString(value)
    return type(value) == "string"
end

--- Checks if a value is a number.
---@param value any The value to check.
---@return boolean Returns true if the value is a number, false otherwise.
function lib.types.isNumber(value)
    return type(value) == "number"
end

--- Checks if a value is an integer.
---@param value any The value to check.
---@return boolean Returns true if the value is an integer, false otherwise.
function lib.types.isInteger(value)
    return type(value) == "number" and math.type(value) == "integer"
end

--- Checks if a value is a float.
---@param value any The value to check.
---@return boolean Returns true if the value is a float, false otherwise.
function lib.types.isFloat(value)
    return type(value) == "number" and math.type(value) == "float"
end

--- Checks if a value is a boolean.
---@param value any The value to check.
---@return boolean Returns true if the value is a boolean, false otherwise.
function lib.types.isBoolean(value)
    return type(value) == "boolean"
end

--- Checks if a value is a function.
---@param value any The value to check.
---@return boolean Returns true if the value is a function, false otherwise.
function lib.types.isFunction(value)
    return type(value) == "function"
end

--- Checks if a value is a thread (coroutine).
---@param value any The value to check.
---@return boolean Returns true if the value is a thread, false otherwise.
function lib.types.isThread(value)
    return type(value) == "thread"
end

--- Checks if a value is userdata.
---@param value any The value to check.
---@return boolean Returns true if the value is userdata, false otherwise.
function lib.types.isUserdata(value)
    return type(value) == "userdata"
end

--- Checks if a value is nil.
---@param value any The value to check.
---@return boolean Returns true if the value is nil, false otherwise.
function lib.types.isNil(value)
    return value == nil
end

--- Checks if a value is callable (function or table with __call metamethod).
---@param value any The value to check.
---@return boolean Returns true if the value is callable, false otherwise.
function lib.types.isCallable(value)
    if type(value) == "function" then
        return true
    end

    local mt = getmetatable(value)
    return mt and type(mt.__call) == "function"
end

--- Checks if a value is an array-like table (all keys are sequential integers starting at 1).
---@param value any The value to check.
---@return boolean Returns true if the value is an array-like table, false otherwise.
function lib.types.isArray(value)
    if type(value) ~= "table" then
        return false
    end

    local i = 0
    for k in pairs(value) do
        i = i + 1
        if k ~= i then
            return false
        end
    end

    return true
end

--- Checks if a value is an empty table.
---@param value any The value to check.
---@return boolean Returns true if the value is an empty table, false otherwise.
function lib.types.isEmpty(value)
    if type(value) ~= "table" then
        return false
    end

    return next(value) == nil
end

--- Checks if a string is empty or contains only whitespace.
---@param value any The value to check.
---@return boolean Returns true if the value is an empty string or whitespace-only, false otherwise.
function lib.types.isEmptyString(value)
    if type(value) ~= "string" then
        return false
    end

    return value:match("^%s*$") ~= nil
end

--- Checks if a value is a positive number.
---@param value any The value to check.
---@return boolean Returns true if the value is a positive number, false otherwise.
function lib.types.isPositive(value)
    return type(value) == "number" and value > 0
end

--- Checks if a value is a negative number.
---@param value any The value to check.
---@return boolean Returns true if the value is a negative number, false otherwise.
function lib.types.isNegative(value)
    return type(value) == "number" and value < 0
end

--- Checks if a value is zero.
---@param value any The value to check.
---@return boolean Returns true if the value is zero, false otherwise.
function lib.types.isZero(value)
    return type(value) == "number" and value == 0
end

--- Checks if a value is a finite number (not NaN or infinite).
---@param value any The value to check.
---@return boolean Returns true if the value is a finite number, false otherwise.
function lib.types.isFinite(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

--- Checks if a value is NaN (Not a Number).
---@param value any The value to check.
---@return boolean Returns true if the value is NaN, false otherwise.
function lib.types.isNaN(value)
    return type(value) == "number" and value ~= value
end

--- Checks if a value is infinite.
---@param value any The value to check.
---@return boolean Returns true if the value is infinite, false otherwise.
function lib.types.isInfinite(value)
    return type(value) == "number" and (value == math.huge or value == -math.huge)
end

--- Checks if a value is a vector2.
---@param value any The value to check.
---@return boolean Returns true if the value is a vector2, false otherwise.
function lib.types.isVector2(value)
    return type(value) == "vector2"
end

--- Checks if a value is a vector3.
---@param value any The value to check.
---@return boolean Returns true if the value is a vector3, false otherwise.
function lib.types.isVector3(value)
    return type(value) == "vector3"
end

--- Checks if a value is a vector4.
---@param value any The value to check.
---@return boolean Returns true if the value is a vector4, false otherwise.
function lib.types.isVector4(value)
    return type(value) == "vector4"
end

--- Checks if a value is any vector type.
---@param value any The value to check.
---@return boolean Returns true if the value is a vector, false otherwise.
function lib.types.isVector(value)
    local valueType = type(value)
    return valueType == "vector2" or valueType == "vector3" or valueType == "vector4"
end

--- Checks if a value is a valid entity ID.
---@param value any The value to check.
---@return boolean Returns true if the value is a valid entity ID, false otherwise.
function lib.types.isEntity(value)
    return type(value) == "number" and value > 0 and DoesEntityExist(value)
end

--- Checks if a value is a valid player ID.
---@param value any The value to check.
---@return boolean Returns true if the value is a valid player ID, false otherwise.
function lib.types.isPlayer(value)
    return type(value) == "number" and value >= 0 and GetPlayerPed(value) ~= 0
end

--- Checks if a value is a valid vehicle entity.
---@param value any The value to check.
---@return boolean Returns true if the value is a valid vehicle, false otherwise.
function lib.types.isVehicle(value)
    return lib.types.isEntity(value) and IsEntityAVehicle(value)
end

--- Checks if a value is a valid ped entity.
---@param value any The value to check.
---@return boolean Returns true if the value is a valid ped, false otherwise.
function lib.types.isPed(value)
    return lib.types.isEntity(value) and IsEntityAPed(value)
end

--- Checks if a value is a valid object entity.
---@param value any The value to check.
---@return boolean Returns true if the value is a valid object, false otherwise.
function lib.types.isObject(value)
    return lib.types.isEntity(value) and IsEntityAnObject(value)
end

--- Gets the detailed type of a value, including custom types.
---@param value any The value to check.
---@return string The detailed type name.
function lib.types.getType(value)
    local basicType = type(value)

    if basicType == "number" then
        if math.type(value) == "integer" then
            return "integer"
        else
            return "float"
        end
    elseif basicType == "table" then
        if lib.types.isArray(value) then
            return "array"
        elseif lib.types.isEmpty(value) then
            return "empty_table"
        else
            return "table"
        end
    elseif basicType == "userdata" then
        -- Check for vector types
        local mt = getmetatable(value)
        if mt and mt.__name then
            return mt.__name
        end
    end

    return basicType
end

--- Validates that a value matches one of the expected types.
---@param value any The value to validate.
---@param expectedTypes string|string[] Expected type(s).
---@param valueName? string Optional name for error messages.
---@return boolean valid Whether the value matches expected types.
---@return string? error Error message if validation failed.
function lib.types.validate(value, expectedTypes, valueName)
    if type(expectedTypes) == "string" then
        expectedTypes = { expectedTypes }
    end

    local actualType = lib.types.getType(value)

    for _, expectedType in ipairs(expectedTypes) do
        if actualType == expectedType then
            return true
        end

        -- Special case handling
        if expectedType == "number" and (actualType == "integer" or actualType == "float") then
            return true
        elseif expectedType == "table" and (actualType == "array" or actualType == "empty_table") then
            return true
        end
    end

    local name = valueName or "Value"
    local expectedStr = table.concat(expectedTypes, " or ")
    return false, ("%s must be %s (received %s)"):format(name, expectedStr, actualType)
end

--- Asserts that a value matches the expected type(s).
---@param value any The value to check.
---@param expectedTypes string|string[] Expected type(s).
---@param valueName? string Optional name for error messages.
---@return any value The original value if validation passes.
function lib.types.assert(value, expectedTypes, valueName)
    local valid, error = lib.types.validate(value, expectedTypes, valueName)

    if not valid then
        lib.print.error(error)
        error(error, 2)
    end

    return value
end

--- Safely converts a value to the specified type if possible.
---@param value any The value to convert.
---@param targetType string The target type.
---@return any? converted The converted value or nil if conversion failed.
function lib.types.convert(value, targetType)
    local currentType = type(value)

    if currentType == targetType then
        return value
    end

    if targetType == "string" then
        return tostring(value)
    elseif targetType == "number" then
        if currentType == "string" then
            return tonumber(value)
        end
    elseif targetType == "boolean" then
        if currentType == "string" then
            local lower = value:lower()
            if lower == "true" or lower == "1" or lower == "yes" then
                return true
            elseif lower == "false" or lower == "0" or lower == "no" then
                return false
            end
        elseif currentType == "number" then
            return value ~= 0
        end
    end

    return nil
end

--- Checks if a table has all the required keys.
---@param tbl table The table to check.
---@param requiredKeys string[] Array of required key names.
---@return boolean valid Whether all required keys exist.
---@return string[] missing Array of missing key names.
function lib.types.hasRequiredKeys(tbl, requiredKeys)
    if not lib.types.isTable(tbl) then
        return false, requiredKeys
    end

    local missing = {}

    for _, key in ipairs(requiredKeys) do
        if tbl[key] == nil then
            missing[#missing + 1] = key
        end
    end

    return #missing == 0, missing
end

--- Creates a type checker function for a specific type.
---@param expectedType string The expected type.
---@return function checker A function that checks if a value matches the type.
function lib.types.createChecker(expectedType)
    return function(value)
        return lib.types.getType(value) == expectedType
    end
end

--- Creates a validator function for multiple types.
---@param expectedTypes string[] Array of expected types.
---@return function validator A function that validates values against the types.
function lib.types.createValidator(expectedTypes)
    return function(value, valueName)
        return lib.types.validate(value, expectedTypes, valueName)
    end
end

return lib.types
