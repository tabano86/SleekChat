local _, addon = ...
addon.Integration={}
local Integration= addon.Integration

function Integration:SendToDiscord(text,channel,sender)
    -- Stub for cross-sending to external system
end

function Integration:SyncMessage(text,channel,sender)
    -- Stub for cross-character or external bridging
end

return Integration
