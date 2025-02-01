-- ModuleRegistry.lua
local ModuleRegistry = {}
ModuleRegistry.__index = ModuleRegistry

-- Create a new registry.
function ModuleRegistry:new()
    local self = setmetatable({}, ModuleRegistry)
    self.modules = {}
    return self
end

-- Register a module instance under a given name.
function ModuleRegistry:register(name, instance)
    assert(type(name) == "string" and name ~= "", "Module name must be a non-empty string")
    if self.modules[name] then
        self:Debug("Module '" .. name .. "' already registered; overwriting.")
    end
    self.modules[name] = instance
end

-- Retrieve a module instance by name.
function ModuleRegistry:get(name)
    return self.modules[name]
end

-- Check if a module is registered.
function ModuleRegistry:exists(name)
    return self.modules[name] ~= nil
end

-- (Optional) Dump the registry.
function ModuleRegistry:dump()
    for k, v in pairs(self.modules) do
        print("Module:", k, v)
    end
end

-- Internal debug (for now, using print).
function ModuleRegistry:Debug(message)
    print("[ModuleRegistry DEBUG] " .. message)
end

_G.SleekChat = _G.SleekChat or {}
_G.SleekChat.ModuleRegistry = ModuleRegistry
