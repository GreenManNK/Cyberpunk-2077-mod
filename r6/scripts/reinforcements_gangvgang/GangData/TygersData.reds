module Gibbon.GR.GangData


public class GRTygerData extends GRGangData {public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak
                let weakBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerWeakBike2",
                     t"DynamicSpawnSystem.GRTygerWeakBike3"
                    ], 1);    
                return weakBike;
            case 2:  // 1 weak, 1 normal
                let weakBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerWeakBike1",
                     t"DynamicSpawnSystem.GRTygerWeakBike2",
                     t"DynamicSpawnSystem.GRTygerWeakBike3"
                    ], 1);    

                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 1);                       
                return ArrayMerge(weakBike, normalBike);
            case 3: // 2 weak, 1 normal
                let weakBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerWeakBike1",
                     t"DynamicSpawnSystem.GRTygerWeakBike2",
                     t"DynamicSpawnSystem.GRTygerWeakBike3"
                    ], 1);  

                let weakNormalCar = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 1);  

                return ArrayMerge(weakNormalCar, weakBike);
            case 4: // 2 weak, 2 normal
                return GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 2);            
            case 5:  // 2 weak, 2 normal, 1 rare
                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 1);  

                let weakNormalCar = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 2);  

                return ArrayMerge(weakNormalCar, rareBike);
            case 6:  // 3 weak, 2 normal, 1 rare
                let weakBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerWeakBike1",
                     t"DynamicSpawnSystem.GRTygerWeakBike2",
                     t"DynamicSpawnSystem.GRTygerWeakBike3"
                    ], 1);  

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 1);  

                let weakNormalCar = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 2);  

                return ArrayMerge(ArrayMerge(weakNormalCar, rareBike), weakBike);
            case 7:  // 3 weak, 3 normal, 1 rare
                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 1);    

                let weakBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerWeakBike1",
                     t"DynamicSpawnSystem.GRTygerWeakBike2",
                     t"DynamicSpawnSystem.GRTygerWeakBike3"
                    ], 1);  

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 1);  

                let weakNormalCar = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 2);  

                return ArrayMerge(ArrayMerge(ArrayMerge(weakNormalCar, rareBike), weakBike), normalBike);
            case 8: // 2 weak, 3 normals, 2 rare        
                let rareNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad1",
                        t"DynamicSpawnSystem.GRTygerRareSquad2",
                        t"DynamicSpawnSystem.GRTygerRareSquad3",
                        t"DynamicSpawnSystem.GRTygerRareSquad4",
                        t"DynamicSpawnSystem.GRTygerRareSquad5",
                        t"DynamicSpawnSystem.GRTygerRareSquad6",
                        t"DynamicSpawnSystem.GRTygerRareSquad7",
                        t"DynamicSpawnSystem.GRTygerRareSquad8"
                    ], 1);

                let weakNormalCar = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 2);   

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 1); 

                return ArrayMerge(ArrayMerge(weakNormalCar, rareBike), rareNormalCar);
            case 9:  //  2 weak, 4 normals, 2 rare    
                let rareNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad1",
                        t"DynamicSpawnSystem.GRTygerRareSquad2",
                        t"DynamicSpawnSystem.GRTygerRareSquad3",
                        t"DynamicSpawnSystem.GRTygerRareSquad4",
                        t"DynamicSpawnSystem.GRTygerRareSquad5",
                        t"DynamicSpawnSystem.GRTygerRareSquad6",
                        t"DynamicSpawnSystem.GRTygerRareSquad7",
                        t"DynamicSpawnSystem.GRTygerRareSquad8"
                    ], 2);

                let weakNormalCar = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalSquad1",
                     t"DynamicSpawnSystem.GRTygerNormalSquad2",
                     t"DynamicSpawnSystem.GRTygerNormalSquad3",
                     t"DynamicSpawnSystem.GRTygerNormalSquad4",
                     t"DynamicSpawnSystem.GRTygerNormalSquad5"
                    ], 2);  

                return ArrayMerge(weakNormalCar, rareNormalCar);   
            case 10: // 1 weak, 3 normals, 2 rares, 1 elite
                let rareNormalSquad = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareSquad9",
                     t"DynamicSpawnSystem.GRTygerRareSquad10",
                     t"DynamicSpawnSystem.GRTygerRareSquad11",
                     t"DynamicSpawnSystem.GRTygerRareSquad12",
                     t"DynamicSpawnSystem.GRTygerRareSquad13",
                     t"DynamicSpawnSystem.GRTygerRareSquad14"
                    ], 1);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 1
                );

                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 1);  

                return ArrayMerge(ArrayMerge(rareNormalSquad, eliteRareCar), normalBike); 
            case 11: // 5 normals 3 rares, 1 elite
            
                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 1
                );

                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 3);  

                let rareNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad1",
                        t"DynamicSpawnSystem.GRTygerRareSquad2",
                        t"DynamicSpawnSystem.GRTygerRareSquad3",
                        t"DynamicSpawnSystem.GRTygerRareSquad4",
                        t"DynamicSpawnSystem.GRTygerRareSquad5",
                        t"DynamicSpawnSystem.GRTygerRareSquad6",
                        t"DynamicSpawnSystem.GRTygerRareSquad7",
                        t"DynamicSpawnSystem.GRTygerRareSquad8"
                    ], 2);
                return ArrayMerge(ArrayMerge(rareNormalCar, eliteRareCar), normalBike);       
            case 12: // 3 weak, 6 normals, 4 rares, 1 elite
                let rareNormalSquad = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareSquad9",
                     t"DynamicSpawnSystem.GRTygerRareSquad10",
                     t"DynamicSpawnSystem.GRTygerRareSquad11",
                     t"DynamicSpawnSystem.GRTygerRareSquad12",
                     t"DynamicSpawnSystem.GRTygerRareSquad13",
                     t"DynamicSpawnSystem.GRTygerRareSquad14"
                    ], 3);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 1
                );
                return ArrayMerge(eliteRareCar, rareNormalSquad);               
            case 13: // 3 weak, 7 normals, 4 rares, 1 elite
                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 1);  

                let rareNormalSquad = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareSquad9",
                     t"DynamicSpawnSystem.GRTygerRareSquad10",
                     t"DynamicSpawnSystem.GRTygerRareSquad11",
                     t"DynamicSpawnSystem.GRTygerRareSquad12",
                     t"DynamicSpawnSystem.GRTygerRareSquad13",
                     t"DynamicSpawnSystem.GRTygerRareSquad14"
                    ], 3);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 1
                );
                return ArrayMerge(ArrayMerge(eliteRareCar, rareNormalSquad), normalBike);   
            case 14: // 3 weaks ,8 normals, 4 rares, 1 elite
                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 2);  

                let rareNormalSquad = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareSquad9",
                     t"DynamicSpawnSystem.GRTygerRareSquad10",
                     t"DynamicSpawnSystem.GRTygerRareSquad11",
                     t"DynamicSpawnSystem.GRTygerRareSquad12",
                     t"DynamicSpawnSystem.GRTygerRareSquad13",
                     t"DynamicSpawnSystem.GRTygerRareSquad14"
                    ], 3);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 1);
                return ArrayMerge(ArrayMerge(eliteRareCar, rareNormalSquad), normalBike);   
            case 15: // 6 normals, 4 rares, 2 elite
                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 2);  

                let rareNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad1",
                        t"DynamicSpawnSystem.GRTygerRareSquad2",
                        t"DynamicSpawnSystem.GRTygerRareSquad3",
                        t"DynamicSpawnSystem.GRTygerRareSquad4",
                        t"DynamicSpawnSystem.GRTygerRareSquad5",
                        t"DynamicSpawnSystem.GRTygerRareSquad6",
                        t"DynamicSpawnSystem.GRTygerRareSquad7",
                        t"DynamicSpawnSystem.GRTygerRareSquad8"
                    ], 2);

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 2);
                return ArrayMerge(ArrayMerge(eliteRareCar, rareNormalCar), normalBike);   
            case 16: // 5 normals 5 rares, 2 elite
                let normalBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerNormalBike1",
                     t"DynamicSpawnSystem.GRTygerNormalBike2",
                     t"DynamicSpawnSystem.GRTygerNormalBike3",
                     t"DynamicSpawnSystem.GRTygerNormalBike4"
                    ], 2);  

                let rareNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad1",
                        t"DynamicSpawnSystem.GRTygerRareSquad2",
                        t"DynamicSpawnSystem.GRTygerRareSquad3",
                        t"DynamicSpawnSystem.GRTygerRareSquad4",
                        t"DynamicSpawnSystem.GRTygerRareSquad5",
                        t"DynamicSpawnSystem.GRTygerRareSquad6",
                        t"DynamicSpawnSystem.GRTygerRareSquad7",
                        t"DynamicSpawnSystem.GRTygerRareSquad8"
                    ], 2);

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 1);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 2);
                return ArrayMerge(ArrayMerge(ArrayMerge(eliteRareCar, rareNormalCar), normalBike), rareBike);   
            case 17: // 2 normals, 6 rares, 2 elite

                let rareNormalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad1",
                        t"DynamicSpawnSystem.GRTygerRareSquad2",
                        t"DynamicSpawnSystem.GRTygerRareSquad3",
                        t"DynamicSpawnSystem.GRTygerRareSquad4",
                        t"DynamicSpawnSystem.GRTygerRareSquad5",
                        t"DynamicSpawnSystem.GRTygerRareSquad6",
                        t"DynamicSpawnSystem.GRTygerRareSquad7",
                        t"DynamicSpawnSystem.GRTygerRareSquad8"
                    ], 2);

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 2);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 2);
                return ArrayMerge(ArrayMerge(eliteRareCar, rareNormalCar), rareBike); 
            case 18: // 1 normal, 7 rares, 2 elite
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad15",
                        t"DynamicSpawnSystem.GRTygerRareSquad16",
                        t"DynamicSpawnSystem.GRTygerRareSquad17"
                    ], 1);

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 2);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 2);

                return ArrayMerge(ArrayMerge(eliteRareCar, rareSquad), rareBike); 
            case 19: // 1 normal, 8 rares, 2 elite
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad15",
                        t"DynamicSpawnSystem.GRTygerRareSquad16",
                        t"DynamicSpawnSystem.GRTygerRareSquad17"
                    ], 1);

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 3);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 2);

                return ArrayMerge(ArrayMerge(eliteRareCar, rareSquad), rareBike); 
            case 20: // 2 normals, 10 rares, 3 elite
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerRareSquad15",
                        t"DynamicSpawnSystem.GRTygerRareSquad16",
                        t"DynamicSpawnSystem.GRTygerRareSquad17"
                    ], 2);

                let rareBike = GetRandomFrom(
                    [
                     t"DynamicSpawnSystem.GRTygerRareBike1",
                     t"DynamicSpawnSystem.GRTygerRareBike2",
                     t"DynamicSpawnSystem.GRTygerRareBike3",
                     t"DynamicSpawnSystem.GRTygerRareBike4",
                     t"DynamicSpawnSystem.GRTygerRareBike5",
                     t"DynamicSpawnSystem.GRTygerRareBike6"
                    ], 1);  

                let eliteRareCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRTygerEliteSquad1",
                        t"DynamicSpawnSystem.GRTygerEliteSquad2",
                        t"DynamicSpawnSystem.GRTygerEliteSquad3",
                        t"DynamicSpawnSystem.GRTygerEliteSquad4",
                        t"DynamicSpawnSystem.GRTygerEliteSquad5",
                        t"DynamicSpawnSystem.GRTygerEliteSquad6"
                    ], 3);

                return ArrayMerge(ArrayMerge(eliteRareCar, rareSquad), rareBike); 
            default: 
                return [];
        }
    }
}