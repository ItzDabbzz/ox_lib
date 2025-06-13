--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxMoney
lib.money = {}

---@class MoneyAccount
---@field cash number Cash amount
---@field bank number Bank amount
---@field black_money? number Black money amount (ESX only)
---@field crypto? number Crypto amount (some frameworks)

--- Convert money type between frameworks
---@param moneyType string
---@return string
local function convertMoneyType(moneyType)
    local framework = lib.framework.getFramework()

    if framework == 'esx' then
        -- ESX uses 'money' for cash
        if moneyType == 'cash' then
            return 'money'
        end
    elseif framework == 'qb' or framework == 'qbx' then
        -- QB uses 'cash' for money
        if moneyType == 'money' then
            return 'cash'
        end
    end

    return moneyType
end

--- Get player money amount
---@param source number Player server ID
---@param moneyType string Money type ('cash', 'bank', 'money', etc.)
---@return number amount Money amount
function lib.money.get(source, moneyType)
    if not lib.assert.playerSource(source, 'Player source') then
        return 0
    end

    if not lib.assert.type(moneyType, 'string', 'Money type') then
        return 0
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player %s not found'):format(source))
        return 0
    end

    moneyType = convertMoneyType(moneyType)
    local framework = lib.framework.getFramework()

    if framework == 'esx' then
        local account = player.getAccount(moneyType)
        return account and account.money or 0
    elseif framework == 'qb' or framework == 'qbx' then
        return player.PlayerData.money[moneyType] or 0
    end

    return 0
end

--- Add money to player
---@param source number Player server ID
---@param moneyType string Money type
---@param amount number Amount to add
---@param reason? string Reason for transaction
---@return boolean success
function lib.money.add(source, moneyType, amount, reason)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    if not lib.assert.type(moneyType, 'string', 'Money type') then
        return false
    end

    if not lib.assert.type(amount, 'number', 'Amount') then
        return false
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player %s not found'):format(source))
        return false
    end

    moneyType = convertMoneyType(moneyType)
    local framework = lib.framework.getFramework()
    local success = false

    if framework == 'esx' then
        success = player.addAccountMoney(moneyType, amount, reason)
    elseif framework == 'qb' or framework == 'qbx' then
        success = player.Functions.AddMoney(moneyType, amount, reason)
    end

    if success then
        lib.print.debug(('Added $%d %s to player %s%s'):format(
            amount, moneyType, source, reason and (' - ' .. reason) or ''
        ))

        if lib.logger then
            lib.logger(source, 'money_add', 'Money Added',
                'amount:' .. amount,
                'type:' .. moneyType,
                'reason:' .. (reason or 'none')
            )
        end
    end

    return success or false
end

--- Remove money from player
---@param source number Player server ID
---@param moneyType string Money type
---@param amount number Amount to remove
---@param reason? string Reason for transaction
---@return boolean success
function lib.money.remove(source, moneyType, amount, reason)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    if not lib.assert.type(moneyType, 'string', 'Money type') then
        return false
    end

    if not lib.assert.type(amount, 'number', 'Amount') then
        return false
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player %s not found'):format(source))
        return false
    end

    moneyType = convertMoneyType(moneyType)
    local framework = lib.framework.getFramework()
    local success = false

    if framework == 'esx' then
        success = player.removeAccountMoney(moneyType, amount, reason)
    elseif framework == 'qb' or framework == 'qbx' then
        success = player.Functions.RemoveMoney(moneyType, amount, reason)
    end

    if success then
        lib.print.debug(('Removed $%d %s from player %s%s'):format(
            amount, moneyType, source, reason and (' - ' .. reason) or ''
        ))

        if lib.logger then
            lib.logger(source, 'money_remove', 'Money Removed',
                'amount:' .. amount,
                'type:' .. moneyType,
                'reason:' .. (reason or 'none')
            )
        end
    end

    return success or false
end

--- Check if player has enough money
---@param source number Player server ID
---@param moneyType string Money type
---@param amount number Amount to check
---@return boolean hasEnough
function lib.money.has(source, moneyType, amount)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    if not lib.assert.type(moneyType, 'string', 'Money type') then
        return false
    end

    if not lib.assert.type(amount, 'number', 'Amount') then
        return false
    end

    local currentAmount = lib.money.get(source, moneyType)
    return currentAmount >= amount
end

--- Get all player money accounts
---@param source number Player server ID
---@return MoneyAccount? accounts All money accounts
function lib.money.getAll(source)
    if not lib.assert.playerSource(source, 'Player source') then
        return nil
    end

    local player = lib.framework.getPlayer(source)
    if not player then
        lib.print.warn(('Player %s not found'):format(source))
        return nil
    end

    local framework = lib.framework.getFramework()

    if framework == 'esx' then
        local accounts = {}
        for _, account in pairs(player.getAccounts()) do
            accounts[account.name] = account.money
        end
        return accounts
    elseif framework == 'qb' or framework == 'qbx' then
        return lib.table.deepclone(player.PlayerData.money)
    end

    return nil
