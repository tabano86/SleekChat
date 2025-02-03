local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB    = LibStub("AceDB-3.0")
local AceLocale= LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

function SleekChat:OnInitialize()
    -- Create or load user DB
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults(), true)

    -- Setup core + config
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)

    -- Build the UI
    addon.ChatFrame:Initialize(self)

    -- Hide default chat if user wants
    self:HookDefaultChat()

    self:Print(string.format(L.addon_loaded, GetAddOnMetadata("SleekChat", "Version")))
end

function SleekChat:OnEnable()
    if addon.Events then
        addon.Events:Initialize(self)
    end
    if addon.History then
        addon.History:Initialize(self)
    end
    if addon.ChatModeration then
        addon.ChatModeration:Initialize(self)
    end
    if addon.Notifications then
        addon.Notifications:Initialize(self)
    end
    if addon.ThreadManager then
        addon.ThreadManager:Initialize(self)
    end

    self:UpdateChatVisibility()

    if addon.ChatFrame and addon.ChatFrame.mainFrame then
        addon.ChatFrame.mainFrame:Show()
    end
end

--------------------------------------------------------------------------------
-- Hide default Blizzard chat frames
--------------------------------------------------------------------------------
function SleekChat:HookDefaultChat()
    if ChatFrameMenuButton then ChatFrameMenuButton:Hide() end
    if QuickJoinToastButton then QuickJoinToastButton:Hide() end
    for i = 1, 10 do
        local cf  = _G["ChatFrame"..i]
        local tab = _G["ChatFrame"..i.."Tab"]
        if cf  then cf:Hide() end
        if tab then
            tab:Hide()
            tab.Show = function() end
        end
    end
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:Hide()
    end
end

function SleekChat:UpdateChatVisibility()
    if not self.db.profile.showDefaultChat then
        for i = 1, 10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Hide() end
        end
    else
        for i = 1, 10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Show() end
        end
    end
end

--------------------------------------------------------------------------------
-- Debug printing
--------------------------------------------------------------------------------
function SleekChat:PrintDebug(msg)
    if self.db.profile.debug then
        self:Print("|cFF00FFFF[SleekChat Debug]|r ".. msg)
    end
end
