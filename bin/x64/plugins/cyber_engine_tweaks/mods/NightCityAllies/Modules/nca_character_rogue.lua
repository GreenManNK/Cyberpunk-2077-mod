--
-- Adds Rogue  to NCA. 
-- She unlocks after the sudequest Chippin' In
--
-- GetMod("NightCityAllies"):UnlockConversation("nca_unlock_rogue_dialogue")
--
return {
    name = "NCA Rogue",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Rogue",
            record = "Character.Rogue",
            unlock="sq031_done",
            unlockConversation="nca_unlock_rogue_dialogue",
            appearance = 1,
            outfits = {
                casual = 3,
                mission = 1,
                home = 4,
                bed = 4
            }
        })
        
        NCA:RegisterConversation("nca_unlock_rogue_dialogue", "Character.Rogue", {
            {
                id = "start",
                textLines = {
                    "Been thinking about what went down on the Ebunike. And the oil fields after that. Let’s just say... some old ghosts finally got put to rest."
                },
                responses = {
                    { text = "That supposed to mean we're square?", next = "square" },
                    { text = "Johnny again?", next = "johnny", effect="friendship++" }
                }
            },
            {
                id = "johnny",
                textLines = {
                    "He was always a damn idiot.",
                    "But he had a talent for pulling the right people together."
                },
                responses = {
                    { text = "What are you getting at?", next = "debt" },
                    { text = "Yeah... sounds like him.", next = "debt", effect="friendship++" }
                }
            },
            {
                id = "square",
                textLines = {
                    "Square?",
                    "In Night City, no one’s ever square."
                },
                responses = {
                    { text = "Figured as much. Now what?", next = "debt" },
                    { text = "Then why message me?", next = "debt" }
                }
            },
            {
                id = "debt",
                textLines = {
                    "I still owe Johnny something. And since you're the one carrying him around, guess that means I owe you too.",
                    "Looked over the Ebunike recordings again. And honestly V?",
                    "My trigger finger hasn't stopped itching since."
                },
                responses = {
                    { text = "The queen of the Afterlife misses the smell of gunpowder?", next = "bored", effect="friendship++" },
                    { text = "You serious?", next = "bored" }
                }
            },

            {
                id = "bored",
                textLines = {
                    "Careful.",
                    "But yeah.",
                    "Being a fixer pays well but it's boring as hell.",
                    "Watching you out there, getting things done reminded me why I started all this in the first place."
                },
                responses = {
                    { text = "So what, you want back in?", next = "offer", effect="friendship++" },
                    { text = "Didn't think you'd miss it.", next = "offer", effect="friendship++" }
                }
            },
            {
                id = "offer",
                textLines = {
                    "Not really.",
                    "But won't hurt to make an exception once or twice, right?",
                    "Next time you kick a hornet's nest and need someone watching your back...",
                    "call me.",
                    "I'll show you how we used to do things."
                },
                responses = {
                    { text = "I could use some help right now.", next = "join", effect = "commute" },
                    { text = "I'll keep that in mind.", next = "ending" }
                }
            },
            {
                id = "join",
                textLines = {
                    "Knew you'd say that.",
                    "Let's see if I still remember how this feels.",
                    "Give me a minute."
                },
                responses = {}
            },
            {
                id = "ending",
                textLines = {
                    "Don't wait too long, V."
                },
                responses = {}
            }
        })
    end
}
