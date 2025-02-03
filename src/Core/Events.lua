-- Core/Events.lua
local _, addon = ...
local Events = {}

local EVENT_MAP = {
    CHAT_MSG_SAY = "SAY",
    CHAT_MSG_YELL = "YELL",
    CHAT_MSG_PARTY = "PARTY",
    CHAT_MSG_PARTY_LEADER = "PARTY",
    CHAT_MSG_GUILD = "GUILD",
    CHAT_MSG_OFFICER = "OFFICER",
    CHAT_MSG_RAID = "RAID",
    CHAT_MSG_RAID_LEADER = "RAID",
    CHAT_MSG_RAID_WARNING = "RAIDWARNING",
    CHAT_MSG_WHISPER = "WHISPER",
    CHAT_MSG_WHISPER_INFORM = "WHISPER",
    CHAT_MSG_BN_WHISPER = "BNWHISPER",
    CHAT_MSG_BN_WHISPER_INFORM = "BNWHISPER",
    CHAT_MSG_EMOTE = "EMOTE",
    CHAT_MSG_TEXT_EMOTE = "EMOTE",
    CHAT_MSG_SYSTEM = "SYSTEM",
    CHAT_MSG_CHANNEL = "CHANNEL",
    CHAT_MSG_COMMUNITIES_CHANNEL = "COMMUNITY",
    CHAT_MSG_INSTANCE_CHAT = "INSTANCE",
    CHAT_MSG_INSTANCE_CHAT_LEADER = "INSTANCE",
    CHAT_MSG_MONSTER_SAY = "MONSTER",
    CHAT_MSG_MONSTER_YELL = "MONSTER",
    CHAT_MSG_MONSTER_PARTY = "MONSTER",
    CHAT_MSG_MONSTER_WHISPER = "MONSTER",
    CHAT_MSG_MONSTER_EMOTE = "MONSTER",
    CHAT_MSG_RAID_BOSS_EMOTE = "BOSS",
    CHAT_MSG_RAID_BOSS_WHISPER = "BOSS",
    CHAT_MSG_BG_SYSTEM_ALLIANCE = "BGSYS",
    CHAT_MSG_BG_SYSTEM_HORDE = "BGSYS",
    CHAT_MSG_BG_SYSTEM_NEUTRAL = "BGSYS",
    CHAT_MSG_LOOT = "LOOT",
    CHAT_MSG_MONEY = "LOOT",
    CHAT_MSG_SKILL = "SKILL",
    CHAT_MSG_TRADESKILLS = "TRADESKILL",
    CHAT_MSG_IGNORED = "SYSTEM",
    CHAT_MSG_FILTERED = "SYSTEM",
    CHAT_MSG_RESTRICTED = "SYSTEM",
    CHAT_MSG_TARGETICONS = "SYSTEM",
    CHAT_MSG_GUILD_ACHIEVEMENT = "GUILDACHV",
}

local chatEvents = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_EMOTE",
    "CHAT_MSG_TEXT_EMOTE", "CHAT_MSG_SYSTEM", "CHAT_MSG_CHANNEL",
    "CHAT_MSG_COMMUNITIES_CHANNEL", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_PARTY",
    "CHAT_MSG_MONSTER_EMOTE", "CHAT_MSG_MONSTER_WHISPER", "CHAT_MSG_RAID_BOSS_EMOTE",
    "CHAT_MSG_RAID_BOSS_WHISPER", "CHAT_MSG_BG_SYSTEM_ALLIANCE",
    "CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG_BG_SYSTEM_NEUTRAL", "CHAT_MSG_LOOT",
    "CHAT_MSG_MONEY", "CHAT_MSG_SKILL", "CHAT_MSG_TRADESKILLS",
    "CHAT_MSG_IGNORED", "CHAT_MSG_FILTERED", "CHAT_MSG_RESTRICTED",
    "CHAT_MSG_TARGETICONS", "CHAT_MSG_GUILD_ACHIEVEMENT",
}

function Events:Initialize(addonObj)
    self.addonObj = addonObj
    addonObj.db = addonObj.db or {}
    addonObj.db.profile = addonObj.db.profile or {}

    local eventFrame = CreateFrame("Frame", nil, UIParent)
    for _, evt in ipairs(chatEvents) do
        eventFrame:RegisterEvent(evt)
    end
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatTabs and addon.ChatTabs.mainFrame then
                addon.ChatTabs.mainFrame:SetAlpha(0)
            end
            return
        elseif event == "PLAYER_REGEN_ENABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatTabs and addon.ChatTabs.mainFrame then
                addon.ChatTabs.mainFrame:SetAlpha(1)
            end
            return
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local info = { CombatLogGetCurrentEventInfo() }
            local subEvent = info[2]
            local srcName = info[5] or "?"
            local dstName = info[9] or "?"
            if addon.ChatTabs then
                local line = string.format("[%.2f] %s -> %s : %s", (GetTime() % 60), srcName, dstName, subEvent or "")
                addon.ChatTabs:AddIncoming(line, "CombatLog", "COMBAT")
            end
        else
            local msg, sender, _, _, channelName = ...
            local mappedChannel = EVENT_MAP[event] or "ALL"
            if addon.ChatTabs then
                if event == "CHAT_MSG_CHANNEL" then
                    addon.ChatTabs:AddIncoming(msg or "", sender or "Unknown", channelName or mappedChannel)
                else
                    addon.ChatTabs:AddIncoming(msg or "", sender or "Unknown", mappedChannel)
                end
            end
        end
    end)
end

addon.Events = Events
return Events
