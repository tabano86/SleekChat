-- Modules/ChatFrame.lua
local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local SM = LibStub("LibSharedMedia-3.0")
local L = AceLocale:GetLocale("SleekChat", true)

local ChatFrame = {}
addon.ChatFrame = ChatFrame

local floor, format, tinsert = math.floor, format, table.insert
local PLAYER_NAME = UnitName("player") or "Player"
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"

function ChatFrame:Initialize(addonObj)
    self.addonObj = addonObj
    self.db = addonObj.db
    self.pinnedMessages = {}
    self.activeChannel = "ALL"

    local f = CreateFrame("Frame", "SleekChat_MainFrame", UIParent, "BackdropTemplate")
    self.mainFrame = f
    f:SetSize(self.db.profile.width, self.db.profile.height)
    f:SetPoint(self.db.profile.position.point, UIParent, self.db.profile.position.relPoint, floor(self.db.profile.position.x), floor(self.db.profile.position.y))
    f:SetMovable(true)
    f:SetResizable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint()
        self.db.profile.position = { point = point, relPoint = relPoint, x = x, y = y }
    end)
    if f.SetResizeBounds then f:SetResizeBounds(400, 250) end

    local resize = CreateFrame("Button", nil, f)
    resize:SetSize(16, 16)
    resize:SetPoint("BOTTOMRIGHT")
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        self.db.profile.width = floor(f:GetWidth())
        self.db.profile.height = floor(f:GetHeight())
        self:LayoutFrames()
    end)

    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity or 0.8)

    -- Sidebar for channels
    self.sidebar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    self.sidebar:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    self.sidebar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 4, 4)
    self.sidebar:SetWidth(120)
    self.sidebar:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
    self.sidebar:SetBackdropColor(0, 0, 0, 0.9)

    local sf = CreateFrame("ScrollFrame", nil, self.sidebar, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", self.sidebar, "TOPLEFT", 0, -4)
    sf:SetPoint("BOTTOMRIGHT", self.sidebar, "BOTTOMRIGHT", -25, 4)
    self.sidebarScroll = sf

    local sbContent = CreateFrame("Frame", nil, sf)
    sf:SetScrollChild(sbContent)
    sbContent:SetSize(100, 400)
    self.sidebarContent = sbContent
    self.channelButtons = {}

    -- Main message frame
    local msg = CreateFrame("ScrollingMessageFrame", nil, f)
    self.messageFrame = msg
    msg:SetFading(false)
    msg:SetMaxLines(2000)
    msg:SetHyperlinksEnabled(true)
    msg:SetJustifyH("LEFT")
    msg:EnableMouseWheel(true)
    msg:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then scrollSpeed = scrollSpeed * 3 end
        if delta > 0 then msg:ScrollUp(scrollSpeed) else msg:ScrollDown(scrollSpeed) end
    end)
    msg:SetScript("OnHyperlinkClick", function(_, link)
        local linkType, val = strsplit(":", link, 2)
        if linkType == "url" then self:HandleURL(val) end
    end)

    -- Bottom input box (hidden until activated)
    local edit = CreateFrame("EditBox", "SleekChat_InputBox", f, "InputBoxTemplate")
    self.inputBox = edit
    edit:SetAutoFocus(false)
    edit:SetHeight(24)
    edit:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 8)
    edit:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
    edit:Hide() -- hide by default
    edit:SetScript("OnEnterPressed", function(box)
        local text = box:GetText() and box:GetText():trim()
        if text and text ~= "" then
            self:SendSmartMessage(text)
        end
        box:SetText("")
        box:ClearFocus()
        box:Hide()  -- hide input after sending
    end)

    -- Clicking the chat frame will show the input box
    f:SetScript("OnMouseDown", function() edit:Show() edit:SetFocus() end)

    self:LayoutFrames()
    self:SetChatFont()
    self:ApplyTheme()
    self:BuildChannelList()

    -- Settings icon embedded inside chat window (top-right corner)
    local settingsBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    settingsBtn:SetSize(24, 24)
    settingsBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    settingsBtn:SetText("⚙")
    settingsBtn:SetScript("OnClick", function() addon.ShowConfig() end)

    -- Watermark for active channel
    self.watermark = self.messageFrame:CreateFontString(nil, "BACKGROUND")
    self.watermark:SetFontObject("GameFontNormalHuge")
    self.watermark:SetTextColor(0.3, 0.3, 0.3, 0.4)
    self.watermark:SetPoint("CENTER")
    self.watermark:SetText(self.activeChannel)

    addon:PrintDebug("SleekChat v2.0 chat UI initialized.")
end

function ChatFrame:LayoutFrames()
    local f = self.mainFrame
    local pad = 8
    self.sidebar:ClearAllPoints()
    self.sidebar:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    self.sidebar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 4, 4)
    self.sidebar:SetWidth(120)
    self.messageFrame:ClearAllPoints()
    self.messageFrame:SetPoint("TOPLEFT", self.sidebar, "TOPRIGHT", pad, -pad)
    self.messageFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -pad, -pad)
    self.messageFrame:SetPoint("BOTTOM", self.inputBox, "TOP", 0, 4)
end

function ChatFrame:BuildChannelList()
    local container = self.sidebarContent
    local yOffset = -4
    local index = 1
    local channels = self:GetChannelList()
    for _, chName in ipairs(channels) do
        local btn = self.channelButtons[index] or CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        self.channelButtons[index] = btn
        btn:Show()
        btn:SetSize(100, 24)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", 4, yOffset)
        btn:SetText(chName)
        btn:SetScript("OnClick", function() self:SwitchChannel(chName) end)
        yOffset = yOffset - 26
        index = index + 1
    end
    for i = index, #self.channelButtons do
        self.channelButtons[i]:Hide()
    end
    container:SetHeight(math.abs(yOffset) + 20)
