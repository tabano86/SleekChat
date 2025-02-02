local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.Config = {}
local Config = addon.Config

local function CreateGeneralOptions(addonObj)
    return {
        name = L.general,
        type = "group",
        order = 1,
        args = {
            headerGeneral = {
                name = L.general_settings,
                type = "header",
                order = 1,
            },
            classColors = {
                name = L.class_colors,
                desc = L.class_colors_desc,
                type = "toggle",
                order = 2,
                get = function() return addonObj.db.profile.classColors end,
                set = function(_, val)
                    addonObj.db.profile.classColors = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateAll then
                        addonObj.ChatFrame:UpdateAll()
                    end
                end,
            },
            timestamps = {
                name = L.timestamps,
                desc = L.timestamps_desc,
                type = "toggle",
                order = 3,
                get = function() return addonObj.db.profile.timestamps end,
                set = function(_, val)
                    addonObj.db.profile.timestamps = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateAll then
                        addonObj.ChatFrame:UpdateAll()
                    end
                end,
            },
            timestampFormat = {
                name = L.timestamp_format,
                desc = L.timestamp_format_desc,
                type = "input",
                order = 4,
                get = function() return addonObj.db.profile.timestampFormat end,
                set = function(_, val)
                    if pcall(date, val) then
                        addonObj.db.profile.timestampFormat = val
                        if addonObj.ChatFrame and addonObj.ChatFrame.UpdateAll then
                            addonObj.ChatFrame:UpdateAll()
                        end
                    else
                        addonObj:Print(L.invalid_format)
                    end
                end,
            },
            urlDetection = {
                name = L.url_detection,
                desc = L.url_detection_desc,
                type = "toggle",
                order = 5,
                get = function() return addonObj.db.profile.urlDetection end,
                set = function(_, val)
                    addonObj.db.profile.urlDetection = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateAll then
                        addonObj.ChatFrame:UpdateAll()
                    end
                end,
            },
            maxHistory = {
                name = L.max_history_messages,
                desc = L.max_history_messages_desc,
                type = "range",
                order = 6,
                min = 100,
                max = 5000,
                step = 100,
                get = function() return addonObj.db.profile.historySize end,
                set = function(_, val)
                    addonObj.db.profile.historySize = val
                    if addonObj.History and addonObj.History.UpdateMaxSize then
                        addonObj.History:UpdateMaxSize(val)
                    end
                end,
            },
            layout = {
                name = L.layout,
                desc = L.layout_desc,
                type = "select",
                order = 7,
                values = {
                    CLASSIC = L.layout_classic,
                    TRANSPOSED = L.layout_transposed,
                },
                get = function() return addonObj.db.profile.layout end,
                set = function(_, val)
                    addonObj.db.profile.layout = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.ApplyLayout then
                        addonObj.ChatFrame:ApplyLayout()
                    end
                end,
            },
        },
    }
end

