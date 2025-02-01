-- core.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Core and _G.SleekChat.Core._loaded then return end
local Core = {}  -- local module table
local Logger = _G.SleekChat.Logger

Logger:Debug("Core Loading...")

function Core.getDefaults()
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
            position = { "CENTER", "UIParent", "CENTER", 0, 0 },
            historySize = 500,
            tabs = { "SAY", "YELL", "PARTY", "GUILD", "RAID", "WHISPER" },
            debug = false,
            enableNotifications = true,
        }
    }
end

function Core.computeActions(profile)
    local actions = {}
    actions.hideChatFrames = profile.hideDefault
    return actions
end

function Core.ApplySettings(instance)
    local actions = Core.computeActions(instance.db.profile)
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

function Core.Initialize(instance)
    Logger:Info("Core module initialized.")
    instance.ApplySettings = Core.ApplySettings
end

function Core.Enable(instance)
    Logger:Info("Core module enabled.")
end

Logger:Debug("Core Loaded!")
Core._loaded = true
local registry = _G.SleekChat.Modules
registry:register("Core", Core)
