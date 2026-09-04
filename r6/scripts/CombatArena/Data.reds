// =====================================================================
//  COMBAT ARENA - DATA
//
//  Every TweakDBID here was verified against the shipped TweakDB.
//  Built once and cached by ArenaSystem; never rebuilt per frame.
// =====================================================================

public class ArenaWeapon {
  public let name: String;
  public let id: TweakDBID;
  public let price: Int32;
  public let cat: Int32;   // index into ArenaData.CategoryNames()
}

public class ArenaAlly {
  public let name: String;
  public let id: TweakDBID;
  public let blurb: String;
  public let tier: Int32;  // index into ArenaData.TierNames()
  public let price: Int32;
}

public class ArenaPerk {
  public let key: CName;
  public let name: String;
  public let blurb: String;
  public let price: Int32;
}

public abstract class ArenaData {

  // ------------------------------------------------------------ helpers

  public static func W(name: String, id: TweakDBID, price: Int32, cat: Int32) -> ref<ArenaWeapon> {
    let w = new ArenaWeapon();
    w.name = name; w.id = id; w.price = price; w.cat = cat;
    return w;
  }

  public static func A(name: String, id: TweakDBID, tier: Int32, price: Int32, blurb: String) -> ref<ArenaAlly> {
    let a = new ArenaAlly();
    a.name = name; a.id = id; a.tier = tier; a.price = price; a.blurb = blurb;
    return a;
  }

  public static func P(key: CName, name: String, price: Int32, blurb: String) -> ref<ArenaPerk> {
    let p = new ArenaPerk();
    p.key = key; p.name = name; p.price = price; p.blurb = blurb;
    return p;
  }

  // --------------------------------------------------------- categories

  public static func CategoryNames() -> array<String> {
    return [
      "HANDGUNS", "SMGS", "SHOTGUNS", "RIFLES", "SNIPERS", "MELEE", "THROWN",
      "ICONIC HANDGUNS", "ICONIC SMGS", "ICONIC SHOTGUNS", "ICONIC RIFLES",
      "ICONIC SNIPERS", "ICONIC HEAVY", "ICONIC SMART", "ICONIC MELEE"
    ];
  }

  // --------------------------------------------------------- the arsenal

