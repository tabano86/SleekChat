local _, addon = ...
local Events = {}

-- Maps WoW “CHAT_MSG_*” events to logical channel identifiers
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

function Events:Initialize(addonObj)
    -- Store a reference to our addon object if needed
    self.addonObj = addonObj

    -- Safely prepare database references to avoid errors if not defined
    addonObj.db = addonObj.db or {}
    addonObj.db.profile = addonObj.db.profile or {}
    addonObj.db.profile.autoHideInCombat = addonObj.db.profile.autoHideInCombat or false

    -- Frame to capture events
    local eventFrame = CreateFrame("Frame", nil, UIParent)

    -- List all relevant chat/combat events
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
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_COMMUNITIES_CHANNEL",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_MONSTER_SAY",
        "CHAT_MSG_MONSTER_YELL",
        "CHAT_MSG_MONSTER_PARTY",
        "CHAT_MSG_MONSTER_EMOTE",
        "CHAT_MSG_MONSTER_WHISPER",
        "CHAT_MSG_RAID_BOSS_EMOTE",
        "CHAT_MSG_RAID_BOSS_WHISPER",
        "CHAT_MSG_BG_SYSTEM_ALLIANCE",
        "CHAT_MSG_BG_SYSTEM_HORDE",
        "CHAT_MSG_BG_SYSTEM_NEUTRAL",
        "CHAT_MSG_LOOT",
        "CHAT_MSG_MONEY",
        "CHAT_MSG_SKILL",
        "CHAT_MSG_TRADESKILLS",
        "CHAT_MSG_IGNORED",
        "CHAT_MSG_FILTERED",
        "CHAT_MSG_RESTRICTED",
        "CHAT_MSG_TARGETICONS",
        "CHAT_MSG_GUILD_ACHIEVEMENT",
    }

    -- Register all chat events
    for _, evt in ipairs(chatEvents) do
        eventFrame:RegisterEvent(evt)
    end

    -- Combat log event (unfiltered)
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- Monitor player entering/exiting combat to adjust UI if desired
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    eventFrame:SetScript("OnEvent", function(_, event, ...)
        -- If entering combat
        if event == "PLAYER_REGEN_DISABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatTabs and addon.ChatTabs.mainFrame then
                addon.ChatTabs.mainFrame:SetAlpha(0)
            end
            return
        end

        -- If leaving combat
        if event == "PLAYER_REGEN_ENABLED" then
            if addonObj.db.profile.autoHideInCombat and addon.ChatTabs and addon.ChatTabs.mainFrame then
                addon.ChatTabs.mainFrame:SetAlpha(1)
            end
            return
        end

        -- Handle combat log data
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local info = { CombatLogGetCurrentEventInfo() }
            local timeStamp = info[1]   -- e.g. event time
            local subEvent  = info[2]   -- e.g. SPELL_CAST_START, SWING_DAMAGE, etc.
            local srcName   = info[5] or "?"
            local dstName   = info[9] or "?"

            if addon.ChatTabs then
                local line = string.format(
                        "[%.2f] %s -> %s : %s",
                        (GetTime() % 60),
                        srcName,
                        dstName,
                        subEvent or ""
                )
                addon.ChatTabs:AddIncoming(line, "CombatLog", "COMBAT")
            end
            return
        end

        -- Process normal chat messages
        local msg, sender, _, _, channelName = ...
        local mappedChannel = EVENT_MAP[event] or "ALL"

        if addon.ChatTabs then
            if event == "CHAT_MSG_CHANNEL" then
                addon.ChatTabs:AddIncoming(msg or "", sender or "Unknown", channelName or mappedChannel)
            else
                addon.ChatTabs:AddIncoming(msg or "", sender or "Unknown", mappedChannel)
            end
        end
    end)
end

-- Expose Events API to the addon
addon.Events = Events
