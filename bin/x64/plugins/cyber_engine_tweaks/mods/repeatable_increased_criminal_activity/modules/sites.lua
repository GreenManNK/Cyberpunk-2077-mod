local Sites = {
    {
        id = "we_ep1_01",
        name = "Kress Street / Longshore Stacks",
        boss = "Ross Ulmer (exoskeleton)",
        bossRecord = "Character.we_ep1_01_mini_boss_2nd_phase",
        finishedFact = "we_ep1_01_finished",
        position = { x = -2429.64, y = -2365.81, z = 10.95 },
    },
    {
        id = "we_ep1_05",
        name = "Luxor High Wellness Spa",
        boss = "Ayo Zarin",
        bossRecord = "Character.we_ep1_05_mini_boss",
        finishedFact = "we_ep1_05_finished",
        position = { x = -1418.849, y = -2642.115, z = 83.71233 },
    },
    {
        id = "we_ep1_17",
        name = "Terra Cognita",
        boss = "Modified MRS-071 drone",
        bossRecord = "Character.we_ep1_17_miniboss",
        finishedFact = "we_ep1_17_finished",
        position = { x = -2263.553, y = -2917.408, z = 117.47 },
    },
}

local byID = {}
for _, site in ipairs(Sites) do byID[site.id] = site end

return { list = Sites, byID = byID }
