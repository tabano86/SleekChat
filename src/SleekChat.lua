-- SleekChat.lua
local AceAddon = LibStub("AceAddon-3.0")

-- Use a separate local variable so we don’t overshadow the global table.
local addon = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")

-- Make sure we always have a global table available to attach our modules.
_G.SleekChat = _G.SleekChat or {}

-- Ensure our modules exist before we call them:
SleekChat.Core      = SleekChat.Core      or {}
SleekChat.Config    = SleekChat.Config    or {}
SleekChat.Events    = SleekChat.Events    or {}
SleekChat.History   = SleekChat.History   or {}
SleekChat.UI        = SleekChat.UI        or {}

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

-- The core addon lifecycle methods follow.
function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SleekChatDB", SleekChat.Core.getDefaults(), true)
    SleekChat.Config.Setup(self, SleekChat.Config.generateOptions)
    SleekChat.Core.Initialize(self)
end

function addon:OnEnable()
    SleekChat.History.Initialize(self)
    SleekChat.UI.Initialize(self)
    self:RegisterEvent("CHAT_MSG_ADDON", "OnAddonMessage")
end

function addon:OnAddonMessage(prefix, message, channel, sender)
    local msgData = SleekChat.Events.ProcessMessage(prefix, message, channel, sender, self.db.profile)
    if msgData then
        SleekChat.History.AddMessage(self, msgData)
        SleekChat.UI.AddMessage(self, msgData)
    end
end

function addon:ChatCommand(input)
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

-- Expose the local addon as the global SleekChat so other files can access it.
_G.SleekChat = addon
