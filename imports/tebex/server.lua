--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxTebex
lib.tebex = {}

---@class TebexHook
---@field id string Unique identifier for the hook.
---@field label string Human-readable label for the hook.
---@field onPurchase? fun(cfxId: string, args: table): TebexActionResult Optional purchase handler.
---@field onRemove? fun(cfxId: string, args: table): TebexActionResult Optional removal handler.
---@field onRenew? fun(cfxId: string, args: table): TebexActionResult Optional renewal handler.

---@class TebexActionResult
---@field success boolean Whether the action was successful
---@field message? string Optional message describing the result
---@field data? table Optional additional data
---@field retry? boolean Whether the action should be retried on failure
---@field retryDelay? number Delay in seconds before retry (default: 30)

---@class TebexScheduledAction
---@field id string Unique identifier for the scheduled action
---@field hookId string The hook ID to execute
---@field action string The action type (purchase, remove, renew)
---@field cfxId string The CFX ID
---@field args table Command arguments
---@field executeAt number Timestamp when to execute
---@field retries number Number of retries attempted
---@field maxRetries number Maximum retries allowed
---@field retryDelay number Delay between retries in seconds
---@field created number Timestamp when action was created

local tebexHooks = {}
local scheduledActions = {}
local actionIdCounter = 0

--- Generates a unique action ID
---@return string
local function generateActionId()
    actionIdCounter = actionIdCounter + 1
    return ('tebex_action_%d_%d'):format(os.time(), actionIdCounter)
end

--- Logs a Tebex action using lib.logger if available
---@param action string The action type (purchase, remove, renew)
---@param hookId string The hook ID
---@param cfxId string The CFX ID
---@param args table Command arguments
---@param result TebexActionResult? The action result
---@param error? string Error message if action failed
---@param scheduled? boolean Whether this was a scheduled action
---@param executionTime? number Time taken to execute in milliseconds
local function logTebexAction(action, hookId, cfxId, args, result, error, scheduled, executionTime)
    if not lib.logger then return end

    local success = result and result.success or false
    local message = ('Tebex %s - %s%s'):format(
        action:gsub("^%l", string.upper),
        hookId,
        scheduled and " (Scheduled)" or ""
    )

    local logData = {
        action = action,
        hookId = hookId,
        cfxId = cfxId,
        args = args,
        success = success,
        timestamp = os.time(),
        scheduled = scheduled or false,
        executionTime = executionTime
    }

    if result then
        logData.result = {
            message = result.message,
            data = result.data,
            retry = result.retry,
            retryDelay = result.retryDelay
        }
    end

    if error then
        logData.error = error
        logData.stack_trace = debug.traceback()
    end

    -- Use logData by including it in the message or as structured tags
    lib.logger(
        tonumber(cfxId),
        'tebex',
        message .. ' - ' .. json.encode(logData),
        'hookId:' .. hookId,
        'action:' .. action,
        'success:' .. tostring(success)
    )
end


--- Validates handler arguments
---@param hook TebexHook
---@param handlerType string
---@param cfxId string
---@param args table
---@return boolean valid
local function validateHandlerArgs(hook, handlerType, cfxId, args)
    if not hook then
        lib.print.error('Hook object is nil')
        return false
    end

    if not hook.id or hook.id == '' then
        lib.print.error('Hook ID is missing or empty')
        return false
    end

    if not handlerType or handlerType == '' then
        lib.print.error('Handler type is missing or empty')
        return false
    end

    if not cfxId or cfxId == '' or cfxId == '0' then
        lib.print.error('CFX ID is invalid')
        return false
    end

    if type(args) ~= 'table' then
        lib.print.error('Args must be a table')
        return false
    end

    if not hook[handlerType] then
        lib.print.error(('Handler %s not found in hook %s'):format(handlerType, hook.id))
        return false
    end

    return true
end

