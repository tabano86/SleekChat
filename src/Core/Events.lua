local _, addon = ...
local Events = {}

local CHANNEL_COMMANDS = {
    SAY = { event = "CHAT_MSG_SAY", prefix = "/s " },
    YELL = { event = "CHAT_MSG_YELL", prefix = "/y " },
    PARTY = { event = "CHAT_MSG_PARTY", prefix = "/p " },
    GUILD = { event = "CHAT_MSG_GUILD", prefix = "/g " },
    RAID = { event = "CHAT_MSG_RAID", prefix = "/ra " },
    WHISPER = { event = "CHAT_MSG_WHISPER", prefix = "/w " },
    TRADE = { event = "CHAT_MSG_CHANNEL", channel = "Trade" },
    LOCALDEFENSE = { event = "CHAT_MSG_CHANNEL", channel = "LocalDefense" },
    LOOKINGFORGROUP = { event = "CHAT_MSG_CHANNEL", channel = "LookingForGroup" },
}

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix("SleekChat")
end

function Events:Initialize(addonObj)
    local frame = CreateFrame("Frame")
    for channel, data in pairs(CHANNEL_COMMANDS) do
        frame:RegisterEvent(data.event)
    end
    frame:RegisterEvent("CHAT_MSG_SYSTEM")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_SYSTEM" then
            addon.ChatFrame:AddMessage(..., "SYSTEM")
            return
        end
        for channel, data in pairs(CHANNEL_COMMANDS) do
            if event == data.event then
                local msg, sender = ...
                if data.channel then
                    if addonObj.db.profile.channels[data.channel:upper()] then
                        addon.ChatFrame:AddMessage(msg, data.channel, sender)
                    end
                else
                    if addonObj.db.profile.channels[channel] then
                        addon.ChatFrame:AddMessage(msg, channel, sender)
                        if channel == "WHISPER" then
                            addon.Notifications:ShowWhisperAlert(sender, msg)
                            addon.ChatFrame:HandleWhisper(sender, msg)
                        end
                    end
                end
                break
            end
        end
    end)
end

addon.Events = Events
return Events
