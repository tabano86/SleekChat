local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

function SleekChat:OnInitialize()
    -- 1) Load or create user DB
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults(), true)

    -- 2) Initialize core + config
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)

    -- 3) Build the chat UI
    addon.ChatFrame:Initialize(self)

    -- 4) Hide default chat frames if user wants
    self:HookDefaultChat()

    -- 5) Print load message
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

    -- The new hook
    if addon.Hooks then
        addon.Hooks:Initialize()
    end

    self:UpdateChatVisibility()
    if addon.ChatFrame and addon.ChatFrame.mainFrame then
        addon.ChatFrame.mainFrame:Show()
    end
end


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
        for i=1,10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Hide() end
        end
    else
        for i=1,10 do
            local cf = _G["ChatFrame"..i]
            if cf then cf:Show() end
        end
    end
end

function SleekChat:PrintDebug(msg)
    if self.db.profile.debug then
        self:Print("|cFF00FFFF[SleekChat Debug]|r "..msg)
    end
end
