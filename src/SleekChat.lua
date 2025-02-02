local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat")

-- Separate function to initialize database and load defaults
local function InitializeDatabase(self)
    self.db = AceDB:New("SleekChatDB", self.Core.GetDefaults())
end

-- Separate function to initialize the core functionality
local function InitializeCore(self)
    self.Core.Initialize(self)
end

-- Separate function to initialize configuration settings
local function InitializeConfig(self)
    self.Config.Initialize(self)
end

-- Print a basic loaded message
local function PrintLoadedMessage(self)
    self:Print(L.addon_loaded)
end

function SleekChat:OnInitialize()
    InitializeDatabase(self)
    InitializeCore(self)
    InitializeConfig(self)
    PrintLoadedMessage(self)
end

-- Separate function to set up modules
local function InitializeModulesSafely(self)
    xpcall(function()
        self.Events.Initialize(self)
        self.ChatFrame.Initialize(self)
        self.History.Initialize(self)
        self.Notifications.Initialize(self)
    end, function(err)
        self:Print("|cFFFF0000Initialization Error:|r " .. tostring(err))
        geterrorhandler()(err)
    end)
end

function SleekChat:OnEnable()
    InitializeModulesSafely(self)
end
