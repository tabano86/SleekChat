local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")

addon.Config = {}
local Config = addon.Config

local function GetOptions(self)
    return {
        name = "SleekChat",
        type = "group",
        args = {
            general = {
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
                }
            },
            appearance = {
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
                        set = function(_, val) self.db.profile.enableNotifications = val end,
                        order = 4
                    },
                }
            }
        }
    }
end

function Config.Initialize(self)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("SleekChat", GetOptions(self))
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SleekChat", "SleekChat")
end
