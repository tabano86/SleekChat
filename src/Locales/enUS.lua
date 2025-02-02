local L = LibStub("AceLocale-3.0"):NewLocale("SleekChat", "enUS", true, true)

-- General
L.general = "General"
L.general_settings = "General Settings"
L.class_colors = "Class Colors"
L.class_colors_desc = "Color player names by their class"
L.timestamps = "Timestamps"
L.timestamps_desc = "Show timestamps next to messages"
L.url_detection = "URL Detection"
L.url_detection_desc = "Highlight and make URLs clickable"
L.timestamp_format = "Timestamp Format"
L.timestamp_format_desc = "Use Lua date format (e.g. [%H:%M])"
L.max_history_messages = "Max History Messages"
L.max_history_messages_desc = "Maximum number of messages to store in history"
L.background_opacity = "Background Opacity"
L.background_opacity_desc = "Set the chat window background transparency"

-- Appearance
L.appearance = "Appearance"
L.appearance_settings = "Appearance Settings"
L.font = "Font"
L.font_size = "Font Size"
L.tab_unread_highlight = "Unread Tab Highlight"
L.tab_unread_highlight_desc = "Highlight tabs with unread messages"

-- Notifications
L.notifications = "Notifications"
L.notifications_settings = "Notifications Settings"
L.enable_notifications = "Enable Notifications"
L.notification_sound = "Notification Sound"
L.notification_sound_desc = "Select a sound to play when receiving a whisper"
L.sound_volume = "Sound Volume"
L.sound_volume_desc = "Adjust the volume of notification sounds"
L.flash_taskbar = "Flash Taskbar"
L.flash_taskbar_desc = "Flash the game icon when receiving a whisper"

-- System
L.addon_loaded = "SleekChat v%s loaded"
L.whisper_notification = "New whisper from %s"
L.history_copied = "Chat history copied to clipboard"
L.settings_saved = "Settings saved"
L.settings_reset = "Settings reset to defaults"
L.invalid_format = "Invalid timestamp format"
L.open_url_dialog = "Open URL:"
L.open = "Open"
L.cancel = "Cancel"
L.url_copied = "URL copied to clipboard"

-- Debug
L.debug_mode = "Debug Mode"
L.debug_mode_desc = "Show detailed debug information in chat"
L.show_default_chat = "Show Default Chat"
L.show_default_chat_desc = "Keep the original Blizzard chat frame visible"
L.debug_enabled = "Debug mode enabled"
L.debug_disabled = "Debug mode disabled"
L.default_chat_visible = "Default chat frames are now visible"
L.default_chat_hidden = "Default chat frames are now hidden"

-- Layout options
L.layout = "Layout"
L.layout_desc = "Select the chat layout (tabs on top or left)"
L.layout_classic = "Classic (Tabs on top)"
L.layout_transposed = "Transposed (Tabs on left)"

-- Channels
L.channels = "Channels"
L.channel_settings = "Channel Settings"
L.say = "Say"
L.yell = "Yell"
L.party = "Party"
L.guild = "Guild"
L.raid = "Raid"
L.whisper = "Whisper"

return L
