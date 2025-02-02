-- logger.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Logger and _G.SleekChat.Logger._loaded then return end
_G.SleekChat.Logger = _G.SleekChat.Logger or {}
local Logger = _G.SleekChat.Logger

function Logger:Info(message)
    print("|cff00ff00[INFO]|r " .. tostring(message))
end

function Logger:Warn(message)
    print("|cffffff00[WARN]|r " .. tostring(message))
end

function Logger:Error(message)
    print("|cffff0000[ERROR]|r " .. tostring(message))
end

function Logger:Debug(message)
    self:Info("[DEBUG] " .. tostring(message))
end

Logger._loaded = true
local registry = _G.SleekChat.Modules
if registry then
    registry:register("Logger", Logger)
else
    error("Global Modules registry not defined in logger.lua. Check Init.lua and .toc order.")
end
