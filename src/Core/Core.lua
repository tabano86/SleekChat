-- Core/Core.lua
local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

function Core.GetDefaults()
    -- Full user DB defaults, referencing new features (stubs + existing)
    return {
        profile = {
            version = 21,
            showDefaultChat = false,
            debug = false,

            -- Basic visual and theme settings
            backgroundOpacity = 0.8,
            darkMode = false,
            font = "Friz Quadrata",
            fontSize = 12,
            scrollSpeed = 3,
            timestamps = true,
            timestampFormat = "[%H:%M]",

            -- Behavior
            autoHideInCombat = false,
            enablePinning = true,
            chatLocked = false,
            autoRejoinChannels = true,

            -- Expanded advanced linking / item display
            advancedLinkingEnabled = true,

            -- Regex-based filter
            regexFilters = {},

            -- Notification & alerts
            enableNotifications = true,
            notificationSound = "None",
            soundVolume = 1.0,
            flashTaskbar = false,

            -- Mute / spam
            muteList = {},
            blockedKeywords = { "badword1", "badword2" },

            -- Tabs & channels
            tabs = {
                {
                    name = "General",
                    filters = { SAY=true, YELL=true, PARTY=true, RAID=true, GUILD=true, WHISPER=true },
                },
                {
                    name = "Combat",
                    filters = { COMBAT=true, RAIDWARNING=true, MONSTER=true, BOSS=true },
                },
                {
                    name = "System",
                    filters = { SYSTEM=true },
                },
                {
                    name = "All",
                    filters = {},
                },
            },
            tabOrientation = "Horizontal",

            -- Chat history
            historySize = 2000,
            messageHistory = {},

            -- Additional placeholders
            pinnedMessages = {},
            mentionKeywords = { "@" .. (UnitName("player") or "Player") },
            unreadCounts = {},
            channels = {},     -- Extra user-defined channels
            position = { point="CENTER", relPoint="CENTER", x=0, y=0 },
            width = 600,
            height = 400,
        },
    }
end

local function ApplyMigrations(db)
    if db.profile.version < 21 then
        -- Example migration
        db.profile.version = 21
    end
end

local function RegisterCommands(addonObj)
    addonObj:RegisterChatCommand("sleekchat", function(input)
        if input and input ~= "" then
            addonObj:Print(L.unknown_command .. ": " .. input)
        else
            addonObj.ShowConfig()
        end
    end)
end

function Core:Initialize(addonObj)
    if not addonObj.db then error("DB not ready!") end
    ApplyMigrations(addonObj.db)

    RegisterCommands(addonObj)
end

return Core
