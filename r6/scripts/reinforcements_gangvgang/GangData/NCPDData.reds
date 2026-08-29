module Gibbon.GR.GangData


public class GRNCPDData extends GRGangData {
    public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak - (biker)
                return [t"DynamicSpawnSystem.GRNCPDWeakBike1"];
            case 2:  // 1 weak, 1 normal (patrol car 1w/1n)
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 1);
                return patrolCar;
            case 3: // 2 weak, 1 normal (biker + patrol)
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 1);
                let biker = [t"DynamicSpawnSystem.GRNCPDWeakBike1"];

                return ArrayMerge(patrolCar, biker);
            case 4: // 2 weak, 2 normal (2 patrols)
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 2);           
            case 5:  // 3 normal, 1 rare (standard squad)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 2);

                return standardSquad;
            case 6:  // 1 weak, 3 normal, 1 rare (standdard squad + bike)
               let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 2);    
                let biker = [t"DynamicSpawnSystem.GRNCPDWeakBike1"];  

                return ArrayMerge(biker, standardSquad);
            case 7:  // 1 weak, 4 normal, 1 rare (standard squad + patrol car)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 1);    
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 1); 

                return ArrayMerge(patrolCar, standardSquad);
            case 8: // 2 weak, 3 normals, 2 rare (rrnn, patrol car, bike)       
                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 1);   
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 1); 
                let biker = [t"DynamicSpawnSystem.GRNCPDWeakBike1"];

                return ArrayMerge(ArrayMerge(patrolCar, rrnn), biker);
            case 9:  //  2 weak, 4 normals, 2 rare     (rrnn, 2x patrol car)    
                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 1);   
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 2); 

                return ArrayMerge(patrolCar, rrnn);  
            case 10: // 1 weak, 2 normals, 2 rares, 1 elite (elite + patrol car)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 2);   
                let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 1); 
                return ArrayMerge(rare, patrolCar);
            case 11: // 5 normals 3 rares, 1 elite (elite + standard squad)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 1);               
                return ArrayMerge(rare, standardSquad);       
            case 12: // 1 weak, 5 normals, 4 rares, 1 elite (elite + standard squad + bike)
                let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 1);               
                let bike = [t"DynamicSpawnSystem.GRNCPDWeakBike1"];

                return ArrayMerge(ArrayMerge(rare, standardSquad), bike);                 
            case 13: // 6 normals, 4 rares, 1 elite (elite + 2 standard squads)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 1);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 2);               
                return ArrayMerge(elite, standardSquad);   
            case 14: // 2weak, 6 normals, 4 rares, 1 elite (elite + 2 standard squads + bike)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 1);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 2);               
                let bike = [t"DynamicSpawnSystem.GRNCPDWeakBike1", t"DynamicSpawnSystem.GRNCPDWeakBike1"];

                return ArrayMerge(ArrayMerge(elite, standardSquad), bike);   
            case 15: // 6 normals, 4 rares, 2 elite (2 elite + standard quad)
                   let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 2);   
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 1);               
                return ArrayMerge(elite, standardSquad);   
            case 16: // 5 normals 5 rares, 2 elite (2 elite + standard quad + bike)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 2);   

                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 1);               
                let bike = [t"DynamicSpawnSystem.GRNCPDWeakBike1"];

                return ArrayMerge(ArrayMerge(elite, standardSquad), bike);   
            case 17: // 2 normals, 6 rares, 2 elite (2 elite + standard quad + patrol)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 2);   
                    
                    let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad6",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad7",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad8",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad9"
                    ], 1);               
                	let patrolCar = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDNormalSquad1",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad2",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad3",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad4",
                        t"DynamicSpawnSystem.GRNCPDNormalSquad5"
                    ], 1); 
                return ArrayMerge(ArrayMerge(elite, standardSquad), patrolCar);   
            case 18: // 6 normals, 6 rares, 2 elite (2 elite + 2standard quad )
                   let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 2);   
                    let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 2);               
                return ArrayMerge(elite, rare);   
            case 19: // 8 rares, 2 elite + (2 elite + 2standard quad  + bike)
                let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 2);   

                    let rare = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDRareSquad1",
                        t"DynamicSpawnSystem.GRNCPDRareSquad2",
                        t"DynamicSpawnSystem.GRNCPDRareSquad3",
                        t"DynamicSpawnSystem.GRNCPDRareSquad4"
                    ], 2);               
                let bike = [t"DynamicSpawnSystem.GRNCPDWeakBike1"];

                return ArrayMerge(ArrayMerge(elite, rare), bike);   
            case 20: // 3 normals 7 rares, 3 elite (3 elite + standard)
                   let elite = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRNCPDEliteSquad1",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad2",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad3",
                        t"DynamicSpawnSystem.GRNCPDEliteSquad4"
                    ], 3);             
                return elite;   
            default: 
                return [];
        }
    }
}