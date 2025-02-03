local _, addon= ...
addon.AdvancedMessaging={}
local AdvancedMessaging= addon.AdvancedMessaging

function AdvancedMessaging:ProcessOutgoing(text,channel,sender)
    -- e.g. replace emotes or highlight @someone
    return text
end

function AdvancedMessaging:ProcessIncoming(text, sender, channel)
    -- URL detection
    text = text:gsub("(%S+)://(%S+)", "|Hurl:%1://%2|h[Link]|h")

    -- Mention detection
    local playerName = UnitName("player")
    text = text:gsub("@" .. playerName, "|cffff0000@%0|r")

    -- Emoji replacement
    local emojis = { [":)"] = "Interface\\AddOns\\SleekChat\\emojis\\smile" }
    for k,v in pairs(emojis) do
        text = text:gsub(k, "|T"..v..":16|t")
    end

    return text
end

function AdvancedMessaging:IsMentioned(text)
    return text:lower():find("@" .. UnitName("player"):lower())
end

function AdvancedMessaging:SwitchChannel(channel)
    -- if you want to do special logic on channel switch
end

return AdvancedMessaging
