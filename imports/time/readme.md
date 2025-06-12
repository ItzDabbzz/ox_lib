# lib.time – Time Utility Functions

A comprehensive collection of time-related utility functions for FiveM/Lua applications. This module provides formatting, parsing, relative time calculations, uptime tracking, in-game time utilities, and timer functionality with automatic environment detection.

**Features dynamic assignment for environment-specific implementations and seamless fallbacks for different execution contexts.**

---

## ✨ Features

- **Cross-Platform Compatibility:** Automatically detects FiveM natives vs standard Lua environment
- **Time Formatting:** Convert timestamps to human-readable formats with custom patterns
- **Relative Time:** Generate "time ago" strings (e.g., "5 minutes ago", "2 hours ago")
- **Date/Time Parsing:** Parse structured date strings into Lua tables
- **Timestamp Arithmetic:** Add/subtract seconds, minutes, hours, and days from timestamps
- **Server Uptime Tracking:** Monitor and display server uptime in human-readable format
- **In-Game Time Integration:** Work with FiveM's in-game time system for day/night detection
- **Timer Utilities:** Create precise timers with start/stop/elapsed functionality
- **Automatic Fallbacks:** Gracefully handles missing FiveM natives with standard Lua alternatives

---

## 🚀 Usage

### 1. **Basic Time Operations**

```lua
-- Get current timestamp in different formats
local timestamp = lib.time.getTimestamp() -- "3:45 PM"
local datetime = lib.time.getDateTime()   -- "2024-01-15 15:45:30"
local unix = lib.time.getUnixTimestamp()  -- 1705339530

-- Format timestamps with custom patterns
local formatted = lib.time.format("%Y/%m/%d %H:%M", unix) -- "2024/01/15 15:45"
local dateOnly = lib.time.format("%B %d, %Y")             -- "January 15, 2024"
```

### 2. **Relative Time Calculations**

```lua
-- Calculate time differences
local pastTime = os.time() - 3600 -- 1 hour ago
local relative = lib.time.timeAgo(pastTime) -- "1 hour ago"

-- Examples of different time periods
local now = os.time()
print(lib.time.timeAgo(now - 30))    -- "30 seconds ago"
print(lib.time.timeAgo(now - 300))   -- "5 minutes ago"
print(lib.time.timeAgo(now - 7200))  -- "2 hours ago"
print(lib.time.timeAgo(now - 86400)) -- "1 day ago"
```

### 3. **Date/Time Parsing**

```lua
-- Parse structured date strings
local dateStr = "2024-01-15 15:45:30"
local parsed = lib.time.parseDateTime(dateStr)
-- Returns: { year = 2024, month = 1, day = 15, hour = 15, min = 45, sec = 30 }

if parsed then
    print("Year:", parsed.year)
    print("Month:", parsed.month)
    print("Day:", parsed.day)
end
```

### 4. **Timestamp Arithmetic**

```lua
local baseTime = os.time()

-- Add time units
local in5Minutes = lib.time.addMinutes(baseTime, 5)
local in2Hours = lib.time.addHours(baseTime, 2)
local tomorrow = lib.time.addDays(baseTime, 1)

-- Subtract time units (use negative values)
local fiveMinutesAgo = lib.time.addMinutes(baseTime, -5)
local yesterday = lib.time.addDays(baseTime, -1)

-- Combine operations
local complexTime = lib.time.addDays(
    lib.time.addHours(
        lib.time.addMinutes(baseTime, 30), 
        2
    ), 
    1
) -- 1 day, 2 hours, 30 minutes from now
```

### 5. **Server Uptime Tracking**

```lua
-- Get server uptime (automatically starts tracking on first call)
local uptime = lib.time.getUptime()
print("Server uptime:", uptime) -- "2 hours, 13 minutes"

-- Examples of different uptime formats
-- "45 seconds"
-- "5 minutes"
-- "1 hour, 30 minutes"
-- "2 days, 5 hours, 15 minutes"
```

### 6. **In-Game Time Integration**

