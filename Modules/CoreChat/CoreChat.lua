-- ===========================================================================
-- SleekChat v2.0 - CoreChat.lua
-- Core hooking and baseline chat modifications
-- ===========================================================================
local CoreChat = {}
SleekChat_CoreChat = CoreChat

local eventsFrame = CreateFrame("Frame", "SleekChatCoreFrame", UIParent)
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "SleekChat" then
            if not SleekChatDB then SleekChatDB = {} end
            SleekChat_Config:InitializeDefaults()
            CoreChat:RegisterSlashCommands()
            print("|cff00ff00SleekChat v2.0 Loaded.|r")
        end
    elseif event == "PLAYER_LOGIN" then
        CoreChat:OnPlayerLogin()
    end
end

function CoreChat:OnPlayerLogin()
    self:ApplyCoreHooks()
end

function CoreChat:ApplyCoreHooks()
    local historyLines = SleekChat_Config.Get("core", "historyLines") or 5000
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame and chatFrame.SetMaxLines then
            chatFrame:SetMaxLines(historyLines)
        end
    end
end

function CoreChat:RegisterSlashCommands()
    SLASH_SLEEKCHAT1 = "/sleekchat"
    SlashCmdList["SLEEKCHAT"] = function(msg)
        local args = { strsplit(" ", msg) }
        if #args == 0 or args[1] == "" then
            print("|cff00ff00SleekChat Help:|r /sleekchat config | /sleekchat reload | /sleekchat debug [on/off] | /sleekchat clear")
            return
        end
        local cmd = strlower(args[1])
        if cmd == "config" then
            print("Open config UI (production-ready UI not implemented).")
        elseif cmd == "reload" then
            ReloadUI()
        elseif cmd == "debug" then
            if args[2] == "on" then
                SleekChatDB.debug = true
                print("SleekChat debug enabled.")
            elseif args[2] == "off" then
                SleekChatDB.debug = false
                print("SleekChat debug disabled.")
            else
                print("Usage: /sleekchat debug [on/off]")
            end
        elseif cmd == "clear" then
            CoreChat:ClearChatFrames()
        else
            print("Unknown command. Available: config, reload, debug, clear")
        end
    end
end

function CoreChat:ClearChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame and chatFrame.Clear then
            chatFrame:Clear()
        end
    end
    print("Chat frames cleared.")
end

eventsFrame:SetScript("OnEvent", OnEvent)
eventsFrame:RegisterEvent("ADDON_LOADED")
eventsFrame:RegisterEvent("PLAYER_LOGIN")
