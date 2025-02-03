local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

function Integration:SendToDiscord(text, channel, sender)
    -- If you want to do an HTTP POST from an external client,
    -- you'd do it here. Not possible purely in-game.
end

function Integration:SyncMessage(text, channel, sender)
    -- Cross-character syncing or RealID bridging, if desired
end

return Integration
