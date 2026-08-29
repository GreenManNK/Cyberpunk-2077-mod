--
-- Adds Judy to NCA. 
-- She unlocks after the last Evelyn mission. (q105_done)
--
return {
    name = "NCA Judy",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Judy",
            record = "Character.Judy",
            unlock="q105_done",
            unlockConversation="nca_unlock_judy_dialogue",
            appearance = 0,
            outfits = {
                casual = 0,
                bed = 4,
                home = 13,
                mission = 2,
                shower = 10
            }
        })
        
        NCA:RegisterConversation("nca_unlock_judy_dialogue", "Character.Judy", {
            {
                id = "start",
                textLines = {
                    "I'm bored!"
                },
                responses = {
                    { text = "Okay...?", next = "ask" },
                    { text = "Same here.", next = "yes", effect="friendship+++" }
                }
            },
            {
                id = "ask",
                textLines = {
                    "c1an we like",
                    "you know, hang out?",
                    "*can",
                    "...",
                    "unless you're busy",
                    "ignore me if this is weird"
                },
                responses = {
                    { text = "Not weird. Let's hang.", next = "yes", effect="friendship+++" },
                    { text = "You okay?", next = "ask2" },
                    { text = "Later, I'm busy.", next = "no" }
                }
            },
            {
                id = "ask2",
                textLines = {
                    "yeah just",
                    "trying to be social or whatever",
                    "come on don't make me look awkward now",
                    "need a break from these BDs before my brain melts",
                    "sooo?"
                },
                responses = {
                    { text = "Sure, sounds good.", next = "yes", effect="friendship+++" },
                    { text = "Later, I'm busy.", next = "no" }
                }
            },
            {
                id = "yes",
                textLines = {
                    ":D",
                    "nice",
                    "what are you doing can I tag along?"
                },
                responses = {
                    { text = "Always", next = "join", effect = "commute" },
                    { text = "Actually, I'm busy now", next = "no" }
                }
            },
            {
                id = "no",
                textLines = {
                    "ah, gotcha",
                    "no worries",
                    "ping me when you feel like hanging out, yeah?"
                },
                responses = {
                    { text = "Soon as I'm done here!", next = "end" },
                    { text = "Will do.", next = "end" }
                }
            },
            {
                id = "join",
                textLines = {
                    "cool",
                    "be there in a minute"
                },
                responses = {
                }
            }
        })
    end
}