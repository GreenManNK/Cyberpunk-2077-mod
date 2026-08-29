module Gibbon.GR.GangData


public class GRMilitechData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 2 weak (1 ww car)
                let ww = [t"DynamicSpawnSystem.GRMilitechWeakSquad1"];

                return ww;
            case 2:  // 1 weak, 1 normal (1 wn car)        
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 1);

                return nw;
            case 3: // 3 weak, 1 normal (1 ww car, 1 wn car)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 1);
                let ww = [t"DynamicSpawnSystem.GRMilitechWeakSquad1"];   
                return ArrayMerge(nw, ww);
            case 4: // 2 weak, 2 normal 
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 2);
                return nw;           
            case 5:  // 3 normal, 1 rare (rnnn car)
                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 1);
                return rnnn;
            case 6:  // 2 weak, 3 normal, 1 rare (rnnn car + ww car)
                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 1);

                let ww = [t"DynamicSpawnSystem.GRMilitechWeakSquad1"];                  

                return ArrayMerge(rnnn, ww);
            case 7:  // 1 weak, 4 normal, 1 rare  (rnnn car + nw car)
                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 1);

                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 1);
                return ArrayMerge(rnnn, nw);
            case 8: // 3 weak, 4 normals, 1 rare  (rnnn car + nw car + ww car)  
                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 1);
                    
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 1);     

                let ww = [t"DynamicSpawnSystem.GRMilitechWeakSquad1"];                   
                return ArrayMerge(ArrayMerge(rnnn, nw), ww);
            case 9:  // 6 normals, 2 rare (2 rnnn car)   
                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 2);            
                return rnnn;      
            case 10: // 5 normals, 2 rares, 1 elite (ernn + rnnn)
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 1);  

                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 2);  

                return ArrayMerge(ernn, rnnn);
            case 11: // 4 normals 3 rares, 1 elite (ernn + rrnn)
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 1);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 1);  

                return ArrayMerge(ernn, rrnn);      
            case 12: // 2 weak, 4 normals, 3 rares, 1 elite (ernn + rrnn + ww)
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 1);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 1);  

                let ww = [t"DynamicSpawnSystem.GRMilitechWeakSquad1"];   

                return ArrayMerge(ArrayMerge(ernn, rrnn), ww);                
            case 13: // 1 weak, 5 normals, 3 rares, 1 elite (ernn + rrnn + nw)
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 1);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 1);  
                    
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ernn, rrnn), nw);   
            case 14: // 7 normals, 4 rares, 1 elite (ernn + rrnn + rnnn)
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 1);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 1);  

                let rnnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad1",
                        t"DynamicSpawnSystem.GRMilitechRareSquad2",
                        t"DynamicSpawnSystem.GRMilitechRareSquad3",
                        t"DynamicSpawnSystem.GRMilitechRareSquad4"
                    ], 1);                      

                return ArrayMerge(ArrayMerge(ernn, rrnn), rnnn);   
            case 15: // 4 normals, 4 rares, 2 elite (2 ernn + rrnn)\
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 2);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 1);  

                return ArrayMerge(ernn, rrnn);   
            case 16: // 6 normals 5 rares, 2 elite (2 ernn + rrnn + nw)
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 2);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 1);  
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechNormalSquad1",
                        t"DynamicSpawnSystem.GRMilitechNormalSquad2"
                    ], 1);

                return ArrayMerge(ArrayMerge(ernn, rrnn), nw);   
            case 17: // 6 normals, 6 rares, 2 elite (2 ernn + 2rrnn )
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 2);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 2);  

                return ArrayMerge(ernn, rrnn);   
            case 18: // 6 normals, 6 rares, 2 elite (2 ernn + 2rrnn )
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 2);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 2);  

                return ArrayMerge(ernn, rrnn);   
            case 19: // 8 normals, 7 rares, 3 elite (3 ernn + 2rrnn )
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 3);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 2);  

                return ArrayMerge(ernn, rrnn);   
            case 20: // 12 normals, 8 rares, 4 elite (4 ernn + 2rrnn )
                let ernn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechEliteSquad1",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad2",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad3",
                        t"DynamicSpawnSystem.GRMilitechEliteSquad4"
                    ], 4);  

                let rrnn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRMilitechRareSquad5",
                        t"DynamicSpawnSystem.GRMilitechRareSquad6",
                        t"DynamicSpawnSystem.GRMilitechRareSquad7"
                    ], 2);  

                return ArrayMerge(ernn, rrnn);   
            default: 
                return [];
        }
    }
}