end

function ChatFrame:GetChannelList()
    local list = { "ALL", "SYSTEM", "COMBAT", "SAY", "YELL", "PARTY", "RAID", "GUILD", "OFFICER", "WHISPER", "BNWHISPER", "EMOTE", "BATTLEGROUND", "INSTANCE", "RAIDWARNING" }
    if self.db.profile.channels then
        for chName, enabled in pairs(self.db.profile.channels) do
            if enabled then tinsert(list, chName) end
        end
    end
    table.sort(list, function(a, b) if a=="ALL" then return true elseif b=="ALL" then return false else return a < b end end)
    return list
end

function ChatFrame:SendSmartMessage(text)
    local channel = self.activeChannel or "ALL"
    local cmd = text:match("^/(%S+)")
    if cmd then
        cmd = cmd:lower()
        if cmd == "s" or cmd == "say" then channel = "SAY"
        elseif cmd == "y" or cmd == "yell" then channel = "YELL"
        elseif cmd == "p" or cmd == "party" then channel = "PARTY"
        elseif cmd == "ra" or cmd == "raid" then channel = "RAID"
        elseif cmd == "g" or cmd == "guild" then channel = "GUILD"
        elseif cmd == "o" or cmd == "officer" then channel = "OFFICER" end
        text = text:gsub("^/%S+%s*", "")
    end
    self:SendToBlizzard(text, channel)
    self:AddIncoming(text, PLAYER_NAME, channel)
end

function ChatFrame:SendToBlizzard(text, channel)
    local chatType = channel
    if channel == "WHISPER" or channel == "BNWHISPER" then return end
    SendChatMessage(text, chatType)
end

function ChatFrame:AddIncoming(text, sender, channel)
    if not self.messageFrame or not self.db then return end
    if addon.ChatModeration and addon.ChatModeration:IsMuted(sender) then return end
    if addon.ChatModeration then text = addon.ChatModeration:FilterMessage(text) end
    if addon.History then addon.History:AddMessage(text, sender, channel) end
    if self:ShouldDisplayChannel(channel) then self:AddMessageToFrame(text, channel, sender) end
end

function ChatFrame:ShouldDisplayChannel(ch)
    return self.activeChannel == "ALL" or self.activeChannel == ch
end

function ChatFrame:AddMessageToFrame(text, channel, sender)
    local final = ""
    if self.db.profile.timestamps then final = final .. format("|cff808080[%s]|r ", date(self.db.profile.timestampFormat)) end
    if sender and sender ~= "" then
        final = final .. format("|cffFFFFFF%s|r: ", sender)
    end
    if channel ~= "ALL" and channel ~= "SYSTEM" then
        final = final .. format("|cff00ffff[%s]|r ", channel)
    end
    final = final .. text
    self.messageFrame:AddMessage(final)
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:SwitchChannel(chName)
    self.activeChannel = chName
    self.messageFrame:Clear()
    for _, pin in ipairs(self.pinnedMessages) do
        self.messageFrame:AddMessage("|cffFFD700[PINNED]|r " .. pin)
    end
    if self.activeChannel == "ALL" then
        if addon.History and addon.History.db then
            local stor = addon.History.db.profile.messageHistory
            if stor then
                for chName, arr in pairs(stor) do
                    for i = #arr, 1, -1 do
                        local msgData = arr[i]
                        self:AddMessageToFrame(msgData.text, msgData.channel, msgData.sender)
                    end
                end
            end
        end
    else
        if addon.History and addon.History.db then
            local stor = addon.History.db.profile.messageHistory
            if stor and stor[chName] then
                for i = #stor[chName], 1, -1 do
                    local m = stor[chName][i]
                    self:AddMessageToFrame(m.text, m.channel, m.sender)
                end
            end
        end
    end
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:PinMessage(msg)
    if not self.db.profile.enablePinning then return end
    tinsert(self.pinnedMessages, msg)
    self:SwitchChannel(self.activeChannel)
end

function ChatFrame:ApplyTheme()
    local dark = self.db.profile.darkMode
    local alpha = dark and 0.7 or (self.db.profile.backgroundOpacity or 0.8)
    self.mainFrame:SetBackdropColor(0, 0, 0, alpha)
    local textColor = dark and { r=0.8, g=0.8, b=0.8 } or { r=0.1, g=0.1, b=0.1 }
    self.messageFrame:SetTextColor(textColor.r, textColor.g, textColor.b)
    self.inputBox:SetTextColor(textColor.r, textColor.g, textColor.b)
end

function ChatFrame:SetChatFont()
    local fontPath = SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local fontSize = math.min(math.max(self.db.profile.fontSize or 12, 8), 24)
    self.messageFrame:SetFont(fontPath, fontSize, "")
    self.messageFrame:SetJustifyH("LEFT")
end

function ChatFrame:HandleURL(url)
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = url })
end

function ChatFrame:FilterMessages(searchText)
    self.messageFrame:Clear()
    for _, msg in ipairs(self.db.profile.messageHistory or {}) do
        if msg.text:lower():find(searchText:lower()) then
            self:AddMessageToFrame(msg.text, msg.channel, msg.sender)
        end
    end
end

return ChatFrame
