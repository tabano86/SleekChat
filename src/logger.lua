-- logger.lua
local Util = require("Util") or _G.SleekChat.Util

local Logger = Util.singleton("Logger", function()
    local self = {}

    function self:Info(message)
        print("|cff00ff00[INFO]|r " .. tostring(message))
    end

    function self:Warn(message)
        print("|cffffff00[WARN]|r " .. tostring(message))
    end

    function self:Error(message)
        print("|cffff0000[ERROR]|r " .. tostring(message))
    end

    function self:Debug(message)
        if _G.SleekChat and _G.SleekChat.db and _G.SleekChat.db.profile and _G.SleekChat.db.profile.debug then
            print("|cff00ffff[DEBUG]|r " .. tostring(message))
        end
    end

    return self
end)

return Logger
