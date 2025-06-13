# ox_lib Money Module

Cross-framework money management system that works with ESX, QBX, and QB-Core automatically.

## Features

- Automatic framework detection (ESX, QBX, QB-Core)
- Cross-framework money type conversion
- Built-in validation and error handling
- Transaction logging with ox_lib logger
- Money formatting utilities
- Player statistics

## Quick Start

```lua
-- Get player money
local cash = lib.money.get(source, 'cash')
local bank = lib.money.get(source, 'bank')

-- Add money
lib.money.add(source, 'cash', 1000, 'Salary payment')

-- Remove money
lib.money.remove(source, 'bank', 500, 'Store purchase')

-- Check if player has enough money
if lib.money.has(source, 'cash', 100) then
    -- Player has at least $100 cash
end
```

## API Reference

### `lib.money.get(source, moneyType)`
Get player's money amount.

```lua
local cash = lib.money.get(source, 'cash')
local bank = lib.money.get(source, 'bank')
local blackMoney = lib.money.get(source, 'black_money') -- ESX only
```

**Parameters:**
- `source` (number): Player server ID
- `moneyType` (string): Money type ('cash', 'bank', 'money', etc.)

**Returns:** `number` - Money amount

### `lib.money.add(source, moneyType, amount, reason?)`
Add money to player.

```lua
lib.money.add(source, 'cash', 1000, 'Job payment')
lib.money.add(source, 'bank', 5000, 'Business profit')
```

**Parameters:**
- `source` (number): Player server ID
- `moneyType` (string): Money type
- `amount` (number): Amount to add (must be positive)
- `reason` (string, optional): Transaction reason

**Returns:** `boolean` - Success status

### `lib.money.remove(source, moneyType, amount, reason?)`
Remove money from player.

```lua
lib.money.remove(source, 'cash', 100, 'Store purchase')
lib.money.remove(source, 'bank', 2500, 'Fine payment')
```

**Parameters:**
- `source` (number): Player server ID
- `moneyType` (string): Money type
- `amount` (number): Amount to remove (must be positive)
- `reason` (string, optional): Transaction reason

**Returns:** `boolean` - Success status

### `lib.money.has(source, moneyType, amount)`
Check if player has enough money.

```lua
if lib.money.has(source, 'cash', 500) then
    -- Player has at least $500 cash
    lib.money.remove(source, 'cash', 500, 'Purchase')
end
```

**Parameters:**
- `source` (number): Player server ID
- `moneyType` (string): Money type
- `amount` (number): Amount to check

**Returns:** `boolean` - Whether player has enough money

### `lib.money.getAll(source)`
Get all player money accounts.

```lua
local accounts = lib.money.getAll(source)
-- ESX: { money = 1000, bank = 5000, black_money = 100 }
-- QB: { cash = 1000, bank = 5000, crypto = 50 }
```

**Parameters:**
- `source` (number): Player server ID

**Returns:** `MoneyAccount?` - All money accounts or nil

### `lib.money.transfer(fromSource, toSource, moneyType, amount, reason?)`
Transfer money between players.

```lua
-- Transfer $500 cash from player 1 to player 2
lib.money.transfer(1, 2, 'cash', 500, 'Payment')
```

**Parameters:**
- `fromSource` (number): Source player ID
- `toSource` (number): Target player ID
- `moneyType` (string): Money type
- `amount` (number): Amount to transfer
- `reason` (string, optional): Transaction reason

**Returns:** `boolean` - Success status (auto-refunds on failure)

### `lib.money.set(source, moneyType, amount, reason?)`
Set player money to specific amount.

```lua
-- Set player cash to exactly $1000
lib.money.set(source, 'cash', 1000, 'Admin adjustment')
```

**Parameters:**
- `source` (number): Player server ID
- `moneyType` (string): Money type
- `amount` (number): Amount to set (must be non-negative)
- `reason` (string, optional): Transaction reason

**Returns:** `boolean` - Success status

### `lib.money.format(amount, currency?, separator?)`
Format money amount for display.

```lua
local formatted = lib.money.format(1234567)        -- "$1,234,567"
local euros = lib.money.format(1000, '€')          -- "€1,000"
local custom = lib.money.format(1000, '$', '.')    -- "$1.000"
```

**Parameters:**
- `amount` (number): Money amount
- `currency` (string, optional): Currency symbol (default: '$')
- `separator` (string, optional): Thousands separator (default: ',')

**Returns:** `string` - Formatted money string

## Utility Functions

### `lib.money.getFramework()`
Get current framework name.

```lua
local framework = lib.money.getFramework() -- 'esx', 'qb', 'qbx', or nil
```

### `lib.money.isAvailable()`
Check if money system is available.

```lua
if lib.money.isAvailable() then
    -- Money system is ready
end
```

### `lib.money.getStats()`
Get money statistics for all players.

```lua
local stats = lib.money.getStats()
--[[
{
    totalPlayers = 25,
    totalCash = 125000,
    totalBank = 500000,
    averageCash = 5000,
    averageBank = 20000,
    richestPlayer = { source = 5, amount = 100000 },
    poorestPlayer = { source = 12, amount = 500 }
}
--]]
```

