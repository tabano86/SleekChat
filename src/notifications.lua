-- notifications.lua
-- Notifications module. Contains functions to show and fade out notifications.
local Notifications = {}

function Notifications.Initialize(instance)
    instance.notifications = { active = {} }
    if instance.db.profile.debug then
        instance:Print("Notifications module initialized.")
    end
end

function Notifications.ShowNotification(instance, message)
    if not instance.db.profile.enableNotifications then return end

    local notif = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    notif:SetSize(250, 40)
    notif:SetPoint("TOP", UIParent, "TOP", 0, -100)
    notif:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    notif:SetBackdropColor(0, 0, 0, 0.8)

    local text = notif:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", notif, "CENTER")
    text:SetText(message)
    notif.text = text

    notif:Show()
    table.insert(instance.notifications.active, notif)

    if instance.db.profile.debug then
        instance:Print("Notification shown: " .. message)
    end

    C_Timer.After(3, function()
        Notifications.FadeOut(instance, notif, 1)
    end)
end

function Notifications.FadeOut(instance, frame, duration)
    if not frame then return end
    frame.fadeInfo = {
        mode         = "OUT",
        timeToFade   = duration,
        finishedFunc = function()
            frame:Hide()
            for i, f in ipairs(instance.notifications.active) do
                if f == frame then
                    table.remove(instance.notifications.active, i)
                    break
                end
            end
        end,
    }
    UIFrameFade(frame, frame.fadeInfo)
end

SleekChat = SleekChat or {}
SleekChat.Notifications = Notifications
