module Gibbon.GR.GangData


public class GRValentinoData extends GRGangData {public func GetReinforcements(heat: Int32) -> array<TweakDBID> { 
        switch (heat) {
            case 1: // 1 weak (weak bike)
                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakBike1",
                        t"DynamicSpawnSystem.GRValentinoWeakBike2",
                        t"DynamicSpawnSystem.GRValentinoWeakBike3",
                        t"DynamicSpawnSystem.GRValentinoWeakBike4",
                        t"DynamicSpawnSystem.GRValentinoWeakBike5",
                        t"DynamicSpawnSystem.GRValentinoWeakBike6"
                    ], 1);
                return weakBike;
            case 2:  // 1 weak, 1 normal (wn)  
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoNormalSquad1",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad2",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad3",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad4",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad5",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad6",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad7"
                    ], 1);
                return nw;
            case 3: // 2 weak, 1 normal (wn + weak bike)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoNormalSquad1",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad2",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad3",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad4",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad5",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad6",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad7"
                    ], 1);

                 let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakBike1",
                        t"DynamicSpawnSystem.GRValentinoWeakBike2",
                        t"DynamicSpawnSystem.GRValentinoWeakBike3",
                        t"DynamicSpawnSystem.GRValentinoWeakBike4",
                        t"DynamicSpawnSystem.GRValentinoWeakBike5",
                        t"DynamicSpawnSystem.GRValentinoWeakBike6"
                    ], 1);

                return ArrayMerge(nw, weakBike);
            case 4: // 2 weak, 2 normal (2x wn)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoNormalSquad1",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad2",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad3",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad4",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad5",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad6",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad7"
                    ], 2);
                return nw;           
            case 5:  // 2 weak, 2 normal, 1 rare (rnnw + weak bike)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);

                let weakBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakBike1",
                        t"DynamicSpawnSystem.GRValentinoWeakBike2",
                        t"DynamicSpawnSystem.GRValentinoWeakBike3",
                        t"DynamicSpawnSystem.GRValentinoWeakBike4",
                        t"DynamicSpawnSystem.GRValentinoWeakBike5",
                        t"DynamicSpawnSystem.GRValentinoWeakBike6"
                    ], 1);
                
                return ArrayMerge(rnnw, weakBike);
            case 6:  // 2 weak, 3 normal, 1 rare (rnnw + wn)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoNormalSquad1",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad2",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad3",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad4",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad5",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad6",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad7"
                    ], 1);  

                return ArrayMerge(nw, rnnw);
            case 7:  // 3 weak, 3 normal, 1 rare (3x wn + rare bike)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoNormalSquad1",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad2",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad3",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad4",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad5",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad6",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad7"
                    ], 3);  

                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1); 

                return ArrayMerge(nw, rBike);
            case 8: // 2 weak, 3 normals, 2 rare (rnnw + rare bike + wn)
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoNormalSquad1",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad2",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad3",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad4",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad5",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad6",
                        t"DynamicSpawnSystem.GRValentinoNormalSquad7"
                    ], 1);  

                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1); 

                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);

                return ArrayMerge(ArrayMerge(nw, rBike), rnnw);
            case 9:  //  2 weak, 4 normals, 2 rare (2x rnnw)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 2);
                return rnnw;      
            case 10: // 2 weak, 2 normals, 2 rares, 1 elite (ew, rare bike, rnnw)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 1);    

                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1);              

                return ArrayMerge(ArrayMerge(ew, rBike), rnnw);
            case 11: // 2 weak, 4 normals 2 rares, 1 elite (ew, 2x rnnw)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 1);              
                return ArrayMerge(ew, rnnw);      
            case 12: // 5 weakm, 2 normals, 3 rares, 1 elite, (rrnw + wwww + ew)
                let wwww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakSquad1",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad2",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad3",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad4"
                    ], 1); 
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 1);                      

                return ArrayMerge(ArrayMerge(ew, rnnw), wwww);              
            case 13: // 5 weakm, 2 normals, 4 rares, 1 elite, (rrnw + wwww + ew + rare bike)
                let wwww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakSquad1",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad2",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad3",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad4"
                    ], 1); 
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 1);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 1);                      
                    
                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1); 

                return ArrayMerge(ArrayMerge(ArrayMerge(ew, rnnw), wwww), rBike);    
            case 14: // 3 weak, 2 normals, 5 rares, 1 elite, (2x rrnw + ew + rare bike)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 2);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 1);                      
                    
                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1); 

                return ArrayMerge(ArrayMerge(ew, rnnw), rBike);    
            case 15: // 4 weak, 2 normals, 4 rares, 2 elite (2 ew + 2x rrnw)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 2);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 2);                      
                    
                return ArrayMerge(ew, rnnw);   
            case 16: // 4 weak, 2 normals, 5 rares, 2 elite (2 ew + 2x rrnw + rare bike)
                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1); 

                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 2);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 2);                      

                return ArrayMerge(ArrayMerge(ew, rnnw), rBike);   
            case 17: // 4 weak, 2 normals, 6 rares, 2 elite (2 ew + 2x rrnw + 2 rare bikes)
                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 2); 

                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 2);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 2);                      

                return ArrayMerge(ArrayMerge(ew, rnnw), rBike); 
            case 18: // 3 weak, 3 normals, 6 rares, 2 elite  (2 ew + 3x rrnw)
                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 3);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 2);                      

                return ArrayMerge(ew, rnnw); 
            case 19: // 7 weak, 3 normals, 6 rares, 2 elite (2 ew + 3x rrnw + wwww)
                let wwww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakSquad1",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad2",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad3",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad4"
                    ], 1); 

                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 3);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 2);             

                return ArrayMerge(ArrayMerge(ew, rnnw), wwww); 
            case 20: // 7 weak, 3 normals, 7 rares, 2 elite (2 ew + 3x rrnw + wwww + rare bike)
                let rBike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareBike1",
                        t"DynamicSpawnSystem.GRValentinoRareBike2",
                        t"DynamicSpawnSystem.GRValentinoRareBike3",
                        t"DynamicSpawnSystem.GRValentinoRareBike4",
                        t"DynamicSpawnSystem.GRValentinoRareBike5"
                    ], 1); 

                let wwww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoWeakSquad1",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad2",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad3",
                        t"DynamicSpawnSystem.GRValentinoWeakSquad4"
                    ], 1); 

                let rnnw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoRareSquad1",
                        t"DynamicSpawnSystem.GRValentinoRareSquad2",
                        t"DynamicSpawnSystem.GRValentinoRareSquad3",
                        t"DynamicSpawnSystem.GRValentinoRareSquad4",
                        t"DynamicSpawnSystem.GRValentinoRareSquad5"
                    ], 3);

                let ew = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRValentinoEliteSquad1",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad2",
                        t"DynamicSpawnSystem.GRValentinoEliteSquad3"
                    ], 2);             

                return ArrayMerge(ArrayMerge(ArrayMerge(ew, rnnw), wwww), rBike); 
            default: 
                return [];
        }
    }
}