--- Executes a handler with comprehensive error handling and timing
---@param hook TebexHook
---@param handlerType string
---@param cfxId string
---@param args table
---@param scheduled? boolean
---@return TebexActionResult?, string?
local function executeHandler(hook, handlerType, cfxId, args, scheduled)
    local startTime = GetGameTimer()

    if not validateHandlerArgs(hook, handlerType, cfxId, args) then
        return {
            success = false,
            message = "Handler validation failed",
            retry = false
        }, "Validation failed"
    end

    local handler = hook[handlerType]
    local success, result = pcall(handler, hook, cfxId, args)
    local executionTime = GetGameTimer() - startTime

    if not success then
        logTebexAction(handlerType:gsub("^on", ""):lower(), hook.id, cfxId, args, nil, result, scheduled, executionTime)

        return {
            success = false,
            message = "Handler execution failed",
            retry = true,
            data = { error = result, executionTime = executionTime }
        }, result
    end

    -- Validate and normalize result
    if result == nil then
        result = { success = true, message = "Handler completed successfully" }
    elseif type(result) ~= "table" then
        result = { success = true, message = tostring(result) }
    else
        if result.success == nil then
            result.success = true
        end

        if result.retry and type(result.retry) ~= "boolean" then
            result.retry = false
        end

        if result.retryDelay and (type(result.retryDelay) ~= "number" or result.retryDelay < 0) then
            result.retryDelay = 30
        end
    end

    logTebexAction(handlerType:gsub("^on", ""):lower(), hook.id, cfxId, args, result, nil, scheduled, executionTime)

    return result, nil
end


--- Processes a scheduled action with comprehensive error handling
---@param scheduledAction TebexScheduledAction
local function processScheduledAction(scheduledAction)
    if not scheduledAction then
        lib.print.error('Scheduled action is nil')
        return
    end

    local hook = tebexHooks[scheduledAction.hookId]
    if not hook then
        lib.print.error(('Hook %s not found for scheduled action'):format(scheduledAction.hookId))
        scheduledActions[scheduledAction.id] = nil
        return
    end

    local handlerType = "on" .. scheduledAction.action:gsub("^%l", string.upper)
    local result, error = executeHandler(hook, handlerType, scheduledAction.cfxId, scheduledAction.args, true)

    if result and not result.success and result.retry and scheduledAction.retries < scheduledAction.maxRetries then
        scheduledAction.retries = scheduledAction.retries + 1
        local retryDelay = result.retryDelay or scheduledAction.retryDelay
        scheduledAction.executeAt = os.time() + retryDelay

        if lib.logger then
            lib.logger(tonumber(scheduledAction.cfxId), 'tebex', 'Action Retry Scheduled',
                'actionId:' .. scheduledAction.id, 'retries:' .. scheduledAction.retries, 'delay:' .. retryDelay)
        end

        CreateThread(function()
            lib.waitFor(function()
                return os.time() >= scheduledAction.executeAt and true or nil
            end, ('Retry for action %s timed out'):format(scheduledAction.id), false)

            processScheduledAction(scheduledAction)
        end)
    else
        if lib.logger then
            local status = result and result.success and "completed" or "failed"
            lib.logger(tonumber(scheduledAction.cfxId), 'tebex', 'Scheduled Action Finished',
                'actionId:' .. scheduledAction.id, 'status:' .. status, 'retries:' .. scheduledAction.retries)
        end

        scheduledActions[scheduledAction.id] = nil
    end
end

--- Schedules an action for later execution
---@param hookId string
---@param action string
---@param cfxId string
---@param args table
---@param delay number Delay in seconds
---@param maxRetries? number Maximum retries (default: 3)
---@return string? actionId
local function scheduleAction(hookId, action, cfxId, args, delay, maxRetries)
    if not tebexHooks[hookId] then
        lib.print.error(('Hook %s not found'):format(hookId))
        return nil
    end

    if type(delay) ~= 'number' or delay <= 0 then
        lib.print.error('Delay must be a positive number')
        return nil
    end

    local actionId = generateActionId()
    local executeAt = os.time() + delay

    scheduledActions[actionId] = {
        id = actionId,
        hookId = hookId,
        action = action,
        cfxId = cfxId,
        args = args,
        executeAt = executeAt,
        retries = 0,
        maxRetries = maxRetries or 3,
        retryDelay = 30,
        created = os.time()
    }

    if lib.logger then
        lib.logger(tonumber(cfxId), 'tebex', 'Action Scheduled', 'actionId:' .. actionId, 'hookId:' .. hookId, 'delay:' .. delay)
    end

    CreateThread(function()
        lib.waitFor(function()
            return os.time() >= executeAt and true or nil
        end, ('Scheduled action %s timed out'):format(actionId), false)

        processScheduledAction(scheduledActions[actionId])
    end)

    return actionId
end

