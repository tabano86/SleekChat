local _, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceLocale = LibStub("AceLocale-3.0")

SleekChat = AceAddon:NewAddon("SleekChat", "AceConsole-3.0", "AceEvent-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

local function InitializeDatabase(addonObj)
    addonObj.db = AceDB:New("SleekChatDB", addon.Core.GetDefaults())
end

local function InitializeCore(addonObj)
    addon.Core:Initialize(addonObj)
end

local function InitializeConfig(addonObj)
    addon.Config:Initialize(addonObj)
end

local function PrintLoadedMessage(addonObj)
    addonObj:Print(format(L.addon_loaded, GetAddOnMetadata("SleekChat", "Version") or ""))
end

function SleekChat:OnInitialize()
    InitializeDatabase(self)
    InitializeCore(self)
    InitializeConfig(self)
    PrintLoadedMessage(self)
end

local function InitializeModulesSafely(addonObj)
    xpcall(function()
        if addon.Events then addon.Events:Initialize(self) end
        if addon.ChatFrame then addon.ChatFrame:Initialize(self) end
        if addon.History then addon.History:Initialize(self) end
        if addon.Notifications and addon.Notifications.Initialize then
            addon.Notifications:Initialize(self)
        end
    end, function(err)
        self:Print("|cFFFF0000Initialization Error:|r " .. tostring(err))
        geterrorhandler()(err)
    end)
end

function SleekChat:OnEnable()
    InitializeModulesSafely(self)
    if ChatFrame1 then
        ChatFrame1:Hide()
    end
end

