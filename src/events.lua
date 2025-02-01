SleekChatEvents = {
    events = {
        "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_RAID",
        "CHAT_MSG_WHISPER", "CHAT_MSG_CHANNEL",
    }
}

function SleekChatEvents:Initialize()
    for _, event in ipairs(self.events) do
        SleekChat:RegisterEvent(event, function(...) self:OnEvent(event, ...) end)
    end
end

function SleekChatEvents:OnEvent(event, msg, sender, _, _, _, _, _, _, _, _, guid)
    local channel = event:match("CHAT_MSG_(.*)")
    local class = guid and select(2, GetPlayerInfoByGUID(guid))

    SleekChatHistory:AddMessage({
        text = msg,
        sender = sender,
        channel = channel,
        class = class,
        time = time(),
    })

    SleekChatUI:AddMessage(sender, msg, channel, class)
end
