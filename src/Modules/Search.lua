-- Modules/Search.lua
local _, addon = ...
addon.Search = {}
local Search = addon.Search

function Search:Initialize(addonObj)
    self.db = addonObj.db
    self.frame = CreateFrame("Frame", "SleekChatSearch", UIParent, "BackdropTemplate")
    self:CreateSearchBox()
end

function Search:CreateSearchBox()
    local edit = CreateFrame("EditBox", nil, self.frame, "InputBoxTemplate")
    edit:SetSize(200, 24)
    edit:SetPoint("TOP", UIParent, "TOP", 0, -100)
    edit:SetAutoFocus(false)
    edit:SetScript("OnTextChanged", function(this)
        addon.ChatFrame:FilterMessages(this:GetText())
    end)
    local label = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM", edit, "TOP", 0, 2)
    label:SetText("Search Chat")
end
