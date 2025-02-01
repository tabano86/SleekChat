-- Locale_enUS.lua
if not _G.SleekChat then _G.SleekChat = {} end
local L = LibStub("AceLocale-3.0"):NewLocale("SleekChat", "enUS", true)
if not L then return end  -- exit if locale already registered
L["General"]           = "General"
L["Hide Default Chat"] = "Hide Default Chat"
L["Class Colors"]      = "Class Colors"
L["Timestamps"]        = "Timestamps"
L["URL Detection"]     = "URL Detection"
L["Appearance"]        = "Appearance"
L["Font"]              = "Font"
L["Font Size"]         = "Font Size"
L["Background Color"]  = "Background Color"
_G.SleekChat.L = L
