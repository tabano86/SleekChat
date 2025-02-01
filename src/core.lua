local defaults = {
    profile = {
        hideDefaultChat = true,
        classColors = true,
        showTimestamps = true,
        timestampFormat = "%H:%M",
        urlDetection = true,
        font = "Friz Quadrata TT",
        fontSize = 12,
        backgroundColor = {r=0,g=0,b=0,a=0.8},
        windowWidth = 600,
        windowHeight = 350,
        messageHistory = 1000,
    },
}

function SleekChat:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SleekChatDB", defaults)
    self:SetupDefaultUI()
    self:RegisterChatCommand("sc", "HandleCommand")
end

function SleekChat:OnEnable()
    SleekChatUI:Initialize()
    SleekChatEvents:Initialize()
    SleekChatHistory:Initialize()
end

function SleekChat:HandleCommand(input)
    if input == "reset" then
        self.db:ResetProfile()
        self:Print("Settings reset to defaults")
    else
        InterfaceOptionsFrame_OpenToCategory("SleekChat")
    end
end

function SleekChat:SetupDefaultUI()
    for i = 1, NUM_CHAT_WINDOWS do
        if self.db.profile.hideDefaultChat then
            _G["ChatFrame"..i]:Hide()
        else
            _G["ChatFrame"..i]:Show()
        end
    end
end
