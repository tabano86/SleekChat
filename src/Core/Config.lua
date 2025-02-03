local _, addon = ...
local AceLocale= LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true)
local SM = LibStub("LibSharedMedia-3.0")

addon.Config={}
local Config= addon.Config

local function CreateGeneralOptions(addonObj)
    return {
        name = L.general_settings,
        type = "group",
        args = {
            showDefaultChat = {
                name = L.show_default_chat,
                desc = L.show_default_chat_desc,
                type = "toggle",
                order = 1,
                get = function() return addonObj.db.profile.showDefaultChat end,
                set = function(_, val)
                    addonObj.db.profile.showDefaultChat = val
                    addonObj:UpdateChatVisibility()
                end,
            },
            debugMode= {
                name = L.debug_mode,
                desc = L.debug_mode_desc,
                type = "toggle",
                order = 2,
                get = function() return addonObj.db.profile.debug end,
                set = function(_, val)
                    addonObj.db.profile.debug = val
                    addonObj:Print(val and L.debug_enabled or L.debug_disabled)
                end,
            },
            timestamps= {
                name = L.timestamps,
                desc = L.timestamps_desc,
                type = "toggle",
                order= 3,
                get = function() return addonObj.db.profile.timestamps end,
                set = function(_, val)
                    addonObj.db.profile.timestamps = val
                end,
            },
            timestampFormat= {
                name= L.timestamp_format,
                desc= L.timestamp_format_desc,
                type= "input",
                order= 4,
                get= function() return addonObj.db.profile.timestampFormat end,
                set= function(_, val)
                    if pcall(date, val) then
                        addonObj.db.profile.timestampFormat = val
                    else
                        addonObj:Print(L.invalid_format)
                    end
                end,
            },
            storeCombat= {
                name= "Store Combat Logs",
                desc= "Capture combat logs in the custom chat (somewhat verbose).",
                type= "toggle",
                order=5,
                get= function() return addonObj.db.profile.storeCombat end,
                set= function(_, val) addonObj.db.profile.storeCombat= val end,
            },
            storeSystem= {
                name= "Store System Logs",
                desc= "Capture system messages in the custom chat.",
                type= "toggle",
                order=6,
                get= function() return addonObj.db.profile.storeSystem end,
                set= function(_, val) addonObj.db.profile.storeSystem= val end,
            },
            autoHideInCombat= {
                name= "Auto-Hide In Combat",
                type= "toggle",
                order=7,
                get= function() return addonObj.db.profile.autoHideInCombat end,
                set= function(_, val) addonObj.db.profile.autoHideInCombat= val end,
            },
            tabOrientation = {
                name = "Tab Layout",
                desc = "Arrange tabs vertically or horizontally",
                type = "select",
                order = 8,
                values = { Vertical = "Vertical", Horizontal = "Horizontal" },
                get = function() return addonObj.db.profile.tabOrientation end,
                set = function(_, val)
                    addonObj.db.profile.tabOrientation = val
                    addonObj.ChatTabs:UpdateTabLayout()
                end,
            },
            enablePinning = {
                name = "Enable Message Pinning",
                type = "toggle",
                order = 9,
                get = function() return addonObj.db.profile.enablePinning end,
                set = function(_, val) addonObj.db.profile.enablePinning = val end,
            },
        },
    }
end

