local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

-- Utility shortcuts
local floor, format, gsub, strlower, strsplit = floor, format, gsub, strlower, strsplit
local tinsert = table.insert

local PLAYER_NAME = UnitName("player") or "Player"
local RAID_CLASS_COLORS = RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

--------------------------------------------------------------------------------
-- Simple approach: Single chat feed + top channel bar
--------------------------------------------------------------------------------

function ChatFrame:Initialize(addonObj)
    self.db = addonObj.db

    -- Main UI Frame
    local f = CreateFrame("Frame", "SleekChat_MainFrame", UIParent, "BackdropTemplate")
    self.mainFrame = f
    f:SetSize(self.db.profile.width, self.db.profile.height)
    f:SetPoint(self.db.profile.position.point, UIParent, self.db.profile.position.relPoint,
            floor(self.db.profile.position.x), floor(self.db.profile.position.y))
    f:SetMovable(true)
    f:SetResizable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point, _, relPoint, xOfs, yOfs = f:GetPoint()
        self.db.profile.position.point = point
        self.db.profile.position.relPoint = relPoint
        self.db.profile.position.x = xOfs
        self.db.profile.position.y = yOfs
    end)

    if f.SetResizeBounds then
        f:SetResizeBounds(300, 150)
    elseif f.SetMinResize then
        f:SetMinResize(300, 150)
    end

    -- Resize handle
    local resize = CreateFrame("Button", nil, f)
    resize:SetSize(16, 16)
    resize:SetPoint("BOTTOMRIGHT")
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resize:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        self.db.profile.width  = floor(f:GetWidth())
        self.db.profile.height = floor(f:GetHeight())
        self:LayoutChannelButtons()
        self:LayoutMessageFrame()
        self:LayoutInputBox()
    end)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left=4, right=4, top=4, bottom=4 },
    })
    f:SetBackdropColor(0,0,0,0.8)

    -- Channel Bar (top)
    local channelBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    self.channelBar = channelBar
    channelBar:SetPoint("TOPLEFT", 4, -4)
    channelBar:SetPoint("TOPRIGHT", -4, -4)
    channelBar:SetHeight(28)

    -- Scrollable message frame (large)
    local msgFrame = CreateFrame("ScrollingMessageFrame", "SleekChat_MessageFrame", f)
    self.msgFrame = msgFrame
    msgFrame:SetFading(false)
    msgFrame:SetMaxLines(1000)
    msgFrame:SetHyperlinksEnabled(true)
    msgFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = strsplit(":", link, 2)
        if linkType == "url" then
            self:HandleURL(value)
        elseif linkType == "player" then
            self:SwitchChannel("WHISPER:"..value)
        end
    end)

    msgFrame:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then scrollSpeed = scrollSpeed * 3 end
        if delta > 0 then
            msgFrame:ScrollUp(scrollSpeed)
        else
            msgFrame:ScrollDown(scrollSpeed)
        end
    end)

    -- Input box (bottom)
    local edit = CreateFrame("EditBox", "SleekChat_InputBox", f, "InputBoxTemplate")
    self.inputBox = edit
    edit:SetAutoFocus(false)
    edit:SetHeight(24)
    edit:SetScript("OnEnterPressed", function(box)
        local text = box:GetText() and box:GetText():trim()
        if text ~= "" then
            self:SendMessage(text)
        end
        box:SetText("")
        box:ClearFocus()
    end)

    -- A button to focus this input, so we can bind it in KeyBindings or override
    local focusBtn = CreateFrame("Button", "SleekChatFocusButton", UIParent, "UIPanelButtonTemplate")
    focusBtn:SetScript("OnClick", function() edit:SetFocus() end)
    focusBtn:Hide() -- no reason to show

    -- Channels known
    self.channelButtons = {}
    self.activeChannel = "SAY"

    self:CreateChannelButtons()
    self:LayoutChannelButtons()
    self:LayoutMessageFrame()
    self:LayoutInputBox()

    -- Setup fonts
    self:SetChatFont()
end

--------------------------------------------------------------------------------
-- Layout helpers
--------------------------------------------------------------------------------
function ChatFrame:LayoutChannelButtons()
    local pad = 4
    local totalWidth = self.mainFrame:GetWidth() - 8
    local numChannels = #self.channelButtons
    local btnWidth = math.floor((totalWidth - pad*(numChannels-1)) / numChannels)

    for i, btn in ipairs(self.channelButtons) do
        btn:SetWidth(btnWidth)
        btn:SetHeight(24)
        btn:ClearAllPoints()
        if i == 1 then
            btn:SetPoint("LEFT", self.channelBar, "LEFT", 0, 0)
        else
            btn:SetPoint("LEFT", self.channelButtons[i-1], "RIGHT", pad, 0)
        end
    end
end

function ChatFrame:LayoutMessageFrame()
    self.msgFrame:ClearAllPoints()
    self.msgFrame:SetPoint("TOPLEFT", self.channelBar, "BOTTOMLEFT", 4, -4)
    self.msgFrame:SetPoint("TOPRIGHT", self.channelBar, "BOTTOMRIGHT", -4, -4)
    self.msgFrame:SetPoint("BOTTOM", self.inputBox, "TOP", 0, 4)