end

--- Transfer money between players
---@param fromSource number Source player ID
---@param toSource number Target player ID
---@param moneyType string Money type
---@param amount number Amount to transfer
---@param reason? string Reason for transaction
---@return boolean success
function lib.money.transfer(fromSource, toSource, moneyType, amount, reason)
    if not lib.assert.playerSource(fromSource, 'From player source') then
        return false
    end

    if not lib.assert.playerSource(toSource, 'To player source') then
        return false
    end

    if not lib.assert.type(moneyType, 'string', 'Money type') then
        return false
    end

    if not lib.assert.type(amount, 'number', 'Amount') then
        return false
    end

    if not lib.money.has(fromSource, moneyType, amount) then
        lib.print.warn(('Player %s does not have enough %s'):format(fromSource, moneyType))
        return false
    end

    local removeSuccess = lib.money.remove(fromSource, moneyType, amount, reason)
    if not removeSuccess then
        return false
    end

    local addSuccess = lib.money.add(toSource, moneyType, amount, reason)
    if not addSuccess then
        -- Refund if add failed
        lib.money.add(fromSource, moneyType, amount, 'Transfer refund')
        return false
    end

    lib.print.debug(('Transferred $%d %s from player %s to %s%s'):format(
        amount, moneyType, fromSource, toSource, reason and (' - ' .. reason) or ''
    ))

    if lib.logger then
        lib.logger(fromSource, 'money_transfer', 'Money Transfer',
            'amount:' .. amount,
            'type:' .. moneyType,
            'to:' .. toSource,
            'reason:' .. (reason or 'none')
        )
    end

    return true
end

--- Set player money amount (use with caution)
---@param source number Player server ID
---@param moneyType string Money type
---@param amount number Amount to set
---@param reason? string Reason for transaction
---@return boolean success
function lib.money.set(source, moneyType, amount, reason)
    if not lib.assert.playerSource(source, 'Player source') then
        return false
    end

    if not lib.assert.type(moneyType, 'string', 'Money type') then
        return false
    end


    if not lib.assert.type(amount, 'number', 'Amount') then
        return false
    end

    local currentAmount = lib.money.get(source, moneyType)
    local difference = amount - currentAmount

    if difference > 0 then
        return lib.money.add(source, moneyType, difference, reason)
    elseif difference < 0 then
        return lib.money.remove(source, moneyType, math.abs(difference), reason)
    end

    return true -- No change needed
end

--- Format money amount for display
---@param amount number Money amount
---@param currency? string Currency symbol (default: $)
---@param separator? string Thousands separator (default: ,)
---@return string formatted Formatted money string
function lib.money.format(amount, currency, separator)
    if not lib.assert.type(amount, 'number', 'Amount') then
        return '$0'
    end

    currency = currency or '$'
    separator = separator or ','

    local formatted = tostring(math.floor(amount))
    local k = 0

    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1' .. separator .. '%2')
        if k == 0 then break end
    end

    return currency .. formatted
end

--- Get framework name
---@return string? framework Current framework name
function lib.money.getFramework()
    return lib.framework.getFramework()
end

--- Check if money system is available
---@return boolean available
function lib.money.isAvailable()
    return lib.framework.isAvailable()
end

--- Get money statistics for all players
---@return table stats Money statistics
function lib.money.getStats()
    if not lib.framework.isAvailable() then
        return {}
    end

    local players = lib.framework.getAllPlayers()
    local stats = {
        totalPlayers = #players,
        totalCash = 0,
        totalBank = 0,
        averageCash = 0,
        averageBank = 0,
        richestPlayer = nil,
        poorestPlayer = nil
    }

    local richestAmount = 0
    local poorestAmount = math.huge

    for _, player in pairs(players) do
        local source = type(player) == 'table' and player.source or player
        if source then
            local cash = lib.money.get(source, 'cash')
            local bank = lib.money.get(source, 'bank')
            local total = cash + bank

            stats.totalCash = stats.totalCash + cash
            stats.totalBank = stats.totalBank + bank

            if total > richestAmount then
                richestAmount = total
                stats.richestPlayer = { source = source, amount = total }
            end

            if total < poorestAmount then
                poorestAmount = total
                stats.poorestPlayer = { source = source, amount = total }
            end
        end
    end

    if stats.totalPlayers > 0 then
        stats.averageCash = math.floor(stats.totalCash / stats.totalPlayers)
        stats.averageBank = math.floor(stats.totalBank / stats.totalPlayers)
    end

    return stats
end

--- Wait for framework to be available
lib.waitFor(function()
    return lib.framework.isAvailable()
end, 'Framework not available for money system', 30000)

return lib.money
