--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxHacks
lib.hacks = {}

local minigameFunctions = {
    ['ps-circle'] = function(cb, ...)
        exports['ps-ui']:Circle(cb, ...)
    end,

    ['ps-maze'] = function(cb, ...)
        exports['ps-ui']:Maze(cb, ...)
    end,

    ['ps-varhack'] = function(cb, ...)
        exports['ps-ui']:VarHack(cb, ...)
    end,

    ['ps-thermite'] = function(cb, ...)
        exports['ps-ui']:Thermite(cb, ...)
    end,

    ['ps-scrambler'] = function(cb, ...)
        exports['ps-ui']:Scrambler(cb, ...)
    end,

    ['memorygame-thermite'] = function(cb, correctBlocks, incorrectBlocks, timetoShow, timetoLose)
        local successCallback = function() cb(true) end
        local failCallback = function() cb(false) end
        exports['memorygame']:thermiteminigame(correctBlocks, incorrectBlocks, timetoShow, timetoLose, successCallback, failCallback)
    end,

    ['ran-memorycard'] = function(cb, ...)
        cb(exports['ran-minigames']:MemoryCard(...))
    end,

    ['ran-openterminal'] = function(cb, ...)
        cb(exports['ran-minigames']:OpenTerminal(...))
    end,

    ['hacking-opengame'] = function(cb, puzzleDuration, puzzleLength, puzzleAmount)
        local successCallback = function(success) cb(success) end
        exports['hacking']:OpenHackingGame(puzzleDuration, puzzleLength, puzzleAmount, successCallback)
    end,

    ['howdy-begin'] = function(cb, ...)
        cb(exports['howdy-hackminigame']:Begin(...))
    end,

    ['sn-memorygame'] = function(cb, ...)
        cb(exports['SN-Hacking']:MemoryGame(...))
    end,

    ['sn-skillcheck'] = function(cb, ...)
        cb(exports['SN-Hacking']:SkillCheck(...))
    end,

    ['sn-thermite'] = function(cb, ...)
        cb(exports['SN-Hacking']:Thermite(...))
    end,

    ['sn-keypad'] = function(cb, ...)
        cb(exports['SN-Hacking']:KeyPad(...))
    end,

    ['sn-colorpicker'] = function(cb, ...)
        cb(exports['SN-Hacking']:ColorPicker(...))
    end,

    ['sn-skillbar'] = function(cb, ...)
        cb(exports['SN-Hacking']:SkillBar(...))
    end,

    ['sn-shownumber'] = function(cb, ...)
        cb(exports['SN-Hacking']:ShowNumber(...))
    end,

    ['sn-memorycards'] = function(cb, ...)
        cb(exports['SN-Hacking']:MemoryCards(...))
    end,

    ['sn-mines'] = function(cb, ...)
        cb(exports['SN-Hacking']:Mines(...))
    end,

    ['rm-typinggame'] = function(cb, ...)
        cb(exports['rm_minigames']:typingGame(...))
    end,

    ['rm-timedlockpick'] = function(cb, ...)
        cb(exports['rm_minigames']:timedLockpick(...))
    end,

    ['rm-timedaction'] = function(cb, ...)
        cb(exports['rm_minigames']:timedAction(...))
    end,

    ['rm-quicktimeevent'] = function(cb, ...)
        cb(exports['rm_minigames']:quickTimeEvent(...))
    end,

    ['rm-combinationlock'] = function(cb, ...)
        cb(exports['rm_minigames']:combinationLock(...))
    end,

    ['rm-buttonmashing'] = function(cb, ...)
        cb(exports['rm_minigames']:buttonMashing(...))
    end,

    ['rm-angledlockpick'] = function(cb, ...)
        cb(exports['rm_minigames']:angledLockpick(...))
    end,

    ['rm-fingerprint'] = function(cb, ...)
        cb(exports['rm_minigames']:fingerPrint(...))
    end,

    ['rm-circleClick'] = function(cb, ...)
        cb(exports['rm_minigames']:circleClick(...))
    end,

    ['rm-hotwirehack'] = function(cb, ...)
        cb(exports['rm_minigames']:hotwireHack(...))
    end,

    ['rm-hackerminigame'] = function(cb, ...)
        cb(exports['rm_minigames']:hackerMinigame(...))
    end,

    ['rm-safecrack'] = function(cb, ...)
        cb(exports['rm_minigames']:safeCrack(...))
    end,

    ['bl-circlesum'] = function(cb, ...)
        cb(exports['bl_ui']:CircleSum(...))
    end,

    ['bl-digitdazzle'] = function(cb, ...)
        cb(exports['bl_ui']:DigitDazzle(...))
    end,

    ['bl-lightsout'] = function(cb, ...)
        cb(exports['bl_ui']:LightsOut(...))
    end,

    ['bl-minesweeper'] = function(cb, ...)
        cb(exports['bl_ui']:MineSweeper(...))
    end,

    ['bl-pathfind'] = function(cb, ...)
        cb(exports['bl_ui']:PathFind(...))
    end,

    ['bl-printlock'] = function(cb, ...)
        cb(exports['bl_ui']:PrintLock(...))
    end,

    ['bl-untangle'] = function(cb, ...)
        cb(exports['bl_ui']:Untangle(...))
    end,

    ['bl-wavematch'] = function(cb, ...)
        cb(exports['bl_ui']:WaveMatch(...))
    end,

    ['bl-wordwiz'] = function(cb, ...)
        cb(exports['bl_ui']:WordWiz(...))
    end,

    ['bd-lockpick'] = function(cb, ...)
        cb(exports['bd-minigames']:Lockpick(...))
    end,

    ['bd-chopping'] = function(cb, ...)
        cb(exports['bd-minigames']:Chopping(...))
    end,

    ['bd-pincracker'] = function(cb, ...)
        cb(exports['bd-minigames']:PinCracker(...))
    end,

    ['bd-roofrunning'] = function(cb, ...)
        cb(exports['bd-minigames']:RoofRunning(...))
    end,

    ['bd-thermite'] = function(cb, ...)
        cb(exports['bd-minigames']:Thermite(...))
    end,

    ['bd-terminal'] = function(cb, ...)
        cb(exports['bd-minigames']:Terminal(...))
    end,

    ['gl-firewall-pulse'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartFirewallPulse(...))
    end,

    ['gl-backdoor-sequence'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartBackdoorSequence(...))
    end,

    ['gl-circuit-rhythm'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartCircuitRhythm(...))
    end,

    ['gl-surge-override'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartSurgeOverride(...))
    end,

    ['gl-circuit-breaker'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartCircuitBreaker(...))
    end,

    ['gl-data-crack'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartDataCrack(...))
    end,

    ['gl-brute-force'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartBruteForce(...))
    end,

    ['gl-var-hack'] = function(cb, ...)
        cb(exports['glitch-minigames']:StartVarHack(...))
    end,

    ['pure-numbercounter'] = function(cb, ...)
        cb(exports['pure-minigames']:numberCounter(...))
    end,

    ['simonsays'] = function(cb, ...)
        cb(exports['simonsays']:StartSimonSays(...))
    end,
}

