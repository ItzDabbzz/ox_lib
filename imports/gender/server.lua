--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxGender
lib.gender = {}

--- Returns a function that, when called with a player object, returns the corresponding gender.
---@return function A function that returns 'Male' or 'Female' based on player data
local function getPlayerGender()
    return function(player)
        return player.PlayerData.charinfo.gender == 0 and 'Male' or 'Female'
    end
end

-- Assign the dynamically selected function
local getGenderFromPlayer = getPlayerGender()

--- Gets the gender of a player by their source ID.
---@param source number The player's source ID
---@return string Returns 'Male' or 'Female' based on the player's gender
function lib.gender.getFromPlayer(source)
    local player = exports.qbx_core:GetPlayer(source)
    return getGenderFromPlayer(player)
end

lib.callback.register('ox_lib:getGender', function(source)
    return lib.gender.getFromPlayer(source)
end)

return lib.gender
