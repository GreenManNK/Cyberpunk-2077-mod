--
-- Red Dirt location
--
return {
    name = "NCA Red Dirt",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterLocation("Red Dirt")
        NCA:RegisterSpawn("Red Dirt", { name = "RedDirt_Entrance_1", pos = { -723.6944, -993.99115, 8.06086 }, rot = { 0.0, 0.0, -0.5179392, -0.8554175 } })
        NCA:RegisterSpawn("Red Dirt", { name = "RedDirt_Entrance_2", pos = { -724.5591, -995.075, 8.061951 }, rot = { 0.0, 0.0, -0.3858114, -0.9225777 } })
        NCA:RegisterSpawn("Red Dirt", { name = "RedDirt_Bar", pos = { -725.7207, -1003.2317, 8.004082 }, rot = { 0.0, 0.0, 0.45917884, 0.88834393 } })
        NCA:RegisterSpawn("Red Dirt", { name = "RedDirt_Table", pos = { -734.3654, -997.76825, 8.004082 }, rot = { 0.0, 0.0, -0.24792166, 0.9687801 } })
        NCA:Location():RegisterDistrictTrigger("Red Dirt", gamedataDistrict.Arroyo_Red_Dirt)
        NCA:Spawn():RegisterAffiliationSpawnRule("Red Dirt", "Factions.AfterlifeMercs", 0.0)
        NCA:Spawn():RegisterAffiliationSpawnRule("Red Dirt", "Factions.Maelstrom", 0.0)
        NCA:Spawn():RegisterAffiliationSpawnRule("Red Dirt", "Factions.TheMox", 0.0)
    end
}