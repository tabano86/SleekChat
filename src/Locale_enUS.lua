if not _G.SleekChat then
    _G.SleekChat = {}
end

-- Return if we've already set up a locale.
if _G.SleekChat.Locale then
    return
end

local L = LibStub("AceLocale-3.0"):NewLocale("SleekChat", "enUS", true)
if not L then
    -- If the locale is not needed or otherwise unavailable,
    -- stop before registering it.
    return
end

-- Define locale strings:
L["General"]           = "General"
L["Hide Default Chat"] = "Hide Default Chat"
L["Class Colors"]      = "Class Colors"
L["Timestamps"]        = "Timestamps"
L["URL Detection"]     = "URL Detection"
L["Appearance"]        = "Appearance"
L["Font"]              = "Font"
L["Font Size"]         = "Font Size"
L["Background Color"]  = "Background Color"

-- Store the locale in the global SleekChat table.
_G.SleekChat.Locale = L

-- Register the locale in SleekChat's module registry.
local registry = _G.SleekChat.Modules
registry:register("Locale", L)
