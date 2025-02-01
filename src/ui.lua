-- ui.lua
SleekChatUI = {}
local UI = SleekChatUI
local TAB_PADDING = 12  -- Extra pixels for tab width

function UI:InitializeUI()
    -- Main chat frame.
    UI.frame = CreateFrame("Frame", "SleekChat_MainFrame", UIParent, "BackdropTemplate")
    UI.frame:SetSize(600, 350)
    UI.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 50, 50)
    UI.frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    UI.frame:SetBackdropColor(
            SleekChat.db.profile.backgroundColor.r,
            SleekChat.db.profile.backgroundColor.g,
            SleekChat.db.profile.backgroundColor.b,
            SleekChat.db.profile.backgroundColor.a
    )
    UI.frame:EnableMouse(true)
    if SleekChat.db.profile.draggableWindow then
        UI.frame:SetMovable(true)
        UI.frame:RegisterForDrag("LeftButton")
        UI.frame:SetScript("OnDragStart", UI.frame.StartMoving)
        UI.frame:SetScript("OnDragStop", UI.frame.StopMovingOrSizing)
    end
    UI.frame:Show()

    -- Create dynamic tabs.
    UI:CreateTabs()

    -- Create scroll frame for messages.
    UI.scrollFrame = CreateFrame("ScrollFrame", "SleekChat_ScrollFrame", UI.frame, "UIPanelScrollFrameTemplate")
    UI.scrollFrame:SetPoint("TOPLEFT", UI.frame, "TOPLEFT", 10, -50)
    UI.scrollFrame:SetPoint("BOTTOMRIGHT", UI.frame, "BOTTOMRIGHT", -30, 40)
    UI.scrollFrame:EnableMouse(true)
    UI.scrollFrame:SetClipsChildren(true)

    -- Create content frame (the scroll child).
    UI.content = CreateFrame("Frame", "SleekChat_Content", UI.scrollFrame)
    UI.content:SetSize(560, 240)
    UI.scrollFrame:SetScrollChild(UI.content)

    UI.messages = {}
    UI.messageCount = 0

    -- Create input box.
    UI.inputBox = CreateFrame("EditBox", "SleekChat_InputBox", UI.frame, "InputBoxTemplate")
    UI.inputBox:SetSize(560, 24)
    UI.inputBox:SetPoint("BOTTOMLEFT", UI.frame, "BOTTOMLEFT", 10, 10)
    UI.inputBox:SetAutoFocus(false)
    UI.inputBox:SetScript("OnEnterPressed", function(self)
        UI:ProcessInput(self:GetText())
        self:SetText("")
        self:ClearFocus()
    end)
    UI.inputHistory = {}
    UI.historyIndex = 0
    UI.inputBox:SetScript("OnKeyDown", function(self, key)
        if key == "UP" then
            UI:ShowPreviousHistory()
        elseif key == "DOWN" then
            UI:ShowNextHistory()
        end
    end)

    UI:InitializeHyperlinkHandling()
    SleekChatUtil:Log("UI initialized.", "DEBUG")
end

function UI:CreateTabs()
    UI.tabs = {}
    local tabNames = SleekChat.db.profile.chatTabs.tabOrder or { "SAY", "YELL", "GUILD", "PARTY", "RAID", "WHISPER", "CHANNEL" }
    local xOffset = 10
    for _, name in ipairs(tabNames) do
        -- Create the tab with a unique global name.
        local tab = CreateFrame("Button", "SleekChat_Tab_" .. name, UI.frame, "OptionsFrameTabButtonTemplate")
        tab:SetText(name)
        -- Adjust width based on text.
        local fs = tab:GetFontString()
        local textWidth = fs and fs:GetStringWidth() or 50
        tab:SetWidth(textWidth + TAB_PADDING)
        tab:SetPoint("TOPLEFT", UI.frame, "TOPLEFT", xOffset, -10)
        tab:SetScript("OnClick", function() UI:SelectTab(name) end)
        UI.tabs[name] = tab
        xOffset = xOffset + tab:GetWidth() - 5  -- slight overlap for aesthetics
    end
    UI.selectedTab = tabNames[1]
    UI:HighlightTab(UI.selectedTab)
end

function UI:SelectTab(tabName)
    UI:HighlightTab(tabName)
end

function UI:HighlightTab(tabName)
    for name, tab in pairs(UI.tabs) do
        if name == tabName then
            PanelTemplates_SelectTab(tab)
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
    UI.selectedTab = tabName
    UI:RefreshMessages()
end

function UI:UpdateFontSettings()
    for _, msg in ipairs(UI.messages) do
        msg.text:SetFont(SleekChat.db.profile.font, SleekChat.db.profile.fontSize)
    end
end

