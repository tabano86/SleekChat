-- history.lua
local Util = require("Util") or _G.SleekChat.Util

local History = Util.singleton("History", function()
    local self = {}

    function self.Initialize(instance)
        instance.history = {
            messages = {},
            pinned   = {},
            maxSize  = instance.db.profile.historySize,
        }
        -- Create a table for each configured tab.
        for _, tabName in ipairs(instance.db.profile.tabs) do
            instance.history.messages[tabName] = {}
        end

        if instance.db.profile.debug then
            instance:Print("History module initialized with maxSize " .. instance.history.maxSize)
        end
    end

    function self.AddMessage(instance, msg)
        local channel = msg.channel or "General"
        if not instance.history.messages[channel] then
            instance.history.messages[channel] = {}
        end
        table.insert(instance.history.messages[channel], 1, msg)
        if #instance.history.messages[channel] > instance.history.maxSize then
            table.remove(instance.history.messages[channel])
        end
        if instance.db.profile.debug then
            instance:Print("Added message to " .. channel .. ". Total messages: " .. #instance.history.messages[channel])
        end
    end

    function self.GetMessages(instance, tabName)
        return instance.history.messages[tabName] or {}
    end

    function self.Clear(instance, tabName)
        if tabName then
            instance.history.messages[tabName] = {}
        else
            for k in pairs(instance.history.messages) do
                instance.history.messages[k] = {}
            end
        end
    end

    return self
end)

return History
