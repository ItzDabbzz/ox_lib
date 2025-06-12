--[[
    https://github.com/overextended/ox_lib
    https://github.com/ItzDabbzz/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 ItzDabbzz <https://github.com/ItzDabbzz>
]]

---@class OxEmail
lib.email = {}

local detectedPhoneResource = nil
local sendEmailFunction = nil

--- Table of supported phone resources with their configurations
local phoneResources = {
    {
        name = 'qb-phone',
        priority = 1,
        handler = function(sender, subject, message)
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender = sender,
                subject = subject,
                message = message,
            })
        end
    },
    {
        name = 'qs-smartphone',
        priority = 2,
        handler = function(sender, subject, message, button)
            TriggerServerEvent('qs-smartphone:server:sendNewMail', {
                sender = sender,
                subject = subject,
                message = message,
                button = button and button or {}
            })
        end
    },
    {
        name = 'qs-smartphone-pro',
        priority = 3,
        handler = function(sender, subject, message)
            TriggerServerEvent('phone:sendNewMail', {
                sender = sender,
                subject = subject,
                message = message
            })
        end
    },
    {
        name = 'high-phone',
        priority = 4,
        handler = function(sender, subject, message)
            local senderData = {
                address = type(sender) == 'table' and sender.address or sender,
                name = type(sender) == 'table' and sender.name or sender,
                photo = type(sender) == 'table' and sender.photo or ''
            }
            TriggerServerEvent('high_phone:sendMailFromServer', senderData, subject, message, {})
        end
    },
    {
        name = 'npwd-phone',
        priority = 5,
        handler = function(sender, subject, message)
            exports['npwd']:createNotification({
                notisId = 'npwd:emailNotification',
                appId = 'EMAIL',
                content = message,
                secondaryTitle = subject,
                keepOpen = false,
                duration = 5000,
                path = '/email',
            })
        end
    },
    {
        name = 'lb-phone',
        priority = 6,
        handler = function(sender, subject, message)
            TriggerServerEvent('ox_lib:sendEmail', {
                sender = sender,
                subject = subject,
                message = message,
                resource = 'lb-phone'
            })
        end
    },
    {
        name = 'yseries',
        priority = 7,
        handler = function(sender, subject, message)
            TriggerServerEvent('ox_lib:sendEmail', {
                sender = sender,
                subject = subject,
                message = message,
                resource = 'yseries'
            })
        end
    },
    {
        name = 'yflip-phone',
        priority = 8,
        handler = function(sender, subject, message)
            TriggerServerEvent('ox_lib:sendEmail', {
                sender = sender,
                subject = subject,
                message = message,
                resource = 'yflip-phone'
            })
        end
    },
    {
        name = 'okokPhone',
        priority = 9,
        handler = function(sender, subject, message)
            TriggerServerEvent('ox_lib:sendEmail', {
                sender = sender,
                subject = subject,
                message = message,
                resource = 'okokPhone'
            })
        end
    },
    {
        name = 'gks-phone',
        priority = 10,
        handler = function(sender, subject, message)
            exports['gksphone']:SendNewMail({
                sender = sender,
                image = '/html/static/img/icons/mail.png',
                subject = subject,
                message = message
            })
        end
    },
    {
        name = 'gksphone',
        priority = 11,
        handler = function(sender, subject, message)
            exports['gksphone']:SendNewMail({
                sender = sender,
                image = '/html/static/img/icons/mail.png',
                subject = subject,
                message = message
            })
        end
    },
    {
        name = 'roadphone',
        priority = 12,
        handler = function(sender, subject, message)
            exports['roadphone']:sendMail({
                sender = sender,
                subject = subject,
                message = message
            })
        end
    }
}

--- Detects and initializes the phone resource system
---@return boolean success Whether a phone resource was detected and initialized
local function detectPhoneResource()
    if detectedPhoneResource and sendEmailFunction then
        return true
    end

    -- Sort resources by priority (lower number = higher priority)
    table.sort(phoneResources, function(a, b)
        return a.priority < b.priority
    end)

    for _, resource in ipairs(phoneResources) do
        if GetResourceState(resource.name) == 'started' then
            detectedPhoneResource = resource.name
            sendEmailFunction = resource.handler

            lib.print.info(('Email system initialized with phone resource: %s'):format(resource.name))
            return true
        end
    end

    lib.print.warn('No supported phone resource detected')
    return false
end

