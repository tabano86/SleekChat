-- Modules/Integration.lua
local _, addon = ...
addon.Integration = {}
local Integration = addon.Integration

function Integration:SendToDiscord(text, channel, sender)
    -- Integration stub: send to external system
end

function Integration:SyncMessage(text, channel, sender)
    -- Integration stub: cross-character syncing
end

return Integration
