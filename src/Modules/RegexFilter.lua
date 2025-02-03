-- Modules/RegexFilter.lua
local _, addon = ...
addon.RegexFilter = {}
local RegexFilter = addon.RegexFilter

function RegexFilter:Initialize(addonObj)
    self.db = addonObj.db
end

-- For user-defined regex filters to highlight or block certain patterns
function RegexFilter:ApplyFilters(text)
    local filters = self.db.profile.regexFilters or {}
    -- Example structure: { { pattern="WTS", block=true }, { pattern="LFG", highlight="|cff00ff00$0|r" } }
    for _, rule in ipairs(filters) do
        if rule.block and text:find(rule.pattern) then
            return ""  -- block message
        end
        if rule.highlight then
            text = text:gsub(rule.pattern, rule.highlight)
        end
    end
    return text
end

return RegexFilter