function UI:UpdateBackgroundColor()
    local c = SleekChat.db.profile.backgroundColor
    UI.frame:SetBackdropColor(c.r, c.g, c.b, c.a)
end

function UI:UpdateDraggable()
    if SleekChat.db.profile.draggableWindow then
        UI.frame:SetMovable(true)
        UI.frame:RegisterForDrag("LeftButton")
    else
        UI.frame:SetMovable(false)
        UI.frame:EnableMouse(false)
    end
end

function UI:ProcessInput(text)
    if text and text ~= "" then
        table.insert(UI.inputHistory, text)
        UI.historyIndex = #UI.inputHistory + 1
        if text:sub(1, 1) == "/" then
            ChatEdit_SendText(UI.inputBox, 0)
        else
            UI:AddMessage("You", text, UI.selectedTab)
            if UI.selectedTab == "SAY" then
                SendChatMessage(text, "SAY")
            elseif UI.selectedTab == "YELL" then
                SendChatMessage(text, "YELL")
            elseif UI.selectedTab == "GUILD" then
                SendChatMessage(text, "GUILD")
            elseif UI.selectedTab == "PARTY" then
                SendChatMessage(text, "PARTY")
            elseif UI.selectedTab == "RAID" then
                SendChatMessage(text, "RAID")
            elseif UI.selectedTab == "WHISPER" then
                SendChatMessage(text, "WHISPER", nil, "target")
            else
                SendChatMessage(text, "CHANNEL")
            end
        end
    end
end

function UI:ShowPreviousHistory()
    if #UI.inputHistory > 0 then
        UI.historyIndex = math.max(1, UI.historyIndex - 1)
        UI.inputBox:SetText(UI.inputHistory[UI.historyIndex])
    end
end

function UI:ShowNextHistory()
    if #UI.inputHistory > 0 then
        UI.historyIndex = math.min(#UI.inputHistory, UI.historyIndex + 1)
        UI.inputBox:SetText(UI.inputHistory[UI.historyIndex])
    end
end

function UI:AddMessage(sender, text, channel)
    UI.messageCount = UI.messageCount + 1
    local yOffset = (UI.messageCount - 1) * 20
    local msgFrame = CreateFrame("Frame", nil, UI.content)
    msgFrame:SetSize(560, 20)
    msgFrame:SetPoint("TOPLEFT", UI.content, "TOPLEFT", 0, -yOffset)
    local msgText = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    msgText:SetAllPoints()
    msgText:SetJustifyH("LEFT")
    msgText:SetFont(SleekChat.db.profile.font, SleekChat.db.profile.fontSize)

    local timestamp = ""
    if SleekChat.db.profile.showTimestamps then
        timestamp = date("[%H:%M:%S] ")
    end
    local formattedText = string.format("%s[%s] %s: %s", timestamp, channel, sender, text)
    msgText:SetText(formattedText)

    -- If the fontstring supports hyperlink enabling, call it.
    if msgText.SetHyperlinksEnabled then
        msgText:SetHyperlinksEnabled(true)
    end

    -- Right-click for additional actions.
    msgText:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            SleekChat:Print("Right-click on message: " .. formattedText)
        end
    end)

    table.insert(UI.messages, { frame = msgFrame, text = msgText, channel = channel })
    UI:RefreshMessages()
    SleekChatHistory:AddToHistory({ sender = sender, text = text, channel = channel })
    SleekChatNotifications:ShowNotification("New message from " .. sender)
end

function UI:RefreshMessages()
    if not UI.content then
        SleekChatUtil:Log("UI.content is nil in RefreshMessages", "ERROR")
        return
    end
    UI.content:Hide()
    UI.content:Show()
    local y = 0
    for _, msg in ipairs(UI.messages) do
        if msg.channel == UI.selectedTab then
            msg.frame:ClearAllPoints()
            msg.frame:SetPoint("TOPLEFT", UI.content, "TOPLEFT", 0, -y)
            msg.frame:Show()
            y = y + 20
        else
            msg.frame:Hide()
        end
    end
end

function UI:InitializeHyperlinkHandling()
    hooksecurefunc("SetItemRef", function(link, text, button)
        if link:sub(1, 6) == "Sleek:" then
            UI:HandleCustomLink(link, text, button)
        end
    end)
end

function UI:HandleHyperlink(link, text, button)
    if link:find("item:") then
        GameTooltip:SetOwner(UI.frame, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    elseif link:find("player:") then
        local playerName = link:match("player:(.+)")
        if playerName then
            NotifyInspect(playerName)
        end
    else
        SetItemRef(link, text, button)
    end
end

function UI:HandleCustomLink(link, text, button)
    SleekChat:Print("Custom link clicked: " .. link)
end
