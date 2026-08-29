18-Aug-24

Thank you very much for your interest in translating Native Settings UI Side Menu Add-on mod.

This file describes how to create translations for the mod menus.


To start with, please copy JSON file(s) from the "en-us_template" folder to your language folder and make your changes there.
You can test the results by reloading all mods in the Cyber Engine Tweaks user interface and then verifying it in the Native Settings UI Side Menu Add-on mod tab.

If you accidentally omit or remove an entry in a translated file or the mod finds it invalid, it will fall back to the default English strings for the entry or the whole strings set at runtime.
Same if the file fails to load for whatever reason.

In case of issues, you could verify technical integrity of your translated JSON text using some free online tools.
E.g. this one: https://jsonlint.com/


Cyberpunk 2077 LocKey support:
LocKeys are supported only in the Native UI strings (texts that are displayed in the game interface, not in the CET overlay windows).
When using LocKeys, please remember to use codes that are available in all supported game versions and don't require the installation of Phantom Liberty or other additional content.


Testing:

The mod loads all language files on CET scripts load. If you modify it while the game is running, you should reload mods to update it.
Once loaded, check these areas:
- Native Settings UI Side Menu Add-on mod tab


Please note that the content of the template file(s) is a subject to change as the mod evolves or new options are added.
You may need to update your translated files accordingly.
The template files are automatically generated with the currently supported string sets on each mod startup.

Also, some strings are not exposed for translation. E.g. warning/error messages printed to console and logs.


Please feel free to publish your translation as a translation mod at Nexusmods.


Thank you very much.
Anygoodname