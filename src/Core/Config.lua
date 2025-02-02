local _, addon = ...
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.Config = {}
local Config = addon.Config

-- General options
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
                    if addonObj.ChatFrame then addonObj.ChatFrame:UpdateAll() end
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
                    if addonObj.ChatFrame then addonObj.ChatFrame:UpdateAll() end
                end,
            },
            timestampFormat = {
                name = L.timestamp_format,
                desc = L.timestamp_format_desc,
                type = "input",
                order = 4,
                get = function() return addonObj.db.profile.timestampFormat end,
                set = function(_, val)
                    -- Validate Lua date format
                    if pcall(date, val) then
                        addonObj.db.profile.timestampFormat = val
                        if addonObj.ChatFrame then addonObj.ChatFrame:UpdateAll() end
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
                    if addonObj.ChatFrame then addonObj.ChatFrame:UpdateAll() end
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
                    if addonObj.History then addonObj.History:UpdateMaxSize(val) end
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
            showDefaultChat = {
                name = L.show_default_chat,
                desc = L.show_default_chat_desc,
                type = "toggle",
                order = 8,
                get = function() return addonObj.db.profile.showDefaultChat end,
                set = function(_, val)
                    addonObj.db.profile.showDefaultChat = val
                    addonObj:UpdateChatVisibility()
                end,
            },
            debugMode = {
                name = L.debug_mode,
                desc = L.debug_mode_desc,
                type = "toggle",
                order = 9,
                get = function() return addonObj.db.profile.debug end,
                set = function(_, val)
                    addonObj.db.profile.debug = val
                    addonObj:Print(val and L.debug_enabled or L.debug_disabled)
                end,
            },
            enablePinning = {
                name = "Enable Pinning",
                desc = "Allow pinning of important channels",
                type = "toggle",
                order = 10,
                get = function() return addonObj.db.profile.enablePinning end,
                set = function(_, val) addonObj.db.profile.enablePinning = val end,
            },
            enableAutoComplete = {
                name = "Enable Auto-Complete",
                desc = "Provides auto-completion for slash commands",
                type = "toggle",
                order = 11,
                get = function() return addonObj.db.profile.enableAutoComplete end,
                set = function(_, val) addonObj.db.profile.enableAutoComplete = val end,
            },
            scrollSpeed = {
                name = "Scroll Speed",
                desc = "Adjust message frame scroll speed",
                type = "range",
                order = 12,
                min = 1,
                max = 10,
                step = 1,
                get = function() return addonObj.db.profile.scrollSpeed or 3 end,
                set = function(_, val) addonObj.db.profile.scrollSpeed = val end,
            },
            customFontColor = {
                name = "Custom Font Color",
                desc = "Override class colors with a fixed color",
                type = "color",
                order = 13,
                get = function() return unpack(addonObj.db.profile.customFontColor or {1,1,1,1}) end,
                set = function(_, r, g, b, a)
                    addonObj.db.profile.customFontColor = { r, g, b, a }
                    if addonObj.ChatFrame then addonObj.ChatFrame:UpdateAll() end
                end,
            },
            enableEmotes = {
                name = "Enable Emotes",
                desc = "Convert emote shorthand into icons",
                type = "toggle",
                order = 14,
                get = function() return addonObj.db.profile.enableEmotes end,
                set = function(_, val) addonObj.db.profile.enableEmotes = val end,
            },
            hideTimestamp = {
                name = "Hide Timestamps",
                desc = "Disable timestamps in messages",
                type = "toggle",
                order = 15,
                get = function() return not addonObj.db.profile.timestamps end,
                set = function(_, val)
                    addonObj.db.profile.timestamps = not val
                    if addonObj.ChatFrame then addonObj.ChatFrame:UpdateAll() end
                end,
            },
            sidebarEnabled = {
                name = "Enable Sidebar",
                desc = "Show a collapsible sidebar for conversations",
                type = "toggle",
                order = 16,
                get = function() return addonObj.db.profile.sidebarEnabled end,
                set = function(_, val) addonObj.db.profile.sidebarEnabled = val end,
            },
            threadedReplies = {
                name = "Threaded Replies",
                desc = "Enable threaded message replies (stub for future)",
                type = "toggle",
                order = 17,
                get = function() return addonObj.db.profile.threadedReplies end,
                set = function(_, val) addonObj.db.profile.threadedReplies = val end,
            },
            darkMode = {
                name = "Dark Mode",
                desc = "Toggle a dark theme for the chat window",
                type = "toggle",
                order = 18,
                get = function() return addonObj.db.profile.darkMode end,
                set = function(_, val)
                    addonObj.db.profile.darkMode = val
                    if addonObj.ChatFrame then addonObj.ChatFrame:ApplyTheme() end
                end,
            },
            profanityFilter = {
                name = "Profanity Filter",
                desc = "Filter offensive words",
                type = "toggle",
                order = 19,
                get = function() return addonObj.db.profile.profanityFilter end,
                set = function(_, val) addonObj.db.profile.profanityFilter = val end,
            },
            muteList = {
                name = "Mute List",
                desc = "Comma-separated list of players to mute",
                type = "input",
                order = 20,
                get = function()
                    return table.concat(addonObj.db.profile.muteList or {}, ", ")
                end,
                set = function(_, val)
                    local t = {}
                    for word in val:gmatch("([^,]+)") do
                        t[#t+1] = word:gsub("^%s*(.-)%s*$", "%1")
                    end
                    addonObj.db.profile.muteList = t
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
            customFontColor = {
                name = "Custom Font Color",
                desc = "Override class colors with a fixed color",
                type = "color",
                order = 5,
                get = function() return unpack(addonObj.db.profile.customFontColor or {1,1,1,1}) end,
                set = function(_, r, g, b, a)
                    addonObj.db.profile.customFontColor = { r, g, b, a }
                    if addonObj.ChatFrame and addonObj.ChatFrame.UpdateAll then
                        addonObj.ChatFrame:UpdateAll()
                    end
                end,
            },
            enableEmotes = {
                name = "Enable Emotes",
                desc = "Convert emote shorthand to icons",
                type = "toggle",
                order = 6,
                get = function() return addonObj.db.profile.enableEmotes end,
                set = function(_, val)
                    addonObj.db.profile.enableEmotes = val
                end,
            },
        },
    }
end

local function CreateTabManagementOptions(addonObj)
    return {
        name = "Tab Management",
        type = "group",
        order = 4,
        args = {
            customTabOrder = {
                name = "Custom Tab Order",
                desc = "Allow tabs to be rearranged by dragging",
                type = "toggle",
                order = 1,
                get = function() return addonObj.db.profile.customTabOrder end,
                set = function(_, val) addonObj.db.profile.customTabOrder = val end,
            },
            tabRenaming = {
                name = "Tab Renaming",
                desc = "Allow users to rename tabs",
                type = "toggle",
                order = 2,
                get = function() return addonObj.db.profile.tabRenaming end,
                set = function(_, val) addonObj.db.profile.tabRenaming = val end,
            },
            autoCollapseTabs = {
                name = "Auto-Collapse Inactive Tabs",
                desc = "Automatically collapse tabs after inactivity",
                type = "toggle",
                order = 3,
                get = function() return addonObj.db.profile.autoCollapseTabs end,
                set = function(_, val) addonObj.db.profile.autoCollapseTabs = val end,
            },
            tabColorCustomization = {
                name = "Tab Color Customization",
                desc = "Customize tab background/text colors",
                type = "color",
                order = 4,
                get = function() return unpack(addonObj.db.profile.tabColor or {0.2, 0.2, 0.2, 0.8}) end,
                set = function(_, r, g, b, a)
                    addonObj.db.profile.tabColor = { r, g, b, a }
                end,
            },
            unreadBadge = {
                name = "Unread Message Badge",
                desc = "Show unread count on tabs",
                type = "toggle",
                order = 5,
                get = function() return addonObj.db.profile.unreadBadge end,
                set = function(_, val) addonObj.db.profile.unreadBadge = val end,
            },
            tabTooltips = {
                name = "Tab Tooltips",
                desc = "Display tooltips with a message preview",
                type = "toggle",
                order = 6,
                get = function() return addonObj.db.profile.tabTooltips end,
                set = function(_, val) addonObj.db.profile.tabTooltips = val end,
            },
            tabLocking = {
                name = "Tab Locking/Pinning",
                desc = "Allow locking/pinning important tabs",
                type = "toggle",
                order = 7,
                get = function() return addonObj.db.profile.tabLocking end,
                set = function(_, val) addonObj.db.profile.tabLocking = val end,
            },
            smartTabGrouping = {
                name = "Smart Tab Grouping",
                desc = "Group similar tabs (e.g. whispers) together",
                type = "toggle",
                order = 8,
                get = function() return addonObj.db.profile.smartTabGrouping end,
                set = function(_, val) addonObj.db.profile.smartTabGrouping = val end,
            },
            dynamicTabScrolling = {
                name = "Dynamic Tab Scrolling",
                desc = "Enable horizontal scrolling when too many tabs exist",
                type = "toggle",
                order = 9,
                get = function() return addonObj.db.profile.dynamicTabScrolling end,
                set = function(_, val) addonObj.db.profile.dynamicTabScrolling = val end,
            },
            tabNotificationSound = {
                name = "Tab Notification Sound",
                desc = "Sound to play for tab notifications",
                type = "select",
                order = 10,
                values = SM:HashTable("sound"),
                get = function() return addonObj.db.profile.tabNotificationSound end,
                set = function(_, val) addonObj.db.profile.tabNotificationSound = val end,
            },
            tabHistoryPreview = {
                name = "Tab History Preview",
                desc = "Show recent message preview on hover",
                type = "toggle",
                order = 11,
                get = function() return addonObj.db.profile.tabHistoryPreview end,
                set = function(_, val) addonObj.db.profile.tabHistoryPreview = val end,
            },
            tabFlashing = {
                name = "Tab Flashing for Mentions",
                desc = "Flash tab when a message mentions you",
                type = "toggle",
                order = 12,
                get = function() return addonObj.db.profile.tabFlashing end,
                set = function(_, val) addonObj.db.profile.tabFlashing = val end,
            },
            tabFontCustomization = {
                name = "Tab Font Customization",
                type = "group",
                order = 13,
                args = {
                    tabFont = {
                        name = "Tab Font",
                        type = "select",
                        dialogControl = "LSM30_Font",
                        order = 1,
                        values = SM:HashTable("font"),
                        get = function() return addonObj.db.profile.tabFont end,
                        set = function(_, val) addonObj.db.profile.tabFont = val end,
                    },
                    tabFontSize = {
                        name = "Tab Font Size",
                        type = "range",
                        order = 2,
                        min = 8,
                        max = 24,
                        step = 1,
                        get = function() return addonObj.db.profile.tabFontSize or 12 end,
                        set = function(_, val) addonObj.db.profile.tabFontSize = val end,
                    },
                },
            },
            autoSwitchTab = {
                name = "Auto-Switch on New Message",
                desc = "Switch to a tab when a new message arrives",
                type = "toggle",
                order = 14,
                get = function() return addonObj.db.profile.autoSwitchTab end,
                set = function(_, val) addonObj.db.profile.autoSwitchTab = val end,
            },
            clearUnreadOnDoubleClick = {
                name = "Clear Unread on Double-Click",
                desc = "Double-click a tab to mark messages as read",
                type = "toggle",
                order = 15,
                get = function() return addonObj.db.profile.clearUnreadOnDoubleClick end,
                set = function(_, val) addonObj.db.profile.clearUnreadOnDoubleClick = val end,
            },
            tabLockIcon = {
                name = "Tab Lock Icon",
                desc = "Show a lock icon on pinned tabs",
                type = "toggle",
                order = 16,
                get = function() return addonObj.db.profile.tabLockIcon end,
                set = function(_, val) addonObj.db.profile.tabLockIcon = val end,
            },
            dragDropFileSupport = {
                name = "Drag & Drop File Support",
                desc = "Allow dragging files/images onto tabs",
                type = "toggle",
                order = 17,
                get = function() return addonObj.db.profile.dragDropFileSupport end,
                set = function(_, val) addonObj.db.profile.dragDropFileSupport = val end,
            },
            customHotkeys = {
                name = "Custom Hotkeys for Tab Switching",
                desc = "Define custom hotkeys to switch tabs",
                type = "input",
                order = 18,
                get = function() return addonObj.db.profile.customHotkeys or "" end,
                set = function(_, val) addonObj.db.profile.customHotkeys = val end,
            },
            tabSessionPersistence = {
                name = "Tab Session Persistence",
                desc = "Remember tab order and state across sessions",
                type = "toggle",
                order = 19,
                get = function() return addonObj.db.profile.tabSessionPersistence end,
                set = function(_, val) addonObj.db.profile.tabSessionPersistence = val end,
            },
            animatedTabTransitions = {
                name = "Animated Tab Transitions",
                desc = "Smooth transitions when switching tabs",
                type = "toggle",
                order = 20,
                get = function() return addonObj.db.profile.animatedTabTransitions end,
                set = function(_, val) addonObj.db.profile.animatedTabTransitions = val end,
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
                set = function(_, val) addonObj.db.profile.enableNotifications = val end,
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
                set = function(_, val) addonObj.db.profile.flashTaskbar = val end,
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
            tabManagement = CreateTabManagementOptions(addonObj),
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
