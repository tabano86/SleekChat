local _, addon = ...
local Events = {}

local EVENT_MAP = {
    CHAT_MSG_SAY     = "SAY",
    CHAT_MSG_YELL    = "YELL",
    CHAT_MSG_PARTY   = "PARTY",
    CHAT_MSG_PARTY_LEADER = "PARTY",
    CHAT_MSG_RAID    = "RAID",
    CHAT_MSG_RAID_LEADER = "RAID",
    CHAT_MSG_GUILD   = "GUILD",
    CHAT_MSG_OFFICER = "OFFICER",
    CHAT_MSG_WHISPER = "WHISPER",
    CHAT_MSG_WHISPER_INFORM = "WHISPER",
    CHAT_MSG_BN_WHISPER = "BNWHISPER",
    CHAT_MSG_BN_WHISPER_INFORM = "BNWHISPER",
    CHAT_MSG_EMOTE   = "EMOTE",
    CHAT_MSG_TEXT_EMOTE= "EMOTE",
    CHAT_MSG_SYSTEM  = "SYSTEM",

    -- BG or instance
    --CHAT_MSG_BATTLEGROUND        = "BATTLEGROUND",
    --CHAT_MSG_BATTLEGROUND_LEADER = "BATTLEGROUND",
    CHAT_MSG_INSTANCE_CHAT       = "INSTANCE",
    CHAT_MSG_INSTANCE_CHAT_LEADER= "INSTANCE",
    CHAT_MSG_RAID_WARNING        = "RAIDWARNING",

    -- Channel
    CHAT_MSG_CHANNEL  = "CHANNEL",
    CHAT_MSG_COMMUNITIES_CHANNEL= "COMMUNITY",

    -- Combat-like
    CHAT_MSG_COMBAT_XP_GAIN  = "COMBAT",
    CHAT_MSG_COMBAT_HONOR_GAIN= "COMBAT",
    CHAT_MSG_COMBAT_FACTION_CHANGE= "COMBAT",
    CHAT_MSG_LOOT           = "COMBAT",
    CHAT_MSG_MONEY          = "COMBAT",
    CHAT_MSG_SKILL          = "COMBAT",
    CHAT_MSG_TRADESKILLS    = "COMBAT",
    CHAT_MSG_BG_SYSTEM_ALLIANCE = "COMBAT",
    CHAT_MSG_BG_SYSTEM_HORDE    = "COMBAT",
    CHAT_MSG_BG_SYSTEM_NEUTRAL  = "COMBAT",

    -- Monster NPC
    CHAT_MSG_MONSTER_SAY    = "MONSTER",
    CHAT_MSG_MONSTER_YELL   = "MONSTER",
    CHAT_MSG_MONSTER_EMOTE  = "MONSTER",
    CHAT_MSG_MONSTER_WHISPER= "MONSTER",
    CHAT_MSG_MONSTER_PARTY  = "MONSTER",
    CHAT_MSG_RAID_BOSS_EMOTE= "BOSS",
    CHAT_MSG_RAID_BOSS_WHISPER="BOSS",

    -- More
    CHAT_MSG_IGNORED        = "SYSTEM",
    CHAT_MSG_FILTERED       = "SYSTEM",
    CHAT_MSG_RESTRICTED     = "SYSTEM",
    CHAT_MSG_TARGETICONS    = "SYSTEM",
    CHAT_MSG_GUILD_ACHIEVEMENT= "GUILDACHV",
}

function Events:Initialize(addonObj)
    local frame = CreateFrame("Frame")

    -- comprehensive list of chat events
    local chatEvents = {
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_BN_WHISPER_INFORM",
        "CHAT_MSG_EMOTE",
        "CHAT_MSG_TEXT_EMOTE",
        "CHAT_MSG_SYSTEM",
        --"CHAT_MSG_BATTLEGROUND",
        --"CHAT_MSG_BATTLEGROUND_LEADER",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_COMMUNITIES_CHANNEL",

        "CHAT_MSG_COMBAT_XP_GAIN",
        "CHAT_MSG_COMBAT_HONOR_GAIN",
        "CHAT_MSG_COMBAT_FACTION_CHANGE",
        "CHAT_MSG_LOOT",
        "CHAT_MSG_MONEY",
        "CHAT_MSG_SKILL",
        "CHAT_MSG_TRADESKILLS",
        "CHAT_MSG_BG_SYSTEM_ALLIANCE",
        "CHAT_MSG_BG_SYSTEM_HORDE",
        "CHAT_MSG_BG_SYSTEM_NEUTRAL",

        "CHAT_MSG_MONSTER_SAY",
        "CHAT_MSG_MONSTER_YELL",
        "CHAT_MSG_MONSTER_EMOTE",
        "CHAT_MSG_MONSTER_WHISPER",
        "CHAT_MSG_MONSTER_PARTY",
        "CHAT_MSG_RAID_BOSS_EMOTE",
        "CHAT_MSG_RAID_BOSS_WHISPER",

        "CHAT_MSG_IGNORED",
        "CHAT_MSG_FILTERED",
        "CHAT_MSG_RESTRICTED",
        "CHAT_MSG_TARGETICONS",
        "CHAT_MSG_GUILD_ACHIEVEMENT",
    }

    for _, evt in ipairs(chatEvents) do
        frame:RegisterEvent(evt)
    end

    -- Also handle fade in/out in combat
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    frame:SetScript("OnEvent", function(_, event, ...)
        -- Combat fade
        if event=="PLAYER_REGEN_DISABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame and addon.ChatFrame.mainFrame then
                addon.ChatFrame.mainFrame:SetAlpha(0)
            end
            return
        elseif event=="PLAYER_REGEN_ENABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatFrame and addon.ChatFrame.mainFrame then
                addon.ChatFrame.mainFrame:SetAlpha(1)
            end
            return
        end

        local msg, sender, _, _, channelName = ...

        local mapped = EVENT_MAP[event] or "ALL"

        -- If user opted out of storing system logs, skip
        if mapped=="SYSTEM" and (not addonObj.db.profile.storeSystem) then
            return
        end
        -- If mapped is COMBAT but user doesn't want them
        if mapped=="COMBAT" and (not addonObj.db.profile.storeCombat) then
            return
        end

        -- Now pass to ChatFrame
        if addon.ChatFrame and addon.ChatFrame.AddIncoming then
            if event=="CHAT_MSG_CHANNEL" then
                addon.ChatFrame:AddIncoming(msg, sender, channelName or mapped)
            else
                addon.ChatFrame:AddIncoming(msg, sender, mapped)
            end
        end
    end)
end

addon.Events = Events
