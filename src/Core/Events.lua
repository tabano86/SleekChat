local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

local Events = {}

local eventMap = {
    CHAT_MSG_SAY        = "SAY",
    CHAT_MSG_YELL       = "YELL",
    CHAT_MSG_PARTY      = "PARTY",
    CHAT_MSG_GUILD      = "GUILD",
    CHAT_MSG_RAID       = "RAID",
    CHAT_MSG_WHISPER    = "WHISPER",
}

function Events:Initialize(addonObj)
    local frame = CreateFrame("Frame")
    for event in pairs(eventMap) do
        frame:RegisterEvent(event)
    end
    frame:RegisterEvent("CHAT_MSG_SYSTEM")

    frame:SetScript("OnEvent", function(_, event, ...)
        if eventMap[event] then
            local channel = eventMap[event]
            if addonObj.db.profile.channels[channel] then
                local text, sender = ...
                if addon.ChatFrame and addon.ChatFrame.AddMessage then
                    addon.ChatFrame:AddMessage(text, channel, sender)
                end
                if channel == "WHISPER" and addon.Notifications then
                    addon.Notifications:ShowWhisperAlert(sender, text)
                end
            end
        elseif event == "CHAT_MSG_SYSTEM" then
            local text = ...
            if addon.ChatFrame and addon.ChatFrame.AddMessage then
                addon.ChatFrame:AddMessage(text, "SYSTEM")
            end
        end
    end)
end

return Events
