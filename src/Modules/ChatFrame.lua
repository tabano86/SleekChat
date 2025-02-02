local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

local URL_PATTERNS = {
    "%w+://%S+",
    "www%.[%w_-]+%.%S+",
}

-- AutoComplete stub – expand as needed.
local function AutoComplete(editBox)
    -- Placeholder for auto-complete logic.
end

-- Returns the player's class for a given sender.
function ChatFrame:GetPlayerClass(sender)
    for i = 1, 4 do
        if UnitName("party" .. i) == sender then
            local _, class = UnitClass("party" .. i)
            return class
        end
    end
    if IsInRaid() then
        for i = 1, 40 do
            if UnitName("raid" .. i) == sender then
                local _, class = UnitClass("raid" .. i)
                return class
            end
        end
    end
    return nil
end

-- Detach a tab into a floating window.
function ChatFrame:DetachTab(channel)
    if not self.tabs[channel] then return end
    local detachFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    detachFrame:SetSize(self.db.profile.width * 0.5, self.db.profile.height * 0.5)
    detachFrame:SetPoint("CENTER")
    detachFrame:SetBackdrop({
        bgFile = SM:Fetch("background", "Solid"),
        edgeFile = SM:Fetch("border", "Blizzard Tooltip"),
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    detachFrame:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity)
    local scrollFrame = CreateFrame("ScrollingMessageFrame", nil, detachFrame)
    scrollFrame:SetAllPoints()
    scrollFrame:SetHyperlinksEnabled(true)
    scrollFrame:SetFontObject(ChatFontNormal)
    scrollFrame:SetJustifyH("LEFT")
    scrollFrame:SetMaxLines(500)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then
            scrollFrame:ScrollUp()
        else
            scrollFrame:ScrollDown()
        end
    end)
    if addon.History and addon.History.messages and addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            scrollFrame:AddMessage(msg.text)
        end
    end
    detachFrame:Show()
end

function ChatFrame:ApplyTheme()
    -- Prevent multiple ApplyTheme calls from stacking
    if self.isTheming then
        return
    end
    self.isTheming = true

    if self.db.profile.darkMode then
        self.chatFrame:SetBackdropColor(0.1, 0.1, 0.1, self.db.profile.backgroundOpacity)
    else
        self.chatFrame:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity)
    end

    -- If you still want to call UpdateAll, be sure it won’t call ApplyTheme again.
    -- Otherwise, remove or comment this out.
    if type(self.UpdateAll) == "function" then
        self:UpdateAll()
    end

    self.isTheming = false
end

-- Initialize the SleekChat UI.
function ChatFrame:Initialize(addonObj)
    self.db = addonObj.db
    self.activeChannel = "SAY"
    self.tabs = {}
    self.pinnedMessages = {}

    -- Main frame.
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BackdropTemplate")
    self.chatFrame:SetSize(self.db.profile.width, self.db.profile.height)
    self.chatFrame:SetPoint(self.db.profile.position.point, UIParent, self.db.profile.position.relPoint, self.db.profile.position.x, self.db.profile.position.y)
    self.chatFrame:SetBackdrop({
        bgFile = SM:Fetch("background", "Solid"),
        edgeFile = SM:Fetch("border", "Blizzard Tooltip"),
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    self.chatFrame:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity)

    -- Message frame.
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:SetPoint("TOPLEFT", 8, -30)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -8, 40)
    self:UpdateFonts()
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetMaxLines(500)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        local speed = self.db.profile.scrollSpeed or 3
        if delta > 0 then
            for i = 1, speed do self.messageFrame:ScrollUp() end
        else
            for i = 1, speed do self.messageFrame:ScrollDown() end
        end
    end)
    self.messageFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = link:match("^(%a+):(.+)$")
        if linkType == "player" then
            self.editBox:SetText(format("/whisper %s ", value))
            self.editBox:SetFocus()
        elseif linkType == "url" then
            StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = value })
        end
    end)

    -- Input box.
    self.editBox = CreateFrame("EditBox", nil, self.chatFrame, "InputBoxTemplate")
    self.editBox:SetPoint("BOTTOMLEFT", 8, 8)
    self.editBox:SetPoint("BOTTOMRIGHT", -8, 8)
    self.editBox:SetHeight(20)
    self.editBox:SetAutoFocus(false)
    self.editBox:SetScript("OnEnterPressed", function(f)
        local text = f:GetText()
        if text ~= "" then
            self:SendMessage(text, self.activeChannel, UnitName("player"))
        end
        f:SetText("")
        f:ClearFocus()
    end)
    self.editBox:SetScript("OnTextChanged", function(f)
        if self.db.profile.enableAutoComplete then AutoComplete(f) end
    end)

    -- Create channel tabs.
    self:CreateTabs()
    self:UpdateTabAppearance()

    -- Resize handle.
    local resizeButton = CreateFrame("Button", nil, self.chatFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", function() self.chatFrame:StartSizing("BOTTOMRIGHT") end)
    resizeButton:SetScript("OnMouseUp", function()
        self.chatFrame:StopMovingOrSizing()
        self.db.profile.width = self.chatFrame:GetWidth()
        self.db.profile.height = self.chatFrame:GetHeight()
        self:UpdateTabPositions()
    end)

    -- Enable dragging.
    self.chatFrame:EnableMouse(true)
    self.chatFrame:SetMovable(true)
    self.chatFrame:RegisterForDrag("LeftButton")
    self.chatFrame:SetScript("OnDragStart", self.chatFrame.StartMoving)
    self.chatFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint(1)
        self.db.profile.position = { point = point, relPoint = relPoint, x = x, y = y }
    end)

    addonObj:PrintDebug("SleekChat frame initialized")
    self.messageFrame:AddMessage(L.addon_loaded:format(GetAddOnMetadata("SleekChat", "Version")))
    -- Apply initial theme
    self:ApplyTheme()
