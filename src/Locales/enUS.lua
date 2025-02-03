local L= LibStub("AceLocale-3.0"):NewLocale("SleekChat","enUS",true,true)

L.addon_loaded= "SleekChat v%s loaded"
L.general_settings= "General Settings"
L.show_default_chat= "Show Default Chat"
L.show_default_chat_desc= "Keep Blizzard's chat frames visible"
L.debug_mode= "Debug Mode"
L.debug_mode_desc= "Show debug logs"
L.debug_enabled= "Debug mode enabled"
L.debug_disabled="Debug mode disabled"

L.timestamps= "Timestamps"
L.timestamps_desc= "Show timestamps"
L.timestamp_format= "Timestamp Format"
L.timestamp_format_desc= "Use e.g. [%H:%M]"

L.invalid_format= "Invalid timestamp format"
L.open_url_dialog= "Open URL:"
L.open="Open"
L.cancel="Cancel"
L.url_copied="URL copied to clipboard"
L.settings_reset="Settings reset to defaults"

L.appearance_settings="Appearance"
L.dark_mode="Dark Mode"
L.dark_mode_desc="Toggle dark theme"
L.background_opacity= "Background Opacity"
L.background_opacity_desc="How transparent the chat window is"
L.font="Font"
L.font_size="Font Size"

L.notifications_settings="Notifications"
L.enable_notifications="Enable Notifications"
L.notification_sound="Notification Sound"
L.notification_sound_desc="Sound to play on whisper"
L.sound_volume="Sound Volume"
L.sound_volume_desc="Volume for notifications"
L.flash_taskbar="Flash Taskbar"

L.whisper_notification="New whisper from %s"

return L