--- Registers a new TebexHook.
---@param data table Table containing at least 'id', 'label', and any handlers.
---@return TebexHook? hook The registered hook, or nil on failure.
function lib.tebex.registerHook(data)
    if type(data) ~= 'table' then
        lib.print.error('Hook registration data must be a table')
        return nil
    end

    if not data.id or data.id == '' then
        lib.print.error('Hook ID is required')
        return nil
    end

    if not data.label or data.label == '' then
        lib.print.error('Hook label is required')
        return nil
    end

    if tebexHooks[data.id] then
        lib.print.error(('Hook with ID %s already exists'):format(data.id))
        return nil
    end

    local commands = {
        onPurchase = "purchase_%s",
        onRemove = "remove_%s",
        onRenew = "renew_%s"
    }

    for handlerType, commandFmt in pairs(commands) do
        if data[handlerType] then
            if type(data[handlerType]) ~= 'function' then
                lib.print.error(('Handler %s must be a function'):format(handlerType))
                return nil
            end

            local commandName = commandFmt:format(data.id)
            RegisterCommand(commandName, function(src, args, raw)
                if src ~= 0 then return end
                local cfxId = args[1]
                if not cfxId or cfxId == "0" then return end

                local result, error = executeHandler(data, handlerType, cfxId, args, false)

                if result and result.success then
                    lib.print.info(('[Tebex] Successfully executed %s for hook %s (CFX: %s)%s'):format(
                        handlerType, data.id, cfxId, result.message and (" - " .. result.message) or ""
                    ))
                else
                    lib.print.error(('[Tebex] Failed to execute %s for hook %s (CFX: %s): %s'):format(
                        handlerType, data.id, cfxId, error or (result and result.message) or "Unknown error"
                    ))
                end
            end, true)

            local scheduledCommandName = (commandFmt .. "_scheduled"):format(data.id)
            RegisterCommand(scheduledCommandName, function(src, args, raw)
                if src ~= 0 then return end
                local cfxId = args[1]
                local delay = tonumber(args[2]) or 60
                if not cfxId or cfxId == "0" then return end

                local actionId = scheduleAction(data.id, handlerType:gsub("^on", ""):lower(), cfxId, args, delay)
                if actionId then
                    lib.print.info(('[Tebex] Scheduled %s for hook %s (CFX: %s) in %d seconds (ID: %s)'):format(
                        handlerType, data.id, cfxId, delay, actionId
                    ))
                else
                    lib.print.error(('[Tebex] Failed to schedule %s for hook %s (CFX: %s)'):format(
                        handlerType, data.id, cfxId
                    ))
                end
            end, true)
        end
    end

    if lib.logger then
        lib.logger(nil, 'tebex', 'Hook Registered', 'hookId:' .. data.id, 'label:' .. data.label)
    end

    tebexHooks[data.id] = data
    return data
end

--- Retrieves a registered TebexHook by id.
---@param id string
---@return TebexHook? hook
function lib.tebex.getHook(id)
    if type(id) ~= 'string' then
        lib.print.error('Hook ID must be a string')
        return nil
    end
    return tebexHooks[id]
end

--- Returns all registered TebexHooks.
---@return table<string, TebexHook>
function lib.tebex.getAllHooks()
    return tebexHooks
end

--- Removes a TebexHook by id.
---@param id string
function lib.tebex.removeHook(id)
    if type(id) ~= 'string' then
        lib.print.error('Hook ID must be a string')
        return
    end

    local hook = tebexHooks[id]
    if hook and lib.logger then
        lib.logger(nil, 'tebex', 'Hook Removed', 'hookId:' .. id, 'label:' .. hook.label)
    end
    tebexHooks[id] = nil
end

--- Schedules a Tebex action for later execution
---@param hookId string The hook ID
---@param action string The action type (purchase, remove, renew)
---@param cfxId string The CFX ID
---@param args table Command arguments
---@param delay number Delay in seconds
---@param maxRetries? number Maximum retries (default: 3)
---@return string? actionId The scheduled action ID, or nil if hook not found
function lib.tebex.scheduleAction(hookId, action, cfxId, args, delay, maxRetries)
    if type(hookId) ~= 'string' then
        lib.print.error('Hook ID must be a string')
        return nil
    end

    if type(action) ~= 'string' then
        lib.print.error('Action must be a string')
        return nil
    end

    if type(cfxId) ~= 'string' then
        lib.print.error('CFX ID must be a string')
        return nil
    end

    if type(args) ~= 'table' then
        lib.print.error('Args must be a table')
        return nil
    end

    if not tebexHooks[hookId] then
        lib.print.error(('Hook %s not found'):format(hookId))
        return nil
    end

    return scheduleAction(hookId, action, cfxId, args, delay, maxRetries)
end

--- Gets all scheduled actions
---@return table<string, TebexScheduledAction>
function lib.tebex.getScheduledActions()
    return scheduledActions
end

