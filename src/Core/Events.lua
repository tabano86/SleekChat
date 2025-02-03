local _, addon = ...
local Events = {}

function Events:Initialize(addonObj)
    local frame = CreateFrame("Frame")

    -- We register chat events we want:
    local chatEvents = {
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_RAID",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_SYSTEM",
    }
    for _, e in ipairs(chatEvents) do
        frame:RegisterEvent(e)
    end

    frame:SetScript("OnEvent", function(_, event, ...)
        if not addon.ChatFrame or not addon.ChatFrame.AddIncoming then return end
        if event == "CHAT_MSG_SYSTEM" then
            -- could display system messages if you want
            return
        elseif event == "CHAT_MSG_CHANNEL" then
            local msg, sender, _, _, channelName = ...
            addon.ChatFrame:AddIncoming(msg, sender, channelName)
        else
            -- e.g. "CHAT_MSG_SAY" => the channel is "SAY"
            local msg, sender = ...
            local channel = event:match("CHAT_MSG_(%S+)")
            if channel then
                channel = channel:upper() -- "SAY","YELL","PARTY","WHISPER", etc.
            end
            addon.ChatFrame:AddIncoming(msg, sender, channel or "ALL")
        end
    end)
end

addon.Events = Events