```lua
-- Check day/night cycle (works with FiveM's in-game time)
if lib.time.isNight() then
    print("It's nighttime in-game (19:00 to 7:00)")
    -- Enable night-specific features
    SetWeatherTypePersist("CLEAR")
else
    print("It's daytime in-game (7:00 to 19:00)")
    -- Enable day-specific features
end

-- Get detailed in-game time
local gameTime = lib.time.getGameTime()
print(string.format("Game time: %02d:%02d:%02d", 
    gameTime.hour, gameTime.minute, gameTime.second))
```

### 7. **Timer Utilities**

```lua
-- Create and use timers
local timer = lib.time.newTimer()

timer:start()
-- ... do some work ...
timer:stop()

print("Operation took:", timer:elapsed(), "seconds")

-- Timer can be restarted
timer:start()
-- ... more work ...
print("Current elapsed time:", timer:elapsed()) -- While still running
timer:stop()
```

---

## 📊 Environment Detection

The module automatically detects the execution environment and uses appropriate time sources:

### FiveM Environment
- Uses `GetLocalTime()` native for real-world time
- Uses `GetClockHours()`, `GetClockMinutes()`, `GetClockSeconds()` for in-game time
- Provides accurate day/night cycle detection

### Standard Lua Environment
- Falls back to `os.date("*t")` for time operations
- Uses system time for all time-related functions
- Maintains full compatibility with all features

```lua
-- This works in both environments automatically
local timestamp = lib.time.getTimestamp() -- Always works

-- In-game time functions gracefully fall back to system time
local isNight = lib.time.isNight() -- Works everywhere
```

---

## 🧑‍💻 API Reference

### **Basic Time Functions**

#### `lib.time.getTimestamp()`
Returns the current local time as a formatted 12-hour string.
- **Returns:** `string` - Time in "HH:MM AM/PM" format
- **Example:** `"3:45 PM"`

#### `lib.time.getDateTime()`
Returns the current local date and time in ISO-like format.
- **Returns:** `string` - DateTime in "YYYY-MM-DD HH:MM:SS" format
- **Example:** `"2024-01-15 15:45:30"`

#### `lib.time.getUnixTimestamp()`
Returns the current Unix timestamp.
- **Returns:** `number` - Seconds since Unix epoch
- **Example:** `1705339530`

#### `lib.time.format(pattern, time?)`
Formats a timestamp using a custom pattern.
- `pattern` (`string`): The os.date pattern (e.g., "%Y/%m/%d %H:%M")
- `time` (`number`, optional): Unix timestamp (defaults to current time)
- **Returns:** `string` - Formatted date/time string
- **Example:** `lib.time.format("%B %d, %Y")` → `"January 15, 2024"`

### **Relative Time Functions**

#### `lib.time.timeAgo(pastTimestamp)`
Returns a human-readable relative time string.
- `pastTimestamp` (`number`): Unix timestamp in the past
- **Returns:** `string` - Relative time description
- **Examples:**
  - `"5 seconds ago"`
  - `"1 minute ago"`
  - `"2 hours ago"`
  - `"3 days ago"`
  - `"in the future"` (for future timestamps)

### **Parsing Functions**

#### `lib.time.parseDateTime(str)`
Parses a date string in "YYYY-MM-DD HH:MM:SS" format.
- `str` (`string`): Date string to parse
- **Returns:** `table?` - Parsed date table or `nil` if invalid
- **Table Structure:**
  ```lua
  {
      year = 2024,
      month = 1,
      day = 15,
      hour = 15,
      min = 45,
      sec = 30
  }
  ```

### **Timestamp Arithmetic Functions**

#### `lib.time.addSeconds(ts, n)`
Adds or subtracts seconds from a timestamp.
- `ts` (`number`): Base Unix timestamp
- `n` (`number`): Seconds to add (negative to subtract)
- **Returns:** `number` - Modified timestamp

#### `lib.time.addMinutes(ts, n)`
Adds or subtracts minutes from a timestamp.
- `ts` (`number`): Base Unix timestamp
- `n` (`number`): Minutes to add (negative to subtract)
- **Returns:** `number` - Modified timestamp

#### `lib.time.addHours(ts, n)`
Adds or subtracts hours from a timestamp.
- `ts` (`number`): Base Unix timestamp
- `n` (`number`): Hours to add (negative to subtract)
- **Returns:** `number` - Modified timestamp

