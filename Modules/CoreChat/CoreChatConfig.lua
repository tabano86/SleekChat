-- ===========================================================================
-- SleekChat v2.0 - CoreChatConfig.lua
-- Default configuration for core chat features
-- ===========================================================================
local CoreChatConfig = {}

CoreChatConfig.defaults = {
    historyLines = 5000,  -- Extended scrollback
    preserveDefault = true,
}

function CoreChatConfig:GetDefaults()
    return self.defaults
end

SleekChat_CoreChatConfig = CoreChatConfig