  public static func Weapons() -> array<ref<ArenaWeapon>> {
    return [
      // handguns
      ArenaData.W("Lexington",        t"Items.Preset_Lexington_Default", 90, 0),
      ArenaData.W("Unity",            t"Items.Preset_Unity_Default", 90, 0),
      ArenaData.W("Nue",              t"Items.Preset_Nue_Default", 90, 0),
      ArenaData.W("Overture",         t"Items.Preset_Overture_Default", 100, 0),
      ArenaData.W("Burya",            t"Items.Preset_Burya_Default", 100, 0),
      // smgs
      ArenaData.W("Pulsar",           t"Items.Preset_Pulsar_Default", 110, 1),
      ArenaData.W("Saratoga",         t"Items.Preset_Saratoga_Default", 110, 1),
      ArenaData.W("Shingen",          t"Items.Preset_Shingen_Default", 110, 1),
      // shotguns
      ArenaData.W("Carnage",          t"Items.Preset_Carnage_Default", 130, 2),
      ArenaData.W("Crusher",          t"Items.Preset_Crusher_Default", 130, 2),
      // rifles
      ArenaData.W("Ajax",             t"Items.Preset_Ajax_Default", 140, 3),
      ArenaData.W("Copperhead",       t"Items.Preset_Copperhead_Default", 140, 3),
      ArenaData.W("Masamune",         t"Items.Preset_Masamune_Default", 140, 3),
      // snipers
      ArenaData.W("Nekomata",         t"Items.Preset_Nekomata_Default", 170, 4),
      ArenaData.W("Grad",             t"Items.Preset_Grad_Default", 170, 4),
      ArenaData.W("Achilles",         t"Items.Preset_Achilles_Default", 170, 4),
      // melee
      ArenaData.W("Katana",           t"Items.Preset_Katana_Default", 70, 5),
      ArenaData.W("Machete",          t"Items.Preset_Machete_Default", 70, 5),
      ArenaData.W("Baseball Bat",     t"Items.Preset_Baseball_Bat_Default", 70, 5),
      // thrown
      ArenaData.W("Frag Grenade",     t"Items.GrenadeFragRegular", 50, 6),
      ArenaData.W("Incendiary",       t"Items.GrenadeIncendiaryRegular", 50, 6),
      ArenaData.W("EMP Grenade",      t"Items.GrenadeEMPRegular", 50, 6),

      // iconic handguns
      ArenaData.W("Dying Night",      t"Items.Preset_Lexington_Wilson", 320, 7),
      ArenaData.W("Rook",             t"Items.Preset_Lexington_Rook", 320, 7),
      ArenaData.W("Cheetah",          t"Items.Preset_Unity_Angelica", 320, 7),
      ArenaData.W("Her Majesty",      t"Items.Preset_Unity_Agent", 320, 7),
      ArenaData.W("La Chingona Dorada", t"Items.Preset_Nue_Jackie", 320, 7),
      ArenaData.W("Plan B",           t"Items.Preset_Liberty_Dex", 320, 7),
      ArenaData.W("Pride",            t"Items.Preset_Liberty_Rogue", 320, 7),
      ArenaData.W("Seraph",           t"Items.Preset_Liberty_Padre", 320, 7),
      ArenaData.W("Lizzie",           t"Items.Preset_Omaha_Suzie", 320, 7),
      ArenaData.W("Genjiroh",         t"Items.Preset_Yukimura_Kiji", 340, 7),
      ArenaData.W("Skippy",           t"Items.Preset_Yukimura_Skippy_PostQuest", 340, 7),
      ArenaData.W("Malorian 3516",    t"Items.Preset_Silverhand_3516", 400, 7),
      ArenaData.W("Amnesty",          t"Items.Preset_Overture_Cassidy", 340, 7),
      ArenaData.W("Archangel",        t"Items.Preset_Overture_Kerry", 340, 7),
      ArenaData.W("Comrade's Hammer", t"Items.Preset_Burya_Comrade", 340, 7),
      ArenaData.W("Bald Eagle",       t"Items.Preset_Metel_Kurt", 340, 7),

      // iconic smgs
      ArenaData.W("Buzzsaw",          t"Items.Preset_Pulsar_Buzzsaw", 340, 8),
      ArenaData.W("Fenrir",           t"Items.Preset_Saratoga_Maelstrom", 340, 8),
      ArenaData.W("Problem Solver",   t"Items.Preset_Saratoga_Raffen", 340, 8),
      ArenaData.W("Shingen V",        t"Items.Preset_Shingen_Prototype", 340, 8),
      ArenaData.W("Erebus",           t"Items.Preset_Borg4a_HauntedGun", 400, 8),

      // iconic shotguns
      ArenaData.W("Mox",              t"Items.Preset_Carnage_Mox", 360, 9),
      ArenaData.W("Guts",             t"Items.Preset_Carnage_Edgerunners", 360, 9),
      ArenaData.W("Bloody Maria",     t"Items.Preset_Tactician_Dino", 360, 9),
      ArenaData.W("The Headsman",     t"Items.Preset_Tactician_Headsman", 360, 9),
      ArenaData.W("Order",            t"Items.Preset_Satara_Brick", 360, 9),
      ArenaData.W("Ba Xing Chong",    t"Items.Preset_Zhuo_Eight_Star", 420, 9),

      // iconic rifles
      ArenaData.W("Moron Labe",       t"Items.Preset_Ajax_Moron", 380, 10),
      ArenaData.W("Psalm 11:6",       t"Items.Preset_Copperhead_Genesis", 380, 10),
      ArenaData.W("Prejudice",        t"Items.Preset_Masamune_Rogue", 380, 10),
      ArenaData.W("Divided We Stand", t"Items.Preset_Sidewinder_Divided", 380, 10),
      ArenaData.W("Yinglong",         t"Items.Preset_Dian_Yinglong", 380, 10),

      // iconic snipers
      ArenaData.W("Widow Maker",      t"Items.Preset_Achilles_Nash", 400, 11),
      ArenaData.W("Breakthrough",     t"Items.Preset_Nekomata_Breakthrough", 400, 11),
      ArenaData.W("O'Five",           t"Items.Preset_Grad_Buck", 400, 11),
      ArenaData.W("Overwatch",        t"Items.Preset_Grad_Panam", 400, 11),
      ArenaData.W("Rasetsu",          t"Items.Preset_Rasetsu_Prototype", 400, 11),

      // iconic heavy
      ArenaData.W("Wild Dog",         t"Items.Preset_Defender_Kurt", 480, 12),
      ArenaData.W("Pizdets",          t"Items.Preset_Warden_Boris", 480, 12),
      ArenaData.W("Hercules 3AX",     t"Items.Preset_Hercules_Prototype", 480, 12),
      ArenaData.W("Sovereign",        t"Items.Preset_Igla_Sovereign", 480, 12),

      // iconic smart
      ArenaData.W("Ambition",         t"Items.Preset_Kenshin_Spy", 380, 13),
      ArenaData.W("Chaos",            t"Items.Preset_Kenshin_Royce", 380, 13),
      ArenaData.W("Carmen",           t"Items.Preset_Umbra_Bebe", 380, 13),
      ArenaData.W("Hypercritical",    t"Items.Preset_Kolac_Tiny_Mike", 380, 13),

      // iconic melee
      ArenaData.W("Satori",           t"Items.Preset_Katana_Saburo", 300, 14),
      ArenaData.W("Jinchu-Maru",      t"Items.Preset_Katana_Takemura", 300, 14),
      ArenaData.W("Byakko",           t"Items.Preset_Katana_Wakako", 300, 14),
      ArenaData.W("Scalpel",          t"Items.Preset_Katana_Surgeon", 300, 14),
      ArenaData.W("Gwynbleidd",       t"Items.Preset_Sword_Witcher", 300, 14),
      ArenaData.W("Black Unicorn",    t"Items.Preset_Katana_GoG", 300, 14),
      ArenaData.W("Sasquatch's Hammer", t"Items.w_melee_boss_hammer", 340, 14),
      ArenaData.W("Cottonmouth",      t"Items.Preset_Cane_Fingers", 300, 14),
      ArenaData.W("Headhunter",       t"Items.Preset_Punk_Knife_Iconic", 300, 14),
      ArenaData.W("Stinger",          t"Items.Preset_Knife_Stinger", 300, 14),
      ArenaData.W("Agaou",            t"Items.Preset_VB_Axe", 300, 14),
      ArenaData.W("Ogou",             t"Items.Preset_Chao_VooDoo", 300, 14)
    ];
  }

