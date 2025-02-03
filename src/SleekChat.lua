-- SleekChat.lua
local _, addon = ...
local AceAddon    = LibStub("AceAddon-3.0")
local AceDB       = LibStub("AceDB-3.0")
local AceLocale   = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

function SleekChat:OnInitialize()
    -- Create or load user DB with default settings
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults(), true)

    -- Initialize core logic (DB migrations, slash commands, etc.)
    addon.Core:Initialize(self)

    -- Load config UI
    addon.Config:Initialize(self)

    -- Print loaded message
    self:Print(string.format(L.addon_loaded, GetAddOnMetadata("SleekChat","Version") or "2.0"))
end

function SleekChat:OnEnable()
    -- Initialize all modules
    if addon.Events          then addon.Events:Initialize(self) end
    if addon.Hooks           then addon.Hooks:Initialize() end
    if addon.History         then addon.History:Initialize(self) end
    if addon.ChatModeration  then addon.ChatModeration:Initialize(self) end
    if addon.Notifications   then addon.Notifications:Initialize(self) end
    if addon.ChatTabs        then addon.ChatTabs:Initialize(self) end
    if addon.ChatFrame       then addon.ChatFrame:Initialize(self) end
    if addon.ChannelRejoin   then addon.ChannelRejoin:Initialize(self) end
    if addon.AdvancedLinking then addon.AdvancedLinking:Initialize(self) end
    if addon.RegexFilter     then addon.RegexFilter:Initialize(self) end
    if addon.AutoHide        then addon.AutoHide:Initialize(self) end

    -- Hide or show default chat frames
    self:UpdateChatVisibility()
end

-- Toggle default chat frames based on user setting
function SleekChat:UpdateChatVisibility()
    if self.db.profile.showDefaultChat then
        for i = 1, NUM_CHAT_WINDOWS do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Show() end
        end
    else
        for i = 1, NUM_CHAT_WINDOWS do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Hide() end
        end
    end
end

function SleekChat:PrintDebug(msg)
    if self.db and self.db.profile.debug then
        self:Print("|cFF00FFFF[SleekChat Debug]|r " .. (msg or ""))
    end
end
