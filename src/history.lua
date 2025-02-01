-- history.lua
SleekChatHistory = {}
local History = SleekChatHistory

function History:InitializeHistory()
    self.history = {}  -- Local buffer for messages.
    SleekChatUtil:Log("History module initialized.", "DEBUG")
end

function History:AddToHistory(message)
    table.insert(self.history, message)
    local maxSize = SleekChat.db.profile.messageHistorySize or 1000
    if #self.history > maxSize then
        table.remove(self.history, 1)
    end
    SleekChatUtil:Log("Message added to history. Total messages: " .. #self.history, "DEBUG")
end

function History:GetHistory()
    return self.history
end

function History:SearchHistory(query)
    local results = {}
    if query and query ~= "" then
        local lowerQuery = query:lower()
        for _, msg in ipairs(self.history) do
            if (msg.text and msg.text:lower():find(lowerQuery)) or
                    (msg.sender and msg.sender:lower():find(lowerQuery)) then
                table.insert(results, msg)
            end
        end
    end
    return results
end

function History:ClearHistory()
    self.history = {}
    SleekChatUtil:Log("History cleared.", "DEBUG")
end
