module Gibbon.GR.GangData

public class GRAnimalsData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);
                return weakBike;
            case 2:  // 1 weak, 1 normal           
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);

                let normalCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsNormalBike1",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike2",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike3",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike4",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike5",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike6",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike7",
                        t"DynamicSpawnSystem.GRAnimalsNormalBike8"
                    ], 1);

                return ArrayMerge(normalCar, weakBike);
            case 3: // 2 normal
                let doubleTrouble = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad1",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad2",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad3",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad4"
                    ], 1);
                return doubleTrouble;
            case 4: // 1 rare
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);
            
                return rareBike;           
            case 5:  // 2 normal, 1 rare
                let doubleTrouble = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad1",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad2",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad3",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad4"
                    ], 1);
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);

                return ArrayMerge(doubleTrouble, rareBike);
            case 6:  // 1 weak, 2 normal, 1 rare
                let doubleTrouble = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad1",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad2",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad3",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad4"
                    ], 1);
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);
                return ArrayMerge(doubleTrouble, ArrayMerge(rareBike, weakBike));
            case 7:  // 1 weak, 2 normal, 2 rare
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);
                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);
                return ArrayMerge(squad, weakBike);
            case 8: // 2 normals, 3 rare            
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);
                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);
                return ArrayMerge(squad, weakBike);
            case 9:  //  1 weak, 2 normals, 3 rare    
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);

                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);
                return ArrayMerge(ArrayMerge(squad, weakBike), rareBike);    
            case 10: //  2 rares, 2 elite
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);

                return eliteSquad;
            case 11: // 4 normals 2 rares, 2 elite
                    let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);

                let doubleTrouble = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad1",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad2",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad3",
                        t"DynamicSpawnSystem.GRAnimalsNormalSquad4"
                    ], 2);
                return ArrayMerge(doubleTrouble, eliteSquad);       
            case 12: // 2 normals, 4 rares, 2 elite
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);                    
                return ArrayMerge(squad, eliteSquad);               
            case 13: // 1 weak, 2 normals, 4 rares, 2 elite
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsWeakBike1",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike2",
                        t"DynamicSpawnSystem.GRAnimalsWeakBike3"
                    ], 1);
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);      

                return ArrayMerge(weakBike, ArrayMerge(squad, eliteSquad));    
            case 14: // 2 normals, 5 rares, 2 elite
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);
            
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);      

                return ArrayMerge(rareBike, ArrayMerge(squad, eliteSquad));    
            case 15: // 2 normals, 4 rares, 3 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteBike1",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike2",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike3",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike4"
                    ], 1);
            
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);

                let squad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareSquad1",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad2",
                        t"DynamicSpawnSystem.GRAnimalsRareSquad3"
                    ], 1);      

                return ArrayMerge(eliteBike, ArrayMerge(squad, eliteSquad)); 
            case 16: // 5 rares, 3 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteBike1",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike2",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike3",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike4"
                    ], 1);
            
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);
            
                return ArrayMerge(rareBike, ArrayMerge(eliteBike, eliteSquad)); 
            case 17: // 6 rares, 3 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteBike1",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike2",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike3",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike4"
                    ], 1);
            
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 4);
            
                return ArrayMerge(rareBike, ArrayMerge(eliteBike, eliteSquad)); 
            case 18: // 3 rares, 4 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteBike1",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike2",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike3",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike4"
                    ], 2);
            
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 1);
                let rareBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsRareBike1",
                        t"DynamicSpawnSystem.GRAnimalsRareBike2",
                        t"DynamicSpawnSystem.GRAnimalsRareBike3",
                        t"DynamicSpawnSystem.GRAnimalsRareBike4",
                        t"DynamicSpawnSystem.GRAnimalsRareBike6",
                        t"DynamicSpawnSystem.GRAnimalsRareBike7",
                        t"DynamicSpawnSystem.GRAnimalsRareBike8",
                        t"DynamicSpawnSystem.GRAnimalsRareBike9",
                        t"DynamicSpawnSystem.GRAnimalsRareBike10",
                        t"DynamicSpawnSystem.GRAnimalsRareBike5"
                    ], 1);
            
                return ArrayMerge(rareBike, ArrayMerge(eliteBike, eliteSquad)); 
            case 19: // 4 rares, 4 elite
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 2);
            case 20: // 4 rares, 5 elite
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad1",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad2",
                        t"DynamicSpawnSystem.GRAnimalsEliteSquad3"
                    ], 2);
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAnimalsEliteBike1",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike2",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike3",
                        t"DynamicSpawnSystem.GRAnimalsEliteBike4"
                    ], 1);
                return  ArrayMerge(eliteBike, eliteSquad);
            default: 
                return [];
        }
    }
}