-- ui.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.UI and _G.SleekChat.UI._loaded then return end
_G.SleekChat.UI = _G.SleekChat.UI or {}
local UI = _G.SleekChat.UI
local Logger = _G.SleekChat.Logger
local Modules = _G.SleekChat.Modules or error("Modules registry missing. Check Init.lua and .toc order!")
Logger:Debug("UI Loading...")

function UI.Initialize(instance)
    -- Frame positioning logic
    if not instance.db.profile.position then
        instance.db.profile.position = {"CENTER", "UIParent", "CENTER", 0, 0}
    end

    -- Main frame creation
    instance.UIFrame = CreateFrame("Frame", "SleekChatFrame", UIParent, "BackdropTemplate")
    instance.UIFrame:SetSize(instance.db.profile.width, instance.db.profile.height)

    -- Restore position
    local pos = instance.db.profile.position
    if pos and #pos == 5 then
        instance.UIFrame:SetPoint(pos[1], _G[pos[2]] or UIParent, pos[3], pos[4], pos[5])
    else
        instance.UIFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    instance.UIFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    instance.UIFrame:SetMovable(true)
    instance.UIFrame:EnableMouse(true)
    instance.UIFrame:RegisterForDrag("LeftButton")
    instance.UIFrame:SetScript("OnDragStart", instance.UIFrame.StartMoving)
    instance.UIFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, relativeTo, relativePoint, x, y = frame:GetPoint()
        instance.db.profile.position = {
            point,
            relativeTo:GetName(),
            relativePoint,
            x,
            y
        }
    end)

    -- Chat Area with proper backdrop
    instance.ChatArea = CreateFrame("Frame", "SleekChatChatArea", instance.UIFrame, "BackdropTemplate")
    instance.ChatArea:SetPoint("TOPLEFT", instance.UIFrame, "TOPLEFT", 10, -10)
    instance.ChatArea:SetPoint("BOTTOMRIGHT", instance.UIFrame, "BOTTOMRIGHT", -10, 40)
    instance.ChatArea:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    instance.ChatArea:SetBackdropColor(0, 0, 0, 0.5)
    instance.ChatArea:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    -- Remaining UI elements (scroll frame, input box, etc.)
    -- ... [rest of your UI initialization code] ...

    UI.UpdateBackground(instance)
    Logger:Info("UI module initialized.")
end

-- ... [rest of your UI functions] ...

Logger:Debug("UI Loaded!")
UI._loaded = true
Modules:register("UI", UI)
