module iconicshop.Helpers.ProductsList

import iconicshop.Helpers.Products.*
import iconicshop.Helpers.ProductsList.*
import iconicshop.Settings.General.*
import iconicshop.Prices.Common.*
import iconicshop.Prices.Top.*
import iconicshop.Prices.Legendary.*

public func GetItemsList () -> array<ref<ISProduct>> {
  let ItemsList: array<ref<ISProduct>>;
 // ### Iconic Ranged Weapons ###
  // Iconic Pistols
    ArrayPush(ItemsList, ISCreateProduct("Her Majesty", "Items.Preset_Unity_Agent", GetCommonCustomPrice("HerMajesty"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Her Majesty", "Items.Preset_Unity_Agent", GetLegendaryCustomPrice("HerMajesty"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Her Majesty", "Items.Preset_Unity_Agent", GetTopCustomPrice("HerMajesty"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Cheetah", "Items.Preset_Unity_Angelica", GetCommonCustomPrice("Cheetah"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Cheetah", "Items.Preset_Unity_Angelica", GetLegendaryCustomPrice("Cheetah"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cheetah", "Items.Preset_Unity_Angelica", GetTopCustomPrice("Cheetah"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Dying Night", "Items.Preset_Lexington_Wilson_Legendary", GetCommonCustomPrice("DyingNight"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Dying Night", "Items.Preset_Lexington_Wilson_Legendary", GetLegendaryCustomPrice("DyingNight"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Dying Night", "Items.Preset_Lexington_Wilson_Legendary", GetTopCustomPrice("DyingNight"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Lexington x-MOD2", "Items.Preset_Lexington_Shooting_Competition", GetCommonCustomPrice("LexingtonXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Lexington x-MOD2", "Items.Preset_Lexington_Shooting_Competition", GetLegendaryCustomPrice("LexingtonXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Lexington x-MOD2", "Items.Preset_Lexington_Shooting_Competition", GetTopCustomPrice("LexingtonXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Rook", "Items.Preset_Lexington_Rook", GetCommonCustomPrice("Rook"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Rook", "Items.Preset_Lexington_Rook", GetLegendaryCustomPrice("Rook"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Rook", "Items.Preset_Lexington_Rook", GetTopCustomPrice("Rook"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Kongou", "Items.Preset_Liberty_Yorinobu", GetCommonCustomPrice("Kongou"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Kongou", "Items.Preset_Liberty_Yorinobu", GetLegendaryCustomPrice("Kongou"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Kongou", "Items.Preset_Liberty_Yorinobu", GetTopCustomPrice("Kongou"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Plan B", "Items.Preset_Liberty_Dex", GetCommonCustomPrice("PlanB"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Plan B", "Items.Preset_Liberty_Dex", GetLegendaryCustomPrice("PlanB"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Plan B", "Items.Preset_Liberty_Dex", GetTopCustomPrice("PlanB"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Pride", "Items.Preset_Liberty_Rogue", GetCommonCustomPrice("Pride"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Pride", "Items.Preset_Liberty_Rogue", GetLegendaryCustomPrice("Pride"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Pride", "Items.Preset_Liberty_Rogue", GetTopCustomPrice("Pride"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Seraph", "Items.Preset_Liberty_Padre", GetCommonCustomPrice("Seraph"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Seraph", "Items.Preset_Liberty_Padre", GetLegendaryCustomPrice("Seraph"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Seraph", "Items.Preset_Liberty_Padre", GetTopCustomPrice("Seraph"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Death and Taxes", "Items.Preset_Nue_Maiko", GetCommonCustomPrice("DeathAndTaxes"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Death and Taxes", "Items.Preset_Nue_Maiko", GetLegendaryCustomPrice("DeathAndTaxes"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Death and Taxes", "Items.Preset_Nue_Maiko", GetTopCustomPrice("DeathAndTaxes"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("La Chingona Dorada", "Items.Preset_Nue_Jackie", GetCommonCustomPrice("LaChingonaDorada"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("La Chingona Dorada", "Items.Preset_Nue_Jackie", GetLegendaryCustomPrice("LaChingonaDorada"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("La Chingona Dorada", "Items.Preset_Nue_Jackie", GetTopCustomPrice("LaChingonaDorada"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Riskit", "Items.Preset_Nue_Bree", GetCommonCustomPrice("Riskit"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Riskit", "Items.Preset_Nue_Bree", GetLegendaryCustomPrice("Riskit"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Riskit", "Items.Preset_Nue_Bree", GetTopCustomPrice("Riskit"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Malorian Arms 3516", "Items.Preset_Silverhand_3516", GetCommonCustomPrice("MalorianArms3516"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Malorian Arms 3516", "Items.Preset_Silverhand_3516", GetLegendaryCustomPrice("MalorianArms3516"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Malorian Arms 3516", "Items.Preset_Silverhand_3516", GetTopCustomPrice("MalorianArms3516"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Genjiroh", "Items.Preset_Yukimura_Kiji", GetCommonCustomPrice("Genjiroh"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Genjiroh", "Items.Preset_Yukimura_Kiji", GetLegendaryCustomPrice("Genjiroh"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Genjiroh", "Items.Preset_Yukimura_Kiji", GetTopCustomPrice("Genjiroh"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Skippy", "Items.Preset_Yukimura_Skippy", GetCommonCustomPrice("Skippy"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Skippy", "Items.Preset_Yukimura_Skippy", GetLegendaryCustomPrice("Skippy"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Skippy", "Items.Preset_Yukimura_Skippy", GetTopCustomPrice("Skippy"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Crimestopper", "Items.Preset_Kappa_George", GetCommonCustomPrice("Crimestopper"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Crimestopper", "Items.Preset_Kappa_George", GetLegendaryCustomPrice("Crimestopper"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Crimestopper", "Items.Preset_Kappa_George", GetTopCustomPrice("Crimestopper"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Kappa x-MOD2", "Items.Preset_Kappa_Legendary", GetCommonCustomPrice("KappaXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Kappa x-MOD2", "Items.Preset_Kappa_Legendary", GetLegendaryCustomPrice("KappaXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Kappa x-MOD2", "Items.Preset_Kappa_Legendary", GetTopCustomPrice("KappaXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Ogou", "Items.Preset_Chao_VooDoo", GetCommonCustomPrice("Ogou"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Ogou", "Items.Preset_Chao_VooDoo", GetLegendaryCustomPrice("Ogou"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ogou", "Items.Preset_Chao_VooDoo", GetTopCustomPrice("Ogou"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Apparition", "Items.Preset_Kenshin_Frank", GetCommonCustomPrice("Apparition"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Apparition", "Items.Preset_Kenshin_Frank", GetLegendaryCustomPrice("Apparition"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Apparition", "Items.Preset_Kenshin_Frank", GetTopCustomPrice("Apparition"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Chaos", "Items.Preset_Kenshin_Royce", GetCommonCustomPrice("Chaos"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Chaos", "Items.Preset_Kenshin_Royce", GetLegendaryCustomPrice("Chaos"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Chaos", "Items.Preset_Kenshin_Royce", GetTopCustomPrice("Chaos"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Ambition", "Items.Preset_Kenshin_Spy", GetCommonCustomPrice("Ambition"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Ambition", "Items.Preset_Kenshin_Spy", GetLegendaryCustomPrice("Ambition"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ambition", "Items.Preset_Kenshin_Spy", GetTopCustomPrice("Ambition"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Catahoula", "Items.Preset_Grit_Amazon", GetCommonCustomPrice("Catahoula"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Catahoula", "Items.Preset_Grit_Amazon", GetLegendaryCustomPrice("Catahoula"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Catahoula", "Items.Preset_Grit_Amazon", GetTopCustomPrice("Catahoula"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Lizzie", "Items.Preset_Omaha_Suzie", GetCommonCustomPrice("Lizzie"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Lizzie", "Items.Preset_Omaha_Suzie", GetLegendaryCustomPrice("Lizzie"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Lizzie", "Items.Preset_Omaha_Suzie", GetTopCustomPrice("Lizzie"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Pariah", "Items.Preset_Ticon_Reed", GetCommonCustomPrice("Pariah"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Pariah", "Items.Preset_Ticon_Reed", GetLegendaryCustomPrice("Pariah"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Pariah", "Items.Preset_Ticon_Reed", GetTopCustomPrice("Pariah"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Scorch", "Items.Preset_Ticon_Gwent", GetCommonCustomPrice("Scorch"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Scorch", "Items.Preset_Ticon_Gwent", GetLegendaryCustomPrice("Scorch"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Scorch", "Items.Preset_Ticon_Gwent", GetTopCustomPrice("Scorch"), "LegendaryPlusPlus"));

  // Iconic Revolvers
    ArrayPush(ItemsList, ISCreateProduct("Doom Doom", "Items.Preset_Nova_Doom_Doom", GetCommonCustomPrice("DoomDoom"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Doom Doom", "Items.Preset_Nova_Doom_Doom", GetLegendaryCustomPrice("DoomDoom"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Doom Doom", "Items.Preset_Nova_Doom_Doom", GetTopCustomPrice("DoomDoom"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Mancinella", "Items.Preset_Nova_Hitman", GetCommonCustomPrice("Mancinella"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Mancinella", "Items.Preset_Nova_Hitman", GetLegendaryCustomPrice("Mancinella"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Mancinella", "Items.Preset_Nova_Hitman", GetTopCustomPrice("Mancinella"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Amnesty", "Items.Preset_Overture_Cassidy", GetCommonCustomPrice("Amnesty"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Amnesty", "Items.Preset_Overture_Cassidy", GetLegendaryCustomPrice("Amnesty"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Amnesty", "Items.Preset_Overture_Cassidy", GetTopCustomPrice("Amnesty"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Archangel", "Items.Preset_Overture_Kerry", GetCommonCustomPrice("Archangel"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Archangel", "Items.Preset_Overture_Kerry", GetLegendaryCustomPrice("Archangel"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Archangel", "Items.Preset_Overture_Kerry", GetTopCustomPrice("Archangel"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Crash", "Items.Preset_Overture_River", GetCommonCustomPrice("Crash"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Crash", "Items.Preset_Overture_River", GetLegendaryCustomPrice("Crash"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Crash", "Items.Preset_Overture_River", GetTopCustomPrice("Crash"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Rosco", "Items.Preset_Overture_Dodger", GetCommonCustomPrice("Rosco"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Rosco", "Items.Preset_Overture_Dodger", GetLegendaryCustomPrice("Rosco"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Rosco", "Items.Preset_Overture_Dodger", GetTopCustomPrice("Rosco"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Ol` Reliable", "Items.Preset_Overture_Dante", GetCommonCustomPrice("OlReliable"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Ol` Reliable", "Items.Preset_Overture_Dante", GetLegendaryCustomPrice("OlReliable"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ol` Reliable", "Items.Preset_Overture_Dante", GetTopCustomPrice("OlReliable"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Taigan", "Items.Preset_Metel_AirDrop", GetCommonCustomPrice("Taigan"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Taigan", "Items.Preset_Metel_AirDrop", GetLegendaryCustomPrice("Taigan"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Taigan", "Items.Preset_Metel_AirDrop", GetTopCustomPrice("Taigan"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Bald Eagle", "Items.Preset_Metel_Kurt", GetCommonCustomPrice("BaldEagle"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Bald Eagle", "Items.Preset_Metel_Kurt", GetLegendaryCustomPrice("BaldEagle"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Bald Eagle", "Items.Preset_Metel_Kurt", GetTopCustomPrice("BaldEagle"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Comrade's Hammer", "Items.Preset_Burya_Comrade", GetCommonCustomPrice("ComradesHammer"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Comrade's Hammer", "Items.Preset_Burya_Comrade", GetLegendaryCustomPrice("ComradesHammer"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Comrade's Hammer", "Items.Preset_Burya_Comrade", GetTopCustomPrice("ComradesHammer"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Laika", "Items.Preset_Burya_AirDrop", GetCommonCustomPrice("Laika"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Laika", "Items.Preset_Burya_AirDrop", GetLegendaryCustomPrice("Laika"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Laika", "Items.Preset_Burya_AirDrop", GetTopCustomPrice("Laika"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Gris-Gris", "Items.Preset_Quasar_Baron", GetCommonCustomPrice("GrisGris"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Gris-Gris", "Items.Preset_Quasar_Baron", GetLegendaryCustomPrice("GrisGris"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Gris-Gris", "Items.Preset_Quasar_Baron", GetTopCustomPrice("GrisGris"), "LegendaryPlusPlus"));

  // Iconic Shotguns
    ArrayPush(ItemsList, ISCreateProduct("The Headsman", "Items.Preset_Tactician_Headsman", GetCommonCustomPrice("TheHeadsman"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("The Headsman", "Items.Preset_Tactician_Headsman", GetLegendaryCustomPrice("TheHeadsman"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("The Headsman", "Items.Preset_Tactician_Headsman", GetTopCustomPrice("TheHeadsman"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Bloody Maria", "Items.Preset_Tactician_Dino", GetCommonCustomPrice("BloodyMaria"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Bloody Maria", "Items.Preset_Tactician_Dino", GetLegendaryCustomPrice("BloodyMaria"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Bloody Maria", "Items.Preset_Tactician_Dino", GetTopCustomPrice("BloodyMaria"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Mox", "Items.Preset_Carnage_Mox", GetCommonCustomPrice("Mox"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Mox", "Items.Preset_Carnage_Mox", GetLegendaryCustomPrice("Mox"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Mox", "Items.Preset_Carnage_Mox", GetTopCustomPrice("Mox"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Guts", "Items.Preset_Carnage_Edgerunners", GetCommonCustomPrice("Guts"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Guts", "Items.Preset_Carnage_Edgerunners", GetLegendaryCustomPrice("Guts"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Guts", "Items.Preset_Carnage_Edgerunners", GetTopCustomPrice("Guts"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Amstaff", "Items.Preset_Crusher_Amazon", GetCommonCustomPrice("Amstaff"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Amstaff", "Items.Preset_Crusher_Amazon", GetLegendaryCustomPrice("Amstaff"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Amstaff", "Items.Preset_Crusher_Amazon", GetTopCustomPrice("Amstaff"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Dezerter", "Items.Preset_Testera_Nicolas", GetCommonCustomPrice("Dezerter"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Dezerter", "Items.Preset_Testera_Nicolas", GetLegendaryCustomPrice("Dezerter"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Dezerter", "Items.Preset_Testera_Nicolas", GetTopCustomPrice("Dezerter"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Sovereign", "Items.Preset_Igla_Sovereign", GetCommonCustomPrice("Sovereign"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Sovereign", "Items.Preset_Igla_Sovereign", GetLegendaryCustomPrice("Sovereign"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Sovereign", "Items.Preset_Igla_Sovereign", GetTopCustomPrice("Sovereign"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Alabai", "Items.Preset_Pozhar_AirDrop", GetCommonCustomPrice("Alabai"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Alabai", "Items.Preset_Pozhar_AirDrop", GetLegendaryCustomPrice("Alabai"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Alabai", "Items.Preset_Pozhar_AirDrop", GetTopCustomPrice("Alabai"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Pozhar x-MOD2", "Items.Preset_Pozhar_Legendary", GetCommonCustomPrice("PozharXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Pozhar x-MOD2", "Items.Preset_Pozhar_Legendary", GetLegendaryCustomPrice("PozharXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Pozhar x-MOD2", "Items.Preset_Pozhar_Legendary", GetTopCustomPrice("PozharXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Ba Xing Chong", "Items.Preset_Zhuo_Eight_Star", GetCommonCustomPrice("BaXingChong"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Ba Xing Chong", "Items.Preset_Zhuo_Eight_Star", GetLegendaryCustomPrice("BaXingChong"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ba Xing Chong", "Items.Preset_Zhuo_Eight_Star", GetTopCustomPrice("BaXingChong"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Order", "Items.Preset_Satara_Brick", GetCommonCustomPrice("Order"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Order", "Items.Preset_Satara_Brick", GetLegendaryCustomPrice("Order"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Order", "Items.Preset_Satara_Brick", GetTopCustomPrice("Order"), "LegendaryPlusPlus"));

  // Iconic Submachine Guns
    ArrayPush(ItemsList, ISCreateProduct("Fenrir", "Items.Preset_Saratoga_Maelstrom", GetCommonCustomPrice("Fenrir"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Fenrir", "Items.Preset_Saratoga_Maelstrom", GetLegendaryCustomPrice("Fenrir"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Fenrir", "Items.Preset_Saratoga_Maelstrom", GetTopCustomPrice("Fenrir"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Problem Solver", "Items.Preset_Saratoga_Raffen", GetCommonCustomPrice("ProblemSolver"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Problem Solver", "Items.Preset_Saratoga_Raffen", GetLegendaryCustomPrice("ProblemSolver"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Problem Solver", "Items.Preset_Saratoga_Raffen", GetTopCustomPrice("ProblemSolver"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Guillotine x-MOD2", "Items.Preset_Guillotine_Collectible", GetCommonCustomPrice("GuillotineXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Guillotine x-MOD2", "Items.Preset_Guillotine_Collectible", GetLegendaryCustomPrice("GuillotineXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Guillotine x-MOD2", "Items.Preset_Guillotine_Collectible", GetTopCustomPrice("GuillotineXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Buzzsaw", "Items.Preset_Pulsar_Buzzsaw", GetCommonCustomPrice("Buzzsaw"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Buzzsaw", "Items.Preset_Pulsar_Buzzsaw", GetLegendaryCustomPrice("Buzzsaw"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Buzzsaw", "Items.Preset_Pulsar_Buzzsaw", GetTopCustomPrice("Buzzsaw"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Midnight Arms Erebus", "Items.Preset_Borg4a_HauntedGun", GetCommonCustomPrice("MidnightArmsErebus"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Midnight Arms Erebus", "Items.Preset_Borg4a_HauntedGun", GetLegendaryCustomPrice("MidnightArmsErebus"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Midnight Arms Erebus", "Items.Preset_Borg4a_HauntedGun", GetTopCustomPrice("MidnightArmsErebus"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Prototype: Shingen Mark V", "Items.Preset_Shingen_Prototype", GetCommonCustomPrice("PrototypeShingenMarkV"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Prototype: Shingen Mark V", "Items.Preset_Shingen_Prototype", GetLegendaryCustomPrice("PrototypeShingenMarkV"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Prototype: Shingen Mark V", "Items.Preset_Shingen_Prototype", GetTopCustomPrice("PrototypeShingenMarkV"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Yinglong", "Items.Preset_Dian_Yinglong", GetCommonCustomPrice("Yinglong"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Yinglong", "Items.Preset_Dian_Yinglong", GetLegendaryCustomPrice("Yinglong"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Yinglong", "Items.Preset_Dian_Yinglong", GetTopCustomPrice("Yinglong"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Pizdets", "Items.Preset_Warden_Boris", GetCommonCustomPrice("Pizdets"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Pizdets", "Items.Preset_Warden_Boris", GetLegendaryCustomPrice("Pizdets"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Pizdets", "Items.Preset_Warden_Boris", GetTopCustomPrice("Pizdets"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Chesapeake", "Items.Preset_Warden_Amazon", GetCommonCustomPrice("Chesapeake"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Chesapeake", "Items.Preset_Warden_Amazon", GetLegendaryCustomPrice("Chesapeake"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Chesapeake", "Items.Preset_Warden_Amazon", GetTopCustomPrice("Chesapeake"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Raiju", "Items.Preset_Senkoh_Prototype", GetCommonCustomPrice("Raiju"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Raiju", "Items.Preset_Senkoh_Prototype", GetLegendaryCustomPrice("Raiju"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Raiju", "Items.Preset_Senkoh_Prototype", GetTopCustomPrice("Raiju"), "LegendaryPlusPlus"));

  // Iconic Assault Rifles
    ArrayPush(ItemsList, ISCreateProduct("Prejudice", "Items.Preset_Masamune_Rogue", GetCommonCustomPrice("Prejudice"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Prejudice", "Items.Preset_Masamune_Rogue", GetLegendaryCustomPrice("Prejudice"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Prejudice", "Items.Preset_Masamune_Rogue", GetTopCustomPrice("Prejudice"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Carmen", "Items.Preset_Umbra_Bebe", GetCommonCustomPrice("Carmen"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Carmen", "Items.Preset_Umbra_Bebe", GetLegendaryCustomPrice("Carmen"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Carmen", "Items.Preset_Umbra_Bebe", GetTopCustomPrice("Carmen"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Umbra x-MOD2", "Items.Preset_Umbra_Collectible", GetCommonCustomPrice("UmbraXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Umbra x-MOD2", "Items.Preset_Umbra_Collectible", GetLegendaryCustomPrice("UmbraXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Umbra x-MOD2", "Items.Preset_Umbra_Collectible", GetTopCustomPrice("UmbraXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Kyubi x-MOD2", "Items.Preset_Kyubi_Legendary", GetCommonCustomPrice("KyubiXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Kyubi x-MOD2", "Items.Preset_Kyubi_Legendary", GetLegendaryCustomPrice("KyubiXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Kyubi x-MOD2", "Items.Preset_Kyubi_Legendary", GetTopCustomPrice("KyubiXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Hawk", "Items.Preset_Kyubi_Myers", GetCommonCustomPrice("Hawk"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Hawk", "Items.Preset_Kyubi_Myers", GetLegendaryCustomPrice("Hawk"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Hawk", "Items.Preset_Kyubi_Myers", GetTopCustomPrice("Hawk"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Chinook", "Items.Preset_Kyubi_Amazon", GetCommonCustomPrice("Chinook"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Chinook", "Items.Preset_Kyubi_Amazon", GetLegendaryCustomPrice("Chinook"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Chinook", "Items.Preset_Kyubi_Amazon", GetTopCustomPrice("Chinook"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Moron Labe", "Items.Preset_Ajax_Moron", GetCommonCustomPrice("MoronLabe"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Moron Labe", "Items.Preset_Ajax_Moron", GetLegendaryCustomPrice("MoronLabe"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Moron Labe", "Items.Preset_Ajax_Moron", GetTopCustomPrice("MoronLabe"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Pit Bull", "Items.Preset_Ajax_Amazon", GetCommonCustomPrice("PitBull"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Pit Bull", "Items.Preset_Ajax_Amazon", GetLegendaryCustomPrice("PitBull"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Pit Bull", "Items.Preset_Ajax_Amazon", GetTopCustomPrice("PitBull"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Psalm 11:6", "Items.Preset_Copperhead_Genesis", GetCommonCustomPrice("Psalm116"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Psalm 11:6", "Items.Preset_Copperhead_Genesis", GetLegendaryCustomPrice("Psalm116"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Psalm 11:6", "Items.Preset_Copperhead_Genesis", GetTopCustomPrice("Psalm116"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Divided We Stand", "Items.Preset_Sidewinder_Divided", GetCommonCustomPrice("DividedWeStand"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Divided We Stand", "Items.Preset_Sidewinder_Divided", GetLegendaryCustomPrice("DividedWeStand"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Divided We Stand", "Items.Preset_Sidewinder_Divided", GetTopCustomPrice("DividedWeStand"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Militech Hercules 3AX", "Items.Preset_Hercules_Prototype", GetCommonCustomPrice("MilitechHercules3AX"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Militech Hercules 3AX", "Items.Preset_Hercules_Prototype", GetLegendaryCustomPrice("MilitechHercules3AX"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Militech Hercules 3AX", "Items.Preset_Hercules_Prototype", GetTopCustomPrice("MilitechHercules3AX"), "LegendaryPlusPlus"));

  // Iconic Machine Guns
    ArrayPush(ItemsList, ISCreateProduct("Wild Dog", "Items.Preset_Defender_Kurt", GetCommonCustomPrice("WildDog"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Wild Dog", "Items.Preset_Defender_Kurt", GetLegendaryCustomPrice("WildDog"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Wild Dog", "Items.Preset_Defender_Kurt", GetTopCustomPrice("WildDog"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("MA70 HB x-MOD2", "Items.Preset_MA70_Collectible", GetCommonCustomPrice("MA70HBXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("MA70 HB x-MOD2", "Items.Preset_MA70_Collectible", GetLegendaryCustomPrice("MA70HBXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("MA70 HB x-MOD2", "Items.Preset_MA70_Collectible", GetTopCustomPrice("MA70HBXMOD2"), "LegendaryPlusPlus"));

  // Iconic Precision Rifles
    ArrayPush(ItemsList, ISCreateProduct("Hypercritical", "Items.Preset_Kolac_Tiny_Mike", GetCommonCustomPrice("Hypercritical"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Hypercritical", "Items.Preset_Kolac_Tiny_Mike", GetLegendaryCustomPrice("Hypercritical"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Hypercritical", "Items.Preset_Kolac_Tiny_Mike", GetTopCustomPrice("Hypercritical"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Widow Maker", "Items.Preset_Achilles_Nash", GetCommonCustomPrice("WidowMaker"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Widow Maker", "Items.Preset_Achilles_Nash", GetLegendaryCustomPrice("WidowMaker"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Widow Maker", "Items.Preset_Achilles_Nash", GetTopCustomPrice("WidowMaker"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Achilles x-MOD2", "Items.Preset_Achilles_Collectible", GetCommonCustomPrice("AchillesXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Achilles x-MOD2", "Items.Preset_Achilles_Collectible", GetLegendaryCustomPrice("AchillesXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Achilles x-MOD2", "Items.Preset_Achilles_Collectible", GetTopCustomPrice("AchillesXMOD2"), "LegendaryPlusPlus"));

  // Iconic Sniper Rifles
    ArrayPush(ItemsList, ISCreateProduct("O'Five", "Items.Preset_Grad_Buck", GetCommonCustomPrice("OFive"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("O'Five", "Items.Preset_Grad_Buck", GetLegendaryCustomPrice("OFive"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("O'Five", "Items.Preset_Grad_Buck", GetTopCustomPrice("OFive"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Overwatch", "Items.Preset_Grad_Panam", GetCommonCustomPrice("Overwatch"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Overwatch", "Items.Preset_Grad_Panam", GetLegendaryCustomPrice("Overwatch"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Overwatch", "Items.Preset_Grad_Panam", GetTopCustomPrice("Overwatch"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Sparky", "Items.Preset_Grad_Scav", GetCommonCustomPrice("Sparky"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Sparky", "Items.Preset_Grad_Scav", GetLegendaryCustomPrice("Sparky"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Sparky", "Items.Preset_Grad_Scav", GetTopCustomPrice("Sparky"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Borzaya", "Items.Preset_Grad_AirDrop", GetCommonCustomPrice("Borzaya"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Borzaya", "Items.Preset_Grad_AirDrop", GetLegendaryCustomPrice("Borzaya"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Borzaya", "Items.Preset_Grad_AirDrop", GetTopCustomPrice("Borzaya"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Osprey", "Items.Preset_Osprey_Prototype", GetCommonCustomPrice("Osprey"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Osprey", "Items.Preset_Osprey_Prototype", GetLegendaryCustomPrice("Osprey"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Osprey", "Items.Preset_Osprey_Prototype", GetTopCustomPrice("Osprey"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Yasha", "Items.Preset_Ashura_Twitch", GetCommonCustomPrice("Yasha"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Yasha", "Items.Preset_Ashura_Twitch", GetLegendaryCustomPrice("Yasha"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Yasha", "Items.Preset_Ashura_Twitch", GetTopCustomPrice("Yasha"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Breakthrough", "Items.Preset_Nekomata_Breakthrough", GetCommonCustomPrice("Breakthrough"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Breakthrough", "Items.Preset_Nekomata_Breakthrough", GetLegendaryCustomPrice("Breakthrough"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Breakthrough", "Items.Preset_Nekomata_Breakthrough", GetTopCustomPrice("Breakthrough"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Foxhound", "Items.Preset_Nekomata_Amazon", GetCommonCustomPrice("Foxhound"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Foxhound", "Items.Preset_Nekomata_Amazon", GetLegendaryCustomPrice("Foxhound"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Foxhound", "Items.Preset_Nekomata_Amazon", GetTopCustomPrice("Foxhound"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Tsunami Rasetsu", "Items.Preset_Rasetsu_Prototype", GetCommonCustomPrice("TsunamiRasetsu"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Tsunami Rasetsu", "Items.Preset_Rasetsu_Prototype", GetLegendaryCustomPrice("TsunamiRasetsu"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Tsunami Rasetsu", "Items.Preset_Rasetsu_Prototype", GetTopCustomPrice("TsunamiRasetsu"), "LegendaryPlusPlus"));

 // ### Iconic Melee Weapons ##
  // Iconic 2H Clubs and Hammers
    ArrayPush(ItemsList, ISCreateProduct("Gold-plated baseball bat", "Items.Preset_Baseball_Bat_Denny", GetCommonCustomPrice("GoldPlatedBaseballBat"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Gold-plated baseball bat", "Items.Preset_Baseball_Bat_Denny", GetLegendaryCustomPrice("GoldPlatedBaseballBat"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Gold-plated baseball bat", "Items.Preset_Baseball_Bat_Denny", GetTopCustomPrice("GoldPlatedBaseballBat"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Baby Boomer", "Items.Preset_Baseball_Bat_Malina", GetCommonCustomPrice("BabyBoomer"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Baby Boomer", "Items.Preset_Baseball_Bat_Malina", GetLegendaryCustomPrice("BabyBoomer"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Baby Boomer", "Items.Preset_Baseball_Bat_Malina", GetTopCustomPrice("BabyBoomer"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Baseball Bat x-MOD2", "Items.Preset_Baseball_Bat_Legendary", GetCommonCustomPrice("BaseballBatXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Baseball Bat x-MOD2", "Items.Preset_Baseball_Bat_Legendary", GetLegendaryCustomPrice("BaseballBatXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Baseball Bat x-MOD2", "Items.Preset_Baseball_Bat_Legendary", GetTopCustomPrice("BaseballBatXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Caretaker's Spade", "Items.Preset_Shovel_Caretaker", GetCommonCustomPrice("CaretakersSpade"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Caretaker's Spade", "Items.Preset_Shovel_Caretaker", GetLegendaryCustomPrice("CaretakersSpade"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Caretaker's Spade", "Items.Preset_Shovel_Caretaker", GetTopCustomPrice("CaretakersSpade"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Sasquatch's Hammer", "Items.w_melee_boss_hammer", GetCommonCustomPrice("SasquatchsHammer"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Sasquatch's Hammer", "Items.w_melee_boss_hammer", GetLegendaryCustomPrice("SasquatchsHammer"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Sasquatch's Hammer", "Items.w_melee_boss_hammer", GetTopCustomPrice("SasquatchsHammer"), "LegendaryPlusPlus"));

  // Iconic 1H Clubs
    ArrayPush(ItemsList, ISCreateProduct("Cottonmouth", "Items.Preset_Cane_Fingers", GetCommonCustomPrice("Cottonmouth"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Cottonmouth", "Items.Preset_Cane_Fingers", GetLegendaryCustomPrice("Cottonmouth"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cottonmouth", "Items.Preset_Cane_Fingers", GetTopCustomPrice("Cottonmouth"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Sir John Phallustiff", "Items.Preset_Dildo_Stout", GetCommonCustomPrice("SirJohnPhallustiff"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Sir John Phallustiff", "Items.Preset_Dildo_Stout", GetLegendaryCustomPrice("SirJohnPhallustiff"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Sir John Phallustiff", "Items.Preset_Dildo_Stout", GetTopCustomPrice("SirJohnPhallustiff"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("BFC 9000", "Items.Preset_Dildo_SexShop", GetCommonCustomPrice("BFC9000"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("BFC 9000", "Items.Preset_Dildo_SexShop", GetLegendaryCustomPrice("BFC9000"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("BFC 9000", "Items.Preset_Dildo_SexShop", GetTopCustomPrice("BFC9000"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Tinker Bell", "Items.Preset_Baton_Tinker_Bell", GetCommonCustomPrice("TinkerBell"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Tinker Bell", "Items.Preset_Baton_Tinker_Bell", GetLegendaryCustomPrice("TinkerBell"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Tinker Bell", "Items.Preset_Baton_Tinker_Bell", GetTopCustomPrice("TinkerBell"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Murphy's Law", "Items.Preset_Baton_Murphy", GetCommonCustomPrice("MurphysLaw"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Murphy's Law", "Items.Preset_Baton_Murphy", GetLegendaryCustomPrice("MurphysLaw"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Murphy's Law", "Items.Preset_Baton_Murphy", GetTopCustomPrice("MurphysLaw"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Crowbar", "Items.Preset_Crowbar_Bunker", GetCommonCustomPrice("Crowbar"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Crowbar", "Items.Preset_Crowbar_Bunker", GetLegendaryCustomPrice("Crowbar"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Crowbar", "Items.Preset_Crowbar_Bunker", GetTopCustomPrice("Crowbar"), "LegendaryPlusPlus"));

  // Iconic Katana
    ArrayPush(ItemsList, ISCreateProduct("Byakko", "Items.Preset_Katana_Wakako", GetCommonCustomPrice("Byakko"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Byakko", "Items.Preset_Katana_Wakako", GetLegendaryCustomPrice("Byakko"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Byakko", "Items.Preset_Katana_Wakako", GetTopCustomPrice("Byakko"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Cocktail Stick", "Items.Preset_Katana_Cocktail", GetCommonCustomPrice("CocktailStick"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Cocktail Stick", "Items.Preset_Katana_Cocktail", GetLegendaryCustomPrice("CocktailStick"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cocktail Stick", "Items.Preset_Katana_Cocktail", GetTopCustomPrice("CocktailStick"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Jinchu-Maru", "Items.Preset_Katana_Takemura", GetCommonCustomPrice("JinchuMaru"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Jinchu-Maru", "Items.Preset_Katana_Takemura", GetLegendaryCustomPrice("JinchuMaru"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Jinchu-Maru", "Items.Preset_Katana_Takemura", GetTopCustomPrice("JinchuMaru"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Satori", "Items.Preset_Katana_Saburo", GetCommonCustomPrice("Satori"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Satori", "Items.Preset_Katana_Saburo", GetLegendaryCustomPrice("Satori"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Satori", "Items.Preset_Katana_Saburo", GetTopCustomPrice("Satori"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Scalpel", "Items.Preset_Katana_Surgeon", GetCommonCustomPrice("Scalpel"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Scalpel", "Items.Preset_Katana_Surgeon", GetLegendaryCustomPrice("Scalpel"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Scalpel", "Items.Preset_Katana_Surgeon", GetTopCustomPrice("Scalpel"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Tsumetogi", "Items.Preset_Katana_Hiromi", GetCommonCustomPrice("Tsumetogi"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Tsumetogi", "Items.Preset_Katana_Hiromi", GetLegendaryCustomPrice("Tsumetogi"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Tsumetogi", "Items.Preset_Katana_Hiromi", GetTopCustomPrice("Tsumetogi"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Errata", "Items.Preset_Katana_E3", GetCommonCustomPrice("Errata"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Errata", "Items.Preset_Katana_E3", GetLegendaryCustomPrice("Errata"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Errata", "Items.Preset_Katana_E3", GetTopCustomPrice("Errata"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Black Unicorn", "Items.Preset_Katana_GoG", GetCommonCustomPrice("BlackUnicorn"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Black Unicorn", "Items.Preset_Katana_GoG", GetLegendaryCustomPrice("BlackUnicorn"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Black Unicorn", "Items.Preset_Katana_GoG", GetTopCustomPrice("BlackUnicorn"), "LegendaryPlusPlus"));

  // Iconic Knives
    ArrayPush(ItemsList, ISCreateProduct("Butcher's Cleaver", "Items.Preset_Butchers_Knife_Iconic", GetCommonCustomPrice("ButchersCleaver"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Butcher's Cleaver", "Items.Preset_Butchers_Knife_Iconic", GetLegendaryCustomPrice("ButchersCleaver"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Butcher's Cleaver", "Items.Preset_Butchers_Knife_Iconic", GetTopCustomPrice("ButchersCleaver"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Blue Fang", "Items.Preset_Neurotoxin_Knife_Iconic", GetCommonCustomPrice("BlueFang"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Blue Fang", "Items.Preset_Neurotoxin_Knife_Iconic", GetLegendaryCustomPrice("BlueFang"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Blue Fang", "Items.Preset_Neurotoxin_Knife_Iconic", GetTopCustomPrice("BlueFang"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Headhunter", "Items.Preset_Punk_Knife_Iconic", GetCommonCustomPrice("Headhunter"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Headhunter", "Items.Preset_Punk_Knife_Iconic", GetLegendaryCustomPrice("Headhunter"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Headhunter", "Items.Preset_Punk_Knife_Iconic", GetTopCustomPrice("Headhunter"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Stinger", "Items.Preset_Knife_Stinger", GetCommonCustomPrice("Stinger"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Stinger", "Items.Preset_Knife_Stinger", GetLegendaryCustomPrice("Stinger"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Stinger", "Items.Preset_Knife_Stinger", GetTopCustomPrice("Stinger"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Fang", "Items.Preset_Knife_Kurtz_1", GetCommonCustomPrice("Fang"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Fang", "Items.Preset_Knife_Kurtz_1", GetLegendaryCustomPrice("Fang"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Fang", "Items.Preset_Knife_Kurtz_1", GetTopCustomPrice("Fang"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Nehan", "Items.Preset_Tanto_Saburo", GetCommonCustomPrice("Nehan"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Nehan", "Items.Preset_Tanto_Saburo", GetLegendaryCustomPrice("Nehan"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Nehan", "Items.Preset_Tanto_Saburo", GetTopCustomPrice("Nehan"), "LegendaryPlusPlus"));

  // Other iconic melee weapons
    ArrayPush(ItemsList, ISCreateProduct("VB_Axe", "Items.Preset_VB_Axe", GetCommonCustomPrice("VBAxe"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("VB_Axe", "Items.Preset_VB_Axe", GetLegendaryCustomPrice("VBAxe"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("VB_Axe", "Items.Preset_VB_Axe", GetTopCustomPrice("VBAxe"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Claw x-MOD2", "Items.Preset_Fanged_Axe_Collectible", GetCommonCustomPrice("ClawXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Claw x-MOD2", "Items.Preset_Fanged_Axe_Collectible", GetLegendaryCustomPrice("ClawXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Claw x-MOD2", "Items.Preset_Fanged_Axe_Collectible", GetTopCustomPrice("ClawXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Cut-o-Matic x-MOD2", "Items.Preset_Chainsword_Legendary", GetCommonCustomPrice("CutOMaticXMOD2"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Cut-o-Matic x-MOD2", "Items.Preset_Chainsword_Legendary", GetLegendaryCustomPrice("CutOMaticXMOD2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cut-o-Matic x-MOD2", "Items.Preset_Chainsword_Legendary", GetTopCustomPrice("CutOMaticXMOD2"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Volkodav", "Items.Preset_Machete_Borg_AirDrop", GetCommonCustomPrice("Volkodav"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Volkodav", "Items.Preset_Machete_Borg_AirDrop", GetLegendaryCustomPrice("Volkodav"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Volkodav", "Items.Preset_Machete_Borg_AirDrop", GetTopCustomPrice("Volkodav"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Gwynbleidd", "Items.Preset_Sword_Witcher", GetCommonCustomPrice("Gwynbleidd"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Gwynbleidd", "Items.Preset_Sword_Witcher", GetLegendaryCustomPrice("Gwynbleidd"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Gwynbleidd", "Items.Preset_Sword_Witcher", GetTopCustomPrice("Gwynbleidd"), "LegendaryPlusPlus"));

 // ### Iconic Cyberware ###
  // Iconic Circulatory System
    ArrayPush(ItemsList, ISCreateProduct("Electromag Recycler", "Items.IconicDischargeConnectorLegendary", GetLegendaryCustomPrice("ElectromagRecycler"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Electromag Recycler", "Items.IconicDischargeConnectorLegendaryPlusPlus", GetTopCustomPrice("ElectromagRecycler"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Isometric Stabilizer", "Items.IconicShockAbsorberLegendary", GetLegendaryCustomPrice("IsometricStabilizer"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Isometric Stabilizer", "Items.IconicShockAbsorberLegendaryPlusPlus", GetTopCustomPrice("IsometricStabilizer"), "LegendaryPlusPlus"));

  // Iconic Face Implants
    ArrayPush(ItemsList, ISCreateProduct("Behavioral Imprint-synced Faceplate", "Items.MaskCW", GetLegendaryCustomPrice("BehavioralImprintSyncedFaceplate"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Behavioral Imprint-synced Faceplate", "Items.MaskCWPlusPlus", GetTopCustomPrice("BehavioralImprintSyncedFaceplate"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Kiroshi 'Cockatrice' Optics", "Items.Iconic_AdvancedKiroshiOpticsBareLegendary", GetLegendaryCustomPrice("KiroshiCockatriceOptics"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Kiroshi 'Cockatrice' Optics", "Items.Iconic_AdvancedKiroshiOpticsBareLegendaryPlusPlus", GetTopCustomPrice("KiroshiCockatriceOptics"), "LegendaryPlusPlus"));

  // Iconic Frontal Cortex
    ArrayPush(ItemsList, ISCreateProduct("Axolotl", "Items.IconicAdvancedSubdermalCoProcessorLegendary", GetLegendaryCustomPrice("Axolotl"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Axolotl", "Items.IconicAdvancedSubdermalCoProcessorLegendaryPlusPlus", GetTopCustomPrice("Axolotl"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("COX-2 Cybersomatic Optimizer", "Items.IconicBioConductorsLegendary", GetLegendaryCustomPrice("COX2CybersomaticOptimizer"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("COX-2 Cybersomatic Optimizer", "Items.IconicBioConductorsLegendaryPlusPlus", GetTopCustomPrice("COX2CybersomaticOptimizer"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("RAM Reallocator", "Items.IconicCamilloRamManagerLegendary", GetLegendaryCustomPrice("RAMReallocator"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("RAM Reallocator", "Items.IconicCamilloRamManagerLegendaryPlusPlus", GetTopCustomPrice("RAMReallocator"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Quantum Tuner", "Items.AdvancedTimeBankLegendary", GetLegendaryCustomPrice("QuantumTuner"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Quantum Tuner", "Items.AdvancedTimeBankLegendaryPlusPlus", GetTopCustomPrice("QuantumTuner"), "LegendaryPlusPlus"));

  // Iconic Hands Implants
    ArrayPush(ItemsList, ISCreateProduct("Immovable Force", "Items.IconicGunStabilizerCommon", GetCommonCustomPrice("ImmovableForce"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Immovable Force", "Items.IconicGunStabilizerLegendary", GetLegendaryCustomPrice("ImmovableForce"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Immovable Force", "Items.IconicGunStabilizerLegendaryPlusPlus", GetTopCustomPrice("ImmovableForce"), "LegendaryPlusPlus"));

  // Iconic Integumentary System
    ArrayPush(ItemsList, ISCreateProduct("Chitin", "Items.IconicAdvancedChitonCommon", GetCommonCustomPrice("Chitin"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Chitin", "Items.IconicAdvancedChitonLegendary", GetLegendaryCustomPrice("Chitin"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Chitin", "Items.IconicAdvancedChitonLegendaryPlusPlus", GetTopCustomPrice("Chitin"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Peripheral Inverse", "Items.IconicAdvancedProximityReducerLegendary", GetLegendaryCustomPrice("PeripheralInverse"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Peripheral Inverse", "Items.IconicAdvancedProximityReducerLegendaryPlusPlus", GetTopCustomPrice("PeripheralInverse"), "LegendaryPlusPlus"));

  // Iconic Legs Implants
    ArrayPush(ItemsList, ISCreateProduct("Leeroy Ligament System", "Items.IconicJenkinsTendonsLegendary", GetLegendaryCustomPrice("LeeroyLigamentSystem"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Leeroy Ligament System", "Items.IconicJenkinsTendonsLegendaryPlusPlus", GetTopCustomPrice("LeeroyLigamentSystem"), "LegendaryPlusPlus"));

  // Iconic Nervous System
    ArrayPush(ItemsList, ISCreateProduct("Adreno-trigger", "Items.IconicAdvancedDetectorRushLegendary", GetLegendaryCustomPrice("AdrenoTrigger"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Adreno-trigger", "Items.IconicAdvancedDetectorRushLegendaryPlusPlus", GetTopCustomPrice("AdrenoTrigger"), "LegendaryPlusPlus"));
    
    ArrayPush(ItemsList, ISCreateProduct("Deep-field Visual Interface", "Items.IconicAdvancedVisualCortexSupportCommon", GetCommonCustomPrice("DeepFieldVisualInterface"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Deep-field Visual Interface", "Items.IconicAdvancedVisualCortexSupportLegendary", GetLegendaryCustomPrice("DeepFieldVisualInterface"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Deep-field Visual Interface", "Items.IconicAdvancedVisualCortexSupportLegendaryPlusPlus", GetTopCustomPrice("DeepFieldVisualInterface"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Revulsor", "Items.IconicAdvancedReflexRecorderLegendary", GetLegendaryCustomPrice("Revulsor"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Revulsor", "Items.IconicAdvancedReflexRecorderLegendaryPlusPlus", GetTopCustomPrice("Revulsor"), "LegendaryPlusPlus"));

  // Iconic Operating System
    ArrayPush(ItemsList, ISCreateProduct("Chrome Compressor", "Items.CapacityBoosterLegendary", GetLegendaryCustomPrice("ChromeCompressor"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Chrome Compressor", "Items.CapacityBoosterLegendaryPlusPlus", GetTopCustomPrice("ChromeCompressor"), "LegendaryPlusPlus"));

    ArrayPush(ItemsList, ISCreateProduct("Militech Canto", "Items.HauntedCyberdeck_Legendary", GetLegendaryCustomPrice("MilitechCanto"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Militech Canto", "Items.HauntedCyberdeck_LegendaryPlusPlus", GetTopCustomPrice("MilitechCanto"), "LegendaryPlusPlus"));

  // Iconic Skeleton Implants
    ArrayPush(ItemsList, ISCreateProduct("Rara Avis", "Items.IconicAdvancedT1000Common", GetCommonCustomPrice("RaraAvis"), "Common"));
    ArrayPush(ItemsList, ISCreateProduct("Rara Avis", "Items.IconicAdvancedT1000Legendary", GetLegendaryCustomPrice("RaraAvis"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Rara Avis", "Items.IconicAdvancedT1000LegendaryPlusPlus", GetTopCustomPrice("RaraAvis"), "LegendaryPlusPlus"));

  // Iconic Arms Implants
    ArrayPush(ItemsList, ISCreateProduct("Max TacMantis Blades", "Items.AdvancedMaxTacMantisBladesLegendary", GetLegendaryCustomPrice("MaxTacMantisBlades"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Max TacMantis Blades", "Items.AdvancedMaxTacMantisBladesLegendaryPlusPlus", GetTopCustomPrice("MaxTacMantisBlades"), "LegendaryPlusPlus"));

 // ### Iconic Quickhacks ###
  // Combat
    ArrayPush(ItemsList, ISCreateProduct("Overheat", "Items.OverheatLvl4PlusPlusProgram", GetLegendaryCustomPrice("Overheat"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Short Circuit", "Items.EMPOverloadLvl4PlusPlusProgram", GetLegendaryCustomPrice("ShortCircuit"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Contagion", "Items.ContagionLvl4PlusPlusProgram", GetLegendaryCustomPrice("Contagion"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Synapse Burnout", "Items.BrainMeltLvl4PlusPlusProgram", GetLegendaryCustomPrice("SynapseBurnout"), "Legendary"));

  // Control
    ArrayPush(ItemsList, ISCreateProduct("Reboot Optics", "Items.BlindLvl4PlusPlusProgram", GetLegendaryCustomPrice("RebootOptics"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cyberware Malfunction", "Items.DisableCyberwareLvl4PlusPlusProgram", GetLegendaryCustomPrice("CyberwareMalfunction"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cripple Movement", "Items.LocomotionMalfunctionLvl4PlusPlusProgram", GetLegendaryCustomPrice("CrippleMovement"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Weapon Glitch", "Items.WeaponMalfunctionLvl4PlusPlusProgram", GetLegendaryCustomPrice("WeaponGlitch"), "Legendary"));

  // Covert
    ArrayPush(ItemsList, ISCreateProduct("Ping", "Items.PingLvl4PlusPlusProgram", GetLegendaryCustomPrice("Ping"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Bait", "Items.WhistleLvl4PlusPlusProgram", GetLegendaryCustomPrice("Bait"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Request Backup", "Items.CommsCallInLvl4PlusPlusProgram", GetLegendaryCustomPrice("RequestBackup"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Memory Wipe", "Items.MemoryWipeLvl4PlusPlusProgram", GetLegendaryCustomPrice("MemoryWipe"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Sonic Shock", "Items.CommsNoiseLvl4PlusPlusProgram", GetLegendaryCustomPrice("SonicShock"), "Legendary"));

  // Ultimate
    ArrayPush(ItemsList, ISCreateProduct("Cyberpsychosis", "Items.MadnessLvl4PlusPlusProgram", GetLegendaryCustomPrice("Cyberpsychosis"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Suicide", "Items.SuicideLvl4PlusPlusProgram", GetLegendaryCustomPrice("Suicide"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("System Collapse", "Items.SystemCollapseLvl4PlusPlusProgram", GetLegendaryCustomPrice("SystemCollapse"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("DetonateGrenade", "Items.GrenadeExplodeLvl4PlusPlusProgram", GetLegendaryCustomPrice("DetonateGrenade"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Blackwall Gateway", "Items.BlackWallProgramLvl4Slot", GetLegendaryCustomPrice("BlackWallGateway"), "Legendary"));

 // ### Iconic Mods ###
    ArrayPush(ItemsList, ISCreateProduct("Severance", "Items.ChimeraMeleeMod", GetLegendaryCustomPrice("Severance"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Firecracker", "Items.ChimeraPowerMod", GetLegendaryCustomPrice("Firecracker"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Wallpuncher", "Items.ChimeraTechMod", GetLegendaryCustomPrice("Wallpuncher"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Hackatomy", "Items.ChimeraSmartMod", GetLegendaryCustomPrice("Hackatomy"), "Legendary"));
 // ### Iconic Clothes ###
  // Twitch set
    ArrayPush(ItemsList, ISCreateProduct("NUS infiltrator headgear", "Items.Twitch_Drop_Specs", GetLegendaryCustomPrice("TwitchSetHead"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("NUS infiltrator jacket", "Items.Twitch_Drop_Vest", GetLegendaryCustomPrice("TwitchSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("NUS infiltrator pants", "Items.Twitch_Drop_Pants", GetLegendaryCustomPrice("TwitchSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("NUS infiltrator boots", "Items.Twitch_Drop_Boots", GetLegendaryCustomPrice("TwitchSetFeet"), "Legendary"));
  // Johnny`s set
    ArrayPush(ItemsList, ISCreateProduct("Johnny's aviators", "Items.Q005_Johnny_Glasses", GetLegendaryCustomPrice("JohnnySetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Replica of Johnny's Samurai jacket", "Items.SQ031_Samurai_Jacket", GetLegendaryCustomPrice("JohnnySetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Johnny's tank top", "Items.Q005_Johnny_Shirt", GetLegendaryCustomPrice("JohnnySetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Johnny's pants", "Items.Q005_Johnny_Pants", GetLegendaryCustomPrice("JohnnySetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Johnny's shoes", "Items.Q005_Johnny_Shoes", GetLegendaryCustomPrice("JohnnySetFeet"), "Legendary"));
  // Techie set
    ArrayPush(ItemsList, ISCreateProduct("Cushioned techie baseball cap", "Items.Techie_01_Set_Cap", GetLegendaryCustomPrice("TechieSetHead"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Laminated ICE-protected techie ocuset", "Items.Techie_01_Set_Tech", GetLegendaryCustomPrice("TechieSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Polycarbonate nanoweave techie harness", "Items.Techie_01_Set_Vest", GetLegendaryCustomPrice("TechieSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Thermoactive tear-resistant techie shirt", "Items.Techie_01_Set_TShirt", GetLegendaryCustomPrice("TechieSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Reinforced duolayer techie cargo pants", "Items.Techie_01_Set_Pants", GetLegendaryCustomPrice("TechieSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Cushioned aramid-sole techie shoes", "Items.Techie_01_Set_Shoes", GetLegendaryCustomPrice("TechieSetFeet"), "Legendary"));
  // Solo set
    ArrayPush(ItemsList, ISCreateProduct("Titanium solo techgogs with tactical software", "Items.Solo_01_Set_Visor", GetLegendaryCustomPrice("SoloSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Heavy shock-absorbent solo jacket", "Items.Solo_01_Set_Jacket", GetLegendaryCustomPrice("SoloSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ultrathin composite-print solo shirt", "Items.Solo_01_Set_TShirt", GetLegendaryCustomPrice("SoloSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Armor-plated syn-leather solo pants", "Items.Solo_01_Set_Pants", GetLegendaryCustomPrice("SoloSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Gold-tipped manganese steel solo boots", "Items.Solo_01_Set_Boots", GetLegendaryCustomPrice("SoloSetFeet"), "Legendary"));
  // Rockerboy set
    ArrayPush(ItemsList, ISCreateProduct("Scratch-resistant polarized rocker aviators", "Items.Rockerboy_01_Set_Glasses", GetLegendaryCustomPrice("RockerboySetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Reinforced composite-lined rocker foldtop/Duolayer polyamide rocker vest", "Items.Rockerboy_01_Set_Jacket", GetLegendaryCustomPrice("RockerboySetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Armorweave rocker bra/Reinforced-seam cotton rocker tank", "Items.Rockerboy_01_Set_TShirt", GetLegendaryCustomPrice("RockerboySetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Elastic flame-resistant rocker pants", "Items.Rockerboy_01_Set_Pants", GetLegendaryCustomPrice("RockerboySetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Puncture-resistant rocker ankle boots", "Items.Rockerboy_01_Set_Boots", GetLegendaryCustomPrice("RockerboySetFeet"), "Legendary"));
  // Cop set
    ArrayPush(ItemsList, ISCreateProduct("Holo-tinted badge goggles", "Items.Cop_01_Set_Glasses", GetLegendaryCustomPrice("CopSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Heavy-duty aramid-reinforced badge coat", "Items.Cop_01_Set_Jacket", GetLegendaryCustomPrice("CopSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Anti-puncture neotac pants with composite lining", "Items.Cop_01_Set_Pants", GetLegendaryCustomPrice("CopSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Waterproof badge combat boots", "Items.Cop_01_Set_Boots", GetLegendaryCustomPrice("CopSetFeet"), "Legendary"));
  // Nomad set
    ArrayPush(ItemsList, ISCreateProduct("Manganese-laminate nomad gas mask", "Items.Nomad_01_Set_Mask", GetLegendaryCustomPrice("NomadSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Duolayer microplate-mesh nomad jacket", "Items.Nomad_01_Set_Jacket", GetLegendaryCustomPrice("NomadSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Polycarbonate nomad shirt with reinforced seams", "Items.Nomad_01_Set_TShirt", GetLegendaryCustomPrice("NomadSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ultralight tear-resistant nomad pants", "Items.Nomad_01_Set_Pants", GetLegendaryCustomPrice("NomadSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Durable bioleather nomad western boots", "Items.Nomad_01_Set_Boots", GetLegendaryCustomPrice("NomadSetFeet"), "Legendary"));
  // Netrunner set
    ArrayPush(ItemsList, ISCreateProduct("Antisurge ICE-protected netrunner infovisor", "Items.Netrunner_01_Set_Visor", GetLegendaryCustomPrice("NetrunnerSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Heat-resistant hybridweave netrunning suit", "Items.Netrunner_01_Set_Jumpsuit", GetLegendaryCustomPrice("NetrunnerSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Dura-membrane netrunner neotac pants", "Items.Netrunner_01_Set_Pants", GetLegendaryCustomPrice("NetrunnerSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Hardened netrunner boots with composite inserts", "Items.Netrunner_01_Set_Shoes", GetLegendaryCustomPrice("NetrunnerSetFeet"), "Legendary"));
  // Media set
    ArrayPush(ItemsList, ISCreateProduct("Media baseball cap with reactive layer", "Items.Media_01_Set_Cap", GetLegendaryCustomPrice("MediaSetHead"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Armored media ocuset with camera", "Items.Media_01_Set_Tech", GetLegendaryCustomPrice("MediaSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Laminate-armor media ballistic vest", "Items.Media_01_Set_Vest", GetLegendaryCustomPrice("MediaSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Heat-resistant nanoweave media shirt", "Items.Media_01_Set_Shirt", GetLegendaryCustomPrice("MediaSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Anti-piercing tactical media cargo pants", "Items.Media_01_Set_Pants", GetLegendaryCustomPrice("MediaSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Lightweight hardened-rubber media steel-toes", "Items.Media_01_Set_Shoes", GetLegendaryCustomPrice("MediaSetFeet"), "Legendary"));
  // Fixer set
    ArrayPush(ItemsList, ISCreateProduct("Polycarbonate opti-enhanced fixer glasses", "Items.Fixer_01_Set_Glasses", GetLegendaryCustomPrice("FixerSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Trilayer aramid-weave fixer skirt with jacket/coat", "Items.Fixer_01_Set_Coat", GetLegendaryCustomPrice("FixerSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Heat-resistant aramid-weave fixer bustier/shirt", "Items.Fixer_01_Set_TShirt", GetLegendaryCustomPrice("FixerSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Protective-layer fixer skirt/pants", "Items.Fixer_01_Set_Pants", GetLegendaryCustomPrice("FixerSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Elastiweave fixer pumps with reinforced seams/shoes", "Items.Fixer_01_Set_FormalShoes", GetLegendaryCustomPrice("FixerSetFeet"), "Legendary"));
  // Corporate set
    ArrayPush(ItemsList, ISCreateProduct("Tactical hybrid-glass corporate glasses", "Items.Corporate_01_Set_Glasses", GetLegendaryCustomPrice("CorporateSetFace"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Corporate blazer with bulletproof lining", "Items.Corporate_01_Set_FormalJacket", GetLegendaryCustomPrice("CorporateSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Carbonweave silk corporate shirt", "Items.Corporate_01_Set_FormalShirt", GetLegendaryCustomPrice("CorporateSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Breathable reinforced bio-cotton corporate slacks", "Items.Corporate_01_Set_Pants", GetLegendaryCustomPrice("CorporateSetLegs"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Ergonomic reinforced corporate pumps/evening shoes", "Items.Corporate_01_Set_FormalShoes", GetLegendaryCustomPrice("CorporateSetFeet"), "Legendary"));
  // MaxTac set
    ArrayPush(ItemsList, ISCreateProduct("MaxTac tactical helmet with multifunction infovisor", "Items.SQ030_MaxTac_Helmet", GetLegendaryCustomPrice("MaxTacSetHead"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("MaxTac multilayered armor-weave Jacket", "Items.SQ030_MaxTac_Chest", GetLegendaryCustomPrice("MaxTacSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Heavy-duty MaxTac cargo pants", "Items.SQ030_MaxTac_Pants", GetLegendaryCustomPrice("MaxTacSetLegs"), "Legendary"));
  // GOG set
    ArrayPush(ItemsList, ISCreateProduct("Wolf School Jacket", "Items.GOG_DLC_Jacket", GetLegendaryCustomPrice("GOGSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Galaxy T-shirt", "Items.GOG_Galaxy_TShirt", GetLegendaryCustomPrice("GOGSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Wolf School T-shirt", "Items.GOG_DLC_TShirt", GetLegendaryCustomPrice("GOGSetInnerTorso2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Wild Hunt jacket", "Items.Red_Play_Jacket", GetLegendaryCustomPrice("GOGSetOuterTorso2"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Rarog vest", "Items.Red_Play_Vest", GetLegendaryCustomPrice("GOGSetOuterTorso3"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("GWENT t-shirt", "Items.Red_Play_TShirt", GetLegendaryCustomPrice("GOGSetInnerTorso3"), "Legendary"));
  // Edgerunner set
    ArrayPush(ItemsList, ISCreateProduct("David's Jacket", "Items.MQ049_martinez_jacket", GetLegendaryCustomPrice("EdgerunnerSetOuterTorso"), "Legendary"));
  // The Heist set
    ArrayPush(ItemsList, ISCreateProduct("Kōtetsu no Ryū coat", "Items.Q005_Steel_Dragons_Coat", GetLegendaryCustomPrice("HeistSetOuterTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Yorinobu's formal shirt", "Items.Q005_Yorinobu_FormalShirt", GetLegendaryCustomPrice("HeistSetInnerTorso"), "Legendary"));
    ArrayPush(ItemsList, ISCreateProduct("Yorinobu's slacks", "Items.Q005_Yorinobu_FormalPants", GetLegendaryCustomPrice("HeistSetLegs"), "Legendary"));

 
 // ### Return ###
  return ItemsList;
}

public func GetModItemsList () -> array<ref<ISProduct>> {
  let ItemsList: array<ref<ISProduct>>;
 // ### Extra Iconic ###
  ArrayPush(ItemsList, ISCreateProduct("Danger Room", "Items.SJ_DangerRoom", GetCommonCustomPrice("SJ_DangerRoom"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Danger Room", "Items.SJ_DangerRoom", GetLegendaryCustomPrice("SJ_DangerRoom"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Danger Room", "Items.SJ_DangerRoom", GetTopCustomPrice("SJ_DangerRoom"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Desert Snake", "Items.SJ_DesertSnake", GetCommonCustomPrice("SJ_DesertSnake"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Desert Snake", "Items.SJ_DesertSnake", GetLegendaryCustomPrice("SJ_DesertSnake"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Desert Snake", "Items.SJ_DesertSnake", GetTopCustomPrice("SJ_DesertSnake"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Dice", "Items.SJ_Dice", GetCommonCustomPrice("SJ_Dice"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Dice", "Items.SJ_Dice", GetLegendaryCustomPrice("SJ_Dice"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Dice", "Items.SJ_Dice", GetTopCustomPrice("SJ_Dice"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Firestorm", "Items.SJ_Firestorm", GetCommonCustomPrice("SJ_Firestorm"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Firestorm", "Items.SJ_Firestorm", GetLegendaryCustomPrice("SJ_Firestorm"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Firestorm", "Items.SJ_Firestorm", GetTopCustomPrice("SJ_Firestorm"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Gambiteer", "Items.SJ_Gambiteer", GetCommonCustomPrice("SJ_Gambiteer"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Gambiteer", "Items.SJ_Gambiteer", GetLegendaryCustomPrice("SJ_Gambiteer"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Gambiteer", "Items.SJ_Gambiteer", GetTopCustomPrice("SJ_Gambiteer"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Ghost Blade", "Items.SJ_GhostBlade", GetCommonCustomPrice("SJ_GhostBlade"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Ghost Blade", "Items.SJ_GhostBlade", GetLegendaryCustomPrice("SJ_GhostBlade"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Ghost Blade", "Items.SJ_GhostBlade", GetTopCustomPrice("SJ_GhostBlade"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("High Doom", "Items.SJ_HighDoom", GetCommonCustomPrice("SJ_HighDoom"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("High Doom", "Items.SJ_HighDoom", GetLegendaryCustomPrice("SJ_HighDoom"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("High Doom", "Items.SJ_HighDoom", GetTopCustomPrice("SJ_HighDoom"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Mercy", "Items.SJ_Mercy", GetCommonCustomPrice("SJ_Mercy"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Mercy", "Items.SJ_Mercy", GetLegendaryCustomPrice("SJ_Mercy"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Mercy", "Items.SJ_Mercy", GetTopCustomPrice("SJ_Mercy"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Mistifier", "Items.SJ_Mistifier", GetCommonCustomPrice("SJ_Mistifier"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Mistifier", "Items.SJ_Mistifier", GetLegendaryCustomPrice("SJ_Mistifier"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Mistifier", "Items.SJ_Mistifier", GetTopCustomPrice("SJ_Mistifier"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("NetHound", "Items.SJ_NetHound", GetCommonCustomPrice("SJ_NetHound"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("NetHound", "Items.SJ_NetHound", GetLegendaryCustomPrice("SJ_NetHound"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("NetHound", "Items.SJ_NetHound", GetTopCustomPrice("SJ_NetHound"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("NetRam", "Items.SJ_NetRam", GetCommonCustomPrice("SJ_NetRam"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("NetRam", "Items.SJ_NetRam", GetLegendaryCustomPrice("SJ_NetRam"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("NetRam", "Items.SJ_NetRam", GetTopCustomPrice("SJ_NetRam"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Plasma Shotgun", "Items.SJ_PlasmaShotgun", GetCommonCustomPrice("SJ_PlasmaShotgun"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Plasma Shotgun", "Items.SJ_PlasmaShotgun", GetLegendaryCustomPrice("SJ_PlasmaShotgun"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Plasma Shotgun", "Items.SJ_PlasmaShotgun", GetTopCustomPrice("SJ_PlasmaShotgun"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Raijin", "Items.SJ_Raijin", GetCommonCustomPrice("SJ_Raijin"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Raijin", "Items.SJ_Raijin", GetLegendaryCustomPrice("SJ_Raijin"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Raijin", "Items.SJ_Raijin", GetTopCustomPrice("SJ_Raijin"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Slice", "Items.SJ_Slice", GetCommonCustomPrice("SJ_Slice"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Slice", "Items.SJ_Slice", GetLegendaryCustomPrice("SJ_Slice"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Slice", "Items.SJ_Slice", GetTopCustomPrice("SJ_Slice"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Special Delivery", "Items.SJ_SpecialDelivery", GetCommonCustomPrice("SJ_SpecialDelivery"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Special Delivery", "Items.SJ_SpecialDelivery", GetLegendaryCustomPrice("SJ_SpecialDelivery"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Special Delivery", "Items.SJ_SpecialDelivery", GetTopCustomPrice("SJ_SpecialDelivery"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Thunderstrike", "Items.SJ_Thunderstrike", GetCommonCustomPrice("SJ_Thunderstrike"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Thunderstrike", "Items.SJ_Thunderstrike", GetLegendaryCustomPrice("SJ_Thunderstrike"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Thunderstrike", "Items.SJ_Thunderstrike", GetTopCustomPrice("SJ_Thunderstrike"), "LegendaryPlusPlus"));

  ArrayPush(ItemsList, ISCreateProduct("Tzijimura", "Items.SJ_Tzijimura", GetCommonCustomPrice("SJ_Tzijimura"), "Common"));
  ArrayPush(ItemsList, ISCreateProduct("Tzijimura", "Items.SJ_Tzijimura", GetLegendaryCustomPrice("SJ_Tzijimura"), "Legendary"));
  ArrayPush(ItemsList, ISCreateProduct("Tzijimura", "Items.SJ_Tzijimura", GetTopCustomPrice("SJ_Tzijimura"), "LegendaryPlusPlus"));
 // ### Return ###
  return ItemsList; 
}  

public func GetSettingPrices (itemID: String, defaultPrice: Int32, settings: ref<ISSetting>) -> Int32 {
  switch (itemID) {
  // ### Iconic Ranged Weapons ###
   // Iconic Pistols  
    case "HerMajesty":
      return settings.HerMajesty;
    case "Cheetah":
      return settings.Cheetah;
    case "DyingNight":
      return settings.DyingNight;
    case "LexingtonXMOD2":
      return settings.LexingtonXMOD2;
    case "Rook":
      return settings.Rook;
    case "Kongou":
      return settings.Kongou;
    case "PlanB":
      return settings.PlanB;
    case "Pride":
      return settings.Pride;
    case "Seraph":
      return settings.Seraph;
    case "DeathAndTaxes":
      return settings.DeathAndTaxes;
    case "LaChingonaDorada":
      return settings.LaChingonaDorada;
    case "Riskit":
      return settings.Riskit;
    case "MalorianArms3516":
      return settings.MalorianArms3516;
    case "Genjiroh":
      return settings.Genjiroh;
    case "Skippy":
      return settings.Skippy;
    case "Crimestopper":
      return settings.Crimestopper;
    case "KappaXMOD2":
      return settings.KappaXMOD2;
    case "Ogou":
      return settings.Ogou;
    case "Apparition":
      return settings.Apparition;
    case "Chaos":
      return settings.Chaos;
    case "Ambition":
      return settings.Ambition;
    case "Catahoula":
      return settings.Catahoula;
    case "Lizzie":
      return settings.Lizzie;
    case "Pariah":
      return settings.Pariah;
    case "Scorch":
      return settings.Scorch;

   // Iconic Revolvers
    case "DoomDoom":
      return settings.DoomDoom;
    case "Mancinella":
      return settings.Mancinella;
    case "Amnesty":
      return settings.Amnesty;
    case "Archangel":
      return settings.Archangel;
    case "Crash":
      return settings.Crash;
    case "Rosco":
      return settings.Rosco;
    case "OlReliable":
      return settings.OlReliable;
    case "Taigan":
      return settings.Taigan;
    case "BaldEagle":
      return settings.BaldEagle;
    case "ComradesHammer":
      return settings.ComradesHammer;
    case "Laika":
      return settings.Laika;
    case "GrisGris":
      return settings.GrisGris;

   // Iconic Shotguns
    case "TheHeadsman":
      return settings.TheHeadsman;
    case "BloodyMaria":
      return settings.BloodyMaria;
    case "Mox":
      return settings.Mox;
    case "Guts":
      return settings.Guts;
    case "Amstaff":
      return settings.Amstaff;
    case "Dezerter":
      return settings.Dezerter;
    case "Sovereign":
      return settings.Sovereign;
    case "Alabai":
      return settings.Alabai;
    case "PozharXMOD2":
      return settings.PozharXMOD2;
    case "BaXingChong":
      return settings.BaXingChong;
    case "Order":
      return settings.Order;

   // Iconic Submachine Guns
    case "Fenrir":
      return settings.Fenrir;
    case "ProblemSolver":
      return settings.ProblemSolver;
    case "GuillotineXMOD2":
      return settings.GuillotineXMOD2;
    case "Buzzsaw":
      return settings.Buzzsaw;
    case "MidnightArmsErebus":
      return settings.MidnightArmsErebus;
    case "PrototypeShingenMarkV":
      return settings.PrototypeShingenMarkV;
    case "Yinglong":
      return settings.Yinglong;
    case "Pizdets":
      return settings.Pizdets;
    case "Chesapeake":
      return settings.Chesapeake;
    case "Raiju":
      return settings.Raiju;

   // Iconic Assault Rifles
    case "Prejudice":
      return settings.Prejudice;
    case "Carmen":
      return settings.Carmen;
    case "UmbraXMOD2":
      return settings.UmbraXMOD2;
    case "KyubiXMOD2":
      return settings.KyubiXMOD2;
    case "Hawk":
      return settings.Hawk;
    case "Chinook":
      return settings.Chinook;
    case "MoronLabe":
      return settings.MoronLabe;
    case "PitBull":
      return settings.PitBull;
    case "Psalm116":
      return settings.Psalm116;
    case "DividedWeStand":
      return settings.DividedWeStand;
    case "MilitechHercules3AX":
      return settings.MilitechHercules3AX;

   // Iconic Machine Guns
    case "WildDog":
      return settings.WildDog;
    case "MA70HBXMOD2":
      return settings.MA70HBXMOD2;

   // Iconic Precision Rifles
    case "Hypercritical":
      return settings.Hypercritical;
    case "WidowMaker":
      return settings.WidowMaker;
    case "AchillesXMOD2":
      return settings.AchillesXMOD2;

   // Iconic Sniper Rifles
    case "OFive":
      return settings.OFive;
    case "Overwatch":
      return settings.Overwatch;
    case "Sparky":
      return settings.Sparky;
    case "Borzaya":
      return settings.Borzaya;
    case "NokotaOsprey":
      return settings.NokotaOsprey;
    case "Yasha":
      return settings.Yasha;
    case "Breakthrough":
      return settings.Breakthrough;
    case "Foxhound":
      return settings.Foxhound;
    case "TsunamiRasetsu":
      return settings.TsunamiRasetsu;
  // ### Iconic 2H Clubs and Hammers ###
   // Iconic 2H Clubs and Hammers
    case "GoldPlatedBaseballBat":
      return settings.GoldPlatedBaseballBat;
    case "BabyBoomer":
      return settings.BabyBoomer;
    case "BaseballBatXMOD2":
      return settings.BaseballBatXMOD2;
    case "CaretakersSpade":
      return settings.CaretakersSpade;
    case "SasquatchsHammer":
      return settings.SasquatchsHammer;
    
   // Iconic 1H Blunts
    case "Cottonmouth":
      return settings.Cottonmouth;
    case "SirJohnPhallustiff":
      return settings.SirJohnPhallustiff;
    case "BFC9000":
      return settings.BFC9000;
    case "TinkerBell":
      return settings.TinkerBell;
    case "MurphysLaw":
      return settings.MurphysLaw;
    case "Crowbar":
      return settings.Crowbar;

   // Iconic Katana
    case "Byakko":  
      return settings.Byakko;
    case "CocktailStick":
      return settings.CocktailStick;
    case "JinchuMaru": 
      return settings.JinchuMaru;
    case "Satori":
      return settings.Satori;
    case "Scalpel":
      return settings.Scalpel;
    case "Tsumetogi":
      return settings.Tsumetogi;
    case "Errata":
      return settings.Errata;
    case "BlackUnicorn":
      return settings.BlackUnicorn;

   // Iconic Knives
    case "ButchersCleaver":
      return settings.ButchersCleaver;
    case "BlueFang":
      return settings.BlueFang;
    case "Headhunter":
      return settings.Headhunter;
    case "Stinger":
      return settings.Stinger;
    case "Fang":
      return settings.Fang;
    case "Nehan":
      return settings.Nehan;

   // Other melee weapons
    case "Agaou":
      return settings.Agaou;
    case "ClawXMOD2":
      return settings.ClawXMOD2;
    case "CutOMaticXMOD2":
      return settings.CutOMaticXMOD2;
    case "Volkodav":
      return settings.Volkodav;
    case "Gwynbleidd":
      return settings.Gwynbleidd;
    
  // ### Iconic Cyberware ###
   // Circulatory System
    case "ElectromagRecycler":
      return settings.ElectromagRecycler;
    case "IsometricStabilizer":
      return settings.IsometricStabilizer;

   // Face Implant
    case "BehavioralImprintSyncedFaceplate":
      return settings.BehavioralImprintSyncedFaceplate;
    case "KiroshiCockatriceOptics":
      return settings.KiroshiCockatriceOptics;

   // Frontal Cortex
    case "Axolotl":
      return settings.Axolotl;
    case "COX2CybersomaticOptimizer":
      return settings.COX2CybersomaticOptimizer;
    case "RAMReallocator":
      return settings.RAMReallocator;
    case "QuantumTuner":
      return settings.QuantumTuner;

   // Hands Implant
    case "ImmovableForce":
      return settings.ImmovableForce;

   // Integumentary System
    case "Chitin":
      return settings.Chitin;
    case "PeripheralInverse":
      return settings.PeripheralInverse;
    case "LeeroyLigamentSystem":
      return settings.LeeroyLigamentSystem;

   // Nervous System
    case "AdrenoTrigger":
      return settings.AdrenoTrigger;
    case "DeepFieldVisualInterface":
      return settings.DeepFieldVisualInterface;
    case "Revulsor":
      return settings.Revulsor;

   // Operating System
    case "ChromeCompressor":
      return settings.ChromeCompressor;
    case "MilitechCanto":
      return settings.MilitechCanto;

   // Skeleton Implants
    case "RaraAvis":
      return settings.RaraAvis;

   // Arms
    case "MaxTacMantisBlades":
      return settings.MaxTacMantisBlades;

  // ### Iconic Quickhacks ###
   // Combat Quickhacks
    case "Overheat":
      return settings.Overheat;
    case "ShortCircuit":
      return settings.ShortCircuit;
    case "Contagion":
      return settings.Contagion;
    case "SynapseBurnout":
    return settings.SynapseBurnout;
   // Control Quickhacks
    case "RebootOptics":
      return settings.RebootOptics;
    case "CyberwareMalfunction":
      return settings.CyberwareMalfunction;
    case "CrippleMovement":
      return settings.CrippleMovement;
    case "WeaponGlitch":
      return settings.WeaponGlitch;
   // Covert Quickhacks
    case "Ping":
      return settings.Ping;
    case "Bait":
      return settings.Bait;
    case "RequestBackup":
      return settings.RequestBackup;
    case "MemoryWipe":
      return settings.MemoryWipe;
    case "SonicShock":
      return settings.SonicShock;
   // Ultimate Quickhacks
    case "Cyberpsychosis":
      return settings.Cyberpsychosis;
    case "Suicide":
      return settings.Suicide;
    case "SystemCollapse":
      return settings.SystemCollapse;
    case "DetonateGrenade":
      return settings.DetonateGrenade;
    case "BlackWallGateway":
      return settings.BlackWallGateway;
  // ### Iconic Mods ###
    case "Severance":
      return settings.Severance;
    case "Firecracker":
      return settings.Firecracker;
    case "Wallpuncher":
      return settings.Wallpuncher;
    case "Hackatomy":
      return settings.Hackatomy;
  // ### Iconic Clothes
   // Twitch set  
    case "TwitchSetHead":
      return settings.Head;
    case "TwitchSetOuterTorso":
      return settings.OuterTorso;
    case "TwitchSetLegs":
      return settings.Legs;
    case "TwitchSetFeet":
      return settings.Feet;
   // Johnny`s set
    case "JohnnySetFace":
      return settings.Face;
    case "JohnnySetOuterTorso":
      return settings.OuterTorso;
    case "JohnnySetInnerTorso":
      return settings.InnerTorso;
    case "JohnnySetLegs":
      return settings.Legs;
    case "JohnnySetFeet":
      return settings.Feet;
   // Techie set
    case "TechieSetHead":
      return settings.Head;
    case "TechieSetFace":
      return settings.Face;
    case "TechieSetOuterTorso":
      return settings.OuterTorso;
    case "TechieSetInnerTorso":
      return settings.InnerTorso;
    case "TechieSetLegs":
      return settings.Legs;
    case "TechieSetFeet":
      return settings.Feet;
   // Solo set
    case "SoloSetFace":
      return settings.Face;
    case "SoloSetOuterTorso":
      return settings.OuterTorso;
    case "SoloSetInnerTorso":
      return settings.InnerTorso;
    case "SoloSetLegs":
      return settings.Legs;
    case "SoloSetFeet":
      return settings.Feet;
   // Rockerboy set
    case "RockerboySetFace":
      return settings.Face;
    case "RockerboySetOuterTorso":
      return settings.OuterTorso;
    case "RockerboySetInnerTorso":
      return settings.InnerTorso;
    case "RockerboySetLegs":
      return settings.Legs;
    case "RockerboySetFeet":
      return settings.Feet;
   // Cop set
    case "CopSetFace":
      return settings.Face;
    case "CopSetOuterTorso":
      return settings.OuterTorso;
    case "CopSetInnerTorso":
      return settings.InnerTorso;
    case "CopSetLegs":
      return settings.Legs;
    case "CopSetFeet":
      return settings.Feet;
   // Nomad set
    case "NomadSetFace":
      return settings.Face;
    case "NomadSetOuterTorso":
      return settings.OuterTorso;
    case "NomadSetInnerTorso":
      return settings.InnerTorso;
    case "NomadSetLegs":
      return settings.Legs;
    case "NomadSetFeet":
      return settings.Feet;
   // Netrunner set
    case "NetrunnerSetFace":
      return settings.Face;
    case "NetrunnerSetOuterTorso":
      return settings.OuterTorso;
    case "NetrunnerSetInnerTorso":
      return settings.InnerTorso;
    case "NetrunnerSetLegs":
      return settings.Legs;
    case "NetrunnerSetFeet":
      return settings.Feet;
   // Media set
    case "MediaSetFace":
      return settings.Face;
    case "MediaSetOuterTorso":
      return settings.OuterTorso;
    case "MediaSetInnerTorso":
      return settings.InnerTorso;
    case "MediaSetLegs":
      return settings.Legs;
    case "MediaSetFeet":
      return settings.Feet;
   // Fixer set
    case "FixerSetFace":
      return settings.Face;
    case "FixerSetOuterTorso":
      return settings.OuterTorso;
    case "FixerSetInnerTorso":
      return settings.InnerTorso;
    case "FixerSetLegs":
      return settings.Legs;
    case "FixerSetFeet":
      return settings.Feet;
   // Corporate set
    case "CorporateSetFace":
      return settings.Face;
    case "CorporateSetOuterTorso":
      return settings.OuterTorso;
    case "CorporateSetInnerTorso":
      return settings.InnerTorso;
    case "CorporateSetLegs":
      return settings.Legs;
    case "CorporateSetFeet":
      return settings.Feet;
  // MaxTac set
    case "MaxTacSetHead":
      return settings.Head;
    case "MaxTacSetOuterTorso":
      return settings.OuterTorso;
    case "MaxTacSetLegs":
      return settings.Legs;
  // GOG set
    case "GOGSetOuterTorso":
      return settings.OuterTorso;
    case "GOGSetInnerTorso":
      return settings.InnerTorso;
    case "GOGSetInnerTorso2":
      return settings.InnerTorso;
    case "GOGSetOuterTorso2":
      return settings.OuterTorso;
    case "GOGSetOuterTorso3":
      return settings.OuterTorso;
    case "GOGSetInnerTorso3":
      return settings.InnerTorso;
  // Edgerunner set
    case "EdgerunnerSetOuterTorso":
      return settings.OuterTorso;
  // The Heist set
    case "HeistSetOuterTorso":
      return settings.OuterTorso;
    case "HeistSetInnerTorso":
      return settings.InnerTorso;
    case "HeistSetLegs":
      return settings.Legs;

  // ### DEFAULT ###
    default:
      return defaultPrice;
  }
}