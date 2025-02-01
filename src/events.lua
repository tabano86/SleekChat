-- events.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Events and _G.SleekChat.Events._loaded then return end
_G.SleekChat.Events = _G.SleekChat.Events or {}
local Events = _G.SleekChat.Events
local Logger = _G.SleekChat.Logger

Logger:Debug("Events Loading...")

function Events.ProcessMessage(prefix, message, channel, sender, profile)
    local guid = nil  -- GUID logic disabled.
    local class
    if guid and guid ~= "" then
        local _, engClass = GetPlayerInfoByGUID(guid)
        class = engClass
    end
    local msg = {
        text    = message,
        sender  = sender,
        channel = (channel:match("CHAT_MSG_(.*)") or channel),
        class   = class,
        time    = os.date(profile.timestampFormat or "[%H:%M]"),
    }
    Logger:Debug("Events.ProcessMessage: " .. message)
    return msg
end

Logger:Debug("Events Loaded!")
Events._loaded = true
