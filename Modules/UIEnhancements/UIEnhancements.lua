-- ===========================================================================
-- SleekChat v2.0 - UIEnhancements.lua
-- Dynamic tab management, auto-hiding input bar, custom fonts/themes, etc.
-- ===========================================================================

local UIEnhancements = {}
SleekChat_UIEnhancements = UIEnhancements

local frame = CreateFrame("Frame", "SleekChatUIEnhFrame", UIParent)
frame:RegisterEvent("PLAYER_LOGIN")

-- For dynamic tab creation, we'll watch chat messages and possibly rearrange
local function OnChatMsg(self, event, message, sender, ...)
    if event == "CHAT_MSG_CHANNEL" then
        local channelName = select(9, ...)
        if channelName and string.find(channelName, "Trade") then
            -- If user has "splitTrade" enabled in config, move these messages to a dedicated frame
            local separateTrade = SleekChat_Config.Get("ui", "splitTrade")
            if separateTrade then
                UIEnhancements:RedirectChatToCustomFrame("Trade", event, message, sender, ...)
                return true
            end
        end
    end

    return false  -- let normal chat process
end

function UIEnhancements:RedirectChatToCustomFrame(frameName, event, message, sender, ...)
    local chatFrame = self:GetOrCreateTab(frameName)
    if chatFrame then
        local formattedMsg = string.format("[%s] %s", frameName, message)
        chatFrame:AddMessage(formattedMsg)
    end
end

local chatFrames = {}

function UIEnhancements:GetOrCreateTab(tabName)
    if chatFrames[tabName] then
        return chatFrames[tabName]
    end

    -- Create a new ChatFrame dynamically
    local newFrame = FCF_OpenNewWindow(tabName)
    chatFrames[tabName] = _G[newFrame:GetName()] or newFrame
    return chatFrames[tabName]
end

-- Auto-hiding input bar
local function OnEditFocusGained(self)
    self:Show()
end

local function OnEditFocusLost(self)
    if SleekChat_Config.Get("ui", "autoHideInput") then
        self:Hide()
    end
end

function UIEnhancements:InitializeAutoHideInput()
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

function UIEnhancements:ApplyCustomFonts()
    local fontPath = SleekChat_Config.Get("ui", "fontPath")
    if not fontPath then return end

    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            chatFrame:SetFont(fontPath, 14)
        end
    end
end

-- Player login initialization
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        UIEnhancements:InitializeAutoHideInput()
        UIEnhancements:ApplyCustomFonts()

        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", OnChatMsg)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", OnChatMsg)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADE", OnChatMsg)
        -- Add more filters if needed
    end
end)
