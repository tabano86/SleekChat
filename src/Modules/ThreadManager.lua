local _, addon = ...
addon.ThreadManager = {}
local ThreadManager = addon.ThreadManager

function ThreadManager:Initialize(addonObj)
    self.db = addonObj.db
    self.threads = {}  -- { threadId -> { parentId, messages={...} } }
    self.nextThreadId = 1
end

-- Start a new sub-thread from a given "parentMessageId"
function ThreadManager:StartThread(parentMsgId)
    local tId = self.nextThreadId
    self.nextThreadId = self.nextThreadId+1
    self.threads[tId] = {
        parentId = parentMsgId,
        messages = {},
    }
    return tId
end

function ThreadManager:AddToThread(threadId, text, sender)
    local thr = self.threads[threadId]
    if not thr then return end
    table.insert(thr.messages, {
        text=text,
        sender=sender,
        time=time(),
    })
end

function ThreadManager:GetThread(threadId)
    return self.threads[threadId]
end

-- If you want "inline" display, you do something in ChatFrame:
-- ChatFrame sees "ThreadManager" data. This is a simplified stub.
return ThreadManager
