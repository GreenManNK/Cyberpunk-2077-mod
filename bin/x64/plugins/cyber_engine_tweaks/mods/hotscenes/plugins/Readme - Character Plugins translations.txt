04-Aug-24

Thank you very much for your interest in translating character plugins for Hotscenes.


Intro:

While the character plugin records already support translations in the performerFullNameTranslations table,
it may be cumbersome to add a translation for a specific language or character without editing the entire plugin file.
Furthermore, the plugin files do not support merging translations from multiple authors. 
Additionally, as these files are replaced with each new mod or plugin release, any user changes to these translation tables are lost during updates.

The new alternative translation method allows you to add 'targeted' translations on top of the existing ones using separate custom files,
resolving potential conflicts caused by plugin updates or multiple translation providers overwriting the same base file with their own versions.


How it works:

-	The base character plugin file contains character records with performer names defined in the performerFullName fields and possibly translated names in the performerFullNameTranslations tables.
-	If the mod finds a character plugin translation file containing a reference to the base plugin file and matching character records with valid translation alternatives,
	it will use these alternative translations instead of those in the base plugin file.
-	If there are multiple translation files, the data from the files will be merged (e.g., one file containing a German translation, another containing a French translation).
	However, if two or more files contain the same language translation for the same character, the last one loaded will be used.
-	The translation files must reside in the same directory as the base plugin file.

A translation file may contain translations for a single language or multiple languages. However, it's recommended to limit each file to a single language to make it easier for users and other modders to manage the translations.
It is also recommended to name the translation files in a way that makes them easy to identify and manage.
E.g. if the base plugin file name is: little_china_tourists.json, a French translation file could be named: little_china_tourists_fr-fr_translation.json

Please note that, technically, it does not matter how a translation file is named as long as it contains the base plugin file name reference and is a valid JSON file.
The naming convention is only intended to make it easier for users to manage the files and to help resolve file name conflicts if multiple translation files are merged in a folder.


Example:

- The base character plugin file:

hotscenes\plugins\anygoodname_mods\characters\little_china_tourists.json

Contains character records (data limited to the key elements in this example):
{
	"femalePerformers": {
		"mq026__tourist_01": {
			"performerFullName": "Meghan Hattori (tourist)",
		},
		"mq026__tourist_02": {
			"performerFullName": "Airi Okawa (tourist)",
		},
		"youngster_wa_slacker_wa_012": {
			"performerFullName": "Sadie Thorpe (tourist)",
		},
		"youngster_wa_slacker_wa_017": {
			"performerFullName": "Bruna Paiva (tourist)",
		}
	}
}

- To add a German translation, create a JSON file in the same directory with a descriptive name, e.g.:

hotscenes\plugins\anygoodname_mods\characters\little_china_tourists_de-de_translation.json

containing the base plugin file name reference and the corresponding character translation data as follows:
{
	"modName": "Hotscenes",
	"translationAuthorName": "put your name here",
	"translationVer": "put your version identification here",

	"isTranslation": true,
	"translatedFileName": "little_china_tourists.json",
	"femalePerformers": {
		"mq026__tourist_01": {
			"performerFullNameTranslations": {
				"de-de": {"cetUi": "Meghan Hattori (Touristin)", "nativeUi" : "Meghan Hattori (Touristin)"}
			}
		},
		"mq026__tourist_02": {
			"performerFullNameTranslations": {
				"de-de": {"cetUi": "Airi Okawa (Touristin)", "nativeUi" : "Airi Okawa (Touristin)"}
			}
		},
		"youngster_wa_slacker_wa_012": {
			"performerFullNameTranslations": {
				"de-de": {"cetUi": "Sadie Thorpe (Touristin)", "nativeUi" : "Sadie Thorpe (Touristin)"}
			}
		},
		"youngster_wa_slacker_wa_017": {
			"performerFullNameTranslations": {
				"de-de": {"cetUi": "Bruna Paiva (Touristin)", "nativeUi" : "Bruna Paiva (Touristin)"}
			}
		}
	}
}

The fields "isTranslation" and "translatedFileName" are mandatory to identify the file as containing translation data.
You can add other fields e.g. with your name or other data identifiers if you wish to. They may help you or users to learn more details about the file while being ignored by the mod.

Please note that the CET interface is limited on displaying language-specific characters and may require changing font type to support your language.
If a character is not supported by the currently configured CET font, it will display a question mark (?) instead.
Conversely, the game's Native UI has no such limitations for supported languages.

This is the main reason why there are separate string sets for CET and Native UI.
The second reason is that some strings should be adjusted for their respective interfaces, E.g. to fit in the designed space or to adjust line braks in longer text.


If for whatever reason the mod finds an entry invalid (a field or table), it will just skip it and use base data at runtime.
Same if a file fails to load for whatever reason.

In case of issues, you could verify technical integrity of your translated JSON text using some free online tools.
E.g. this one: https://jsonlint.com/


Cyberpunk 2077 LocKey support:
LocKeys are supported only in the NativeUI strings ("nativeUi" fields).
When using LocKeys, please remember to use codes that are available in all supported game versions and don't require the installation of Phantom Liberty or other additional content.
LocKeys support is not enabled in CET strings, as the CET default font cannot display language-specific characters beyond the ASCII8 Latin encoding table.
While internally all CET strings are processed as UTF, the font glyph set is limited at the time of writing this text.


Thank you very much.
Anygoodname