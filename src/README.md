Below is an updated README that not only describes the feature set and integration strategy for SleekChat v2.0 but also outlines the overall project architecture, directory structure, and considerations for extensibility, CI/CD, and modularity. This design is intended to support a robust, maintainable addon that can grow over time while strictly remaining within the WoW Classic API and Blizzard policies.

* * *

**SleekChat v2.0 – Enhancing WoW Classic Chat (Not Replacing It!)**
===================================================================

SleekChat v2.0 is a modular, lightweight addon that builds on top of WoW Classic’s default chat system. Our goal is to extend and enhance the existing chat functionality—improving dynamic tab management, filtering, advanced linking, and many other quality‑of‑life features—without replacing the built‑in chat app. By using approved API hooks and a modular architecture, SleekChat integrates seamlessly with the default system and with popular addons like Prat 3.0, WIM, and BadBoy.

* * *

**Core Goals & Integration Strategy**
-------------------------------------

*   **Enhance, Don’t Replace:**

    *   **Default Chat Preservation:** Our addon hooks into existing chat frames to add new features while keeping all native behaviors intact.
    *   **Seamless Hooking:** Features such as advanced linking, smart filtering, and dynamic UI adjustments overlay the default system using Blizzard‑approved API calls.
*   **Policy‑Compliant Enhancements:**

    *   All data and functions use in‑game APIs, saved variables, and approved UI modification methods.
    *   No automated messaging, external data transfers, or violations of Blizzard’s secure frame rules.
*   **Automatic Settings Persistence:**

    *   User settings (tab layouts, filters, themes, linking preferences, etc.) are stored in saved variables and automatically migrated across updates.
    *   Integration with other addons is auto‑detected at startup, eliminating manual configuration via slash commands.

* * *

**Key Feature Categories (All Within the Chat Domain)**
-------------------------------------------------------

**A. Core Chat Organization & UI Improvements**

*   Dynamic Tab & Channel Management
*   Auto‑Hiding Input Bar & Resizable Windows
*   Custom Font & Theme Options
*   Message Pinning & Extended Scrollback
*   Auto‑Rejoin Preferred Channels
*   Tab‑Specific Mute & Prioritization

**B. Smart Notifications & Filtering**

*   Customizable Ping Alerts & Regex‑Based Keyword Highlighting
*   Anti‑Spam & LFG/Trade Filtering (integrated with BadBoy)
*   Guild & Raid Announcement Pinning

**C. Advanced Linking & In‑Chat Integrations (20+ Features)**

*   Character, Item, Achievement, and Profession Linking
*   Custom Link Filters & Hyperlink Copy/Paste
*   In‑Chat Linking Commands and Shortcut Generation
*   Social Context Menus and Auction House Lookup Integration
*   Enhanced Tooltip Comparison and Link Bookmarking

**D. Additional Chat Quality‑of‑Life Features (15+ Enhancements)**

*   In‑Chat Search & Filtering, Custom Scroll Speed
*   Chat Log Export/Import and Timestamp Customization
*   Inactivity Timer, Clickable Names, and Auto‑Scroll Lock
*   Enhanced Emote Display and Guild Roster Quick Access
*   Channel Filter Presets, Custom Sound Cues, Macro Buttons, etc.

**E. Future Roadmap (Planned Enhancements as Modules)**

*   Enhanced Combat Log Grouping
*   Loot Spam Management
*   Advanced Raid Coordination Tools
*   Expanded UI Themes & Customization
*   Advanced Manual Chat Log Export

* * *

**Project Architecture & Structure**
------------------------------------

To ensure extensibility and maintainability, each feature group is developed as a separate module. This modular design allows for independent development, testing, and CI/CD integration.

### **Languages & Technologies**

*   **Lua:** Primary scripting language for WoW addons.
*   **XML:** Used for defining UI layouts and frames.
*   **YAML/JSON:** For CI/CD configuration (e.g., GitHub Actions).
*   **Documentation:** Markdown files for developer and user guides.

### **Directory Structure**

