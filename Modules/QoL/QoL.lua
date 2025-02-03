-- ===========================================================================
-- SleekChat v2.0 - QoL.lua
-- In-chat search, extended scrollback, channel rejoin, inactivity timers, etc.
-- ===========================================================================

local QoL = {}
SleekChat_QoL = QoL

local frame = CreateFrame("Frame", "SleekChatQoLFrame", UIParent)
frame:RegisterEvent("PLAYER_LOGIN")

-- Inactivity / auto-scroll lock
local function OnUpdate(self, elapsed)
    self.lastUpdate = (self.lastUpdate or 0) + elapsed
    local idleThreshold = SleekChat_Config.Get("qol", "inactivityThreshold") or 300

    if self.lastUpdate > 5 then
        if (GetTime() - (self.lastAction or 0)) > idleThreshold then
            -- Example: auto-lock chat frames so they don't keep scrolling
            for i = 1, NUM_CHAT_WINDOWS do
                local cf = _G["ChatFrame"..i]
                if cf and not cf.isLocked then
                    FCF_SetLocked(cf, 1)
                end
            end
        end
        self.lastUpdate = 0
    end
end

frame:SetScript("OnUpdate", OnUpdate)

-- Listen for user input to reset inactivity timer
local function OnUserInput(self, event, key)
    self.lastAction = GetTime()
    -- Unlock all chat frames if locked
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame"..i]
        if cf and cf.isLocked then
            FCF_SetLocked(cf, 0)
        end
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:SetPropagateKeyboardInput(true)
        self:SetScript("OnKeyDown", OnUserInput)

        -- Auto rejoin channels
        QoL:AutoRejoinChannels()
    end
end)

function QoL:AutoRejoinChannels()
    local channels = SleekChat_Config.Get("qol", "autoRejoinChannels") or {}
    for _, ch in ipairs(channels) do
        local idTable = { GetChannelList() }
        local alreadyJoined = false
        for i=1, #idTable, 2 do
            local index, name = idTable[i], idTable[i+1]
            if name:lower() == ch:lower() then
                alreadyJoined = true
                break
            end
        end
        if not alreadyJoined then
            JoinChannelByName(ch)
        end
    end
end

-- Simple in-chat search example (bind to slash or a UI element)
SLASH_SLEEKCHAT_SEARCH1 = "/chatsearch"
SlashCmdList["SLEEKCHAT_SEARCH"] = function(query)
    if not query or query == "" then
        print("Usage: /chatsearch <text>")
        return
    end
    QoL:SearchCurrentChat(query)
end

function QoL:SearchCurrentChat(query)
    local cf = SELECTED_CHAT_FRAME
    if not cf then return end

    -- Each ChatFrame region might be a FontString or other UI elements
    local lines = { cf:GetRegions() }
    local foundSomething = false
    for _, region in ipairs(lines) do
        if region.GetText then
            local text = region:GetText()
            if text and string.find(string.lower(text), string.lower(query), 1, true) then
                print("|cff00ff00[Match]|r: "..text)
                foundSomething = true
            end
        end
    end

    if not foundSomething then
        print("No matches found for '"..query.."' in current chat frame.")
    end
end
