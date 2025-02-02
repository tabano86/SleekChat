local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

function Integration:SendToDiscord(text, channel, sender)
    -- Stub: implement HTTP POST to Discord if desired
end

function Integration:SyncMessage(text, channel, sender)
    -- Stub: implement cross-character syncing
end

return Integration
