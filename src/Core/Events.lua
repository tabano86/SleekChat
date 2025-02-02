local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

local Events = {}

local eventMap = {
    CHAT_MSG_SAY    = "SAY",
    CHAT_MSG_YELL   = "YELL",
    CHAT_MSG_PARTY  = "PARTY",
    CHAT_MSG_GUILD  = "GUILD",
    CHAT_MSG_RAID   = "RAID",
    CHAT_MSG_WHISPER = "WHISPER",
}

local function ProcessChatEvent(addonObj, eventName, text, sender, ...)
    local channel = eventMap[eventName]
    if not (addonObj.db.profile.channels and addonObj.db.profile.channels[channel]) then
        return
    end
    if addonObj.History and addonObj.History.AddMessage then
        addonObj.History:AddMessage(text, sender, channel)
    end
    if addonObj.ChatFrame and addonObj.ChatFrame.AddMessage then
        addonObj.ChatFrame:AddMessage(text, sender, channel)
    end
    if eventName == "CHAT_MSG_WHISPER" and addonObj.Notifications and addonObj.Notifications.ShowWhisperAlert then
        addonObj.Notifications:ShowWhisperAlert(sender, text)
    end
end

function Events:Initialize(addonObj)
    for eventName in pairs(eventMap) do
        addonObj:RegisterEvent(eventName, function(...) ProcessChatEvent(addonObj, ...) end)
    end
end

return Events