--- Validates email parameters
---@param sender string|table The email sender
---@param subject string The email subject
---@param message string The email message
---@return boolean valid Whether the parameters are valid
local function validateEmailParams(sender, subject, message)
    if not lib.assert.notNil(sender, 'Email sender') then
        return false
    end

    if not lib.assert.type(subject, 'string', 'Email subject') then
        return false
    end

    if not lib.assert.type(message, 'string', 'Email message') then
        return false
    end

    if not lib.assert.notEmpty(subject, 'Email subject') then
        return false
    end

    if not lib.assert.notEmpty(message, 'Email message') then
        return false
    end

    -- Validate sender based on type
    if type(sender) == 'string' then
        if not lib.assert.notEmpty(sender, 'Email sender') then
            return false
        end
    elseif type(sender) == 'table' then
        if not lib.assert.notNil(sender.name or sender.address, 'Email sender name/address') then
            return false
        end
    else
        lib.print.error('Email sender must be string or table')
        return false
    end

    return true
end

--- Sends an email using the detected phone resource
---@param sender string|table The email sender (string for simple sender, table for advanced)
---@param subject string The email subject line
---@param message string The email message content
---@return boolean success Whether the email was sent successfully
function lib.email.send(sender, subject, message)
    -- Validate parameters
    if not validateEmailParams(sender, subject, message) then
        lib.print.error('Invalid email parameters')
        return false
    end

    -- Ensure phone resource is detected
    if not detectPhoneResource() then
        lib.print.error('No phone resource available for sending emails')
        return false
    end

    -- Attempt to send email
    local success, error = pcall(sendEmailFunction, sender, subject, message)

    if not success then
        lib.print.error(('Failed to send email: %s'):format(error))
        return false
    end

    lib.print.verbose(('Email sent successfully via %s'):format(detectedPhoneResource))
    return true
end

--- Sends an email with advanced sender information
---@param senderData table Advanced sender data {name: string, address?: string, photo?: string}
---@param subject string The email subject line
---@param message string The email message content
---@return boolean success Whether the email was sent successfully
function lib.email.sendAdvanced(senderData, subject, message)
    if not lib.assert.type(senderData, 'table', 'Sender data') then
        return false
    end

    if not lib.assert.notEmpty(senderData.name, 'Sender name') then
        return false
    end

    return lib.email.send(senderData, subject, message)
end

--- Sends a simple email with string sender
---@param senderName string The sender's name
---@param subject string The email subject line
---@param message string The email message content
---@return boolean success Whether the email was sent successfully
function lib.email.sendSimple(senderName, subject, message)
    return lib.email.send(senderName, subject, message)
end

--- Gets the currently detected phone resource
---@return string? phoneResource The name of the detected phone resource
function lib.email.getPhoneResource()
    detectPhoneResource()
    return detectedPhoneResource
end

--- Checks if email functionality is available
---@return boolean available Whether email can be sent
function lib.email.isAvailable()
    return detectPhoneResource()
end

--- Refreshes phone resource detection
---@return boolean success Whether a phone resource was detected after refresh
function lib.email.refresh()
    detectedPhoneResource = nil
    sendEmailFunction = nil
    return detectPhoneResource()
end

--- Validates email content for common issues
---@param subject string The email subject
---@param message string The email message
---@return boolean valid, string? error Whether content is valid and optional error message
function lib.email.validateContent(subject, message)
    if not lib.assert.type(subject, 'string', 'Subject') then
        return false, 'Subject must be a string'
    end

    if not lib.assert.type(message, 'string', 'Message') then
        return false, 'Message must be a string'
    end

    -- Check length limits
    if #subject > 100 then
        return false, 'Subject too long (max 100 characters)'
    end

    if #message > 1000 then
        return false, 'Message too long (max 1000 characters)'
    end

    -- Check for empty content
    if subject:match('^%s*$') then
        return false, 'Subject cannot be empty'
    end

    if message:match('^%s*$') then
        return false, 'Message cannot be empty'
    end

    return true
end

-- Initialize phone resource detection
CreateThread(function()
    Wait(1000) -- Wait for resources to load
    detectPhoneResource()
end)

-- Re-detect phone resources when resources start/stop
AddEventHandler('onClientResourceStart', function(resourceName)
    for _, resource in ipairs(phoneResources) do
        if resource.name == resourceName then
            lib.print.info(('Phone resource started: %s'):format(resourceName))
            lib.email.refresh()
            break
        end
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if detectedPhoneResource == resourceName then
        lib.print.warn(('Active phone resource stopped: %s'):format(resourceName))
        lib.email.refresh()
    end
end)

return lib.email
