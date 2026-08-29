05-Jun-25

Thank you very much for your interest in translating Airdrops mod.

This file describes how to create translations for the mod menus.


To start with, after installing and running the mod for the first time, please copy JSON file(s) from the "en-us_template" folder to your language folder and make your changes there.
You can test the results by reloading all mods in the Cyber Engine Tweaks user interface and then verifying it in the game as described below.

There are two sets of strings in the template file(s):
cetUiStrings - this table contains text entries used only in the CET overlay.
nuiUiStrings - this table contains text entries used in the game's native UI.

The purpose of having the two sets is to handle limited text encoding support in CET UI (as opposed to the game's native UI supporting all languages) and different text formatting.

If you accidentally omit or remove an entry in a translated file or the mod finds it invalid, it will fall back to the default English strings for the entry or the whole strings set at runtime.
Same if the file fails to load for whatever reason.

In case of issues, you could verify technical integrity of your translated JSON text using some free online tools.
E.g. this one: https://jsonlint.com/


Testing:

The mod loads all language files on CET scripts load. If you modify it while the game is running, you should reload mods to update it.
Once loaded, check these areas:
- Airdrops mod window in the CET overlay
- Airdrops mod tab in the Native UI Settings menu


Please note that the content of the template file(s) is a subject to change as the mod evolves or new options are added.
You may need to update your translated files accordingly.
The template files are automatically generated with the currently supported string sets on each mod startup.

Also, some strings are not exposed for translation. E.g. warning/error messages printed to console and logs.


Please feel free to publish your translation as a translation mod at Nexusmods.


Thank you very much.
Anygoodname