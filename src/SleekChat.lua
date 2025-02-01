-- SleekChat.lua
if not _G.SleekChat then _G.SleekChat = {} end
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")

-- Ensure that all modules are attached to _G.SleekChat.
local Util   = _G.SleekChat.Util
local Logger = _G.SleekChat.Logger
local Core   = _G.SleekChat.Core
local Config = _G.SleekChat.Config
local Events = _G.SleekChat.Events
local History= _G.SleekChat.History
local UI     = _G.SleekChat.UI

Logger:Debug("SleekChat Loading...")

-- Defensive checks (you may remove these in production).
if not Core then error("Core module not loaded. Check your .toc order!") end
if not History then error("History module not loaded. Check your .toc order!") end
if not Config then error("Config module not loaded. Check your .toc order!") end
if not Events then error("Events module not loaded. Check your .toc order!") end
if not UI then error("UI module not loaded. Check your .toc order!") end

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
    input = Util.trim(input or ""):lower()
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
Logger:Debug("SleekChat Loaded!")
