-- core.lua
-- Core module: handles defaults, initialization, and applying settings.
local Core = {}

-- Pure function: returns the defaults table.
function Core.getDefaults()
    return {
        profile = {
            hideDefault   = true,
            classColors   = true,
            timestamps    = true,
            timestampFormat = "[%H:%M]",
            urlDetection  = true,
            font          = "Fonts\\FRIZQT__.TTF",
            fontSize      = 12,
            bgColor       = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
            width         = 600,
            height        = 350,
            position      = {"CENTER", nil, "CENTER", 0, 0},
            historySize   = 500,
            tabs          = {"SAY", "YELL", "PARTY", "GUILD", "RAID", "WHISPER"},
            debug         = false,
            enableNotifications = true,
        }
    }
end

-- Pure function: compute desired actions based on profile.
function Core.computeActions(profile)
    local actions = {}
    actions.hideChatFrames = profile.hideDefault
    return actions
end

-- Side-effect function: apply settings to the environment.
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
    if instance.db.profile.debug then
        instance:Print("Applied settings: hideChatFrames = " .. tostring(actions.hideChatFrames))
    end
end

-- Initialization function that accepts the addon instance.
function Core.Initialize(instance)
    if instance.db.profile.debug then
        instance:Print("Core module initialized.")
    end
end

-- Enable function (can include further logic as needed).
function Core.Enable(instance)
    if instance.db.profile.debug then
        instance:Print("Core module enabled.")
    end
end

Core.ApplySettings = Core.ApplySettings
SleekChat = SleekChat or {}
SleekChat.Core = Core
