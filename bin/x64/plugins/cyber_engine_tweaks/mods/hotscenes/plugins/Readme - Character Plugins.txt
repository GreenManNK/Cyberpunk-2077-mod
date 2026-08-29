20-May-24

Thank you very much for your interest in creating character plugins for Hotscenes.


To start, you will need a toolbox:

- A game files editor capable of creating/editing entity (ENT) files and character appearance (APP) files and packing them into an ARCHIVE file for the game to load. 
Wolvenkit is strongly recommended here:
https://www.nexusmods.com/cyberpunk2077/mods/2201
Also, you should familiarize yourself with the game files structure and editing.


- Know-how on creating/editing character appearances:
While there is no comprehensive guide known to me at the time of writing, you could use this one as a starting point:
https://wiki.redmodding.org/cyberpunk-2077-modding/for-mod-creators/modding-guides/npcs/appearances-change-the-looks
Please note that it does not cover all appearance technical details.
If you need more information or support, I suggest joining the Cyberpunk 2077 Modding Community Discord server and seeking help there.


--------------------------------------------------------------------------------------------------------------------------

Next, you will need to create some files and ensure they're unique.
This means they won't collide with the game files or with files from other modders by using the same file paths.

Required files:

1) An ARCHIVE file containing game files that your characters use.
2) A metadata JSON file containing descriptions of your characters for the mod to use.


1) The game files required:

Your character requires some game files packed in an ARCHIVE file that will contain data allowing the game to spawn the character and select its appearance in a scene.
The ARCHIVE file serves as a package that should be placed in the game directory.
As it will be mixed with other mod files in a special folder, you should ensure its name will not collide with others so they won't overwrite each other.

In a nutshell, you will need to put at least some entity ENT files in the ARCHIVE files to allow the mod to make the game use it.
You may need to add more game files of various types depending on what you would like to introduce to the game.


ENT files:

You need at least a set of ENT files for your characters that will point to the characters' APP files containing the actual character appearance build data.

There are four JoyToy scenes in the game, each scene requires a separate ENT file.
Please note that internally, Jig-Jig St scenes are named 'Japantown' or 'wbr-jpn,' while Dark Matter scenes are named 'Glen' or 'hey_gle' (despite being well outside Glen).
This document uses the game's internal naming conventions.

The ENT file should be technically compatible with the game's JoyToy characters.
There are four of these files in the game that you could copy and use for your characters:

Japantown Female scene:
	base\open_world\characters\vendors\wbr_jpn_prostitute_female.ent
Japantown Male scene:
	base\open_world\characters\vendors\wbr_jpn_prostitute_male.ent
Glen Female scene:
	base\open_world\characters\vendors\hey_gle_prostitute_female.ent
Glen Male scene:
	base\open_world\characters\vendors\hey_gle_prostitute_male.ent

I'd suggest using a copy of the original game's files and customize it for your character.
Each character must have its own respective ENT file for a scene, separated from others by proper folder and file naming.

The ENT files should contain an appearance map with a set of appearances expected by the game.
In this map, you can specify your preferred APP files by providing their paths and appearance names in the APP file.
You can point to existing game APP files or create your own files - this is where your creativity comes into play.
However, I would not recommend pointing to other mod's internal APP files as there is a risk that the referred file no longer exists in the specified location,
which could cause issues, including game application crashes.

Just make sure to separate your custom ENT and any other custom game files you may need to create from the original game files and other modders' files.
You can achieve this by creating your custom folder structure within your archive folder.
For example:

"...\Cyberpunk\archive\pc\mod\hotscenes_mod_black_hole_creations_mods_characters.archive" file containing:
black_hole_creations_mods
  hotscenes_mod
    characters
        (put you character game files here)


Appearance maps:

Japantown Female scene:

	service__sexworker_wa__ow__poor_01_naked	->	this is a fully naked appearance used in the scene
	service__sexworker_wa__ow__poor_01		->	this is a fully dressed appearance used in the scene
	service__sexworker_wa__ow__poor_01_no_coat	->	this is a dressed appearance without a coat/jacket used in the scene
	service__sexworker_wa__ow__poor_01_strap	->	this is an almost naked appearance with strap-on pants used in the scene
	
Japantown Male scene:
	service__sexworker_ma__ow__poor_01_naked	->	this is a fully naked appearance used in the scene
	service__sexworker_ma__ow__poor_01		->	this is a fully dressed appearance used in the scene

Glen Female scene:
	service__sexworker_wa__ow__luxury_01_naked	->	this is a fully naked appearance used in the scene
	service__sexworker_wa__ow__luxury_01		->	this is a fully dressed appearance used in the scene
	service__sexworker_wa__ow__luxury_01_strap	->	this is an almost naked appearance with strapoon pants used in the scene

Glen Male scene:
	service__sexworker_ma__ow__luxury_01		->	this is a fully dressed appearance used in the scene
	service__sexworker_ma__ow__luxury_01_naked	->	this is a fully naked appearance used in the scene


To customize an appearance entry in your character ENT file for Hotscenes, adjust the appearance entry fields:

	appearanceName		- This is where you input the appearance name located in your APP file. Simply copy the name from the APP file and paste it here.
	appearanceResource	- Input the custom appearance file path here. Copy the path of your APP file and paste it in this field.
	name			- do not edit this field.



2) The JSON metadata files:

You need to create a JSON file containing a description of your characters for the mod to load it.
These files should be located in:

"...\Cyberpunk\bin\x64\plugins\cyber_engine_tweaks\mods\hotscenes\plugins"

Again, please make sure to use unique names, as this folder is a shared storage for plugins from all modders.
I'd suggest creating a folder structure to separate your files from others.
For example:

plugins
	black_hole_creations_mods
		characters
			(put you character JSON files here or create another subfolder to store your JSON files)

You can name the folders and JSON files whatever you like as long as these are valid file system names and the file paths don't exceed the file system path length limits.
The plugins folder tree is scanned up to 3 levels deep for JSON files.


To create the metadata JSON file, just copy the template file:

"..\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\hotscenes\plugins\character_plugin_template.json"

to your folder, rename it and fill it with your character data.
The template file contains comments on what is expected to be included.


You can also refer to the examples file located in the folder:

"..\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\hotscenes\plugins\anygoodname_mods"


If you'd like to share your characters with others, you're welcome to publish your character files as a plugin mod on Nexusmods.


Thank you very much.
Anygoodname