local function CreateAppearanceOptions(addonObj)
    return {
        name = L.appearance,
        type = "group",
        order = 2,
        args = {
            headerAppearance = {
                name = L.appearance_settings,
                type = "header",
                order = 1,
            },
            font = {
                name = L.font,
                type = "select",
                dialogControl = "LSM30_Font",
                order = 2,
                values = SM:HashTable("font"),
                get = function() return addonObj.db.profile.font end,
                set = function(_, val)
                    addonObj.db.profile.font = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateFonts then
                        addonObj.ChatFrame:UpdateFonts()
                    end
                end,
            },
            fontSize = {
                name = L.font_size,
                type = "range",
                order = 3,
                min = 8,
                max = 24,
                step = 1,
                get = function() return addonObj.db.profile.fontSize end,
                set = function(_, val)
                    addonObj.db.profile.fontSize = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateFonts then
                        addonObj.ChatFrame:UpdateFonts()
                    end
                end,
            },
            backgroundOpacity = {
                name = L.background_opacity,
                desc = L.background_opacity_desc,
                type = "range",
                order = 4,
                min = 0,
                max = 1,
                step = 0.1,
                get = function() return addonObj.db.profile.backgroundOpacity end,
                set = function(_, val)
                    addonObj.db.profile.backgroundOpacity = val
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateBackground then
                        addonObj.ChatFrame:UpdateBackground()
                    end
                end,
            },
            tabUnreadHighlight = {
                name = L.tab_unread_highlight,
                desc = L.tab_unread_highlight_desc,
                type = "toggle",
                order = 5,
                get = function() return addonObj.db.profile.tabUnreadHighlight end,
                set = function(_, val)
                    addonObj.db.profile.tabUnreadHighlight = val
                end,
            },
            debugMode = {
                name = L.debug_mode,
                desc = L.debug_mode_desc,
                type = "toggle",
                order = 6,
                get = function() return addonObj.db.profile.debug end,
                set = function(_, val)
                    addonObj.db.profile.debug = val
                    addonObj:Print(val and L.debug_enabled or L.debug_disabled)
                end,
            },
            showDefaultChat = {
                name = L.show_default_chat,
                desc = L.show_default_chat_desc,
                type = "toggle",
                order = 8,
                get = function() return addonObj.db.profile.showDefaultChat end,
                set = function(_, val)
                    addonObj.db.profile.showDefaultChat = val
                    addonObj:UpdateChatVisibility()
                    addonObj:Print(val and L.default_chat_visible or L.default_chat_hidden)
                end,
            },
        },
    }
end

local function CreateNotificationOptions(addonObj)
    return {
        name = L.notifications,
        type = "group",
        order = 3,
        args = {
            headerNotifications = {
                name = L.notifications_settings,
                type = "header",
                order = 1,
            },
            enableNotifications = {
                name = L.enable_notifications,
                type = "toggle",
                order = 2,
                get = function() return addonObj.db.profile.enableNotifications end,
                set = function(_, val)
                    addonObj.db.profile.enableNotifications = val
                end,
            },
            notificationSound = {
                name = L.notification_sound,
                desc = L.notification_sound_desc,
                type = "select",
                dialogControl = "LSM30_Sound",
                order = 3,
                values = SM:HashTable("sound"),
                get = function() return addonObj.db.profile.notificationSound end,
                set = function(_, val)
                    addonObj.db.profile.notificationSound = val
                    if val ~= "None" then
                        PlaySoundFile(SM:Fetch("sound", val))
                    end
                end,
            },
            soundVolume = {
                name = L.sound_volume,
                desc = L.sound_volume_desc,
                type = "range",
                order = 4,
                min = 0,
                max = 1,
                step = 0.1,
                get = function() return addonObj.db.profile.soundVolume end,
                set = function(_, val)
                    addonObj.db.profile.soundVolume = val
                    if addonObj.db.profile.notificationSound ~= "None" then
                        PlaySoundFile(SM:Fetch("sound", addonObj.db.profile.notificationSound), "Master", val)
                    end
                end,
            },
            flashTaskbar = {
                name = L.flash_taskbar,
                desc = L.flash_taskbar_desc,
                type = "toggle",
                order = 5,
                get = function() return addonObj.db.profile.flashTaskbar end,
                set = function(_, val)
                    addonObj.db.profile.flashTaskbar = val
                end,
            },
        },
    }
end

local function GetOptions(addonObj)
    return {
        name = "SleekChat",
        type = "group",
        childGroups = "tab",
        args = {
            general = CreateGeneralOptions(addonObj),
            appearance = CreateAppearanceOptions(addonObj),
            notifications = CreateNotificationOptions(addonObj),
        },
    }
end

function Config:Initialize(addonObj)
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    AceConfig:RegisterOptionsTable("SleekChat", GetOptions(addonObj))
    AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")
    addonObj:RegisterChatCommand("screset", function()
        addonObj.db:ResetProfile()
        addonObj:Print(L.settings_reset)
    end)
end

return Config
