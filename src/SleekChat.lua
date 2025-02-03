-- SleekChat.lua
local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB    = LibStub("AceDB-3.0")
local AceLocale= LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

function SleekChat:OnInitialize()
    -- Create or load user DB with default settings
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults(), true)
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)

    self:HookDefaultChat()
    self:Print(string.format(L.addon_loaded, GetAddOnMetadata("SleekChat","Version") or "2.0"))
end

function SleekChat:OnEnable()
    if addon.Events then addon.Events:Initialize(self) end
    if addon.Hooks then addon.Hooks:Initialize() end
    if addon.History then addon.History:Initialize(self) end
    if addon.ChatModeration then addon.ChatModeration:Initialize(self) end
    if addon.Notifications then addon.Notifications:Initialize(self) end
    if addon.ChatTabs then addon.ChatTabs:Initialize(self) end
    if addon.ChatFrame then addon.ChatFrame:Initialize(self) end

    self:UpdateChatVisibility()
end

-- Hide default chat frames (resizable windows will be created by our UI)
function SleekChat:HookDefaultChat()
    if ChatFrameMenuButton then ChatFrameMenuButton:Hide() end
    if QuickJoinToastButton then QuickJoinToastButton:Hide() end
    for i=1,10 do
        local cf  = _G["ChatFrame"..i]
        local tab = _G["ChatFrame"..i.."Tab"]
        if cf then cf:Hide() end
        if tab then tab:Hide() end
    end
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:Hide()
    end
end

-- Toggle default chat based on settings
function SleekChat:UpdateChatVisibility()
    if self.db.profile.showDefaultChat then
        for i=1,10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Show() end
        end
    else
        for i=1,10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Hide() end
        end
    end
end

function SleekChat:PrintDebug(msg)
    if self.db and self.db.profile.debug then
        self:Print("|cFF00FFFF[SleekChat Debug]|r " .. msg)
    end
end
