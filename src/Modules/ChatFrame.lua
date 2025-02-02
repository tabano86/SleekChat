local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

-- Cache frequently used functions and values
local floor, date, format, gsub, ipairs, pairs, select, strlower, strsplit, tinsert =
math.floor, date, string.format, string.gsub, ipairs, pairs, select, string.lower, strsplit, table.insert

-- Some WoW globals used below
local UnitName, UnitClass, IsShiftKeyDown, PlaySound, GameTooltip =
UnitName, UnitClass, IsShiftKeyDown, PlaySound, GameTooltip

-- Class color fallback
local RAID_CLASS_COLORS = RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"
local PLAYER_NAME = UnitName("player")

addon.ChatFrame = {}
local ChatFrame = addon.ChatFrame

---------------------------------------------------------------------
-- URL patterns, priority rules, and “smart” features
---------------------------------------------------------------------
local URL_PATTERNS = {
    -- Enhanced URL patterns with TLD validation and special chars
    "https?://[%w-_%%%.%?%.:/%+=&]+",
    "www%.[%w-_%%]+%.%w%w%w?%w?%.?%w*",
    "ftp://[%w-_%%%.%?%.:/%+=&]+",
    "[%w_.%%+-]+@[%w_.%%+-]+%.%w%w%w?%w?",     -- Email
    "%d?%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?", -- IP:port
}

local MESSAGE_PRIORITY = {
    ["WHISPER"] = 3,
    ["PARTY"]   = 2,
    ["RAID"]    = 2,
    ["GUILD"]   = 1.5,
    ["YELL"]    = 1,
    ["SAY"]     = 1,
}

local SMART_FEATURES = {
    MENTION_TRIGGERS      = { strlower(PLAYER_NAME), "@", "!" },
    INACTIVE_TAB_TIMEOUT  = 1800, -- 30 minutes
    MAX_WHISPER_TABS      = 5,
    TAB_WIDTH_RANGE       = { 60, 150 },
}

---------------------------------------------------------------------
-- Player class cache, with fallback for group scanning
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

    -- Check party and raid
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
-- TabManager: stubs for advanced tab behavior (fading, cleanup, etc.)
---------------------------------------------------------------------
local TabManager = {
    activeTabs   = {},
    whisperTabs  = {},

    AddTab = function(self, tabType, identifier)
        -- Implementation placeholder: track whisper tabs, etc.
        -- If you want to handle special whisper-only logic, do it here.
        self.whisperTabs[identifier] = {
            lastActivity = time(),
        }
    end,

    CleanupOldTabs = function(self)
        -- Example: remove tabs that haven't been active for a while
        -- or keep the total whisper tabs below SMART_FEATURES.MAX_WHISPER_TABS
    end,

    UpdateTabVisuals = function(self)
        -- Example: highlight active channel tab, fade inactive, etc.
    end,
}

