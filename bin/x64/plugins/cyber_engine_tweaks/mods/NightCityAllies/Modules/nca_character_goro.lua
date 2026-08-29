--
-- Adds Goro Takemura to NCA. 
-- He unlocks after q112_done
--
return {
    name = "NCA Goro",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Goro",
            record = "Character.Takemura",
            unlock="q112_done",
            unlockConversation="nca_unlock_takemura_dialogue",
            appearance = 0,
            outfits = {
                casual = 2,
                mission = 1,
                home = 0
            }
        })

        NCA:RegisterConversation("nca_unlock_takemura_dialogue", "Character.Takemura", {
            {
                id = "start",
                textLines = {
                    "V.",
                    "I hope this message does not disturb you."
                },
                responses = {
                    { text = "Not at all. What's going on?", next = "why", effect="friendship+++" },
                    { text = "Depends. Is this trouble?", next = "joke", effect="friendship+++" },
                }
            },
            {
                id = "joke",
                textLines = {
                    "In Night City there is always trouble.",
                    "But that is not why I write.",
                    "I wished to speak with you regarding a certain matter."
                },
                responses = {
                    { text = "Alright, I'm listening.", next = "explain" },
                    { text = "Make it quick.", next = "explain" }
                }
            },
            {
                id = "why",
                textLines = {
                    "You have proven yourself reliable.",
                    "This is a quality I respect.",
                    "If you should require assistance in your endeavors, I would offer mine."
                },
                responses = {
                    { text = "You're offering to help?", next = "explain" },
                    { text = "I could use help now.", next = "join", effect="commute" }
                }
            },
            {
                id = "explain",
                textLines = {
                    "Yes.",
                    "I am trained in combat and tactics.",
                    "Should danger arise, I would stand at your side."
                },
                responses = {
                    { text = "I'll remember that.", next = "ending" },
                    { text = "Then come join me.", next = "join", effect="commute" }
                }
            },
            {
                id = "join",
                textLines = {
                    "Understood.",
                    "Send me your location.",
                    "I will arrive shortly."
                },
                responses = {
                }
            },
            {
                id = "ending",
                textLines = {
                    "Very well.",
                    "Contact me if the situation changes.",
                    "Stay vigilant, V."
                },
                responses = {
                }
            }
        })
    end
}
