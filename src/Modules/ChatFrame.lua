local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

-- Simple URL patterns
local URL_PATTERNS = {
    "%w+%.?[^%s/]*%.%a%a+[^%s]*",
    "[a-zA-Z0-9]+://[^%s]*",
}

local function ConfigureChatFrameAppearance(addonObj)
    local frame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BasicFrameTemplate")
    frame:SetSize(addonObj.db.profile.width, addonObj.db.profile.height)
    frame:SetPoint("CENTER")
    frame:SetResizable(true)
    frame:SetResizeBounds(300, 200, 800, 600)
    frame:SetBackdrop({
        bgFile = SM:Fetch("background", (addonObj.db.profile.background and addonObj.db.profile.background.texture) or "Solid") or "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = SM:Fetch("border", (addonObj.db.profile.border and addonObj.db.profile.border.texture) or "Blizzard Tooltip") or "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = (addonObj.db.profile.border and addonObj.db.profile.border.size) or 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, addonObj.db.profile.backgroundOpacity or 0.8)
    frame:SetFrameStrata("HIGH")
    return frame
end

local function CreateResizeButton(addonObj)
    local resizeButton = CreateFrame("Button", nil, ChatFrame.chatFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetScript("OnMouseDown", function() ChatFrame.chatFrame:StartSizing("BOTTOMRIGHT") end)
    resizeButton:SetScript("OnMouseUp", function()
        ChatFrame.chatFrame:StopMovingOrSizing()
        addon.db.profile.width = ChatFrame.chatFrame:GetWidth()
        addon.db.profile.height = ChatFrame.chatFrame:GetHeight()
    end)
end

local function ConfigureFrameMover(addonObj)
    local frame = ChatFrame.chatFrame
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f) f:StartMoving() end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, xOfs, yOfs = f:GetPoint()
        addon.db.profile.position = { point = point, relPoint = relPoint, x = xOfs, y = yOfs }
    end)
end

local function RestoreSavedPosition(addonObj)
    if addonObj.db.profile.position then
        ChatFrame.chatFrame:ClearAllPoints()
        ChatFrame.chatFrame:SetPoint(
                addon.db.profile.position.point,
                UIParent,
                addon.db.profile.position.relPoint,
                addon.db.profile.position.x,
                addon.db.profile.position.y
        )
    end
end

local function CreateMessageFrame(addonObj)
    local msgFrame = CreateFrame("ScrollingMessageFrame", nil, ChatFrame.chatFrame)
    msgFrame:SetPoint("TOPLEFT", 8, -24)
    msgFrame:SetPoint("BOTTOMRIGHT", -8, 8)
    msgFrame:SetFontObject(ChatFontNormal)
    msgFrame:SetJustifyH("LEFT")
    msgFrame:SetMaxLines(500)
    msgFrame:SetFading(false)
    msgFrame:SetHyperlinksEnabled(true)
    msgFrame:SetScript("OnHyperlinkClick", function(_, link)
        if link:sub(1, 3) == "url" then
            local url = link:sub(5)
            StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = url })
        end
    end)
    return msgFrame
end

local function AddFrameTitle(addonObj)
    local title = ChatFrame.chatFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -5)
    title:SetText("SleekChat")
end

function ChatFrame:Initialize(addonObj)
    self.db = addonObj.db  -- store the db reference locally
    -- Main Container Frame
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent)
    self.chatFrame:SetSize(addonObj.db.profile.width or 600, addonObj.db.profile.height or 400)
    self.chatFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 50, 50)
    self.chatFrame:SetFrameStrata("DIALOG")
    self.chatFrame:EnableMouse(true)
    self.chatFrame:SetMovable(true)
    self.chatFrame:RegisterForDrag("LeftButton")
    self.chatFrame:SetScript("OnDragStart", self.chatFrame.StartMoving)
    self.chatFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint()
        self.db.profile.position = { point = point, relPoint = relPoint, x = x, y = y }
    end)

    -- Message Display Area
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetPoint("TOPLEFT", 10, -30)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -10, 40)
    self.messageFrame:SetFontObject(ChatFontNormal)
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetFading(false)
    self.messageFrame:SetMaxLines(500)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then
            self.messageFrame:ScrollUp()
        else
            self.messageFrame:ScrollDown()
        end
    end)

    -- Input Box
    self.editBox = CreateFrame("EditBox", nil, self.chatFrame, "InputBoxTemplate")
    self.editBox:SetPoint("BOTTOMLEFT", 10, 10)
    self.editBox:SetPoint("BOTTOMRIGHT", -10, 10)
    self.editBox:SetHeight(20)
    self.editBox:SetAutoFocus(false)
    self.editBox:SetScript("OnEnterPressed", function(f)
        ChatFrame_SendText(f:GetText())
        f:SetText("")
        f:ClearFocus()
    end)

    self:CreateTabs(addonObj)
    self:HookBlizzardChat()
    ConfigureFrameMover(addonObj)
    RestoreSavedPosition(addonObj)
    CreateResizeButton(addonObj)
    AddFrameTitle(addonObj)

    addonObj:PrintDebug("Chat system initialized")
end

function ChatFrame:UpdateFonts()
    local font = SM:Fetch("font", self.db.profile.font) or self.db.profile.font
    self.messageFrame:SetFont(font, self.db.profile.fontSize or 12)
end

local function UpdateURLDetection(text)
    for _, pattern in ipairs(URL_PATTERNS) do
        text = text:gsub(pattern, function(url)
            return format("|cff00ffff|Hurl:%s|h[%s]|h|r", url, url:sub(1, 40))
        end)
    end
    return text
end

