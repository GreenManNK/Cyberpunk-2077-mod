module Gibbon.GR.GangData




public class GRArasakaData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // empty
                return [t"DynamicSpawnSystem.GRArasakaWeakBike1"];
            case 2:  // empty       
                return [t"DynamicSpawnSystem.GRArasakaWeakBike1"];
            case 3: // empty
                return [t"DynamicSpawnSystem.GRArasakaWeakSquad1"];
            case 4: // 4 normal (rangers)
                let rangers = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad1",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad2"
                    ], 1);
                return rangers;        
            case 5:  // 2 rares (soldier rares)
                let rares = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad1",
                        t"DynamicSpawnSystem.GRArasakaRareSquad2",
                        t"DynamicSpawnSystem.GRArasakaRareSquad3",
                        t"DynamicSpawnSystem.GRArasakaRareSquad4"
                    ], 1);
                return rares;     
            case 6:  // 4 normals 2 rares (soldier rares)
                let rangers = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad1",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad2"
                    ], 1);

                let rares = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad1",
                        t"DynamicSpawnSystem.GRArasakaRareSquad2",
                        t"DynamicSpawnSystem.GRArasakaRareSquad3",
                        t"DynamicSpawnSystem.GRArasakaRareSquad4"
                    ], 1);                                
                return ArrayMerge(rangers, rares);
            case 7:  // 4 normals 2 rares (soldier rares)
                let rangers = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad1",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad2"
                    ], 1);

                let rares = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad1",
                        t"DynamicSpawnSystem.GRArasakaRareSquad2",
                        t"DynamicSpawnSystem.GRArasakaRareSquad3",
                        t"DynamicSpawnSystem.GRArasakaRareSquad4"
                    ], 1);                                
                return ArrayMerge(rangers, rares);
            case 8: // 4 rares (snadrad squads)      
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
            case 9:  //  4 rares (snadrad squads)     
                 return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);  
            case 10: // 4 rares (standard squads), 1 elite (assassin)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 1);
                return ArrayMerge(standardSquad, eliteBike);
            case 11: // 8 normies (rangers), 4 rare ((specialised)), 1 elite (assassin)
                let rangers = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad1",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad2"
                    ], 2);
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(ArrayMerge(rangers, eliteBike), specialisedSquad);   
            case 12: // 8 rares (1 standard squad, 1 specialised), 1 elite (non juggernaut)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(ArrayMerge(standardSquad, eliteBike), specialisedSquad);             
            case 13: // 8 rares (1 standard squad, 1 specialised), 1 elite (non juggernaut)
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(ArrayMerge(standardSquad, eliteBike), specialisedSquad);     
            case 14: // 8 rares, 2 elite
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad);     
            case 15: // 8 rares 3 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 1);            
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(eliteBike, ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad));     
            case 16: // 12 rares, 3 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 1);            
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 2);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(eliteBike, ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad));    
            case 17: // 12 rares, 4 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 2);            
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 2);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 1);
                return ArrayMerge(eliteBike, ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad));    
            case 18: // 12 rares, 4 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 2);            
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 2);
                return ArrayMerge(eliteBike, ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad));   
            case 19: // 12 rares, 5 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 3);            
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 1);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 2);
                return ArrayMerge(eliteBike, ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad));  
            case 20: // 12 rares, 6 elite
                let eliteBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteBike1",
                        t"DynamicSpawnSystem.GRArasakaEliteBike2",
                        t"DynamicSpawnSystem.GRArasakaEliteBike3",
                        t"DynamicSpawnSystem.GRArasakaEliteBike4",
                        t"DynamicSpawnSystem.GRArasakaEliteBike5"
                    ], 2);            
                let standardSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaNormalSquad3",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad4",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad5",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad6",
                        t"DynamicSpawnSystem.GRArasakaNormalSquad7"
                    ], 1);
                let heavySquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaEliteSquad1",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad2",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad3",
                        t"DynamicSpawnSystem.GRArasakaEliteSquad4"
                    ], 2);
                let specialisedSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRArasakaRareSquad5",
                        t"DynamicSpawnSystem.GRArasakaRareSquad6",
                        t"DynamicSpawnSystem.GRArasakaRareSquad7",
                        t"DynamicSpawnSystem.GRArasakaRareSquad8",
                        t"DynamicSpawnSystem.GRArasakaRareSquad10",
                        t"DynamicSpawnSystem.GRArasakaRareSquad11",
                        t"DynamicSpawnSystem.GRArasakaRareSquad9"
                    ], 2);
                return ArrayMerge(eliteBike, ArrayMerge(ArrayMerge(standardSquad, heavySquad), specialisedSquad));  
            default: 
                return [];
        }
    }
}