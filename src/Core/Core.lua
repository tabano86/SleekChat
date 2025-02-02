local _, addon = ...
local AceEvent = LibStub("AceEvent-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

addon.Core = {}
local Core = addon.Core

-- Provide default settings (used later in the DB initialization)
function Core.GetDefaults()
    return {
        profile = {
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

local function ApplyMigrations(self)
    if self.db.profile.version < 2 then
        self.db.profile.background = self.db.profile.background or {
            texture = "SleekChat Default",
            opacity = 0.8,
        }
        self.db.profile.border = self.db.profile.border or {
            texture = "SleekChat Simple",
            size = 16,
        }
        self.db.profile.version = 2
    end
end

local function RegisterCommands(core)
    core:RegisterChatCommand("sleekchat", "ShowConfig")
    core:RegisterChatCommand("sc", "ShowConfig")
end

function Core:Initialize()
    SetupStaticPopup()
    ApplyMigrations(self)
    RegisterCommands(self)
end

function Core:ShowConfig()
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end

return Core
