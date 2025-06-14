# OX Lib Blips System

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)](https://fivem.net/)
[![Framework](https://img.shields.io/badge/Framework-ESX%20%7C%20QB%20%7C%20QBX-orange.svg)](https://github.com/overextended/ox_lib)

A comprehensive, enterprise-grade blip management system for FiveM servers built on the OX Lib framework. This system provides advanced blip categorization, job-based access control, and seamless synchronization across all players.

## 🚀 Features

### Core Functionality
- **Dynamic Blip Management**: Create, update, and remove blips in real-time
- **Category System**: Organize blips into logical categories with FiveM's native category support
- **Access Control**: Job, gang, and grade-based restrictions for blip visibility
- **Framework Agnostic**: Compatible with ESX, QB-Core, and QBX frameworks
- **Real-time Synchronization**: Automatic sync when player jobs change
- **Bulk Operations**: Efficient batch operations for large-scale blip management

### Advanced Features
- **Job Integration**: Automatic job-specific blip categorization
- **Permission System**: Granular access control with multiple restriction types
- **Performance Optimized**: Smart synchronization to minimize network overhead
- **Debug Support**: Comprehensive logging and debugging capabilities
- **Administrative Tools**: Built-in commands for system management
- **Statistics Monitoring**: Real-time system statistics and health monitoring

## 📋 Requirements

- **ox_lib**: Latest version
- **FiveM Server**: Build 2802 or higher
- **Framework**: ESX, QB-Core, or QBX (optional but recommended)

## 🔧 Configuration

   ```cfg
   # Debug mode
   set ox:blips:debug true

   # Sync interval (milliseconds)
   set ox:blips:syncInterval 30000

   # Maximum blips per category
   set ox:blips:maxPerCategory 100

   # Maximum categories
   set ox:blips:maxCategories 50

   # Use FiveM categories
   set ox:blips:categories true
   ```

## 📖 API Documentation

### Server-Side API

#### Categories

```lua
-- Create a new category
local success, error = lib.blips.createCategory('police', {
    label = 'Police Stations',
    description = 'Law enforcement locations',
    restrictions = {
        jobs = { 'police', 'sheriff' },
        minGrade = 0
    },
    enabled = true
})

-- Remove a category
local success, error = lib.blips.removeCategory('police')

-- Get all categories
local categories = lib.blips.getCategories()

-- Enable/disable a category
local success, error = lib.blips.setCategoryEnabled('police', false)
```

#### Blips

```lua
-- Add a new blip
local blipId, error = lib.blips.addBlip({
    coords = vector3(425.1, -979.5, 30.7),
    sprite = 60,
    color = 29,
    label = 'Mission Row Police Station',
    scale = 0.8,
    shortRange = true,
    category = 'police',
    restrictions = {
        jobs = { 'police' },
        minGrade = 0
    },
    metadata = {
        type = 'station',
        district = 'downtown'
    }
})

-- Update a blip
local success, error = lib.blips.updateBlip(blipId, {
    label = 'Updated Police Station',
    color = 3
})

-- Remove a blip
local success, error = lib.blips.removeBlip(blipId)

-- Get blip by ID
local blip = lib.blips.getBlip(blipId)

-- Get blips by category
local policeBlips = lib.blips.getBlipsByCategory('police')
```

#### Job-Specific Functions

```lua
-- Add job-specific blip (auto-categorized)
local blipId, error = lib.blips.addJobBlip('police', {
    coords = vector3(425.1, -979.5, 30.7),
    sprite = 60,
    color = 29,
    label = 'Police Station'
})

-- Add public job blip (visible to everyone)
local blipId, error = lib.blips.addPublicJobBlip('mechanic', {
    coords = vector3(1174.8, 2640.8, 37.8),
    sprite = 446,
    color = 5,
    label = 'Sandy Shores Mechanic'
})

-- Bulk add job blips
local results = lib.blips.addJobBlips({
    police = {
        {
            coords = vector3(425.1, -979.5, 30.7),
            sprite = 60,
            color = 29,
            label = 'Mission Row PD'
        },
        {
            coords = vector3(1853.1, 3686.6, 34.3),
            sprite = 60,
            color = 29,
            label = 'Sandy Shores PD'
        }
    }
})

-- Remove all job blips
local removedCount = lib.blips.removeJobBlips('police')

-- Get job blips
local jobBlips = lib.blips.getJobBlips('police')
```

#### System Management

```lua
-- Get system statistics
local stats = lib.blips.getStats()
print(json.encode(stats, { indent = true }))

-- Clear all blips and categories
lib.blips.clearAll()
```

### Client-Side API

```lua
-- Request sync from server
lib.blips.requestSync()

-- Get cached data
local categories = lib.blips.getCategories()
local blips = lib.blips.getBlips()
local categoryBlips = lib.blips.getBlipsByCategory('police')

-- Create manual blip
local blipHandle = lib.blips.createBlip({
    coords = vector3(0.0, 0.0, 0.0),
    sprite = 1,
    color = 0,
    label = 'Custom Blip',
    category = 'Custom Category'
})

-- Remove manual blip
lib.blips.removeBlip(blipHandle)

-- Set blip category
lib.blips.setBlipCategory(blipHandle, 'Custom Category')

-- Get system statistics
local stats = lib.blips.getStats()

-- Clear all managed blips
lib.blips.clearAll()
```

## 🎯 Usage Examples

### Basic Police Station Setup

```lua
-- Server-side script
CreateThread(function()
    -- Create police category
    lib.blips.createCategory('police', {
        label = 'Police Stations',
        description = 'Law enforcement locations',
        enabled = true
    })

    -- Add police stations
    local stations = {
        {
            coords = vector3(425.1, -979.5, 30.7),
            label = 'Mission Row Police Station'
        },
        {
            coords = vector3(1853.1, 3686.6, 34.3),
            label = 'Sandy Shores Police Station'
        },
        {
            coords = vector3(-449.1, 6008.3, 31.7),
            label = 'Paleto Bay Police Station'
        }
    }

    for _, station in ipairs(stations) do
        lib.blips.addJobBlip('police', {
            coords = station.coords,
            sprite = 60,
            color = 29,
            label = station.label,
            scale = 0.8,
            shortRange = true
        })
    end
end)
```

### Job-Based Blip System

```lua
-- Server-side job blip manager
local JobBlips = {
    police = {
        {
            coords = vector3(425.1, -979.5, 30.7),
            sprite = 60,
            color = 29,
            label = 'Mission Row PD',
            restrictions = { jobs = { 'police' }, minGrade = 0 }
        }
    },
    ems = {
        {
            coords = vector3(1839.6, 3672.9, 34.3),
            sprite = 61,
            color = 1,
            label = 'Sandy Shores Medical',
            restrictions = { jobs = { 'ambulance' }, minGrade = 0 }
        }
    },
    mechanic = {
        {
            coords = vector3(1174.8, 2640.8, 37.8),
            sprite = 446,
            color = 5,
            label = 'Sandy Shores Mechanic'
            -- No restrictions = public blip
        }
    }
}

-- Initialize all job blips
CreateThread(function()
    local results = lib.blips.addJobBlips(JobBlips)

    for jobName, jobResults in pairs(results) do
        local successCount = 0
        for _, result in ipairs(jobResults) do
            if result.success then
                successCount = successCount + 1
            end
        end
        print(('Loaded %d/%d blips for job: %s'):format(successCount, #jobResults, jobName))
    end
end)
```

### Dynamic Blip Management

```lua
-- Server-side event handlers
RegisterNetEvent('myresource:createTempBlip', function(coords, duration)
    local source = source

    -- Create temporary blip
    local blipId = lib.blips.addBlip({
        coords = coords,
        sprite = 1,
        color = 1,
        label = 'Temporary Location',
        restrictions = {
            jobs = { GetPlayerJob(source) }
        }
    })

    -- Remove after duration
    if blipId then
        SetTimeout(duration * 1000, function()
            lib.blips.removeBlip(blipId)
        end)
    end
end)

-- Job change handler
AddEventHandler('esx:setJob', function(playerId, job, lastJob)
    -- Remove old job blips and sync new ones
    -- This is handled automatically by the system
    print(('Player %d changed from %s to %s - blips will be re-synced'):format(
        playerId, lastJob.name, job.name))
end)
```

## 🔧 Configuration

### Convar Options

| Convar | Type | Default | Description |
|--------|------|---------|-------------|
| `ox:blips:debug` | boolean | `false` | Enable debug logging |
| `ox:blips:syncInterval` | number | `30000` | Sync interval in milliseconds |
| `ox:blips:maxPerCategory` | number | `100` | Maximum blips per category |
| `ox:blips:maxCategories` | number | `50` | Maximum number of categories |
| `ox:blips:categories` | boolean | `true` | Use FiveM's category system |

### Access Restrictions

```lua
-- Job-based restrictions
restrictions = {
    jobs = { 'police', 'sheriff' },  -- Allowed jobs
    minGrade = 2                     -- Minimum grade required
}

-- Gang-based restrictions (QB/QBX only)
restrictions = {
    gangs = { 'ballas', 'families' },
    minGrade = 1
}

-- Combined restrictions
restrictions = {
    jobs = { 'police' },
    gangs = { 'lostmc' },
    minGrade = 3
}
```

## 🛠️ Administrative Commands

Available when `ox:blips:debug` is enabled:

```bash
# Show system statistics
blips_stats

# Force sync for a player
blips_sync [playerId]

# Clear all blips and categories
blips_clear

# Reload default categories
blips_reload
```

## 📊 Monitoring & Statistics

```lua
-- Get comprehensive system stats
local stats = lib.blips.getStats()
--[[
{
    totalCategories = 12,
    totalBlips = 45,
    enabledCategories = 10,
    enabledBlips = 42,
    blipsByCategory = {
        police = 5,
        ems = 3,
        mechanic = 8
    },
    playersTracked = 32,
    nextBlipId = 46,
    config = { ... }
}
--]]
```

## 🐛 Troubleshooting

### Common Issues

**Blips not appearing:**
- Check if the category is enabled
- Verify player has required job/grade
- Ensure blip is enabled
- Check debug logs

**Performance issues:**
- Reduce sync interval
- Limit blips per category
- Check for excessive blip creation/removal

**Framework integration:**
- Ensure framework is properly detected
- Check job change events are firing
- Verify player data structure

### Debug Mode

Enable debug mode for detailed logging:
```cfg
set ox:blips:debug true
```

This will provide detailed logs about:
- Blip creation/removal
- Player synchronization
- Permission checks
- System events

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the LGPL-3.0 License - see the [LICENSE](https://www.gnu.org/licenses/lgpl-3.0.en.html) file for details.

## 🙏 Acknowledgments

- [Overextended](https://github.com/overextended) for the OX Lib framework
- [ItzDabbzz](https://github.com/ItzDabbzz) for the blips implementation
- FiveM community for testing and feedback

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/ItzDabbzz/ox_lib/issues)

---

**Made with ❤️ for the FiveM community**
