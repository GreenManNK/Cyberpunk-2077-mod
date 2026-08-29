--
-- Adds Kerry to NCA. 
-- He unlocks after "Holdin' On" (sq028_done)
--
return {
    name = "NCA Kerry",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Kerry",
            record = "Character.Kerry",
            locked = true,
            appearance = 14,
            outfits = {
                casual = 14,
                mission = 11,
                home = 10,
                bed = 7,
                shower = 20
            }
        })
        
        -- sth is wrong with sq028_done which would be the end of Kerrys questchain
        -- try match some more quests just in case the bug occurs
        NCA:On("QuestComplete", function()
            if NCA:CheckQuest("sq011_done")
            and NCA:CheckQuest("sq017_done")
            and NCA:CheckQuest("sq028_done")
            then
                NCA:UnlockConversation("nca_unlock_kerry_dialogue")
                NCA:SetConversationImportant("nca_unlock_kerry_dialogue")
                return true -- resolve (= delete the callback)
            end
        end)

        NCA:On("ConversationFinished", function(id)
            if NameToString(id) == "nca_unlock_kerry_dialogue" then
                NCA:UnlockCharacter("Character.Kerry")
                return true -- resolve
            end
        end)
        
        NCA:RegisterConversation("nca_unlock_kerry_dialogue", "Character.Kerry", {
            {
                id = "start",
                textLines = {
                    "V.",
                    "You busy?"
                },
                responses = {
                    { text = "Depends. What's up?", next = "why", effect="friendship+++" },
                    { text = "For you? Never.", next = "joke", effect="friendship+++" }
                }
            },
            {
                id = "joke",
                textLines = {
                    "Ha. Careful, I'll start believing that.",
                    "Actually got a reason for messaging.",
                    "Been stuck in meetings with suits all day.",
                    "Need a break before I lose my damn mind."
                },
                responses = {
                    { text = "Sounds rough.", next = "explain" },
                    { text = "Want to get out of there?", next = "join", effect = "commute" },
                    { text = "Maybe later.", next = "ending" }
                }
            },
            {
                id = "why",
                textLines = {
                    "Just needed to talk to someone normal for a minute.",
                    "Well... normal-ish.",
                    "Anyway, figured if you're getting into trouble somewhere I could tag along."
                },
                responses = {
                    { text = "You? Looking for trouble?", next = "explain" },
                    { text = "Sure, come join me.", next = "join", effect = "commute" }
                }
            },
            {
                id = "explain",
                textLines = {
                    "Hey, I'm still a rockerboy.",
                    "Chaos is part of the job description.",
                    "Besides, hanging with you beats another hour with my manager."
                },
                responses = {
                    { text = "Alright, I'll keep that in mind.", next = "ending" },
                    { text = "Then come along.", next = "join", effect = "commute" }
                }
            },
            {
                id = "join",
                textLines = {
                    "Hell yeah.",
                    "Give me a minute and I'll swing by."
                },
                responses = {
                }
            },
            {
                id = "ending",
                textLines = {
                    "Anyway.",
                    "If you end up doing something interesting, call me.",
                    "Could use the inspiration."
                },
                responses = {
                }
            }
        })
    end
}
