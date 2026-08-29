--
-- Adds Royce and Brick
-- Brick only unlocks when brick is saved & royce dead bc royce kills him later when both live
--
return{
    name = "NCA Maelstrom - Royce and Brick",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({name = "Brick", record = "Character.Brick", locked=true, type="mercenary", rarity="elite"})
        NCA:RegisterCharacter({name = "Royce", record = "Character.Royce", locked=true, type="mercenary", rarity="elite"})
        NCA:On("QuestComplete", function()
            if NCA:CheckQuest("q003_royce_dead") then
                NCA:LockCharacter("Character.Royce")

                if NCA:CheckQuest("q003_brick_saved") then
                    NCA:MakeHireable("Character.Brick")
                    return true --resolve
                end
            elseif NCA:CheckQuest("q003_deal_peaceful") or NCA:CheckQuest("q003_royce_left_deal") then
                NCA:MakeHireable("Character.Royce")
                return true --resolve
            end
        end)
    end
}

--q003_royce_left_deal
--q003_royce_dead
--q003_deal_peaceful
--q003_brick_found
--q003_brick_dead
--q003_brick_saved
