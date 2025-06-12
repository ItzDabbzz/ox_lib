--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxAssert
lib.assert = {}

--- Safe assertion that logs detailed errors instead of crashing
---@param condition any The condition to check
---@param message string Error message if condition fails
---@param context? table Additional context for logging
---@param source? number Player source for logging (optional)
---@param level? string Log level (default: "error")
---@return boolean success Whether the assertion passed
function lib.assert.check(condition, message, context, source, level)
    if condition then
        return true
    end

    level = level or "error"
    local resource = cache.resource

    local errorData = {
        assertion_failed = true,
        message = message,
        context = context or {},
        stack_trace = debug.traceback(),
        timestamp = os.time(),
        resource = resource
    }

    if lib.logger then
        lib.logger(
            source and tonumber(source) or nil,
            'assertion',
            message,
            'resource:' .. resource,
            'level:' .. level
        )
    else
        -- Fallback to console logging
        lib.print.error(('[%s] ASSERTION FAILED: %s'):format(resource, message))
        if context and next(context) then
            lib.print.info(('[%s] Context: %s'):format(resource, json.encode(context)))
            lib.print.info(('[%s] Stack Trace: %s'):format(resource, debug.traceback()))
        end
    end

    return false
end

--- Validates that a value is not nil
---@param value any The value to check
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.notNil(value, name, context, source)
    return lib.assert.check(
        value ~= nil,
        ('%s cannot be nil'):format(name),
        context,
        source
    )
end

