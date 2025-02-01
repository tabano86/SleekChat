-- config.lua
-- This file configures and registers settings for SleekChat
-- using AceConfig. It sets up logical sections, localized keys,
-- and ties them to the addon's database.

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true) or AceLocale:NewLocale("SleekChat", "enUS", true)

-- Populate localization strings for English as a fallback.
if L then
    L["General"]           = L["General"] or "General"
    L["Hide Default Chat"] = L["Hide Default Chat"] or "Hide Default Chat"
    L["Class Colors"]      = L["Class Colors"] or "Class Colors"
    L["Timestamps"]        = L["Timestamps"] or "Timestamps"
    L["URL Detection"]     = L["URL Detection"] or "URL Detection"
    L["Appearance"]        = L["Appearance"] or "Appearance"
    L["Font"]              = L["Font"] or "Font"
    L["Font Size"]         = L["Font Size"] or "Font Size"
    L["Background Color"]  = L["Background Color"] or "Background Color"
end

--- Generates the AceConfig options table for SleekChat.
-- @param getter A function to retrieve values from the addon's DB.
-- @param setter A function to store values to the addon's DB.
-- @return A table describing SleekChat’s options.
local function generateOptions(getter, setter)
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

local AceConfig       = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- Sets up AceConfig registration for SleekChat, linking DB getters and setters.
-- @param instance A reference to the main addon instance with a .db field.
-- @param configGenerator A function returning the AceConfig table.
local function Setup(instance, configGenerator)
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
end

-- Attach to the global namespace for other modules to require.
SleekChat = SleekChat or {}
SleekChat.Config = {
    generateOptions = generateOptions,
    Setup = Setup,
}
