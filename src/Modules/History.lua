local _, addon = ...
addon.History = {}
local History = addon.History

local function EnsureChannelTableExists(db, channel)
    if not db.profile.messageHistory[channel] then
        db.profile.messageHistory[channel] = {}
    end
end

local function MigrateOldData(db, storage)
    if not db.profile.messageHistory then
        db.profile.messageHistory = storage
    end
end

local function InsertMessage(db, channel, text, sender)
    table.insert(db.profile.messageHistory[channel], 1, {
        text = text,
        sender = sender,
        channel = channel,
        time = time(),
    })
end

local function EnforceMaxSize(db, channel, maxSize)
    while #db.profile.messageHistory[channel] > maxSize do
        table.remove(db.profile.messageHistory[channel])
    end
end

function History:Initialize()
    self.messages = self.db.profile.messageHistory or {}
    self.maxSize = self.db.profile.historySize or 1000
    MigrateOldData(self.db, self.messages)
end

function History:AddMessage(text, sender, channel)
    EnsureChannelTableExists(self.db, channel)
    InsertMessage(self.db, channel, text, sender)
    EnforceMaxSize(self.db, channel, self.maxSize)
end

function History:UpdateMaxSize(newSize)
    self.maxSize = newSize
    for channel, messages in pairs(self.db.profile.messageHistory or {}) do
        while #messages > newSize do
            table.remove(messages)
        end
    end
end

return History
