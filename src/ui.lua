-- ui.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.UI and _G.SleekChat.UI._loaded then return end
_G.SleekChat.UI = _G.SleekChat.UI or {}
local UI = _G.SleekChat.UI
local Logger = _G.SleekChat.Logger
local Modules = _G.SleekChat.Modules or error("Modules registry missing. Check Init.lua and .toc order!")
Logger:Debug("UI Loading...")

function UI.Initialize(instance)
    if not instance.db.profile.position then
        instance.db.profile.position = {"CENTER", UIParent, "CENTER", 0, 0}
    end
    instance.UIFrame = CreateFrame("Frame", "SleekChatFrame", UIParent, "BackdropTemplate")
    instance.UIFrame:SetSize(instance.db.profile.width, instance.db.profile.height)
    instance.UIFrame:SetPoint("CENTER")
    instance.UIFrame:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    instance.UIFrame:SetMovable(true)
    instance.UIFrame:EnableMouse(true)
    instance.UIFrame:RegisterForDrag("LeftButton")
    instance.UIFrame:SetScript("OnDragStart", instance.UIFrame.StartMoving)
    instance.UIFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, _, x, y = frame:GetPoint()
        instance.db.profile.position = { point, x, y }
    end)

    instance.Sidebar = CreateFrame("Frame", "SleekChatSidebar", instance.UIFrame, "InsetFrameTemplate")
    instance.Sidebar:SetSize(150, instance.UIFrame:GetHeight() - 20)
    instance.Sidebar:SetPoint("TOPLEFT", instance.UIFrame, "TOPLEFT", 10, -10)
    UI.CreateSidebar(instance)

    -- Set current tab to the first one in the list
    if #instance.db.profile.tabs > 0 then
        instance.currentTab = instance.db.profile.tabs[1]
        UI.SwitchTab(instance, instance.currentTab)
    else
        Logger:Error("No tabs configured in profile.tabs")
    end

    instance.ChatArea = CreateFrame("Frame", "SleekChatChatArea", instance.UIFrame, "BackdropTemplate")
    instance.ChatArea:SetPoint("TOPLEFT", instance.Sidebar, "TOPRIGHT", 10, 0)
    instance.ChatArea:SetPoint("BOTTOMRIGHT", instance.UIFrame, "BOTTOMRIGHT", -10, 10)
    instance.ChatArea:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    instance.PinnedArea = CreateFrame("Frame", "SleekChatPinnedArea", instance.ChatArea)
    instance.PinnedArea:SetSize(instance.ChatArea:GetWidth(), 60)
    instance.PinnedArea:SetPoint("TOPLEFT", instance.ChatArea, "TOPLEFT", 0, -10)

    instance.ScrollFrame = CreateFrame("ScrollFrame", "SleekChatScroll", instance.ChatArea, "UIPanelScrollFrameTemplate")
    instance.ScrollFrame:SetPoint("TOPLEFT", instance.PinnedArea, "BOTTOMLEFT", 0, -10)
    instance.ScrollFrame:SetPoint("BOTTOMRIGHT", instance.ChatArea, "BOTTOMRIGHT", -10, 40)

    instance.Content = CreateFrame("Frame", nil, instance.ScrollFrame)
    instance.Content:SetSize(instance.ScrollFrame:GetWidth(), instance.ScrollFrame:GetHeight())
    instance.ScrollFrame:SetScrollChild(instance.Content)

    instance.InputBox = CreateFrame("EditBox", "SleekChatInput", instance.ChatArea, "InputBoxTemplate")
    instance.InputBox:SetSize(instance.ChatArea:GetWidth() - 20, 30)
    instance.InputBox:SetPoint("BOTTOM", instance.ChatArea, "BOTTOM", 0, 10)
    instance.InputBox:SetAutoFocus(false)
    instance.InputBox:SetScript("OnEnterPressed", function(box)
        local text = box:GetText()
        if text and text ~= "" then
            UI.SendMessage(instance, text)
            box:SetText("")
        end
    end)

    UI.UpdateBackground(instance)
    UI.RefreshMessages(instance)
    UI.RefreshPinned(instance)
    Logger:Info("UI module initialized.")
end

function UI.CreateSidebar(instance)
    instance.Sidebar.buttons = {}
    local buttonHeight = 30
    local padding = 5
    for i, tabName in ipairs(instance.db.profile.tabs) do
        local btn = CreateFrame("Button", "SleekChatSidebarBtn" .. tabName, instance.Sidebar, "UIPanelButtonTemplate")
        btn:SetSize(130, buttonHeight)
        btn:SetPoint("TOP", instance.Sidebar, "TOP", 0, -((i - 1) * (buttonHeight + padding) - padding))
        btn:SetText(tabName)
        btn:SetScript("OnClick", function() UI.SwitchTab(instance, tabName) end)
        instance.Sidebar.buttons[tabName] = btn
    end
