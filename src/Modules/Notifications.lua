local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Notifications = {}
local Notifications = addon.Notifications

function Notifications.Initialize(self)
    self.notificationPool = {}
end

function Notifications.ShowWhisperAlert(self, sender, message)
    if not self.db.profile.enableNotifications then return end

    local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
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

    -- Auto-fade after 5 seconds
    C_Timer.After(5, function()
        UIFrameFadeOut(f, 1, 1, 0)
        f:SetScript("OnFadeComplete", function() f:Hide() end)
    end)
end