---------------------------------------------------------------------
-- MessageProcessor: parses message for URLs, mentions, priority
---------------------------------------------------------------------
local MessageProcessor = {
    ParseMessage = function(text, sender, channel)
        local processed = {
            original = text,
            links    = {},
            mentions = {},
            priority = MESSAGE_PRIORITY[channel] or 1
        }

        -- URL detection
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
    end,

    ShouldNotify = function(processedMessage)
        -- Example rule: notify if we have mentions or high priority
        return (#processedMessage.mentions > 0) or (processedMessage.priority >= 3)
    end
}

---------------------------------------------------------------------
-- ChatFrame methods
---------------------------------------------------------------------

-- Handle incoming whispers, create a dedicated tab if needed
function ChatFrame:HandleWhisper(sender, msg)
    local channelName = "WHISPER:"..sender
    if not self.db.profile.messageHistory[channelName] then
        self.db.profile.messageHistory[channelName] = {}
    end

    -- Create or register a whisper tab in TabManager
    TabManager:AddTab("WHISPER", sender)
    return true
end

-- Initialize the main chat frame, hooking up everything
function ChatFrame:Initialize(addonObj)
    self.db           = addonObj.db
    self.activeChannel = "SAY"
    self.messageQueue  = {}
    self.pinnedMessages = {} -- from old code, if you want pinning

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

    -- Allow resizing
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
        self.db.profile.width  = floor(self.chatFrame:GetWidth())
        self.db.profile.height = floor(self.chatFrame:GetHeight())
        self:UpdateTabPositions() -- in case you want to re-layout tabs
    end)

    -- Allow dragging
    self.chatFrame:EnableMouse(true)
    self.chatFrame:SetMovable(true)
    self.chatFrame:RegisterForDrag("LeftButton")
    self.chatFrame:SetScript("OnDragStart", self.chatFrame.StartMoving)
    self.chatFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint(1)
        self.db.profile.position = {
            point   = point,
            relPoint= relPoint,
            x       = floor(x),
            y       = floor(y),
        }
    end)

    -- Use SharedMedia for backdrop
    self.chatFrame:SetBackdrop({
        bgFile   = SM:Fetch("background", self.db.profile.background) or "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = SM:Fetch("border", self.db.profile.border) or "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    -- ScrollingMessageFrame for chat messages
    self.messageFrame = CreateFrame("ScrollingMessageFrame", nil, self.chatFrame)
    self.messageFrame:SetHyperlinksEnabled(true)
    self.messageFrame:SetPoint("TOPLEFT", 8, -30)
    self.messageFrame:SetPoint("BOTTOMRIGHT", -8, 40)
    self.messageFrame:SetJustifyH("LEFT")
    self.messageFrame:SetMaxLines(1000)
    self.messageFrame:EnableMouseWheel(true)

    -- Adaptive scrolling with shift speed
    self.messageFrame:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed = self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then
            scrollSpeed = scrollSpeed * 3
        end
        self.messageFrame:ScrollByAmount(-delta * scrollSpeed)
    end)

    -- Hyperlink handling (URL + player links)
    self.messageFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, value = strsplit(":", link, 2)
        if linkType == "player" then
            -- Start a whisper
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

    -- Send message on Enter
    self.editBox:SetScript("OnEnterPressed", function(f)
        local text = f:GetText() and f:GetText():trim()
        if text and text ~= "" then
            self:SendSmartMessage(text)  -- new approach
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

    -- Initialize tab system (replaces old CreateTabs)
    self:InitializeTabSystem()

    -- Periodic cleanup for tabs and messages
    self:ScheduleRepeatingTimer(function()
        TabManager:CleanupOldTabs()
        self:ProcessMessageQueue()
    end, 5)

    -- Register slash commands
    self:RegisterSlashCommands()

    -- Final styling
    addon:PrintDebug("SleekChat initialized with smart features")
    self:ApplyTheme()
end

-- Updates font based on user settings
function ChatFrame:UpdateFonts()
    local fontPath  = SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local fontSize  = tonumber(self.db.profile.fontSize) or 12
    if fontSize < 8 then fontSize = 8 end
    if fontSize > 24 then fontSize = 24 end

    self.messageFrame:SetFont(fontPath, fontSize, "")
    self.messageFrame:SetShadowColor(0, 0, 0, 1)
    self.messageFrame:SetShadowOffset(1, -1)
end

---------------------------------------------------------------------
-- Smart message sending/processing
---------------------------------------------------------------------
function ChatFrame:SendSmartMessage(text)
    local processed = MessageProcessor:ParseMessage(text, PLAYER_NAME, self.activeChannel)

    -- Simple slash-detection for channels
    local targetChannel = self.activeChannel
    if text:sub(1, 1) == "/" then
        local command = strsplit(" ", text:sub(2)):lower()
        if command == "p" or command == "party" then
            targetChannel = "PARTY"
        elseif command == "raid" then
            targetChannel = "RAID"
        end
    end

    -- High-priority messages get a sound or tab flash
    if processed.priority >= 3 then
        self:FlashTab(self.activeChannel)
        if self.db.profile.mentionSounds then
            -- SOUNDKIT.IG_PLAYER_INVITE is a common "ping" sound
            PlaySound(SOUNDKIT.IG_PLAYER_INVITE)
        end
    end

    self:AddMessage(processed.original, targetChannel, PLAYER_NAME)
end

-- Add a message to queue; high priority goes to front
function ChatFrame:AddMessage(text, eventType, sender)
    local processed = MessageProcessor:ParseMessage(text, sender, eventType)
    local formatted = self:FormatMessage(processed.original, sender, eventType)

    if processed.priority > 2 then
        table.insert(self.messageQueue, 1, { formatted, eventType })
    else
        table.insert(self.messageQueue, { formatted, eventType })
    end

    -- Throttle if queue is large
    if #self.messageQueue > 50 then
        self:ProcessMessageQueue()
    end
end

-- Process queued messages, display those matching activeChannel
function ChatFrame:ProcessMessageQueue()
    for i, msgData in ipairs(self.messageQueue) do
        local text  = msgData[1]
        local chan  = msgData[2]
        if chan == self.activeChannel then
            self.messageFrame:AddMessage(text)
        end
        self.messageQueue[i] = nil
    end
    self.messageFrame:ScrollToBottom()
end

-- Basic mention of a tab flash
function ChatFrame:FlashTab(channel)
    -- Stub: highlight the channel tab visually or do something fancy
end

-- Format message (timestamp, channel tags, class-colored sender)
function ChatFrame:FormatMessage(text, sender, channel)
    local parts = {}

    -- Timestamps
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

    -- Channel with optional icon
    local channelIcon = ""
    if self.db.profile.channelIcons and addon.ChannelIcons then
        channelIcon = addon.ChannelIcons[channel] or ""
    end

    table.insert(parts, format("[%s%s]", channelIcon, channel))
    if sender then
        table.insert(parts, format("%s:", sender))
    end
    table.insert(parts, text)

    return table.concat(parts, " ")
end

---------------------------------------------------------------------
-- Tab system: replaces old CreateTabs/UpdateTabs
---------------------------------------------------------------------
function ChatFrame:InitializeTabSystem()
    -- A simple pool for reusing tab buttons
    self.tabPool = CreateFramePool("Button", self.chatFrame, function(pool, tab)
        tab:ClearAllPoints()
        tab:Hide()
    end)

    -- A scroll frame for tabs if there are too many
    self.tabScrollFrame = CreateFrame("ScrollFrame", nil, self.chatFrame, "UIPanelScrollFrameTemplate")
    self.tabScrollFrame:SetPoint("TOPLEFT", self.chatFrame, "TOPLEFT", 5, -5)
    self.tabScrollFrame:SetSize(self.db.profile.width - 10, 30)

    self:RegisterMessage("SLEEKCHAT_SETTINGS_CHANGED", "UpdateTabSystem")

    self:UpdateTabSystem()
end

function ChatFrame:UpdateTabSystem()
    self.tabPool:ReleaseAll()

    -- Create a tab for each channel in the user’s config
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

    -- Blizz template doesn't have :SetText(), so create a fontstring or use mixture:
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

    -- Simple tooltips
    tab:SetScript("OnEnter", function()
        GameTooltip:SetOwner(tab, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(channel)
        if channel:find("WHISPER:") and TabManager.whisperTabs[channel:gsub("WHISPER:", "")] then
            local info = TabManager.whisperTabs[channel:gsub("WHISPER:", "")]
            if info.lastActivity then
                GameTooltip:AddLine(L["last_activity"]..date("%X", info.lastActivity))
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
    -- If tabs exceed width, horizontally scroll
    local neededWidth = xOffset - self.tabScrollFrame:GetWidth()
    if neededWidth < 0 then
        neededWidth = 0
    end
    self.tabScrollFrame:SetHorizontalScroll(neededWidth)
end

-- Right-click channel toggles or advanced logic
function ChatFrame:ToggleChannel(channel)
    -- Stub if you want to detach/close channels, etc.
end

---------------------------------------------------------------------
-- Switching channels: partially from old code (needed for new tabs)
---------------------------------------------------------------------
function ChatFrame:SwitchChannel(channel)
    self.activeChannel = channel
    self.messageFrame:Clear()

    -- Reload channel history if present
    if addon.History and addon.History.messages and addon.History.messages[channel] then
        for _, msg in ipairs(addon.History.messages[channel]) do
            self:AddMessage(msg.text, msg.channel, msg.sender)
        end
    end

    -- Update tab visuals (highlight active, etc.)
    TabManager:UpdateTabVisuals()

    self.messageFrame:ScrollToBottom()

    -- If there's advanced messaging logic
    if addon.AdvancedMessaging and addon.AdvancedMessaging.SwitchChannel then
        addon.AdvancedMessaging:SwitchChannel(channel)
    end
end

---------------------------------------------------------------------
-- Pinning messages (from old code)
---------------------------------------------------------------------
function ChatFrame:PinMessage(message)
    if not self.db.profile.enablePinning then return end
    table.insert(self.pinnedMessages, message)
    self:UpdateAll()
end

function ChatFrame:UpdateAll()
    -- Rebuild chat from pinned + history
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
        }
    }

    for cmd, info in pairs(addon.SlashCommands) do
        _G["SLASH_SLEEKCHAT"..cmd:upper().."1"] = "/sleekchat "..cmd
        SlashCmdList["SLEEKCHAT"..cmd:upper()] = info.handler
    end
end

-- Example search functionality
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
        -- Command completion
        for cmd, info in pairs(addon.SlashCommands) do
            local cmdCheck = "/"..cmd
            if cmdCheck:find(input, 1, true) then
                tinsert(self.editBox.autoComplete, info.usage)
            end
        end
    else
        -- Player name completion
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
-- Helper stubs for hyperlink clicks
---------------------------------------------------------------------
function ChatFrame:StartConversation(target)
    -- If you want a quick way to jump to whisper mode
    self.activeChannel = "WHISPER:"..target
    self.messageFrame:AddMessage(format("|cffffff00Starting whisper to %s...|r", target))
end

function ChatFrame:HandleURL(url)
    -- Example: show a popup or copy box
    StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"] = {
        text         = L["url_dialog"] or "Copy URL:",
        button1      = OKAY,
        OnShow       = function(self) self.editBox:SetText(url) self.editBox:HighlightText() end,
        hasEditBox   = true,
        timeout      = 0,
        whileDead    = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG")
end

---------------------------------------------------------------------
-- Theming
---------------------------------------------------------------------
function ChatFrame:ApplyTheme()
    local theme = self.db.profile.theme or {
        background = {r = 0, g = 0, b = 0, a = 0.6},
        border     = {r = 1, g = 1, b = 1, a = 1},
        shadowAlpha= 1,
    }

    self.chatFrame:SetBackdropColor(
            theme.background.r,
            theme.background.g,
            theme.background.b,
            theme.background.a
    )

    self.chatFrame:SetBackdropBorderColor(
            theme.border.r,
            theme.border.g,
            theme.border.b,
            theme.border.a
    )

    self.messageFrame:SetShadowColor(0, 0, 0, theme.shadowAlpha or 1)
end

---------------------------------------------------------------------
-- Return the ChatFrame module
---------------------------------------------------------------------
return ChatFrame
