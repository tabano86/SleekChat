-- events.lua
-- This module processes incoming chat messages, returning a table
-- of relevant details for downstream handling (like UI or history storage).

local Events = {}

--[[
    Processes a chat message, retrieving sender, channel, class, and timestamp data.
    @param prefix   Prefix associated with addon messages (unused by default).
    @param message  The raw message text.
    @param channel  The chat channel ID or event name (e.g., "CHAT_MSG_SAY").
    @param sender   The name of the message sender.
    @param profile  The addon profile table, which may contain a timestamp format.
    @return A table containing message data for further handling.
--]]
function Events.ProcessMessage(prefix, message, channel, sender, profile)
    -- GUID logic is disabled here by default. If you want to fetch it,
    -- you may pass or retrieve the GUID from relevant calling context.
    local guid = nil
    local class
    if guid and guid ~= "" then
        local _, engClass = GetPlayerInfoByGUID(guid)
        class = engClass
    end

    return {
        text    = message,
        sender  = sender,
        channel = (channel:match("CHAT_MSG_(.*)") or channel),
        class   = class,
        -- Timestamp using os.date, with fallback to "[%H:%M]"
        time    = os.date(profile.timestampFormat or "[%H:%M]"),
    }
end

-- Expose the module under SleekChat.Events
SleekChat = SleekChat or {}
SleekChat.Events = Events
