# lib.tebex – Tebex Webhook Command Registration System

A modular, extensible system for registering and handling Tebex (FiveM store) webhook commands in your server resources.

This module allows you to easily define purchase, removal, and renewal handlers for Tebex packages, and exposes them as server console commands for testing or manual invocation.

**Features automatic logging integration with lib.logger and robust error handling.**

---

## ✨ Features

- **Declarative Hook Registration:** Register Tebex package logic in a single table with `id`, `label`, and handler functions.
- **Automatic Command Registration:** For each handler (`onPurchase`, `onRemove`, `onRenew`), a server console command is registered (e.g., `purchase_vip`).
- **OOP-style Handlers:** Handler functions receive the hook instance as `self`, plus the CFX ID and arguments.
- **Safe, Console-Only Execution:** Registered commands can only be run from the server console (`src == 0`).
- **Centralized Hook Registry:** Retrieve hooks by ID or get all registered hooks for introspection or debugging.
- **Automatic Logging Integration:** When lib.logger is configured, all Tebex actions are automatically logged with structured data.
- **Robust Error Handling:** Uses lib.print for consistent error reporting and detailed error logging.
- **Handler Return Values:** Handlers can return structured results with success status, messages, retry logic, and custom data.
- **Scheduled Actions:** Schedule Tebex actions for future execution with automatic retry logic using lib.waitFor.
- **Performance Monitoring:** Execution timing and performance metrics for all handlers.
- **Extensible:** Add more handler types or logic as needed.

---

## 🚀 Usage

### 1. **Register a Tebex Hook**

In your server script:

```lua
lib.tebex.registerHook{
    id = "vip",
    label = "VIP Package",
    onPurchase = function(self, cfxId, args)
        local success = GrantVIPAccess(cfxId)
        return {
            success = success,
            message = success and "VIP access granted" or "Failed to grant VIP",
            data = { package = "vip", cfxId = cfxId, timestamp = os.time() },
            retry = not success,
            retryDelay = success and nil or 120 -- 2 minutes retry on failure
        }
    end,
    onRemove = function(self, cfxId, args)
        local success = RemoveVIPAccess(cfxId)
        return {
            success = success,
            message = success and "VIP access removed" or "Failed to remove VIP",
            retry = not success,
            retryDelay = 60
        }
    end,
    onRenew = function(self, cfxId, args)
        local success = RenewVIPAccess(cfxId)
        return {
            success = success,
            message = success and "VIP access renewed" or "Failed to renew VIP",
            retry = not success
        }
    end
}
```

### 2. **Triggering Handlers via Console**

After registering, the following commands are available in the server console:

**Immediate Execution:**
- `purchase_vip <cfxId>`
- `remove_vip <cfxId>`
- `renew_vip <cfxId>`

**Scheduled Execution:**
- `purchase_vip_scheduled <cfxId> <delay_seconds>`
- `remove_vip_scheduled <cfxId> <delay_seconds>`
- `renew_vip_scheduled <cfxId> <delay_seconds>`

Examples:
```
purchase_vip 110000112345678
purchase_vip_scheduled 110000112345678 300
```

### 3. **Programmatic Usage**

You can execute and schedule actions programmatically:

```lua
-- Execute immediately
local result = lib.tebex.executeAction("vip", "purchase", "110000112345678", {})
if result and result.success then
    lib.print.info("VIP granted:", result.message)
end

-- Schedule for later execution
local actionId = lib.tebex.scheduleAction("vip", "purchase", "110000112345678", {}, 300, 5) -- 5 minutes, max 5 retries

-- Cancel scheduled action
local cancelled = lib.tebex.cancelScheduledAction(actionId)

-- Get all scheduled actions
local scheduled = lib.tebex.getScheduledActions()

-- Get system statistics
local stats = lib.tebex.getStats()
```

### 4. **Accessing Registered Hooks**

You can retrieve hooks programmatically:

```lua
local vipHook = lib.tebex.getHook("vip")
local allHooks = lib.tebex.getAllHooks()

-- Remove a hook
lib.tebex.removeHook("vip")
```

---

## 📊 Logging Integration

When lib.logger is configured in your resource, lib.tebex automatically logs:

### Hook Registration
```lua
-- Logged when a hook is registered
{
    hookId = "vip",
    label = "VIP Package",
    handlers = {
        onPurchase = true,
        onRemove = true,
        onRenew = false
    },
    commandsRegistered = true
}
```

### Action Execution
```lua
-- Logged for each successful/failed action
{
    action = "purchase",
    hookId = "vip",
    cfxId = "110000112345678",
    args = {...},
    success = true,
    timestamp = 1234567890,
    scheduled = false,
    executionTime = 45, -- milliseconds
    result = {
        message = "VIP access granted",
        data = {...},
        retry = false
    }
}
```

### Scheduled Actions
```lua
-- Logged when actions are scheduled
{
    actionId = "tebex_action_1234567890_1",
    hookId = "vip",
    action = "purchase",
    cfxId = "110000112345678",
    delay = 300,
    executeAt = 1234567890,
    maxRetries = 3
}
```

### Setting Up Logging

To enable logging, configure lib.logger in your resource according to the ox_lib documentation.

---

## 🛡️ Error Handling & Validation

lib.tebex uses robust error handling and validation:

### Non-Crashing Error Handling
All validations use lib.print for safe error reporting that won't crash your script:

```lua
-- These will log detailed errors but never crash your script
if not hook then
    lib.print.error('Hook object is nil')
    return false
end

if type(cfxId) ~= 'string' then
    lib.print.error('CFX ID must be a string')
    return nil
end
```

### Handler Error Recovery
Handler errors are caught and logged with full context:

```lua
-- Handler execution is wrapped in pcall
local success, result = pcall(handler, hook, cfxId, args)
if not success then
    -- Error is logged with full context
    -- Execution continues gracefully
end
```

---

## 🧑‍💻 API Reference

### `lib.tebex.registerHook(data)`
Registers a new Tebex hook and its handlers.
- `data` (`table`): Must contain `id` (string), `label` (string), and any handler functions (`onPurchase`, `onRemove`, `onRenew`).
- **Returns:** The registered hook object, or `nil` on failure.
- **Logs:** Hook registration with handler details.

### `lib.tebex.getHook(id)`
Retrieve a registered hook by its ID.
- `id` (`string`): The unique hook identifier.
- **Returns:** The hook object, or `nil` if not found.

### `lib.tebex.getAllHooks()`
Get a table of all registered hooks.
- **Returns:** `table<string, TebexHook>`

### `lib.tebex.removeHook(id)`
Remove a registered hook by its ID.
- `id` (`string`): The unique hook identifier.
- **Logs:** Hook removal with hook details.

### `lib.tebex.executeAction(hookId, action, cfxId, args)`
Execute a Tebex action immediately.
- `hookId` (`string`): The hook identifier.
- `action` (`string`): The action type (`purchase`, `remove`, `renew`).
- `cfxId` (`string`): The CFX/FiveM player identifier.
- `args` (`table`): Command arguments.
- **Returns:** `TebexActionResult` or `nil` if hook not found.
- **Logs:** Action execution with results and timing.

### `lib.tebex.scheduleAction(hookId, action, cfxId, args, delay, maxRetries?)`
Schedule a Tebex action for future execution.
- `hookId` (`string`): The hook identifier.
- `action` (`string`): The action type (`purchase`, `remove`, `renew`).
- `cfxId` (`string`): The CFX/FiveM player identifier.
- `args` (`table`): Command arguments.
- `delay` (`number`): Delay in seconds before execution.
- `maxRetries` (`number`, optional): Maximum retry attempts (default: 3).
- **Returns:** Action ID (`string`) or `nil` if hook not found.
- **Logs:** Scheduling, execution, retries, and completion.

### `lib.tebex.getScheduledActions()`
Get all currently scheduled actions.
- **Returns:** `table<string, TebexScheduledAction>`

### `lib.tebex.getScheduledAction(actionId)`
Get a specific scheduled action by ID.
- `actionId` (`string`): The action identifier.
- **Returns:** `TebexScheduledAction` or `nil` if not found.

### `lib.tebex.cancelScheduledAction(actionId)`
Cancel a scheduled action.
- `actionId` (`string`): The action identifier.
- **Returns:** `boolean` indicating success.
- **Logs:** Action cancellation with details.