  // ------------------------------------------------------------ enemies

  public static func Grunts() -> array<TweakDBID> {
    return [
      t"Character.bls_se_tyger_claws_biker1_melee1_baseball_wa",
      t"Character.bls_se_tyger_claws_biker1_ranged1_nue_wa",
      t"Character.bls_se_wraiths_grunt1_melee1_tireiron_ma",
      t"Character.bls_se_wraiths_grunt1_ranged1_nova_ma",
      t"Character.arr_valentinos_grunt1_ranged1_nova_ma",
      t"Character.arr_valentinos_grunt2_melee2_knife_ma",
      t"Character.cpz_maelstrom_grunt1_ranged1_copperhead_ma",
      t"Character.enemy_maelstrom_melee_machete",
      t"Character.kabuki_maelstrom_handgunner",
      t"Character.cvi_animals_grunt1_ranged1_pulsar_mb"
    ];
  }

  public static func Heavies() -> array<TweakDBID> {
    return [
      t"Character.bls_ne_maelstrom_grunt2_ranged2_ajax_wa",
      t"Character.enemy_maelstrom_shotgun",
      t"Character.bls_se_tyger_claws_gangster3_ranged3_sidewinder_ma",
      t"Character.bls_se_tyger_claws_biker3_shotgun2_tactician_wa",
      t"Character.arr_militech_ranger2_ranged2_omaha_ma",
      t"Character.bls_se_militech_android_android2_ajax_ma",
      t"Character.bls_se_wraiths_android_android2_pulsar_ma",
      t"Character.animals_bouncer2_hmelee2_hammer_mba_rare",
      t"Character.animals_bouncer1_ranged1_omaha_mb",
      t"Character.arasaka_agent_fmelee2rare_katana_ma_rare",
      // The netrunner and the quest drone that used to close this list
      // spawned but never fought - swapped for proven shooters.
      t"Character.bls_se_wraiths_grunt2_ranged2_copperhead_ma",
      t"Character.arasaka_ranger1_melee2_knife_ma"
    ];
  }

