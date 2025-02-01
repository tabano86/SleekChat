-- SleekChat.lua
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")

local Util = require("Util") or _G.SleekChat.Util
local Logger = require("Logger") or _G.SleekChat.Logger

-- Load all modules as singletons.
local Core          = require("Core")
local Config        = require("Config")
local Events        = require("Events")
local History       = require("History")
local Notifications = require("Notifications")
local UI            = require("UI")

-- Resource loader: preload modules and attach to global namespace.
local function loadStubs()
    if not SleekChat then _G.SleekChat = {} end
    SleekChat.Core = Core
    SleekChat.Config = Config
    SleekChat.Events = Events
    SleekChat.History = History
    SleekChat.Notifications = Notifications
    SleekChat.UI = UI
    Logger:Debug("Global stubs loaded.")
end

loadStubs()

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SleekChatDB", Core.getDefaults(), true)
    Config.Setup(self, Config.generateOptions)
    Core.Initialize(self)
    Logger:Info("Addon OnInitialize complete.")
end

function addon:OnEnable()
    History.Initialize(self)
    UI.Initialize(self)
    self:RegisterEvent("CHAT_MSG_ADDON", "OnAddonMessage")
    Logger:Info("Addon OnEnable complete.")
end

function addon:OnAddonMessage(event, prefix, message, channel, sender)
    local msgData = Events.ProcessMessage(prefix, message, channel, sender, self.db.profile)
    if msgData then
        History.AddMessage(self, msgData)
        UI.AddMessage(self, msgData)
        Logger:Debug("Processed message: " .. message)
    end
end

function addon:ChatCommand(input)
    input = (input or ""):trim():lower()
    if input == "" or input == "config" then
        LibStub("AceConfigDialog-3.0"):Open("SleekChat")
    elseif input == "reset" then
        self.db:ResetProfile()
        self:Print("Profile reset to defaults.")
        Core.ApplySettings(self)
    else
        self:Print("Usage: /sleek [config|reset]")
    end
end

_G.SleekChat = addon
