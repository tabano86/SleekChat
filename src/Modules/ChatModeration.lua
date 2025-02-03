-- Modules/ChatModeration.lua
local _, addon = ...
addon.ChatModeration = {}
local ChatModeration = addon.ChatModeration

ChatModeration.blockedKeywords = { "badword1", "badword2" }

function ChatModeration:Initialize(addonObj)
    self.db = addonObj.db
end

function ChatModeration:IsMuted(sender)
    local mutes = self.db.profile.muteList or {}
    for _, name in ipairs(mutes) do
        if name:lower() == sender:lower() then return true end
    end
    return false
end

function ChatModeration:FilterMessage(text)
    for _, kw in ipairs(self.blockedKeywords) do
        text = text:gsub(kw, string.rep("*", #kw))
    end
    return text
end

return ChatModeration
