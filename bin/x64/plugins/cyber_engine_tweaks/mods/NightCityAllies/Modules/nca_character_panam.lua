--
-- Adds Panam to NCA.
-- She unlocks helping her in "Life During Wartime". (q104_done)
--
return {
    name = "NCA Panam",
    author = "NCA",
    load = function(NCA)
        NCA:RegisterCharacter({
            --name = "Panam",
            record = "Character.Panam",
            unlock = "q104_done",
            unlockConversation = "nca_unlock_panam_dialogue",
            appearance = 0,
            outfits = {
                casual = 0,
                mission = 0,
                home = 3,
                bed = 13,
                shower = 5
            }
        })

        NCA:RegisterConversation("nca_unlock_panam_dialogue", "Character.Panam", {
            {
                id = "start",
                textLines = {
                    "V, you there? Wanted to say thanks."
                },
                responses = {
                    { text = "For what?", next = "why", effect="friendship+++" },
                    { text = "Always a pleasure.", next = "joke", effect="friendship+++" }
                }
            },
            {
                id = "joke",
                textLines = {
                    "You didn't even hear what I had to say yet!",
                    "Comedian",
                    "Seriously though. What you did for me meant a lot. If you ever need backup yourself, just say the word. I can swing by."
                },
                responses = {
                    { text = "Backup?", next = "explain" },
                    { text = "Then come join me.", next = "join", effect = "commute" },
                    { text = "Not a good time right now.", next = "ending" }
                }
            },
            {
                id = "why",
                textLines = {
                    "For helping me out, dummy.",
                    "You're someone I can actually rely on. That's rare.",
                    "So if you ever need help with something, just call."
                },
                responses = {
                    { text = "What do you mean?", next = "explain" },
                    { text = "Come join me now!", next = "join", effect = "commute" },
                }
            },
            {
                id = "explain",
                textLines = {
                    "Means I can watch your back sometimes.",
                    "Don't hesitate to ask allright? I know how to hold a rifle so don't hesitate. If you call, I'll show up."
                },
                responses = {
                    { text = "I'll keep that in mind.", next = "ending" },
                    { text = "How about now?", next = "join", effect = "commute" }
                }
            },
            {
                id = "join",
                textLines = {
                    "Heh. Thought you'd never ask.",
                    "Be there in 5"
                },
                responses = {
                }
            },
            {
                id = "ending",
                textLines = {
                    "Anyway.",
                    "Hit me up whenever you need help.",
                    "...just maybe not at 3AM, alright?"
                },
                responses = {
                    { text = "Got it. Thanks Panam.", next = "end" }
                }
            }
        })
    end
}