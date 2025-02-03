-- Modules/Hooks.lua
local _, addon = ...
addon.Hooks = {}
local Hooks = addon.Hooks

local orig_AddMessage, orig_print

function Hooks:Initialize()
    -- Hook to redirect default chat messages
    if not orig_AddMessage then
        orig_AddMessage = DEFAULT_CHAT_FRAME.AddMessage
        DEFAULT_CHAT_FRAME.AddMessage = function(cf, text, r, g, b, ...)
            if addon.ChatTabs and addon.ChatTabs.AddIncoming then
                addon.ChatTabs:AddIncoming(text or "", "BlizzPrint", "SYSTEM")
            end
            return orig_AddMessage(cf, text, r, g, b, ...)
        end
    end

    -- Hook to redirect global print
    if not orig_print then
        orig_print = _G.print
        _G.print = function(...)
            local line = table.concat({ ... }, " ")
            if addon.ChatTabs and addon.ChatTabs.AddIncoming then
                addon.ChatTabs:AddIncoming(line, "print", "SYSTEM")
            end
            return orig_print(...)
        end
    end
end

return Hooks
