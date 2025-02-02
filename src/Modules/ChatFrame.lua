local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

-- Cache frequently used
local floor, date, format, gsub, ipairs, pairs, select, strlower, strsplit, tinsert =
math.floor, date, string.format, string.gsub, ipairs, pairs, select, string.lower, strsplit, table.insert

local UnitName, UnitClass, IsShiftKeyDown, PlaySound, GameTooltip =
UnitName, UnitClass, IsShiftKeyDown, PlaySound, GameTooltip

local RAID_CLASS_COLORS = RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"
local PLAYER_NAME = UnitName("player")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

---------------------------------------------------------------------
-- URL patterns, priority rules, mention triggers
---------------------------------------------------------------------
local URL_PATTERNS = {
    "https?://[%w-_%%%.%?%.:/%+=&]+",
    "www%.[%w-_%%]+%.%w%w%w?%w?%.?%w*",
    "ftp://[%w-_%%%.%?%.:/%+=&]+",
    "[%w_.%%+-]+@[%w_.%%+-]+%.%w%w%w?%w?",     -- Email
    "%d?%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?", -- IP:port
}

local MESSAGE_PRIORITY = {
    WHISPER = 3,
    PARTY   = 2,
    RAID    = 2,
    GUILD   = 1.5,
    YELL    = 1,
    SAY     = 1,
}

local SMART_FEATURES = {
    MENTION_TRIGGERS     = { strlower(PLAYER_NAME), "@", "!" },
    INACTIVE_TAB_TIMEOUT = 1800, -- 30 min
    MAX_WHISPER_TABS     = 5,
    TAB_WIDTH_RANGE      = { 60, 150 },
}

---------------------------------------------------------------------
-- Simple class cache
---------------------------------------------------------------------
local classCache = setmetatable({}, {
    __index = function(t, sender)
        local class = ChatFrame:GetPlayerClass(sender)
        rawset(t, sender, class or false)
        return class
    end
})

function ChatFrame:GetPlayerClass(sender)
    if sender == PLAYER_NAME then
        return select(2, UnitClass("player"))
    end
    -- Check party/raid for that name
    for prefix, maxMembers in pairs({ party = 4, raid = 40 }) do
        for i = 1, maxMembers do
            local unit = prefix..i
            if not UnitName(unit) then break end
            if UnitName(unit) == sender then
                return select(2, UnitClass(unit))
            end
        end
    end
end

---------------------------------------------------------------------
-- TabManager stubs
---------------------------------------------------------------------
local TabManager = {
    activeTabs  = {},
    whisperTabs = {},
}

function TabManager:AddTab(tabType, identifier)
    self.whisperTabs[identifier] = { lastActivity = time() }
end

function TabManager:CleanupOldTabs()
    -- Example: remove or hide old whisper tabs
end

function TabManager:UpdateTabVisuals()
    -- Example: highlight or fade tabs
end

---------------------------------------------------------------------
-- MessageProcessor
---------------------------------------------------------------------
local MessageProcessor = {}

function MessageProcessor:ParseMessage(text, sender, channel)
    local processed = {
        original = text,
        links    = {},
        mentions = {},
        priority = MESSAGE_PRIORITY[channel] or 1
    }

    -- Detect URLs
    for _, pattern in ipairs(URL_PATTERNS) do
        processed.original = gsub(processed.original, pattern, function(url)
            tinsert(processed.links, url)
            return format("|cff00FFFF|Hurl:%s|h[Link]|h|r", url)
        end)
    end

    -- Mention detection
    local lowerText = strlower(processed.original)
    for _, trigger in ipairs(SMART_FEATURES.MENTION_TRIGGERS) do
        if lowerText:find(trigger, 1, true) then
            processed.priority = math.max(processed.priority, 4)
            tinsert(processed.mentions, trigger)
            break
        end
    end

    return processed
end

