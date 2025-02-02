local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

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
    if addon.db.profile.position then
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
    if not addonObj.db then
        addonObj:Print("|cFFFF0000ERROR: Database missing during chat frame init!|r")
        return
    end

    addonObj:PrintDebug("Creating main chat frame")
    -- Create main frame with explicit visibility controls
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BasicFrameTemplate")
    self.chatFrame:SetSize(addonObj.db.profile.width or 600, addonObj.db.profile.height or 400)
    self.chatFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    self.chatFrame:SetToplevel(true)
    self.chatFrame:SetClampedToScreen(true)
    self.chatFrame:EnableMouse(true)
    self.chatFrame:SetMovable(true)
    self.chatFrame:SetUserPlaced(true)

    -- Force visible state
    self.chatFrame:Show()
    self.chatFrame:Raise()

    -- Position handling with failsafe
    if addonObj.db.profile.position then
        self.chatFrame:ClearAllPoints()
        self.chatFrame:SetPoint(
                addonObj.db.profile.position.point,
                UIParent,
                addonObj.db.profile.position.relPoint,
                addonObj.db.profile.position.x,
                addonObj.db.profile.position.y
        )
    else
        -- Default position if none exists
        self.chatFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    -- Create message display area
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetAllPoints(true)
    self.messageFrame:SetFontObject(ChatFontNormal)
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetFading(false)
    self.messageFrame:SetMaxLines(500)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:Show()

    -- Initial test message
    self.messageFrame:AddMessage("|cFF00FF00SleekChat initialized successfully!|r")
    addonObj:PrintDebug(string.format("Chat frame created at %dx%d",
            self.chatFrame:GetWidth(),
            self.chatFrame:GetHeight()))
end

function ChatFrame:UpdateFonts(addonObj)
    addonObj:PrintDebug(string.format("Updating fonts to %s (%dpt)",
            addonObj.db.profile.font,
            addonObj.db.profile.fontSize))
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", addonObj.db.profile.font) or addonObj.db.profile.font
    self.messageFrame:SetFont(font or STANDARD_TEXT_FONT, addonObj.db.profile.fontSize or 12)
end

local function UpdateURLDetection(text)
    for _, pattern in ipairs(URL_PATTERNS) do
        text = text:gsub(pattern, function(url)
            return format("|cff00ffff|Hurl:%s|h[%s]|h|r", url, url:sub(1, 40))
        end)
    end
    return text
end

function ChatFrame:AddMessage(text, sender, channel, ...)
    if addon.db.profile.urlDetection then
        text = UpdateURLDetection(text)
    end
    local msg = self:FormatMessage(text, sender, channel, ...)
    self.messageFrame:AddMessage(msg)
    if channel ~= addon.db.profile.currentChannel and addon.db.profile.tabUnreadHighlight then
        if self.tabs and self.tabs[channel] then
            self.tabs[channel]:SetText(format("|cFF00FF00%s|r", channel))
        end
    end
end

function ChatFrame:FormatMessage(text, sender, channel, ...)
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
                self:AddMessage(msg.text, msg.sender, msg.channel)
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
    self.tabs = {}
    local xOffset = 0
    for channel in pairs(addonObj.db.profile.channels or {}) do
        local tab = CreateFrame("Button", nil, self.chatFrame, "CharacterFrameTabButtonTemplate")
        tab:SetPoint("BOTTOMLEFT", self.chatFrame, "TOPLEFT", xOffset, -4)
        tab:SetText(channel)
        tab:SetWidth(80)
        xOffset = xOffset + 85
        tab:SetScript("OnClick", function() self:SwitchChannel(channel) end)
        self.tabs[channel] = tab
    end
end

function ChatFrame:SwitchChannel(channel)
    addon.db.profile.currentChannel = channel
    self.messageFrame:Clear()
    if addon.History and addon.History.messages and addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            self:AddMessage(msg.text, msg.sender, msg.channel)
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

return ChatFrame
