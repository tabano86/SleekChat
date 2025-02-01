-- util.lua
-- Utility module: helper functions and a singleton factory

local Util = {}

-- Singleton factory function.
-- Usage: local Module = Util.singleton("ModuleName", function() ... return moduleInstance end)
function Util.singleton(name, creator)
    if not _G.SleekChat then _G.SleekChat = {} end
    if not _G.SleekChat[name] then
        _G.SleekChat[name] = creator()
    end
    return _G.SleekChat[name]
end

-- Trims leading and trailing whitespace from a string.
function Util.trim(s)
    if type(s) ~= "string" then return "" end
    return s:match("^%s*(.-)%s*$") or ""
end

-- Colorizes text using a hexadecimal color code.
function Util.ColorizeHex(color, text)
    local r = (type(color) == "table" and color.r) or 1
    local g = color.g or 1
    local b = color.b or 1
    return string.format("|cff%02x%02x%02x%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), text or "")
end

-- Checks if a string is empty or nil.
function Util.isEmpty(s)
    return not s or s == ""
end

-- Splits a string into a table of substrings based on a delimiter.
function Util.split(s, delimiter)
    local result = {}
    if type(s) ~= "string" or s == "" then return result end
    delimiter = delimiter or "%s"
    for match in s:gmatch("([^" .. delimiter .. "]+)") do
        table.insert(result, match)
    end
    return result
end

return Util