  public static func Bosses() -> array<TweakDBID> {
    return [
      t"Character.main_boss_oda",
      t"Character.ma_hey_spr_06_cyberpsycho",
      t"Character.ma_bls_ina_se1_08_cyberpsycho"
    ];
  }

  public static func FinalBoss() -> TweakDBID {
    return t"Character.main_boss_adam_smasher";
  }

  // ------------------------------------------------------------- allies

  public static func TierNames() -> array<String> {
    return [
      "STREET BACKUP", "HIRED GUN", "NIGHT CITY CREW",
      "AFTERLIFE LEGEND", "THE CHOOM", "MERC OF LAST RESORT"
    ];
  }

  public static func TierPrices() -> array<Int32> {
    return [250, 500, 900, 1400, 2000, 3500];
  }

  public static func Allies() -> array<ref<ArenaAlly>> {
    return [
      ArenaData.A("Militech Griffin",  t"Character.bls_se_militech_drone_griffin_medium", 0, 250,
        "Rented combat drone. Loyal until the battery dies."),
      ArenaData.A("Animals Bouncer",   t"Character.animals_bouncer1_ranged1_omaha_mb", 0, 250,
        "All protein, no plan. Absorbs bullets beautifully."),
      ArenaData.A("Valentino Soldado", t"Character.arr_valentinos_grunt2_ranged2_ajax_ma", 0, 250,
        "Owes somebody a favour. Tonight that's you."),

      ArenaData.A("Arasaka Ninja",     t"Character.arasaka_ninja_fmelee3_mantis_ma_elite", 1, 500,
        "Mantis blades. Doesn't talk. Doesn't need to."),
      ArenaData.A("Arasaka Sumo",      t"Character.arasaka_sumo_hmelee2_fists_mb_rare", 1, 500,
        "A wall that punches back."),
      ArenaData.A("Militech Minotaur", t"Character.bls_se_militech_minotaur", 1, 500,
        "Two tonnes of corporate problem-solving."),

      // Tier 2 is combat NPCs only. The friendly civilians who used to
      // live here (Judy, Kerry, Claire, Mitch, Saul) spawn without
      // fight-capable AI, so they are out - no decorative crew.
      // Panam, Jackie and Songbird's story records never engage when
      // spawned outside their quests - these are elite combat records
      // cast to play their roles instead.
      ArenaData.A("Aldecaldo Sniper",  t"Character.aldecaldos_grunt2_sniper2_sor22_wa_elite", 2, 900,
        "Nomad temper, Overwatch aim. Best backup in the Badlands."),
      ArenaData.A("Aldecaldo Bruiser", t"Character.aldecaldos_grunt2_melee2__ma", 2, 900,
        "Nomad muscle. Settles arguments with a wrench."),
      ArenaData.A("Wraith Raider",     t"Character.bls_se_wraiths_grunt2_ranged2_pulsar_wa", 2, 900,
        "Badlands pirate with an SMG and no manners."),
      ArenaData.A("Arasaka Ranger",    t"Character.arasaka_ranger1_ranged2_masamune_ma", 2, 900,
        "Corporate soldier, off the books for one night."),
      ArenaData.A("Tyger Claws Gunner", t"Character.bls_se_tyger_claws_gangster1_ranged1_copperhead_wa", 2, 900,
        "Kabuki muscle on loan. Cheap ink, expensive aim."),

      // Tier 3+ is verified-combat only. Rogue and Takemura's story
      // records idle like the other companions did, and Oda's follower
      // record was unproven - all replaced with elite records from
      // pools that demonstrably fight.
      ArenaData.A("Militech Ranger",   t"Character.arr_militech_ranger2_ranged2_omaha_ma", 3, 1400,
        "Corporate special forces, rented by the hour."),
      ArenaData.A("Arasaka Blademaster", t"Character.arasaka_agent_fmelee2rare_katana_ma_rare", 3, 1400,
        "Saburo's own school. Precise, patient, lethal."),

      ArenaData.A("El Valentino",      t"Character.arr_valentinos_elite2_ranged3_dual_ma_rare", 4, 2000,
        "Dual pistols, gold chains, Heywood heart. Jackie would approve."),

      // The ally Smasher uses the same boss record that closes every
      // run - the one Smasher record guaranteed to fight.
      ArenaData.A("Adam Smasher",      t"Character.main_boss_adam_smasher", 5, 3500,
        "He does not care about you. He does care about the money.")
    ];
  }

