local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local SM = LibStub("LibSharedMedia-3.0")

local L = AceLocale:GetLocale("SleekChat", true)
local ChatFrame = {}
addon.ChatFrame = ChatFrame

-- Utility shortcuts
local floor, format, gsub, strlower, strsplit = floor, format, gsub, strlower, strsplit
local tinsert = table.insert

local PLAYER_NAME = UnitName("player") or "Player"
local RAID_CLASS_COLORS = RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"

--------------------------------------------------------------------------------
-- Initialize main chat UI
--------------------------------------------------------------------------------
function ChatFrame:Initialize(addonObj)
    self.addonObj = addonObj
    self.db = addonObj.db
    self.pinnedMessages = {}   -- For pinned message feature
    self.activeChannel = "SAY" -- Default selection
    self.messageQueue = {}

    -- Main window
    local f = CreateFrame("Frame", "SleekChat_MainFrame", UIParent, "BackdropTemplate")
    self.mainFrame = f
    f:SetSize(self.db.profile.width, self.db.profile.height)
    f:SetPoint(
            self.db.profile.position.point,
            UIParent,
            self.db.profile.position.relPoint,
            floor(self.db.profile.position.x),
            floor(self.db.profile.position.y)
    )
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
    resize:SetSize(16,16)
    resize:SetPoint("BOTTOMRIGHT")
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resize:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        self.db.profile.width  = floor(f:GetWidth())
        self.db.profile.height = floor(f:GetHeight())
        self:LayoutFrames()
    end)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets  = {left=4, right=4, top=4, bottom=4},
    })
    f:SetBackdropColor(0,0,0,0.8)

    -- MessageFrame
    local msg = CreateFrame("ScrollingMessageFrame", "SleekChat_MessageFrame", f)
    self.msgFrame = msg
    msg:SetFading(false)
    msg:SetMaxLines(2000)
    msg:SetHyperlinksEnabled(true)
    msg:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = strsplit(":", link, 2)
        if linkType == "url" then
            self:HandleURL(value)
        elseif linkType == "player" then
            self:SwitchChannel("WHISPER:"..value)
        end
    end)
    msg:EnableMouseWheel(true)
    msg:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then
            scrollSpeed = scrollSpeed * 3
        end
        if delta > 0 then
            msg:ScrollUp(scrollSpeed)
        else
            msg:ScrollDown(scrollSpeed)
        end
    end)

    -- Input box
    local edit = CreateFrame("EditBox","SleekChat_InputBox", f, "InputBoxTemplate")
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

    -- "Gear" icon or button for channel manager
    local gear = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    gear:SetSize(24,24)
    gear:SetPoint("TOPRIGHT", -4, -4)
    gear:SetText("⚙")  -- Potential font fallback issue; see #Issue2 below
    gear:SetScript("OnClick", function() self:ToggleChannelManager() end)

    -- Channel manager frame (initially hidden)
    self:CreateChannelManager()

    -- Final layout
    self:LayoutFrames()
    self:SetChatFont()
    self:ApplyTheme()

    addonObj:PrintDebug("SleekChat UI initialized")
end

--------------------------------------------------------------------------------
-- Layout/Positioning
--------------------------------------------------------------------------------
function ChatFrame:LayoutFrames()
    local f = self.mainFrame
    local pad = 8

    -- The message frame
    self.msgFrame:ClearAllPoints()
    self.msgFrame:SetPoint("TOPLEFT", f, "TOPLEFT", pad, -40)
    self.msgFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -pad, -40)
    self.msgFrame:SetPoint("BOTTOM", self.inputBox, "TOP", 0, 4)

    -- The input box
    self.inputBox:ClearAllPoints()
    self.inputBox:SetPoint("LEFT", f, "LEFT", pad, 8)
    self.inputBox:SetPoint("RIGHT", f, "RIGHT", -pad, 8)
    self.inputBox:SetHeight(24)
end

