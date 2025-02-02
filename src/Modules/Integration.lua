local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

function Integration:SendToDiscord(text, channel, sender)
    -- Stub: Implement HTTP POST to Discord webhook.
end

function Integration:SyncMessage(text, channel, sender)
    -- Stub: Implement cross-character syncing.
end

return Integration
