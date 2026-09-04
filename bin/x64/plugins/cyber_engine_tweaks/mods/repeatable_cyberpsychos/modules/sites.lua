-- Positions and orientations are the original boss community workspots, not
-- the vanilla POI coordinates. Several POIs point at evidence or loot; Smoke
-- on the Water's old marker was 109 metres from the actual cyberpsycho.
local Sites = {
    { id = "ma_bls_ina_se1_07", name = "The Wasteland", finishedFact = "ma_bls_ina_se1_07_finished", bossRecord = "Character.ma_bls_ina_se1_07_cyberpsycho_1", position = { x = 2682.5698, y = -1508.25, z = 64.96 }, orientation = { i = 0, j = 0, k = 0.29816148, r = 0.95451546 } },
    { id = "ma_bls_ina_se1_08", name = "House on a Hill", finishedFact = "ma_bls_ina_se1_08_finished", bossRecord = "Character.ma_bls_ina_se1_08_cyberpsycho", position = { x = 2681.682, y = -546.2816, z = 104.04512 }, orientation = { i = 0, j = 0, k = -0.9998565, r = 0.0169487 } },
    { id = "ma_bls_ina_se1_22", name = "Second Chances", finishedFact = "ma_ina_se1_22_finished", bossRecord = "Character.ma_bls_ina_se1_22_psycho", position = { x = 4823.2627, y = -1387.651, z = 143.0134 }, orientation = { i = 0, j = 0, k = 0.3545947, r = 0.9350202 } },
    { id = "ma_cct_dtn_03", name = "On Deaf Ears", finishedFact = "ma_dtn_03_finished", bossRecord = "Character.ma_cct_dtn_03_cyberpsycho", position = { x = -2140.6445, y = 268.22052, z = 8.01 }, orientation = { i = 0, j = 0, k = 0.22376248, r = 0.9746437 } },
    { id = "ma_cct_dtn_07", name = "Phantom of Night City", finishedFact = "ma_cct_dtn_07_finished", bossRecord = "Character.ma_cct_dtn_07_cyberpsycho", position = { x = -1689.9946, y = 247.96243, z = 16.529 }, orientation = { i = 0, j = 0, k = -0.72568935, r = 0.68802255 } },
    { id = "ma_hey_spr_04", name = "Seaside Cafe", finishedFact = "ma_spr_04_finished", bossRecord = "Character.ma_hey_spr_04_cyberpsycho", position = { x = -2263.3071, y = -1320.8014, z = 7.199726 }, orientation = { i = 0, j = 0, k = -0.9933455, r = 0.11517328 } },
    { id = "ma_hey_spr_06", name = "Letter of the Law", finishedFact = "ma_hey_spr_06_finished", bossRecord = "Character.ma_hey_spr_06_cyberpsycho", position = { x = -2409.2646, y = -1088.9158, z = 12.809999 }, orientation = { i = 0, j = 0, k = 0.8462195, r = 0.53283465 } },
    { id = "ma_pac_cvi_08", name = "Smoke on the Water", finishedFact = "ma_pac_cvi_08_finished", bossRecord = "Character.ma_pac_cvi_08_psycho", position = { x = -2128.3938, y = -1505.7416, z = 12.0599985 }, orientation = { i = 0, j = 0, k = -0.50753844, r = -0.8616291 } },
    { id = "ma_pac_cvi_15", name = "Lex Talionis", finishedFact = "ma_pac_cvi_15_finished", bossRecord = "Character.ma_pac_cvi_15_cyberpsycho", position = { x = -2237.3357, y = -1980.1117, z = 5.6502023 }, orientation = { i = 0, j = 0, k = -0.23344555, r = 0.9723699 } },
    { id = "ma_std_arr_06", name = "Discount Doc", finishedFact = "ma_arr_06_finished", bossRecord = "Character.ma_std_arr_06_cyberpsycho", position = { x = -641.89795, y = -1312.407, z = 8.023128 }, orientation = { i = 0, j = 0, k = 0.9588618, r = 0.2838732 } },
    { id = "ma_std_rcr_11", name = "Under the Bridge", finishedFact = "ma_rcr_11_finished", bossRecord = "Character.ma_std_rcr_11_cyberpsycho", position = { x = 308.94043, y = -1893.8796, z = -7 }, orientation = { i = 0, j = 0, k = 0.95785636, r = 0.28724775 } },
    { id = "ma_wat_kab_02", name = "Demons of War", finishedFact = "ma_kab_02_finished", bossRecord = "Character.ma_wat_kab_02_cyberpsycho", position = { x = -787.1592, y = 1879.7571, z = 47.759995 }, orientation = { i = 0, j = 0, k = 0, r = 1 } },
    { id = "ma_wat_lch_06", name = "Ticket to the Major Leagues", finishedFact = "ma_wat_lch_06_finished", bossRecord = "Character.ma_wat_lch_06_cyberpsycho", position = { x = -2050.7861, y = 1225.5829, z = 3.8899999 }, orientation = { i = 0, j = 0, k = -0.63607824, r = 0.7716246 } },
    { id = "ma_wat_nid_03", name = "Where the Bodies Hit the Floor", finishedFact = "ma_nid_03_finished", bossRecord = "Character.ma_wat_nid_03_shard_psycho", position = { x = -1713.779, y = 2222.7595, z = 18.429945 }, orientation = { i = 0, j = 0, k = 0.28316602, r = 0.959071 } },
    { id = "ma_wat_nid_15", name = "Six Feet Under", finishedFact = "ma_nid_15_finished", bossRecord = "Character.ma_wat_nid_15_psycho", position = { x = -1530.0504, y = 2509.6418, z = 7.1501465 }, orientation = { i = 0, j = 0, k = -0.7880108, r = 0.61566144 } },
    { id = "ma_wat_nid_22", name = "Lt. Mower", finishedFact = "ma_nid_22_finished", bossRecord = "Character.ma_wat_nid_22_monk", position = { x = -1053.5896, y = 2799.9705, z = 7.1354833 }, orientation = { i = 0, j = 0, k = 0.46174872, r = 0.88701075 } },
    { id = "sts_wat_nid_01", name = "Bloody Ritual", finishedFact = "nid_01_finished", bossRecord = "Character.sts_wat_nid_01_cyberpsycho", position = { x = -1216.8411, y = 2278.1885, z = 6.9746165 }, orientation = { i = 0, j = 0, k = 0.10452862, r = -0.994522 }, scripted = true },
}

local byID = {}
for _, site in ipairs(Sites) do byID[site.id] = site end

return { list = Sites, byID = byID }