--- Gets a specific scheduled action by ID
---@param actionId string
---@return TebexScheduledAction? action
function lib.tebex.getScheduledAction(actionId)
    if type(actionId) ~= 'string' then
        lib.print.error('Action ID must be a string')
        return nil
    end
    return scheduledActions[actionId]
end

--- Cancels a scheduled action
---@param actionId string
---@return boolean success
function lib.tebex.cancelScheduledAction(actionId)
    if type(actionId) ~= 'string' then
        lib.print.error('Action ID must be a string')
        return false
    end

    if scheduledActions[actionId] then
        local action = scheduledActions[actionId]
        scheduledActions[actionId] = nil

        if lib.logger then
            lib.logger(tonumber(action.cfxId), 'tebex', 'Scheduled Action Cancelled',
                'actionId:' .. actionId, 'hookId:' .. action.hookId, 'action:' .. action.action)
        end

        return true
    end

    lib.print.error(('Scheduled action %s not found'):format(actionId))
    return false
end

--- Executes a Tebex action immediately (programmatically)
---@param hookId string The hook ID
---@param action string The action type (purchase, remove, renew)
---@param cfxId string The CFX ID
---@param args table Command arguments
---@return TebexActionResult? result The action result, or nil if hook not found
function lib.tebex.executeAction(hookId, action, cfxId, args)
    if type(hookId) ~= 'string' then
        lib.print.error('Hook ID must be a string')
        return nil
    end

    if type(action) ~= 'string' then
        lib.print.error('Action must be a string')
        return nil
    end

    if type(cfxId) ~= 'string' then
        lib.print.error('CFX ID must be a string')
        return nil
    end

    if type(args) ~= 'table' then
        lib.print.error('Args must be a table')
        return nil
    end

    local hook = tebexHooks[hookId]
    if not hook then
        lib.print.error(('Hook %s not found'):format(hookId))
        return nil
    end

    local handlerType = "on" .. action:gsub("^%l", string.upper)
    local result, error = executeHandler(hook, handlerType, cfxId, args, false)

    return result
end

--- Gets statistics about Tebex operations
---@return table stats
function lib.tebex.getStats()
    local stats = {
        totalHooks = 0,
        scheduledActions = 0,
        actionsByHook = {},
        actionsByType = {},
        oldestScheduledAction = nil,
        newestScheduledAction = nil
    }

    for hookId, hook in pairs(tebexHooks) do
        stats.totalHooks = stats.totalHooks + 1
        stats.actionsByHook[hookId] = {
            label = hook.label,
            scheduledCount = 0
        }
    end

    for actionId, action in pairs(scheduledActions) do
        stats.scheduledActions = stats.scheduledActions + 1

        if stats.actionsByHook[action.hookId] then
            stats.actionsByHook[action.hookId].scheduledCount = stats.actionsByHook[action.hookId].scheduledCount + 1
        end

        stats.actionsByType[action.action] = (stats.actionsByType[action.action] or 0) + 1

        if not stats.oldestScheduledAction or action.created < stats.oldestScheduledAction.created then
            stats.oldestScheduledAction = action
        end

        if not stats.newestScheduledAction or action.created > stats.newestScheduledAction.created then
            stats.newestScheduledAction = action
        end
    end

    return stats
end

--- Initialize Tebex system
function lib.tebex.initialize()
    if lib.logger then
        lib.logger(nil, 'tebex', 'System Initializing', 'resource:' .. cache.resource)
    end

    RegisterCommand("tebex_stats", function(src)
        if src ~= 0 then return end
        local stats = lib.tebex.getStats()
        lib.print.info(('[Tebex] Stats: %s'):format(json.encode(stats, { indent = true })))
    end, true)

    RegisterCommand("tebex_cleanup", function(src)
        if src ~= 0 then return end
        local cleaned = 0
        local currentTime = os.time()

        for actionId, action in pairs(scheduledActions) do
            if (currentTime - action.created) > 86400 then
                scheduledActions[actionId] = nil
                cleaned = cleaned + 1
            end
        end

        lib.print.info(('[Tebex] Cleaned up %d old scheduled actions'):format(cleaned))

        if lib.logger then
            lib.logger(nil, 'tebex', 'Cleanup Performed', 'actionsRemoved:' .. cleaned, 'remainingActions:' .. lib.tebex.getStats().scheduledActions)
        end
    end, true)

    if lib.logger then
        lib.logger(nil, 'tebex', 'System Initialized', 'commandsRegistered:true')
    end
end

-- Auto-initialize when the module loads
CreateThread(function()
    Wait(1000)
    lib.tebex.initialize()
end)

return lib.tebex
