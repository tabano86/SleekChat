local _, addon = ...
addon.History = {}
local History = addon.History

-- Helper function to ensure the channel table exists
local function EnsureChannelTableExists(db, channel)
    if not db.profile.messageHistory[channel] then
        db.profile.messageHistory[channel] = {}
    end
end

-- Helper function to handle migration if needed
local function MigrateOldData(db, storage)
    if not db.profile.messageHistory then
        db.profile.messageHistory = storage
    end
end

-- Helper function to insert a new message
local function InsertMessage(db, channel, text, sender)
    table.insert(db.profile.messageHistory[channel], 1, {
        text = text,
        sender = sender,
        channel = channel,
        time = time()
    })
end

-- Helper function to enforce maximum storage size
local function EnforceMaxSize(db, channel, maxSize)
    while #db.profile.messageHistory[channel] > maxSize do
        table.remove(db.profile.messageHistory[channel])
    end
end

-- Public method to initialize the History module
function History.Initialize(self)
    self.messages = self.db.profile.messageHistory or {}
    self.maxSize = self.db.profile.historySize
    MigrateOldData(self.db, self.messages)
end

-- Public method to add a message to the history
function History.AddMessage(self, text, sender, channel)
    EnsureChannelTableExists(self.db, channel)
    InsertMessage(self.db, channel, text, sender)
    EnforceMaxSize(self.db, channel, self.maxSize)
end