function MessageProcessor:ShouldNotify(msg)
    return (#msg.mentions > 0) or (msg.priority >= 3)
end

---------------------------------------------------------------------
-- ChatFrame methods
---------------------------------------------------------------------
function ChatFrame:HandleWhisper(sender, msg)
    local channelName = "WHISPER:"..sender
    if not self.db.profile.messageHistory[channelName] then
        self.db.profile.messageHistory[channelName] = {}
    end
    TabManager:AddTab("WHISPER", sender)
    return true
end

function ChatFrame:Initialize(addonObj)
    self.db = addonObj.db
    self.activeChannel = "SAY"
    self.messageQueue = {}
    self.pinnedMessages = {}

    -- Main frame
    self.chatFrame = CreateFrame("Frame", "SleekChatMainFrame", UIParent, "BackdropTemplate")
    self.chatFrame:SetSize(self.db.profile.width, self.db.profile.height)
    self.chatFrame:SetPoint(
            self.db.profile.position.point,
            UIParent,
            self.db.profile.position.relPoint,
            floor(self.db.profile.position.x),
            floor(self.db.profile.position.y)
    )

    -- Resizable
    self.chatFrame:SetResizable(true)
    self.chatFrame:SetMinResize(200, 100)
    local resizeButton = CreateFrame("Button", nil, self.chatFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetScript("OnMouseDown", function()
        self.chatFrame:StartSizing("BOTTOMRIGHT")
    end)
    resizeButton:SetScript("OnMouseUp", function()
        self.chatFrame:StopMovingOrSizing()
        self.db.profile.width = floor(self.chatFrame:GetWidth())
        self.db.profile.height = floor(self.chatFrame:GetHeight())
        self:UpdateTabPositions()
    end)

    -- Draggable
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
            y = floor(y),
        }
    end)

    -- Backdrop
    self.chatFrame:SetBackdrop({
        bgFile = SM:Fetch("background", self.db.profile.background) or "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = SM:Fetch("border", self.db.profile.border) or "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left=4, right=4, top=4, bottom=4 },
    })

    -- ScrollingMessageFrame
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:SetPoint("TOPLEFT", 8, -30)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -8, 40)
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetMaxLines(1000)
    self.messageFrame:EnableMouseWheel(true)
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then
            scrollSpeed = scrollSpeed * 3
        end
        self.messageFrame:ScrollByAmount(-delta * scrollSpeed)
    end)

    -- Hyperlink clicks
    self.messageFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = strsplit(":", link, 2)
        if linkType == "player" then
            self:StartConversation(value)
        elseif linkType == "url" then
            self:HandleURL(value)
        end
    end)

    self:UpdateFonts()

    -- Edit box
    self.editBox = CreateFrame("EditBox", "SleekChatInputBox", self.chatFrame, "InputBoxTemplate")
    self.editBox:SetPoint("BOTTOMLEFT", 8, 8)
    self.editBox:SetPoint("BOTTOMRIGHT", -8, 8)
    self.editBox:SetHeight(24)
    self.editBox:SetAutoFocus(false)
    self.editBox.autoComplete = {}

    self.editBox:SetScript("OnEnterPressed", function(f)
        local text = f:GetText() and f:GetText():trim()
        if text and text ~= "" then
            self:SendSmartMessage(text)
            if addon.History then
                addon.History:AddMessage(text, PLAYER_NAME, self.activeChannel)
            end
        end
        f:SetText("")
        f:ClearFocus()
    end)

    -- Auto-complete
    self.editBox:SetScript("OnTextChanged", function(f, userInput)
        if userInput and self.db.profile.enableAutoComplete then
            self:UpdateAutoComplete(f:GetText())
        end
    end)

    -- Tabs
    self:InitializeTabSystem()

    -- Periodic cleanup (needs AceTimer-3.0)
    addonObj:ScheduleRepeatingTimer(function()
        TabManager:CleanupOldTabs()
        self:ProcessMessageQueue()
    end, 5)

    self:RegisterSlashCommands()

    addon:PrintDebug("SleekChat initialized with smart features")
    self:ApplyTheme()
end

function ChatFrame:UpdateFonts()
    local fontPath = SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local fontSize = tonumber(self.db.profile.fontSize) or 12
    if fontSize < 8 then fontSize = 8 end
    if fontSize > 24 then fontSize = 24 end

    self.messageFrame:SetFont(fontPath, fontSize, "")
    self.messageFrame:SetShadowColor(0, 0, 0, 1)
    self.messageFrame:SetShadowOffset(1, -1)
end

function ChatFrame:SendSmartMessage(text)
    local processed = MessageProcessor:ParseMessage(text, PLAYER_NAME, self.activeChannel)

    -- Check for slash
    if text:sub(1,1) == "/" then
        local command = strsplit(" ", text:sub(2)):lower()
        if command == "p" or command == "party" then
            self.activeChannel = "PARTY"
        elseif command == "raid" then
            self.activeChannel = "RAID"
        end
    end

    if processed.priority >= 3 then
        self:FlashTab(self.activeChannel)
        if self.db.profile.mentionSounds then
            PlaySound(SOUNDKIT.IG_PLAYER_INVITE)
        end
    end

    self:AddMessage(processed.original, self.activeChannel, PLAYER_NAME)
