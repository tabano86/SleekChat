local _, addon = ...
addon.Search = {}
local Search = addon.Search

function Search:Initialize(addonObj)
    self.db = addonObj.db
    self.frame = CreateFrame("Frame", "SleekChatSearch", UIParent)
    self:CreateSearchBox()
end

function Search:CreateSearchBox()
    local edit = CreateFrame("EditBox", nil, self.frame, "InputBoxTemplate")
    edit:SetSize(200, 24)
    edit:SetPoint("TOP", UIParent, "TOP", 0, -100)
    edit:SetScript("OnTextChanged", function(self)
        addon.ChatFrame:FilterMessages(self:GetText())
    end)
end
