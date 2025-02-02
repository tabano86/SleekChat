local _, addon = ...
local AceEvent = LibStub("AceEvent-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

function Core.GetDefaults()
    return {
        profile = {
            debug = true,
            showDefaultChat = false,
            enable = true,
            version = 2,
            position = { point = "CENTER", relPoint = "CENTER", x = 0, y = 0 },
            messageHistory = {},
            classColors = true,
            timestamps = true,
            timestampFormat = "[%H:%M]",
            urlDetection = true,
            enableNotifications = true,
            font = "Friz Quadrata",
            fontSize = 12,
            width = 600,
            height = 400,
            historySize = 1000,
            channels = {
                SAY = true,
                YELL = true,
                PARTY = true,
                GUILD = true,
                RAID = true,
                WHISPER = true,
            },
            backgroundOpacity = 0.8,
            flashTaskbar = true,
            notificationSound = "None",
            soundVolume = 1.0,
        }
    }
end

local function SetupStaticPopup()
    StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"] = {
        text = L.open_url_dialog or "Open URL:",
        button1 = L.open or "Open",
        button2 = L.cancel or "Cancel",
        OnAccept = function(self, data)
            if data.url then
                if ChatFrame_OpenBrowser then
                    ChatFrame_OpenBrowser(data.url)
                else
                    EditBox_CopyTextToClipboard(data.url)
                    self:GetParent():Print(L.url_copied or ("URL copied to clipboard: " .. data.url))
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
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
end

local function RegisterCommands(addonObj)
    -- ... existing commands ...
    addonObj:RegisterChatCommand("scstatus", function()
        addonObj:Print("SleekChat Status Report:")
        addonObj:Print("Debug Mode: "..(addonObj.db.profile.debug and "|cFF00FF00ON" or "|cFFFF0000OFF"))
        addonObj:Print("Default Chat Visible: "..(addonObj.db.profile.showDefaultChat and "|cFF00FF00YES" or "|cFFFF0000NO"))
        if addon.ChatFrame.chatFrame then
            addonObj:Print(string.format("Main Frame: %s (Visible: %s)",
                    tostring(addon.ChatFrame.chatFrame),
                    addon.ChatFrame.chatFrame:IsVisible() and "|cFF00FF00YES" or "|cFFFF0000NO"))
        else
            addonObj:Print("Main Frame: |cFFFF0000NOT INITIALIZED")
        end
    end)
end

function Core:Initialize(addonObj)
    SetupStaticPopup()
    ApplyMigrations(addonObj)
    RegisterCommands(addonObj)
end

function Core:ShowConfig()
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end

return Core
