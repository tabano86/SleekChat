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
    self:PrintDebug("Initializing database")
    InitializeDatabase(self)

    self:PrintDebug("Loading core modules")
    InitializeCore(self)

    self:PrintDebug("Setting up configuration")
    InitializeConfig(self)

    PrintLoadedMessage(self)
end

local function InitializeModulesSafely(addonObj)
    xpcall(function()
        if addon.Events then
            addon.Events:Initialize(self)
        end
        if addon.ChatFrame then
            addon.ChatFrame:Initialize(self)
        end
        if addon.History then
            addon.History:Initialize(self)
        end
        if addon.Notifications and addon.Notifications.Initialize then
            addon.Notifications:Initialize(self)
        end
    end, function(err)
        self:Print("|cFFFF0000Initialization Error:|r " .. tostring(err))
        geterrorhandler()(err)
    end)
end

function SleekChat:UpdateChatVisibility()
    if self.db.profile.showDefaultChat then
        self:PrintDebug("Showing default chat frames")
        for i = 1, 10 do
            local frame = _G["ChatFrame" .. i]
            if frame then
                frame:Show()
            end
        end
    else
        self:HideDefaultChatFrames()
    end
end

function SleekChat:PrintDebug(message)
    if self.db.profile.debug then
        self:Print("|cFF00FFFF[DEBUG]|r " .. message)
    end
end

function SleekChat:HideDefaultChatFrames()
    if not self.db.profile.showDefaultChat then
        self:PrintDebug("Hiding default chat frames")

        -- Hide all default chat frames
        for i = 1, 10 do
            local frame = _G["ChatFrame" .. i]
            if frame then
                frame:Hide()
                frame:SetUserPlaced(true)  -- Prevent Blizzard code from managing it
            end
        end
        -- Ensure the default chat frame is explicitly hidden
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:Hide()
        end
    end
end

function SleekChat:OnEnable()
    -- Delay initialization until after default UI loads
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("VARIABLES_LOADED")
end

function SleekChat:VARIABLES_LOADED()
    -- Initialize core components first
    InitializeModulesSafely(self)

    -- Create chat frame immediately
    if not addon.ChatFrame.chatFrame then
        addon.ChatFrame:Initialize(self)
    end

    -- Force visibility
    addon.ChatFrame.chatFrame:Show()
    addon.ChatFrame.chatFrame:Raise()
end

function SleekChat:PLAYER_ENTERING_WORLD()
    -- Hide default frames last
    self:HideDefaultChatFrames()

    -- Final visibility check
    if addon.ChatFrame.chatFrame then
        addon.ChatFrame.chatFrame:Show()
        addon.ChatFrame.chatFrame:Raise()
    else
        self:Print("|cFFFF0000ERROR: Chat frame failed to initialize!|r")
    end
end
