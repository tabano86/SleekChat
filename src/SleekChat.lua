-- SleekChat.lua
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")

local Util = require("Util") or _G.SleekChat.Util

-- Initialize singleton modules.
local Core          = require("Core")
local Config        = require("Config")
local Events        = require("Events")
local History       = require("History")
local Notifications = require("Notifications")
local UI            = require("UI")

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SleekChatDB", Core.getDefaults(), true)
    Config.Setup(self, Config.generateOptions)
    Core.Initialize(self)
end

function addon:OnEnable()
    History.Initialize(self)
    UI.Initialize(self)
    self:RegisterEvent("CHAT_MSG_ADDON", "OnAddonMessage")
end

function addon:OnAddonMessage(event, prefix, message, channel, sender)
    local msgData = Events.ProcessMessage(prefix, message, channel, sender, self.db.profile)
    if msgData then
        History.AddMessage(self, msgData)
        UI.AddMessage(self, msgData)
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

-- Provide safe, minimal implementations if they’re missing (so references never fail).
if not SleekChat.Core.getDefaults then
    function SleekChat.Core.getDefaults()
        return {} -- or your defaults
    end
end

if not SleekChat.Config.Setup then
    function SleekChat.Config.Setup(addonInstance, configGenerator) end
end

if not SleekChat.Config.generateOptions then
    function SleekChat.Config.generateOptions()
        return {}
    end
end

if not SleekChat.Core.Initialize then
    function SleekChat.Core.Initialize(addonInstance) end
end

if not SleekChat.Core.ApplySettings then
    function SleekChat.Core.ApplySettings(addonInstance) end
end

if not SleekChat.Events.ProcessMessage then
    function SleekChat.Events.ProcessMessage(prefix, message, channel, sender, dbProfile)
        -- Return nil if there's no actual code yet.
    end
end

if not SleekChat.History.Initialize then
    function SleekChat.History.Initialize(addonInstance) end
end

if not SleekChat.History.AddMessage then
    function SleekChat.History.AddMessage(addonInstance, msgData) end
end

if not SleekChat.UI.Initialize then
    function SleekChat.UI.Initialize(addonInstance) end
end

if not SleekChat.UI.AddMessage then
    function SleekChat.UI.AddMessage(addonInstance, msgData) end
end

_G.SleekChat = addon