#### `lib.time.addDays(ts, n)`
Adds or subtracts days from a timestamp.
- `ts` (`number`): Base Unix timestamp
- `n` (`number`): Days to add (negative to subtract)
- **Returns:** `number` - Modified timestamp

### **Server Uptime Functions**

#### `lib.time.getUptime()`
Returns server uptime as a human-readable string.
- **Returns:** `string` - Uptime description
- **Examples:**
  - `"45 seconds"`
  - `"5 minutes"`
  - `"1 hour, 30 minutes"`
  - `"2 days, 5 hours, 15 minutes"`
- **Note:** Automatically starts tracking on first call

### **In-Game Time Functions**

#### `lib.time.isNight()`
Checks if it's currently nighttime in-game.
- **Returns:** `boolean` - `true` if night (19:00 to 7:00), `false` otherwise
- **Note:** Uses FiveM natives when available, system time otherwise

#### `lib.time.isDay()`
Checks if it's currently daytime in-game.
- **Returns:** `boolean` - `true` if day (7:00 to 19:00), `false` otherwise
- **Note:** Uses FiveM natives when available, system time otherwise

#### `lib.time.getGameTime()`
Returns the current in-game time as a structured table.
- **Returns:** `table` - Time structure
- **Table Structure:**
  ```lua
  {
      hour = 15,
      minute = 45,
      second = 30
  }
  ```

### **Timer Functions**

#### `lib.time.newTimer()`
Creates a new timer object for precise time measurement.
- **Returns:** `table` - Timer object with methods
- **Timer Methods:**
  - `timer:start()` - Start the timer
  - `timer:stop()` - Stop the timer
  - `timer:elapsed()` - Get elapsed time in seconds

**Timer Usage Example:**
```lua
local timer = lib.time.newTimer()
timer:start()
-- ... work ...
local elapsed = timer:elapsed() -- Get time while running
timer:stop()
local finalTime = timer:elapsed() -- Get final time
```

---

## 📚 Practical Examples

### **Event Scheduling System**

```lua
-- Schedule events based on time calculations
local function scheduleEvent(delayMinutes, callback)
    local executeAt = lib.time.addMinutes(lib.time.getUnixTimestamp(), delayMinutes)
    
    CreateThread(function()
        while lib.time.getUnixTimestamp() < executeAt do
            Wait(1000)
        end
        callback()
    end)
end

-- Usage
scheduleEvent(30, function()
    print("Event executed 30 minutes later!")
end)
```

### **Activity Logger with Timestamps**

```lua
local activityLog = {}

local function logActivity(playerName, action)
    local entry = {
        player = playerName,
        action = action,
        timestamp = lib.time.getUnixTimestamp(),
        formatted = lib.time.getDateTime()
    }
    
    table.insert(activityLog, entry)
    print(string.format("[%s] %s: %s", entry.formatted, playerName, action))
end

local function getRecentActivity(minutes)
    local cutoff = lib.time.addMinutes(lib.time.getUnixTimestamp(), -minutes)
    local recent = {}
    
    for _, entry in ipairs(activityLog) do
        if entry.timestamp >= cutoff then
            entry.timeAgo = lib.time.timeAgo(entry.timestamp)
            table.insert(recent, entry)
        end
    end
    
    return recent
end
```

### **Day/Night Cycle Handler**

```lua
local lastTimeState = nil

CreateThread(function()
    while true do
        local isNight = lib.time.isNight()
        
        if lastTimeState ~= isNight then
            if isNight then
                print("Night has fallen...")
                -- Enable night features
                TriggerEvent('time:nightfall')
            else
                print("Dawn is breaking...")
                -- Enable day features
                TriggerEvent('time:daybreak')
            end
            lastTimeState = isNight
        end
        
        Wait(60000) -- Check every minute
    end
end)
```

### **Performance Monitoring**

