-- Apr 21, 2026 by (c)anygoodname

local moduleVer = 'v1.6.1'
local moduleName = 'Hotscenes cet version blowup preventer'
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

local unsupportedCetVersions = {
	{min = 1.26, max = 1.26},								-- game v2.0
	{min = 1.29, max = 1.29},								-- game v2.1
	{min = 1.30, max = 1.30},								-- game v2.11
	{min = 1.31, max = 1.3102, reason = 'exEntitySpawner'},	-- game v2.12
	{min = 1.32, max = 1.32, reason = 'exEntitySpawner'},	-- game v2.12a
	--{min = 1.33, max = 1.33, reason = 'exEntitySpawner'},	-- game v2.13	-- proved to work correctly.
	--{min = 1.34, max = 1.34, reason = 'exEntitySpawner'},	-- game v2.2	-- proved to work correctly.
	--{min = 1.35, max = 1.35, reason = 'exEntitySpawner'},	-- game v2.21	-- proved to work correctly.
	--{min = 1.36, max = 1.36, reason = 'exEntitySpawner'},	-- game v2.3	-- proved to work correctly.
	--{min = 1.37, max = 1.37, reason = 'exEntitySpawner'},	-- game v2.31	-- proved to work correctly.
	{min = 1.38, max = 1.38, reason = 'exEntitySpawner'},	-- future game release or major CET update
	{min = 1.39, max = 1.39, reason = 'exEntitySpawner'},	-- future game release or major CET update
	{min = 2.0, max = 2.0, reason = 'exEntitySpawner'},	-- future game release or major CET update
}

local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

function isCurrentCetVersionSupported()
	for _, unsupportedCetRec in ipairs(unsupportedCetVersions) do
		if cetVer >= unsupportedCetRec.min and cetVer <= unsupportedCetRec.max then
			return false, unsupportedCetRec.reason
		end
	end
	return true
end

return {moduleVer = moduleVer, modVer = modVer, modAuthorName = modAuthorName, isCurrentCetVersionSupported = isCurrentCetVersionSupported}