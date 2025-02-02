local _, addon = ...
addon.History = {}
local History = addon.History

function History.Initialize(self)
    self.messages = {}
    self.maxSize = self.db.profile.historySize
end

function History.AddMessage(self, text, sender, channel)
    if not self.messages[channel] then
        self.messages[channel] = {}
    end

    table.insert(self.messages[channel], 1, {
        text = text,
        sender = sender,
        channel = channel,
        time = time()
    })

    while #self.messages[channel] > self.maxSize do
        table.remove(self.messages[channel])
    end
end
