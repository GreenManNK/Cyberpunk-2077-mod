--
-- Adds Misty to NCA. 
-- She unlocks after sq018_done
--
return {
    name = "NCA Misty",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Misty",
            record = "Character.Misty",
            unlock="sq018_03_done",
            unlockConversation="nca_unlock_misty_dialogue",
            appearance = 0
        })

        NCA:RegisterConversation("nca_unlock_misty_dialogue", "Character.Misty", {
            {
                id = "start",
                textLines = {
                    "Hey V. Can we meet?"
                },
                responses = {
                    { text = "Hey Misty what's wrong, something happen? ", next = "why", effect = "friendship+++" },
                    { text = "Always.", next = "yes", effect = "friendship+" }
                }
            },
            {
                id = "why",
                textLines = {
                    "No, nothing happened.",
                    "It's just ...",
                    "You know, since Jackie's gone, I feel like I don't have anyone to talk to.",
                    "I know you have your own problems, but I just wanted to see if we could hang out for a bit.",
                    "I don't want to be a burden, just need to get out of the apartment for a while.",
                    "If you're busy, I understand. I just wanted to ask."
                },
                responses = {
                    { text = "Of course Misty, I'm here for you.", next = "yes" },
                    { text = "Now is not a good time, but we can hang out later.", next = "end" }
                }
            },
            {
                id = "yes",
                textLines = {
                    "Thanks I can really use some company right now.",
                    "Coming to you okay?"
                },
                responses = {
                    { text = "Sure", next = "end", effect = "commute" }
                }
            }
        })
    end
}