```lua
local function monitorFunction(func, name)
    return function(...)
        local timer = lib.time.newTimer()
        timer:start()
        
        local results = {func(...)}
        
        timer:stop()
        local elapsed = timer:elapsed()
        
        if elapsed > 0.1 then -- Log slow operations
            print(string.format("SLOW: %s took %.3f seconds", name, elapsed))
        end
        
        return table.unpack(results)
    end
end

-- Usage
local monitoredFunction = monitorFunction(someExpensiveFunction, "ExpensiveOperation")
```

### **Session Duration Tracker**

```lua
local playerSessions = {}

AddEventHandler('playerConnecting', function()
    local source = source
    playerSessions[source] = {
        joinTime = lib.time.getUnixTimestamp(),
        joinFormatted = lib.time.getDateTime()
    }
end)

AddEventHandler('playerDropped', function()
    local source = source
    local session = playerSessions[source]
    
    if session then
        local duration = lib.time.getUnixTimestamp() - session.joinTime
        local durationStr = lib.time.timeAgo(session.joinTime)
        
        print(string.format("Player %s played for %s", GetPlayerName(source), durationStr))
        playerSessions[source] = nil
    end
end)
```

---

## 🛠️ Advanced Usage

### **Custom Time Formatters**

```lua
-- Create reusable formatters
local formatters = {
    logFormat = function(timestamp)
        return lib.time.format("[%Y-%m-%d %H:%M:%S]", timestamp)
    end,
    
    userFriendly = function(timestamp)
        return lib.time.format("%B %d, %Y at %I:%M %p", timestamp)
    end,
    
    filename = function(timestamp)
        return lib.time.format("%Y%m%d_%H%M%S", timestamp)
    end
}

-- Usage
local now = lib.time.getUnixTimestamp()
print(formatters.logFormat(now))      -- "[2024-01-15 15:45:30]"
print(formatters.userFriendly(now))   -- "January 15, 2024 at 3:45 PM"
print(formatters.filename(now))       -- "20240115_154530"
```

### **Time-Based Caching System**

```lua
local cache = {}

local function getCachedData(key, ttlMinutes, fetchFunction)
    local entry = cache[key]
    local now = lib.time.getUnixTimestamp()
    
    if entry and (now - entry.timestamp) < (ttlMinutes * 60) then
        -- Cache hit
        return entry.data
    end
    
    -- Cache miss or expired
    local data = fetchFunction()
    cache[key] = {
        data = data,
        timestamp = now,
        expires = lib.time.addMinutes(now, ttlMinutes)
    }
    
    return data
end

-- Usage
local function getExpensiveData()
    -- Simulate expensive operation
    Wait(1000)
    return { value = math.random(1000) }
end

local data = getCachedData("expensive_data", 5, getExpensiveData) -- Cache for 5 minutes
```

### **Scheduled Task Manager**

```lua
local scheduledTasks = {}
local taskIdCounter = 0

local function scheduleTask(delay, callback, recurring)
    taskIdCounter = taskIdCounter + 1
    local taskId = taskIdCounter
    
    local executeAt = lib.time.addSeconds(lib.time.getUnixTimestamp(), delay)
    
    scheduledTasks[taskId] = {
        id = taskId,
        executeAt = executeAt,
        callback = callback,
        recurring = recurring,
        delay = delay,
        created = lib.time.getDateTime()
    }
    
    return taskId
end

local function cancelTask(taskId)
    scheduledTasks[taskId] = nil
end

-- Task executor thread
CreateThread(function()
    while true do
        local now = lib.time.getUnixTimestamp()
        
        for taskId, task in pairs(scheduledTasks) do
            if now >= task.executeAt then
                -- Execute task
                local success, err = pcall(task.callback)
                
                if not success then
                    print("Task error:", err)
                end
                
                if task.recurring then
                    -- Reschedule
                    task.executeAt = lib.time.addSeconds(now, task.delay)
                else
                    -- Remove one-time task
                    scheduledTasks[taskId] = nil
                end
            end
        end
        
        Wait(1000) -- Check every second
    end
end)

-- Usage examples
scheduleTask(60, function()
    print("One-time task executed after 1 minute")
end, false)

scheduleTask(300, function()
    print("Recurring task executed every 5 minutes")
end, true)
```

### **Time Zone Handling**

