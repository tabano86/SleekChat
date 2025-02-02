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

function Events:Initialize(addonObj)
    -- Register all chat events
    local frame = CreateFrame("Frame")
    for event in pairs(eventMap) do
        frame:RegisterEvent(event)
    end

    frame:SetScript("OnEvent", function(_, event, ...)
        local channel = eventMap[event]
        if channel and addonObj.db.profile.channels[channel] then
            local text, sender = ...
            if addon.ChatFrame and addon.ChatFrame.AddMessage then
                addon.ChatFrame:AddMessage(text, channel, sender)
            end
        end
    end)

    -- System message handling
    frame:RegisterEvent("CHAT_MSG_SYSTEM")
    frame:SetScript("OnEvent", function(_, event, text)
        if event == "CHAT_MSG_SYSTEM" then
            if addon.ChatFrame and addon.ChatFrame.AddMessage then
                addon.ChatFrame:AddMessage(text, "SYSTEM")
            end
        end
    end)
end

return Events
