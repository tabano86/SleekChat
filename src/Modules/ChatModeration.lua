local _, addon = ...
addon.ChatModeration = {}
local ChatModeration = addon.ChatModeration

ChatModeration.blockedKeywords = { "badword1", "badword2" }

function ChatModeration:FilterMessage(text)
    for _, keyword in ipairs(self.blockedKeywords) do
        text = text:gsub(keyword, string.rep("*", #keyword))
    end
    return text
end

function ChatModeration:IsMuted(sender)
    local muteList = addon.db.profile.muteList or {}
    for _, muted in ipairs(muteList) do
        if muted:lower() == sender:lower() then
            return true
        end
    end
    return false
end

return ChatModeration
