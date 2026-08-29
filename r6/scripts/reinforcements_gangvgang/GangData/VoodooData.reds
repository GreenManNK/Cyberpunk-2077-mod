module Gibbon.GR.GangData


public class GRVoodooData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak merc
                let weakMercBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakBike1",
                        t"DynamicSpawnSystem.GRVoodooWeakBike2",
                        t"DynamicSpawnSystem.GRVoodooWeakBike3",
                        t"DynamicSpawnSystem.GRVoodooWeakBike4"
                    ], 1);
                return weakMercBike;
            case 2:  // 2 weak mercs        
                let weakMercBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakBike1",
                        t"DynamicSpawnSystem.GRVoodooWeakBike2",
                        t"DynamicSpawnSystem.GRVoodooWeakBike3",
                        t"DynamicSpawnSystem.GRVoodooWeakBike4"
                    ], 2);
                return weakMercBike;
            case 3: // 2 weak mercs, 1 vd bike
                let weakMercBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakBike1",
                        t"DynamicSpawnSystem.GRVoodooWeakBike2",
                        t"DynamicSpawnSystem.GRVoodooWeakBike3",
                        t"DynamicSpawnSystem.GRVoodooWeakBike4"
                    ], 2);
                
                let normalVoodooBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalBike1",
                        t"DynamicSpawnSystem.GRVoodooNormalBike2",
                        t"DynamicSpawnSystem.GRVoodooNormalBike3",
                        t"DynamicSpawnSystem.GRVoodooNormalBike4",
                        t"DynamicSpawnSystem.GRVoodooNormalBike5",
                        t"DynamicSpawnSystem.GRVoodooNormalBike6"
                    ], 2);

                return ArrayMerge(weakMercBike, normalVoodooBike);
            case 4: // 2 weak, 2 normal(merc squaad), 1 normal voodoo bike
                let normalVoodooBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalBike1",
                        t"DynamicSpawnSystem.GRVoodooNormalBike2",
                        t"DynamicSpawnSystem.GRVoodooNormalBike3",
                        t"DynamicSpawnSystem.GRVoodooNormalBike4",
                        t"DynamicSpawnSystem.GRVoodooNormalBike5",
                        t"DynamicSpawnSystem.GRVoodooNormalBike6"
                    ], 1);
                let weakMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakSquad1",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad2",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad3"
                    ], 1);
                return ArrayMerge(weakMercSquad, normalVoodooBike);        
            case 5:  // 2 weak, 2 normal(merc squaad), 1 rare  1 normal (small voodoo car)
                let weakMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakSquad1",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad2",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad3"
                    ], 1);

                let voodooCar2 = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareSquad1",
                        t"DynamicSpawnSystem.GRVoodooRareSquad2",
                        t"DynamicSpawnSystem.GRVoodooRareSquad3",
                        t"DynamicSpawnSystem.GRVoodooRareSquad4",
                        t"DynamicSpawnSystem.GRVoodooRareSquad5",
                        t"DynamicSpawnSystem.GRVoodooRareSquad6"
                    ], 1);

                return ArrayMerge(weakMercSquad, voodooCar2);   
            case 6:  // 2 weak, 2 normal(merc squaad), 1 rare  1 normal (small voodoo car), 1 n voodoo bike
                let normalVoodooBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalBike1",
                        t"DynamicSpawnSystem.GRVoodooNormalBike2",
                        t"DynamicSpawnSystem.GRVoodooNormalBike3",
                        t"DynamicSpawnSystem.GRVoodooNormalBike4",
                        t"DynamicSpawnSystem.GRVoodooNormalBike5",
                        t"DynamicSpawnSystem.GRVoodooNormalBike6"
                    ], 1);  

                let weakMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakSquad1",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad2",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad3"
                    ], 1);

                let voodooCar2 = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareSquad1",
                        t"DynamicSpawnSystem.GRVoodooRareSquad2",
                        t"DynamicSpawnSystem.GRVoodooRareSquad3",
                        t"DynamicSpawnSystem.GRVoodooRareSquad4",
                        t"DynamicSpawnSystem.GRVoodooRareSquad5",
                        t"DynamicSpawnSystem.GRVoodooRareSquad6"
                    ], 1);                              
                return ArrayMerge(ArrayMerge(weakMercSquad, voodooCar2), normalVoodooBike);   
            case 7:  // 2 weak, 2 normal(merc squaad), 1 rare  1 normal (small voodoo car), 2 n voodoo bike
                let normalVoodooBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalBike1",
                        t"DynamicSpawnSystem.GRVoodooNormalBike2",
                        t"DynamicSpawnSystem.GRVoodooNormalBike3",
                        t"DynamicSpawnSystem.GRVoodooNormalBike4",
                        t"DynamicSpawnSystem.GRVoodooNormalBike5",
                        t"DynamicSpawnSystem.GRVoodooNormalBike6"
                    ], 2);  

                let weakMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakSquad1",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad2",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad3"
                    ], 1);

                let voodooCar2 = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareSquad1",
                        t"DynamicSpawnSystem.GRVoodooRareSquad2",
                        t"DynamicSpawnSystem.GRVoodooRareSquad3",
                        t"DynamicSpawnSystem.GRVoodooRareSquad4",
                        t"DynamicSpawnSystem.GRVoodooRareSquad5",
                        t"DynamicSpawnSystem.GRVoodooRareSquad6"
                    ], 1);                              
                return ArrayMerge(ArrayMerge(weakMercSquad, voodooCar2), normalVoodooBike);   
            case 8: // 2 weak, 2 normal(merc squaad), 2 rare  2 normal (2 small voodoo car)
                let weakMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooWeakSquad1",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad2",
                        t"DynamicSpawnSystem.GRVoodooWeakSquad3"
                    ], 2);

                let voodooCar2 = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareSquad1",
                        t"DynamicSpawnSystem.GRVoodooRareSquad2",
                        t"DynamicSpawnSystem.GRVoodooRareSquad3",
                        t"DynamicSpawnSystem.GRVoodooRareSquad4",
                        t"DynamicSpawnSystem.GRVoodooRareSquad5",
                        t"DynamicSpawnSystem.GRVoodooRareSquad6"
                    ], 2);                              
                return ArrayMerge(weakMercSquad, voodooCar2);   
            case 9:  //  Medium Merc Squad(2 normal 2 rare), 1 voodoo rare runner on bike
                let runnerBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareBike1",
                        t"DynamicSpawnSystem.GRVoodooRareBike2"
                    ], 1);

                let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 1);   

                return ArrayMerge(runnerBike, mediumMercSquad);       
            case 10: // Medium Merc Squad(2 normal 2 rare), 1 voodoo elite car (elite + normal)
                let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 1);   

                let voodooEliteCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad1",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad2",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad3",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad4"
                    ], 1);

                return ArrayMerge(voodooEliteCar, mediumMercSquad);    
            case 11: //  Medium Merc Squad(2 normal 2 rare), Merc Hit Squad(1 lite, 2 rares, 1 normal), 1 voodoo normal bike
                let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 1);   

                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 1);   

                let normalVoodooBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalBike1",
                        t"DynamicSpawnSystem.GRVoodooNormalBike2",
                        t"DynamicSpawnSystem.GRVoodooNormalBike3",
                        t"DynamicSpawnSystem.GRVoodooNormalBike4",
                        t"DynamicSpawnSystem.GRVoodooNormalBike5",
                        t"DynamicSpawnSystem.GRVoodooNormalBike6"
                    ], 1);  

                return ArrayMerge(ArrayMerge(eliteMercSquad, mediumMercSquad), normalVoodooBike);     
            case 12: // Medium Merc Squad(2 normal 2 rare), Merc Hit Squad(1 lite, 2 rares, 1 normal), 1 voodoo runner rare
                 let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 1);   

                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 1);         
                let runnerBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareBike1",
                        t"DynamicSpawnSystem.GRVoodooRareBike2"
                    ], 1);     
                return ArrayMerge(ArrayMerge(eliteMercSquad, mediumMercSquad), runnerBike);               
            case 13: // Medium Merc Squad(2 normal 2 rare), Merc Hit Squad(1 lite, 2 rares, 1 normal), 1 rare  1 normal (small voodoo car)
                 let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 1);   

                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 1);      
                let voodooCar2 = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareSquad1",
                        t"DynamicSpawnSystem.GRVoodooRareSquad2",
                        t"DynamicSpawnSystem.GRVoodooRareSquad3",
                        t"DynamicSpawnSystem.GRVoodooRareSquad4",
                        t"DynamicSpawnSystem.GRVoodooRareSquad5",
                        t"DynamicSpawnSystem.GRVoodooRareSquad6"
                    ], 1); 

                return ArrayMerge(ArrayMerge(eliteMercSquad, mediumMercSquad), voodooCar2);  
            case 14: // 2 * Medium Merc Squad(2 normal 2 rare), 1 Voodoo elite car
                let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 2);   

                let voodooEliteCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad1",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad2",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad3",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad4"
                    ], 1);                    
                return ArrayMerge(voodooEliteCar, mediumMercSquad);
            case 15: // 2 * Merc Elite squads, 1 Voodoo runner rare
                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 2);   
                    let runnerBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareBike1",
                        t"DynamicSpawnSystem.GRVoodooRareBike2"
                    ], 1); 
                return ArrayMerge(runnerBike, eliteMercSquad);
            case 16: // Voodoo Elite  Squad (2 elites, 2 rares), Medium Merc Squad(2 normal 2 rare)
                let eliteVoodooSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad10",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad11"
                    ], 1); 

                let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 1);  

                return ArrayMerge(eliteVoodooSquad, mediumMercSquad);
            case 17: // Voodoo Elite  Squad (2 elites, 2 rares), 2Medium Merc Squad(2 normal 2 rare)
                let eliteVoodooSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad10",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad11"
                    ], 1); 

                let mediumMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooNormalSquad1",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad2",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad3",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad4",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad5",
                        t"DynamicSpawnSystem.GRVoodooNormalSquad6"
                    ], 2);  

                return ArrayMerge(eliteVoodooSquad, mediumMercSquad);
            case 18: // Voodoo Elite  Squad (2 elites, 2 rares), 1 Merc Elite Squad
                let eliteVoodooSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad10",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad11"
                    ], 1); 

                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 1);                      
                return ArrayMerge(eliteMercSquad, eliteVoodooSquad);  
            case 19: // Voodoo Elite  Squad (2 elites, 2 rares), 1 Merc Elite Squad, 1 Runner bike
                let eliteVoodooSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad10",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad11"
                    ], 1); 

                let runnerBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooRareBike1",
                        t"DynamicSpawnSystem.GRVoodooRareBike2"
                    ], 1);   

                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 1);                      
                return ArrayMerge(ArrayMerge(eliteMercSquad, eliteVoodooSquad), runnerBike);  
            case 20: // Voodoo Elite  Squad (2 elites, 2 rares), 2 Merc Elite Squad
                let eliteVoodooSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad10",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad11"
                    ], 1); 

                let eliteMercSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRVoodooEliteSquad5",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad6",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad7",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad8",
                        t"DynamicSpawnSystem.GRVoodooEliteSquad9"
                    ], 2);                      
                return ArrayMerge(eliteMercSquad, eliteVoodooSquad);  
            default: 
                return [];
        }
    }
}