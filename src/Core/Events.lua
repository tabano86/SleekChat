local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Events = {}
local Events = addon.Events

local eventMap = {
    CHAT_MSG_SAY = "SAY",
    CHAT_MSG_YELL = "YELL",
    CHAT_MSG_PARTY = "PARTY",
    CHAT_MSG_GUILD = "GUILD",
    CHAT_MSG_RAID = "RAID",
    CHAT_MSG_WHISPER = "WHISPER"
}

function Events.Initialize(self)
    for event in pairs(eventMap) do
        self:RegisterEvent(event, "HandleChatEvent")
    end
end

function Events.HandleChatEvent(self, event, text, sender, ...)
    if not self.db.profile.channels[eventMap[event]] then return end

    self.History.AddMessage(text, sender, eventMap[event])
    self.ChatFrame.AddMessage(text, sender, eventMap[event])

    if event == "CHAT_MSG_WHISPER" then
        self.Notifications.ShowWhisperAlert(sender, text)
    end
end
