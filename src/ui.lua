-- ui.lua
-- UI module. Contains functions for creating and updating the main UI.
local UI = {}

-- Pure helper: calculates the frame position from a sequential array.
local function calculateFramePosition(profile)
    return unpack(profile.position)
end

function UI.Initialize(instance)
    -- Create the main frame.
    instance.UIFrame = CreateFrame("Frame", "SleekChatFrame", UIParent, "BackdropTemplate")
    instance.UIFrame:SetSize(instance.db.profile.width, instance.db.profile.height)
    instance.UIFrame:SetPoint(calculateFramePosition(instance.db.profile))
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
        instance.db.profile.position = { point = point, x = x, y = y }
    end)

    -- Create Tabs.
    UI.CreateTabs(instance)

    -- Create Scroll Frame.
    instance.scrollFrame = CreateFrame("ScrollFrame", "SleekChatScroll", instance.UIFrame, "UIPanelScrollFrameTemplate")
    instance.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    instance.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
    instance.content = CreateFrame("Frame", nil, instance.scrollFrame)
    instance.content:SetSize(100, 100)
    instance.scrollFrame:SetScrollChild(instance.content)

    -- Create Input Box.
    instance.inputBox = CreateFrame("EditBox", "SleekChatInput", instance.UIFrame, "InputBoxTemplate")
    instance.inputBox:SetSize(instance.UIFrame:GetWidth() - 20, 20)
    instance.inputBox:SetPoint("BOTTOM", 0, 10)
    instance.inputBox:SetAutoFocus(false)
    instance.inputBox:SetScript("OnEnterPressed", function(box)
        local text = box:GetText()
        if text and text ~= "" then
            UI.SendMessage(instance, text)
            box:SetText("")
        end
    end)

    UI.UpdateBackground(instance)
end

function UI.CreateTabs(instance)
    instance.tabs = {}
    local lastTab = nil
    for i, tabName in ipairs(instance.db.profile.tabs) do
        local tab = CreateFrame("Button", "SleekChatTab" .. tabName, instance.UIFrame, "CharacterFrameTabButtonTemplate")
        tab:SetText(tabName)
        if lastTab then
            tab:SetPoint("BOTTOMLEFT", lastTab, "BOTTOMRIGHT", 0, 30)
        else
            tab:SetPoint("BOTTOMLEFT", instance.UIFrame, "BOTTOMLEFT", 0, 30)
        end
        tab:SetScript("OnClick", function()
            UI.SwitchTab(instance, tabName)
        end)
        instance.tabs[tabName] = tab
        lastTab = tab
    end
    UI.SwitchTab(instance, instance.db.profile.tabs[1])
end

function UI.SwitchTab(instance, tabName)
    instance.currentTab = tabName
    for name, tab in pairs(instance.tabs) do
        if name == tabName then
            PanelTemplates_SelectTab(tab)
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
end

function UI.UpdateBackground(instance)
    local c = instance.db.profile.bgColor
    if instance.UIFrame then
        instance.UIFrame:SetBackdropColor(c.r, c.g, c.b, c.a)
    end
end

function UI.AddMessage(instance, msg)
    instance.UIFrame.messages = instance.UIFrame.messages or {}
    local offset = (#instance.UIFrame.messages) * 20
    local frame = CreateFrame("Frame", nil, instance.content)
    frame:SetSize(instance.content:GetWidth(), 20)
    frame:SetPoint("TOPLEFT", 0, -offset)
    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont(instance.db.profile.font, instance.db.profile.fontSize)
    text:SetPoint("LEFT")
    text:SetJustifyH("LEFT")
    if instance.db.profile.classColors and msg.class and RAID_CLASS_COLORS[msg.class] then
        local color = RAID_CLASS_COLORS[msg.class]
        text:SetTextColor(color.r, color.g, color.b)
    end
    if instance.db.profile.urlDetection then
        msg.text = msg.text:gsub("([wW][wW][wW]%.[%w_-]+%.%S+)", "|cff00ffff|Hurl:%1|h[%1]|h|r")
    end
    text:SetText(string.format("%s %s: %s", msg.time, msg.sender, msg.text))
    table.insert(instance.UIFrame.messages, frame)
    instance.scrollFrame:SetVerticalScroll(#instance.UIFrame.messages * 20)
end

function UI.SendMessage(instance, text)
    if instance.currentTab == "WHISPER" then
        SendChatMessage(text, "WHISPER", nil, UnitName("target"))
    else
        SendChatMessage(text, instance.currentTab)
    end
end

SleekChat = SleekChat or {}
SleekChat.UI = UI
