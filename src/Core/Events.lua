local _, addon = ...
local Events = {}

local EVENT_MAP = {
    CHAT_MSG_SAY     = "SAY",
    CHAT_MSG_YELL    = "YELL",
    CHAT_MSG_PARTY   = "PARTY",
    CHAT_MSG_GUILD   = "GUILD",
    CHAT_MSG_RAID    = "RAID",
    CHAT_MSG_WHISPER = "WHISPER",
}

function Events:Initialize(addonObj)
    local frame = CreateFrame("Frame")

    -- Register events
    frame:RegisterEvent("CHAT_MSG_SYSTEM")
    frame:RegisterEvent("CHAT_MSG_CHANNEL")
    frame:RegisterEvent("CHAT_MSG_SAY")
    frame:RegisterEvent("CHAT_MSG_YELL")
    frame:RegisterEvent("CHAT_MSG_PARTY")
    frame:RegisterEvent("CHAT_MSG_GUILD")
    frame:RegisterEvent("CHAT_MSG_RAID")
    frame:RegisterEvent("CHAT_MSG_WHISPER")

    -- optional: fade in/out in combat
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event=="PLAYER_REGEN_DISABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame.mainFrame then
                addon.ChatFrame.mainFrame:SetAlpha(0)
            end
            return
        elseif event=="PLAYER_REGEN_ENABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame.mainFrame then
                addon.ChatFrame.mainFrame:SetAlpha(1)
            end
            return
        elseif event=="CHAT_MSG_SYSTEM" then
            -- We can skip or handle system messages
            return
        elseif event=="CHAT_MSG_CHANNEL" then
            local msg, sender, _, _, channelName = ...
            if addon.ChatFrame and addon.ChatFrame.AddIncoming then
                addon.ChatFrame:AddIncoming(msg, sender, channelName)
            end
        else
            -- e.g. CHAT_MSG_SAY => "SAY"
            local msg, sender = ...
            local mapped = EVENT_MAP[event] or "ALL"
            if addon.ChatFrame and addon.ChatFrame.AddIncoming then
                addon.ChatFrame:AddIncoming(msg, sender, mapped)
            end
        end
    end)
end

addon.Events = Events
