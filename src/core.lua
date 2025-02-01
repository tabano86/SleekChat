-- core.lua
local Util = require("Util") or _G.SleekChat.Util
local Logger = require("Logger") or _G.SleekChat.Logger

local Core = Util.singleton("Core", function()
    local self = {}

    function self.getDefaults()
        return {
            profile = {
                hideDefault = true,
                classColors = true,
                timestamps = true,
                timestampFormat = "[%H:%M]",
                urlDetection = true,
                font = "Fonts\\FRIZQT__.TTF",
                fontSize = 12,
                bgColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                width = 600,
                height = 350,
                position = { "CENTER", UIParent, "CENTER", 0, 0 },
                historySize = 500,
                tabs = { "SAY", "YELL", "PARTY", "GUILD", "RAID", "WHISPER" },
                debug = false,
                enableNotifications = true,
            }
        }
    end

    function self.computeActions(profile)
        local actions = {}
        actions.hideChatFrames = profile.hideDefault
        return actions
    end

    function self.ApplySettings(instance)
        local actions = self.computeActions(instance.db.profile)
        if actions.hideChatFrames then
            for i = 1, NUM_CHAT_WINDOWS do
                if _G["ChatFrame" .. i] then
                    _G["ChatFrame" .. i]:Hide()
                end
            end
        else
            for i = 1, NUM_CHAT_WINDOWS do
                if _G["ChatFrame" .. i] then
                    _G["ChatFrame" .. i]:Show()
                end
            end
        end
        Logger:Debug("Core.ApplySettings: hideChatFrames = " .. tostring(actions.hideChatFrames))
    end

    function self.Initialize(instance)
        Logger:Info("Core module initialized.")
        instance.ApplySettings = self.ApplySettings
    end

    function self.Enable(instance)
        Logger:Info("Core module enabled.")
    end

    return self
end)

return Core
