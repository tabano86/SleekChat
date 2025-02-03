local _, addon = ...
addon.History = {}
local History = addon.History

local function EnsureChannelTableExists(db, channel)
    if not db.profile.messageHistory[channel] then
        db.profile.messageHistory[channel] = {}
    end
end

function History:Initialize(addonObj)
    self.db = addonObj.db
    self.messages = self.db.profile.messageHistory or {}
    self.maxSize = self.db.profile.historySize or 1000
end

function History:AddMessage(text, sender, channel)
    EnsureChannelTableExists(self.db, channel)
    table.insert(self.db.profile.messageHistory[channel], 1, {
        text=text,
        sender=sender,
        channel=channel,
        time=time(),
    })

    -- Keep size in check
    while #self.db.profile.messageHistory[channel] > self.maxSize do
        table.remove(self.db.profile.messageHistory[channel])
    end
end

function History:UpdateMaxSize(newSize)
    self.maxSize = newSize
    for ch, msgs in pairs(self.db.profile.messageHistory) do
        while #msgs>newSize do
            table.remove(msgs)
        end
    end
end
