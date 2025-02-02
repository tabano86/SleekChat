local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

-- Initialize database FIRST before any other operations
function SleekChat:OnInitialize()
    -- Database must be initialized before anything else
    self.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults())

    -- Now initialize other components
    addon.Core:Initialize(self)
    addon.Config:Initialize(self)

    self:Print(format(L.addon_loaded, GetAddOnMetadata("SleekChat", "Version") or ""))

    -- Debug initial state
    self:PrintDebug("Addon initialized successfully")
end

-- Modified PrintDebug with nil check
function SleekChat:PrintDebug(message)
    if self.db and self.db.profile and self.db.profile.debug then
        self:Print("|cFF00FFFF[DEBUG]|r "..message)
    end
end

-- Updated HideDefaultChatFrames with safety checks
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

-- Revised event handling
function SleekChat:OnEnable()
    self:PrintDebug("Addon enabling")

    -- Safe module initialization
    xpcall(function()
        if addon.Events then addon.Events:Initialize(self) end
        if addon.ChatFrame then addon.ChatFrame:Initialize(self) end
        if addon.History then addon.History:Initialize(self) end
        if addon.Notifications then addon.Notifications:Initialize(self) end
    end, function(err)
        self:Print("|cFFFF0000Initialization Error:|r "..tostring(err))
        geterrorhandler()(err)
    end)

    -- Register events after full initialization
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:PrintDebug("Player entering world")
        self:HideDefaultChatFrames()
        if addon.ChatFrame.chatFrame then
            addon.ChatFrame.chatFrame:Show()
            addon.ChatFrame.chatFrame:Raise()
        end
    end)
end

-- Modified UpdateChatVisibility with nil protection
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
