local _, addon= ...
local AceLocale= LibStub("AceLocale-3.0")
local SM= LibStub("LibSharedMedia-3.0")

local L= AceLocale:GetLocale("SleekChat", true)
local ChatFrame= {}
addon.ChatFrame= ChatFrame

local floor, format, gsub, strlower, strsplit= floor, format, gsub, strlower, strsplit
local tinsert= table.insert

local PLAYER_NAME= UnitName("player") or "Player"
local RAID_CLASS_COLORS= RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS or {}
local DEFAULT_FONT= "Fonts\\FRIZQT__.TTF"

--------------------------------------------------------------------------------
-- Initialize: left sidebar, main feed, pinned, etc.
--------------------------------------------------------------------------------
function ChatFrame:Initialize(addonObj)
    self.addonObj= addonObj
    self.db= addonObj.db
    self.pinnedMessages= {}
    -- We'll show "ALL" by default
    self.activeChannel= "ALL"

    -- Main frame
    local f= CreateFrame("Frame","SleekChat_MainFrame", UIParent,"BackdropTemplate")
    self.mainFrame= f
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
        local point,_,relPoint,xOfs,yOfs= f:GetPoint()
        self.db.profile.position= { point=point,relPoint=relPoint,x=xOfs,y=yOfs }
    end)
    if f.SetResizeBounds then
        f:SetResizeBounds(400,250)
    elseif f.SetMinResize then
        f:SetMinResize(400,250)
    end

    -- Resize handle
    local resize= CreateFrame("Button",nil,f)
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
        self.db.profile.width= floor(f:GetWidth())
        self.db.profile.height= floor(f:GetHeight())
        self:LayoutFrames()
    end)

    f:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=16,
        insets={ left=4, right=4, top=4, bottom=4 },
    })
    f:SetBackdropColor(0,0,0,self.db.profile.backgroundOpacity or 0.8)

    -- Left sidebar for channels
    self.sidebar= CreateFrame("Frame",nil,f,"BackdropTemplate")
    self.sidebar:SetPoint("TOPLEFT", f, "TOPLEFT",4,-4)
    self.sidebar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",4,4)
    self.sidebar:SetWidth(120)
    self.sidebar:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=12,
    })
    self.sidebar:SetBackdropColor(0,0,0,0.9)

    -- A scroll frame in the sidebar so we can list many channels
    local sf= CreateFrame("ScrollFrame",nil,self.sidebar,"UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", self.sidebar, "TOPLEFT",0,-4)
    sf:SetPoint("BOTTOMRIGHT", self.sidebar,"BOTTOMRIGHT",-25,4)
    self.sidebarScroll= sf

    local sbContent= CreateFrame("Frame",nil,sf)
    sf:SetScrollChild(sbContent)
    sbContent:SetSize(100,400)
    self.sidebarContent= sbContent
    self.channelButtons= {}

    -- The main message frame
    local msg= CreateFrame("ScrollingMessageFrame",nil,f)
    self.messageFrame= msg
    msg:SetFading(false)
    msg:SetMaxLines(2000)
    msg:SetHyperlinksEnabled(true)
    msg:SetJustifyH("LEFT")  -- #1 fix: left-aligned
    msg:EnableMouseWheel(true)
    msg:SetScript("OnMouseWheel", function(_, delta)
        local scrollSpeed= self.db.profile.scrollSpeed or 3
        if IsShiftKeyDown() then
            scrollSpeed= scrollSpeed*3
        end
        if delta>0 then
            msg:ScrollUp(scrollSpeed)
        else
            msg:ScrollDown(scrollSpeed)
        end
    end)
    msg:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local linkType, val= strsplit(":", link, 2)
        if linkType=="url" then
            self:HandleURL(val)
        end
    end)

    -- Input box at bottom
    local edit= CreateFrame("EditBox","SleekChat_InputBox", f,"InputBoxTemplate")
    self.inputBox= edit
    edit:SetAutoFocus(false)
    edit:SetHeight(24)
    edit:SetScript("OnEnterPressed", function(box)
        local text= box:GetText() and box:GetText():trim()
        if text and text~="" then
            self:SendSmartMessage(text)
        end
        box:SetText("")
        box:ClearFocus()
    end)

    self:LayoutFrames()
    self:SetChatFont()
    self:ApplyTheme()

    -- Finally, build the channel list
    self:BuildChannelList()

    addonObj:PrintDebug("Teams-like chat UI initialized.")
end

function ChatFrame:LayoutFrames()
    local f= self.mainFrame
    local pad=8

    -- Sidebar is pinned
    self.sidebar:ClearAllPoints()
    self.sidebar:SetPoint("TOPLEFT", f,"TOPLEFT",4,-4)
    self.sidebar:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",4,4)
    self.sidebar:SetWidth(120)

    -- messageFrame to the right of sidebar
    self.messageFrame:ClearAllPoints()
    self.messageFrame:SetPoint("TOPLEFT", self.sidebar, "TOPRIGHT", pad, -pad)
    self.messageFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT",-pad,-pad)
    self.messageFrame:SetPoint("BOTTOM", self.inputBox,"TOP",0,4)

    self.inputBox:ClearAllPoints()
    self.inputBox:SetPoint("BOTTOMLEFT", self.sidebar,"BOTTOMRIGHT", pad, pad)
    self.inputBox:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT",-pad, pad)
    self.inputBox:SetHeight(24)
