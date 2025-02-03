-- Core/Core.lua
local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

function Core.GetDefaults()
    return {
        profile = {
            version = 20,
            showDefaultChat = false,
            debug = false,
            tabOrientation = "Horizontal",
            enablePinning = true,
            chatLocked = false,
            showWatermark = true,
            animationSpeed = 0.3,
            unreadCounts = {},
            mentionKeywords = { "@" .. UnitName("player") },
            position = { point = "CENTER", relPoint = "CENTER", x = 0, y = 0 },
            width = 600,
            height = 400,
            backgroundOpacity = 0.8,
            darkMode = false,
            timestamps = true,
            timestampFormat = "[%H:%M]",
            enableEmotes = false,
            historySize = 2000,
            channels = {},
            font = "Friz Quadrata",
            fontSize = 12,
            scrollSpeed = 3,
            enableNotifications = true,
            notificationSound = "None",
            soundVolume = 1.0,
            flashTaskbar = false,
            profanityFilter = false,
            muteList = {},
            autoHideInCombat = false,
            messageHistory = {},
            -- For dynamic tab management:
            tabs = {
                { name = "General", filters = { SAY=true, YELL=true, PARTY=true, RAID=true, GUILD=true, WHISPER=true } },
                { name = "Combat", filters = { COMBAT=true, RAIDWARNING=true, MONSTER=true, BOSS=true } },
                { name = "System", filters = { SYSTEM=true } },
                { name = "All", filters = {} },
            },
        },
    }
end

local function SetupStaticPopup()
    StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"] = {
        text = L.open_url_dialog or "Open URL:",
        button1 = L.open or "Open",
        button2 = L.cancel or "Cancel",
        OnAccept = function(self, data)
            if data and data.url then
                if ChatFrame_OpenBrowser then
                    ChatFrame_OpenBrowser(data.url)
                else
                    EditBox_CopyTextToClipboard(data.url)
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = false,
        preferIndex = 3,
    }
end

local function ApplyMigrations(addonObj)
    if addonObj.db.profile.version < 20 then
        if not addonObj.db.profile.messageHistory then
            addonObj.db.profile.messageHistory = {}
        end
        addonObj.db.profile.version = 20
    end
end

local function RegisterCommands(addonObj)
    addonObj:RegisterChatCommand("sleekchat", function(input)
        if input and input ~= "" then
            addonObj:Print("Unknown command: " .. input)
        else
            addonObj.ShowConfig()
        end
    end)
end

function Core:Initialize(addonObj)
    if not addonObj.db then error("DB not ready!") end
    SetupStaticPopup()
    ApplyMigrations(addonObj)
    RegisterCommands(addonObj)
end

return Core
