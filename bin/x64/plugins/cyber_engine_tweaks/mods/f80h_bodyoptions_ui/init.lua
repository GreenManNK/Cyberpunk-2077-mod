local configPath = "settings.json"

local f80h_characters = {
    Panam = {
        savedIndex = 1,
        options = {
            [1] = "Bodysuit",
            [2] = "Bodysuit and shorts",
			[3] = "Top",
			[4] = "Top and shorts",
			[5] = "Top and skirt",	
			[6] = "Gym",	
			[7] = "Cartoonish",
			[8] = "nude",
            [9] = "No pants no harness"
        },
        paths = {
            main = {
                "base\\characters\\main_npc\\panam\\outfits\\squeeze\\panam.ent",
                "base\\characters\\main_npc\\panam\\outfits\\squeeze_pants\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\top\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\top_pants\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\top_skirt\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\gym\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\cartoon\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\nude\\panam.ent",
				"base\\characters\\main_npc\\panam\\outfits\\squeeze_no_pants\\panam.ent"
            }
        },
        tweakpath = {
            flag = "Mod.Appearance.PanamEnhanced.Flag",
            tweak = "Character.Panam.entityTemplatePath"
        }
    },
	Rogue = {
        savedIndex = 1,
        options = {
            [1] = "Yellow sweater",
            [2] = "White Tank top",
			[3] = "Young Tank top",
			[3] = "Young yellow sweater",
			[4] = "Nude",
        },
        paths = {
            main = {
                "base\\quest\\secondary_characters\\rogue.ent",
                "base\\characters\\main_npc\\rogue\\outfits\\tanktop\\rogue.ent",
				"base\\characters\\main_npc\\rogue\\outfits\\young\\rogue.ent",
				"base\\characters\\main_npc\\rogue\\outfits\\youngyellow\\rogue.ent",
				"base\\characters\\main_npc\\rogue\\outfits\\nude\\rogue.ent"
            }
        },
        tweakpath = {
            flag = "Mod.Appearance.RogueEnhanced.Flag",
            tweak = "Character.Rogue.entityTemplatePath"
        }
	},
	Misty = {
        savedIndex = 1,
        options = {
            [1] = "Normal",
            [2] = "Revealing",
			[3] = "Phatom Liberty",
			[4] = "Topless",
			[5] = "Topless pierced",
			[6] = "nude",
			[7] = "nude phantom liberty"
        },
        paths = {
            main = {
                "base\\characters\\main_npc\\misty\\outfits\\normal\\misty.ent",
                "base\\characters\\main_npc\\misty\\outfits\\revealing\\misty.ent",
				"base\\characters\\main_npc\\misty\\outfits\\pl\\misty.ent",
				"base\\characters\\main_npc\\misty\\outfits\\topless\\misty.ent",
				"base\\characters\\main_npc\\misty\\outfits\\topless_pierced\\misty.ent",
				"base\\characters\\main_npc\\misty\\outfits\\nude\\misty.ent",
				"base\\characters\\main_npc\\misty\\outfits\\nude_pl\\misty.ent"
            }
        },
        tweakpath = {
            flag = "Mod.Appearance.MistyEnhanced.Flag",
            tweak = "Character.Misty.entityTemplatePath"
        }
    },
	Stout = {
        savedIndex = 1,
        options = {
            [1] = "Uniform",
            [2] = "Gym",
			[3] = "Gym no jacket",
			[4] = "Strap-On",
			[5] = "Always nude",
			[6] = "Always BDSM",
			[7] = "Uniform, futanude",
			[8] = "Gym, futanude",
			[9] = "Gym no jacket, futanude",
			[10] = "Always futa"
        },
        paths = {
            main = {
                "base\\quest\\tertiary_characters\\stout.ent",
                "base\\characters\\main_npc\\militech_agent\\outfit\\gym\\stout.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\gym\\stout_noj.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\strapon\\stout.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\nude\\stout.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\bdsm\\stout.ent",
				"base\\quest\\tertiary_characters\\stout_f.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\gym\\stout_f.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\gym\\stout_f_noj.ent",
				"base\\characters\\main_npc\\militech_agent\\outfit\\futa\\stout.ent"
            }
        },
        tweakpath = {
            flag = "Mod.Appearance.StoutEnhanced.Flag",
            tweak = "Character.Stout.entityTemplatePath"
        }
    },
    Judy = {
        savedIndex = 1,
        options = {
            [1] = "With tattoos old version",
            [2] = "Without tattoos old version",
			[3] = "With tattoos",
			[4] = "Without tattoos",
			[5] = "Gym Outfit",
			[6] = "Skirt Outfit",
			[7] = "Monokini Outfit",
			[8] = "Pijama Outfit",
			[9] = "Slutty",
			[10] = "Always nude"
        },
        paths = {
            main = {
                "base\\characters\\main_npc\\judy\\outfits\\tattoo\\judy_tatt.ent",
                "base\\characters\\main_npc\\judy\\outfits\\notattoo\\judy_notatt.ent",
				"base\\characters\\main_npc\\judy\\outfits\\alt_body\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\alt_body_notatt\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\gym\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\skirt\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\monokini\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\pijama\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\slutty\\judy.ent",
				"base\\characters\\main_npc\\judy\\outfits\\nude\\judy.ent"
            }
        },
        tweakpath = {
            flag = "Mod.Appearance.JudyEnhanced.Flag",
            tweak = "Character.Judy.entityTemplatePath"
        }
    }
}

