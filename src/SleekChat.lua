local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

-- Initialize database FIRST before any other operations
function SleekChat:OnInitialize()
    -- Database initialization
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults())

    -- Core systems
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)
    addon.ChatFrame:Initialize(self)

    -- Complete default chat replacement
    self:HookDefaultChat()
    self:Print(format(L.addon_loaded, GetAddOnMetadata("SleekChat", "Version")))
end

function SleekChat:HookDefaultChat()
    -- Disable Blizzard chat elements
    ChatFrameMenuButton:Hide()
    QuickJoinToastButton:Hide()

    -- Replace chat tabs
    for i = 1, 10 do
        local tab = _G["ChatFrame"..i.."Tab"]
        if tab then
            tab:Hide()
            tab.Show = function() end
        end
    end

    -- Redirect combat text
    CombatText:SetScript("OnEvent", function() end)
end

function SleekChat:PrintDebug(message)
    if self.db and self.db.profile and self.db.profile.debug then
        self:Print("|cFF00FFFF[DEBUG]|r "..message)
    end
end

function SleekChat:HideDefaultChatFrames()
    if not self.db or not self.db.profile then return end

    if not self.db.profile.showDefaultChat then
        self:PrintDebug("Hiding default chat frames")
        for i = 1, 10 do
            local frame = _G["ChatFrame"..i]
            if frame then
                frame:Hide()
                frame:SetUserPlaced(true)
            end
        end
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:Hide()
        end
    end
end

function SleekChat:OnEnable()
    addon.Events:Initialize(self)
    addon.History:Initialize(self)
    addon.Notifications:Initialize(self)

    -- Force UI update
    addon.ChatFrame.chatFrame:Show()
    addon.ChatFrame.messageFrame:Show()
    addon.ChatFrame.editBox:Show()
end

function SleekChat:UpdateChatVisibility()
    if not self.db or not self.db.profile then return end

    if self.db.profile.showDefaultChat then
        self:PrintDebug("Showing default chat frames")
        for i = 1, 10 do
            local frame = _G["ChatFrame"..i]
            if frame then frame:Show() end
        end
    else
        self:HideDefaultChatFrames()
    end
end
