local addonName, SleekChat = ...
SleekChat = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
SleekChat.modules = {}
_G[addonName] = SleekChat
