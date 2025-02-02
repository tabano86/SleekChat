-- util.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Util and _G.SleekChat.Util._loaded then return end
_G.SleekChat.Util = _G.SleekChat.Util or {}
local Util = _G.SleekChat.Util
local Logger = _G.SleekChat.Logger

Logger:Debug("Util Loading...")

function Util.singleton(name, creator)
    if _G.SleekChat[name] then
        Logger:Debug(("singleton: returning existing instance for '%s'"):format(name))
        return _G.SleekChat[name]
    else
        Logger:Debug(("singleton: creating new instance for '%s'"):format(name))
        local instance = creator()
        _G.SleekChat[name] = instance
        return instance
    end
end

function Util.trim(s)
    if type(s) ~= "string" then return "" end
    return s:match("^%s*(.-)%s*$") or ""
end

function Util.ColorizeHex(color, text)
    local r = (type(color) == "table" and color.r) or 1
    local g = color.g or 1
    local b = color.b or 1
    return string.format("|cff%02x%02x%02x%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), text or "")
end

function Util.isEmpty(s)
    return not s or s == ""
end

function Util.split(s, delimiter)
    local result = {}
    if type(s) ~= "string" or s == "" then return result end
    delimiter = delimiter or "%s"
    for match in s:gmatch("([^" .. delimiter .. "]+)") do
        table.insert(result, match)
    end
    return result
end

Logger:Debug("Util Loaded!")
Util._loaded = true
local registry = _G.SleekChat.Modules
registry:register("Util", Util)
