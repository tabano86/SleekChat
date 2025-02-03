-- ===========================================================================
-- SleekChat v2.0 - Linking.lua
-- In-chat linking commands, extended tooltips, slash commands, etc.
-- ===========================================================================

local Linking = {}
SleekChat_Linking = Linking

local frame = CreateFrame("Frame", "SleekChatLinkingFrame", UIParent)

frame:RegisterEvent("PLAYER_LOGIN")

function Linking:OnPlayerLogin()
    self:RegisterSlashCommands()
    -- Additional initialization if needed
end

function Linking:RegisterSlashCommands()
    SLASH_SLEEKCHAT_LINKITEM1 = "/linkitem"
    SlashCmdList["SLEEKCHAT_LINKITEM"] = function(msg)
        local itemName = msg
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
                print("Item link not found in cache. You may need to see the item first.")
            end
        else
            print("Item not found or not cached.")
        end
    end

    SLASH_SLEEKCHAT_LINKQUEST1 = "/linkquest"
    SlashCmdList["SLEEKCHAT_LINKQUEST"] = function(msg)
        -- For demonstration, assume we look up a quest by name
        if not msg or msg == "" then
            print("Usage: /linkquest <quest name>")
            return
        end
        local questLink = self:GenerateQuestLink(msg)
        if questLink then
            ChatEdit_InsertLink(questLink)
        else
            print("Quest not found or not cached.")
        end
    end
end

function Linking:FindItemIDByName(name)
    -- Simplified: in reality, you'd need a more robust approach or rely on already-cached items
    -- This is a placeholder for demonstration.
    for itemID = 1, 200000 do
        local n = GetItemInfo(itemID)
        if n and string.lower(n) == string.lower(name) then
            return itemID
        end
    end
    return nil
end

function Linking:GenerateQuestLink(questName)
    -- Stub: The real logic would search the quest log or an internal database
    local questID = 12345 -- hypothetical
    local questLink = "|cffffff00|Hquest:"..questID..":60|h["..questName.."]|h|r"
    return questLink
end

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        Linking:OnPlayerLogin()
    end
end)
