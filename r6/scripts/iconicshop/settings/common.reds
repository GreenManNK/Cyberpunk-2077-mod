module iconicshop.Prices.Common

import iconicshop.Helpers.ProductsList.*

public class ISSetting {
// Description text
  @runtimeProperty("ModSettings.displayName", "For the shop price changes to take effect, you need to confirm the changes in the current settings below and load your save (F9). After that, the shop prices will be updated.")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Confirm the changes below and load your save (F9) to update shop prices.")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.dependency", "description")
  let description: Bool = false;
  
// Iconic Ranged Weapons
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "                                                            # ICONIC RANGE WEAPONS #")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.dependency", "rangedText") 
  let rangedText: Bool = false;

 // Iconic Pistols
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "3")
  let showIconicPistols: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#87363")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let HerMajesty: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87366")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Cheetah: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40549")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let DyingNight: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93513")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let LexingtonXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87367")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Rook: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40553")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Kongou: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40556")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let PlanB: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40551")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Pride: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#79840")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Seraph: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40559")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let DeathAndTaxes: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40557")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let LaChingonaDorada: Int32 = 10000;
  
  @runtimeProperty("ModSettings.displayName", "LocKey#87574")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Riskit: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40567")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let MalorianArms3516: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40565")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Genjiroh: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40563")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Skippy: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87358")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Crimestopper: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93512")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let KappaXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87361")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Ogou: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40540")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Apparition: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40546")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Chaos: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87362")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Ambition: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94458")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Catahoula: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40561")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Lizzie: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#84847")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Pariah: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#91350")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Pistols")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPistols") 
  let Scorch: Int32 = 10000;

 // Iconic Revolvers
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  let showIconicRevolvers: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40569")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let DoomDoom: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#84843")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Mancinella: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40473")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Amnesty: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40475")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Archangel: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40477")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Crash: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87352")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Rosco: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87573")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let OlReliable: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93440")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Taigan: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#84850")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let BaldEagle: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40609")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let ComradesHammer: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93439")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let Laika: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#88461")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Revolvers")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicRevolvers") 
  let GrisGris: Int32 = 10000;

 // Iconic Shotguns
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  let showIconicShotguns: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40620")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let TheHeadsman: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#79842")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let BloodyMaria: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40579")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Mox: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#84177")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Guts: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94460")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Amstaff: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87350")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Dezerter: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40605")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Sovereign: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93418")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Alabai: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93515")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let PozharXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40607")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let BaXingChong: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#84934")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Shotguns")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicShotguns") 
  let Order: Int32 = 10000;

 // Iconic Submachine Guns
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  let IconicSMG: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40581")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let Fenrir: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40582")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let ProblemSolver: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93517")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let GuillotineXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40611")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let Buzzsaw: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#85504")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let MidnightArmsErebus: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40585")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let PrototypeShingenMarkV: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40613")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let Yinglong: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87356")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let Pizdets: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94457")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let Chesapeake: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#90842")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Submachine Guns")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "IconicSMG") 
  let Raiju: Int32 = 10000;

 // Iconic Assault Rifles
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  let showIconicAssaultRifles: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40577")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let Prejudice: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#84908")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let Carmen: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93516")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let UmbraXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93514")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let KyubiXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#88068")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let Hawk: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94461")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let Chinook: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40627")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let MoronLabe: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94456")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let PitBull: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40625")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let Psalm116: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40632")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let DividedWeStand: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#81449")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Assault Rifles")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicAssaultRifles") 
  let MilitechHercules3AX: Int32 = 10000;

 // Iconic Machine Guns
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Machine Guns")
  @runtimeProperty("ModSettings.category.order", "7")
  let showIconicLMG: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#87641")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Machine Guns")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicLMG") 
  let WildDog: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#95295")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Machine Guns")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicLMG") 
  let MA70HBXMOD2: Int32 = 10000;

 // Iconic Precision Rifles
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Precision Rifles")
  @runtimeProperty("ModSettings.category.order", "8")
  let showIconicPrecisionRifles: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#82706")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Precision Rifles")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPrecisionRifles") 
  let Hypercritical: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40571")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Precision Rifles")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPrecisionRifles") 
  let WidowMaker: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#95294")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Precision Rifles")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicPrecisionRifles") 
  let AchillesXMOD2: Int32 = 10000;

 // Iconic Sniper Rifles
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  let showIconicSniperRifles: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40575")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let OFive: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40573")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let Overwatch: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87364")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let Sparky: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93441")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let Borzaya: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#81410")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let NokotaOsprey: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94217")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let Yasha: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40629")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let Breakthrough: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94459")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let Foxhound: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#81440")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Sniper Rifles")
  @runtimeProperty("ModSettings.category.order", "9")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSniperRifles") 
  let TsunamiRasetsu: Int32 = 10000;

