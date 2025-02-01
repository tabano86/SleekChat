-- events.lua
local Util = require("Util") or _G.SleekChat.Util
local Logger = require("Logger") or _G.SleekChat.Logger

local Events = Util.singleton("Events", function()
    local self = {}

    function self.ProcessMessage(prefix, message, channel, sender, profile)
        local guid = nil  -- GUID logic disabled by default.
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

    return self
end)

return Events