--------------------------------------------------------------------------------
-- Channel Manager
--------------------------------------------------------------------------------
function ChatFrame:CreateChannelManager()
    local cm = CreateFrame("Frame", "SleekChat_ChannelManager", self.mainFrame, "BackdropTemplate")
    self.channelManager = cm
    cm:SetSize(200, 250)
    cm:SetPoint("TOPRIGHT", self.mainFrame, "TOPLEFT", -4, 0)
    cm:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile= "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize= 16,
    })
    cm:SetBackdropColor(0,0,0,0.9)
    cm:Hide()

    local title = cm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Channels")

    cm.scrollFrame = CreateFrame("ScrollFrame", nil, cm, "UIPanelScrollFrameTemplate")
    cm.scrollFrame:SetPoint("TOPLEFT", 10, -30)
    cm.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    -- Child frame for the scroll area
    local content = CreateFrame("Frame", nil, cm.scrollFrame)
    cm.scrollFrame:SetScrollChild(content)
    content:SetSize(160, 200)
    cm.content = content

    cm.checkButtons = {}
end

function ChatFrame:ToggleChannelManager()
    if self.channelManager:IsShown() then
        self.channelManager:Hide()
    else
        self:RefreshChannelManager()
        self.channelManager:Show()
    end
end

function ChatFrame:RefreshChannelManager()
    local cm = self.channelManager
    if not cm then return end

    local content = cm.content
    local checks = cm.checkButtons

    -- Wipe old
    for _, chk in ipairs(checks) do
        chk:Hide()
    end

    local channels = self:GetAvailableChannels()  -- see below
    local offsetY = -5
    local idx = 1

    for _, chName in ipairs(channels) do
        -- #1 FIX: Provide a non-nil, unique name for the check button
        local checkName = "SleekChatCheckButton"..idx
        local chk = checks[idx]
        if not chk then
            chk = CreateFrame("CheckButton", checkName, content, "ChatConfigCheckButtonTemplate")
            checks[idx] = chk
        end

        -- #2 Now we can safely do:
        chk.text = _G[checkName.."Text"] or chk:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chk.text:SetPoint("LEFT", chk, "RIGHT", 0, 1)

        chk:Show()
        chk:SetPoint("TOPLEFT", 10, offsetY)

        -- Possibly user renamed
        local label = chName
        if self.db.profile.renamedChannels and self.db.profile.renamedChannels[chName] then
            label = self.db.profile.renamedChannels[chName]
        end
        -- #3 fallback if label is somehow nil
        if not label then
            label = "[Unknown]"
        end
        chk.text:SetText(label)

        -- If the user toggled channelName off, store false in db
        local defaultOn = (chName ~= "SYSTEM") -- or your logic
        local current = self.db.profile.channels[chName]
        if current == nil then
            current = defaultOn
        end
        chk:SetChecked(current)

        chk:SetScript("OnClick", function(btn)
            local c = btn:GetChecked()
            self.db.profile.channels[chName] = c
            -- #4 optional: re-display chat to reflect immediate toggles
            self:UpdateAll()
        end)

        offsetY = offsetY - 24
        idx = idx + 1
    end

    content:SetHeight(math.abs(offsetY) + 30)
end

-- Example dynamic channel fetch:
function ChatFrame:GetAvailableChannels()
    local list = {}

    -- Built-in ephemeral channels
    local ephemeral = {"SAY","YELL","PARTY","RAID","GUILD","WHISPER","SYSTEM"}
    for _, name in ipairs(ephemeral) do
        tinsert(list, name)
    end

    -- Grab custom channels from the game
    for i=1,30 do
        local id, chName = GetChannelName(i)
        if id and id > 0 and chName and chName:trim() ~= "" then
            tinsert(list, chName)
        end
    end

    table.sort(list)
    return list
end

--------------------------------------------------------------------------------
-- Handling user typed messages
--------------------------------------------------------------------------------
function ChatFrame:SendMessage(text)
    self:AddIncoming(text, PLAYER_NAME, self.activeChannel)
end

function ChatFrame:AddIncoming(text, sender, channel)
    -- Chat moderation
    if addon.ChatModeration and addon.ChatModeration:IsMuted(sender) then
        return
    end
    if addon.ChatModeration then
        text = addon.ChatModeration:FilterMessage(text)
    end

    -- Save in History
    if addon.History then
        addon.History:AddMessage(text, sender, channel)
    end

    -- If channel is toggled on, we show it
    local show = self:ShouldDisplayChannel(channel)
    if show then
        self:AddMessageToFrame(text, channel, sender, true)
    end
