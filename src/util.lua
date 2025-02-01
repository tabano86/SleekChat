-- util.lua
-- A collection of small helper functions for SleekChat.

local Util = {}

--- Removes leading and trailing whitespace from a string.
-- @param s The input string to trim.
-- @return The string without leading/trailing whitespace.
function Util.trim(s)
if type(s) ~= "string" then return "" end
return s:match("^%s*(.-)%s*$") or ""
end

--- Colorizes text using a color table with r, g, b fields (0 – 1).
-- @param color A table containing .r, .g, .b in [0, 1].
-- @param text The text to be colored.
-- @return The text wrapped in a hexadecimal color code string.
function Util.ColorizeHex(color, text)
-- Fallbacks if color is invalid or missing.
local r = (type(color) == "table" and color.r) or 1
local g = color.g or 1
local b = color.b or 1

return string.format("|cff%02x%02x%02x%s|r",
math.floor(r * 255),
math.floor(g * 255),
math.floor(b * 255),
text or ""
)
end

--- Checks if a string is empty or nil.
-- @param s The string to check.
-- @return true if empty or nil, false otherwise.
function Util.isEmpty(s)
return not s or s == ""
end

--- Splits a string into a table of substrings based on a delimiter.
-- @param s The string to split.
-- @param delimiter The pattern or character to split on.
-- @return A table of split substrings.
function Util.split(s, delimiter)
local result = {}
if type(s) ~= "string" or s == "" then
return result
end
delimiter = delimiter or "%s"
for match in s:gmatch("([^" .. delimiter .. "]+)") do
table.insert(result, match)
end
return result
end

-- Make the utility table available on the global SleekChat namespace
SleekChat = SleekChat or {}
SleekChat.Util = Util
