-- Init.lua
if not _G.SleekChat then _G.SleekChat = {} end
if not _G.SleekChat.ModuleRegistry then
    error("ModuleRegistry.lua not loaded. Please ensure it is listed in your .toc before Init.lua.")
end
_G.SleekChat.Modules = _G.SleekChat.ModuleRegistry:new()