end

function ChatFrame:AddMessage(text, eventType, sender)
    local processed = MessageProcessor:ParseMessage(text, sender, eventType)
    local formatted = self:FormatMessage(processed.original, sender, eventType)

    if processed.priority > 2 then
        table.insert(self.messageQueue, 1, { formatted, eventType })
    else
        table.insert(self.messageQueue, { formatted, eventType })
    end

    if #self.messageQueue > 50 then
        self:ProcessMessageQueue()
    end
end

function ChatFrame:ProcessMessageQueue()
    for i, msgData in ipairs(self.messageQueue) do
        local text = msgData[1]
        local chan = msgData[2]
        if chan == self.activeChannel then
            self.messageFrame:AddMessage(text)
        end
        self.messageQueue[i] = nil
    end
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:FlashTab(channel)
    -- Stub: highlight or flash the active channel's tab
end

function ChatFrame:FormatMessage(text, sender, channel)
    local parts = {}

    -- Timestamp
    if self.db.profile.timestamps then
        table.insert(parts, format("|cff798BDD%s|r", date(self.db.profile.timestampFormat)))
    end

    -- Class-colored sender
    if sender then
        local class = classCache[sender]
        local color = class and RAID_CLASS_COLORS[class] or {r=0.8, g=0.8, b=0.8}
        sender = format("|cff%02x%02x%02x|Hplayer:%s|h%s|h|r",
                color.r*255, color.g*255, color.b*255, sender, sender)
    end

    local channelIcon = ""
    if self.db.profile.channelIcons and addon.ChannelIcons then
        channelIcon = addon.ChannelIcons[channel] or ""
    end

    table.insert(parts, format("[%s%s]", channelIcon, channel))
    if sender then
        table.insert(parts, sender..":")
    end
    table.insert(parts, text)

    return table.concat(parts, " ")
end

---------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------
function ChatFrame:InitializeTabSystem()
    -- A simple pool for reusing tab buttons
    self.tabPool = CreateFramePool("Button", self.chatFrame, function(pool, tab)
        tab:ClearAllPoints()
        tab:Hide()
    end)

    self.tabScrollFrame = CreateFrame("ScrollFrame", nil, self.chatFrame, "UIPanelScrollFrameTemplate")
    self.tabScrollFrame:SetPoint("TOPLEFT", self.chatFrame, "TOPLEFT", 5, -5)
    self.tabScrollFrame:SetSize(self.db.profile.width - 10, 30)

    -- Removed the unused self:RegisterMessage("SLEEKCHAT_SETTINGS_CHANGED", "UpdateTabSystem")
    self:UpdateTabSystem()
end

function ChatFrame:UpdateTabSystem()
    self.tabPool:ReleaseAll()

    for channel, enabled in pairs(self.db.profile.channels) do
        if enabled then
            local tab = self.tabPool:Acquire()
            self:ConfigureTab(tab, channel)
            tab:Show()
        end
    end

    self:UpdateTabPositions()
end