```lua
-- Utility for handling different time zones
local timeZones = {
    EST = -5,  -- Eastern Standard Time
    PST = -8,  -- Pacific Standard Time
    GMT = 0,   -- Greenwich Mean Time
    CET = 1,   -- Central European Time
    JST = 9    -- Japan Standard Time
}

local function convertToTimeZone(timestamp, fromZone, toZone)
    local fromOffset = timeZones[fromZone] or 0
    local toOffset = timeZones[toZone] or 0
    local difference = (toOffset - fromOffset) * 3600 -- Convert hours to seconds
    
    return timestamp + difference
end

local function formatInTimeZone(timestamp, timeZone, pattern)
    local offset = timeZones[timeZone] or 0
    local adjustedTime = timestamp + (offset * 3600)
    return lib.time.format(pattern or "%Y-%m-%d %H:%M:%S", adjustedTime) .. " " .. timeZone
end

-- Usage
local utcTime = lib.time.getUnixTimestamp()
local estTime = convertToTimeZone(utcTime, "GMT", "EST")
local pstTime = convertToTimeZone(utcTime, "GMT", "PST")

print("UTC:", formatInTimeZone(utcTime, "GMT"))
print("EST:", formatInTimeZone(estTime, "EST"))
print("PST:", formatInTimeZone(pstTime, "PST"))
```

### **Performance Benchmarking Suite**

```lua
local benchmarks = {}

local function benchmark(name, iterations, func)
    local timer = lib.time.newTimer()
    local results = {}
    
    -- Warm up
    for i = 1, math.min(iterations, 100) do
        func()
    end
    
    -- Actual benchmark
    timer:start()
    for i = 1, iterations do
        local iterTimer = lib.time.newTimer()
        iterTimer:start()
        func()
        iterTimer:stop()
        results[i] = iterTimer:elapsed()
    end
    timer:stop()
    
    -- Calculate statistics
    local totalTime = timer:elapsed()
    local avgTime = totalTime / iterations
    local minTime = math.min(table.unpack(results))
    local maxTime = math.max(table.unpack(results))
    
    benchmarks[name] = {
        name = name,
        iterations = iterations,
        totalTime = totalTime,
        avgTime = avgTime,
        minTime = minTime,
        maxTime = maxTime,
        timestamp = lib.time.getDateTime()
    }
    
    return benchmarks[name]
end

local function printBenchmarkResults(name)
    local result = benchmarks[name]
    if not result then return end
    
    print(string.format("Benchmark: %s", result.name))
    print(string.format("  Iterations: %d", result.iterations))
    print(string.format("  Total Time: %.6f seconds", result.totalTime))
    print(string.format("  Average: %.6f seconds", result.avgTime))
    print(string.format("  Min: %.6f seconds", result.minTime))
    print(string.format("  Max: %.6f seconds", result.maxTime))
    print(string.format("  Tested: %s", result.timestamp))
end

-- Usage
benchmark("string_concat", 10000, function()
    local str = ""
    for i = 1, 100 do
        str = str .. tostring(i)
    end
end)

printBenchmarkResults("string_concat")
```

---

## 🔧 Configuration and Customization

### **Custom Time Sources**

You can extend the module with custom time sources:

```lua
-- Example: Custom time source for testing
local function createMockTimeSource(baseTime, speedMultiplier)
    local startTime = os.clock()
    local mockBaseTime = baseTime or lib.time.getUnixTimestamp()
    local speed = speedMultiplier or 1
    
    return function()
        local elapsed = (os.clock() - startTime) * speed
        local mockTime = mockBaseTime + elapsed
        local date = os.date("*t", mockTime)
        return date.year, date.month, date.day, date.hour, date.min, date.sec
    end
end

-- Usage in testing scenarios
local mockTime = createMockTimeSource(lib.time.getUnixTimestamp(), 60) -- 60x speed
```

### **Custom Formatters**

