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

    for _, data in pairs(CHANNEL_COMMANDS) do
        frame:RegisterEvent(data.event)
    end
    frame:RegisterEvent("CHAT_MSG_SYSTEM")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_SYSTEM" then
            addonObj.ChatFrame:AddMessage(..., "SYSTEM")
            return
        elseif event == "PLAYER_REGEN_DISABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame.chatFrame then
                addonObj.ChatFrame.chatFrame:SetAlpha(0) -- fade out
            end
            return
        elseif event == "PLAYER_REGEN_ENABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame.chatFrame then
                addonObj.ChatFrame.chatFrame:SetAlpha(1) -- restore
            end
            return
        end

        -- Normal chat events
        local msg, sender = ...
        for channel, data in pairs(CHANNEL_COMMANDS) do
            if event == data.event then
                if data.channel then
                    if addonObj.db.profile.channels[data.channel:upper()] then
                        addonObj.ChatFrame:AddMessage(msg, data.channel, sender)
                    end
                else
                    if addonObj.db.profile.channels[channel] then
                        addonObj.ChatFrame:AddMessage(msg, channel, sender)
                        if channel == "WHISPER" then
                            addonObj.Notifications:ShowWhisperAlert(sender, msg)
                            addonObj.ChatFrame:HandleWhisper(sender, msg)
                        end
                    end
                end
                break
            end
        end
    end)
end

addon.Events = Events
