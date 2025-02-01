-- history.lua
-- This module handles the chat history: initialization, storage, retrieval,
-- and clearing of messages, each keyed by chat tabs or channels.

local History = {}

--- Initializes the addon's history structure, creating a messages table
--  for each chat tab. It also sets the maximum size for message storage.
-- @param instance The main addon object, which has a .db.profile field.
function History.Initialize(instance)
    instance.history = {
        messages = {},
        pinned   = {},
        maxSize  = instance.db.profile.historySize,
    }
    -- Create a dedicated messages table for each configured tab.
    for _, tabName in ipairs(instance.db.profile.tabs) do
        instance.history.messages[tabName] = {}
    end

    if instance.db.profile.debug then
        instance:Print("History module initialized with maxSize " .. instance.history.maxSize)
    end
end

--- Adds a new message to the specified channel in the history.
-- @param instance The main addon object.
-- @param msg A table containing at least .channel. If missing, "General" is used.
function History.AddMessage(instance, msg)
    local channel = msg.channel or "General"

    if not instance.history.messages[channel] then
        instance.history.messages[channel] = {}
    end

    -- Insert at the front so most recent messages are at index 1.
    table.insert(instance.history.messages[channel], 1, msg)

    -- Enforce the maximum size limit for stored messages.
    if #instance.history.messages[channel] > instance.history.maxSize then
        table.remove(instance.history.messages[channel])
    end

    if instance.db.profile.debug then
        instance:Print(
                "Added message to " .. channel ..
                        ". Total messages: " .. #instance.history.messages[channel]
        )
    end
end

--- Retrieves the message list for a given chat tab.
-- @param instance The main addon object.
-- @param tabName The tab or channel whose messages should be fetched.
-- @return A table of messages in the specified tab (empty table if none).
function History.GetMessages(instance, tabName)
    return instance.history.messages[tabName] or {}
end

--- Clears the stored messages, either for a specific tab or all tabs.
-- @param instance The main addon object.
-- @param tabName (Optional) The tab to clear. If nil, all tabs are cleared.
function History.Clear(instance, tabName)
    if tabName then
        instance.history.messages[tabName] = {}
    else
        for k in pairs(instance.history.messages) do
            instance.history.messages[k] = {}
        end
    end
end

-- Expose History to the main addon namespace.
SleekChat = SleekChat or {}
SleekChat.History = History
