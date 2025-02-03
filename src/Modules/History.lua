local _, addon = ...
addon.History = {}
local History = addon.History

local function EnsureChannel(db, channel)
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
    EnsureChannel(self.db, channel)
    table.insert(self.db.profile.messageHistory[channel], 1, {
        text=text,
        sender=sender,
        channel=channel,
        time=time(),
    })
    local arr = self.db.profile.messageHistory[channel]
    while #arr>self.maxSize do
        table.remove(arr)
    end
end

function History:UpdateMaxSize(sz)
    self.maxSize = sz
    for ch, arr in pairs(self.db.profile.messageHistory) do
        while #arr>sz do
            table.remove(arr)
        end
    end
end
