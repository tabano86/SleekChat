-- util.lua
-- Utility module with pure helper functions.
local Util = {}

function Util.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function Util.ColorizeHex(color, text)
    return string.format("|cff%02x%02x%02x%s|r",
            math.floor(color.r * 255),
            math.floor(color.g * 255),
            math.floor(color.b * 255),
            text)
end

SleekChat = SleekChat or {}
SleekChat.Util = Util
