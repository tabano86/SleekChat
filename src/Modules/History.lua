local _, addon= ...
addon.History={}
local History= addon.History

function History:Initialize(addonObj)
    self.db= addonObj.db
    if not self.db.profile.messageHistory then
        self.db.profile.messageHistory= {}
    end
    self.maxSize= self.db.profile.historySize or 2000
end

function History:AddMessage(text, sender, channel)
    local db= self.db.profile
    if not db.messageHistory[channel] then
        db.messageHistory[channel]= {}
    end
    table.insert(db.messageHistory[channel],1,{
        text=text, sender=sender,channel=channel,time=time(),
    })
    while #db.messageHistory[channel]> self.maxSize do
        table.remove(db.messageHistory[channel])
    end
end

function History:UpdateMaxSize(sz)
    self.maxSize= sz
    local db= self.db.profile
    for ch,arr in pairs(db.messageHistory) do
        while #arr>sz do
            table.remove(arr)
        end
    end
end
