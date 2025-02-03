local _, addon = ...
local Hooks = {}
addon.Hooks = Hooks

-- We'll store original references to 'AddMessage' and 'print'
local orig_AddMessage = nil
local orig_print      = nil

function Hooks:Initialize()
    -- 1) Hook DEFAULT_CHAT_FRAME:AddMessage
    if not orig_AddMessage then
        orig_AddMessage = DEFAULT_CHAT_FRAME.AddMessage
        DEFAULT_CHAT_FRAME.AddMessage = function(self, text, r, g, b, ...)
            -- pass it to SleekChat
            if addon.ChatFrame and addon.ChatFrame.AddIncoming then
                -- We'll route it as "SYSTEM" or "ADDON" or similar
                addon.ChatFrame:AddIncoming(text or "", "Blizz", "SYSTEM")
            end
            -- still call the original
            if orig_AddMessage then
                return orig_AddMessage(self, text, r, g, b, ...)
            end
        end
    end

    -- 2) Hook global print
    if not orig_print then
        orig_print = _G.print
        _G.print = function(...)
            local line = table.concat({...}, " ")
            -- Send to SleekChat as "SYSTEM" or "ADDON"
            if addon.ChatFrame and addon.ChatFrame.AddIncoming then
                addon.ChatFrame:AddIncoming(line, "print()", "SYSTEM")
            end
            return orig_print(...)
        end
    end
end

return Hooks
