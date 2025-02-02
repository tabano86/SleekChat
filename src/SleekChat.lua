local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat")

function SleekChat:OnInitialize()
    self.db = AceDB:New("SleekChatDB", self.Core.GetDefaults())
    self.Core.Initialize(self)
    self.Config.Initialize(self)
    self:Print(L.addon_loaded)
end

function SleekChat:OnEnable()
    xpcall(function()
        self.Events.Initialize(self)
        self.ChatFrame.Initialize(self)
        self.History.Initialize(self)
        self.Notifications.Initialize(self)
    end, function(err)
        self:Print("|cFFFF0000Initialization Error:|r "..tostring(err))
        geterrorhandler()(err)
    end)
end
