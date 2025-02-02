local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")
local SM = LibStub("LibSharedMedia-3.0")

addon.Notifications = {}
local Notifications = addon.Notifications

function Notifications.ShowWhisperAlert(self, sender, message)
    if not self.db.profile.enableNotifications then return end

    -- Play sound
    if self.db.profile.notificationSound ~= "None" then
        PlaySoundFile(SM:Fetch("sound", self.db.profile.notificationSound), "Master", self.db.profile.soundVolume)
    end

    -- Flash taskbar
    if self.db.profile.flashTaskbar then
        FlashClientIcon()
    end

    -- Create notification frame
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
        self.ChatFrame:SwitchChannel("WHISPER")
        f:Hide()
    end)

    -- Auto-fade after 5 seconds
    UIFrameFadeOut(f, 5, 1, 0)
    f:SetScript("OnFadeComplete", function() f:Hide() end)
end
