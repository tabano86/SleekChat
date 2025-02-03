# SleekChat Architecture

## Overview
SleekChat is organized into feature modules, each responsible for a distinct portion of the chat experience: `CoreChat`, `UIEnhancements`, `Notifications`, `Linking`, `QoL`, and `FutureRoadmap`. Each module hooks into Blizzard's chat API where necessary, adding functionality without overriding the default chat frames.

## High-Level Flow
1. **Initialization**: `CoreChat` loads first, setting up base hooks for chat frames and configuration.
2. **Module Registration**: Additional modules like `Notifications` and `Linking` register their hooks after `CoreChat` is ready.
3. **Saved Variables**: `Config.lua` sets up default or loaded user preferences from `SavedVariables/SleekChat.lua`.
4. **UI**: `UIEnhancements` modifies existing chat frames, creating new frames or tabs as needed.
5. **Notifications & Filtering**: `Notifications` and `QoL` handle triggers, highlights, and spam controls.
6. **Linking**: `Linking` extends hyperlink handling, item/quest references, and slash commands for quick linking.
7. **FutureRoadmap**: Contains placeholder or alpha modules that can be optionally enabled.

## Event Handling
Each module uses `Frame:RegisterEvent("EVENT_NAME")` and calls event handlers via `OnEvent` scripts. Additional hooking is done using `ChatFrame_AddMessageEventFilter` or the relevant hook functions to transform or filter chat lines.

## Data Flow
- **`SleekChatDB`**: The main saved variable table in `SleekChat.lua` stores user settings.
- **Config**: Helper table that merges defaults with user preferences.
- **Module API**: Modules can read from the config or create new config keys. Cross-module calls should be minimal, using local or inline functions to keep coupling low.
