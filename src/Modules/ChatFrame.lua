local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

-- Optimized URL patterns with common protocols and email support
local URL_PATTERNS = {
    "https?://%S+",                     -- HTTP/HTTPS
    "www%.[%w_-%%]+%.%w%w+%.?%w*",      -- Common websites
    "ftp://%S+",                        -- FTP
    "[%w_.%%+-]+@[%w_.%%+-]+%.%w%w+",   -- Email addresses
    "%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?", -- IP with port
    "wowinterface%.com/%S+",            -- Common WoW sites
    "classicwow%.com/%S+",
}

-- Cache frequently used globals
local floor, date, format, gsub, ipairs = math.floor, date, string.format, string.gsub, ipairs
local RAID_CLASS_COLORS = RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local CHAT_FRAME_BACKDROP = {
    bgFile = SM:Fetch("background", "Solid") or "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = SM:Fetch("border", "Blizzard Tooltip") or "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

-- Player class cache to reduce API calls
local classCache = setmetatable({}, {
    __index = function(t, sender)
        local class = ChatFrame.GetPlayerClass(nil, sender)
        rawset(t, sender, class or false)
        return class
    end
})

function ChatFrame:GetPlayerClass(sender)
    local unit, name
    for i = 1, 4 do
        unit = "party"..i
        name = UnitName(unit)
        if name == sender then
            return select(2, UnitClass(unit))
        end
    end

    if IsInRaid() then
        for i = 1, 40 do
            unit = "raid"..i
            name = UnitName(unit)
            if name == sender then
                return select(2, UnitClass(unit))
            end
        end
    end

    -- Check current player
    if sender == UnitName("player") then
        return select(2, UnitClass("player"))
    end
end

-- Unified tab creation function
local function CreateTab(parent, text, onClick, tooltip)
    local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
    tab:SetSize(80, 24)
    tab:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })

    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    tab.bg = bg

    local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(text)
    tab.text = text

    tab:SetScript("OnClick", onClick)

    if tooltip then
        tab:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(tooltip, 1, 1, 1)
            GameTooltip:Show()
        end)
        tab:SetScript("OnLeave", GameTooltip_Hide)
    end

    return tab
end

function ChatFrame:HandleWhisper(sender, msg)
    local channelName = "WHISPER:"..sender
    if not self.db.profile.messageHistory[channelName] then
        self.db.profile.messageHistory[channelName] = {}
    end

    if not self.tabs[channelName] then
        local tab = CreateTab(self.chatFrame, sender, function(_, button)
            if button == "RightButton" then
                -- Future: detach whisper tab
            else
                self:SwitchChannel(channelName)
            end
        end, L.whisper_tab_tooltip:format(sender))

        self.tabs[channelName] = tab
        self.db.profile.channels[channelName] = true
        self:UpdateTabPositions()
    end

    return true
end

function ChatFrame:Initialize(addonObj)
    self.db = addonObj.db
    self.activeChannel = "SAY"
    self.tabs = {}
    self.pinnedMessages = {}

    -- Main frame setup
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BackdropTemplate")
    self.chatFrame:SetSize(self.db.profile.width, self.db.profile.height)
    self.chatFrame:SetPoint(
            self.db.profile.position.point,
            UIParent,
            self.db.profile.position.relPoint,
            self.db.profile.position.x,
            self.db.profile.position.y
    )
    self.chatFrame:SetBackdrop(CHAT_FRAME_BACKDROP)
    self.chatFrame:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity)

    -- Message frame with performance optimizations
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:SetPoint("TOPLEFT", 8, -30)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -8, 40)
    self:UpdateFonts()
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetMaxLines(500)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = (self.db.profile.scrollSpeed or 3) * delta
        self.messageFrame:ScrollByAmount(-scrollSpeed)
    end)

    -- Hyperlink handling with URL detection
    self.messageFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = link:match("^(%a+):(.+)$")
        if linkType == "player" then
            self.editBox:SetText(format("/whisper %s ", value))
            self.editBox:SetFocus()
        elseif linkType == "url" then
            if not StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"] then
                StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = value })
            end
        end
    end)

    -- Edit box with improved auto-complete integration
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
        if self.db.profile.enableAutoComplete then
            AutoComplete(f)
        end
    end)

    -- Unified tab creation
    self:CreateTabs()
    self:UpdateTabAppearance()

    -- Resize button with visual feedback
    local resizeButton = CreateFrame("Button", nil, self.chatFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetScript("OnMouseDown", function() self.chatFrame:StartSizing("BOTTOMRIGHT") end)
    resizeButton:SetScript("OnMouseUp", function()
        self.chatFrame:StopMovingOrSizing()
        self.db.profile.width = floor(self.chatFrame:GetWidth())
        self.db.profile.height = floor(self.chatFrame:GetHeight())
        self:UpdateTabPositions()
    end)

    -- Frame movement handling
    self.chatFrame:EnableMouse(true)
    self.chatFrame:SetMovable(true)
    self.chatFrame:RegisterForDrag("LeftButton")
    self.chatFrame:SetScript("OnDragStart", self.chatFrame.StartMoving)
    self.chatFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint(1)
        self.db.profile.position = {
            point = point,
            relPoint = relPoint,
            x = floor(x),
            y = floor(y)
        }
    end)

    addon:PrintDebug("SleekChat frame initialized")
    self.messageFrame:AddMessage(L.addon_loaded:format(GetAddOnMetadata("SleekChat", "Version") or "1.0"))
    self:ApplyTheme()
end