function ChatFrame:ConfigureTab(tab, channel)
    tab:SetSize(self.db.profile.tabWidth, 24)
    if not tab.textFS then
        tab.textFS = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.textFS:SetPoint("CENTER")
    end
    tab.textFS:SetText(channel:gsub("WHISPER:", ""))

    tab:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            self:ToggleChannel(channel)
        else
            self:SwitchChannel(channel)
        end
    end)

    tab:SetScript("OnEnter", function()
        GameTooltip:SetOwner(tab, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(channel)
        if channel:find("WHISPER:") and TabManager.whisperTabs[channel:gsub("WHISPER:", "")] then
            local info = TabManager.whisperTabs[channel:gsub("WHISPER:", "")]
            if info.lastActivity then
                GameTooltip:AddLine("Last activity: "..date("%X", info.lastActivity))
            end
        end
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", GameTooltip_Hide)
end

function ChatFrame:UpdateTabPositions()
    local xOffset = 0
    for tab in self.tabPool:EnumerateActive() do
        tab:ClearAllPoints()
        tab:SetPoint("BOTTOMLEFT", self.tabScrollFrame, "BOTTOMLEFT", xOffset, 0)
        xOffset = xOffset + tab:GetWidth() + 2
    end

    local neededWidth = xOffset - self.tabScrollFrame:GetWidth()
    if neededWidth < 0 then
        neededWidth = 0
    end
    self.tabScrollFrame:SetHorizontalScroll(neededWidth)
end

function ChatFrame:ToggleChannel(channel)
    -- Stub: e.g., close/detach channel
end

function ChatFrame:SwitchChannel(channel)
    self.activeChannel = channel
    self.messageFrame:Clear()

    if addon.History and addon.History.messages and addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            self:AddMessage(msg.text, msg.channel, msg.sender)
        end
    end
    TabManager:UpdateTabVisuals()
    self.messageFrame:ScrollToBottom()

    if addon.AdvancedMessaging and addon.AdvancedMessaging.SwitchChannel then
        addon.AdvancedMessaging:SwitchChannel(channel)
    end
end

---------------------------------------------------------------------
-- Pinning messages
---------------------------------------------------------------------
function ChatFrame:PinMessage(message)
    if not self.db.profile.enablePinning then return end
    table.insert(self.pinnedMessages, message)
    self:UpdateAll()
end

function ChatFrame:UpdateAll()
    self.messageFrame:Clear()

    for _, msg in ipairs(self.pinnedMessages) do
        self.messageFrame:AddMessage("|cffFFD700[PINNED]|r "..msg)
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

---------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------
function ChatFrame:RegisterSlashCommands()
    addon.SlashCommands = {
        config = {
            handler = function() addon:OpenConfig() end,
            usage   = "/sleekchat config - Open settings"
        },
        clearchat = {
            handler = function() self.messageFrame:Clear() end,
            usage   = "/sleekchat clearchat - Clear current chat"
        },
        find = {
            handler = function(msg)
                self:SearchMessages(strtrim(msg))
            end,
            usage   = "/sleekchat find <text> - Search chat history"
        },
    }

    for cmd, info in pairs(addon.SlashCommands) do
        _G["SLASH_SLEEKCHAT"..cmd:upper().."1"] = "/sleekchat "..cmd
        SlashCmdList["SLEEKCHAT"..cmd:upper()] = info.handler
    end
end

function ChatFrame:SearchMessages(term)
    if not term or term == "" then return end
    local results = {}

    if addon.History and addon.History.messages then
        for channel, messages in pairs(addon.History.messages) do
            for _, msg in ipairs(messages) do
                if strlower(msg.text):find(strlower(term), 1, true) then
                    tinsert(results, msg)
                end
            end
        end
    end

    self.messageFrame:Clear()
    for _, msg in ipairs(results) do
        self:AddMessage(msg.text, msg.channel, msg.sender)
    end
end

---------------------------------------------------------------------
-- Auto-complete
---------------------------------------------------------------------
function ChatFrame:UpdateAutoComplete(input)
    self.editBox.autoComplete = {}

    if input:sub(1, 1) == "/" then
        for cmd, info in pairs(addon.SlashCommands) do
            local cmdCheck = "/"..cmd
            if cmdCheck:find(input, 1, true) then
                tinsert(self.editBox.autoComplete, info.usage)
            end
        end
    else
        for name in pairs(classCache) do
            if strlower(name):find(strlower(input), 1, true) then
                tinsert(self.editBox.autoComplete, name)
            end
        end
    end

    if #self.editBox.autoComplete > 0 then
        ChatEdit_CompleteChat(self.editBox)
    end
end

---------------------------------------------------------------------
-- Helper stubs
---------------------------------------------------------------------
function ChatFrame:StartConversation(target)
    self.activeChannel = "WHISPER:"..target
    self.messageFrame:AddMessage(format("|cffffff00Starting whisper to %s...|r", target))
end

function ChatFrame:HandleURL(url)
    -- Show our unified popup
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG", nil, nil, { url = url })
end

function ChatFrame:ApplyTheme()
    local theme = self.db.profile.theme or {
        background = {r = 0, g = 0, b = 0, a = 0.6},
        border     = {r = 1, g = 1, b = 1, a = 1},
        shadowAlpha= 1,
    }
    self.chatFrame:SetBackdropColor(theme.background.r, theme.background.g, theme.background.b, theme.background.a)
    self.chatFrame:SetBackdropBorderColor(theme.border.r, theme.border.g, theme.border.b, theme.border.a)
    self.messageFrame:SetShadowColor(0, 0, 0, theme.shadowAlpha or 1)
end

return ChatFrame
