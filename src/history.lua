-- history.lua
-- History module for storing and retrieving chat messages.
local History = {}

function History.Initialize(instance)
    instance.history = { messages = {} }
    instance.history.maxSize = instance.db.profile.historySize
    if instance.db.profile.debug then
        instance:Print("History module initialized with maxSize " .. instance.history.maxSize)
    end
end

function History.AddMessage(instance, msg)
    table.insert(instance.history.messages, msg)
    while #instance.history.messages > instance.history.maxSize do
        table.remove(instance.history.messages, 1)
    end
    if instance.db.profile.debug then
        instance:Print("Added message. Total messages: " .. #instance.history.messages)
    end
end

function History.GetMessages(instance)
    return instance.history.messages
end

function History.Clear(instance)
    instance.history.messages = {}
end

SleekChat = SleekChat or {}
SleekChat.History = History
