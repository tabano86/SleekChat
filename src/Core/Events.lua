local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Events = {}
local Events = addon.Events

local eventMap = {
    CHAT_MSG_SAY    = "SAY",
    CHAT_MSG_YELL   = "YELL",
    CHAT_MSG_PARTY  = "PARTY",
    CHAT_MSG_GUILD  = "GUILD",
    CHAT_MSG_RAID   = "RAID",
    CHAT_MSG_WHISPER = "WHISPER",
}

local function RegisterRelevantEvents(self)
    for eventName in pairs(eventMap) do
        self:RegisterEvent(eventName, "HandleChatEvent")
    end
end

local function ProcessChatEvent(self, eventName, text, sender, ...)
    local channel = eventMap[eventName]
    if not (self.db.profile.channels and self.db.profile.channels[channel]) then
        return
    end
    self.History:AddMessage(text, sender, channel)
    self.ChatFrame:AddMessage(text, sender, channel)
    if eventName == "CHAT_MSG_WHISPER" then
        self.Notifications:ShowWhisperAlert(sender, text)
    end
end

function Events:Initialize(addonObject)
    RegisterRelevantEvents(addonObject)
end

function Events:HandleChatEvent(event, text, sender, ...)
    ProcessChatEvent(self, event, text, sender, ...)
end

return Events
