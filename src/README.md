Below is a final, comprehensive README that covers an extensive array of quality‑of‑life (QoL) features—all within the chat domain—for a WoW Classic plugin. Every feature is designed to work strictly within Blizzard’s policies and WoW Classic’s API limitations, enhancing the chat experience without stepping outside its domain.

* * *

**SleekChat v2.0 – The Ultimate Chat Enhancement for WoW Classic**
==================================================================

SleekChat v2.0 is a modular, lightweight addon that reimagines the WoW Classic chat experience. By extending the native chat functionality—without replacing or conflicting with it—SleekChat delivers a rich set of features tailored specifically for chat users. It integrates with popular addons and preserves user settings automatically, ensuring a seamless and compliant upgrade to your chat system.

* * *

**Core Goals & Feasibility**
----------------------------

*   **Chat Domain Focus:**  
    All features strictly enhance chat functionality—from dynamic organization and smart filtering to advanced linking and contextual actions—without venturing into external domains.

*   **Seamless Integration:**  
    Hooks into the default chat system and popular addons (Prat 3.0, WIM, BadBoy, etc.) using Blizzard-approved methods.

*   **Automatic Settings Persistence:**  
    User configurations (tabs, filters, themes, and more) are saved and migrated across updates.

*   **Policy‑Compliant:**  
    No automated message sending or external data transfers; all functionality is implemented using in‑game data and approved API calls.


* * *

**Key Chat Enhancements**
-------------------------

### **A. Core Chat Organization & UI Improvements**

*   **Dynamic Tab & Channel Management:**
    *   Create, rename, reorder, and manage chat tabs.
    *   Smart routing of whispers, combat logs, and system messages.
*   **Auto‑Hiding Input Bar & Resizable Windows:**
    *   Input bar appears only on typing.
    *   Chat frames are draggable, resizable, and snap-to-edge.
*   **Custom Font & Theme Options:**
    *   Choose between Dark Mode, custom color schemes, and scalable fonts.
*   **Message Pinning & Extended Scrollback:**
    *   Pin important messages temporarily.
    *   Increase the scrollback buffer length within session limits.
*   **Auto‑Rejoin Channels:**
    *   Automatically rejoin preferred channels (LFG, Trade, etc.) on login.
*   **Tab‑Specific Mute & Prioritization:**
    *   Mute or emphasize specific channels as desired.

### **B. Smart Notifications & Filtering**

*   **Customizable Ping Alerts:**
    *   Audio/visual alerts based on channels, keywords, or regex patterns.
*   **Regex‑Based Filtering & Keyword Highlighting:**
    *   Define custom rules to highlight or suppress specific text patterns.
*   **Anti‑Spam Integration:**
    *   Works with addons like BadBoy to filter spam and gold seller messages.
*   **Guild & Raid Announcement Pinning:**
    *   Keep critical messages visible for the entire session.

### **C. Advanced Linking & In‑Chat Integrations (15+ Must‑Have Features)**

1.  **Character Linking:**
    *   Click a player’s name to display a profile snippet (class, level, notes).
2.  **Enhanced Item Linking:**
    *   Improved tooltips for items, with extra details (stats, quality, etc.).
3.  **Achievement Linking:**
    *   Rich tooltips showing progress and details when linking achievements.
4.  **Profession Linking:**
    *   Hover on linked professions to view known tradeskills and recipes.
5.  **Custom Link Filters:**
    *   Define filters to suppress duplicate links or emphasize rare items.
6.  **Quick Hyperlink Copy/Paste:**
    *   One-click copy of item, achievement, or character links from chat.
7.  **In‑Chat Linking Commands:**
    *   Slash commands like `/linkchar` or `/linkitem` to quickly insert formatted links.
8.  **In‑Chat Character Bio Display:**
    *   Hovering over a name can optionally show a short bio or note (if configured).
9.  **Auto‑Formatting of Gear Links:**
    *   Color coding and formatting based on item rarity.
10.  **Auction House Lookup Integration:**
     *   Quick AH addon lookup options embedded in item links.
11.  **Social Context Menu for Links:**
     *   Right‑click on names for quick actions (add friend, invite, report).