// Iconic Melee Weapons
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "                                                            # ICONIC MELEE WEAPONS #")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.dependency", "meleeText") 
  let meleeText: Bool = false;

 // Iconic 2H Clubs and Hammers
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 2H Blunts")
  @runtimeProperty("ModSettings.category.order", "11")
  let showIconic2HBlunts: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40587")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 2H Blunts")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic2HBlunts") 
  let GoldPlatedBaseballBat: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87575")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 2H Blunts")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic2HBlunts") 
  let BabyBoomer: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93519")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 2H Blunts")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic2HBlunts") 
  let BaseballBatXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40465")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 2H Blunts")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic2HBlunts") 
  let CaretakersSpade: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#54032")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 2H Blunts")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic2HBlunts") 
  let SasquatchsHammer: Int32 = 10000;

 // Iconic 1H Clubs
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  let showIconic1HBlunts: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40470")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic1HBlunts") 
  let Cottonmouth: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40309")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic1HBlunts") 
  let SirJohnPhallustiff: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#95292")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic1HBlunts") 
  let BFC9000: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40589")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic1HBlunts") 
  let TinkerBell: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87365")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic1HBlunts") 
  let MurphysLaw: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#87708")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic 1H Blunt")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconic1HBlunts") 
  let Crowbar: Int32 = 10000;

 // Iconic Katana
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  let showIconicKatana: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#79844")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let Byakko: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40591")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let CocktailStick: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40598")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let JinchuMaru: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40599")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let Satori: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40600")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let Scalpel: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40597")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let Tsumetogi: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#88070")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let Errata: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#76935")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Katana")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKatana") 
  let BlackUnicorn: Int32 = 10000;

 // Iconic Knives
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  let showIconicKnives: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#40197")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKnives") 
  let ButchersCleaver: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#81571")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKnives") 
  let BlueFang: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#81565")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKnives") 
  let Headhunter: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#40601")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKnives") 
  let Stinger: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#81427")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKnives") 
  let Fang: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#86561")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Knives")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicKnives") 
  let Nehan: Int32 = 10000;

 // Other melee weapons
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Other Melee Weapons")
  @runtimeProperty("ModSettings.category.order", "19")
  let showIconicOtherMelee: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#86806")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Other Melee Weapons")
  @runtimeProperty("ModSettings.category.order", "19")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicOtherMelee") 
  let Agaou: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#95296")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Other Melee Weapons")
  @runtimeProperty("ModSettings.category.order", "19")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicOtherMelee") 
  let ClawXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93518")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Other Melee Weapons")
  @runtimeProperty("ModSettings.category.order", "19")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicOtherMelee") 
  let CutOMaticXMOD2: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#93442")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Other Melee Weapons")
  @runtimeProperty("ModSettings.category.order", "19")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicOtherMelee") 
  let Volkodav: Int32 = 10000;

  @runtimeProperty("ModSettings.displayName", "LocKey#91106")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Other Melee Weapons")
  @runtimeProperty("ModSettings.category.order", "19")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicOtherMelee") 
  let Gwynbleidd: Int32 = 10000;

