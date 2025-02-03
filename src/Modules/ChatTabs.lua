local _, addon= ...
addon.ChatTabs={}
local ChatTabs= addon.ChatTabs

local SM= LibStub("LibSharedMedia-3.0")
local floor= math.floor

function ChatTabs:Initialize(addonObj)
    self.db= addonObj.db

    -- Initialize unreadCounts first
    self.unreadCounts = self.db.profile.unreadCounts or {}

    -- We'll create a main frame with a row of tabs (like default chat).
    local f= CreateFrame("Frame","SleekChatTabs_Main",UIParent,"BackdropTemplate")
    self.mainFrame= f
    f:SetSize(self.db.profile.width or 600, self.db.profile.height or 400)
    f:SetPoint(self.db.profile.position.point, UIParent,
            self.db.profile.position.relPoint,
            floor(self.db.profile.position.x),
            floor(self.db.profile.position.y))

    f:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=16,
        insets={ left=4,right=4,top=4,bottom=4},
    })
    f:SetBackdropColor(0,0,0,self.db.profile.backgroundOpacity or 0.8)

    f:SetMovable(true)
    f:SetResizable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point,_,relPoint,xOfs,yOfs= f:GetPoint()
        self.db.profile.position= { point=point, relPoint=relPoint, x=xOfs, y=yOfs }
    end)
    if f.SetResizeBounds then
        f:SetResizeBounds(400,250)
    elseif f.SetMinResize then
        f:SetMinResize(400,250)
    end

    -- tab container
    self.tabButtons= {}
    self.tabs= {} -- store data for each tab
    self.activeTabIndex= 1

    -- The ScrollingMessageFrame
    local msg= CreateFrame("ScrollingMessageFrame",nil,f)
    self.msgFrame= msg
    msg:SetFading(false)
    msg:SetMaxLines(2000)
    msg:SetJustifyH("LEFT")
    msg:EnableMouseWheel(true)
    msg:SetScript("OnMouseWheel", function(_,delta)
        local scrollSpeed= self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then scrollSpeed= scrollSpeed*3 end
        if delta>0 then msg:ScrollUp(scrollSpeed)
        else msg:ScrollDown(scrollSpeed)
        end
    end)

    local edit= CreateFrame("EditBox",nil,f,"InputBoxTemplate")
    self.inputBox= edit
    edit:SetAutoFocus(false)
    edit:SetHeight(24)
    edit:SetScript("OnEnterPressed", function(box)
        local text= box:GetText() and box:GetText():trim()
        if text and text~="" then
            self:SendMessage(text)
        end
        box:SetText("")
        box:ClearFocus()
    end)

    self:LayoutFrames()
    self:CreateDefaultTabs()
    self:SelectTab(1)

    self.unreadCounts = self.db.profile.unreadCounts or {}
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

function ChatTabs:LayoutFrames()
    local f= self.mainFrame
    local pad=8

    self.msgFrame:ClearAllPoints()
    self.msgFrame:SetPoint("TOPLEFT", f,"TOPLEFT", pad, -45) -- below tabs
    self.msgFrame:SetPoint("TOPRIGHT",f,"TOPRIGHT",-pad, -45)
    self.msgFrame:SetPoint("BOTTOM", self.inputBox,"TOP",0,4)

    self.inputBox:ClearAllPoints()
    self.inputBox:SetPoint("BOTTOMLEFT", f,"BOTTOMLEFT", pad, pad)
    self.inputBox:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-pad, pad)
end

function ChatTabs:CreateDefaultTabs()
    -- We'll define a few tabs: "General," "Combat," "System," "All"
    self:CreateTab("General", {SAY=true, YELL=true, PARTY=true,RAID=true,GUILD=true,WHISPER=true,BNWHISPER=true,OFFICER=true,BATTLEGROUND=true,INSTANCE=true,CHANNEL=true,COMMUNITY=true})
    self:CreateTab("Combat", {COMBAT=true, RAIDWARNING=true, MONSTER=true, BOSS=true})
    self:CreateTab("System", {SYSTEM=true})
    self:CreateTab("All", {}) -- if filters empty => everything
end

