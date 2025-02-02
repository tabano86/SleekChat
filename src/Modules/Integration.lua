local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

-- Stub: Send a message to Discord via webhook.
function Integration:SendToDiscord(text, channel, sender)
    -- Future: Implement HTTP POST to Discord webhook URL.
end

-- Stub: Sync messages across characters.
function Integration:SyncMessage(text, channel, sender)
    -- Future: Implement cross-character syncing using Blizzard APIs.
end

return Integration