// Iconic Cyberware
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "                                                            # ICONIC CYBERWARE #")
  @runtimeProperty("ModSettings.category.order", "20")
  @runtimeProperty("ModSettings.dependency", "cyberwareText") 
  let cyberwareText: Bool = false;

 // Circulatory System
  // @runtimeProperty("ModSettings.displayName", "      show settings")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Circulatory System")
  // @runtimeProperty("ModSettings.category.order", "21")
  let showIconicCirculatorySystem: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94439")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Circulatory System")
  // @runtimeProperty("ModSettings.category.order", "21")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicCirculatorySystem") 
  let ElectromagRecycler: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94435")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Circulatory System")
  // @runtimeProperty("ModSettings.category.order", "21")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicCirculatorySystem") 
  let IsometricStabilizer: Int32 = 20000;

 // Face Implant
  // @runtimeProperty("ModSettings.displayName", "      show settings")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Face Implant")
  // @runtimeProperty("ModSettings.category.order", "22")
  let showIconicFace: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#91483")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Face Implant")
  // @runtimeProperty("ModSettings.category.order", "22")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicFace") 
  let BehavioralImprintSyncedFaceplate: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94426")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Face Implant")
  // @runtimeProperty("ModSettings.category.order", "22")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicFace") 
  let KiroshiCockatriceOptics: Int32 = 20000;

 // Frontal Cortex
  // @runtimeProperty("ModSettings.displayName", "      show settings")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Frontal Cortex")
  // @runtimeProperty("ModSettings.category.order", "22")
  let showIconicFrontalCortex: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94429")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Frontal Cortex")
  // @runtimeProperty("ModSettings.category.order", "23")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicFrontalCortex") 
  let Axolotl: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94428")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Frontal Cortex")
  // @runtimeProperty("ModSettings.category.order", "23")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicFrontalCortex") 
  let COX2CybersomaticOptimizer: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94427")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Frontal Cortex")
  // @runtimeProperty("ModSettings.category.order", "23")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicFrontalCortex") 
  let RAMReallocator: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#85359")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Frontal Cortex")
  // @runtimeProperty("ModSettings.category.order", "23")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicFrontalCortex") 
  let QuantumTuner: Int32 = 20000;

 // Hands Implant
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Hands Implant")
  @runtimeProperty("ModSettings.category.order", "24")
  let showIconicHandsImplant: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#94434")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Hands Implant")
  @runtimeProperty("ModSettings.category.order", "24")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicHandsImplant") 
  let ImmovableForce: Int32 = 20000;

 // Integumentary System
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Integumentary System")
  @runtimeProperty("ModSettings.category.order", "25")
  let showIconicIntegumentarySystem: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#94437")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Integumentary System")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicIntegumentarySystem") 
  let Chitin: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94430")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Integumentary System")
  // @runtimeProperty("ModSettings.category.order", "25")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicIntegumentarySystem") 
  let PeripheralInverse: Int32 = 20000;

 // Legs Implant
  // @runtimeProperty("ModSettings.displayName", "      show settings")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Legs Implant")
  // @runtimeProperty("ModSettings.category.order", "26")
  let showIconicLegsImplant: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94438")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Legs Implant")
  // @runtimeProperty("ModSettings.category.order", "26")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicLegsImplant") 
  let LeeroyLigamentSystem: Int32 = 20000;

 // Nervous System
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Nervous System")
  @runtimeProperty("ModSettings.category.order", "27")
  let showIconicNervousSystem: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94424")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Nervous System")
  // @runtimeProperty("ModSettings.category.order", "27")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicNervousSystem") 
  let AdrenoTrigger: Int32 = 20000;

  @runtimeProperty("ModSettings.displayName", "LocKey#94432")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Nervous System")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicNervousSystem") 
  let DeepFieldVisualInterface: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94431")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Nervous System")
  // @runtimeProperty("ModSettings.category.order", "27")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicNervousSystem") 
  let Revulsor: Int32 = 20000;

 // Operating System
  // @runtimeProperty("ModSettings.displayName", "      show settings")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  let showIconicOperatingSystem: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#94425")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicOperatingSystem") 
  let ChromeCompressor: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#91178")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicOperatingSystem") 
  let MilitechCanto: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#92228")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicOperatingSystem") 
  let NetWatchNetdriver: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#92533")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicOperatingSystem") 
  let MilitechBerserk: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#90784")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicOperatingSystem") 
  let MilitechApogee: Int32 = 20000;

  // @runtimeProperty("ModSettings.displayName", "LocKey#92038")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Operating System")
  // @runtimeProperty("ModSettings.category.order", "28")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicOperatingSystem") 
  let MilitechFalcon: Int32 = 20000;

 // Skeleton
  @runtimeProperty("ModSettings.displayName", "      show settings")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Skeleton")
  @runtimeProperty("ModSettings.category.order", "29")
  let showIconicSkeleton: Bool = false;

  @runtimeProperty("ModSettings.displayName", "LocKey#94436")
  @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  @runtimeProperty("ModSettings.category", "Iconic Skeleton")
  @runtimeProperty("ModSettings.category.order", "29")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  @runtimeProperty("ModSettings.dependency", "showIconicSkeleton") 
  let RaraAvis: Int32 = 20000;

 // Arms
  // @runtimeProperty("ModSettings.displayName", "      show settings")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Arms")
  // @runtimeProperty("ModSettings.category.order", "30")
  let showIconicArms: Bool = false;

  // @runtimeProperty("ModSettings.displayName", "LocKey#88189")
  // @runtimeProperty("ModSettings.mod", "Iconic Shops: Prices - Common")
  // @runtimeProperty("ModSettings.category", "Iconic Arms")
  // @runtimeProperty("ModSettings.category.order", "30")
  // @runtimeProperty("ModSettings.step", "500")
  // @runtimeProperty("ModSettings.min", "1000")
  // @runtimeProperty("ModSettings.max", "300000")
  // @runtimeProperty("ModSettings.dependency", "showIconicArms") 
  let MaxTacMantisBlades: Int32 = 20000;

// End
}

public static func GetCommonCustomPrice(itemID: String) -> Int32 {
  let settings: ref<ISSetting> = new ISSetting();
  let defaultPrice: Int32 = 9999;
  return GetSettingPrices(itemID, defaultPrice, settings);
}