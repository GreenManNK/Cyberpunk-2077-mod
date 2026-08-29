--
-- Adds River to NCA. 
-- He unlocks after "Following the River" (sq021_done)
--
return {
    name = "NCA River",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "River",
            record = "Character.Sobchak",
            unlock="sq021_done",
            unlockConversation="nca_unlock_river_dialogue",
            appearance = 0,
            outfits = {
                casual = 0,
                mission = 0,
                home = 1,
                bed = 3,
                shower = 5
            }
        })

        NCA:RegisterConversation("nca_unlock_river_dialogue", "Character.Sobchak", {
            {
                id = "start",
                textLines = {
                    "Hey V.",
                    "Been thinking about something."
                },
                responses = {
                    { text = "What's up?", next = "why", effect="friendship+++" },
                    { text = "That sounds ominous.", next = "joke", effect="friendship+++" }
                }
            },
            {
                id = "joke",
                textLines = {
                    "Relax. Nothing bad.",
                    "Just wanted to say I owe you one.",
                    "You helped me when things got rough. I don't forget that."
                },
                responses = {
                    { text = "You don't owe me anything.", next = "explain" },
                    { text = "Actually I could use help now.", next = "join", effect = "commute" },
                    { text = "Another time maybe.", next = "ending" }
                }
            },
            {
                id = "why",
                textLines = {
                    "For everything you did.",
                    "For Randy. For my family.",
                    "Means more than you probably realize."
                },
                responses = {
                    { text = "Just doing the right thing.", next = "explain" },
                    { text = "If you're offering help, I'll take it.", next = "join", effect = "commute" }
                }
            },
            {
                id = "explain",
                textLines = {
                    "Point is...",
                    "If you're heading into trouble and need someone watching your back",
                    "give me a call.",
                    "I'm pretty good in a fight."
                },
                responses = {
                    { text = "I'll remember that.", next = "ending" },
                    { text = "Then come help me now.", next = "join", effect = "commute" }
                }
            },
            {
                id = "join",
                textLines = {
                    "Alright.",
                    "Send me the location. I'll head over."
                },
                responses = {
                }
            },
            {
                id = "ending",
                textLines = {
                    "Take care out there, V.",
                    "Night City's not getting any safer."
                },
                responses = {
                }
            }
        })
    end
}
