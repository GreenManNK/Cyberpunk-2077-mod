04-Aug-24

Thank you very much for your interest in translating Hotscenes files.


This file describes how to create translations for the mod menus, built-in characters, and destination lists.
It does not cover the translation of character plugins.
If you would like to translate the plugins, please refer to the file: "hotscenes\plugins\Readme - Character Plugins translations.txt"


To start with, please copy JSON files from the "en-us_template" folder to your language folder and make your changes there.
You can test the results by reloading all mods in the Cyber Engine Tweaks user interface and then verifying it in the Hotscenes mod windows.

The translation breaks down into several files:

cetUiStrings		these are menu and onscreen strings that show up in the mod's CET UI.
nuiUiStrings		these are menu and onscreen strings that show up in the mod's Native UI and Native Settings UI.
performerStrings	these are performer names that show up in the mod's CET UI and Native UI
destinationStrings	these are scene destination strings that show up in the mod's CET UI and Native UI

Please note that the CET interface is limited on displaying language-specific characters and may require changing font type to support your language.
If a character is not supported by the currently configured CET font, it will display a question mark (?) instead.
Conversely, the game's Native UI has no such limitations for supported languages.

This is the main reason why there are separate string sets for CET and Native UI.
The second reason is that some strings should be adjusted for their respective interfaces, E.g. to fit in the designed space or to adjust line braks in longer text.

If you accidentally omit or remove an entry or the mod finds it invalid, it will fall back to the default English strings for the entry or the whole strings set at runtime.
Same if a file fails to load for whatever reason.

In case of issues, you could verify technical integrity of your translated JSON text using some free online tools.
E.g. this one: https://jsonlint.com/


Cyberpunk 2077 LocKey support:
LocKeys are supported only in the NativeUI strings.
When using LocKeys, please remember to use codes that are available in all supported game versions and don't require the installation of Phantom Liberty or other additional content.
LocKeys support is not enabled in CET strings, as the CET default font cannot display language-specific characters beyond the ASCII8 Latin encoding table.
While internally all CET strings are processed as UTF, the font glyph set is limited at the time of writing this text.


Testing:

The mod loads all language files on CET scripts load. If you modify it while the game is running, you should reload mods to update it.
Once loaded, check these areas:
- CET key bindings window,
- Mod's CET menu,
- Mod's Native UI menu,
- Native Settings menu,
- Onscreen warning messages.

To test onscreen warning messages, open the CET console and type a command pointing to the message you would like to show.
E.g.
GetMod("hotscenes").testWarningMessage("playback.timeout")
GetMod("hotscenes").testWarningMessage("actionUnavailable.header")
GetMod("hotscenes").testWarningMessage("actionUnavailable.inCombat")
GetMod("hotscenes").testWarningMessage("hotscenesUnavailable.header")
GetMod("hotscenes").testWarningMessage("hotscenesUnavailable.isCensored")


Please also note that the content of the template files is a subject to change as the mod evolves or new characters or destinations are added.
You may need to update your translated files accordingly.
The template files are automatically generated with the currently supported string sets on each mod startup.

Also, some strings are not exposed for translation. E.g. warning/error messages printed to console and logs.


Please feel free to publish your translation as a translation mod at Nexusmods.


Thank you very much.
Anygoodname