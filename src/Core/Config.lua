local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("SleekChat")
local SM = LibStub("LibSharedMedia-3.0")

addon.Config = {}
local Config = addon.Config

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
            timestampFormat = {
                name = L.timestamp_format,
                desc = L.timestamp_format_desc,
                type = "input",
                get = function() return self.db.profile.timestampFormat end,
                set = function(_, val)
                    if pcall(date, val) then
                        self.db.profile.timestampFormat = val
                        self.ChatFrame.UpdateAll()
                    else
                        self:Print(L.invalid_format)
                    end
                end,
                order = 4
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
                order = 5
            },
            maxHistory = {
                name = L.max_history_messages,
                desc = L.max_history_messages_desc,
                type = "range",
                min = 100,
                max = 5000,
                step = 100,
                get = function() return self.db.profile.historySize end,
                set = function(_, val)
                    self.db.profile.historySize = val
                    self.History.UpdateMaxSize(val)
                end,
                order = 6
            }
        }
    }
end

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
                dialogControl = 'LSM30_Font',
                values = SM:HashTable("font"),
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
            backgroundOpacity = {
                name = L.background_opacity,
                desc = L.background_opacity_desc,
                type = "range",
                min = 0,
                max = 1,
                step = 0.1,
                get = function() return self.db.profile.backgroundOpacity end,
                set = function(_, val)
                    self.db.profile.backgroundOpacity = val
                    self.ChatFrame.UpdateBackground()
                end,
                order = 4
            },
            tabUnreadHighlight = {
                name = L.tab_unread_highlight,
                desc = L.tab_unread_highlight_desc,
                type = "toggle",
                get = function() return self.db.profile.tabUnreadHighlight end,
                set = function(_, val) self.db.profile.tabUnreadHighlight = val end,
                order = 5
            }
        }
    }
end

local function CreateNotificationOptions(self)
    return {
        name = L.notifications,
        type = "group",
        order = 3,
        args = {
            headerNotifications = {
                name = L.notifications_settings,
                type = "header",
                order = 1
            },
            enableNotifications = {
                name = L.enable_notifications,
                type = "toggle",
                get = function() return self.db.profile.enableNotifications end,
                set = function(_, val) self.db.profile.enableNotifications = val end,
                order = 2
            },
            notificationSound = {
                name = L.notification_sound,
                desc = L.notification_sound_desc,
                type = "select",
                dialogControl = 'LSM30_Sound',
                values = SM:HashTable("sound"),
                get = function() return self.db.profile.notificationSound end,
                set = function(_, val)
                    self.db.profile.notificationSound = val
                    if val ~= "None" then
                        PlaySoundFile(SM:Fetch("sound", val))
                    end
                end,
                order = 3
            },
            soundVolume = {
                name = L.sound_volume,
                desc = L.sound_volume_desc,
                type = "range",
                min = 0,
                max = 1,
                step = 0.1,
                get = function() return self.db.profile.soundVolume end,
                set = function(_, val)
                    self.db.profile.soundVolume = val
                    if self.db.profile.notificationSound ~= "None" then
                        PlaySoundFile(SM:Fetch("sound", self.db.profile.notificationSound), "Master", val)
                    end
                end,
                order = 4
            },
            flashTaskbar = {
                name = L.flash_taskbar,
                desc = L.flash_taskbar_desc,
                type = "toggle",
                get = function() return self.db.profile.flashTaskbar end,
                set = function(_, val) self.db.profile.flashTaskbar = val end,
                order = 5
            }
        }
    }
end

local function GetOptions(self)
    return {
        name = "SleekChat",
        type = "group",
        childGroups = "tab",
        args = {
            general = CreateGeneralOptions(self),
            appearance = CreateAppearanceOptions(self),
            notifications = CreateNotificationOptions(self)
        }
    }
end

function Config.Initialize(self)
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    AceConfig:RegisterOptionsTable("SleekChat", GetOptions(self))
    AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")

    -- Add reset button
    self:RegisterChatCommand("screset", function()
        self.db:ResetProfile()
        self:Print(L.settings_reset)
    end)
end
