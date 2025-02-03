# SleekChat v2.0 – Director's Cut

SleekChat v2.0 is a modular, policy-compliant WoW Classic addon that integrates with the default chat system to provide advanced features like dynamic tab management, smart filtering, advanced linking, and a wealth of quality-of-life improvements.

## Key Features

- **Enhanced Chat Organization:** Dynamic tab/channel management, auto-hiding input bar, custom fonts/themes, extended scrollback, and more.
- **Smart Notifications & Filtering:** Keyword highlighting, spam filtering, guild/raid announcement pinning, regex-based triggers, etc.
- **Advanced Linking & Integrations:** Item, quest, achievement linking, in-chat slash commands, social context menus, auction house lookups, and more.
- **Quality-of-Life Upgrades:** In-chat search, chat log export/import, inactivity timer, custom channel filter presets, macro buttons, localization support, and more.
- **Future Roadmap (Modules):** Combat log grouping, loot spam management, advanced raid coordination tools, expanded UI themes, advanced manual chat log exports.

## Installation

1. **Download & Install**  
   Copy the `SleekChat` folder into `Interface/AddOns` in your WoW directory (e.g., `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\`).

2. **Launch WoW**  
   SleekChat auto-detects installed addons and merges with the default chat system. Just log in!

3. **Enjoy**  
   Explore the rich set of features without replacing the built-in chat. Type `/sleekchat` for basic commands and help.

## Contributing

Contributions, bug reports, and feature requests are welcome. See our GitHub for details on how to open issues or pull requests.

## Local Development

Below are some tips for **Windows** users to set up and test SleekChat in a local development environment:

### 1. Symbolic Links (Recommended)

- **Why?** Keep your source in a Git-tracked folder while WoW sees it in the `AddOns` directory—no manual copying after every change.
- **How?**
    1. Put the addon files in a local project folder (e.g. `C:\Users\<YourName>\Projects\SleekChat`).
    2. Remove/rename any existing `SleekChat` folder under WoW’s `AddOns`.
    3. From an **Administrator** Command Prompt:
       ```cmd
       mklink /J "C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\SleekChat" "C:\Users\<YourName>\Projects\SleekChat"
       ```
       Adjust the paths if your WoW install is located elsewhere.

- Once linked, **any edits in your local folder** appear in WoW immediately. Simply type `/reload` in-game to load the changes.

### 2. Linting & Automated Checks

- **LuaCheck** is the standard linter for Lua code.
- Install it on Windows via [Chocolatey](https://chocolatey.org/) or use Windows Subsystem for Linux (WSL).
  ```bash
  choco install luacheck


---

### [Local Development](./docs/LocalDevelopment.md)
