local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

-- OnInitialize: Setup the database and core systems.
function SleekChat:OnInitialize()
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults())
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)
    addon.ChatFrame:Initialize(self)
    self:HookDefaultChat()
    self:Print(format(L.addon_loaded, GetAddOnMetadata("SleekChat", "Version")))
end

-- HookDefaultChat: Hide Blizzard's default chat windows.
function SleekChat:HookDefaultChat()
    if ChatFrameMenuButton then ChatFrameMenuButton:Hide() end
    if QuickJoinToastButton then QuickJoinToastButton:Hide() end
    for i = 1, 10 do
        local tab = _G["ChatFrame"..i.."Tab"]
        if tab then
            tab:Hide()
            tab.Show = function() end
        end
    end
    if CombatText then
        CombatText:SetScript("OnEvent", function() end)
    end
end

function SleekChat:PrintDebug(message)
    if self.db and self.db.profile and self.db.profile.debug then
        self:Print("|cFF00FFFF[DEBUG]|r " .. message)
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
        if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:Hide() end
    end
end

function SleekChat:OnEnable()
    if addon.Events then
        addon.Events:Initialize(self)
    else
        self:Print("Warning: Events module not loaded!")
    end
    addon.History:Initialize(self)
    addon.Notifications:Initialize(self)
    self:UpdateChatVisibility()
    if addon.ChatFrame and addon.ChatFrame.chatFrame then
        addon.ChatFrame.chatFrame:Show()
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
