-- Modules/ChannelRejoin.lua
local _, addon = ...
addon.ChannelRejoin = {}
local ChannelRejoin = addon.ChannelRejoin

function ChannelRejoin:Initialize(addonObj)
    self.db = addonObj.db
    if self.db.profile.autoRejoinChannels then
        self:RejoinChannels()
    end
end

-- Basic stub for rejoining channels on login
function ChannelRejoin:RejoinChannels()
    local userChannels = self.db.profile.channels or {}
    for chName, enabled in pairs(userChannels) do
        if enabled then
            JoinChannelByName(chName)
        end
    end
end

return ChannelRejoin