-- Load saved settings
local function loadSettings()
    local file = io.open(configPath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local data = json.decode(content)
        if data then
            for name, character in pairs(f80h_characters) do
                local key = name .. "AppIndex"
                if data[key] then
                    character.savedIndex = data[key]
                end
            end
        end
    end
end

-- Save current selections
local function saveSettings()
    local data = {}
    for name, character in pairs(f80h_characters) do
        data[name .. "AppIndex"] = character.savedIndex
    end
    local file = io.open(configPath, "w")
    if file then
        file:write(json.encode(data))
        file:close()
        print("[AppearanceSwitcher] Settings saved.")
    else
        print("[AppearanceSwitcher] ERROR: Could not save settings!")
    end
end

-- Apply rig patch for character
local function patchRig(charName, index)
    local char = f80h_characters[charName]
    local paths = char.paths
    local tweakpath = char.tweakpath
    local label = char.options[index] or "Unknown"
    local mainPath = paths.main[index]

    if TweakDB:GetFlat(tweakpath.tweak) then
        TweakDB:SetFlat(tweakpath.tweak, mainPath)
        print("[AppearanceSwitcher] Patched " .. charName .. " rig to: " .. mainPath .. " (" .. label .. ")")
    else
        print("[AppearanceSwitcher] ERROR: Could not find tweak path for " .. charName)
    end
end

-- Main mod init
registerForEvent("onInit", function()
    loadSettings()

    local nativeSettings = GetMod and GetMod("nativeSettings")
    if not nativeSettings then
        print("[AppearanceSwitcher] ERROR: Native Settings UI not loaded!")
        return
    end

    local tabPath = "/AppearanceSwitcher"
    nativeSettings.addTab(tabPath, "f80h Appearance Switcher")

    for name, character in pairs(f80h_characters) do
        local flag = character.tweakpath.flag
        if flag and TweakDB:GetRecord(flag) then
            print("[AppearanceSwitcher] Detected mod: " .. flag)

            local subPath = tabPath .. "/" .. name
            nativeSettings.addSubcategory(subPath, name)

            nativeSettings.addSelectorString(
                subPath,
                "Select Outfit (and then reload a save!)",
                "Choose which appearance " .. name .. " will use",
                character.options,
                character.savedIndex,
                1,
                function(value)
                    if character.savedIndex == value then return end
                    character.savedIndex = value
                    patchRig(name, value)
                    saveSettings()
                end
            )

            patchRig(name, character.savedIndex)
        else
            print("[AppearanceSwitcher] SKIPPED " .. name .. ": TweakDB record flag not found (" .. tostring(flag) .. ")")
        end
    end
end)
