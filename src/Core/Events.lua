local _, addon = ...
local Events = {}

-- We won't hardcode every single channel here, but some ephemeral ones:
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
    -- Player-joined channels (Trade, LocalDefense, LFG, custom) come through "CHAT_MSG_CHANNEL"
}

function Events:Initialize(addonObj)
    local frame = CreateFrame("Frame")

    -- Register the known events
    for _, data in pairs(CHANNEL_COMMANDS) do
        frame:RegisterEvent(data.event)
    end
    frame:RegisterEvent("CHAT_MSG_CHANNEL") -- covers "Trade", "LocalDefense", etc.
    frame:RegisterEvent("CHAT_MSG_SYSTEM")

    -- optional: fade in/out on combat
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_SYSTEM" then
            -- e.g. system messages
            addon.ChatFrame:AddMessage(..., "SYSTEM")
            return
        elseif event == "PLAYER_REGEN_DISABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame.mainFrame then
                addon.ChatFrame.mainFrame:SetAlpha(0)
            end
            return
        elseif event == "PLAYER_REGEN_ENABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame.mainFrame then
                addon.ChatFrame.mainFrame:SetAlpha(1)
            end
            return
        elseif event == "CHAT_MSG_CHANNEL" then
            local msg, sender, _, _, channelName = ...
            -- Channel name might come with region suffix, e.g. "Trade - City"
            -- We typically store just "Trade" or the full string.
            addon.ChatFrame:AddMessage(msg, channelName, sender)
        else
            -- Possibly one of the known ones from CHANNEL_COMMANDS
            local msg, sender = ...
            for ch, data in pairs(CHANNEL_COMMANDS) do
                if event == data.event then
                    addon.ChatFrame:AddMessage(msg, ch, sender)
                    if ch == "WHISPER" then
                        addon.Notifications:ShowWhisperAlert(sender, msg)
                        addon.ChatFrame:HandleWhisper(sender, msg)
                    end
                    break
                end
            end
        end
    end)
end

addon.Events = Events
