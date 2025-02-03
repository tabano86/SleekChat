-- ===========================================================================
-- SleekChat v2.0 - Linking.lua
-- In-chat linking commands for items and quests
-- ===========================================================================
local Linking = {}
SleekChat_Linking = Linking

local frame = CreateFrame("Frame", "SleekChatLinkingFrame", UIParent)
frame:RegisterEvent("PLAYER_LOGIN")

function Linking:OnPlayerLogin()
    self:RegisterSlashCommands()
end

function Linking:RegisterSlashCommands()
    SLASH_SLEEKCHAT_LINKITEM1 = "/linkitem"
    SlashCmdList["SLEEKCHAT_LINKITEM"] = function(msg)
        local itemName = msg and msg:trim()
        if not itemName or itemName == "" then
            print("Usage: /linkitem <item name>")
            return
        end
        local itemID = self:FindItemIDByName(itemName)
        if itemID then
            local link = select(2, GetItemInfo(itemID))
            if link then
                ChatEdit_InsertLink(link)
            else
                print("Item link not cached. Please view the item in-game first.")
            end
        else
            print("Item not found in cache.")
        end
    end

    SLASH_SLEEKCHAT_LINKQUEST1 = "/linkquest"
    SlashCmdList["SLEEKCHAT_LINKQUEST"] = function(msg)
        local questName = msg and msg:trim()
        if not questName or questName == "" then
            print("Usage: /linkquest <quest name>")
            return
        end
        local questLink = self:GenerateQuestLink(questName)
        if questLink then
            ChatEdit_InsertLink(questLink)
        else
            print("Quest not found or not cached.")
        end
    end
end

-- NOTE: This is a simplified implementation. In production, use WoW’s item/quest APIs.
function Linking:FindItemIDByName(name)
    for itemID = 1, 200000 do
        local item = GetItemInfo(itemID)
        if item and strlower(item) == strlower(name) then
            return itemID
        end
    end
    return nil
end

function Linking:GenerateQuestLink(questName)
    local questID = 12345 -- Replace with a lookup from quest log or internal DB.
    return "|cffffff00|Hquest:"..questID..":60|h["..questName.."]|h|r"
end

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        Linking:OnPlayerLogin()
    end
end)
