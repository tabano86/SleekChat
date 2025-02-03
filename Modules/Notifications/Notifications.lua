-- ===========================================================================
-- SleekChat v2.0 - Notifications.lua
-- Keyword alerts, custom pings, regex triggers, spam filters, etc.
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
-- etc, add other relevant chat events as needed

local function CheckForKeywords(msg, event, sender)
    local keywords = SleekChat_Config.Get("notifications", "keywords")
    if not keywords or #keywords == 0 then return end

    for _, word in ipairs(keywords) do
        if string.find(string.lower(msg), string.lower(word), 1, true) then
            -- Trigger alert
            Notifications:TriggerAlert(word, msg, sender, event)
        end
    end
end

-- Optional regex triggers
local function CheckForRegex(msg)
    local regexList = SleekChat_Config.Get("notifications", "regexTriggers")
    if not regexList then return end

    for _, pattern in ipairs(regexList) do
        local found = string.match(msg, pattern)
        if found then
            Notifications:TriggerRegexAlert(pattern, msg)
        end
    end
end

function Notifications:TriggerAlert(keyword, msg, sender, event)
    if SleekChat_Config.Get("notifications", "playSound") then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
    -- Possibly show a UI error or highlight
    UIErrorsFrame:AddMessage("Keyword ["..keyword.."] from "..sender..": "..msg, 1.0, 1.0, 0.0, 53, 5)
end

function Notifications:TriggerRegexAlert(pattern, msg)
    if SleekChat_Config.Get("notifications", "playSound") then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
    UIErrorsFrame:AddMessage("Regex match ["..pattern.."]: "..msg, 1.0, 0.5, 0.5, 53, 5)
end

local function OnChatEvent(self, event, msg, sender, ...)
    -- Check if user wants conditional notifications (like "Need tank" only if you're a tank)
    local conditions = SleekChat_Config.Get("notifications", "conditionalAlerts") or {}
    for _, cond in ipairs(conditions) do
        if cond.class == select(2, UnitClass("player")) or cond.spec == GetSpecialization() then
            if string.find(string.lower(msg), string.lower(cond.phrase), 1, true) then
                Notifications:TriggerAlert(cond.phrase, msg, sender, event)
            end
        end
    end

    CheckForKeywords(msg, event, sender)
    CheckForRegex(msg)

    -- Let normal chat processing continue (we're hooking, not filtering out)
end

frame:SetScript("OnEvent", OnChatEvent)
