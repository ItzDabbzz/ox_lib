# ox_lib Email System

A unified email system for FiveM that automatically detects and integrates with popular phone resources to send in-game emails. The system provides a consistent API regardless of which phone resource is being used.

## Features

- 🔄 **Multi-Phone Support**: Automatically detects and works with 12+ phone resources
- ⚡ **Priority System**: Intelligent phone resource detection with configurable priorities
- 🛡️ **Input Validation**: Comprehensive parameter validation and error handling
- 📱 **Auto-Detection**: Automatic phone resource detection and switching
- 🔧 **Simple API**: Easy-to-use functions for sending emails
- 📊 **Content Validation**: Built-in email content validation with length limits

## Supported Phone Resources

The system automatically detects these phone resources in priority order:

1. **qb-phone** - QBCore phone system
2. **qs-smartphone** - Quasar Smartphone
3. **qs-smartphone-pro** - Quasar Smartphone Pro
4. **high-phone** - High Phone system
5. **npwd-phone** - NPWD (New Phone Who Dis)
6. **lb-phone** - LB Phone
7. **yseries** - Y Series phone
8. **yflip-phone** - Y Flip phone
9. **okokPhone** - OKOK Phone
10. **gks-phone** - GKS Phone
11. **gksphone** - GKS Phone (alternative)
12. **roadphone** - Road Phone

## Installation

The email system is automatically available as part of ox_lib. No additional installation required.

## Dependencies

- **Required**: `ox_lib`
- **Phone Resource**: At least one of the supported phone resources listed above

---

## API Reference

### Core Functions

#### `lib.email.send(sender, subject, message)`
Sends an email using the detected phone resource.

```lua
-- Simple string sender
local success = lib.email.send('John Doe', 'Meeting Reminder', 'Don\'t forget about our meeting at 3 PM!')

-- Advanced sender object
local success = lib.email.send({
    name = 'John Doe',
    address = 'john.doe@email.com',
    photo = 'https://example.com/photo.jpg'
}, 'Meeting Reminder', 'Don\'t forget about our meeting!')

if success then
    print('Email sent successfully')
else
    print('Failed to send email')
end
```

**Parameters:**
- `sender` (string|table): Email sender (string for simple, table for advanced)
- `subject` (string): Email subject line
- `message` (string): Email message content

**Returns:**
- `boolean`: Whether the email was sent successfully

---

#### `lib.email.sendSimple(senderName, subject, message)`
Sends a simple email with a string sender name.

```lua
local success = lib.email.sendSimple('Police Department', 'Citation Notice', 'You have received a traffic citation.')
```

**Parameters:**
- `senderName` (string): Sender's name
- `subject` (string): Email subject line
- `message` (string): Email message content

**Returns:**
- `boolean`: Whether the email was sent successfully

---

#### `lib.email.sendAdvanced(senderData, subject, message)`
Sends an email with advanced sender information.

```lua
local success = lib.email.sendAdvanced({
    name = 'Los Santos Medical',
    address = 'medical@lsmc.gov',
    photo = 'https://lsmc.gov/logo.png'
}, 'Medical Report', 'Your test results are ready for pickup.')
```

**Parameters:**
- `senderData` (table): Advanced sender data
  - `name` (string): Sender's name (required)
  - `address` (string, optional): Email address
  - `photo` (string, optional): Photo URL
- `subject` (string): Email subject line
- `message` (string): Email message content

**Returns:**
- `boolean`: Whether the email was sent successfully

---

### System Information

#### `lib.email.getPhoneResource()`
Gets the currently detected phone resource name.

```lua
local phoneResource = lib.email.getPhoneResource()
if phoneResource then
    print('Using phone resource:', phoneResource)
else
    print('No phone resource detected')
end
```

**Returns:**
- `string?`: Name of the detected phone resource or `nil`

---

#### `lib.email.isAvailable()`
Checks if email functionality is available.

```lua
if lib.email.isAvailable() then
    -- Safe to send emails
    lib.email.send('System', 'Welcome', 'Welcome to the server!')
else
    print('Email system not available')
end
```

**Returns:**
- `boolean`: Whether email can be sent

---

#### `lib.email.refresh()`
Refreshes phone resource detection.

```lua
local success = lib.email.refresh()
if success then
    print('Phone resource detection refreshed')
    print('Now using:', lib.email.getPhoneResource())
else
    print('No phone resource found after refresh')
end
```

**Returns:**
- `boolean`: Whether a phone resource was detected after refresh

---

### Content Validation

#### `lib.email.validateContent(subject, message)`
Validates email content for common issues.

```lua
local valid, error = lib.email.validateContent('Test Subject', 'Test message content')
if valid then
    print('Content is valid')
else
    print('Content validation failed:', error)
end
```

**Parameters:**
- `subject` (string): Email subject to validate
- `message` (string): Email message to validate