end

--------------------------------------------------------------------------------
-- Build left sidebar of channels
--------------------------------------------------------------------------------
function ChatFrame:BuildChannelList()
    local container= self.sidebarContent
    local yOffset= -4
    local index=1
    -- We'll show a list of “ALL,” “SYSTEM,” “COMBAT,” plus known ephemeral
    local channels= self:GetChannelList()

    for _, chName in ipairs(channels) do
        local btn= self.channelButtons[index]
        if not btn then
            btn= CreateFrame("Button", nil, container,"UIPanelButtonTemplate")
            self.channelButtons[index]= btn
        end
        btn:Show()
        btn:SetSize(100,24)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", container,"TOPLEFT",4, yOffset)
        btn:SetText(chName)
        btn:SetScript("OnClick", function()
            self:SwitchChannel(chName)
        end)
        yOffset= yOffset - 26
        index= index+1
    end

    -- If we have leftover buttons from old builds, hide them
    for i=index, #self.channelButtons do
        self.channelButtons[i]:Hide()
    end

    container:SetHeight(math.abs(yOffset)+20)
end

-- Return a table of all channels we want in the sidebar:
-- e.g. { "ALL","SYSTEM","COMBAT","SAY","PARTY","GUILD","WHISPER","...","TRADE - City", etc.}
function ChatFrame:GetChannelList()
    local list= {}

    -- Include "ALL"
    tinsert(list,"ALL")
    -- System
    tinsert(list,"SYSTEM")
    -- Combat
    tinsert(list,"COMBAT")
    -- Some typical ephemeral
    tinsert(list,"SAY")
    tinsert(list,"YELL")
    tinsert(list,"PARTY")
    tinsert(list,"RAID")
    tinsert(list,"GUILD")
    tinsert(list,"OFFICER")
    tinsert(list,"WHISPER")
    tinsert(list,"BNWHISPER")
    tinsert(list,"EMOTE")
    tinsert(list,"BATTLEGROUND")
    tinsert(list,"INSTANCE")
    tinsert(list,"RAIDWARNING")

    -- Then any custom channels from "CHAT_MSG_CHANNEL"
    if self.db.profile.channels then
        for chName, enabled in pairs(self.db.profile.channels) do
            if enabled then
                tinsert(list, chName)
            end
        end
    end

    table.sort(list, function(a,b)
        if a=="ALL" then return true end
        if b=="ALL" then return false end
        return a<b
    end)

    return list
end

--------------------------------------------------------------------------------
-- Actually send chat
--------------------------------------------------------------------------------
function ChatFrame:SendSmartMessage(text)
    local channel= self.activeChannel or "ALL"

    -- If user typed slash commands
    local c= text:match("^/(%S+)")
    if c then
        c= c:lower()
        if c=="s" or c=="say" then
            channel= "SAY"
        elseif c=="y" or c=="yell" then
            channel= "YELL"
        elseif c=="p" or c=="party" then
            channel= "PARTY"
        elseif c=="ra" or c=="raid" then
            channel= "RAID"
        elseif c=="g" or c=="guild" then
            channel= "GUILD"
        elseif c=="o" or c=="officer" then
            channel= "OFFICER"
            -- etc. You can parse more
        end
        -- remove the slash portion from text
        text= text:gsub("^/%S+%s*","")
    end

    self:SendToBlizzard(text, channel)
    self:AddIncoming(text, PLAYER_NAME, channel)
end

function ChatFrame:SendToBlizzard(text, channel)
    -- Convert "SAY","GUILD","RAIDWARNING" to actual chat types
    local chatType= "SAY"
    if channel=="YELL" then chatType="YELL"
    elseif channel=="PARTY" then chatType="PARTY"
    elseif channel=="RAID" then chatType="RAID"
    elseif channel=="GUILD"then chatType="GUILD"
    elseif channel=="OFFICER" then chatType="OFFICER"
    elseif channel=="WHISPER" then
        -- In real scenario, we need a target name
        return
    elseif channel=="BNWHISPER" then
        -- BN whisper requires BN target
        return
    elseif channel=="BATTLEGROUND" then chatType="BATTLEGROUND"
    elseif channel=="INSTANCE" then chatType="INSTANCE_CHAT"
    elseif channel=="RAIDWARNING"then chatType="RAID_WARNING"
    end
    SendChatMessage(text, chatType)
end

