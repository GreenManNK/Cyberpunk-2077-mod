--
-- Adds Jackie to NCA. After the Rescue quest the unlock conversation is shown which turns Jackie into an NCA companion.
-- After the Heist mission Jackie gets locked away. (q001_done - q005_done)
--
return {
    name = "NCA Jackie",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Jackie",
            record = "Character.Jackie",
            unlock="q001_done",
            lock="q005_done",
            unlockConversation="nca_unlock_jackie_dialogue",
            appearance = 0,
            outfits = {
                casual = 0,
                mission = 3,
                home = 12
            }
        })

        NCA:RegisterConversation("nca_unlock_jackie_dialogue", "Character.Jackie", {
            {
                id = "start",
                textLines = {
                    "V! Just had a thought, choom.",
                    "You know you can call me whenever you need backup, right?"
                },
                responses = {
                    { text = "Of course, Jackie.", next = "yes", effect = "friendship+++" },
                    { text = "Appreciate it, man.", next = "yes", effect = "friendship+++" }
                }
            },
            {
                id = "yes",
                textLines = {
                    "Seriously V",
                    "Feels like I only see you when the job's huge and the bullets start flying",
                    "Just saying shoot me a message anytime and I roll out",
                    "Or are you planning to conquer Night City without your hermano?"
                },
                responses = {
                    { text = "Thanks, Jackie.", next = "end" },
                    { text = "How about right now?", next = "now", effect = "commute" }
                }
            },
            {
                id = "now",
                textLines = {
                    "Ha! Now we're talking!",
                    "Let me tell Misty I'll be out for a bit.",
                    "Be there before you can say 'major league', V."
                },
                responses = {
                    { text = "Nova.", next = "end" }
                }
            }
        })
    end
}

-- sq_q001_tbug = The Gift