```lua
-- Extend with custom relative time formatters
local function customTimeAgo(pastTimestamp, options)
    options = options or {}
    local now = lib.time.getUnixTimestamp()
    local diff = now - pastTimestamp
    
    if diff < 0 then
        return options.futureText or "in the future"
    end
    
    local units = {
        { 31536000, "year", "years" },
        { 2592000, "month", "months" },
        { 604800, "week", "weeks" },
        { 86400, "day", "days" },
        { 3600, "hour", "hours" },
        { 60, "minute", "minutes" },
        { 1, "second", "seconds" }
    }
    
    for _, unit in ipairs(units) do
        local seconds, singular, plural = unit[1], unit[2], unit[3]
        if diff >= seconds then
            local count = math.floor(diff / seconds)
            local unitName = count == 1 and singular or plural
            
            if options.short then
                return string.format("%d%s", count, unitName:sub(1, 1))
            else
                return string.format("%d %s ago", count, unitName)
            end
        end
    end
    
    return options.justNow or "just now"
end

-- Usage
local pastTime = lib.time.getUnixTimestamp() - 3661
print(customTimeAgo(pastTime))                    -- "1 hour ago"
print(customTimeAgo(pastTime, { short = true }))  -- "1h"
```

---

## 🐛 Troubleshooting

### **Common Issues**

#### **Time Zone Inconsistencies**
```lua
-- Always use UTC for storage, local time for display
local function storeTimestamp()
    return lib.time.getUnixTimestamp() -- Always UTC
end

local function displayTimestamp(timestamp)
    return lib.time.format("%Y-%m-%d %H:%M:%S", timestamp) -- Local display
end
```

#### **Performance with Frequent Time Calls**
```lua
-- Cache time values for performance-critical code
local timeCache = {
    value = 0,
    lastUpdate = 0,
    ttl = 1 -- 1 second cache
}

local function getCachedTime()
    local now = os.clock()
    if (now - timeCache.lastUpdate) > timeCache.ttl then
        timeCache.value = lib.time.getUnixTimestamp()
        timeCache.lastUpdate = now
    end
    return timeCache.value
end
```

#### **Memory Leaks with Timers**
```lua
-- Always clean up timers and references
local activeTimers = {}

local function createManagedTimer(name)
    local timer = lib.time.newTimer()
    activeTimers[name] = timer
    return timer
end

local function cleanupTimer(name)
    activeTimers[name] = nil
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for name, timer in pairs(activeTimers) do
            if timer.stop then
                timer:stop()
            end
        end
        activeTimers = {}
    end
end)
```

---

## 📖 Best Practices

### **1. Use Appropriate Time Functions**
```lua
-- For logging and storage
local logEntry = {
    message = "User action",
    timestamp = lib.time.getUnixTimestamp(), -- For calculations
    readable = lib.time.getDateTime()        -- For human reading
}

-- For user interfaces
local displayTime = lib.time.timeAgo(logEntry.timestamp) -- "5 minutes ago"
```

### **2. Handle Time Arithmetic Carefully**
```lua
-- Good: Use the provided arithmetic functions
local futureTime = lib.time.addHours(lib.time.getUnixTimestamp(), 24)

-- Avoid: Manual arithmetic (error-prone)
-- local futureTime = lib.time.getUnixTimestamp() + (24 * 60 * 60)
```

### **3. Validate Parsed Time Data**
```lua
local function safeParseDateTime(dateStr)
    local parsed = lib.time.parseDateTime(dateStr)
    
    if not parsed then
        lib.print.warn("Failed to parse date string:", dateStr)
        return nil
    end
    
    -- Additional validation
    if parsed.year < 1970 or parsed.year > 2100 then
        lib.print.warn("Invalid year in date:", parsed.year)
        return nil
    end
    
    return parsed
end
```

### **4. Use Timers for Performance Monitoring**
```lua
-- Wrap expensive operations with timing
local function timedOperation(name, func, ...)
    local timer = lib.time.newTimer()
    timer:start()
    
    local results = {func(...)}
    
    timer:stop()
    local elapsed = timer:elapsed()
    
    if elapsed > 0.05 then -- Log operations taking more than 50ms
        lib.print.warn(string.format("%s took %.3fs", name, elapsed))
    end
    
    return table.unpack(results)
end
```

---

**The lib.time module provides a comprehensive, cross-platform solution for all your time-related needs in FiveM and Lua applications!**