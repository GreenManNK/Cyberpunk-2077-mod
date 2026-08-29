module Gibbon.GR.GangData


public class GRScavData extends GRGangData {
	
    public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 2 weak
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 1);
                return weakCar;
            case 2:  // 4 weak             
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 2);
                return weakCar;
            case 3: // 5 weak
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 2);

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakBike1",
                        t"DynamicSpawnSystem.GRScavWeakBike2"
                    ], 1);
                return ArrayMerge(weakCar, weakBike);
            case 4: // 5 weak, 1 normal
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 2);

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakBike1",
                        t"DynamicSpawnSystem.GRScavWeakBike2"
                    ], 1);

                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                return ArrayMerge(ArrayMerge(weakCar, weakBike), normalBike);
            case 5:  // 5 weak, 2 normal
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 1);
                
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakBike1",
                        t"DynamicSpawnSystem.GRScavWeakBike2"
                    ], 1);

                let normalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalSquad1",
                        t"DynamicSpawnSystem.GRScavNormalSquad2",
                        t"DynamicSpawnSystem.GRScavNormalSquad3",
                        t"DynamicSpawnSystem.GRScavNormalSquad4",
                        t"DynamicSpawnSystem.GRScavNormalSquad5",
                        t"DynamicSpawnSystem.GRScavNormalSquad6"
                    ], 2);
            
                return ArrayMerge(ArrayMerge(normalCar, weakBike), weakSquad);
            case 6:  // 6 weak, 2 normal
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 1);
                
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 1);

                let normalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalSquad1",
                        t"DynamicSpawnSystem.GRScavNormalSquad2",
                        t"DynamicSpawnSystem.GRScavNormalSquad3",
                        t"DynamicSpawnSystem.GRScavNormalSquad4",
                        t"DynamicSpawnSystem.GRScavNormalSquad5",
                        t"DynamicSpawnSystem.GRScavNormalSquad6"
                    ], 2);
            
                return ArrayMerge(ArrayMerge(normalCar, weakCar), weakSquad);
            case 7:  // 6 weak, 3 normal
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 1);
                
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 1);

                let normalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalSquad1",
                        t"DynamicSpawnSystem.GRScavNormalSquad2",
                        t"DynamicSpawnSystem.GRScavNormalSquad3",
                        t"DynamicSpawnSystem.GRScavNormalSquad4",
                        t"DynamicSpawnSystem.GRScavNormalSquad5",
                        t"DynamicSpawnSystem.GRScavNormalSquad6"
                    ], 2);
            
                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                return ArrayMerge(ArrayMerge(ArrayMerge(normalCar, weakCar), weakSquad), normalBike);
            case 8: // 7 weap, 3 normal          
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 1);
                
                let weakCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad1",
                        t"DynamicSpawnSystem.GRScavWeakSquad2",
                        t"DynamicSpawnSystem.GRScavWeakSquad3"
                    ], 1);

                let normalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalSquad1",
                        t"DynamicSpawnSystem.GRScavNormalSquad2",
                        t"DynamicSpawnSystem.GRScavNormalSquad3",
                        t"DynamicSpawnSystem.GRScavNormalSquad4",
                        t"DynamicSpawnSystem.GRScavNormalSquad5",
                        t"DynamicSpawnSystem.GRScavNormalSquad6"
                    ], 2);
            
                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakBike1",
                        t"DynamicSpawnSystem.GRScavWeakBike2"
                    ], 1);

                return ArrayMerge(ArrayMerge(ArrayMerge(ArrayMerge(normalCar, weakCar), weakSquad), normalBike), weakBike);
            case 9:  //  8 weak, 4 normal
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let normalSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalSquad7",
                        t"DynamicSpawnSystem.GRScavNormalSquad8",
                        t"DynamicSpawnSystem.GRScavNormalSquad9",
                        t"DynamicSpawnSystem.GRScavNormalSquad10"
                    ], 1);
                return ArrayMerge(weakSquad, normalSquad);      
            case 10: // 8 weak, 3 normal, 1 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 1);

                return ArrayMerge(weakSquad, rareSquad);  
            case 11: // 8 weak, 4 noromal, 1 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 1);

                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                return ArrayMerge(normalBike, ArrayMerge(weakSquad, rareSquad));      
            case 12: // 8 weak, 6 normal, 1 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 2);

                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                return ArrayMerge(normalBike, ArrayMerge(weakSquad, rareSquad));                
            case 13: // 8 weak, 7 normal, 2 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 2);

                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                return ArrayMerge(normalBike, ArrayMerge(weakSquad, rareSquad));     
            case 14: // 8 weak, 8 normal, 2 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 2);

                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 2);

                return ArrayMerge(normalBike, ArrayMerge(weakSquad, rareSquad));     
            case 15: // 12 weak, 9 normal, 3 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 3);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 3);

                return ArrayMerge(weakSquad, rareSquad);     
            case 16: // 8 weak,  10 normal, 3 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 3);

                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 1);

                return ArrayMerge(normalBike, ArrayMerge(weakSquad, rareSquad));     
            case 17: // 4 weak, 12 normal, 4 rare
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavWeakSquad4",
                        t"DynamicSpawnSystem.GRScavWeakSquad5",
                        t"DynamicSpawnSystem.GRScavWeakSquad6"
                    ], 1);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 4);

                return ArrayMerge(weakSquad, rareSquad);     
            case 18: // 14 normal, 4 rare
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 4);
                let normalBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalBike1",
                        t"DynamicSpawnSystem.GRScavNormalBike2",
                        t"DynamicSpawnSystem.GRScavNormalBike3",
                        t"DynamicSpawnSystem.GRScavNormalBike4",
                        t"DynamicSpawnSystem.GRScavNormalBike5",
                        t"DynamicSpawnSystem.GRScavNormalBike6",
                        t"DynamicSpawnSystem.GRScavNormalBike7",
                        t"DynamicSpawnSystem.GRScavNormalBike8",
                        t"DynamicSpawnSystem.GRScavNormalBike9",
                        t"DynamicSpawnSystem.GRScavNormalBike10",
                        t"DynamicSpawnSystem.GRScavNormalBike11"
                    ], 2);
                return ArrayMerge(normalBike, rareSquad);   
            case 19: // 16 normal, 4 rare
                let normalSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavNormalSquad7",
                        t"DynamicSpawnSystem.GRScavNormalSquad8",
                        t"DynamicSpawnSystem.GRScavNormalSquad9",
                        t"DynamicSpawnSystem.GRScavNormalSquad10"
                    ], 1);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 4);
                return ArrayMerge(rareSquad, normalSquad);
            case 20: // 15 normals, 5 rare
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRScavRareSquad1",
                        t"DynamicSpawnSystem.GRScavRareSquad2",
                        t"DynamicSpawnSystem.GRScavRareSquad3",
                        t"DynamicSpawnSystem.GRScavRareSquad4"
                    ], 5);
            default: 
                return [];
        }
    }
}