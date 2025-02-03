local _, addon= ...
addon.AdvancedMessaging={}
local AdvancedMessaging= addon.AdvancedMessaging

function AdvancedMessaging:ProcessOutgoing(text,channel,sender)
    -- e.g. replace emotes or highlight @someone
    return text
end

function AdvancedMessaging:ProcessIncoming(text, sender, channel)
    return text
end

function AdvancedMessaging:SwitchChannel(channel)
    -- if you want to do special logic on channel switch
end

return AdvancedMessaging
