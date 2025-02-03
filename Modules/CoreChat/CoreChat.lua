-- ===========================================================================
-- SleekChat v2.0 - CoreChat.lua
-- Core hooking and baseline chat modifications
-- ===========================================================================

local CoreChat = {}
SleekChat_CoreChat = CoreChat  -- Expose to global if needed

local eventsFrame = CreateFrame("Frame", "SleekChatCoreFrame", UIParent)

-- General event handler
eventsFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "SleekChat" then
            -- Initialize config / saved variables
            if not SleekChatDB then
                SleekChatDB = {}
            end
            -- Merge defaults
            SleekChat_Config:InitializeDefaults()

            -- Register slash commands
            CoreChat:RegisterSlashCommands()

            print("|cff00ff00SleekChat v2.0 Loaded.|r")
        end
    elseif event == "PLAYER_LOGIN" then
        CoreChat:OnPlayerLogin()
    end
end)

function CoreChat:OnPlayerLogin()
    -- Example hooking: ensure chat frames update with any config changes
    self:ApplyCoreHooks()
end

function CoreChat:ApplyCoreHooks()
    -- Minimal hooking example: change default chat history lines
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            local historyLines = SleekChat_Config.Get("core", "historyLines")
            if historyLines then
                chatFrame:SetMaxLines(historyLines)
            end
        end
    end
end

function CoreChat:RegisterSlashCommands()
    -- /sleekchat main slash
    SLASH_SLEEKCHAT1 = "/sleekchat"
    SlashCmdList["SLEEKCHAT"] = function(msg)
        local args = { strsplit(" ", msg) }
        if #args == 0 or args[1] == "" then
            print("|cff00ff00SleekChat Help:|r /sleekchat config /sleekchat reload /sleekchat debug [on/off]")
            return
        end

        local cmd = string.lower(args[1])
        if cmd == "config" then
            print("Open config UI (placeholder).")
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
        else
            print("Unknown command. Available: config, reload, debug")
        end
    end
end

-- Register events
eventsFrame:RegisterEvent("ADDON_LOADED")
eventsFrame:RegisterEvent("PLAYER_LOGIN")
