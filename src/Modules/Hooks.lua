local _, addon= ...
addon.Hooks={}
local Hooks= addon.Hooks

local orig_AddMessage= nil
local orig_print= nil

function Hooks:Initialize()
    if not orig_AddMessage then
        orig_AddMessage= DEFAULT_CHAT_FRAME.AddMessage
        DEFAULT_CHAT_FRAME.AddMessage= function(self, text, r, g, b, ...)
            -- route to SleekChat
            if addon.ChatTabs and addon.ChatTabs.AddIncoming then
                addon.ChatTabs:AddIncoming(text or "", "BlizzPrint", "SYSTEM")
            end
            -- original
            return orig_AddMessage(self, text, r, g, b, ...)
        end
    end

    if not orig_print then
        orig_print= _G.print
        _G.print= function(...)
            local line= table.concat({...}," ")
            if addon.ChatTabs and addon.ChatTabs.AddIncoming then
                addon.ChatTabs:AddIncoming(line, "print", "SYSTEM")
            end
            return orig_print(...)
        end
    end
end

return Hooks
