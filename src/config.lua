-- config.lua
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Helper functions to reduce duplication in get/set callbacks.
local function getOption(key)
    return function(info)
        return SleekChat.db.profile[key]
    end
end

local function setOption(key, callback)
    return function(info, value, ...)
        SleekChat.db.profile[key] = value
        if callback then callback(value, ...) end
    end
end

local function getColorOption(key)
    return function(info)
        local c = SleekChat.db.profile[key]
        return c.r, c.g, c.b, c.a
    end
end

local function setColorOption(key, callback)
    return function(info, r, g, b, a)
        SleekChat.db.profile[key] = { r = r, g = g, b = b, a = a }
        if callback then callback() end
    end
end

local options = {
    name = "SleekChat",
    handler = SleekChat,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = "General Settings",
            order = 1,
            args = {
                hideDefaultChat = {
                    type = 'toggle',
                    name = "Hide Default Chat",
                    desc = "Hide Blizzard's default chat frames.",
                    order = 1,
                    get = getOption("hideDefaultChat"),
                    set = function(info, value)
                        SleekChat.db.profile.hideDefaultChat = value
                        SleekChat:SetupDefaultUI()
                    end,
                },
                draggableWindow = {
                    type = 'toggle',
                    name = "Draggable Chat Window",
                    desc = "Allow the custom chat window to be moved.",
                    order = 2,
                    get = getOption("draggableWindow"),
                    set = function(info, value)
                        SleekChat.db.profile.draggableWindow = value
                        SleekChatUI:UpdateDraggable()
                    end,
                },
                font = {
                    type = 'input',
                    name = "Font",
                    desc = "Set the chat font.",
                    order = 3,
                    get = getOption("font"),
                    set = function(info, value)
                        SleekChat.db.profile.font = value
                        SleekChatUI:UpdateFontSettings()
                    end,
                },
                fontSize = {
                    type = 'range',
                    name = "Font Size",
                    desc = "Set the chat font size.",
                    order = 4,
                    min = 8, max = 20, step = 1,
                    get = getOption("fontSize"),
                    set = function(info, value)
                        SleekChat.db.profile.fontSize = value
                        SleekChatUI:UpdateFontSettings()
                    end,
                },
                backgroundColor = {
                    type = 'color',
                    name = "Background Color",
                    desc = "Set the chat window background color.",
                    order = 5,
                    hasAlpha = true,
                    get = getColorOption("backgroundColor"),
                    set = function(info, r, g, b, a)
                        SleekChat.db.profile.backgroundColor = { r = r, g = g, b = b, a = a }
                        SleekChatUI:UpdateBackgroundColor()
                    end,
                },
                enableNotifications = {
                    type = 'toggle',
                    name = "Enable Notifications",
                    desc = "Show pop-up notifications for new messages.",
                    order = 6,
                    get = getOption("enableNotifications"),
                    set = setOption("enableNotifications"),
                },
                messageHistorySize = {
                    type = 'range',
                    name = "Message History Size",
                    desc = "Number of messages to store in history.",
                    order = 7,
                    min = 100, max = 2000, step = 50,
                    get = getOption("messageHistorySize"),
                    set = setOption("messageHistorySize"),
                },
                showTimestamps = {
                    type = 'toggle',
                    name = "Show Timestamps",
                    desc = "Display timestamps for each chat message.",
                    order = 8,
                    get = getOption("showTimestamps"),
                    set = function(info, value)
                        SleekChat.db.profile.showTimestamps = value
                        SleekChatUI:RefreshMessages()
                    end,
                },
                debug = {
                    type = 'toggle',
                    name = "Debug Mode",
                    desc = "Enable verbose logging for debugging.",
                    order = 9,
                    get = getOption("debug"),
                    set = function(info, value)
                        SleekChat.db.profile.debug = value
                        SleekChatUtil:Log("Debug mode set to " .. tostring(value), "DEBUG")
                    end,
                },
            },
        },
    },
}

AceConfig:RegisterOptionsTable("SleekChat", options)
AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")
