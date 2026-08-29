module Gibbon.GR.GangData


public class GRMoxData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak - (biker)
                return GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxWeakBike1",
                    t"DynamicSpawnSystem.GRMoxWeakBike2",
                    t"DynamicSpawnSystem.GRMoxWeakBike3"
                ], 1);
            case 2:  // 1 weak, 1 normal (patrol car 1w/1n)
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 1);
                return patrolCar;
            case 3: // 2 weak, 1 normal (biker + patrol)
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 1);
                let biker = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxWeakBike1",
                    t"DynamicSpawnSystem.GRMoxWeakBike2",
                    t"DynamicSpawnSystem.GRMoxWeakBike3"
                ], 1);

                return ArrayMerge(patrolCar, biker);
            case 4: // 2 weak, 2 normal (2 patrols)
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 2);           
            case 5:  // 3 normal, 1 rare (standard squad)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);

                return standardSquad;
            case 6:  // 1 weak, 3 normal, 1 rare (standard squad + bike)
               let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);    
                let biker = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxWeakBike1",
                    t"DynamicSpawnSystem.GRMoxWeakBike2",
                    t"DynamicSpawnSystem.GRMoxWeakBike3"
                ], 1);  

                return ArrayMerge(biker, standardSquad);
            case 7:  // 1 weak, 4 normal, 1 rare (standard squad + patrol car)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);    
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 1); 

                return ArrayMerge(patrolCar, standardSquad);
            case 8: // 2 weak, 3 normals, 2 rare (rrnn, patrol car, bike)       
                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 1);   
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 1); 
                let biker = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxWeakBike1",
                    t"DynamicSpawnSystem.GRMoxWeakBike2",
                    t"DynamicSpawnSystem.GRMoxWeakBike3",
                    t"DynamicSpawnSystem.GRMoxRareBike1",
                    t"DynamicSpawnSystem.GRMoxRareBike2",
                    t"DynamicSpawnSystem.GRMoxRareBike3"
                ], 1);

                return ArrayMerge(ArrayMerge(patrolCar, rrnn), biker);
            case 9:  //  2 weak, 4 normals, 2 rare     (rrnn, 2x patrol car)    
                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 1);   
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 2); 

                return ArrayMerge(patrolCar, rrnn);  
            case 10: // 1 weak, 2 normals, 2 rares (rare + patrol car)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);   
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 1); 
                return ArrayMerge(rare, patrolCar);
            case 11: // 5 normals 3 rares (rare + standard squad)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);               
                return ArrayMerge(rare, standardSquad);       
            case 12: // 1 weak, 5 normals, 4 rares (rare + standard squad + bike)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);               
                let bike = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxRareBike1",
                    t"DynamicSpawnSystem.GRMoxRareBike2",
                    t"DynamicSpawnSystem.GRMoxRareBike3"
                ], 1);

                return ArrayMerge(ArrayMerge(rare, standardSquad), bike);                 
            case 13: // 6 normals, 4 rares (rare + 2 standard squads)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 2);               
                return ArrayMerge(rare, standardSquad);   
            case 14: // 2weak, 6 normals, 4 rares (rare + 2 standard squads + bike)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 2);               
                let bike = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxRareBike1",
                    t"DynamicSpawnSystem.GRMoxRareBike2",
                    t"DynamicSpawnSystem.GRMoxRareBike3"
                ], 2);

                return ArrayMerge(ArrayMerge(rare, standardSquad), bike);   
            case 15: // 6 normals, 4 rares, 2 elite (2 elite + standard squad) - ELITES START HERE
                   let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxEliteSquad1",
                        t"DynamicSpawnSystem.GRMoxEliteSquad2",
                        t"DynamicSpawnSystem.GRMoxEliteSquad3"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);               
                return ArrayMerge(elite, standardSquad);   
            case 16: // 5 normals 5 rares, 2 elite (2 elite + standard squad + bike)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxEliteSquad1",
                        t"DynamicSpawnSystem.GRMoxEliteSquad2",
                        t"DynamicSpawnSystem.GRMoxEliteSquad3"
                    ], 2);   

                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);               
                let bike = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxRareBike1",
                    t"DynamicSpawnSystem.GRMoxRareBike2",
                    t"DynamicSpawnSystem.GRMoxRareBike3"
                ], 1);

                return ArrayMerge(ArrayMerge(elite, standardSquad), bike);   
            case 17: // 2 normals, 6 rares, 2 elite (2 elite + standard squad + patrol)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxEliteSquad1",
                        t"DynamicSpawnSystem.GRMoxEliteSquad2",
                        t"DynamicSpawnSystem.GRMoxEliteSquad3"
                    ], 2);   
                    
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad4",
                        t"DynamicSpawnSystem.GRMoxNormalSquad5",
                        t"DynamicSpawnSystem.GRMoxNormalSquad6",
                        t"DynamicSpawnSystem.GRMoxNormalSquad7"
                    ], 1);               
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxNormalSquad1",
                        t"DynamicSpawnSystem.GRMoxNormalSquad2",
                        t"DynamicSpawnSystem.GRMoxNormalSquad3"
                    ], 1); 
                return ArrayMerge(ArrayMerge(elite, standardSquad), patrolCar);   
            case 18: // 6 normals, 6 rares, 2 elite (2 elite + 2 standard squads)
                   let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxEliteSquad1",
                        t"DynamicSpawnSystem.GRMoxEliteSquad2",
                        t"DynamicSpawnSystem.GRMoxEliteSquad3"
                    ], 2);   
                    let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);               
                return ArrayMerge(elite, rare);   
            case 19: // 8 rares, 2 elite (2 elite + 2 standard squads + bike)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxEliteSquad1",
                        t"DynamicSpawnSystem.GRMoxEliteSquad2",
                        t"DynamicSpawnSystem.GRMoxEliteSquad3"
                    ], 2);   

                    let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 2);               
                let bike = GetRandomFrom([
                    t"DynamicSpawnSystem.GRMoxRareBike1",
                    t"DynamicSpawnSystem.GRMoxRareBike2",
                    t"DynamicSpawnSystem.GRMoxRareBike3",
                    t"DynamicSpawnSystem.GRMoxEliteBike1"
                ], 2);

                return ArrayMerge(ArrayMerge(elite, rare), bike);   
            case 20: // 3 normals 7 rares, 3 elite (3 elite + standard)
                   let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMoxEliteSquad1",
                        t"DynamicSpawnSystem.GRMoxEliteSquad2",
                        t"DynamicSpawnSystem.GRMoxEliteSquad3"
                    ], 3);   
                    let rare = GetRandomFrom(
                    [
                       t"DynamicSpawnSystem.GRMoxRareSquad1",
                        t"DynamicSpawnSystem.GRMoxRareSquad2",
                        t"DynamicSpawnSystem.GRMoxRareSquad3"
                    ], 1);     
					let eliteBike = [t"DynamicSpawnSystem.GRMoxEliteBike1"];          
                return ArrayMerge(ArrayMerge(elite, rare), eliteBike);   
            default: 
                return [];
        }
    }
}
