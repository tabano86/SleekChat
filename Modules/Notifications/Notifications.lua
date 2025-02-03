-- ===========================================================================
-- SleekChat v2.0 - Notifications.lua
-- Implements keyword alerts, regex triggers, and sound notifications.
-- ===========================================================================
local Notifications = {}
SleekChat_Notifications = Notifications

local frame = CreateFrame("Frame", "SleekChatNotificationsFrame", UIParent)
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_WHISPER")

local function CheckForKeywords(msg, sender, event)
    local keywords = SleekChat_Config.Get("notifications", "keywords")
    if keywords then
        for _, word in ipairs(keywords) do
            if msg:lower():find(word:lower(), 1, true) then
                Notifications:TriggerAlert(word, msg, sender, event)
            end
        end
    end
end

local function CheckForRegex(msg)
    local patterns = SleekChat_Config.Get("notifications", "regexTriggers")
    if patterns then
        for _, pattern in ipairs(patterns) do
            if msg:match(pattern) then
                Notifications:TriggerRegexAlert(pattern, msg)
            end
        end
    end
end

function Notifications:TriggerAlert(keyword, msg, sender, event)
    if SleekChat_Config.Get("notifications", "playSound") then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
    UIErrorsFrame:AddMessage(("Keyword [%s] from %s: %s"):format(keyword, sender, msg), 1.0, 1.0, 0.0, 53, 5)
end

function Notifications:TriggerRegexAlert(pattern, msg)
    if SleekChat_Config.Get("notifications", "playSound") then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
    UIErrorsFrame:AddMessage(("Regex match [%s]: %s"):format(pattern, msg), 1.0, 0.5, 0.5, 53, 5)
end

local function OnChatEvent(self, event, msg, sender, ...)
    local conditions = SleekChat_Config.Get("notifications", "conditionalAlerts") or {}
    for _, cond in ipairs(conditions) do
        local playerClass = select(2, UnitClass("player"))
        local playerSpec = GetSpecialization() or 0
        if (cond.class and cond.class == playerClass) or (cond.spec and cond.spec == playerSpec) then
            if msg:lower():find(cond.phrase:lower(), 1, true) then
                Notifications:TriggerAlert(cond.phrase, msg, sender, event)
            end
        end
    end
    CheckForKeywords(msg, sender, event)
    CheckForRegex(msg)
end

frame:SetScript("OnEvent", OnChatEvent)