```
SleekChat/
├── README.md                   # Project overview, features, and usage instructions.
├── LICENSE                     # Open-source license file.
├── .github/                    
│   └── workflows/
│       └── ci.yml              # CI/CD pipeline configuration for linting and tests.
├── docs/                       
│   ├── Architecture.md         # Detailed architectural decisions and module integration.
│   └── FeatureModules.md       # Documentation on each feature module.
├── Modules/                    
│   ├── CoreChat/               # Core chat enhancements module.
│   │   ├── CoreChat.lua
│   │   ├── CoreChat.xml
│   │   └── CoreChatConfig.lua
│   ├── UIEnhancements/         # UI improvements module.
│   │   ├── UIEnhancements.lua
│   │   └── UIEnhancements.xml
│   ├── Notifications/          # Custom notifications & filtering.
│   │   └── Notifications.lua
│   ├── Linking/                # Advanced linking and in‑chat integrations.
│   │   └── Linking.lua
│   ├── QoL/                    # Additional chat quality‑of‑life features.
│   │   └── QoL.lua
│   └── FutureRoadmap/          # Placeholder modules for future features.
│       └── CombatLogEnhancement.lua
├── Config/                     
│   └── Config.lua              # Global configuration and settings management.
├── SavedVariables/             
│   └── SleekChat.lua           # Saved variables file for persistent user settings.
└── Assets/                     
    ├── Icons/                  # Iconography for UI enhancements.
    └── Themes/                 # Theme and color scheme assets.

```


### **Extensibility & CI/CD**

*   **Modular Development:** Each module resides under `Modules/` and is designed to be independent. New features can be added as separate modules and integrated via a central configuration.
*   **CI/CD Pipeline:**
    *   **GitHub Actions:** A CI pipeline (`.github/workflows/ci.yml`) runs linting (using Lua linters) and basic tests (if applicable) on each push to ensure code quality.
    *   **Automated Tests:** Where possible, non‑UI logic is unit tested.
*   **Documentation:** Detailed architecture and feature-specific documentation are maintained in the `docs/` directory.
*   **Versioning:** Semantic versioning is applied, and release notes are generated to track changes, including migration of user settings between updates.

* * *

**Installation & Setup**
------------------------

1.  **Download & Install:**  
    Copy the entire `SleekChat` folder into your `Interface/AddOns` directory.

2.  **Launch WoW:**  
    On startup, SleekChat auto‑detects installed addons and integrates with the default chat system. No manual slash commands are required—the addon applies all enhancements automatically.

3.  **Enjoy the Enhanced Experience:**  
    Your chat now includes advanced tab management, smart filtering, enhanced linking, and many quality‑of‑life improvements, all while preserving native chat functionality.


* * *

**Future Roadmap (as Features/Modules)**
----------------------------------------

*   **Enhanced Combat Log Grouping:**  
    Smarter filtering and grouping for combat messages.
*   **Loot Spam Management:**  
    Additional options for filtering repetitive loot messages.
*   **Raid Coordination Tools:**  
    Advanced features for organizing raid leader communications.
*   **Expanded UI Themes & Customization:**  
    More visual options and theme support.
*   **Advanced Manual Chat Log Export:**  
    Richer archival options with full hyperlink support.

* * *

**Conclusion**
--------------

SleekChat v2.0 is a fully feasible, policy‑compliant enhancement that integrates with and builds upon the default WoW Classic chat system. Its modular architecture, extensive feature set, and robust CI/CD practices ensure a maintainable, extensible addon that will continue to evolve. Whether you’re a WoW Classic veteran or a new player, SleekChat provides a smarter, more connected chat experience—without reinventing the wheel.

* * *

💬 **Join the Community & Contribute**  
Visit our [GitHub Repository](#) for updates, issue tracking, and contributions.

* * *

### **Have We Thought of Everything?**

Within the chat domain, our architecture covers every key aspect—from dynamic UI enhancements and advanced linking to comprehensive QoL improvements and a clear future roadmap. Our modular design means we can add features as needed while preserving the default chat system’s integrity. Enjoy a smarter, more connected chat experience with SleekChat v2.0!

* * *
