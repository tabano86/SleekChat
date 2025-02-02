local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

function ChatFrame.Initialize(self)
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BasicFrameTemplate")
    self.chatFrame:SetSize(self.db.profile.width, self.db.profile.height)
    self.chatFrame:SetPoint("CENTER")

    self.chatFrame:SetMovable(true)
    self.chatFrame:RegisterForDrag("LeftButton")
    self.chatFrame:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)

    self.chatFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, relPoint, xOfs, yOfs = frame:GetPoint()
        self.db.profile.position = {
            point = point,
            relPoint = relPoint,
            x = xOfs,
            y = yOfs
        }
    end)

    if self.db.profile.position then
        self.chatFrame:ClearAllPoints()
        self.chatFrame:SetPoint(
                self.db.profile.position.point,
                UIParent,
                self.db.profile.position.relPoint,
                self.db.profile.position.x,
                self.db.profile.position.y
        )
    end

    -- Message Frame
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetPoint("TOPLEFT", 8, -24)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -8, 8)
    self.messageFrame:SetFontObject(ChatFontNormal)
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetMaxLines(500)
    self.messageFrame:SetFading(false)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        if link:sub(1,3) == "url" then
            local url = link:sub(5)
            StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, {url = url})
        end
    end)

    local title = self.chatFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -5)
    title:SetText("SleekChat")

    self:UpdateFonts()
    self:CreateTabs()
end

function ChatFrame.UpdateFonts(self)
    if LibStub("LibSharedMedia-3.0", true) then
        local font = LibStub("LibSharedMedia-3.0"):Fetch("font", self.db.profile.font)
    else
        local font = self.db.profile.font
    end
    self.messageFrame:SetFont(font or STANDARD_TEXT_FONT, self.db.profile.fontSize)
end

function ChatFrame.AddMessage(self, text, ...)
    -- URL Detection
    if self.db.profile.urlDetection then
        text = text:gsub("([wW][wW][wW]%.[%w-_%.]+%.%S+)", "|cff00ffff|Hurl:%1|h[%1]|h|r")
        text = text:gsub("(%S+://%S+)", "|cff00ffff|Hurl:%1|h[%1]|h|r")
    end

    local msg = self:FormatMessage(text, ...)
    self.messageFrame:AddMessage(msg)
end

function ChatFrame.FormatMessage(self, text, sender, channel, ...)
    local parts = {}

    if self.db.profile.timestamps then
        table.insert(parts, date(self.db.profile.timestampFormat))
    end

    if sender and self.db.profile.classColors then
        local class = self:GetPlayerClass(sender)
        if class then
            local color = RAID_CLASS_COLORS[class]
            sender = format("|cff%02x%02x%02x%s|r", color.r*255, color.g*255, color.b*255, sender)
        end
    end

    table.insert(parts, format("[%s]", channel))
    table.insert(parts, format("%s:", sender or "System"))
    table.insert(parts, text)

    return table.concat(parts, " ")
end


function ChatFrame.UpdateAll(self)
    self.messageFrame:Clear()
    for channel, messages in pairs(self.History.messages) do
        for _, msg in ipairs(messages) do
            self:AddMessage(msg.text, msg.sender, msg.channel)
        end
    end
end

function ChatFrame.GetPlayerClass(self, sender)
    -- Check party/raid members first
    local unit = self:GetUnitIDFromName(sender)
    if unit then
        local _, class = UnitClass(unit)
        return class
    end

    -- Fallback to guild roster
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

function ChatFrame.GetUnitIDFromName(self, name)
    -- Check party
    for i = 1, 4 do
        if UnitName("party"..i) == name then
            return "party"..i
        end
    end

    -- Check raid
    if IsInRaid() then
        for i = 1, 40 do
            if UnitName("raid"..i) == name then
                return "raid"..i
            end
        end
    end

    return nil
end

function ChatFrame.CreateTabs(self)
    self.tabs = {}
    local xOffset = 0
    for channel in pairs(self.db.profile.channels) do
        local tab = CreateFrame("Button", nil, self.chatFrame, "CharacterFrameTabButtonTemplate")
        tab:SetPoint("BOTTOMLEFT", self.chatFrame, "TOPLEFT", xOffset, -4)
        tab:SetText(channel)
        tab:SetWidth(80)
        xOffset = xOffset + 85
        tab:SetScript("OnClick", function()
            self:SwitchChannel(channel)
        end)
        self.tabs[channel] = tab
    end
end

function ChatFrame.SwitchChannel(self, channel)
    self.currentChannel = channel
    self.messageFrame:Clear()
    if self.History.messages[channel] then
        for _, msg in ipairs(self.History.messages[channel]) do
            self:AddMessage(msg.text, msg.sender, msg.channel)
        end
    end
    -- Update tab states
    for ch, tab in pairs(self.tabs) do
        if ch == channel then
            tab:LockHighlight()
        else
            tab:UnlockHighlight()
        end
    end
end
