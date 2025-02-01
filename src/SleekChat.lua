-- SleekChat.lua
if not _G.SleekChat then _G.SleekChat = {} end
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")

local Modules = _G.SleekChat.Modules or error("Modules registry missing. Check Init.lua and .toc order!")
local Core   = Modules:get("Core") or error("Core module not registered. Check .toc order!")
local Logger = Modules:get("Logger") or error("Logger module missing. Check .toc order!")
local Config = Modules:get("Config") or error("Config module missing. Check .toc order!")
local Events = Modules:get("Events") or error("Events module missing. Check .toc order!")
local History= Modules:get("History") or error("History module missing. Check .toc order!")
local UI     = Modules:get("UI") or error("UI module missing. Check .toc order!")

Logger:Debug("SleekChat Loading...")

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
    -- Register regular chat events
    self:RegisterEvent("CHAT_MSG_SAY", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_YELL", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_PARTY", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_GUILD", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_RAID", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_WHISPER", "OnChatMessage")
    Logger:Info("Addon OnEnable complete.")
end

function addon:OnAddonMessage(event, prefix, message, channel, sender)
    local msgData = Events.ProcessMessage(prefix, message, channel, sender, self.db.profile)
    if msgData then
        History.AddMessage(self, msgData)
        UI.AddMessage(self, msgData)
        Logger:Debug("Processed addon message: " .. message)
    end
end

function addon:OnChatMessage(event, message, sender, ...)
    local msgData = Events.ProcessMessage(event, message, event, sender, self.db.profile)
    if msgData then
        History.AddMessage(self, msgData)
        UI.AddMessage(self, msgData)
        Logger:Debug("Processed chat message: " .. message)
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

_G.SleekChat.addon = addon
Modules:register("SleekChat", addon)
Logger:Debug("SleekChat Loaded!")
