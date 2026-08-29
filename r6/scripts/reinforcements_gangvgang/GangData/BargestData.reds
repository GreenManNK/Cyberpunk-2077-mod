module Gibbon.GR.GangData




public class GRBarghestData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak (weak bike)
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 1);

                return weakBike;
            case 2:  // 1 weak, 1 normal (patrol nw)   
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestNormalSquad1",
                        t"DynamicSpawnSystem.GRBargestNormalSquad2",
                        t"DynamicSpawnSystem.GRBargestNormalSquad3",
                        t"DynamicSpawnSystem.GRBargestNormalSquad4",
                        t"DynamicSpawnSystem.GRBargestNormalSquad5"
                    ], 1);

                return nw;     
            case 3: // 2 weak, 1 normal (patrol nw + bike)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestNormalSquad1",
                        t"DynamicSpawnSystem.GRBargestNormalSquad2",
                        t"DynamicSpawnSystem.GRBargestNormalSquad3",
                        t"DynamicSpawnSystem.GRBargestNormalSquad4",
                        t"DynamicSpawnSystem.GRBargestNormalSquad5"
                    ], 1);

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 1);  

                return ArrayMerge(nw, weakBike);
            case 4: // 2 weak, 2 normal (2x nw)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestNormalSquad1",
                        t"DynamicSpawnSystem.GRBargestNormalSquad2",
                        t"DynamicSpawnSystem.GRBargestNormalSquad3",
                        t"DynamicSpawnSystem.GRBargestNormalSquad4",
                        t"DynamicSpawnSystem.GRBargestNormalSquad5"
                    ], 2);     
       
                return nw;           
            case 5:  // 2 weak, 2 normal, 1 rare (rnnw car + bike)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestRareSquad1",
                        t"DynamicSpawnSystem.GRBargestRareSquad2",
                        t"DynamicSpawnSystem.GRBargestRareSquad3",
                        t"DynamicSpawnSystem.GRBargestRareSquad4",
                        t"DynamicSpawnSystem.GRBargestRareSquad5",
                        t"DynamicSpawnSystem.GRBargestRareSquad6",
                        t"DynamicSpawnSystem.GRBargestRareSquad7"
                    ], 1);  

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 1);

                return ArrayMerge(rnnw, weakBike);
            case 6:  // 3 weak, 2 normal, 1 rare (rnnw car + 2 bikes)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestRareSquad1",
                        t"DynamicSpawnSystem.GRBargestRareSquad2",
                        t"DynamicSpawnSystem.GRBargestRareSquad3",
                        t"DynamicSpawnSystem.GRBargestRareSquad4",
                        t"DynamicSpawnSystem.GRBargestRareSquad5",
                        t"DynamicSpawnSystem.GRBargestRareSquad6",
                        t"DynamicSpawnSystem.GRBargestRareSquad7"
                    ], 1);  

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 2);

                return ArrayMerge(rnnw, weakBike);
            case 7:  // 3 weak, 3 normal, 1 rare (rnnw car + 1 bike + nw)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestNormalSquad1",
                        t"DynamicSpawnSystem.GRBargestNormalSquad2",
                        t"DynamicSpawnSystem.GRBargestNormalSquad3",
                        t"DynamicSpawnSystem.GRBargestNormalSquad4",
                        t"DynamicSpawnSystem.GRBargestNormalSquad5"
                    ], 1);  

                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestRareSquad1",
                        t"DynamicSpawnSystem.GRBargestRareSquad2",
                        t"DynamicSpawnSystem.GRBargestRareSquad3",
                        t"DynamicSpawnSystem.GRBargestRareSquad4",
                        t"DynamicSpawnSystem.GRBargestRareSquad5",
                        t"DynamicSpawnSystem.GRBargestRareSquad6",
                        t"DynamicSpawnSystem.GRBargestRareSquad7"
                    ], 1);  

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 1);

                return ArrayMerge(ArrayMerge(rnnw, weakBike), nw);
            case 8: // 2 weak, 4 normals, 2 rare (2 x rnnw)  
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestRareSquad1",
                        t"DynamicSpawnSystem.GRBargestRareSquad2",
                        t"DynamicSpawnSystem.GRBargestRareSquad3",
                        t"DynamicSpawnSystem.GRBargestRareSquad4",
                        t"DynamicSpawnSystem.GRBargestRareSquad5",
                        t"DynamicSpawnSystem.GRBargestRareSquad6",
                        t"DynamicSpawnSystem.GRBargestRareSquad7"
                    ], 2);  

                return rnnw;
            case 9:  //  3 weak, 4 normals, 2 rare ( 2 x rnnw + bike)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestRareSquad1",
                        t"DynamicSpawnSystem.GRBargestRareSquad2",
                        t"DynamicSpawnSystem.GRBargestRareSquad3",
                        t"DynamicSpawnSystem.GRBargestRareSquad4",
                        t"DynamicSpawnSystem.GRBargestRareSquad5",
                        t"DynamicSpawnSystem.GRBargestRareSquad6",
                        t"DynamicSpawnSystem.GRBargestRareSquad7"
                    ], 2);  

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 1);

                return ArrayMerge(rnnw, weakBike);    
            case 10: // 4 weak, 3 rares, 1 elite (errr + wwww)
                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1"];

                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);
                
                return ArrayMerge(errr, wwww);  
            case 11: // 5 weak, 3 rares, 1 elite  (errr + wwww + bike)
                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1"];

                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);
                
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 1);

                return ArrayMerge(ArrayMerge(errr, wwww), weakBike);       
            case 12: // 8 weak, 3 rares, 1 elite  (errr + 2wwww)
                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1", t"DynamicSpawnSystem.GRBargestWeakSquad1"];

                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);
                
                return ArrayMerge(errr, wwww);             
            case 13: // 7 normals, 4 rares, 1 elite (errr + wwww + rnnw)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestRareSquad1",
                        t"DynamicSpawnSystem.GRBargestRareSquad2",
                        t"DynamicSpawnSystem.GRBargestRareSquad3",
                        t"DynamicSpawnSystem.GRBargestRareSquad4",
                        t"DynamicSpawnSystem.GRBargestRareSquad5",
                        t"DynamicSpawnSystem.GRBargestRareSquad6",
                        t"DynamicSpawnSystem.GRBargestRareSquad7"
                    ], 1);    

                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);

                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1"];  

                return ArrayMerge(ArrayMerge(errr, wwww), rnnw);   
            case 14: // 6 rares, 2 elite (2errr)
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 2);

                return errr;
            case 15: // 2 weak, 2 normals, 6 rares, 2 elite (2errr + nw) 
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 2);

                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestNormalSquad1",
                        t"DynamicSpawnSystem.GRBargestNormalSquad2",
                        t"DynamicSpawnSystem.GRBargestNormalSquad3",
                        t"DynamicSpawnSystem.GRBargestNormalSquad4",
                        t"DynamicSpawnSystem.GRBargestNormalSquad5"
                    ], 1);                      

                return ArrayMerge(nw, errr);
            case 16: // 3 rares, 5 elite (eeee + errr) 
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);      

                let eeee = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad7",
                        t"DynamicSpawnSystem.GRBargestEliteSquad8",
                        t"DynamicSpawnSystem.GRBargestEliteSquad9"
                    ], 1);   


                return ArrayMerge(errr, eeee);
            case 17: // 2 weak, 3 rares, 5 elite (eeee + errr + 2bike) 
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);      

                let eeee = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad7",
                        t"DynamicSpawnSystem.GRBargestEliteSquad8",
                        t"DynamicSpawnSystem.GRBargestEliteSquad9"
                    ], 1);   

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestWeakBike1",
                        t"DynamicSpawnSystem.GRBargestWeakBike2",
                        t"DynamicSpawnSystem.GRBargestWeakBike3"
                    ], 2);

                return ArrayMerge(ArrayMerge(errr, eeee), weakBike);
            case 18: // 4 weak, 3 rares, 5 elite (eeee + errr + wwww) 
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);      

                let eeee = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad7",
                        t"DynamicSpawnSystem.GRBargestEliteSquad8",
                        t"DynamicSpawnSystem.GRBargestEliteSquad9"
                    ], 1);   
                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1"];  

                return ArrayMerge(ArrayMerge(errr, eeee), wwww);
            case 19: // 8 weak, 3 rares, 5 elite (eeee + errr + 2wwww) 
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 1);      

                let eeee = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad7",
                        t"DynamicSpawnSystem.GRBargestEliteSquad8",
                        t"DynamicSpawnSystem.GRBargestEliteSquad9"
                    ], 1);   

                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1", t"DynamicSpawnSystem.GRBargestWeakSquad1"];  

                return ArrayMerge(ArrayMerge(errr, eeee), wwww);
            case 20: //  8 weak, 6 rares, 6 elite (eeee + 2errr + 2wwww) 
                let errr = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad1",
                        t"DynamicSpawnSystem.GRBargestEliteSquad2",
                        t"DynamicSpawnSystem.GRBargestEliteSquad3",
                        t"DynamicSpawnSystem.GRBargestEliteSquad4",
                        t"DynamicSpawnSystem.GRBargestEliteSquad5",
                        t"DynamicSpawnSystem.GRBargestEliteSquad6"
                    ], 2);      

                let eeee = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRBargestEliteSquad7",
                        t"DynamicSpawnSystem.GRBargestEliteSquad8",
                        t"DynamicSpawnSystem.GRBargestEliteSquad9"
                    ], 1);   

                let wwww = [t"DynamicSpawnSystem.GRBargestWeakSquad1", t"DynamicSpawnSystem.GRBargestWeakSquad1"];  

                return ArrayMerge(ArrayMerge(errr, eeee), wwww);
            default: 
                return [];
        }
    }
}