function ChatFrame:HookBlizzardChat()
    -- Disable default chat windows
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]
        if frame then
            frame.AddMessage = function() end
            frame:Hide()
        end
    end

    local eventMap = {
        CHAT_MSG_SAY    = true,
        CHAT_MSG_YELL   = true,
        CHAT_MSG_PARTY  = true,
        CHAT_MSG_GUILD  = true,
        CHAT_MSG_RAID   = true,
        CHAT_MSG_WHISPER = true,
    }
    local function MessageHandler(_, event, text, ...)
        self:AddMessage(text, event, ...)
        return true
    end
    for event in pairs(eventMap) do
        ChatFrame_AddMessageEventFilter(event, MessageHandler)
    end

    -- Slash command override example
    SLASH_SLEEKCHAT1 = "/s"
    SLASH_SLEEKCHAT2 = "/say"
    SlashCmdList.SLEEKCHAT = function(msg)
        self.editBox:SetText("/s "..msg)
        self.editBox:SetFocus()
    end
end

function ChatFrame:AddMessage(text, eventType, sender)
    if addon.db.profile.urlDetection then
        text = UpdateURLDetection(text)
    end
    local formatted = self:FormatMessage(text, sender, eventType)
    self.messageFrame:AddMessage(formatted)
end

function ChatFrame:FormatMessage(text, sender, channel)
    local parts = {}
    if addon.db.profile.timestamps then
        table.insert(parts, date(addon.db.profile.timestampFormat or "[%H:%M]"))
    end
    if sender and addon.db.profile.classColors then
        local class = self:GetPlayerClass(sender)
        if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            sender = format("|cff%02x%02x%02x%s|r", color.r*255, color.g*255, color.b*255, sender)
        end
    end
    table.insert(parts, format("[%s]", channel))
    table.insert(parts, format("%s:", sender or "System"))
    table.insert(parts, text)
    return table.concat(parts, " ")
end

function ChatFrame:UpdateAll()
    self.messageFrame:Clear()
    if addon.History and addon.History.messages then
        for channel, messages in pairs(addon.History.messages) do
            for _, msg in ipairs(messages) do
                self:AddMessage(msg.text, msg.channel, msg.sender)
            end
        end
    end
end

function ChatFrame:GetPlayerClass(sender)
    local unit = self:GetUnitIDFromName(sender)
    if unit then
        local _, class = UnitClass(unit)
        return class
    end
    if IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local name, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(i)
            if name == sender then
                return class
            end
        end
    end
    return nil
end

function ChatFrame:GetUnitIDFromName(name)
    for i = 1, 4 do
        if UnitName("party" .. i) == name then return "party" .. i end
    end
    if IsInRaid() then
        for i = 1, 40 do
            if UnitName("raid" .. i) == name then return "raid" .. i end
        end
    end
    return nil
end

function ChatFrame:UpdateBackground()
    self.chatFrame:SetBackdropColor(0, 0, 0, addon.db.profile.backgroundOpacity or 0.8)
end

function ChatFrame:CreateTabs(addonObj)
    -- Clear any existing tabs
    if self.tabs then
        for _, tab in pairs(self.tabs) do
            tab:Hide()
        end
    end
    self.tabs = {}
    if addonObj.db.profile.layout == "TRANSPOSED" then
        local yOffset = 0
        for channel in pairs(addonObj.db.profile.channels or {}) do
            local tab = CreateFrame("Button", "SleekChatTab_"..channel, self.chatFrame, "CharacterFrameTabButtonTemplate")
            tab:SetPoint("TOPLEFT", self.chatFrame, "TOPLEFT", 0, -yOffset)
            tab:SetText(channel)
            tab:SetWidth(80)
            yOffset = yOffset + 25
            tab:SetScript("OnClick", function() self:SwitchChannel(channel) end)
            self.tabs[channel] = tab
        end
    else
        local xOffset = 0
        for channel in pairs(addonObj.db.profile.channels or {}) do
            local tab = CreateFrame("Button", "SleekChatTab_"..channel, self.chatFrame, "CharacterFrameTabButtonTemplate")
            tab:SetPoint("BOTTOMLEFT", self.chatFrame, "TOPLEFT", xOffset, -4)
            tab:SetText(channel)
            tab:SetWidth(80)
            xOffset = xOffset + 85
            tab:SetScript("OnClick", function() self:SwitchChannel(channel) end)
            self.tabs[channel] = tab
        end
    end
end

function ChatFrame:SwitchChannel(channel)
    self.db.profile.currentChannel = channel
    self.messageFrame:Clear()
    if addon.History and addon.History.messages and addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            self:AddMessage(msg.text, msg.channel, msg.sender)
        end
    end
    if self.tabs then
        for ch, tab in pairs(self.tabs) do
            if ch == channel then
                tab:LockHighlight()
                tab:SetText(ch)
            else
                tab:UnlockHighlight()
            end
        end
    end
end


function ChatFrame:CopyToClipboard()
    local text = ""
    for i = 1, self.messageFrame:GetNumMessages() do
        text = text .. (self.messageFrame:GetMessageInfo(i) or "") .. "\n"
    end
    EditBox_CopyTextToClipboard(text)
    addon:Print(L.history_copied)
end

function ChatFrame:ApplyLayout()
    -- Reposition the main frame if a saved position exists
    if addon.db.profile.position then
        self.chatFrame:ClearAllPoints()
        self.chatFrame:SetPoint(addon.db.profile.position.point, UIParent, addon.db.profile.position.relPoint, addon.db.profile.position.x, addon.db.profile.position.y)
    else
        self.chatFrame:SetPoint("CENTER")
    end
    -- Recreate tabs based on the selected layout
    self:CreateTabs(addon)
end

return ChatFrame