end

function ChatFrame:UpdateFonts()
    local fontPath = SM:Fetch("font", self.db.profile.font) or "Fonts\\FRIZQT__.TTF"
    local fontSize = math.max(8, math.min(24, tonumber(self.db.profile.fontSize) or 12))
    self.messageFrame:SetFont(fontPath, fontSize, "")
    self.messageFrame:SetShadowColor(0, 0, 0, 1)
    self.messageFrame:SetShadowOffset(1, -1)
end

function ChatFrame:CreateTabs()
    for _, tab in pairs(self.tabs) do
        tab:Hide()
    end
    self.tabs = {}
    for channel, enabled in pairs(self.db.profile.channels) do
        local tab = CreateFrame("Button", nil, self.chatFrame)
        tab:SetSize(80, 24)
        tab:SetScript("OnClick", function(selfButton, button)
            if button == "RightButton" then
                -- Right-click detaches the tab into a floating window.
                self:DetachTab(channel)
            else
                if enabled then self:SwitchChannel(channel) end
            end
        end)
        local bg = tab:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        tab.bg = bg
        local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText(channel)
        text:SetTextColor(0.8, 0.8, 0.8)
        tab.text = text
        if not enabled then
            text:SetAlpha(0.5)
            tab:SetScript("OnEnter", function()
                GameTooltip:SetOwner(tab, "ANCHOR_TOP")
                GameTooltip:AddLine("Channel disabled", 1, 0, 0)
                GameTooltip:Show()
            end)
            tab:SetScript("OnLeave", GameTooltip_Hide)
        end
        self.tabs[channel] = tab
    end
    self:UpdateTabPositions()
end

function ChatFrame:UpdateTabPositions()
    local layout = self.db.profile.layout
    local xOffset, yOffset = 5, -5
    for channel, tab in pairs(self.tabs) do
        tab:ClearAllPoints()
        if layout == "TRANSPOSED" then
            tab:SetPoint("TOPLEFT", self.chatFrame, "TOPLEFT", xOffset, yOffset)
            yOffset = yOffset - 25
        else
            tab:SetPoint("BOTTOMLEFT", self.chatFrame, "TOPLEFT", xOffset, 0)
            xOffset = xOffset + 85
        end
    end
end

function ChatFrame:SwitchChannel(channel)
    self.activeChannel = channel
    self.messageFrame:Clear()
    if addon.History and addon.History.messages and addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            self:AddMessage(msg.text, msg.channel, msg.sender)
        end
    end
    self:UpdateTabAppearance()
    self.messageFrame:ScrollToBottom()
    -- Trigger advanced messaging (e.g. load thread history) if applicable
    if addon.AdvancedMessaging and addon.AdvancedMessaging.SwitchChannel then
        addon.AdvancedMessaging:SwitchChannel(channel)
    end
end

function ChatFrame:UpdateTabAppearance()
    for channel, tab in pairs(self.tabs) do
        if channel == self.activeChannel then
            tab.bg:SetColorTexture(0.3, 0.3, 0.5, 1)
            tab.text:SetTextColor(1, 1, 1)
        else
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            tab.text:SetTextColor(0.8, 0.8, 0.8)
        end
    end
end

-- Our own SendMessage function.
function ChatFrame:SendMessage(text, channel, sender)
    self:AddMessage(text, channel, sender)
    if addon.AdvancedMessaging and addon.AdvancedMessaging.ProcessOutgoing then
        addon.AdvancedMessaging:ProcessOutgoing(text, channel, sender)
    end
end

function ChatFrame:AddMessage(text, eventType, sender)
    if self.db.profile.profanityFilter then
        -- Call ChatModeration filter
        if addon.ChatModeration and addon.ChatModeration.FilterMessage then
            text = addon.ChatModeration:FilterMessage(text)
        end
    end
    if self.db.profile.urlDetection then
        text = text:gsub("(%S+://%S+)", "|cff00FFFF|Hurl:%1|h[Link]|h|r")
    end
    local formatted = self:FormatMessage(text, sender, eventType)
    self.messageFrame:AddMessage(formatted)
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:FormatMessage(text, sender, channel)
    local parts = {}
    if self.db.profile.timestamps then
        table.insert(parts, date(self.db.profile.timestampFormat))
    end
    if sender then
        local class = self:GetPlayerClass(sender)
        if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            sender = format("|cff%02x%02x%02x|Hplayer:%s|h%s|h|r",
                    color.r*255, color.g*255, color.b*255, sender, sender)
        else
            sender = format("|Hplayer:%s|h%s|h", sender, sender)
        end
    end
    table.insert(parts, format("[%s]", channel))
    if sender then
        table.insert(parts, format("%s:", sender))
    end
    table.insert(parts, text)
    return table.concat(parts, " ")
end

-- Pin a message so it stays at the top.
function ChatFrame:PinMessage(message)
    if not self.db.profile.enablePinning then return end
    table.insert(self.pinnedMessages, message)
    self:UpdateAll()
end

function ChatFrame:UpdateAll()
    if self.isTheming then
        return
    end

    self.messageFrame:Clear()
    for _, msg in ipairs(self.pinnedMessages) do
        self.messageFrame:AddMessage("|cffFFD700[PINNED]|r " .. msg)
    end
    if addon.History and addon.History.messages then
        for channel, messages in pairs(addon.History.messages) do
            for _, msg in ipairs(messages) do
                self:AddMessage(msg.text, msg.channel, msg.sender)
            end
        end
    end
    -- Apply theme after update
    self:ApplyTheme()
end

return ChatFrame
