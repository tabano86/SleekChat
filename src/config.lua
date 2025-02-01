-- config.lua
local Util = require("Util") or _G.SleekChat.Util
local Logger = require("Logger") or _G.SleekChat.Logger

local Config = Util.singleton("Config", function()
    local self = {}

    local L = LibStub("AceLocale-3.0"):NewLocale("SleekChat", "enUS", true)
    if not L then L = {} end  -- Fallback if locale already registered

    L["General"]           = L["General"] or "General"
    L["Hide Default Chat"] = L["Hide Default Chat"] or "Hide Default Chat"
    L["Class Colors"]      = L["Class Colors"] or "Class Colors"
    L["Timestamps"]        = L["Timestamps"] or "Timestamps"
    L["URL Detection"]     = L["URL Detection"] or "URL Detection"
    L["Appearance"]        = L["Appearance"] or "Appearance"
    L["Font"]              = L["Font"] or "Font"
    L["Font Size"]         = L["Font Size"] or "Font Size"
    L["Background Color"]  = L["Background Color"] or "Background Color"

    Logger:Debug("Config module loaded with locale strings.")

    function self.generateOptions(getter, setter)
        return {
            name = "SleekChat",
            type = "group",
            args = {
                general = {
                    name = L["General"],
                    type = "group",
                    args = {
                        hideDefault = {
                            type = "toggle",
                            name = L["Hide Default Chat"],
                            get = getter,
                            set = setter,
                            order = 1,
                        },
                        classColors = {
                            type = "toggle",
                            name = L["Class Colors"],
                            get = getter,
                            set = setter,
                            order = 2,
                        },
                        timestamps = {
                            type = "toggle",
                            name = L["Timestamps"],
                            get = getter,
                            set = setter,
                            order = 3,
                        },
                        urlDetection = {
                            type = "toggle",
                            name = L["URL Detection"],
                            get = getter,
                            set = setter,
                            order = 4,
                        },
                    },
                },
                appearance = {
                    name = L["Appearance"],
                    type = "group",
                    args = {
                        font = {
                            type = "select",
                            name = L["Font"],
                            values = {
                                ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata",
                                ["Fonts\\ARIALN.TTF"]   = "Arial Narrow",
                                ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
                            },
                            get = getter,
                            set = setter,
                            order = 1,
                        },
                        fontSize = {
                            type = "range",
                            name = L["Font Size"],
                            min = 8,
                            max = 24,
                            step = 1,
                            get = getter,
                            set = setter,
                            order = 2,
                        },
                        bgColor = {
                            type = "color",
                            name = L["Background Color"],
                            hasAlpha = true,
                            get = function()
                                local c = SleekChat.db.profile.bgColor
                                return c.r or 0, c.g or 0, c.b or 0, c.a or 1
                            end,
                            set = function(_, r, g, b, a)
                                SleekChat.db.profile.bgColor = { r = r, g = g, b = b, a = a }
                                if SleekChat.UI and SleekChat.UI.UpdateBackground then
                                    SleekChat.UI.UpdateBackground(SleekChat)
                                end
                            end,
                            order = 3,
                        },
                    },
                },
            },
        }
    end

    function self.Setup(instance, configGenerator)
        local AceConfig = LibStub("AceConfig-3.0")
        local AceConfigDialog = LibStub("AceConfigDialog-3.0")
        local function getter(info)
            return instance.db.profile[info[#info]]
        end
        local function setter(info, value)
            instance.db.profile[info[#info]] = value
            if instance.ApplySettings then
                instance:ApplySettings()
            end
        end
        local options = configGenerator(getter, setter)
        AceConfig:RegisterOptionsTable("SleekChat", options)
        AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")
        Logger:Debug("Config.Setup completed.")
    end

    return self
end)

return Config
