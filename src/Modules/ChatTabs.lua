-- Modules/ChatTabs.lua
local _, addon = ...
addon.ChatTabs = {}
local ChatTabs = addon.ChatTabs
local SM = LibStub("LibSharedMedia-3.0")

function ChatTabs:Initialize(addonObj)
    self.db = addonObj.db
    self.unreadCounts = self.db.profile.unreadCounts or {}
    self.tabs = addonObj.db.profile.tabs or {}
    self.activeTabIndex = 1

    local f = CreateFrame("Frame", "SleekChatTabs_Main", UIParent, "BackdropTemplate")
    self.mainFrame = f
    f:SetSize(self.db.profile.width, self.db.profile.height)
    f:SetPoint(self.db.profile.position.point, UIParent, self.db.profile.position.relPoint, self.db.profile.position.x, self.db.profile.position.y)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
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
    if f.SetResizeBounds then f:SetResizeBounds(400, 250) end

    self.tabButtons = {}
    self:CreateTabsUI()
    self:SelectTab(1)
end

-- Dynamic Tab Management (add, remove, rename)
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

function ChatTabs:RefreshTabsUI()
    for _, b in ipairs(self.tabButtons) do b:Hide() end
    self.tabButtons = {}
    self:CreateTabsUI()
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
    self.mainFrame:GetParent().messageFrame:Clear()
    local tabData = self.tabs[index]
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
    self.mainFrame:GetParent().messageFrame:AddMessage(final)
end

function ChatTabs:AddIncoming(text, sender, channel)
    if addon.History then addon.History:AddMessage(text, sender, channel) end
    local idx = self.activeTabIndex
    if self:ShouldDisplay(idx, channel) then
        self:AddMessageToFrame(text, channel, sender)
    end
    if self.activeTabIndex ~= idx then
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
    if not tabData then return false end
    local fs = tabData.filters
    if not fs or next(fs) == nil then return true end
    return fs[channel] or false
end

function ChatTabs:OpenFilterPanel(tabIndex)
    local f = CreateFrame("Frame", "SleekChatFilterPanel", UIParent, "BackdropTemplate")
    f:SetSize(200, 300)
    f:SetPoint("CENTER")
    f:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    local cats = { "SAY", "YELL", "PARTY", "RAID", "RAIDWARNING", "GUILD", "OFFICER", "WHISPER", "BNWHISPER", "EMOTE", "SYSTEM", "COMBAT", "BOSS", "BATTLEGROUND", "INSTANCE", "CHANNEL", "COMMUNITY", "ALL" }
    local tabData = self.tabs[tabIndex]
    local fs = tabData.filters
    local yOffset = -30
    for _, cat in ipairs(cats) do
        local chk = CreateFrame("CheckButton", nil, f, "ChatConfigCheckButtonTemplate")
        chk:SetPoint("TOPLEFT", f, "TOPLEFT", 10, yOffset)
        chk:SetSize(24, 24)
        local label = chk:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", chk, "RIGHT", 0, 1)
        label:SetText(cat)
        chk:SetChecked(fs[cat] or false)
        chk:SetScript("OnClick", function(btn)
            fs[cat] = btn:GetChecked()
        end)
        yOffset = yOffset - 26
    end
    local save = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    save:SetSize(60, 24)
    save:SetText("OK")
    save:SetPoint("BOTTOM", 0, 8)
    save:SetScript("OnClick", function()
        f:Hide()
        self:SelectTab(tabIndex)
    end)
end

function ChatTabs:SendMessage(text)
    local chatType = "SAY"
    if text:match("^/g ") then chatType = "GUILD" end
    SendChatMessage(text, chatType)
    self:AddIncoming(text, UnitName("player"), chatType)
end

return ChatTabs
