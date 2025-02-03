-- ===========================================================================
-- SleekChat v2.0 - Config.lua
-- Global config initialization and helper functions
-- ===========================================================================

SleekChat_Config = {}

local function mergeTable(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then
                dest[k] = {}
            end
            mergeTable(dest[k], v)
        else
            if dest[k] == nil then
                dest[k] = v
            end
        end
    end
end

function SleekChat_Config:InitializeDefaults()
    -- Retrieve defaults from each module
    if not SleekChatDB then
        SleekChatDB = {}
    end

    if not SleekChatDB.config then
        SleekChatDB.config = {}
    end

    -- CoreChat defaults
    local coreDefaults = SleekChat_CoreChatConfig:GetDefaults()
    if not SleekChatDB.config.core then
        SleekChatDB.config.core = {}
    end
    mergeTable(SleekChatDB.config.core, coreDefaults)

    -- UIEnhancements defaults
    if not SleekChatDB.config.ui then
        SleekChatDB.config.ui = {
            autoHideInput = true,
            splitTrade = false,
            fontPath = "Fonts\\FRIZQT__.TTF"
        }
    end

    -- Notifications defaults
    if not SleekChatDB.config.notifications then
        SleekChatDB.config.notifications = {
            keywords = {"heal", "tank", "dps"},
            regexTriggers = { "%[Epic%]" },
            playSound = true,
            conditionalAlerts = {
                { phrase = "Need tank", class = "WARRIOR", spec = nil }
            }
        }
    end

    -- QoL defaults
    if not SleekChatDB.config.qol then
        SleekChatDB.config.qol = {
            inactivityThreshold = 300,
            autoRejoinChannels = { "General", "Trade", "LocalDefense" }
        }
    end
end

function SleekChat_Config.Get(category, key)
    if not SleekChatDB or not SleekChatDB.config then return nil end
    if SleekChatDB.config[category] then
        return SleekChatDB.config[category][key]
    end
    return nil
end

function SleekChat_Config.Set(category, key, value)
    if not SleekChatDB or not SleekChatDB.config then return end
    if not SleekChatDB.config[category] then
        SleekChatDB.config[category] = {}
    end
    SleekChatDB.config[category][key] = value
end
