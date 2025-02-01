-- notifications.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Notifications and _G.SleekChat.Notifications._loaded then return end
_G.SleekChat.Notifications = _G.SleekChat.Notifications or {}
local Notifications = _G.SleekChat.Notifications
local Logger = _G.SleekChat.Logger

Logger:Debug("Notifications Loading...")

function Notifications.Initialize(instance)
    instance.notifications = { active = {} }
    Logger:Info("Notifications module initialized.")
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
    Logger:Info("Notification shown: " .. message)
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

Logger:Debug("Notifications Loaded!")
Notifications._loaded = true
local registry = _G.SleekChat.Modules
registry:register("Notifications", Notifications)