--------------------------------------------------------------------------------
-- Called by events for inbound messages
--------------------------------------------------------------------------------
function ChatFrame:AddIncoming(text, sender, channel)
    -- Chat moderation check
    if addon.ChatModeration and addon.ChatModeration:IsMuted(sender) then
        return
    end
    if addon.ChatModeration then
        text= addon.ChatModeration:FilterMessage(text)
    end

    -- Save in history
    if addon.History then
        addon.History:AddMessage(text, sender, channel)
    end

    if self:ShouldDisplayChannel(channel) then
        self:AddMessageToFrame(text, channel, sender)
    end
end

function ChatFrame:ShouldDisplayChannel(ch)
    if self.activeChannel=="ALL" then
        -- everything
        return true
    end
    return (self.activeChannel==ch)
end

function ChatFrame:AddMessageToFrame(text, channel, sender)
    local line = self:FormatMessage(text, sender, channel)
    local isPinned = false

    -- Add pin button
    if self.db.profile.enablePinning then
        local pinBtn = CreateFrame("Button", nil, self.messageFrame)
        pinBtn:SetSize(16, 16)
        pinBtn:SetNormalTexture("Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up")
        pinBtn:SetScript("OnClick", function()
            self:PinMessage(line)
            pinBtn:Hide()
        end)
        -- Position pin button next to message
    end

    -- Highlight mentions
    if addon.AdvancedMessaging:IsMentioned(text) then
        line = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t" .. line
    end

    self.messageFrame:AddMessage(line)
    self.messageFrame:ScrollToBottom()
end

function ChatFrame:FormatMessage(text,sender,channel)
    local final=""
    if self.db.profile.timestamps then
        final= final.. format("|cff808080[%s]|r ", date(self.db.profile.timestampFormat))
    end
    if sender and sender~="" then
        local color= RAID_CLASS_COLORS["PRIEST"] or {r=1,g=1,b=1}
        if sender==PLAYER_NAME then
            color= RAID_CLASS_COLORS["MAGE"] or color
        end
        final= final.. format("|cff%02x%02x%02x%s|r: ",
                color.r*255,color.g*255,color.b*255, sender)
    end
    if channel~="ALL" and channel~="SYSTEM" then
        final= final.. format("|cff00ffff[%s]|r ", channel)
    end
    final= final.. text
    return final
end

--------------------------------------------------------------------------------
-- Switch channel from the left sidebar
--------------------------------------------------------------------------------
function ChatFrame:SwitchChannel(chName)
    self.activeChannel= chName
    self.messageFrame:Clear()

    -- re-draw pinned
    for _, pin in ipairs(self.pinnedMessages) do
        self.messageFrame:AddMessage("|cffFFD700[PINNED]|r "..pin)
    end

    -- re-display from history
    if self.activeChannel=="ALL" then
        if addon.History and addon.History.db then
            local stor= addon.History.db.profile.messageHistory
            if stor then
                for cName, arr in pairs(stor) do
                    for i=#arr,1,-1 do
                        local msgData= arr[i]
                        self:AddMessageToFrame(msgData.text, msgData.channel, msgData.sender)
                    end
                end
            end
        end
    else
        if addon.History and addon.History.db then
            local stor= addon.History.db.profile.messageHistory
            if stor and stor[chName] then
                local arr= stor[chName]
                for i=#arr,1,-1 do
                    local m= arr[i]
                    self:AddMessageToFrame(m.text, m.channel, m.sender)
                end
            end
        end
    end
    self.messageFrame:ScrollToBottom()
end

--------------------------------------------------------------------------------
-- Pin message
--------------------------------------------------------------------------------
function ChatFrame:PinMessage(msg)
    if not self.db.profile.enablePinning then return end
    tinsert(self.pinnedMessages, msg)
    self:SwitchChannel(self.activeChannel) -- re-draw
end

--------------------------------------------------------------------------------
-- Theming & Font
--------------------------------------------------------------------------------
function ChatFrame:ApplyTheme()
    local dark= self.db.profile.darkMode
    local alpha= dark and 0.7 or (self.db.profile.backgroundOpacity or 0.8)
    self.mainFrame:SetBackdropColor(0,0,0, alpha)
end

function ChatFrame:SetChatFont()
    local fontPath= SM:Fetch("font", self.db.profile.font) or DEFAULT_FONT
    local fontSize= self.db.profile.fontSize or 12
    if fontSize<8 then fontSize=8 end
    if fontSize>24 then fontSize=24 end
    self.messageFrame:SetFont(fontPath, fontSize, "")
    self.messageFrame:SetJustifyH("LEFT")  -- ensure left alignment
end

--------------------------------------------------------------------------------
-- URL Handling
--------------------------------------------------------------------------------
function ChatFrame:HandleURL(url)
    StaticPopup_Show("SLEEKCHAT_URL_DIALOG",nil,nil,{ url=url })
end

function ChatFrame:FilterMessages(searchText)
    self.messageFrame:Clear()
    for _, msg in ipairs(self.db.profile.messageHistory) do
        if msg.text:lower():find(searchText:lower()) then
            self:AddMessageToFrame(msg.text, msg.channel, msg.sender)
        end
    end
end