  // -------------------------------------------------------------- perks

  public static func Perks() -> array<ref<ArenaPerk>> {
    return [
      ArenaData.P(n"heal",   "RIPPERDOC PATCH", 150, "Instant full heal. Your health bar refills the moment you buy it - a panic button for when a wave turns ugly."),
      ArenaData.P(n"time",   "OVERCLOCK",       250, "Adds 60 seconds to the run clock. Buy it when the timer is closing in faster than the waves are dying."),
      ArenaData.P(n"revive", "SECOND WIND",     500, "Arms a one-time save: the next hit that would flatline you instead snaps you back to full health. One charge per purchase."),
      ArenaData.P(n"drop",   "AIRDROP",         400, "A random iconic weapon from the arena arsenal, dropped straight into your inventory. Could be a Malorian. Could be a knife.")
    ];
  }

  // ---------------------------------------------------------- the arena

  public static func ArenaName() -> String {
    return "THE PIT";
  }

  public static func ArenaSubtitle() -> String {
    return "Multi-level kill box. No cover lasts long.";
  }

  // Player and enemies scatter across these, so no two runs open the same.
  public static func ArenaPoints() -> array<Vector4> {
    return [
      new Vector4(-1420.0812, 170.52687,  206.62599, 1.0),
      new Vector4(-1425.9408, 139.69693,  206.6265,  1.0),
      new Vector4(-1413.5193, 115.183655, 206.6265,  1.0),
      new Vector4(-1425.9879, 132.92038,  206.6265,  1.0),
      new Vector4(-1440.5616, 145.2903,   206.6265,  1.0),
      new Vector4(-1437.1752, 162.42181,  206.62624, 1.0),
      new Vector4(-1451.7595, 154.4608,   208.6667,  1.0),
      new Vector4(-1481.392,  175.71063,  208.62599, 1.0),
      new Vector4(-1481.1428, 175.99915,  212.62599, 1.0),
      new Vector4(-1449.6836, 165.94907,  208.6376,  1.0),
      new Vector4(-1427.3235, 133.48708,  206.6265,  1.0),
      new Vector4(-1417.15,   153.89804,  206.62599, 1.0),
      new Vector4(-1425.4507, 144.2837,   206.6265,  1.0),
      new Vector4(-1418.6232, 169.51859,  206.62599, 1.0),
      new Vector4(-1426.5251, 141.4414,   210.6376,  1.0),
      new Vector4(-1429.5281, 116.89871,  206.6265,  1.0),
      new Vector4(-1434.9348, 149.1905,   206.6265,  1.0),
      new Vector4(-1450.8296, 156.30898,  208.6376,  1.0),
      new Vector4(-1465.0634, 160.5845,   208.6376,  1.0),
      new Vector4(-1475.3668, 161.65442,  208.63316, 1.0),
      new Vector4(-1490.5585, 150.32182,  212.66412, 1.0),
      new Vector4(-1484.7225, 175.41881,  212.62599, 1.0)
    ];
  }

  // Enemies per wave, and the clock - the old mod's exact defaults:
  // waves of 1, 3 and 5, then a final wave that is Adam Smasher alone
  // (size 0 = no regular enemies, the boss plan adds him).
  public static func WaveSizes() -> array<Int32> {
    return [1, 3, 5, 0];
  }

  public static func RunSeconds() -> Float {
    return 300.0;
  }
}
