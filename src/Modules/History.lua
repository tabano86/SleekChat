local _, addon = ...
addon.History = {}
local History = addon.History

function History.Initialize(self)
    -- Load from saved variables instead of creating new
    self.messages = self.db.profile.messageHistory or {}
    self.maxSize = self.db.profile.historySize

    -- Migrate old data
    if not self.db.profile.messageHistory then
        self.db.profile.messageHistory = self.messages
    end
end

function History.AddMessage(self, text, sender, channel)
    if not self.db.profile.messageHistory[channel] then
        self.db.profile.messageHistory[channel] = {}
    end

    table.insert(self.db.profile.messageHistory[channel], 1, {
        text = text,
        sender = sender,
        channel = channel,
        time = time()
    })

    while #self.db.profile.messageHistory[channel] > self.maxSize do
        table.remove(self.db.profile.messageHistory[channel])
    end
end
