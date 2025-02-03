local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local SM = LibStub("LibSharedMedia-3.0")

local L = AceLocale:GetLocale("SleekChat", true)
local ChatFrame = {}
addon.ChatFrame = ChatFrame

local floor, strtrim, format, strsplit = floor, strtrim, format, strsplit
local tinsert = table.insert

local PLAYER_NAME = UnitName("player") or "Player"
local RAID_CLASS_COLORS = RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"

--------------------------------------------------------------------------------
-- Initialize the custom chat frame UI
--------------------------------------------------------------------------------
function ChatFrame:Initialize(addonObj)
    self.addonObj = addonObj
    self.db = addonObj.db

    -- Keep track of pinned messages, user typed lines, etc.
    self.pinnedMessages = {}
    -- We'll show all channels by default
    self.activeChannel = "ALL"

    -- Create the main frame
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
        self.db.profile.position = {
            point = point,
            relPoint = relPoint,
            x = xOfs,
            y = yOfs,
        }
    end)

    if f.SetResizeBounds then
        f:SetResizeBounds(300, 150)
    elseif f.SetMinResize then
        f:SetMinResize(300, 150)
    end

    -- Resize corner
    local resize = CreateFrame("Button", nil, f)
    resize:SetSize(16,16)
    resize:SetPoint("BOTTOMRIGHT")
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resize:SetScript("OnMouseDown", function()
        f:StartSizing("BOTTOMRIGHT")
    end)
    resize:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        self.db.profile.width = floor(f:GetWidth())
        self.db.profile.height= floor(f:GetHeight())
        self:LayoutFrames()
    end)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile= "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize= 16,
        insets  = { left=4, right=4, top=4, bottom=4 },
    })
    f:SetBackdropColor(0,0,0, self.db.profile.backgroundOpacity or 0.8)

    -- Create a top row of tabs (ALL, SAY, PARTY, GUILD, WHISPER)
    self:CreateTabs()

    -- The scrolling message frame
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, f)
    self.messageFrame:SetFading(false)
    self.messageFrame:SetMaxLines(1000)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = strsplit(":", link, 2)
        if linkType == "url" then
            self:HandleURL(value)
        end
    end)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then
            scrollSpeed = scrollSpeed * 3
        end
        if delta > 0 then
            self.messageFrame:ScrollUp(scrollSpeed)
        else
            self.messageFrame:ScrollDown(scrollSpeed)
        end
    end)

    -- The input box pinned at bottom
    self.inputBox = CreateFrame("EditBox","SleekChatInputBox", f, "InputBoxTemplate")
    self.inputBox:SetAutoFocus(false)
    self.inputBox:SetHeight(24)
    self.inputBox:SetScript("OnEnterPressed", function(editBox)
        local text = strtrim(editBox:GetText() or "")
        if text ~= "" then
            self:SendSmartMessage(text)
        end
        editBox:SetText("")
        editBox:ClearFocus()
    end)

    self:LayoutFrames()
    self:SetChatFont()
    self:ApplyTheme()

    addonObj:PrintDebug("SleekChat UI initialized!")
end

--------------------------------------------------------------------------------
-- Create a simple tab row: ALL, SAY, PARTY, GUILD, WHISPER
--------------------------------------------------------------------------------
function ChatFrame:CreateTabs()
    local f = self.mainFrame
    self.tabButtons = {}

    local tabData = { "ALL", "SAY", "PARTY", "GUILD", "WHISPER" }

    local container = CreateFrame("Frame", nil, f)
    container:SetSize(self.db.profile.width - 8, 24)
    container:SetPoint("TOPLEFT", 4, -4)
    container:SetPoint("TOPRIGHT", -4, -4)
    self.tabContainer = container

    local xOffset = 0
    for i, channel in ipairs(tabData) do
        local btn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        btn:SetText(channel)
        btn:SetSize(80, 22)
        btn:SetPoint("LEFT", container, "LEFT", xOffset, 0)
        xOffset = xOffset + 84

        btn:SetScript("OnClick", function()
            self:SwitchChannel(channel)
        end)
        self.tabButtons[channel] = btn
    end
end

--------------------------------------------------------------------------------
-- Layout frames: top row for tabs, messageFrame in middle, input box bottom
--------------------------------------------------------------------------------
function ChatFrame:LayoutFrames()
    local f = self.mainFrame
    local topBarHeight = 28
    local pad = 8

    -- The tab container is near the top
    if self.tabContainer then
        self.tabContainer:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
        self.tabContainer:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    end

    -- The message frame below the tabs
    self.messageFrame:ClearAllPoints()
    self.messageFrame:SetPoint("TOPLEFT", f, "TOPLEFT", pad, -(topBarHeight+pad))
    self.messageFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -pad, -(topBarHeight+pad))
    self.messageFrame:SetPoint("BOTTOM", self.inputBox, "TOP", 0, 4)

    self.inputBox:ClearAllPoints()
    self.inputBox:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", pad, pad)
    self.inputBox:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -pad, pad)
end

--------------------------------------------------------------------------------
-- Actually sends chat to Blizzard servers (so other players see it),
-- also logs to history and displays in the custom UI.
--------------------------------------------------------------------------------
function ChatFrame:SendSmartMessage(text)
    local channel = self.activeChannel or "ALL"
    local slashChan = nil

    -- if user typed /p hi => forcibly set channel to PARTY
    if text:sub(1,1) == "/" then
        local c = text:match("^/(%S+)")
        if c == "p" or c == "party" then
            channel = "PARTY"
        elseif c == "g" or c == "guild" then
            channel = "GUILD"
        elseif c == "y" or c == "yell" then
            channel = "YELL"
        elseif c == "s" or c == "say" then
            channel = "SAY"
        end
    end

    -- Actually send to server
    self:SendToBlizzard(text, channel)

    -- Locally show the message
    self:AddIncoming(text, PLAYER_NAME, channel)
