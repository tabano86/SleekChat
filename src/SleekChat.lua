-- SleekChat.lua
-- Main addon file that ties everything together using dependency injection.
local AceAddon = LibStub("AceAddon-3.0")
local SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")

-- Assume that the modules (Config, Core, Events, History, Notifications, UI, Util)
-- have been loaded already (per load order defined in .toc).

-- OnInitialize: Set up the database, configuration options, and initialize core.
function SleekChat:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SleekChatDB", SleekChat.Core.getDefaults(), true)
    -- Set up configuration; pass the pure config generator to our Setup function.
    SleekChat.Config.Setup(self, SleekChat.Config.generateOptions)
    -- Initialize core logic.
    SleekChat.Core.Initialize(self)
end

-- OnEnable: Initialize UI and History modules; register addon events.
function SleekChat:OnEnable()
    SleekChat.UI.Initialize(self)
    SleekChat.History.Initialize(self)
    self:RegisterEvent("CHAT_MSG_ADDON", "OnAddonMessage")
end

-- Event handler: delegates addon messages to the Events module.
function SleekChat:OnAddonMessage(prefix, message, channel, sender)
    local msgData = SleekChat.Events.ProcessMessage(prefix, message, channel, sender, self.db.profile)
    if msgData then
        SleekChat.History.AddMessage(self, msgData)
        SleekChat.UI.AddMessage(self, msgData)
    end
end

-- Slash command handler.
function SleekChat:ChatCommand(input)
    input = (input or ""):trim():lower()
    if input == "" or input == "config" then
        LibStub("AceConfigDialog-3.0"):Open("SleekChat")
    elseif input == "reset" then
        self.db:ResetProfile()
        self:Print("Profile reset to defaults.")
        SleekChat.Core.ApplySettings(self)
    else
        self:Print("Usage: /sleek [config|reset]")
    end
end

-- Expose the addon globally.
_G.SleekChat = SleekChat
