local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

-- Stub: Send a message to Discord via webhook.
function Integration:SendToDiscord(text, channel, sender)
    -- Future: Implement HTTP POST to a Discord webhook URL.
    -- Example:
    -- local payload = { content = string.format("[%s] %s: %s", channel, sender, text) }
    -- Your HTTP client code here.
end

-- Stub: Sync messages across characters.
function Integration:SyncMessage(text, channel, sender)
    -- Future: Use Blizzard APIs or Battle.net integration for cross-character sync.
end

return Integration
