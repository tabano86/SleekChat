local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.Notifications = {}
local Notifications = addon.Notifications

function Notifications:Initialize(addonObj)
    self.db = addonObj.db
end

function Notifications:ShowWhisperAlert(sender, message)
    if not self.db.profile.enableNotifications then return end
    if self.db.profile.notificationSound and self.db.profile.notificationSound ~= "None" then
        PlaySoundFile(SM:Fetch("sound", self.db.profile.notificationSound), "Master", self.db.profile.soundVolume or 1.0)
    end
    if self.db.profile.flashTaskbar then
        FlashClientIcon()
    end
    local f = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    f:SetFrameStrata("DIALOG")
    f:SetSize(300, 40)
    f:SetPoint("TOP", 0, -150)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(format(L.whisper_notification, sender))
    f:SetScript("OnClick", function()
        if addon.ChatFrame and addon.ChatFrame.SwitchChannel then
            addon.ChatFrame:SwitchChannel("WHISPER")
        end
        f:Hide()
    end)
    UIFrameFadeOut(f, 5, 1, 0)
    f:SetScript("OnFadeComplete", function() f:Hide() end)
end

return Notifications
