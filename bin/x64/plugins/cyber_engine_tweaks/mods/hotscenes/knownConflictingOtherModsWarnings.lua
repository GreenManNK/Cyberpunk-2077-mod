-- Apr 22, 2026 by (c)anygoodname

local moduleVer = 'v1.15.0'
local moduleName = 'Hotscenes known conflicting other mods warning list'
local modAuthorName = 'anygoodname'

--[[ DISCLAIMER:

This mod is a non-commercial fan creation intended for personal use only.

By using the word "republish" I mean both republish and redistribute in this disclaimer:
You're not allowed to republish the mod without my consent or against the Nexusmods rules.
You're not allowed to republish parts of this mod code or files without consent. Either mine either other authors.
You can modify the mod code or files for your personal use only.
By modifying the mod code or files, you acknowledge I cannot support the modified mod code or files.
You're not allowed to publish your modifications to the mod code or files without my consent.
You're not allowed to publicly propose unauthorized changes to the mod code or files.
You're not allowed to use any part of the mod code or files for commercial purposes, advertising or promotion of any kind.
You can use the mod code and files to learn how to code this game mods and improve your skills.
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

local worldEditConflictDescSuffix = " Conflict type: Visual only - clipping or floating due to added custom objects or moved original ones."

local conflictDescAptH10 = "Known to add world edits that conflict with H10 V\'s Apartment Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescAptJpn = "Known to add world edits that conflict with Japantown Apartment Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescAptGle = "Known to add world edits that conflict with Glen Apartment Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescAptCtc = "Known to add world edits that conflict with Corpo Plaza Apartment Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescAptVar = "Known to add world edits that conflict with several apartment Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescCustomUrmland = "Known to add world edits that conflict with the Night City Delights Urmland St scene location."..worldEditConflictDescSuffix
local conflictDescCustomMarina = "Known to add world edits that conflict with the Night City Delights Gold Beach Marina scene location."..worldEditConflictDescSuffix
local conflictDescCustomArasakaHotel = "Known to add world edits that conflict with the Konpeki Plaza scene location."..worldEditConflictDescSuffix
local conflictDescCustomPathOfGlory = "Known to add world edits that conflict with Path of Glory Penthouse Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescCustomVar = "Known to add world edits that conflict with some of Hotscenes custom scene locations."..worldEditConflictDescSuffix
local conflictDescDefaultDarkMatter = "Known to add incompatible world edits that conflict with the game's native Dark Matter JoyToy room scene."..worldEditConflictDescSuffix

local knownConflictingOtherMods = {
	{
		modTitle = "Hangout Romances",
		modAuthor = "sfasvafvadevrtar",
		modArchiveFileName = "HangoutsRomances.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = "Some versions of that mod are known to add edits that are inconsistent with the game\'s original hangout scenes, affecting the expected game behavior and the functionality of this mod as a result.",
		disableFeatureNote = "In a bid to prevent severe issues caused by that mod, Hotscenes may be forced to disable its Hangouts integration feature if it finds it cannot overcome these issues.",
		isAddOnRelated = true
	},
	{
		modTitle = "Apartments Enhanced - Archive XL",
		modAuthor = "Ak3nax",
		modArchiveFileName = "Apartments_Enhanced_Core.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptVar,
		isAddOnRelated = true
	},
	{
		modTitle = "THE GLEN PROJECT. AXL",
		modAuthor = "Ak3nax",
		modArchiveFileName = "TheGlenProject.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "JUNGLE RUNNER - H10 Apt - Enhanced",
		modAuthor = "ellios2normandie",
		modArchiveFileName = "Apt_H10_JungleRunner.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "V\'s Mansion Redux - NeoZen",
		modAuthor = "ProximaDust",
		modArchiveFileName = "vs_mansion_neozen.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomPathOfGlory,
		isAddOnRelated = true
	},
	{
		modTitle = "Corpo Plaza apartment - Comfy living - ArchiveXL",
		modAuthor = "unthinkthis",
		modArchiveFileName = "corpo_plaza_apartment_comfy_living.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptCtc,
		isAddOnRelated = true
	},
	{
		modTitle = "Asian Corpo Plaza apartment - archivexl",
		modAuthor = "unthinkthis",
		modArchiveFileName = "corpo_plaza_asian_apartment.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptCtc,
		isAddOnRelated = true
	},
	{
		modTitle = "Luxury corporate the Glen apartment - archivexl",
		modAuthor = "unthinkthis",
		modArchiveFileName = "luxe_glen_apartment.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Cyber Den - apartment h10 - archivexl",
		modAuthor = "unthinkthis",
		modArchiveFileName = "cyber_den_apartment_h10.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Rebel Path - Apartment H10 - archivexl",
		modAuthor = "unthinkthis",
		modArchiveFileName = "rebel_path_corpo_apartment_h10.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Dark Matter Club ( with Apartment )",
		modAuthor = "TheRealJonCross",
		modArchiveFileName = "dark_matter.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescDefaultDarkMatter
	},
	{
		modTitle = "Dark Matter Club ( with Apartment )",
		modAuthor = "TheRealJonCross",
		modArchiveFileName = "RJC_dark_matter.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescDefaultDarkMatter
	},
	{
		modTitle = "Downtown Yacht",
		modAuthor = "TheRealJonCross",
		modArchiveFileName = "downtown_yacht.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomMarina,
		isAddOnRelated = true
	},
	{
		modTitle = "Downtown Yacht",
		modAuthor = "TheRealJonCross",
		modArchiveFileName = "RJC_downtown_yacht.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomMarina,
		isAddOnRelated = true
	},
	{
		modTitle = "Konpeki Plaza Expanded ( with Apartment )",
		modAuthor = "TheRealJonCross",
		modArchiveFileName = "konpeki_plaza.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomArasakaHotel,
		isAddOnRelated = true
	},
	{
		modTitle = "Konpeki Plaza Expanded ( with Apartment )",
		modAuthor = "TheRealJonCross",
		modArchiveFileName = " RJC_konpeki_plaza.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomArasakaHotel,
		isAddOnRelated = true
	},
	{
		modTitle = "DIGITAL OASIS - H10 Apartment",
		modAuthor = "brocreate",
		modArchiveFileName = "NUT_H10digitaloasis_AXL.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "JUNGLE RUNNER - H10 Apartment",
		alternativeModTitle = "JUNGLE RUNNER - TEST",
		modAuthor = "brocreate",
		modArchiveFileName = "NUT_H10junglerunner_AXL.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "CLUB 27 - Glen Apartment",
		modAuthor = "brocreate",
		modArchiveFileName = "NUT_glenclub27_AXL.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Night City Enhanced and Expanded - NPCs",
		modAuthor = "Xurec",
		modArchiveFileName = "NCEE NPC.archive",
		hasMultipleAssociatedArchiveFiles = true,
		modCetFolderName = "NCEE-NPC",
		reason = conflictDescCustomVar,
	},
	{
		modTitle = "spawn0 - BODY MOD 2.0",
		modAuthor = "spawn00000",
		modArchiveFileName = "SP0 BODY MOD assets.archive",
		hasMultipleAssociatedArchiveFiles = true,
		modCetFolderName = "sp0_BODYMOD",
		reason = "Known to cause various issues by modifying fundamental Player design data and the game\'s default NPCs, which may prevent the Night City Delights feature from accessing some female characters in the game.",
		isAddOnRelated = true
	},
	{
		modTitle = "Underwear Remover",
		modAuthor = "Sorrow446",
		modArchiveFileName = "basegame_underwear_patch.archive",
		reason = "Known to introduce changes that break the game\'s Player design consistency, resulting in incompatibilities affecting the Player body, garment and quests systems.",
	},
	{
		modTitle = "Gomorrah Night Club",
		modAuthor = "LiquidBronze",
		modArchiveFileName = "Gomorrah_Standalone.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomUrmland,
		isAddOnRelated = true
	},
	{
		modTitle = "Urmland Street Changes",
		modAuthor = "LiquidBronze",
		modArchiveFileName = "Urmland_Street_Changes.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescCustomUrmland,
		isAddOnRelated = true
	},
	{
		modTitle = "V\'s Modest Netrunner Apartment",
		modAuthor = "ThaFunktopus",
		modArchiveFileName = "VMNA.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Glen Apartment Expanded - Redux",
		modAuthor = "ThaFunktopus",
		modArchiveFileName = "GlenApartmentExpanded.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Japantown Apartment Redesign - Studio Apartment",
		modAuthor = "Vehlir",
		modArchiveFileName = "japantown_studio_apartment_vehlir.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "H10 Apartment redesigned",
		modAuthor = "emaaaris",
		modArchiveFileName = "H10 Apartment.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Glen Apartment REDESIGNED",
		modAuthor = "emaaaris",
		modArchiveFileName = "ris_GLEN_APT_MAINFILES.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Najiva\'s Glen Apartment",
		modAuthor = "Najiva",
		modArchiveFileName = "Najiva_glen_apartment_1.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Oasis",
		modAuthor = "Kali8229",
		modArchiveFileName = "Neon Oasis Act I_F.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Oasis",
		modAuthor = "Kali8229",
		modArchiveFileName = "Neon Oasis Act I_M.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Oasis",
		modAuthor = "Kali8229",
		modArchiveFileName = "NeonOasis_ActI.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Oasis",
		modAuthor = "Kali8229",
		modArchiveFileName = "NeonOasis_ActII.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Oasis",
		modAuthor = "Kali8229",
		modArchiveFileName = "NeonOasis_ActII_Alt.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Oasis",
		modAuthor = "Kali8229",
		modArchiveFileName = "NeonOasis_ActI_Alt.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Kdada-H10apartment",
		modAuthor = "KVdididi",
		modArchiveFileName = "Kdada-H10GONGYU.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Japantown00 Apartment",
		modAuthor = "yuyu69",
		modArchiveFileName = "r_japanvjt.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "Japantown00 Apartment",
		modAuthor = "yuyu69",
		modArchiveFileName = "r_japantownapartment00.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "Japantown00 Apartment",
		modAuthor = "yuyu69",
		modArchiveFileName = "r_japankerryjt.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "Japantown00 Apartment",
		modAuthor = "yuyu69",
		modArchiveFileName = "r_japanpanamjt.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "Japantown00 Apartment",
		modAuthor = "yuyu69",
		modArchiveFileName = "r_rysjapanriverjt.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "H10 netrunner appartment",
		modAuthor = "Lukarkat",
		modArchiveFileName = "H10 netrunner.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "the glen v.1",
		modAuthor = "digitalb0yfriend",
		modArchiveFileName = "the glen v.1 + balconies.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "soft club corpo plaza",
		modAuthor = "digitalb0yfriend",
		modArchiveFileName = "soft club corpo plaza.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptCtc,
		isAddOnRelated = true
	},
	{
		modTitle = "No More Autosaves - Phantom Liberty Compatible",
		modAuthor = "TheManualEnhancer",
		modArchiveFileName = "#NoMoreAutosaves.archive",
		reason = "This mod severely affects the game and mods relying on normal game behavior by removing the game\'s fundamental native autosaving system.",
		isAddOnRelated = true
	},
	{
		modTitle = "Neon Zen H10 Apartment Mod - ArchiveXL",
		modAuthor = "hnovak1",
		modArchiveFileName = "Neon Zen H10.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "H10 Songbird SF1 Apartment",
		modAuthor = "hnovak1",
		modArchiveFileName = "SF1.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Golden Glen Apartment - ArchiveXL",
		modAuthor = "hnovak1",
		modArchiveFileName = "Golden Glen Apartment.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Rockerdoll Japantown Apartment - ArchiveXL",
		modAuthor = "hnovak1",
		modArchiveFileName = "Rockerdoll Japantown Apartment.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptJpn,
		isAddOnRelated = true
	},
	{
		modTitle = "H10_BONE",
		modAuthor = "77reye",
		modArchiveFileName = "77_h10_bone.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "GLEN_AMOEBA_Apartment",
		modAuthor = "77reye",
		modArchiveFileName = "77_glen_amoeba.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "GLEN_OASIS_Apartment",
		modAuthor = "77reye",
		modArchiveFileName = "77_glen_oasis.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "H10_PINK_Apartment",
		modAuthor = "77reye",
		modArchiveFileName = "77_h10_pink.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
	{
		modTitle = "Glen Apartment New Interactions",
		modAuthor = "DrakeEldridge",
		modArchiveFileName = "glennewpropsnodup.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "TactiCool V\'s H10 Apartment",
		modAuthor = "RoxterFox",
		modArchiveFileName = "Jungle_v1.4_Evelyn.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "TactiCool V\'s H10 Apartment",
		modAuthor = "RoxterFox",
		modArchiveFileName = "Jungle_v1.4_No_Evelyn.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptGle,
		isAddOnRelated = true
	},
	{
		modTitle = "Modern H10 Apartment - Archive Preset",
		modAuthor = "DeVaughnDawn",
		modArchiveFileName = "VsH10Apartment.archive",
		hasMultipleAssociatedArchiveFiles = true,
		reason = conflictDescAptH10,
		isAddOnRelated = true
	},
}

return {moduleVer = moduleVer, modVer = modVer, modAuthorName = modAuthorName, knownConflictingOtherMods = knownConflictingOtherMods}