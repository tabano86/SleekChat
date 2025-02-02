local _, addon = ...
local AceEvent = LibStub("AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Core = {}
local Core = addon.Core

-- Separate function to set up static popups
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

-- Separate function for default settings
function Core.GetDefaults()
    return {
        profile = {
            enable = true,
            version = 1,
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
            font = "Fonts\\FRIZQT__.TTF",
            fontSize = 12,
            width = 600,
            height = 400,
            historySize = 500,
            channels = {
                SAY = true,
                YELL = true,
                PARTY = true,
                GUILD = true,
                RAID = true,
                WHISPER = true
            }
        }
    }
end

-- Helper function to handle version-specific migrations
local function ApplyMigrations(self)
    if self.db.profile.version < 1 then
        self.db.profile.messageHistory = self.db.profile.messageHistory or {}
        self.db.profile.version = 1
    end
end

-- Helper function to register chat commands
local function RegisterCommands(core)
    core:RegisterChatCommand("sleekchat", "ShowConfig")
    core:RegisterChatCommand("sc", "ShowConfig")
end

-- Main initialization
function Core.Initialize(self)
    SetupStaticPopup()
    ApplyMigrations(self)
    RegisterCommands(self)
end

-- Show configuration interface
function Core.ShowConfig(input)
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end