12.  **Chat Bubble Link Enhancement:**
     *   Clickable links in chat bubbles following Blizzard’s tooltip standards.
13.  **Cross‑Tab Message Linking:**
     *   Copy unique identifiers from messages to reference them across tabs.
14.  **Quick Link Export:**
     *   Export chat logs with active hyperlinks (formatted as plain text or HTML).
15.  **Advanced Linking Shortcuts:**
     *   Commands like `/lastchar` to generate a link for your most recent character.
16.  **Emoji & Emote Formatting:**
     *   Enhance and format emotes in chat for better visibility.
17.  **Clickable Channel Aliases:**
     *   Define and click custom aliases for channels (e.g., “LFG” for LookingForGroup).
18.  **Hyperlink History Navigation:**
     *   A feature to quickly navigate between previously clicked links.
19.  **Link Bookmarking:**
     *   Save important links for later review during a session.
20.  **Enhanced Tooltip Comparison:**
     *   When hovering over item links, compare similar items (if data is available).

### **D. Additional Chat Quality‑of‑Life Features (15+ Additions)**

1.  **In‑Chat Search & Filtering:**
    *   Search history instantly using an in‑chat search box.
2.  **Custom Scroll Speed Control:**
    *   Adjust scroll speed to match your reading pace.
3.  **Chat Log Export/Import:**
    *   Manual export of chat history for archival purposes.
4.  **Timestamp Customization:**
    *   Options for 12‑hour/24‑hour formats, and server/local time displays.
5.  **Inactivity Timer & Auto‑AFK Indicator:**
    *   Visual cues for when you’re idle.
6.  **Clickable Player Names for Quick Actions:**
    *   Quickly whisper, invite, or report by clicking names.
7.  **Auto‑Scroll Lock Toggle:**
    *   Pause auto-scrolling in busy channels to catch up on messages.
8.  **Enhanced Emote Display:**
    *   Differentiate emotes with distinct formatting or color.
9.  **Guild Roster Quick Access:**
    *   A clickable icon in chat to instantly open the guild roster.
10.  **Channel Filter Presets:**
     *   Predefined filters to quickly switch between views (e.g., “Guild Only”).
11.  **Custom Sound Cues:**
     *   Assign unique sound effects for specific keywords or events.
12.  **In‑Chat Macro Buttons:**
     *   Clickable buttons in the chat frame for common commands.
13.  **Unread Message Badges:**
     *   Visual badges on tabs indicating unread messages.
14.  **Conversation Bookmarking:**
     *   Mark specific moments in chat to return to later.
15.  **Enhanced Chat Bubble Transparency & Borders:**
     *   Customize the look of chat bubbles for better readability.

* * *

**Installation & Setup**
------------------------

1.  **Download & Install:**
    *   Copy the `SleekChat` folder into your `Interface/AddOns` directory.
2.  **Launch WoW:**
    *   SleekChat automatically detects your installed addons and configures itself at startup—no manual slash commands required.
3.  **Enjoy the Upgraded Chat Experience:**
    *   All settings and QoL features activate immediately, preserving your preferences and enhancing every chat interaction.

* * *

**Future Roadmap**
------------------

*   **Enhanced Combat Log Grouping:**
    *   Smarter filtering and grouping for combat-related messages.
*   **Loot Spam Management:**
    *   Further options to filter repetitive loot messages.
*   **Raid Coordination Enhancements:**
    *   Tools to better organize raid leader communications.
*   **Expanded UI Themes & Customization:**
    *   More options based on community feedback.
*   **Advanced Manual Chat Log Export:**
    *   Refinements for a more robust archival system with full hyperlink support.

* * *

**Conclusion**
--------------

SleekChat v2.0 delivers a complete suite of chat-focused QoL enhancements for WoW Classic. Every feature—from dynamic tab management and regex‑based filtering to advanced linking (character, item, achievement, profession) and an array of additional in‑chat conveniences—stays entirely within the chat domain and adheres to Blizzard’s policies. This comprehensive enhancement promises a cleaner, more organized, and highly interactive chat experience for both WoW veterans and new players alike.