--- Starts a hacking minigame based on the specified type and arguments.
--- This function dynamically calls the appropriate minigame function based on the provided type.
--- The function name should match the minigame's corresponding export name.
---@param hackType string The type of hacking minigame to start (e.g., 'ps-circle', 'ps-maze', 'mhacking-start', etc.)
---@param callback function The callback function to handle success or failure (optional).
---@param ... any Additional arguments to pass to the minigame function.
function lib.hacks.start(hackType, callback, ...)
    if type(hackType) ~= 'string' then
        lib.print.error('Hack type must be a string')
        return
    end

    if not callback or type(callback) ~= 'function' then
        lib.print.error('Callback must be a function')
        return
    end

    local minigameFunction = minigameFunctions[hackType]

    if not minigameFunction then
        lib.print.error(('Unknown hacking minigame type: %s'):format(hackType))
        return
    end

    -- Check if the required resource is available
    local resourceName = hackType:match('^([^%-]+)')
    if resourceName and GetResourceState(resourceName) ~= 'started' then
        lib.print.warn(('Resource %s is not started for hack type: %s'):format(resourceName, hackType))
        if callback then
            callback(false)
        end
        return
    end

    -- Execute the minigame with error handling
    local success, err = pcall(minigameFunction, callback, ...)

    if not success then
        lib.print.error(('Failed to start hack %s: %s'):format(hackType, err))
        if callback then
            callback(false)
        end
    end
end

--- Get all available hack types
---@return string[] hackTypes Array of available hack type identifiers
function lib.hacks.getAvailable()
    local available = {}

    for hackType, _ in pairs(minigameFunctions) do
        local resourceName = hackType:match('^([^%-]+)')
        if not resourceName or GetResourceState(resourceName) == 'started' then
            available[#available + 1] = hackType
        end
    end

    return available
end

--- Check if a specific hack type is available
---@param hackType string The hack type to check
---@return boolean available Whether the hack type is available
function lib.hacks.isAvailable(hackType)
    if not minigameFunctions[hackType] then
        return false
    end

    local resourceName = hackType:match('^([^%-]+)')
    if resourceName and GetResourceState(resourceName) ~= 'started' then
        return false
    end

    return true
end

--- Register a custom hack type
---@param hackType string The identifier for the hack type
---@param hackFunction function The function to execute for this hack type
function lib.hacks.register(hackType, hackFunction)
    if type(hackType) ~= 'string' then
        lib.print.error('Hack type must be a string')
        return false
    end

    if type(hackFunction) ~= 'function' then
        lib.print.error('Hack function must be a function')
        return false
    end

    if minigameFunctions[hackType] then
        lib.print.warn(('Overriding existing hack type: %s'):format(hackType))
    end

    minigameFunctions[hackType] = hackFunction
    lib.print.info(('Registered hack type: %s'):format(hackType))
    return true
end

--- Remove a registered hack type
---@param hackType string The hack type to remove
---@return boolean success Whether the hack type was removed
function lib.hacks.unregister(hackType)
    if not minigameFunctions[hackType] then
        lib.print.warn(('Hack type not found: %s'):format(hackType))
        return false
    end

    minigameFunctions[hackType] = nil
    lib.print.info(('Unregistered hack type: %s'):format(hackType))
    return true
end

--- Get information about all registered hack types
---@return table hackInfo Information about registered hack types
function lib.hacks.getInfo()
    local info = {
        total = 0,
        available = 0,
        unavailable = 0,
        types = {}
    }

    for hackType, _ in pairs(minigameFunctions) do
        info.total = info.total + 1

        local resourceName = hackType:match('^([^%-]+)')
        local isAvailable = not resourceName or GetResourceState(resourceName) == 'started'

        if isAvailable then
            info.available = info.available + 1
        else
            info.unavailable = info.unavailable + 1
        end

        info.types[hackType] = {
            available = isAvailable,
            resource = resourceName
        }
    end

    return info
end

return lib.hacks
