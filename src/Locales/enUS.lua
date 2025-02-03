<Ui xmlns="http://www.blizzard.com/wow/ui/">
<!-- Libraries (Ace, etc.) -->
<Script file="Libs\LibStub\LibStub.lua"/>
<Script file="Libs\AceAddon-3.0\AceAddon-3.0.lua"/>
<Script file="Libs\AceDB-3.0\AceDB-3.0.lua"/>
<Script file="Libs\AceConfig-3.0\AceConfig-3.0.lua"/>
<Script file="Libs\AceConsole-3.0\AceConsole-3.0.lua"/>
<Script file="Libs\AceEvent-3.0\AceEvent-3.0.lua"/>
<Script file="Libs\AceTimer-3.0\AceTimer-3.0.lua"/>
<Script file="Libs\AceLocale-3.0\AceLocale-3.0.lua"/>
<Script file="Libs\LibSharedMedia-3.0\LibSharedMedia-3.0\LibSharedMedia-3.0.lua"/>

<!-- Localization -->
<Include file="Locales\enUS.lua"/>

<!-- Core modules -->
<Include file="Core\Core.lua"/>
<Include file="Core\Config.lua"/>
<Include file="Core\Events.lua"/>

<!-- Additional modules -->
<Include file="Modules\Hooks.lua"/>
<Include file="Modules\History.lua"/>
<Include file="Modules\ChatModeration.lua"/>
<Include file="Modules\Notifications.lua"/>
<Include file="Modules\Integration.lua"/>
<Include file="Modules\AdvancedMessaging.lua"/>

<!-- The tab-based UI -->
<Include file="Modules\ChatTabs.lua"/>
</Ui>