end

function ChatFrame:ShouldDisplayChannel(chName)
    if self.activeChannel == "ALL" then
        local enabled = self.db.profile.channels[chName]
        if enabled == nil then
            return true
        else
            return enabled
        end
    else
        return (self.activeChannel == chName)
    end
end

function ChatFrame:AddMessageToFrame(text, channel, sender, newMsg)
    local line = self:FormatMessage(text, sender, channel)
    self.msgFrame:AddMessage(line)
    if newMsg then
        self.msgFrame:ScrollToBottom()
    end
end

function ChatFrame:FormatMessage(text, sender, channel)
    local final = ""
    if self.db.profile.timestamps then
        final = format("|cff808080[%s]|r ", date(self.db.profile.timestampFormat))
    end

    if sender and sender ~= "" then
        local color = RAID_CLASS_COLORS["PRIEST"] or {r=1,g=1,b=1}
        if sender == PLAYER_NAME then
            color = RAID_CLASS_COLORS["MAGE"] or color
        end
        final = final .. format("|cff%02x%02x%02x%s|r: ", color.r*255,color.g*255,color.b*255, sender)
    end

    if channel ~= "ALL" and channel ~= "SYSTEM" then
        final = final .. format("|cff00ffff[%s]|r ", channel)
    end

    final = final .. (text or "")
    return final
end

--------------------------------------------------------------------------------
-- If we get a whisper event
--------------------------------------------------------------------------------
function ChatFrame:HandleWhisper(sender, msg)
    -- e.g. open a dedicated “WHISPER:Name” or show in “WHISPER”
end

--------------------------------------------------------------------------------
-- Pinned Messages
--------------------------------------------------------------------------------
function ChatFrame:PinMessage(msg)
    if not self.db.profile.enablePinning then return end
    tinsert(self.pinnedMessages, msg)
    self:UpdateAll()
end

function ChatFrame:UpdateAll()
    self.msgFrame:Clear()
    for _, pinned in ipairs(self.pinnedMessages) do
        self.msgFrame:AddMessage("|cffFFD700[PINNED]|r ".. pinned)
    end

    if addon.History and addon.History.messages then
        for ch, list in pairs(addon.History.messages) do
            for i = #list,1,-1 do
                local data = list[i]
                if self:ShouldDisplayChannel(ch) then
                    self:AddMessageToFrame(data.text, data.channel, data.sender, false)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Theming & Font
--------------------------------------------------------------------------------
function ChatFrame:ApplyTheme()
    local dark = self.db.profile.darkMode
    local bgAlpha = dark and 0.6 or self.db.profile.backgroundOpacity
    self.mainFrame:SetBackdropColor(0, 0, 0, bgAlpha)
end

function ChatFrame:SetChatFont()
    local fontPath = SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local fontSize = self.db.profile.fontSize or 12
    if fontSize < 8 then fontSize = 8 end
    if fontSize > 24 then fontSize = 24 end
    self.msgFrame:SetFont(fontPath, fontSize, "")
end

--------------------------------------------------------------------------------
-- Expose a channel switch for ephemeral usage
--------------------------------------------------------------------------------
function ChatFrame:SwitchChannel(ch)
    self.activeChannel = ch
    self.msgFrame:Clear()

    if ch == "ALL" then
        if addon.History then
            for cName, messages in pairs(addon.History.messages or {}) do
                for i=#messages,1,-1 do
                    local data = messages[i]
                    if self:ShouldDisplayChannel(cName) then
                        self:AddMessageToFrame(data.text, data.channel, data.sender, false)
                    end
                end
            end
        end
    else
        if addon.History and addon.History.messages[ch] then
            local list = addon.History.messages[ch]
            for i=#list,1,-1 do
                local data = list[i]
                self:AddMessageToFrame(data.text, data.channel, data.sender, false)
            end
        end
    end
    self.msgFrame:ScrollToBottom()
end

--------------------------------------------------------------------------------
-- URL Handling
--------------------------------------------------------------------------------
function ChatFrame:HandleURL(url)
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = url })
end
