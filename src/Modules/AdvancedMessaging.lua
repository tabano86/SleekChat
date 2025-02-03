local _, addon = ...
addon.AdvancedMessaging = {}
local AdvancedMessaging = addon.AdvancedMessaging

function AdvancedMessaging:ProcessOutgoing(text, channel, sender)
    -- e.g. replace :smile: with an icon,
    -- or highlight "@User" in orange
    return text
end

function AdvancedMessaging:ProcessIncoming(text, sender, channel)
    -- do same expansions. Or mention detection
    return text
end

function AdvancedMessaging:SwitchChannel(channel)
    -- if you track advanced state for that channel
end

return AdvancedMessaging