**Returns:**
- `boolean`: Whether content is valid
- `string?`: Error message if validation failed

**Validation Rules:**
- Subject max length: 100 characters
- Message max length: 1000 characters
- Both subject and message cannot be empty or whitespace-only

---

## Usage Examples

### Basic Email Sending
```lua
-- Simple notification email
RegisterCommand('notify', function(source, args)
    local message = table.concat(args, ' ')
    local success = lib.email.send('Server Admin', 'Notification', message)
    
    if success then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 0, 255, 0 },
            multiline = true,
            args = { 'Email', 'Notification sent successfully!' }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { 'Email', 'Failed to send notification.' }
        })
    end
end, false)
```

### Government/Business Integration
```lua
-- Police citation system
local function sendCitation(playerId, offense, fine)
    local playerName = GetPlayerName(playerId)
    
    local success = lib.email.sendAdvanced({
        name = 'Los Santos Police Department',
        address = 'citations@lspd.gov',
        photo = 'https://lspd.gov/badge.png'
    }, 'Traffic Citation Notice', 
    ('Dear %s,\n\nYou have received a citation for: %s\nFine Amount: $%d\n\nPlease pay within 30 days.\n\n- LSPD'):format(
        playerName, offense, fine
    ))
    
    return success
end

-- Usage
sendCitation(source, 'Speeding', 250)
```

### Medical System Integration
```lua
-- Hospital appointment system
local function sendAppointmentReminder(playerId, doctorName, appointmentTime)
    local success = lib.email.sendAdvanced({
        name = 'Pillbox Medical Center',
        address = 'appointments@pillbox.health',
        photo = 'https://pillbox.health/logo.png'
    }, 'Appointment Reminder', 
    ('Your appointment with Dr. %s is scheduled for %s.\n\nPlease arrive 15 minutes early.\n\n- Pillbox Medical'):format(
        doctorName, appointmentTime
    ))
    
    return success
end
```

### Banking System Integration
```lua
-- Bank transaction notifications
local function sendTransactionNotification(playerId, transactionType, amount, balance)
    local success = lib.email.send({
        name = 'Maze Bank',
        address = 'notifications@mazebank.com'
    }, 'Transaction Alert', 
    ('Transaction Type: %s\nAmount: $%s\nNew Balance: $%s\n\nIf this wasn\'t you, contact us immediately.'):format(
        transactionType, lib.math.groupDigits(amount), lib.math.groupDigits(balance)
    ))
    
    return success
end
```

### Job System Integration
```lua
-- Job application responses
local function sendJobResponse(playerId, jobName, accepted)
    local subject = accepted and 'Job Application Accepted' or 'Job Application Declined'
    local message = accepted and 
        ('Congratulations! Your application for %s has been accepted. Report to the job center to begin.'):format(jobName) or
        ('Thank you for your interest in %s. Unfortunately, your application was not accepted at this time.'):format(jobName)
    
    local success = lib.email.send('Human Resources', subject, message)
    return success
end
```

### Event System Integration
```lua
-- Server event notifications
AddEventHandler('playerConnecting', function()
    local source = source
    
    SetTimeout(5000, function() -- Wait for player to fully load
        lib.email.send('Server Welcome Bot', 'Welcome to the Server!', 
            'Welcome to our FiveM server!\n\n' ..
            'Here are some helpful tips:\n' ..
            '• Press F1 for help menu\n' ..
            '• Join our Discord for support\n' ..
            '• Read the rules in the phone app\n\n' ..
            'Have fun and enjoy your stay!'
        )
    end)
end)
```

---

## Error Handling

### Validation Errors
```lua
-- Always validate before sending
local function sendSafeEmail(sender, subject, message)
    -- Check if email system is available
    if not lib.email.isAvailable() then
        lib.print.error('Email system not available')
        return false
    end
    
    -- Validate content
    local valid, error = lib.email.validateContent(subject, message)
    if not valid then
        lib.print.error('Email validation failed: ' .. error)
        return false
    end
    
    -- Send email
    return lib.email.send(sender, subject, message)
end
```

### Graceful Degradation
```lua
-- Fallback when email system is unavailable
local function notifyPlayer(playerId, title, message)
    if lib.email.isAvailable() then
        -- Try email first
        local success = lib.email.send('System', title, message)
        if success then
            return true
        end
    end
    
    -- Fallback to chat notification
    TriggerClientEvent('chat:addMessage', playerId, {
        color = { 255, 255, 0 },
        multiline = true,
        args = { title, message }
    })
    
    return true
end
```

