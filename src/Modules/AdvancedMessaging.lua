-- Modules/AdvancedMessaging.lua
local _, addon = ...
addon.AdvancedMessaging = {}
local AdvancedMessaging = addon.AdvancedMessaging

function AdvancedMessaging:ProcessOutgoing(text, channel, sender)
    -- Replace emotes, highlights, etc.
    return text
end

function AdvancedMessaging:ProcessIncoming(text, sender, channel)
    text = text:gsub("(%S+)://(%S+)", "|Hurl:%1://%2|h[Link]|h")
    local playerName = UnitName("player")
    text = text:gsub("@" .. playerName, "|cffff0000@%0|r")
    local emojis = { [":)"] = "Interface\\AddOns\\SleekChat\\emojis\\smile" }
    for k, v in pairs(emojis) do
        text = text:gsub(k, "|T" .. v .. ":16|t")
    end
    return text
end

function AdvancedMessaging:IsMentioned(text)
    return text:lower():find("@" .. UnitName("player"):lower())
end

function AdvancedMessaging:SwitchChannel(channel)
    -- Special logic on channel switch can be added here.
end

return AdvancedMessaging
