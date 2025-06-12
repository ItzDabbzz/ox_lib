--[[
    https://github.com/overextended/ox_lib
    https://github.com/ITzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxGender
lib.gender = {}

--- Gets the gender of the current player.
--- Ensure this function is called within a coroutine context.
---@return string The player's gender ('Male' or 'Female')
function lib.gender.get()
    local thread = coroutine.running()
    assert(thread, "lib.gender.get must be called from within a coroutine.")

    lib.callback.await('ox_lib:getGender', false, function(gender)
        coroutine.resume(thread, gender)
    end)

    return coroutine.yield()
end

return lib.gender
