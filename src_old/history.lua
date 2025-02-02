-- history.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.History and _G.SleekChat.History._loaded then return end
_G.SleekChat.History = _G.SleekChat.History or {}
local History = _G.SleekChat.History
local Logger = _G.SleekChat.Logger

Logger:Debug("History Loading...")

function History.Initialize(instance)
    instance.history = {
        messages = {},
        pinned   = {},
        maxSize  = instance.db.profile.historySize,
    }
    for _, tabName in ipairs(instance.db.profile.tabs) do
        instance.history.messages[tabName] = {}
    end
    Logger:Info("History module initialized with maxSize " .. instance.history.maxSize)
end

function History.AddMessage(instance, msg)
    local channel = msg.channel or "General"
    if not instance.history.messages[channel] then
        instance.history.messages[channel] = {}
    end
    table.insert(instance.history.messages[channel], 1, msg)
    if #instance.history.messages[channel] > instance.history.maxSize then
        table.remove(instance.history.messages[channel])
    end
    Logger:Debug("Added message to " .. channel)
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

Logger:Debug("History Loaded!")
History._loaded = true
local registry = _G.SleekChat.Modules
registry:register("History", History)
