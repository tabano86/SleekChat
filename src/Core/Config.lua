local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Config = {}
local Config = addon.Config

-- Separate function for creating the "General" configuration group
local function CreateGeneralOptions(self)
    return {
        name = L.general,
        type = "group",
        order = 1,
        args = {
            headerGeneral = {
                name = L.general_settings,
                type = "header",
                order = 1
            },
            classColors = {
                name = L.class_colors,
                desc = L.class_colors_desc,
                type = "toggle",
                get = function() return self.db.profile.classColors end,
                set = function(_, val)
                    self.db.profile.classColors = val
                    self.ChatFrame.UpdateAll()
                end,
                order = 2
            },
            timestamps = {
                name = L.timestamps,
                desc = L.timestamps_desc,
                type = "toggle",
                get = function() return self.db.profile.timestamps end,
                set = function(_, val)
                    self.db.profile.timestamps = val
                    self.ChatFrame.UpdateAll()
                end,
                order = 3
            },
            urlDetection = {
                name = L.url_detection,
                desc = L.url_detection_desc,
                type = "toggle",
                get = function() return self.db.profile.urlDetection end,
                set = function(_, val)
                    self.db.profile.urlDetection = val
                    self.ChatFrame.UpdateAll()
                end,
                order = 4
            },
            timestampFormat = {
                name = L.timestamp_format,
                desc = L.timestamp_format_desc,
                type = "input",
                get = function() return self.db.profile.timestampFormat end,
                set = function(_, val)
                    self.db.profile.timestampFormat = val
                    self.ChatFrame.UpdateAll()
                end,
                order = 5
            },
        }
    }
end

-- Separate function for creating the "Appearance" configuration group
local function CreateAppearanceOptions(self)
    return {
        name = L.appearance,
        type = "group",
        order = 2,
        args = {
            headerAppearance = {
                name = L.appearance_settings,
                type = "header",
                order = 1
            },
            font = {
                name = L.font,
                type = "select",
                values = {
                    ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata",
                    ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
                    ["Fonts\\MORPHEUS.TTF"] = "Morpheus"
                },
                get = function() return self.db.profile.font end,
                set = function(_, val)
                    self.db.profile.font = val
                    self.ChatFrame.UpdateFonts()
                end,
                order = 2
            },
            fontSize = {
                name = L.font_size,
                type = "range",
                min = 8,
                max = 24,
                step = 1,
                get = function() return self.db.profile.fontSize end,
                set = function(_, val)
                    self.db.profile.fontSize = val
                    self.ChatFrame.UpdateFonts()
                end,
                order = 3
            },
            enableNotifications = {
                name = L.enable_notifications,
                type = "toggle",
                get = function() return self.db.profile.enableNotifications end,
                set = function(_, val)
                    self.db.profile.enableNotifications = val
                end,
                order = 4
            },
        }
    }
end

-- Main function to assemble the configuration options
local function GetOptions(self)
    return {
        name = "SleekChat",
        type = "group",
        args = {
            general = CreateGeneralOptions(self),
            appearance = CreateAppearanceOptions(self)
        }
    }
end

function Config.Initialize(self)
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    AceConfig:RegisterOptionsTable("SleekChat", GetOptions(self))
    AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")
end
