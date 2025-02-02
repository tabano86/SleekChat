local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Events = {}
local Events = addon.Events

-- Central mapping for event-to-channel lookups
local eventMap = {
    CHAT_MSG_SAY    = "SAY",
    CHAT_MSG_YELL   = "YELL",
    CHAT_MSG_PARTY  = "PARTY",
    CHAT_MSG_GUILD  = "GUILD",
    CHAT_MSG_RAID   = "RAID",
    CHAT_MSG_WHISPER = "WHISPER"
}

-- Helper function to register all relevant events
local function RegisterRelevantEvents(self)
    for eventName in pairs(eventMap) do
        self:RegisterEvent(eventName, "HandleChatEvent")
    end
end

-- Helper function to process a single chat event
local function ProcessChatEvent(self, eventName, text, sender, ...)
    -- Check if this event's corresponding channel is enabled
    local channel = eventMap[eventName]
    if not self.db.profile.channels[channel] then return end

    -- Record in history and display in chat
    self.History.AddMessage(text, sender, channel)
    self.ChatFrame.AddMessage(text, sender, channel)

    -- Special handling for whispers
    if eventName == "CHAT_MSG_WHISPER" then
        self.Notifications.ShowWhisperAlert(sender, text)
    end
end

-- Public initialization method
function Events.Initialize(self)
    RegisterRelevantEvents(self)
end

-- Main handler for chat events
function Events.HandleChatEvent(self, event, text, sender, ...)
    ProcessChatEvent(self, event, text, sender, ...)
end