### Batch Email Handling
```lua
-- Send emails to multiple players with error handling
local function sendBulkEmail(playerIds, sender, subject, message)
    if not lib.email.isAvailable() then
        lib.print.error('Cannot send bulk emails: Email system not available')
        return 0
    end
    
    local successCount = 0
    
    for _, playerId in ipairs(playerIds) do
        -- Add small delay to prevent spam
        Wait(100)
        
        local success = lib.email.send(sender, subject, message)
        if success then
            successCount = successCount + 1
        else
            lib.print.warn(('Failed to send email to player %d'):format(playerId))
        end
    end
    
    lib.print.info(('Bulk email sent to %d/%d players'):format(successCount, #playerIds))
    return successCount
end
```

---

## Best Practices

### 1. **Always Check Availability**
```lua
-- Good practice
if lib.email.isAvailable() then
    lib.email.send('Sender', 'Subject', 'Message')
end

-- Avoid this
lib.email.send('Sender', 'Subject', 'Message') -- May fail silently
```

### 2. **Validate Content**
```lua
-- Validate before sending
local valid, error = lib.email.validateContent(subject, message)
if valid then
    lib.email.send(sender, subject, message)
else
    lib.print.error('Invalid email content: ' .. error)
end
```

### 3. **Use Appropriate Sender Types**
```lua
-- For simple notifications
lib.email.sendSimple('System', 'Title', 'Message')

-- For official communications
lib.email.sendAdvanced({
    name = 'Los Santos Government',
    address = 'gov@lossantos.gov',
    photo = 'https://lsgov.com/seal.png'
}, 'Official Notice', 'Important government message')
```

### 4. **Handle Errors Gracefully**
```lua
local function sendWithFallback(playerId, title, message)
    local success = lib.email.send('System', title, message)
    
    if not success then
        -- Fallback to alternative notification method
        TriggerClientEvent('showNotification', playerId, title .. ': ' .. message)
    end
    
    return success
end
```

---

## Troubleshooting

### Common Issues

1. **No Phone Resource Detected**
   ```lua
   -- Check which phone resources are running
   local phoneResources = {
       'qb-phone', 'qs-smartphone', 'qs-smartphone-pro',
       'high-phone', 'npwd-phone', 'lb-phone', 'yseries',
       'yflip-phone', 'okokPhone', 'gks-phone', 'gksphone', 'roadphone'
   }
   
   for _, resource in ipairs(phoneResources) do
       print(resource .. ':', GetResourceState(resource))
   end
   
   -- Try refreshing detection
   lib.email.refresh()
   ```

2. **Emails Not Sending**
   ```lua
   -- Debug email system
   print('Email available:', lib.email.isAvailable())
   print('Phone resource:', lib.email.getPhoneResource())
   
   -- Test with simple email
   local success = lib.email.sendSimple('Test', 'Test Subject', 'Test message')
   print('Test email success:', success)
   ```

3. **Content Validation Failures**
   ```lua
   -- Check content limits
   local subject = 'Your subject here'
   local message = 'Your message here'
   
   print('Subject length:', #subject, '(max 100)')
   print('Message length:', #message, '(max 1000)')
   
   local valid, error = lib.email.validateContent(subject, message)
   if not valid then
       print('Validation error:', error)
   end
   ```

### Debug Commands
```lua
-- Add debug command for testing
RegisterCommand('testemail', function(source, args)
    if not lib.email.isAvailable() then
        print('Email system not available')
        return
    end
    
    local success = lib.email.sendSimple('Debug Test', 'Test Email', 'This is a test email from the debug command.')
    print('Test email result:', success)
    print('Using phone resource:', lib.email.getPhoneResource())
end, true)
```

---

## Performance Considerations

### Resource Detection
- Phone resource detection is cached after first successful detection
- Automatic re-detection when resources start/stop
- Minimal performance impact during normal operation

### Email Sending
- Each email send operation is wrapped in `pcall` for error safety
- No internal queuing - emails are sent immediately
- Consider adding delays for bulk email operations

### Memory Usage
- Minimal memory footprint
- No persistent storage of email data
- Automatic cleanup of detection cache

---

## Migration Guide

### From Direct Phone Resource Usage

**Before:**
```lua
-- Direct qb-phone usage
TriggerServerEvent('qb-phone:server:sendNewMail', {
    sender = 'Police',
    subject = 'Citation',
    message = 'You got a ticket'
})

-- Direct qs-smartphone usage
TriggerServerEvent('qs-smartphone:server:sendNewMail', {
    sender = 'Police',
    subject = 'Citation',
    message = 'You got a ticket',
    button = {}
})
```

**After:**
```lua
-- Unified approach - works with any supported phone resource
lib.email.send('Police', 'Citation', 'You got a ticket')
```

### From Custom Email Systems
```lua
-- Replace custom detection logic
local function sendEmail(sender, subject, message)
    -- Old way - manual detection
    if GetResourceState('qb-phone') == 'started' then
        -- qb-phone specific code
    elseif GetResourceState('qs-smartphone') == 'started' then
        -- qs-smartphone specific code
    end
end

-- New way - automatic detection
local function sendEmail(sender, subject, message)
    return lib.email.send(sender, subject, message)
end
```