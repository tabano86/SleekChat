-- util.lua
SleekChatUtil = {}
local util = SleekChatUtil

function util:Log(msg, level)
    level = level or "INFO"
    if SleekChat and SleekChat.db and SleekChat.db.profile.debug then
        print(string.format("[%s][SleekChat]: %s", level, msg))
    end
end

function util:SafeCall(func, ...)
    if type(func) == "function" then
        local success, result = pcall(func, ...)
        if not success then
            self:Log("Error in function call: " .. tostring(result), "ERROR")
        end
        return success, result
    end
    return false, nil
end


function SleekChatUtil:Debug(...)
    if SleekChat.db.profile.debug then
        print("|cff33ff99SleekChat|r:", ...)
    end
end
