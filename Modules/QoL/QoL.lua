-- ===========================================================================
-- SleekChat v2.0 - QoL.lua
-- Provides in-chat search, extended scrollback, channel auto-rejoin,
-- inactivity timers, chat transcript export, and clear chat functionality.
-- ===========================================================================
local QoL = {}
SleekChat_QoL = QoL

local frame = CreateFrame("Frame", "SleekChatQoLFrame", UIParent)
frame:RegisterEvent("PLAYER_LOGIN")

function QoL:CreateExportFrame()
    local frame = CreateFrame("Frame", "SleekChatExportFrame", UIParent, "BasicFrameTemplate")
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER")
    frame:SetTitle("Chat Transcript")
    frame:Hide()

    local scroll = CreateFrame("ScrollFrame", "SleekChatExportScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -30)
    scroll:SetPoint("BOTTOMRIGHT", -30, 8)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetSize(scroll:GetSize())
    edit:SetMultiLine(true)
    edit:SetFontObject("ChatFontNormal")
    edit:SetAutoFocus(false)
    scroll:SetScrollChild(edit)

    frame.editBox = edit
    return frame
end

-- Inactivity timer / auto-lock chat frames
local function OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 5 then
        local idleThreshold = SleekChat_Config.Get("qol", "inactivityThreshold") or 300
        if (GetTime() - (self.lastInput or GetTime())) > idleThreshold then
            for i = 1, NUM_CHAT_WINDOWS do
                local cf = _G["ChatFrame"..i]
                if cf and not cf.isLocked then
                    FCF_SetLocked(cf, 1)
                end
            end
        end
        self.elapsed = 0
    end
end

frame:SetScript("OnUpdate", OnUpdate)

-- Reset inactivity timer on user input and unlock chat frames if needed
local function OnUserInput(self, event)
    self.lastInput = GetTime()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame"..i]
        if cf and cf.isLocked then
            FCF_SetLocked(cf, 0)
        end
    end
end

frame:EnableKeyboard(true)
frame:SetScript("OnKeyDown", OnUserInput)

-- Auto rejoin channels on login
function QoL:AutoRejoinChannels()
    local channels = SleekChat_Config.Get("qol", "autoRejoinChannels") or {}
    for _, ch in ipairs(channels) do
        local alreadyJoined = false
        local channelList = { GetChannelList() }
        for i = 1, #channelList, 2 do
            if type(channelList[i+1]) == "string" and channelList[i+1]:lower() == ch:lower() then
                alreadyJoined = true
                break
            end
        end
        if not alreadyJoined then
            JoinChannelByName(ch)
        end
    end
end

-- In-chat search command
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
    local found = false
    for _, region in ipairs({ cf:GetRegions() }) do
        if region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if text and text:lower():find(query:lower(), 1, true) then
                print("|cff00ff00[Match]|r: " .. text)
                found = true
            end
        end
    end
    if not found then
        print("No matches found for '" .. query .. "' in the current chat frame.")
    end
end

-- Chat transcript export command
SLASH_SLEEKCHAT_EXPORT1 = "/chatexport"
SlashCmdList["SLEEKCHAT_EXPORT"] = function()
    if not SleekChat_QoL.ExportTranscript then
        print("Chat export feature is not available.")
        return
    end
    SleekChat_QoL:ExportTranscript()
end

function QoL:ExportTranscript()
    local cf = SELECTED_CHAT_FRAME
    if not cf or not cf.sleekChatMessages then
        print("SleekChat: No transcript available")
        return
    end

    if not self.exportFrame then
        self.exportFrame = self:CreateExportFrame()
    end

    local text = table.concat(cf.sleekChatMessages, "\n")
    self.exportFrame.editBox:SetText(text)
    self.exportFrame:Show()
end

-- Add message capturing in QoL initialization
function QoL:HookChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame"..i]
        if cf and not cf.sleekChatHooked then
            hooksecurefunc(cf, "AddMessage", function(self, text, ...)
                if not self.sleekChatMessages then
                    self.sleekChatMessages = {}
                end
                table.insert(self.sleekChatMessages, text)
                -- Keep last 5000 messages
                while #self.sleekChatMessages > 5000 do
                    table.remove(self.sleekChatMessages, 1)
                end
            end)
            cf.sleekChatHooked = true
        end
    end
end

-- Update OnEvent handler
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        QoL:AutoRejoinChannels()
        QoL:HookChatFrames()
    end
end)
