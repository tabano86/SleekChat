-- Modules/ChatTabs.lua
local _, addon = ...
addon.ChatTabs = {}
local ChatTabs = addon.ChatTabs

function ChatTabs:Initialize(addonObj)
    self.db = addonObj.db
    self.unreadCounts = self.db.profile.unreadCounts or {}
    self.tabs = addonObj.db.profile.tabs or {}
    self.activeTabIndex = 1

    local f = CreateFrame("Frame", "SleekChatTabs_Main", UIParent, "BackdropTemplate")
    self.mainFrame = f
    f:SetSize(self.db.profile.width, self.db.profile.height)
    f:SetPoint(
            self.db.profile.position.point,
            UIParent,
            self.db.profile.position.relPoint,
            self.db.profile.position.x,
            self.db.profile.position.y
    )
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left=4, right=4, top=4, bottom=4 },
    })
    f:SetBackdropColor(0, 0, 0, self.db.profile.backgroundOpacity or 0.8)
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
    if f.SetResizeBounds then
        f:SetResizeBounds(400, 250)
    end

    self.tabButtons = {}
    self:CreateTabsUI()
    self:SelectTab(1)
end

function ChatTabs:CreateTabsUI()
    local f = self.mainFrame
    for i, tabData in ipairs(self.tabs) do
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(100, 24)
        b:SetText(tabData.name)
        b:SetScript("OnClick", function() self:SelectTab(i) end)
        self.tabButtons[i] = b
    end
    self:UpdateTabLayout()
end

function ChatTabs:UpdateTabLayout()
    local orientation = self.db.profile.tabOrientation
    for i, btn in ipairs(self.tabButtons) do
        btn:ClearAllPoints()
        if orientation == "Vertical" then
            if i == 1 then
                btn:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 8, -8)
            else
                btn:SetPoint("TOP", self.tabButtons[i-1], "BOTTOM", 0, -4)
            end
        else
            if i == 1 then
                btn:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 8, -8)
            else
                btn:SetPoint("LEFT", self.tabButtons[i-1], "RIGHT", 4, 0)
            end
        end
    end
end

function ChatTabs:SelectTab(index)
    self.activeTabIndex = index
    if not self.mainFrame:GetParent() or not self.mainFrame:GetParent().messageFrame then
        return
    end
    local msgFrame = self.mainFrame:GetParent().messageFrame
    if not msgFrame then
        return
    end
    msgFrame:Clear()

    local tabData = self.tabs[index]
    -- Rebuild messages for the selected tab
    if addon.History and addon.History.db then
        local stor = addon.History.db.profile.messageHistory or {}
        for chName, arr in pairs(stor) do
            for i = #arr, 1, -1 do
                local msgData = arr[i]
                if self:ShouldDisplay(index, msgData.channel) then
                    self:AddMessageToFrame(msgData.text, msgData.channel, msgData.sender)
                end
            end
        end
    end

    self.unreadCounts[index] = 0
    self:UpdateTabAppearance(index)
end

function ChatTabs:AddMessageToFrame(text, channel, sender)
    local msgFrame = self.mainFrame:GetParent().messageFrame
    if not msgFrame then
        return
    end

    local final = ""
    if self.db.profile.timestamps then
        final = final .. string.format("|cff808080[%s]|r ", date(self.db.profile.timestampFormat))
    end
    if sender and sender ~= "" then
        final = final .. string.format("|cffFFFFFF%s|r: ", sender)
    end
    if channel and channel ~= "" and channel ~= "ALL" then
        final = final .. string.format("|cff00ffff[%s]|r ", channel)
    end
    final = final .. text
    msgFrame:AddMessage(final)
end

function ChatTabs:AddIncoming(text, sender, channel)
    -- If the current tab wants this channel, display immediately
    local idx = self.activeTabIndex
    if self:ShouldDisplay(idx, channel) then
        self:AddMessageToFrame(text, channel, sender)
    else
        -- Mark unread
        self.unreadCounts[idx] = (self.unreadCounts[idx] or 0) + 1
        self:UpdateTabAppearance(idx)
    end
end

function ChatTabs:UpdateTabAppearance(index)
    local btn = self.tabButtons[index]
    local count = self.unreadCounts[index] or 0
    btn:SetText(string.format("%s (%d)", self.tabs[index].name, count))
end

function ChatTabs:ShouldDisplay(tabIndex, channel)
    local tabData = self.tabs[tabIndex]
    if not tabData then
        return false
    end
    local fs = tabData.filters
    if not fs or next(fs) == nil then
        return true
    end
    return fs[channel] or false
end

-- Tab management stubs
function ChatTabs:AddTab(tabName, filters)
    table.insert(self.tabs, { name = tabName, filters = filters or {} })
    self:RefreshTabsUI()
end

function ChatTabs:RemoveTab(index)
    table.remove(self.tabs, index)
    self:RefreshTabsUI()
end

function ChatTabs:RenameTab(index, newName)
    if self.tabs[index] then
        self.tabs[index].name = newName
        self:RefreshTabsUI()
    end
end

function ChatTabs:RefreshTabsUI()
    for _, b in ipairs(self.tabButtons) do
        b:Hide()
    end
    self.tabButtons = {}
    self:CreateTabsUI()
end

return ChatTabs