local function CreateAppearanceOptions(addonObj)
    return {
        name= L.appearance_settings,
        type= "group",
        args= {
            darkMode= {
                name= L.dark_mode,
                desc= L.dark_mode_desc,
                type= "toggle",
                order=1,
                get= function() return addonObj.db.profile.darkMode end,
                set= function(_, val)
                    addonObj.db.profile.darkMode= val
                    if addonObj.ChatFrame then addonObj.ChatFrame:ApplyTheme() end
                end,
            },
            backgroundOpacity= {
                name= L.background_opacity,
                desc= L.background_opacity_desc,
                type= "range",
                order=2,
                min=0, max=1, step=0.05,
                get= function() return addonObj.db.profile.backgroundOpacity end,
                set= function(_, val)
                    addonObj.db.profile.backgroundOpacity= val
                    if addonObj.ChatFrame then addonObj.ChatFrame:ApplyTheme() end
                end,
            },
            font= {
                name= L.font,
                type= "select",
                dialogControl= "LSM30_Font",
                order=3,
                values= SM:HashTable("font"),
                get= function() return addonObj.db.profile.font end,
                set= function(_, val)
                    addonObj.db.profile.font= val
                    if addonObj.ChatFrame and addonObj.ChatFrame.SetChatFont then
                        addonObj.ChatFrame:SetChatFont()
                    end
                end,
            },
            fontSize= {
                name= L.font_size,
                type= "range",
                order=4,
                min=8, max=24, step=1,
                get= function() return addonObj.db.profile.fontSize end,
                set= function(_, val)
                    addonObj.db.profile.fontSize= val
                    if addonObj.ChatFrame and addonObj.ChatFrame.SetChatFont then
                        addonObj.ChatFrame:SetChatFont()
                    end
                end,
            },
        },
    }
end

local function CreateNotificationsOptions(addonObj)
    return {
        name= L.notifications_settings,
        type= "group",
        args= {
            enableNotifications= {
                name= L.enable_notifications,
                type= "toggle",
                order=1,
                get= function() return addonObj.db.profile.enableNotifications end,
                set= function(_, val) addonObj.db.profile.enableNotifications= val end,
            },
            notificationSound= {
                name= L.notification_sound,
                desc= L.notification_sound_desc,
                type= "select",
                dialogControl= "LSM30_Sound",
                order=2,
                values= SM:HashTable("sound"),
                get= function() return addonObj.db.profile.notificationSound end,
                set= function(_, val)
                    addonObj.db.profile.notificationSound= val
                    if val~="None" then
                        PlaySoundFile(SM:Fetch("sound", val))
                    end
                end,
            },
            soundVolume= {
                name= L.sound_volume,
                desc= L.sound_volume_desc,
                type= "range",
                order=3,
                min=0, max=1, step=0.1,
                get= function() return addonObj.db.profile.soundVolume end,
                set= function(_, val)
                    addonObj.db.profile.soundVolume= val
                end,
            },
            flashTaskbar= {
                name= L.flash_taskbar,
                desc= L.flash_taskbar_desc,
                type= "toggle",
                order=4,
                get= function() return addonObj.db.profile.flashTaskbar end,
                set= function(_, val) addonObj.db.profile.flashTaskbar= val end,
            },
        },
    }
end

local function GetOptions(addonObj)
    return {
        name= "SleekChat",
        type= "group",
        childGroups= "tab",
        args= {
            general= {
                name= L.general_settings,
                type= "group",
                order=1,
                args= CreateGeneralOptions(addonObj).args,
            },
            appearance= {
                name= L.appearance_settings,
                type= "group",
                order=2,
                args= CreateAppearanceOptions(addonObj).args,
            },
            notifications= {
                name= L.notifications_settings,
                type= "group",
                order=3,
                args= CreateNotificationsOptions(addonObj).args,
            },
        },
    }
end

function Config:Initialize(addonObj)
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    -- Create scrollable options container
    local optionsFrame = CreateFrame("Frame", "SleekChatOptions", UIParent, "BasicFrameTemplateWithInset")
    optionsFrame:SetSize(600, 500)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:Hide()

    local scrollFrame = CreateFrame("ScrollFrame", nil, optionsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 4, -28)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 4)

    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(550, 800)

    AceConfig:RegisterOptionsTable("SleekChat", GetOptions(addonObj))
    AceConfigDialog:SetDefaultSize("SleekChat", 600, 500)
    AceConfigDialog:Open("SleekChat", scrollChild)

    -- Custom close button
    optionsFrame.closeBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
    optionsFrame.closeBtn:SetPoint("TOPRIGHT", -4, -4)
    optionsFrame.closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

    addonObj.ShowConfig = function()
        optionsFrame:Show()
        scrollFrame:SetVerticalScroll(0)
    end
end

return Config
