-- notifications.lua
SleekChatNotifications = {}
local Notifications = SleekChatNotifications

function Notifications:InitializeNotifications()
    self.activeNotifications = {}
    SleekChatUtil:Log("Notifications module initialized.", "DEBUG")
end

function Notifications:ShowNotification(message)
    if not SleekChat.db.profile.enableNotifications then
        return
    end

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
    table.insert(self.activeNotifications, notif)
    SleekChatUtil:Log("Notification shown: " .. message, "DEBUG")

    C_Timer.After(3, function()
        self:FadeOut(notif, 1)
    end)
end

function Notifications:FadeOut(frame, duration)
    if not frame then return end
    -- Use Blizzard's UIFrameFade functions with a finished callback to remove the frame.
    frame.fadeInfo = {
        mode         = "OUT",
        timeToFade   = duration,
        finishedFunc = function()
            frame:Hide()
            for i, f in ipairs(self.activeNotifications) do
                if f == frame then
                    table.remove(self.activeNotifications, i)
                    break
                end
            end
        end,
    }
    UIFrameFade(frame, frame.fadeInfo)
end