end

function ChatFrame:LayoutInputBox()
    self.inputBox:ClearAllPoints()
    self.inputBox:SetPoint("LEFT", self.mainFrame, "LEFT", 10, 8)
    self.inputBox:SetPoint("RIGHT", self.mainFrame, "RIGHT", -10, 8)
    self.inputBox:SetHeight(24)
end

--------------------------------------------------------------------------------
-- Creating channel buttons
--------------------------------------------------------------------------------
function ChatFrame:CreateChannelButtons()
    local channels = {
        "SAY", "WHISPER", "PARTY", "GUILD", "RAID", "YELL", "ALL"
        -- You can expand with trade/lfg if you want
    }

    for _, ch in ipairs(channels) do
        local btn = CreateFrame("Button", nil, self.channelBar, "UIPanelButtonTemplate")
        btn:SetText(ch)
        btn:SetScript("OnClick", function() self:SwitchChannel(ch) end)
        table.insert(self.channelButtons, btn)
    end
end

--------------------------------------------------------------------------------
-- Switch channel (like a tab)
--------------------------------------------------------------------------------
function ChatFrame:SwitchChannel(ch)
    self.activeChannel = ch
    self.msgFrame:Clear()

    if ch == "ALL" then
        -- Show all messages from all channels
        if addon.History and addon.History.messages then
            for chan, messages in pairs(addon.History.messages) do
                for i = #messages, 1, -1 do
                    local msgData = messages[i]
                    self:AddMessageToFrame(msgData.text, msgData.channel, msgData.sender, false)
                end
            end
        end
    else
        -- Show only the chosen channel's messages
        if addon.History and addon.History.messages and addon.History.messages[ch] then
            for i = #addon.History.messages[ch], 1, -1 do
                local msgData = addon.History.messages[ch][i]
                self:AddMessageToFrame(msgData.text, msgData.channel, msgData.sender, false)
            end
        end
    end
    self.msgFrame:ScrollToBottom()
end

--------------------------------------------------------------------------------
-- Sending a chat message
--------------------------------------------------------------------------------
function ChatFrame:SendMessage(text)
    -- If activeChannel is e.g. "WHISPER", we might need a "target"
    -- For simplicity, if user typed "/w <target> hello", we parse that
    local actualChannel = self.activeChannel
    -- e.g. if the user is on channel "WHISPER" but hasn't chosen a target,
    -- you might parse the text or open a popup. We'll keep it simple:
    self:AddIncoming(text, PLAYER_NAME, actualChannel)
end

--------------------------------------------------------------------------------
-- Called from the Events module for incoming messages
--------------------------------------------------------------------------------
function ChatFrame:AddIncoming(text, sender, channel)
    if addon.ChatModeration and addon.ChatModeration:IsMuted(sender) then
        return -- do nothing
    end
    if addon.ChatModeration then
        text = addon.ChatModeration:FilterMessage(text)
    end

    -- Log to history
    if addon.History then
        addon.History:AddMessage(text, sender, channel)
    end

    -- If channel == activeChannel or activeChannel == "ALL", we display
    if self.activeChannel == "ALL" or self.activeChannel == channel then
        self:AddMessageToFrame(text, channel, sender, true)
    end
end

function ChatFrame:AddMessageToFrame(text, channel, sender, newMessage)
    local out = self:FormatMessage(text, sender, channel)
    self.msgFrame:AddMessage(out)
    if newMessage then
        self.msgFrame:ScrollToBottom()
    end
end

--------------------------------------------------------------------------------
-- Format message (timestamps, coloring, etc.)
--------------------------------------------------------------------------------
function ChatFrame:FormatMessage(text, sender, channel)
    local final = ""

    if self.db.profile.timestamps then
        final = format("|cff808080[%s]|r ", date(self.db.profile.timestampFormat))
    end

    if sender and sender ~= "" then
        local color = RAID_CLASS_COLORS["PRIEST"] or { r=1, g=1, b=1 }
        -- You can do better class detection if you want:
        if sender == PLAYER_NAME then
            color = RAID_CLASS_COLORS["MAGE"] or color
        end
        final = final .. format("|cff%02x%02x%02x%s|r: ", color.r*255, color.g*255, color.b*255, sender)
    end

    if channel ~= "ALL" then
        final = final .. format("|cff00ffff[%s]|r ", channel)
    end

    final = final .. text
    return final
end

--------------------------------------------------------------------------------
-- Overriding the default ENTER, if needed
--------------------------------------------------------------------------------
function ChatFrame:FocusInputBox()
    if not self.inputBox:IsShown() then
        self.inputBox:Show()
    end
    self.inputBox:SetFocus()
end

--------------------------------------------------------------------------------
-- Also keep or remove as you see fit
--------------------------------------------------------------------------------
function ChatFrame:HandleURL(url)
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = url })
end

function ChatFrame:SetChatFont()
    local fontPath = SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local fontSize = (tonumber(self.db.profile.fontSize) or 12)
    if fontSize < 8 then fontSize = 8 end
    if fontSize > 24 then fontSize = 24 end
    self.msgFrame:SetFont(fontPath, fontSize, "")
end
