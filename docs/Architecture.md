# SleekChat Architecture

## Overview
SleekChat is organized into feature modules, each responsible for a distinct portion of the chat experience:
- **CoreChat:** Sets up base hooks and configuration.
- **UIEnhancements:** Adjusts the chat UI (dynamic tabs, auto-hiding input, custom fonts).
- **Notifications:** Implements keyword highlights, regex triggers, and sound alerts.
- **Linking:** Provides in-chat linking for items and quests.
- **QoL:** Adds quality-of-life improvements (chat export, clear chat, auto-rejoin, inactivity timer).
- **FutureRoadmap:** Contains modules planned for future enhancements.

Each module hooks into Blizzard's chat API without overriding default chat frames.

## High-Level Flow
1. **Initialization:** CoreChat loads first, merging saved variables and defaults.
2. **Module Registration:** Additional modules register their event handlers after CoreChat is ready.
3. **Saved Variables:** `SleekChatDB` stores user preferences.
4. **UI Modifications:** UIEnhancements refines chat frames.
5. **Notifications & Filtering:** Notifications and QoL manage triggers and chat features.
6. **Linking:** Extends hyperlink handling and slash commands.
7. **Future Modules:** Reserved for advanced features.

## Event Handling
Modules use `Frame:RegisterEvent` and `OnEvent` scripts to integrate with WoW’s chat events while preserving native functionality.

## Data Flow
- **SleekChatDB:** The saved variable table.
- **Config:** Merges defaults and user preferences.
- **Module API:** Modules access config data independently to minimize coupling.
