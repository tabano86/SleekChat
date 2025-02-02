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

function ChatFrame:Initialize(addonObj)
    self.db = addonObj.db
    self.activeChannel = "SAY"
    self.tabs = {}

    -- Main Frame
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BackdropTemplate")
    self.chatFrame:SetSize(self.db.profile.width, self.db.profile.height)
    self.chatFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 50, 50)
    self.chatFrame:SetBackdrop({
        bgFile = SM:Fetch("background", "Solid"),
        edgeFile = SM:Fetch("border", "Blizzard Tooltip"),
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    self.chatFrame:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity)

    -- Message Frame
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetPoint("TOPLEFT", 8, -30)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -8, 40)
    self.messageFrame:SetFont(SM:Fetch("font", self.db.profile.font), self.db.profile.fontSize)
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetMaxLines(500)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then
            self.messageFrame:ScrollUp()
        else
            self.messageFrame:ScrollDown()
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

    -- Input Box
    self.editBox = CreateFrame("EditBox", nil, self.chatFrame, "InputBoxTemplate")
    self.editBox:SetPoint("BOTTOMLEFT", 8, 8)
    self.editBox:SetPoint("BOTTOMRIGHT", -8, 8)
    self.editBox:SetHeight(20)
    self.editBox:SetAutoFocus(false)
    self.editBox:SetScript("OnEnterPressed", function(f)
        local text = f:GetText()
        if text ~= "" then
            local commands = {
                SAY = "/s ",
                YELL = "/y ",
                PARTY = "/p ",
                GUILD = "/g ",
                RAID = "/ra ",
                WHISPER = "/w ",
            }
            local cmd = commands[self.activeChannel] or "/s "
            ChatFrame_SendText(cmd .. text)

        end
        f:SetText("")
        f:ClearFocus()
    end)

    -- Tabs
    self:CreateTabs()
    self:UpdateTabAppearance()

    -- Resize Handle
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

    self.chatFrame:EnableMouse(true)
    self.chatFrame:SetMovable(true)
    self.chatFrame:RegisterForDrag("LeftButton")
    self.chatFrame:SetScript("OnDragStart", self.chatFrame.StartMoving)
    self.chatFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint(1)
        self.db.profile.position = { point = point, relPoint = relPoint, x = x, y = y }
    end)

    addonObj:PrintDebug("ChatFrame initialized")
end

function ChatFrame:CreateTabs()
    for _, tab in pairs(self.tabs) do
        tab:Hide()
    end
    self.tabs = {}

    local index = 1
    for channel in pairs(self.db.profile.channels) do
        if self.db.profile.channels[channel] then
            local tab = CreateFrame("Button", nil, self.chatFrame)
            tab:SetSize(80, 24)
            tab:SetScript("OnClick", function() self:SwitchChannel(channel) end)

            -- Background
            local bg = tab:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            tab.bg = bg

            -- Text
            local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("CENTER")
            text:SetText(channel)
            tab.text = text

            self.tabs[channel] = tab
            index = index + 1
        end
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
    if addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            self:AddMessage(msg.text, msg.channel, msg.sender)
        end
    end
    self:UpdateTabAppearance()
    self.messageFrame:ScrollToBottom()
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

function ChatFrame:AddMessage(text, eventType, sender)
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
        if class and RAID_CLASS_COLORS[class] then
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
