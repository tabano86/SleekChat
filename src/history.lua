-- history.lua
local History = {}

function History.Initialize(instance)
    instance.history = {
        messages = {},
        pinned = {},
        maxSize = instance.db.profile.historySize,
    }
    -- Initialize per-group tables for each chat tab.
    for _, tabName in ipairs(instance.db.profile.tabs) do
        instance.history.messages[tabName] = {}
    end
    if instance.db.profile.debug then
        instance:Print("History module initialized with maxSize " .. instance.history.maxSize)
    end
end

function History.AddMessage(instance, msg)
    local channel = msg.channel or "General"
    if not instance.history.messages[channel] then
        instance.history.messages[channel] = {}
    end
    -- Insert at the beginning so newest are on top.
    table.insert(instance.history.messages[channel], 1, msg)
    if #instance.history.messages[channel] > instance.history.maxSize then
        table.remove(instance.history.messages[channel])
    end
    if instance.db.profile.debug then
        instance:Print("Added message to " .. channel .. ". Total messages: " .. #instance.history.messages[channel])
    end
end

function History.GetMessages(instance, tabName)
    return instance.history.messages[tabName] or {}
end

function History.Clear(instance, tabName)
    if tabName then
        instance.history.messages[tabName] = {}
    else
        for k in pairs(instance.history.messages) do
            instance.history.messages[k] = {}
        end
    end
end

SleekChat = SleekChat or {}
SleekChat.History = History
