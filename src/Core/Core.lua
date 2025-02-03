local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

function Core.GetDefaults()
    return {
        profile = {
            enable = true,
            version = 6,
            layout = "CLASSIC",
            position = { point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", x = 50, y = 50 },
            width = 600,
            height = 400,
            tabWidth = 80,
            inputHeight = 20,
            classColors = true,
            timestamps = true,
            timestampFormat = "[%H:%M]",
            urlDetection = true,
            enableNotifications = true,
            font = "Friz Quadrata",
            fontSize = 12,
            historySize = 1000,
            channels = {},  -- We store toggles here: channels["Trade"] = true
            backgroundOpacity = 0.8,
            debug = false,
            showDefaultChat = false,
            enablePinning = true,
            enableAutoComplete = true,
            scrollSpeed = 3,
            customFontColor = {1,1,1,1},
            notificationSound = "None",
            soundVolume = 1.0,
            flashTaskbar = false,
            messageHistory = {},
            sidebarEnabled = false,
            threadedReplies = false,
            darkMode = false,
            profanityFilter = false,
            muteList = {},
            customTabOrder = false,
            tabRenaming = false,
            autoCollapseTabs = false,
            tabColor = {0.2, 0.2, 0.2, 0.8},
            unreadBadge = false,
            tabTooltips = false,
            tabLocking = false,
            smartTabGrouping = false,
            dynamicTabScrolling = false,
            tabNotificationSound = "None",
            tabHistoryPreview = false,
            tabFlashing = false,
            tabFont = "Friz Quadrata",
            tabFontSize = 12,
            autoSwitchTab = false,
            clearUnreadOnDoubleClick = false,
            tabLockIcon = false,
            dragDropFileSupport = false,
            customHotkeys = "",
            tabSessionPersistence = false,
            animatedTabTransitions = false,
            autoHideInCombat = false,
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
                    addon:PrintDebug(L.url_copied or ("URL copied: " .. data.url))
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
    if addonObj.db.profile.version < 5 then
        addonObj.db.profile.autoHideInCombat = addonObj.db.profile.autoHideInCombat or false
        addonObj.db.profile.version = 5
    end
end

local function RegisterCommands(addonObj)
    addonObj:RegisterChatCommand("scstatus", function()
        addonObj:Print("SleekChat Status:")
        addonObj:Print("Debug: " .. (addonObj.db.profile.debug and "ON" or "OFF"))
        addonObj:Print("Default Chat Visible: " .. (addonObj.db.profile.showDefaultChat and "YES" or "NO"))
    end)
end

function Core:Initialize(addonObj)
    if not addonObj.db then
        error("Database not initialized!")
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
