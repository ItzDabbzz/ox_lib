--- @class lib.time
--- @author ItzDabbzz
--- @version 1.1.0
--- @description
---     A collection of useful time-related functions for FiveM/Lua.
---     Includes formatting, parsing, relative time, uptime, in-game time, and timer utilities.
---     Uses dynamic assignment for environment-specific implementations.

---@class OxTime
lib.time = {}

-- Dynamic selector for local time source (real-world or in-game)
local function selectGetLocalTime()
    if GetLocalTime then
        -- FiveM native (returns year, month, day, hour, minute, second)
        return function()
            return GetLocalTime()
        end
    else
        -- Fallback to os.date (returns a table)
        return function()
            local t = os.date("*t")
            return t.year, t.month, t.day, t.hour, t.min, t.sec
        end
    end
end

local getLocalTimeSelected = selectGetLocalTime()

--- Returns the current local time as a formatted string "HH:MM AM/PM".
---@return string
local function getTimestamp()
    local meridiem = 'AM'
    local year, month, day, hour, minute, second = getLocalTimeSelected()

    if hour >= 13 then
        hour = hour - 12
        meridiem = 'PM'
    elseif hour == 12 then
        meridiem = 'PM'
    elseif hour == 0 then
        hour = 12
    end

    if minute <= 9 then
        minute = '0' .. minute
    end

    return ('%d:%s %s'):format(hour, minute, meridiem)
end

lib.time.getTimestamp = getTimestamp

--- Returns the current local date and time as "YYYY-MM-DD HH:MM:SS".
---@return string
local function getDateTime()
    local year, month, day, hour, minute, second = getLocalTimeSelected()
    return ('%04d-%02d-%02d %02d:%02d:%02d'):format(year, month, day, hour, minute, second)
end

lib.time.getDateTime = getDateTime

--- Returns the current Unix timestamp (seconds since epoch).
---@return number
function lib.time.getUnixTimestamp()
    return os.time()
end

--- Returns a formatted date/time string using a custom Lua os.date pattern.
---@param pattern string The os.date pattern (e.g. "%Y/%m/%d %H:%M").
---@param time number? Optional unix timestamp (defaults to now).
---@return string
function lib.time.format(pattern, time)
    return os.date(pattern, time or os.time())
end

--- Returns a human-readable relative time string (e.g. "5 minutes ago").
---@param pastTimestamp number The unix timestamp in the past.
---@return string
function lib.time.timeAgo(pastTimestamp)
    local now = os.time()
    local diff = now - pastTimestamp

    if diff < 0 then
        return "in the future"
    end

    if diff < 60 then
        return diff == 1 and "1 second ago" or ('%d seconds ago'):format(diff)
    elseif diff < 3600 then
        local m = math.floor(diff / 60)
        return m == 1 and "1 minute ago" or ('%d minutes ago'):format(m)
    elseif diff < 86400 then
        local h = math.floor(diff / 3600)
        return h == 1 and "1 hour ago" or ('%d hours ago'):format(h)
    else
        local d = math.floor(diff / 86400)
        return d == 1 and "1 day ago" or ('%d days ago'):format(d)
    end
end

--- Parses a date string in "YYYY-MM-DD HH:MM:SS" format to a table.
---@param str string
---@return table?
function lib.time.parseDateTime(str)
    local y, m, d, H, M, S = str:match("(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)")

    if not (y and m and d and H and M and S) then
        return nil
    end

    return {
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(H),
        min = tonumber(M),
        sec = tonumber(S)
    }
end

--- Adds or subtracts seconds to a given unix timestamp.
---@param ts number The base unix timestamp.
---@param n number Number of seconds to add (negative to subtract).
---@return number
function lib.time.addSeconds(ts, n)
    return ts + n
end

--- Adds or subtracts minutes to a given unix timestamp.
---@param ts number The base unix timestamp.
---@param n number Number of minutes to add (negative to subtract).
---@return number
function lib.time.addMinutes(ts, n)
    return ts + n * 60
end

--- Adds or subtracts hours to a given unix timestamp.
---@param ts number The base unix timestamp.
---@param n number Number of hours to add (negative to subtract).
---@return number
function lib.time.addHours(ts, n)
    return ts + n * 3600
end

--- Adds or subtracts days to a given unix timestamp.
---@param ts number The base unix timestamp.
---@param n number Number of days to add (negative to subtract).
---@return number
function lib.time.addDays(ts, n)
    return ts + n * 86400
end

--- Returns the server uptime as a human-readable string (e.g. "2 hours, 13 minutes").
---@return string
local function getUptime()
    if not lib.time._startTime then
        lib.time._startTime = os.time()
    end

    local diff = os.time() - lib.time._startTime
    local d = math.floor(diff / 86400)
    local h = math.floor((diff % 86400) / 3600)
    local m = math.floor((diff % 3600) / 60)
    local s = diff % 60

    local parts = {}

    if d > 0 then
        parts[#parts + 1] = ('%d day%s'):format(d, d ~= 1 and "s" or "")
    end

    if h > 0 then
        parts[#parts + 1] = ('%d hour%s'):format(h, h ~= 1 and "s" or "")
    end

    if m > 0 then
        parts[#parts + 1] = ('%d minute%s'):format(m, m ~= 1 and "s" or "")
    end

    if s > 0 and #parts == 0 then
        parts[#parts + 1] = ('%d second%s'):format(s, s ~= 1 and "s" or "")
    end

    return table.concat(parts, ", ")
end

lib.time.getUptime = getUptime

-- Dynamic selector for in-game time (FiveM) or fallback
local function selectGetGameTime()
    if GetClockHours and GetClockMinutes and GetClockSeconds then
        return function()
            return GetClockHours(), GetClockMinutes(), GetClockSeconds()
        end
    else
        -- Fallback to system time
        return function()
            local t = os.date("*t")
            return t.hour, t.min, t.sec
        end
    end
end

local getGameTimeSelected = selectGetGameTime()

--- Returns whether it's currently night in-game (19:00 to 7:00).
---@return boolean
function lib.time.isNight()
    local hour = select(1, getGameTimeSelected())
    return (hour >= 19 or hour < 7)
end

--- Returns whether it's currently day in-game (7:00 to 19:00).
---@return boolean
function lib.time.isDay()
    local hour = select(1, getGameTimeSelected())
    return (hour >= 7 and hour < 19)
end

--- Returns the current in-game time as a table { hour, minute, second }.
---@return table
function lib.time.getGameTime()
    local hour, minute, second = getGameTimeSelected()
    return { hour = hour, minute = minute, second = second }
end

--- Timer utility: Creates a new timer object.
---@return table Timer object with :start(), :stop(), :elapsed()
function lib.time.newTimer()
    local timer = {
        _start = nil,
        _elapsed = 0,
        start = function(self)
            self._start = os.clock()
        end,
        stop = function(self)
            if self._start then
                self._elapsed = os.clock() - self._start
                self._start = nil
            end
        end,
        elapsed = function(self)
            if self._start then
                return os.clock() - self._start
            else
                return self._elapsed
            end
        end
    }
    return timer
end

return lib.time
