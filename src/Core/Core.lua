local _, addon = ...
local AceLocale= LibStub("AceLocale-3.0")
local L= AceLocale:GetLocale("SleekChat",true)

addon.Core={}
local Core= addon.Core

function Core.GetDefaults()
    return {
        profile= {
            version=10,
            showDefaultChat= false,
            debug= false,
            tabOrientation = "Horizontal",
            enablePinning = true,
            unreadCounts = {},
            mentionKeywords = { "@" .. UnitName("player") },

            -- Chat window settings
            position= { point="BOTTOMLEFT", relPoint="BOTTOMLEFT", x=50,y=50 },
            width= 600,
            height= 400,
            backgroundOpacity= 0.8,
            darkMode= false,

            -- Timestamps
            timestamps= true,
            timestampFormat= "[%H:%M]",
            enablePinning= true,
            enableEmotes= false,
            historySize= 2000,

            -- Channels toggles
            channels= {},
            font= "Friz Quadrata",
            fontSize= 12,
            scrollSpeed= 3,

            -- Notifications
            enableNotifications= true,
            notificationSound= "None",
            soundVolume=1.0,
            flashTaskbar= false,

            -- Mute list
            profanityFilter= false,
            muteList= {},

            -- Combat fade
            autoHideInCombat= false,

            -- We store lines here
            messageHistory= {},

            -- Tab system
            tabs= {},  -- We'll store user-specified tab filters
        },
    }
end

local function SetupStaticPopup()
    StaticPopupDialogs["SLEEKCHAT_URL_DIALOG"]= {
        text= L.open_url_dialog or "Open URL:",
        button1= L.open or "Open",
        button2= L.cancel or "Cancel",
        OnAccept= function(self, data)
            if data and data.url then
                if ChatFrame_OpenBrowser then
                    ChatFrame_OpenBrowser(data.url)
                else
                    EditBox_CopyTextToClipboard(data.url)
                end
            end
        end,
        timeout=0,
        whileDead= true,
        hideOnEscape= true,
        hasEditBox= false,
        preferIndex=3,
    }
end

local function ApplyMigrations(addonObj)
    if addonObj.db.profile.version <10 then
        if not addonObj.db.profile.messageHistory then
            addonObj.db.profile.messageHistory= {}
        end
        addonObj.db.profile.version=10
    end
end

local function RegisterCommands(addonObj)
    addonObj:RegisterChatCommand("scstatus", function()
        addonObj:Print("SleekChat Status:")
        addonObj:Print("Debug: "..(addonObj.db.profile.debug and "ON" or "OFF"))
        addonObj:Print("Default Chat: "..(addonObj.db.profile.showDefaultChat and "Visible" or "Hidden"))
    end)
end

function Core:Initialize(addonObj)
    if not addonObj.db then
        error("DB not ready!")
        return
    end
    SetupStaticPopup()
    ApplyMigrations(addonObj)
    RegisterCommands(addonObj)
end

function Core:ShowConfig()
    LibStub("AceConfigDialog-3.0"):Open("SleekChat")
end

return Core
