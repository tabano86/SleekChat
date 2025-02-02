local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

-- Initialize database FIRST before any other operations
function SleekChat:OnInitialize()
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults())
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)
    addon.ChatFrame:Initialize(self)
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
    -- Initialize critical components first
    addon.ChatFrame:Initialize(self)  -- Ensure ChatFrame is fully initialized

    -- Then initialize other modules
    if addon.Events then
        addon.Events:Initialize(self)
    else
        self:Print("Warning: Events module not loaded!")
    end
    addon.History:Initialize(self)
    addon.Notifications:Initialize(self)

    -- Show UI components after initialization
    if addon.ChatFrame.chatFrame then
        addon.ChatFrame.chatFrame:Show()
    end
    if addon.ChatFrame.messageFrame then
        addon.ChatFrame.messageFrame:Show()
    end
    if addon.ChatFrame.editBox then
        addon.ChatFrame.editBox:Show()
    end
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