--- Validates that a value is of the expected type
---@param value any The value to check
---@param expectedType string The expected type
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.type(value, expectedType, name, context, source)
    local actualType = type(value)
    local mergedContext = lib.table and lib.table.merge({
        expectedType = expectedType,
        actualType = actualType,
        value = value
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.expectedType = expectedType
        mergedContext.actualType = actualType
        mergedContext.value = value
    end

    return lib.assert.check(
        actualType == expectedType,
        ('%s must be %s, got %s'):format(name, expectedType, actualType),
        mergedContext,
        source
    )
end

--- Validates that a string is not empty
---@param value string The string to check
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.notEmpty(value, name, context, source)
    local mergedContext = lib.table and lib.table.merge({
        valueType = type(value),
        valueLength = type(value) == "string" and #value or nil
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.valueType = type(value)
        mergedContext.valueLength = type(value) == "string" and #value or nil
    end

    return lib.assert.check(
        type(value) == "string" and value ~= "",
        ('%s must be a non-empty string'):format(name),
        mergedContext,
        source
    )
end

--- Validates that a number is positive
---@param value number The number to check
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.positive(value, name, context, source)
    local mergedContext = lib.table and lib.table.merge({
        valueType = type(value),
        value = value
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.valueType = type(value)
        mergedContext.value = value
    end

    return lib.assert.check(
        type(value) == "number" and value > 0,
        ('%s must be a positive number'):format(name),
        mergedContext,
        source
    )
end

--- Validates that a table contains a specific key
---@param tbl table The table to check
---@param key any The key to look for
---@param name string The name of the table for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.hasKey(tbl, key, name, context, source)
    local mergedContext = lib.table and lib.table.merge({
        tableType = type(tbl),
        key = key,
        hasKey = type(tbl) == "table" and tbl[key] ~= nil
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.tableType = type(tbl)
        mergedContext.key = key
        mergedContext.hasKey = type(tbl) == "table" and tbl[key] ~= nil
    end

    return lib.assert.check(
        type(tbl) == "table" and tbl[key] ~= nil,
        ('%s must contain key \'%s\''):format(name, tostring(key)),
        mergedContext,
        source
    )
end

--- Validates that a value is within a range
---@param value number The value to check
---@param min number Minimum value (inclusive)
---@param max number Maximum value (inclusive)
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.range(value, min, max, name, context, source)
    local mergedContext = lib.table and lib.table.merge({
        value = value,
        min = min,
        max = max,
        valueType = type(value)
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.value = value
        mergedContext.min = min
        mergedContext.max = max
        mergedContext.valueType = type(value)
    end

    return lib.assert.check(
        type(value) == "number" and value >= min and value <= max,
        ('%s must be between %s and %s'):format(name, min, max),
        mergedContext,
        source
    )
end

--- Validates multiple conditions at once
---@param conditions table Array of condition tables with {condition, message, context?}
---@param source? number Player source
---@return boolean allValid Whether all conditions passed
---@return table failedConditions Array of failed condition messages
function lib.assert.multiple(conditions, source)
    local allValid = true
    local failedConditions = {}

    for i, conditionData in ipairs(conditions) do
        local condition = conditionData[1] or conditionData.condition
        local message = conditionData[2] or conditionData.message
        local context = conditionData[3] or conditionData.context

        if not lib.assert.check(condition, message, context, source) then
            allValid = false
            failedConditions[#failedConditions + 1] = message
        end
    end

    return allValid, failedConditions
end

--- Creates a scoped assertion function with preset context
---@param baseContext table Base context to include in all assertions
---@param source? number Default source
---@return function scopedAssert Function that takes (condition, message, additionalContext?)
function lib.assert.createScoped(baseContext, source)
    return function(condition, message, additionalContext)
        local mergedContext = baseContext or {}
        if lib.table and additionalContext then
            mergedContext = lib.table.merge(additionalContext, baseContext or {})
        elseif additionalContext then
            -- Fallback manual merge if lib.table not available
            for k, v in pairs(additionalContext) do
                mergedContext[k] = v
            end
        end
        return lib.assert.check(condition, message, mergedContext, source)
    end
end

--- Validates that a value is a valid vector3
---@param value any The value to check
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.vector3(value, name, context, source)
    local isValid = type(value) == 'vector3' or
        (type(value) == 'table' and value.x and value.y and value.z)

    local mergedContext = lib.table and lib.table.merge({
        valueType = type(value),
        hasX = type(value) == 'table' and value.x ~= nil,
        hasY = type(value) == 'table' and value.y ~= nil,
        hasZ = type(value) == 'table' and value.z ~= nil
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.valueType = type(value)
        if type(value) == 'table' then
            mergedContext.hasX = value.x ~= nil
            mergedContext.hasY = value.y ~= nil
            mergedContext.hasZ = value.z ~= nil
        end
    end

    return lib.assert.check(
        isValid,
        ('%s must be a valid vector3'):format(name),
        mergedContext,
        source
    )
end

--- Validates that a value is a valid entity
---@param value any The value to check
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.entity(value, name, context, source)
    local isValid = type(value) == 'number' and DoesEntityExist(value)

    local mergedContext = lib.table and lib.table.merge({
        valueType = type(value),
        value = value,
        exists = type(value) == 'number' and DoesEntityExist(value)
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.valueType = type(value)
        mergedContext.value = value
        mergedContext.exists = type(value) == 'number' and DoesEntityExist(value)
    end

    return lib.assert.check(
        isValid,
        ('%s must be a valid entity'):format(name),
        mergedContext,
        source
    )
end

--- Validates that a value is a valid player source
---@param value any The value to check
---@param name string The name of the value for error messages
---@param context? table Additional context
---@param source? number Player source
---@return boolean valid
function lib.assert.playerSource(value, name, context, source)
    local isValid = type(value) == 'number' and value > 0 and GetPlayerName(value) ~= nil

    local mergedContext = lib.table and lib.table.merge({
        valueType = type(value),
        value = value,
        playerExists = type(value) == 'number' and GetPlayerName(value) ~= nil
    }, context or {}) or context or {}

    if not lib.table then
        mergedContext.valueType = type(value)
        mergedContext.value = value
        mergedContext.playerExists = type(value) == 'number' and GetPlayerName(value) ~= nil
    end

    return lib.assert.check(
        isValid,
        ('%s must be a valid player source'):format(name),
        mergedContext,
        source
    )
end

--- Global shorthand function for quick assertions
---@param condition any The condition to check
---@param message string Error message if condition fails
---@param context? table Additional context for logging
---@param source? number Player source for logging
---@return boolean success Whether the assertion passed
function lib.safeAssert(condition, message, context, source)
    return lib.assert.check(condition, message, context, source)
end

return lib.assert
