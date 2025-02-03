-- Modules/ChatModeration.lua
local _, addon = ...
addon.ChatModeration = {}
local ChatModeration = addon.ChatModeration

function ChatModeration:Initialize(addonObj)
    self.db = addonObj.db
end

-- Check if sender is in the user’s mute list
function ChatModeration:IsMuted(sender)
    local mutes = self.db.profile.muteList or {}
    for _, name in ipairs(mutes) do
        if name:lower() == (sender or ""):lower() then
            return true
        end
    end
    return false
end

-- Basic keyword filtering
function ChatModeration:FilterMessage(text)
    local blocked = self.db.profile.blockedKeywords or {}
    for _, kw in ipairs(blocked) do
        text = text:gsub(kw, string.rep("*", #kw))
    end
    return text
end

return ChatModeration