end

function UI.SwitchTab(instance, tabName)
    instance.currentTab = tabName
    for name, btn in pairs(instance.Sidebar.buttons) do
        if name == tabName then
            btn:LockHighlight()
        else
            btn:UnlockHighlight()
        end
    end
    UI.RefreshMessages(instance)
end

function UI.RefreshMessages(instance)
    -- Guard against missing instance or content.
    if not instance or not instance.Content then
        return
    end

    -- Ensure instance.Content.children is a valid table.
    instance.Content.children = instance.Content.children or {}

    -- Hide and detach existing children.
    for _, child in ipairs(instance.Content.children) do
        if child then
            if child.Hide then
                child:Hide()
            end
            if child.SetParent then
                child:SetParent(nil)
            end
        end
    end

    -- Reset the children table.
    instance.Content.children = {}

    -- Safely retrieve messages from your History module.
    local messages = {}
    local historyModule = _G.SleekChat and _G.SleekChat.Modules and _G.SleekChat.Modules:get("History")
    if historyModule and historyModule.GetMessages then
        messages = historyModule.GetMessages(instance, instance.currentTab) or {}
    end

    -- Populate with new message frames.
    local yOffset = 0
    if UI.CreateMessageFrame then
        for _, msg in ipairs(messages) do
            local frame = UI.CreateMessageFrame(instance, msg, yOffset)
            if frame then
                table.insert(instance.Content.children, frame)
                if frame.GetHeight then
                    yOffset = yOffset + frame:GetHeight() + 5
                end
            end
        end
    end

    -- Adjust the container height if possible.
    if instance.Content.SetHeight then
        instance.Content:SetHeight(yOffset)
    end
end


function UI.CreateMessageFrame(instance, msg, yOffset)
    local frame = CreateFrame("Frame", nil, instance.Content, "BackdropTemplate")
    frame:SetSize(instance.Content:GetWidth(), 30)
    frame:SetPoint("TOPLEFT", instance.Content, "TOPLEFT", 0, -yOffset)
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetFont(instance.db.profile.font, instance.db.profile.fontSize)
    text:SetPoint("LEFT", frame, "LEFT", 10, 0)
    text:SetJustifyH("LEFT")
    text:SetText(string.format("%s %s: %s", msg.time, msg.sender, msg.text))
    frame.text = text
    local pinBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    pinBtn:SetSize(50, 20)
    pinBtn:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    pinBtn:SetText(msg.pinned and "Unpin" or "Pin")
    pinBtn:SetScript("OnClick", function()
        msg.pinned = not msg.pinned
        pinBtn:SetText(msg.pinned and "Unpin" or "Pin")
        if msg.pinned then
            table.insert(instance.history.pinned, msg)
        else
            for i, m in ipairs(instance.history.pinned) do
                if m == msg then
                    table.remove(instance.history.pinned, i)
                    break
                end
            end
        end
        UI.RefreshPinned(instance)
    end)
    return frame
end

function UI.RefreshPinned(instance)
    if instance.PinnedArea.children then
        for _, child in ipairs(instance.PinnedArea.children) do
            child:Hide()
            child:SetParent(nil)
        end
    end
    instance.PinnedArea.children = {}
    local yOffset = 0
    for i, msg in ipairs(instance.history.pinned) do
        local frame = CreateFrame("Frame", nil, instance.PinnedArea, "BackdropTemplate")
        frame:SetSize(instance.PinnedArea:GetWidth(), 30)
        frame:SetPoint("TOPLEFT", instance.PinnedArea, "TOPLEFT", 0, -yOffset)
        local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetFont(instance.db.profile.font, instance.db.profile.fontSize)
        text:SetPoint("LEFT", frame, "LEFT", 10, 0)
        text:SetJustifyH("LEFT")
        text:SetText(string.format("%s %s: %s", msg.time, msg.sender, msg.text))
        frame.text = text
        table.insert(instance.PinnedArea.children, frame)
        yOffset = yOffset + frame:GetHeight() + 5
    end
    instance.PinnedArea:SetHeight(yOffset)
end

function UI.AddMessage(instance, msg)
    if msg.channel == instance.currentTab then
        UI.RefreshMessages(instance)
    end
end

function UI.SendMessage(instance, text)
    if instance.currentTab == "WHISPER" then
        SendChatMessage(text, "WHISPER", nil, UnitName("target"))
    else
        SendChatMessage(text, instance.currentTab)
    end
end

function UI.UpdateBackground(instance)
    local c = instance.db.profile.bgColor
    if instance.UIFrame then
        instance.UIFrame:SetBackdropColor(c.r, c.g, c.b, c.a)
    end
end

Logger:Debug("UI Loaded!")
UI._loaded = true
_G.SleekChat.addon = addon
Modules:register("UI", UI)
Logger:Debug("UI Loaded!")
