-- ===========================================================================
-- SleekChat v2.0 - CoreChatConfig.lua
-- Default config for core chat features
-- ===========================================================================

local CoreChatConfig = {}

-- Define defaults specifically for core chat
CoreChatConfig.defaults = {
    historyLines = 5000,  -- Extended scrollback
    preserveDefault = true,
}

function CoreChatConfig:GetDefaults()
    return self.defaults
end

SleekChat_CoreChatConfig = CoreChatConfig