end

-- Convert our logical channel to the Blizz channel for SendChatMessage
function ChatFrame:SendToBlizzard(text, channel)
    local chatType = "SAY"
    if channel == "PARTY" then
        chatType = "PARTY"
    elseif channel == "RAID" then
        chatType = "RAID"
    elseif channel == "GUILD" then
        chatType = "GUILD"
    elseif channel == "YELL" then
        chatType = "YELL"
    elseif channel == "WHISPER" then
        -- user must specify a target if it's truly a whisper
        -- for now, let's skip or parse "/w target message"
        -- example placeholder
        return
    end

    if text:sub(1,1) == "/" then
        -- remove the slash from text
        text = text:gsub("^/%S+", ""):trim()
    end

    -- Actually send
    SendChatMessage(text, chatType)
end

--------------------------------------------------------------------------------
-- Called from Events.lua or from user typed
--------------------------------------------------------------------------------
function ChatFrame:AddIncoming(msg, sender, channel)
    if addon.ChatModeration and addon.ChatModeration:IsMuted(sender) then
        return
    end
    if addon.ChatModeration then
        msg = addon.ChatModeration:FilterMessage(msg)
    end

    -- Store in history
    if addon.History then
        addon.History:AddMessage(msg, sender, channel)
    end

    -- If the current tab wants to see it, display
    if self:ShouldDisplayChannel(channel) then
        self:AddMessage(msg, channel, sender)
    end
end

--------------------------------------------------------------------------------
-- Decide if a given channel should show in the active tab
--------------------------------------------------------------------------------
function ChatFrame:ShouldDisplayChannel(ch)
    if self.activeChannel == "ALL" then
        return true
    end
    return (self.activeChannel == ch)
end

--------------------------------------------------------------------------------
-- Actually add text to messageFrame
--------------------------------------------------------------------------------
function ChatFrame:AddMessage(text, channel, sender)
    local line = self:FormatMessage(text, sender, channel)
    self.messageFrame:AddMessage(line)
    self.messageFrame:ScrollToBottom()
end

--------------------------------------------------------------------------------
-- Format lines with timestamps, class coloring, etc.
--------------------------------------------------------------------------------
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
        final = final .. format("|cff%02x%02x%02x%s|r: ",
                color.r*255, color.g*255, color.b*255, sender)
    end

    if channel ~= "ALL" then
        final = final .. format("|cff00ffff[%s]|r ", channel)
    end

    final = final .. text
    return final
end

--------------------------------------------------------------------------------
-- Switch the active channel tab
--------------------------------------------------------------------------------
function ChatFrame:SwitchChannel(newChannel)
    self.activeChannel = newChannel
    self.messageFrame:Clear()

    -- Re-display from history for that channel (or ALL)
    if newChannel == "ALL" then
        if addon.History and addon.History.messages then
            for chName, list in pairs(addon.History.messages) do
                for i=#list, 1, -1 do
                    local msgData = list[i]
                    self:AddMessage(msgData.text, msgData.channel, msgData.sender)
                end
            end
        end
    else
        if addon.History and addon.History.messages[newChannel] then
            local messages = addon.History.messages[newChannel]
            for i=#messages, 1, -1 do
                local m = messages[i]
                self:AddMessage(m.text, m.channel, m.sender)
            end
        end
    end

    self.messageFrame:ScrollToBottom()
end

--------------------------------------------------------------------------------
-- Pin message example
--------------------------------------------------------------------------------
function ChatFrame:PinMessage(msg)
    if not self.db.profile.enablePinning then return end
    tinsert(self.pinnedMessages, msg)
    self:RedrawAll()
end

function ChatFrame:RedrawAll()
    self.messageFrame:Clear()

    -- show pinned first
    for _, pin in ipairs(self.pinnedMessages) do
        self.messageFrame:AddMessage("|cffFFD700[PINNED]|r "..pin)
    end

    if self.activeChannel=="ALL" then
        if addon.History then
            for chName, list in pairs(addon.History.messages or {}) do
                for i=#list,1,-1 do
                    local m = list[i]
                    self:AddMessage(m.text, m.channel, m.sender)
                end
            end
        end
    else
        local list = addon.History and addon.History.messages[self.activeChannel]
        if list then
            for i=#list,1,-1 do
                local m = list[i]
                self:AddMessage(m.text, m.channel, m.sender)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Theming & Font
--------------------------------------------------------------------------------
function ChatFrame:ApplyTheme()
    local f = self.mainFrame
    local dark = self.db.profile.darkMode
    local alpha = dark and 0.7 or (self.db.profile.backgroundOpacity or 0.8)
    f:SetBackdropColor(0,0,0, alpha)
end

function ChatFrame:SetChatFont()
    local path = SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local size = self.db.profile.fontSize or 12
    if size<8 then size=8 end
    if size>24 then size=24 end
    self.messageFrame:SetFont(path, size, "")
end

--------------------------------------------------------------------------------
-- URL Handling
--------------------------------------------------------------------------------
function ChatFrame:HandleURL(url)
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = url })
end
