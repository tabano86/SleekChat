local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

-- We add "AceTimer-3.0" to allow scheduled tasks, if needed
SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

function SleekChat:OnInitialize()
    -- 1) Load or create user DB
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults())

    -- 2) Init core and config
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)

    -- 3) Create our chat UI (which we do in ChatFrame.lua)
    addon.ChatFrame:Initialize(self)

    -- 4) Hide default chat frames
    self:HookDefaultChat()

    -- 5) Show load message
    self:Print(string.format(L.addon_loaded, GetAddOnMetadata("SleekChat", "Version")))
end

function SleekChat:OnEnable()
    if addon.Events then
        addon.Events:Initialize(self)
    end
    if addon.History then
        addon.History:Initialize(self)
    end
    if addon.Notifications then
        addon.Notifications:Initialize(self)
    end

    self:UpdateChatVisibility()

    if addon.ChatFrame and addon.ChatFrame.mainFrame then
        addon.ChatFrame.mainFrame:Show()
    end

    -- Optionally, forcibly override Enter key to focus SleekChat
    -- (If you want a default binding w/o user going to the binding UI)
    SetOverrideBindingClick(self, false, "ENTER", "SleekChatFocusButton")
end

--------------------------------------------------------------------------------
-- Hide default Blizzard chat frames
--------------------------------------------------------------------------------
function SleekChat:HookDefaultChat()
    if ChatFrameMenuButton then ChatFrameMenuButton:Hide() end
    if QuickJoinToastButton then QuickJoinToastButton:Hide() end

    -- Hide 10 default chat frames
    for i = 1, 10 do
        local cf = _G["ChatFrame"..i]
        local tab = _G["ChatFrame"..i.."Tab"]
        if cf then cf:Hide() end
        if tab then
            tab:Hide()
            tab.Show = function() end  -- prevent re-showing
        end
    end

    -- Hide CombatText and so on
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:Hide()
    end
end

function SleekChat:UpdateChatVisibility()
    if not self.db or not self.db.profile then return end
    if self.db.profile.showDefaultChat then
        for i = 1, 10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Show() end
        end
    else
        for i = 1, 10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Hide() end
        end
    end
end

--------------------------------------------------------------------------------
-- Utility for debug prints
--------------------------------------------------------------------------------
function SleekChat:PrintDebug(msg)
    if self.db and self.db.profile and self.db.profile.debug then
        self:Print("|cFFFF00FF[SleekChat Debug]|r " .. msg)
    end
end
