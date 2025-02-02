local _, addon = ...
local AceEvent = LibStub("AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Core = {}
local Core = addon.Core

local function SetupStaticPopup()
    StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"] = {
        text = "Open URL:",
        button1 = "Open",
        button2 = "Cancel",
        OnAccept = function(self, data)
            if data.url then
                if ChatFrame_OpenBrowser then
                    ChatFrame_OpenBrowser(data.url)
                else
                    EditBox_CopyTextToClipboard(data.url)
                    self:GetParent():Print("URL copied to clipboard: " .. data.url)
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
end

function Core.GetDefaults()
    return {
        profile = {
            enable = true,
            version = 2,
            position = {
                point = "CENTER",
                relPoint = "CENTER",
                x = 0,
                y = 0
            },
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
                RAID_WARNING = true,
                INSTANCE_CHAT = true
            },
            background = {
                texture = "SleekChat Default",
                opacity = 0.8
            },
            border = {
                texture = "SleekChat Simple",
                size = 16
            },
            notificationSound = "None",
            soundVolume = 1.0,
            flashTaskbar = true
        }
    }
end

local function ApplyMigrations(self)
    if self.db.profile.version < 2 then
        self.db.profile.background = self.db.profile.background or {
            texture = "SleekChat Default",
            opacity = 0.8
        }
        self.db.profile.border = self.db.profile.border or {
            texture = "SleekChat Simple",
            size = 16
        }
        self.db.profile.version = 2
    end
end

local function RegisterCommands(core)
    core:RegisterChatCommand("sleekchat", "ShowConfig")
    core:RegisterChatCommand("sc", "ShowConfig")
end

function Core.Initialize(self)
    SetupStaticPopup()
    ApplyMigrations(self)
    RegisterCommands(self)
end

function Core.ShowConfig(input)
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end
