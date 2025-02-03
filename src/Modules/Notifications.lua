local _, addon= ...
local AceLocale= LibStub("AceLocale-3.0")
local L= AceLocale:GetLocale("SleekChat", true)
local SM= LibStub("LibSharedMedia-3.0")

addon.Notifications={}
local Notifications= addon.Notifications

function Notifications:Initialize(addonObj)
    self.db= addonObj.db
end

function Notifications:ShowWhisperAlert(sender, msg)
    if not self.db.profile.enableNotifications then return end
    if self.db.profile.notificationSound and self.db.profile.notificationSound~="None" then
        PlaySoundFile(SM:Fetch("sound", self.db.profile.notificationSound), "Master", self.db.profile.soundVolume or 1.0)
        if addon.AdvancedMessaging:IsMentioned(msg) then
            PlaySoundFile(SM:Fetch("sound", "UI_Quest_Log_Open"), "Master")
        end
    end
    if self.db.profile.flashTaskbar then
        FlashClientIcon()
    end
    local f= CreateFrame("Button", nil, UIParent,"BackdropTemplate")
    f:SetFrameStrata("DIALOG")
    f:SetSize(300,40)
    f:SetPoint("TOP",0,-150)
    f:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=16,
    })
    f:SetBackdropColor(0,0,0,0.8)
    local txt= f:CreateFontString(nil,"OVERLAY","GameFontNormal")
    txt:SetPoint("TOPLEFT")
    txt:SetText(string.format(L.whisper_notification, sender))
    f:SetScript("OnClick", function()
        if addon.ChatFrame and addon.ChatFrame.SwitchChannel then
            addon.ChatFrame:SwitchChannel("WHISPER")
        end
        f:Hide()
    end)
    UIFrameFadeOut(f,5,1,0)
    f:SetScript("OnFadeComplete", function() f:Hide() end)

    -- Add clickable avatar
    local avatar = CreateFrame("Button", nil, f)
    avatar:SetSize(32, 32)
    avatar:SetPoint("LEFT", 4, 0)

    local texture = avatar:CreateTexture()
    texture:SetAllPoints()
    SetPortraitTexture(texture, sender)

    -- Add notification queue system
    if not self.notificationQueue then self.notificationQueue = {} end
    tinsert(self.notificationQueue, f)

    -- Position notifications vertically
    for i, frame in ipairs(self.notificationQueue) do
        frame:ClearAllPoints()
        frame:SetPoint("TOP", UIParent, "TOP", 0, -150 - ((i-1) * 45))
    end

    local _, class = UnitClass(sender)
    local color = RAID_CLASS_COLORS[class] or {r=0.4, g=0.4, b=1}
    f:SetBackdropBorderColor(color.r, color.g, color.b, 0.8)

    -- Add reply button
    local replyBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    replyBtn:SetSize(80, 22)
    replyBtn:SetPoint("RIGHT", f, -4, 0)
    replyBtn:SetText("Reply")
    replyBtn:SetScript("OnClick", function()
        addon.ChatFrame:SwitchChannel("WHISPER")
        addon.ChatFrame.inputBox:SetFocus()
        f:Hide()
    end)
end