### `lib.tebex.getStats()`
Get system statistics and metrics.
- **Returns:** Statistics table with hook counts, scheduled actions, and performance data.

---

## 📝 Handler Function Signature

Each handler receives:
- `self`: The hook instance.
- `cfxId`: The CFX/FiveM player identifier (string).
- `args`: Table of command arguments (table).

Each handler can return a `TebexActionResult`:
- `success` (`boolean`): Whether the action succeeded.
- `message` (`string`, optional): Result message.
- `data` (`table`, optional): Additional result data.
- `retry` (`boolean`, optional): Whether to retry on failure.
- `retryDelay` (`number`, optional): Custom retry delay in seconds.

Example:
```lua
function(self, cfxId, args)
    -- self.id, self.label, etc. available
    local success = DoSomething(cfxId)
    return {
        success = success,
        message = success and "Operation completed" or "Operation failed",
        data = { cfxId = cfxId, timestamp = os.time() },
        retry = not success,
        retryDelay = 60
    }
end
```

---

## 📚 Example with Logging and Error Handling

```lua
-- Register hook (automatically logged and validated)
lib.tebex.registerHook{
    id = "premium",
    label = "Premium Package",
    onPurchase = function(self, cfxId, args)
        -- All validation is handled automatically
        local success = GrantPremiumAccess(cfxId)
        return {
            success = success,
            message = success and "Premium access granted" or "Failed to grant premium access",
            data = {
                package = "premium",
                cfxId = cfxId,
                grantedAt = os.time()
            },
            retry = not success,
            retryDelay = success and nil or 120
        }
    end
}

-- Schedule an action (automatically logged and validated)
local actionId = lib.tebex.scheduleAction("premium", "purchase", "110000109876543", {}, 300)

-- Execute immediately (automatically logged and validated)
local result = lib.tebex.executeAction("premium", "purchase", "110000109876543", {})
```

Now, from the server console:
```
purchase_premium 110000109876543
purchase_premium_scheduled 110000109876543 600
tebex_stats
tebex_cleanup
```

This will:
1. Execute your handler with comprehensive error handling and validation
2. Log the action to your configured service with detailed context
3. Time the execution and include performance metrics
4. Handle retries automatically if the handler indicates failure
5. Provide detailed statistics and cleanup capabilities
6. Never crash on invalid input - all errors are logged safely

---

## 🛠️ Advanced

### Debugging with Logs and Stats

You can use the registry, logging, and statistics to debug hooks:

```lua
-- Get system statistics
local stats = lib.tebex.getStats()
lib.print.info(json.encode(stats, { indent = true }))

-- Get all scheduled actions
local scheduled = lib.tebex.getScheduledActions()
for actionId, action in pairs(scheduled) do
    lib.print.info(("Scheduled: %s - %s for %s (retries: %d/%d)"):format(
        actionId, action.action, action.hookId, action.retries, action.maxRetries
    ))
end
```

### Custom Error Handling

```lua
lib.tebex.registerHook{
    id = "advanced",
    label = "Advanced Package",
    onPurchase = function(self, cfxId, args)
        -- Your logic here
        -- Any errors thrown will be automatically caught and logged with full context
        if not someCondition then
            error("Custom error message") -- This will be logged with full context
        end
        return {
            success = true,
            message = "Advanced package granted",
            data = { advanced = true }
        }
    end
}
```

### Scheduled Actions with Custom Retry Logic

```lua
-- Schedule with custom retry settings
local actionId = lib.tebex.scheduleAction("vip", "purchase", "12345", {}, 300, 5) -- 5 max retries

-- Handler with custom retry logic
lib.tebex.registerHook{
    id = "custom_retry",
    label = "Custom Retry Package",
    onPurchase = function(self, cfxId, args)
        local attempts = tonumber(args[2]) or 1
        local success = attempts > 3 -- Succeed after 3 attempts
        return {
            success = success,
            message = success and "Finally succeeded!" or ("Attempt %d failed"):format(attempts),
            retry = not success,
            retryDelay = 30 * attempts -- Increasing delay
        }
    end
}
```

---

**Happy automating your Tebex packages with comprehensive logging and robust error handling!**