function ChatTabs:CreateTab(tabName, filters)
    local index = #self.tabs + 1
    local tabData = {
        name = tabName,
        filters = filters or {},
        pinned = {}
    }
    self.tabs[index] = tabData

    -- Modern tab button with hover effects
    local b = CreateFrame("Button", nil, self.mainFrame, "UIPanelButtonTemplate")
    b:SetSize(100, 24)
    b:SetText(tabName)
    b:SetNormalFontObject("GameFontNormalSmall")
    b:SetHighlightFontObject("GameFontHighlightSmall")

    -- Tab styling
    local ntex = b:CreateTexture()
    ntex:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
    ntex:SetTexCoord(0, 0.25, 0, 1)
    ntex:SetAllPoints()
    b:SetNormalTexture(ntex)

    local htex = b:CreateTexture()
    htex:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
    htex:SetTexCoord(0.25, 0.5, 0, 1)
    htex:SetAllPoints()
    b:SetHighlightTexture(htex)

    -- Active tab indicator
    b:GetFontString():SetPoint("CENTER", 0, 2)
    b:SetScript("OnClick", function()
        self:SelectTab(index)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end)

    -- Unread counter
    b.unread = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.unread:SetPoint("RIGHT", -5, 0)
    b.unread:SetTextColor(1, 0.82, 0)

    -- Settings gear
    local gear = CreateFrame("Button", nil, b, "UIPanelButtonTemplate")
    gear:SetSize(20, 20)
    gear:SetPoint("RIGHT", b, "LEFT", -2, 0)
    gear:SetNormalTexture("Interface\\GossipFrame\\BinderGossipIcon")
    gear:SetScript("OnClick", function()
        self:OpenFilterPanel(index)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

    self.tabButtons[index] = b
    self:UpdateTabLayout()
end

function ChatTabs:SelectTab(index)
    self.activeTabIndex= index
    self.msgFrame:Clear()

    -- re-inject pinned
    local pinned= self.tabs[index].pinned
    for _, pinText in ipairs(pinned) do
        self.msgFrame:AddMessage("|cffFFD700[PINNED]|r ".. pinText)
    end

    -- re-inject from history
    local stor= self.db.profile.messageHistory
    if not stor then return end
    for channelName,arr in pairs(stor) do
        for i=#arr,1,-1 do
            local msgData= arr[i]
            if self:ShouldDisplay(index, msgData.channel) then
                self:AddMessageToFrame(msgData.text, msgData.channel, msgData.sender)
            end
        end
    end
    self.msgFrame:ScrollToBottom()
    self.unreadCounts[index] = 0
    self:UpdateTabAppearance(index)
end

-- This new function fixes the "AddMessageToFrame" nil error:
function ChatTabs:AddMessageToFrame(text, channel, sender)
    -- You can expand or adjust the formatting as needed:
    local line = self:FormatMessage(text, sender, channel)
    self.msgFrame:AddMessage(line)
end

function ChatTabs:AddIncoming(text, sender, channel)
    -- store in history
    if addon.History then
        addon.History:AddMessage(text, sender, channel)
    end
    -- if it belongs in the active tab (based on filters), display
    local idx= self.activeTabIndex
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
    local tabData= self.tabs[tabIndex]
    if not tabData then return false end

    local fs= tabData.filters
    if (not fs) or (next(fs)==nil) then
        -- no filters => everything
        return true
    end
    -- If the filter set has "channel==true," show. If not present, skip.
    return fs[channel] or false
end

function ChatTabs:FormatMessage(text, sender, channel)
    local final=""
    if self.db.profile.timestamps then
        final= final.. string.format("|cff808080[%s]|r ", date(self.db.profile.timestampFormat))
    end
    if sender and sender~="" then
        final= final.. string.format("|cffFFFFFF%s|r: ", sender)
    end
    if channel and channel~="" and channel~="ALL" then
        final= final.. string.format("|cff00ffff[%s]|r ",channel)
    end
    final= final.. text
    return final
end

function ChatTabs:OpenFilterPanel(tabIndex)
    -- A small panel to let user toggle categories for that tab
    local f= CreateFrame("Frame","SleekChatFilterPanel",UIParent,"BackdropTemplate")
    f:SetSize(200,300)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=16,
    })
    f:SetBackdropColor(0,0,0,0.85)

    local close= CreateFrame("Button",nil,f,"UIPanelCloseButton")
    close:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)

    local cats= { "SAY","YELL","PARTY","RAID","RAIDWARNING","GUILD","OFFICER","WHISPER","BNWHISPER","EMOTE","SYSTEM","COMBAT","BOSS","BATTLEGROUND","INSTANCE","CHANNEL","COMMUNITY","ALL" }
    local tabData= self.tabs[tabIndex]
    local fs= tabData.filters

    local yOffset= -30
    for _, cat in ipairs(cats) do
        local chk= CreateFrame("CheckButton",nil,f,"ChatConfigCheckButtonTemplate")
        chk:SetPoint("TOPLEFT",f,"TOPLEFT",10,yOffset)
        chk:SetSize(24,24)
        local label= chk:CreateFontString(nil,"OVERLAY","GameFontNormal")
        label:SetPoint("LEFT", chk,"RIGHT",0,1)
        label:SetText(cat)

        local current= fs[cat] or false
        chk:SetChecked(current)
        chk:SetScript("OnClick", function(btn)
            local c= btn:GetChecked()
            fs[cat]= c
        end)
        yOffset= yOffset-26
    end

    local save=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
    save:SetSize(60,24)
    save:SetText("OK")
    save:SetPoint("BOTTOM",0,8)
    save:SetScript("OnClick", function()
        f:Hide()
        self:SelectTab(tabIndex)
    end)
end

function ChatTabs:SendMessage(text)
    -- We can do slash detection or just send everything as SAY:
    local chatType= "SAY"
    if text:match("^/g ") then chatType="GUILD" end
    -- etc.

    -- Actually send
    SendChatMessage(text, chatType)
    -- Also show locally
    self:AddIncoming(text,UnitName("player"), chatType)
end
