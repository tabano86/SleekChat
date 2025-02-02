local _, addon = ...
local AceEvent = LibStub("AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Core = {}
local Core = addon.Core

StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"] = {
    text = "Open URL:",
    button1 = "Open",
    button2 = "Cancel",
    OnAccept = function(self, data)
        if data.url then
            ChatFrame_OpenBrowser(data.url)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

function Core.GetDefaults()
    return {
        profile = {
            enable = true,
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

function Core.Initialize(self)
    self:RegisterChatCommand("sleekchat", "ShowConfig")
    self:RegisterChatCommand("sc", "ShowConfig")
end

function Core.ShowConfig(input)
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end
