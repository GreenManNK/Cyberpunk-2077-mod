module Gibbon.GR.GangData


public class GRWraithsData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 w bike
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);
                return weakBike;
            case 2:  // 1 wn       
                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 1);

                return wn;
            case 3: // 1 wn + 1 w bike
                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 1);

                 let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);                   

                return ArrayMerge(wn, weakBike);
            case 4: // 2 wn
                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2);            

                return wn;           
            case 5:  // rn + wn + w bike 
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 1);   

                 let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   
                return ArrayMerge(ArrayMerge(rn, wn), weakBike);
            case 6:  // rn + wn + 2w bike  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 1);   

                 let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 2);   
                return ArrayMerge(ArrayMerge(rn, wn), weakBike);
            case 7:  // rn + 2wn + 1w bike  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2);   

                 let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   
                return ArrayMerge(ArrayMerge(rn, wn), weakBike);
            case 8: // 2 rn + wn + 1 w bike
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 1);   

                 let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   
                return ArrayMerge(ArrayMerge(rn, wn), weakBike);
            case 9:  // 2 rn + 2wn
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2);   
 
                return ArrayMerge(rn, wn);
            case 10: // er + rn + 2wn + 1 weak bike
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 1);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2); 

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), weakBike);
            case 11: // er + 2rn + nw + 1 weak bike
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 1);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 1); 

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), weakBike);   
            case 12: // er + 2rn + 2nw + 1 weak bike
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 1);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2); 

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), weakBike);          
            case 13: // er + 3rn + 2nw + 1 weak bike
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 1);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 3);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2); 

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), weakBike);
            case 14: // er + 3rn + 2nw + 2 weak bike
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 1);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 3);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2); 

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithWeakBike1",
                        t"DynamicSpawnSystem.GRWraithWeakBike2",
                        t"DynamicSpawnSystem.GRWraithWeakBike3",
                        t"DynamicSpawnSystem.GRWraithWeakBike4"
                    ], 2);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), weakBike);
            case 15: // 2er + 2rn + 2nw + normal bikes   
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 2);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2); 

                let nBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalBike1",
                        t"DynamicSpawnSystem.GRWraithNormalBike2",
                        t"DynamicSpawnSystem.GRWraithNormalBike3",
                        t"DynamicSpawnSystem.GRWraithNormalBike4"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), nBike);
            case 16: // 2er + 2rn + 2nw + 2 normal bikes
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 2);  
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let wn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalSquad1",
                        t"DynamicSpawnSystem.GRWraithNormalSquad2",
                        t"DynamicSpawnSystem.GRWraithNormalSquad3",
                        t"DynamicSpawnSystem.GRWraithNormalSquad4",
                        t"DynamicSpawnSystem.GRWraithNormalSquad5"
                    ], 2); 

                let nBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalBike1",
                        t"DynamicSpawnSystem.GRWraithNormalBike2",
                        t"DynamicSpawnSystem.GRWraithNormalBike3",
                        t"DynamicSpawnSystem.GRWraithNormalBike4"
                    ], 2);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), wn), nBike);
            case 17: // 2er + rrrr + 2 normal bikes
                let rrrr = [t"DynamicSpawnSystem.GRWraithRareSquad5"];

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 2);  

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let nBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalBike1",
                        t"DynamicSpawnSystem.GRWraithNormalBike2",
                        t"DynamicSpawnSystem.GRWraithNormalBike3",
                        t"DynamicSpawnSystem.GRWraithNormalBike4"
                    ], 1);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), nBike), rrrr);
            case 18: // 2er + rrrr + 3 normal bikes 
                let rrrr = [t"DynamicSpawnSystem.GRWraithRareSquad5"];

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 2);  

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let nBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalBike1",
                        t"DynamicSpawnSystem.GRWraithNormalBike2",
                        t"DynamicSpawnSystem.GRWraithNormalBike3",
                        t"DynamicSpawnSystem.GRWraithNormalBike4"
                    ], 2);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), nBike), rrrr);
            case 19: // 2er + rrrr + 4 normal bikes
                let rrrr = [t"DynamicSpawnSystem.GRWraithRareSquad5"];

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 2);  

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 1);  

                let nBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalBike1",
                        t"DynamicSpawnSystem.GRWraithNormalBike2",
                        t"DynamicSpawnSystem.GRWraithNormalBike3",
                        t"DynamicSpawnSystem.GRWraithNormalBike4"
                    ], 3);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), nBike), rrrr);
            case 20: // 3er + rrrr + 4 normal bikes
                let rrrr = [t"DynamicSpawnSystem.GRWraithRareSquad5"];

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithEliteSquad1",
                        t"DynamicSpawnSystem.GRWraithEliteSquad2",
                        t"DynamicSpawnSystem.GRWraithEliteSquad3"
                    ], 3);  

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithRareSquad1",
                        t"DynamicSpawnSystem.GRWraithRareSquad2",
                        t"DynamicSpawnSystem.GRWraithRareSquad3",
                        t"DynamicSpawnSystem.GRWraithRareSquad4"
                    ], 2);  

                let nBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRWraithNormalBike1",
                        t"DynamicSpawnSystem.GRWraithNormalBike2",
                        t"DynamicSpawnSystem.GRWraithNormalBike3",
                        t"DynamicSpawnSystem.GRWraithNormalBike4"
                    ], 2);   

                return ArrayMerge(ArrayMerge(ArrayMerge(er, rn), nBike), rrrr);
            default: 
                return [];
        }
    }
}