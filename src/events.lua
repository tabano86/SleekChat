-- events.lua
local Events = {}

function Events.ProcessMessage(prefix, message, channel, sender, profile)
    -- For testability, the GUID is omitted (or can be passed in).
    local guid = nil
    local class = nil
    if guid and guid ~= "" then
        local _, engClass = GetPlayerInfoByGUID(guid)
        class = engClass or nil
    end

    local msgData = {
        text    = message,
        sender  = sender,
        channel = (channel:match("CHAT_MSG_(.*)") or channel),
        class   = class,
        time    = os.date(profile.timestampFormat or "[%H:%M]"),
    }
    return msgData
end

SleekChat = SleekChat or {}
SleekChat.Events = Events
