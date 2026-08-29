module Gibbon.GR.GangData


public class GRMaelstormData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromWeakBike1",
                        t"DynamicSpawnSystem.GRMaelstromWeakBike2"
                    ], 1);
                return weakBike;
            case 2:  // 1 weak, 1 normal     
                let weakNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad1",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad2",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad3",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad4",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad5",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad6",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad7",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad8"
                    ], 1);

                return weakNormalCar;
            case 3: // 2 weak, 1 normal
                let weakNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad1",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad2",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad3",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad4",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad5",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad6",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad7",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad8"
                    ], 1);
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromWeakBike1",
                        t"DynamicSpawnSystem.GRMaelstromWeakBike2"
                    ], 1);   

                return ArrayMerge(weakNormalCar, weakBike);
            case 4: // 2 weak, 2 normal
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad1",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad2",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad3",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad4",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad5",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad6",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad7",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad8"
                    ], 2);          
            case 5:  // 3 normal, 1 rare
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1);   
            case 6:  // 1 weak, 3 normal, 1 rare
                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 

                let weakBike = GetRandomFrom(
                [
                    t"DynamicSpawnSystem.GRMaelstromWeakBike1",
                    t"DynamicSpawnSystem.GRMaelstromWeakBike2"
                ], 1);                 
                return ArrayMerge(squad, weakBike);
            case 7:  // 3 weak, 3 normal, 1 rare
                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 

                let weakBike = GetRandomFrom(
                [
                    t"DynamicSpawnSystem.GRMaelstromWeakBike1",
                    t"DynamicSpawnSystem.GRMaelstromWeakBike2"
                ], 3);                 
                return ArrayMerge(squad, weakBike);
            case 8: // 2 weak, 4 normals, 1 rare       
                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 

                let weakBike = GetRandomFrom(
                [
                    t"DynamicSpawnSystem.GRMaelstromWeakBike1",
                    t"DynamicSpawnSystem.GRMaelstromWeakBike2"
                ], 3);   
                let weakNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad1",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad2",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad3",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad4",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad5",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad6",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad7",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad8"
                    ], 1);
                return ArrayMerge(ArrayMerge(squad, weakBike), weakNormalCar);
            case 9:  // 6 normals, 2 rare    
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 2);    
            case 10: // 2 elite
                return [t"DynamicSpawnSystem.GRMaelstromRareSquad1", t"DynamicSpawnSystem.GRMaelstromRareSquad5"];
            case 11: // 5 normals 3 rares, 1 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 1); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1);  

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 

                return ArrayMerge(ArrayMerge(squad, elite), rrnnSquad);      
            case 12: // 1 weak, 5 normals, 3 rares, 1 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 1); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1);  

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 

                let weakNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad1",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad2",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad3",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad4",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad5",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad6",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad7",
                        t"DynamicSpawnSystem.GRMaelstromNormalSquad8"
                    ], 1);

                return ArrayMerge(weakNormalCar, ArrayMerge(ArrayMerge(squad, elite), rrnnSquad));                  
            case 13: // 7 normals, 5 rares, 1 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 2); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1);  

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 

                return ArrayMerge(ArrayMerge(squad, elite), rrnnSquad);      
            case 14: // 6 normals, 6 rares, 1 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 3); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1);  

                return ArrayMerge(rrnnSquad, elite);     
            case 15: // 4 normals, 4 rares, 2 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 2); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 2);  

                return ArrayMerge(rrnnSquad, elite);   
            case 16: // 7 normals 5 rares, 2 elite
                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 1); 
        
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 2); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 2);  

                return ArrayMerge(ArrayMerge(rrnnSquad, elite), squad);  
            case 17: // 6 normals, 6 rares, 2 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 3); 
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 2);  

                return ArrayMerge(rrnnSquad, elite);   
            case 18: // 2 normals, 6 rares, 2 elite
                let rrnnSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad5",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad6",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad7",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad8",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad9"
                    ], 1); 

                let rares = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad10",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad11"
                    ], 1); 

                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 2);  
            
                return ArrayMerge(ArrayMerge(rrnnSquad, elite), rares);
            case 19: // 8 rares, 2 elite
                let rares = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad10",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad11"
                    ], 2); 

                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 2);  
            
                return ArrayMerge(rares, elite);
            case 20: // 8 rares, 3 elite, 1 elite bike
                let rares = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad10",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad11"
                    ], 2);

                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMaelstromRareSquad1",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad2",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad3",
                        t"DynamicSpawnSystem.GRMaelstromRareSquad4"
                    ], 3);

                let eliteBike = [t"DynamicSpawnSystem.GRMaelstromEliteBike1"];

                return ArrayMerge(ArrayMerge(rares, elite), eliteBike);
            default: 
                return [];
        }
    }
}