function ChatFrame:UpdateFonts()
    local fontPath = SM:Fetch("font", self.db.profile.font) or "Fonts\\FRIZQT__.TTF"
    local fontSize = math.clamp(tonumber(self.db.profile.fontSize) or 12, 8, 24)
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
        if enabled and not channel:find("WHISPER:") and channel ~= "WHISPER" then
            local tab = CreateFrame("Button", nil, self.chatFrame)
            tab:SetSize(80, 24)
            tab:SetScript("OnClick", function(_, button)
                if button == "RightButton" then
                    -- Future: manual pinning/detach.
                else
                    self:SwitchChannel(channel)
                end
            end)
            local bg = tab:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            tab.bg = bg
            local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("CENTER")
            text:SetText(channel)
            tab.text = text
            if self.db.profile.customTabOrder then
                tab:SetMovable(true)
                tab:EnableMouse(true)
                tab:RegisterForDrag("LeftButton")
                tab:SetScript("OnDragStart", function(self) self:StartMoving() end)
                tab:SetScript("OnDragStop", function(self)
                    self:StopMovingOrSizing()
                    -- (Persist new order here as needed.)
                end)
            end
            if self.db.profile.tabTooltips then
                tab:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
                    local preview = self.lastMessage or "No recent messages"
                    GameTooltip:AddLine("Preview: " .. preview)
                    if self.unreadCount and self.unreadCount > 0 then
                        GameTooltip:AddLine("Unread: " .. self.unreadCount)
                    end
                    GameTooltip:Show()
                end)
                tab:SetScript("OnLeave", GameTooltip_Hide)
            end
            tab:SetScript("OnDoubleClick", function(self)
                if self.db and self.db.profile.clearUnreadOnDoubleClick then
                    self.unreadCount = 0
                    self.text:SetText(self.text:GetText():gsub(" %(%d+%)", ""))
                end
            end)
            self.tabs[channel] = tab
        end
    end
    if self.db.profile.channels.WHISPER then
        local tab = CreateFrame("Button", nil, self.chatFrame)
        tab:SetSize(80, 24)
        tab:SetScript("OnClick", function(_, button)
            if button == "RightButton" then
                -- Future: detach whispers.
            else
                self:SwitchChannel("WHISPER")
            end
        end)
        local bg = tab:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        tab.bg = bg
        local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Whispers")
        tab.text = text
        self.tabs["WHISPER"] = tab
    end
    self:UpdateTabPositions()
end

function ChatFrame:UpdateTabPositions()
    local layout = self.db.profile.layout
    local xOffset, yOffset = 5, -5
    for key, tab in pairs(self.tabs) do
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
    if addon.AdvancedMessaging and addon.AdvancedMessaging.SwitchChannel then
        addon.AdvancedMessaging:SwitchChannel(channel)
    end
end

function ChatFrame:UpdateTabAppearance()
    for key, tab in pairs(self.tabs) do
        if key == self.activeChannel then
            tab.bg:SetColorTexture(0.3, 0.3, 0.5, 1)
            tab.text:SetTextColor(1, 1, 1)
        else
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            tab.text:SetTextColor(0.8, 0.8, 0.8)
        end
    end
end

function ChatFrame:SendMessage(text, channel, sender)
    local processedText = text
    if addon.AdvancedMessaging and addon.AdvancedMessaging.ProcessOutgoing then
        processedText = addon.AdvancedMessaging:ProcessOutgoing(text, channel, sender)
    end
    self:AddMessage(processedText, channel, sender)
    if addon.History then
        addon.History:AddMessage(processedText, sender, channel)
    end
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:AddMessage(text, eventType, sender)
    -- Enhanced URL detection
    if self.db.profile.urlDetection then
        text = gsub(text, "(%S+)", function(word)
            for _, pattern in ipairs(URL_PATTERNS) do
                if word:match(pattern) then
                    return format("|cff00FFFF|Hurl:%s|h[Link]|h|r", word)
                end
            end
            return word
        end)
    end

    local formatted = self:FormatMessage(text, sender, eventType)

    -- Unread message counter
    if self.activeChannel ~= eventType and self.db.profile.unreadBadge then
        local tab = self.tabs[eventType]
        if tab then
            tab.unreadCount = (tab.unreadCount or 0) + 1
            local text = tab.text:GetText()
            tab.text:SetText(gsub(text, "%s%(%d+%)$", "").." ("..tab.unreadCount..")")
        end
    end

    self.messageFrame:AddMessage(formatted)
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:FormatMessage(text, sender, channel)
    local parts = {}

    if self.db.profile.timestamps then
        table.insert(parts, date(self.db.profile.timestampFormat))
    end

    if sender then
        local class = classCache[sender]
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            sender = format("|cff%02x%02x%02x|Hplayer:%s|h%s|h|r",
                    color.r * 255, color.g * 255, color.b * 255, sender, sender)
        else
            sender = format("|Hplayer:%s|h%s|h", sender, sender)
        end
    end

    table.insert(parts, format("[%s]", channel))
    if sender then table.insert(parts, format("%s:", sender)) end
    table.insert(parts, text)

    return table.concat(parts, " ")
end

function ChatFrame:PinMessage(message)
    if not self.db.profile.enablePinning then return end
    table.insert(self.pinnedMessages, message)
    self:UpdateAll()
end

function ChatFrame:UpdateAll()
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
    self:ApplyTheme()
end

function ChatFrame:ApplyTheme()
    if self.db.profile.darkMode then
        self.chatFrame:SetBackdropColor(0.1, 0.1, 0.1, self.db.profile.backgroundOpacity)
    else
        self.chatFrame:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity)
    end
end

return ChatFrame
