local _, addon = ...
local AceEvent = LibStub("AceEvent-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

function Core.GetDefaults()
    return {
        profile = {
            enable = true,
            version = 4,
            layout = "CLASSIC",
            messageFormat = "[{time}] {channel} {sender}: {message}",
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
            channels = {
                SAY = true,
                YELL = true,
                PARTY = true,
                GUILD = true,
                RAID = true,
                WHISPER = true,
                TRADE = true,
                LOCALDEFENSE = true,
                LOOKINGFORGROUP = true,
            },
            backgroundOpacity = 0.8,
            background = {
                texture = "Solid",
                color = { r = 0, g = 0, b = 0, a = 0.8 },
            },
            border = {
                texture = "Blizzard Tooltip",
                size = 16,
            },
            tabs = {
                activeColor = { r = 1, g = 1, b = 1 },
                inactiveColor = { r = 0.5, g = 0.5, b = 0.5 },
            },
            tabUnreadHighlight = true,
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
            -- Tab management
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
        },
    }
end

local function SetupStaticPopup()
    -- Unified definition for opening URLs (used by ChatFrame:HandleURL)
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
                    addon:PrintDebug(L.url_copied or ("URL copied to clipboard: " .. data.url))
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
    if addonObj.db.profile.version < 2 then
        addonObj.db.profile.background = addonObj.db.profile.background or {
            texture = "SleekChat Default",
            opacity = 0.8,
        }
        addonObj.db.profile.border = addonObj.db.profile.border or {
            texture = "SleekChat Simple",
            size = 16,
        }
        addonObj.db.profile.version = 2
    end
    if addonObj.db.profile.version < 4 then
        addonObj.db.profile.darkMode = addonObj.db.profile.darkMode or false
        addonObj.db.profile.profanityFilter = addonObj.db.profile.profanityFilter or false
        addonObj.db.profile.muteList = addonObj.db.profile.muteList or {}
        addonObj.db.profile.channels.TRADE = true
        addonObj.db.profile.channels.LOCALDEFENSE = true
        addonObj.db.profile.channels.LOOKINGFORGROUP = true
        addonObj.db.profile.version = 4
    end
end

local function RegisterCommands(addonObj)
    addonObj:RegisterChatCommand("scstatus", function()
        addonObj:Print("SleekChat Status Report:")
        addonObj:Print("Debug Mode: " .. (addonObj.db.profile.debug and "|cFF00FF00ON" or "|cFFFF0000OFF"))
        addonObj:Print("Default Chat Visible: " .. (addonObj.db.profile.showDefaultChat and "|cFF00FF00YES" or "|cFFFF0000NO"))
        if addon.ChatFrame and addon.ChatFrame.chatFrame then
            addonObj:Print(string.format("Main Frame: %s (Visible: %s)",
                    tostring(addon.ChatFrame.chatFrame),
                    addon.ChatFrame.chatFrame:IsVisible() and "|cFF00FF00YES" or "|cFFFF0000NO"))
        else
            addonObj:Print("Main Frame: |cFFFF0000NOT INITIALIZED")
        end
    end)
end

function Core:Initialize(addonObj)
    if not addonObj.db then
        geterrorhandler()("Critical error: Database not initialized!")
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