## Money Types

### ESX
- `money` (cash)
- `bank`
- `black_money`

### QB-Core / QBX
- `cash`
- `bank`
- `crypto`

**Note:** The system automatically converts between `cash`/`money` types across frameworks.

## Examples

### Basic Money Operations
```lua
-- Salary system
RegisterNetEvent('job:paySalary', function()
    local source = source
    local amount = 1000
    
    if lib.money.add(source, 'bank', amount, 'Salary payment') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'BANK', ('Salary deposited: %s'):format(lib.money.format(amount)) }
        })
    end
end)

-- Store purchase
RegisterNetEvent('store:buyItem', function(itemPrice)
    local source = source
    
    if lib.money.has(source, 'cash', itemPrice) then
        if lib.money.remove(source, 'cash', itemPrice, 'Store purchase') then
            -- Give item to player
            TriggerClientEvent('inventory:addItem', source, 'bread', 1)
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'STORE', 'Not enough cash!' }
        })
    end
end)
```

### Money Transfer System
```lua
-- Player-to-player money transfer
RegisterNetEvent('money:transfer', function(targetId, amount)
    local source = source
    
    if not lib.money.has(source, 'cash', amount) then
        return TriggerClientEvent('notify', source, 'Not enough cash', 'error')
    end
    
    if lib.money.transfer(source, targetId, 'cash', amount, 'Player transfer') then
        TriggerClientEvent('notify', source, ('Sent %s to player'):format(lib.money.format(amount)), 'success')
        TriggerClientEvent('notify', targetId, ('Received %s from player'):format(lib.money.format(amount)), 'success')
    else
        TriggerClientEvent('notify', source, 'Transfer failed', 'error')
    end
end)
```

### Banking System
```lua
-- ATM deposit
RegisterNetEvent('bank:deposit', function(amount)
    local source = source
    
    if lib.money.has(source, 'cash', amount) then
        if lib.money.remove(source, 'cash', amount, 'Bank deposit') and
           lib.money.add(source, 'bank', amount, 'Bank deposit') then
            TriggerClientEvent('notify', source, ('Deposited %s'):format(lib.money.format(amount)))
        end
    end
end)

-- ATM withdrawal
RegisterNetEvent('bank:withdraw', function(amount)
    local source = source
    
    if lib.money.has(source, 'bank', amount) then
        if lib.money.remove(source, 'bank', amount, 'Bank withdrawal') and
           lib.money.add(source, 'cash', amount, 'Bank withdrawal') then
            TriggerClientEvent('notify', source, ('Withdrew %s'):format(lib.money.format(amount)))
        end
    end
end)
```

### Admin Commands
```lua
-- Give money command
lib.addCommand('givemoney', {
    help = 'Give money to player',
    params = {
        { name = 'id', type = 'playerId', help = 'Player ID' },
        { name = 'type', type = 'string', help = 'Money type (cash/bank)' },
        { name = 'amount', type = 'number', help = 'Amount' }
    },
    restricted = 'group.admin'
}, function(source, args)
    if lib.money.add(args.id, args.type, args.amount, 'Admin give') then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'ADMIN', ('Gave %s %s to player %d'):format(lib.money.format(args.amount), args.type, args.id) }
        })
    end
end)

-- Check money command
lib.addCommand('checkmoney', {
    help = 'Check player money',
    params = {
        { name = 'id', type = 'playerId', help = 'Player ID' }
    },
    restricted = 'group.admin'
}, function(source, args)
    local accounts = lib.money.getAll(args.id)
    if accounts then
        for accountType, amount in pairs(accounts) do
            TriggerClientEvent('chat:addMessage', source, {
                args = { 'MONEY', ('%s: %s'):format(accountType, lib.money.format(amount)) }
            })
        end
    end
end)
```

### Job Payment System
```lua
-- Job completion reward
local jobPayments = {
    police = 500,
    ems = 400,
    mechanic = 300
}

RegisterNetEvent('job:complete', function(jobType)
    local source = source
    local payment = jobPayments[jobType]
    
    if payment and lib.money.add(source, 'bank', payment, ('Job completion: %s'):format(jobType)) then
        TriggerClientEvent('notify', source, ('Job completed! Earned %s'):format(lib.money.format(payment)))
    end
end)
```

## Error Handling

The money system includes comprehensive error handling:

- Validates player existence
- Checks for positive amounts
- Prevents negative money values
- Auto-refunds failed transfers
- Logs all transactions (if logger available)

## Logging

All money transactions are automatically logged if `lib.logger` is available:

```lua
-- Logged events:
-- money_add: When money is added
-- money_remove: When money is removed  
-- money_transfer: When money is transferred between players
```

## Framework Compatibility

| Framework | Cash Type | Bank Type | Additional |
|-----------|-----------|-----------|------------|
| ESX | `money` | `bank` | `black_money` |
| QB-Core | `cash` | `bank` | `crypto` |
| QBX | `cash` | `bank` | `crypto` |

The system automatically handles type conversion, so you can use `'cash'` consistently across all frameworks.
