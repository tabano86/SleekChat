local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

function Integration:SendToDiscord(text, channel, sender)
    -- Stub: implement HTTP POST to Discord webhook if desired.
end

function Integration:SyncMessage(text, channel, sender)
    -- Stub: implement cross-character syncing using Blizzard APIs.
end

return Integration
