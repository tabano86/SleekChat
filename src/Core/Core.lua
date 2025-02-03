local _, addon = ...
local AceLocale= LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

function Core.GetDefaults()
    return {
        profile = {
            version = 7,
            debug = false,
            showDefaultChat = false,

            -- Window position + size
            position = { point="BOTTOMLEFT", relPoint="BOTTOMLEFT", x=50, y=50 },
            width = 700,
            height= 500,
            backgroundOpacity= 0.8,
            darkMode = false,

            -- Timestamps
            timestamps = true,
            timestampFormat = "[%H:%M]",
            enablePinning = true,
            enableEmotes = false,
            historySize = 1000,

            -- Chat channels toggles
            channels = {}, -- e.g. ["Trade - City"] = true

            -- Font
            font = "Friz Quadrata",
            fontSize = 12,
            scrollSpeed = 3,

            -- Notification
            enableNotifications = true,
            notificationSound = "None",
            soundVolume = 1.0,
            flashTaskbar = false,

            -- Mute + filter
            profanityFilter = false,
            muteList = {},

            -- Combat fade
            autoHideInCombat = false,

            -- "System" & "Combat" placeholders, to store them if we want
            storeSystem = true,
            storeCombat = true,

            -- Where we store messages
            messageHistory = {},
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
                    addon:PrintDebug(L.url_copied or ("URL copied to clipboard: ".. data.url))
                end
            end
        end,
        timeout = 0,
        whileDead= true,
        hideOnEscape= true,
        hasEditBox= false,
        preferIndex= 3,
    }
end

local function ApplyMigrations(addonObj)
    if addonObj.db.profile.version < 7 then
        addonObj.db.profile.messageHistory = addonObj.db.profile.messageHistory or {}
        addonObj.db.profile.version = 7
    end
end

local function RegisterCommands(addonObj)
    addonObj:RegisterChatCommand("scstatus", function()
        addonObj:Print("SleekChat Status:")
        addonObj:Print("Debug: "..(addonObj.db.profile.debug and "ON" or "OFF"))
        addonObj:Print("Default Chat: "..(addonObj.db.profile.showDefaultChat and "Visible" or "Hidden"))
    end)
end

function Core:Initialize(addonObj)
    if not addonObj.db then
        error("Database not ready!")
        return
    end
    SetupStaticPopup()
    ApplyMigrations(addonObj)
    RegisterCommands(addonObj)
end

function Core:ShowConfig()
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end

return Core
