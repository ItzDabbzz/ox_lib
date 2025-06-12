# lib.hacks

A simple wrapper for FiveM hacking minigames. Supports 40+ different minigame resources with a unified API.

## Quick Start

```lua
-- Start a hacking minigame
lib.hacks.start('ps-circle', function(success)
    if success then
        print('Hack successful!')
    else
        print('Hack failed!')
    end
end, 2, 10) -- Additional parameters for the minigame
```

## Basic Usage

```lua
-- Simple thermite hack
lib.hacks.start('ps-thermite', function(success)
    if success then
        -- Player succeeded
        TriggerEvent('heist:thermiteSuccess')
    else
        -- Player failed
        TriggerEvent('heist:thermiteFailed')
    end
end, 10, 5, 3) -- gridsize, incorrectBlocks, timetoShow

-- Check if a hack type is available
if lib.hacks.isAvailable('ps-circle') then
    lib.hacks.start('ps-circle', callback, difficulty, lives)
end
```

## Supported Minigames

### PS-UI
- `ps-circle` - Circle timing game
- `ps-maze` - Navigate through maze
- `ps-varhack` - Variable hacking
- `ps-thermite` - Thermite puzzle
- `ps-scrambler` - Word scrambler

### Memory Game
- `memorygame-thermite` - Thermite memory game

### RAN Minigames
- `ran-memorycard` - Memory card matching
- `ran-openterminal` - Terminal hacking

### Hacking Resource
- `hacking-opengame` - General hacking game

### Howdy Hack
- `howdy-begin` - Howdy hacking minigame

### SN-Hacking
- `sn-memorygame` - Memory game
- `sn-skillcheck` - Skill check
- `sn-thermite` - Thermite game
- `sn-keypad` - Keypad entry
- `sn-colorpicker` - Color matching
- `sn-skillbar` - Skill bar timing
- `sn-shownumber` - Number memory
- `sn-memorycards` - Card memory
- `sn-mines` - Minesweeper

### RM Minigames
- `rm-typinggame` - Typing challenge
- `rm-timedlockpick` - Timed lockpicking
- `rm-timedaction` - Timed actions
- `rm-quicktimeevent` - Quick time events
- `rm-combinationlock` - Combination locks
- `rm-buttonmashing` - Button mashing
- `rm-angledlockpick` - Angled lockpicking
- `rm-fingerprint` - Fingerprint matching
- `rm-circleClick` - Circle clicking
- `rm-hotwirehack` - Hotwire hacking
- `rm-hackerminigame` - Hacker game
- `rm-safecrack` - Safe cracking

### BL UI
- `bl-circlesum` - Circle sum puzzle
- `bl-digitdazzle` - Digit puzzle
- `bl-lightsout` - Lights out game
- `bl-minesweeper` - Minesweeper
- `bl-pathfind` - Path finding
- `bl-printlock` - Print lock
- `bl-untangle` - Untangle puzzle
- `bl-wavematch` - Wave matching
- `bl-wordwiz` - Word wizard

### BD Minigames
- `bd-lockpick` - Lockpicking
- `bd-chopping` - Chopping game
- `bd-pincracker` - PIN cracker
- `bd-roofrunning` - Roof running
- `bd-thermite` - Thermite game
- `bd-terminal` - Terminal hacking

### Glitch Minigames
- `gl-firewall-pulse` - Firewall pulse
- `gl-backdoor-sequence` - Backdoor sequence
- `gl-circuit-rhythm` - Circuit rhythm
- `gl-surge-override` - Surge override
- `gl-circuit-breaker` - Circuit breaker
- `gl-data-crack` - Data cracking
- `gl-brute-force` - Brute force
- `gl-var-hack` - Variable hack

### Other
- `pure-numbercounter` - Number counter
- `simonsays` - Simon Says game

## Functions

### Main Functions
- `lib.hacks.start(hackType, callback, ...)` - Start a minigame
- `lib.hacks.isAvailable(hackType)` - Check if hack type is available
- `lib.hacks.getAvailable()` - Get all available hack types

### Management Functions
- `lib.hacks.register(hackType, hackFunction)` - Add custom hack type
- `lib.hacks.unregister(hackType)` - Remove hack type
- `lib.hacks.getInfo()` - Get detailed info about all hacks

## Examples

### Bank Heist Thermite
```lua
local function startThermite()
    lib.hacks.start('ps-thermite', function(success)
        if success then
            -- Open vault door
            TriggerEvent('bank:openVault')
            lib.notify({
                title = 'Success',
                description = 'Thermite charge planted successfully!',
                type = 'success'
            })
        else
            -- Alert security
            TriggerEvent('bank:alertSecurity')
            lib.notify({
                title = 'Failed',
                description = 'Thermite charge failed to detonate!',
                type = 'error'
            })
        end
    end, 10, 5, 3) -- gridsize, incorrectBlocks, timetoShow
end
```

### Lockpicking
```lua
local function pickLock()
    if not lib.hacks.isAvailable('bd-lockpick') then
        lib.notify({
            title = 'Error',
            description = 'Lockpicking system not available',
            type = 'error'
        })
        return
    end
    
    lib.hacks.start('bd-lockpick', function(success)
        if success then
            -- Unlock door/container
            SetEntityHeading(doorEntity, targetHeading)
            lib.notify({
                title = 'Success',
                description = 'Lock picked successfully!',
                type = 'success'
            })
        else
            -- Break lockpick or alert
            TriggerEvent('inventory:removeItem', 'lockpick', 1)
            lib.notify({
                title = 'Failed',
                description = 'Lockpick broke!',
                type = 'error'
            })
        end
    end, 3) -- difficulty level
end
```

### Custom Hack Registration
```lua
-- Register a custom hack type
lib.hacks.register('my-custom-hack', function(callback, difficulty)
    -- Your custom minigame logic here
    local success = math.random() > 0.5 -- Random success for example
    callback(success)
end)

-- Use your custom hack
lib.hacks.start('my-custom-hack', function(success)
    print('Custom hack result:', success)
end, 5) -- difficulty parameter
```

That's it! Just call `lib.hacks.start()` with your preferred minigame type and handle the result in the callback.
