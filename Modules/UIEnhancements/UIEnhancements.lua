-- ===========================================================================
-- SleekChat v2.0 - UIEnhancements.lua
-- Handles dynamic tab management, auto-hiding the input bar, and custom fonts/themes.
-- ===========================================================================
local UIEnhancements = {}
SleekChat_UIEnhancements = UIEnhancements

local frame = CreateFrame("Frame", "SleekChatEnhFrame", UIParent, "BackdropTemplate")
frame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true,
    tileSize = 32,
    edgeSize = 32,
    insets   = { left = 8, right = 8, top = 8, bottom = 8 },
})
frame:RegisterEvent("PLAYER_LOGIN")

local chatTabs = {}

local function OnChatMsg(self, event, message, sender, ...)
    if event == "CHAT_MSG_CHANNEL" then
        local channelName = select(9, ...)
        if channelName and channelName:lower():find("trade") then
            if SleekChat_Config.Get("ui", "splitTrade") then
                UIEnhancements:RedirectChat("Trade", event, message, sender, ...)
                return true
            end
        end
    end
    return false
end

function UIEnhancements:RedirectChat(tabName, event, message, sender, ...)
    local chatFrame = self:GetOrCreateTab(tabName)
    if chatFrame then
        local formattedMsg = string.format("[%s] %s", tabName, message)
        chatFrame:AddMessage(formattedMsg)
    end
end

function UIEnhancements:GetOrCreateTab(tabName)
    if chatTabs[tabName] then
        return chatTabs[tabName]
    end
    local newFrame = FCF_OpenNewWindow(tabName)
    chatTabs[tabName] = newFrame
    return newFrame
end

local function OnEditFocusGained(self)
    self:Show()
end

local function OnEditFocusLost(self)
    if SleekChat_Config.Get("ui", "autoHideInput") then
        self:Hide()
    end
end

function UIEnhancements:InitializeInputBehavior()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame"..i]
        if cf and cf.editBox then
            cf.editBox:HookScript("OnEditFocusGained", OnEditFocusGained)
            cf.editBox:HookScript("OnEditFocusLost", OnEditFocusLost)
            if SleekChat_Config.Get("ui", "autoHideInput") then
                cf.editBox:Hide()
            end
        end
    end
end

-- Modules\UIEnhancements\UIEnhancements.lua
function UIEnhancements:ApplyCustomFonts()
    local fontPath = SleekChat_Config.Get("ui", "fontPath")
    if fontPath and fontPath ~= "" then
        local font = CreateFont("SleekChatCustomFont")
        font:SetFont(fontPath, 14, "")

        for i = 1, NUM_CHAT_WINDOWS do
            local cf = _G["ChatFrame"..i]
            if cf then
                cf:SetFontObject("SleekChatCustomFont")
            end
        end
    end
end

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        UIEnhancements:InitializeInputBehavior()
        UIEnhancements:ApplyCustomFonts()
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", OnChatMsg)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", OnChatMsg)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADE", OnChatMsg)
    end
end)
