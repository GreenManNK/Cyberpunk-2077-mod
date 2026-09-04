local messages = require("modules/messages")

local lang = {
    ["en-us"] = {
        Ending = {
            "Thanks, V. I needed that.",
            "Thank you, V. I needed that.",
            "Thanks, V — that was exactly what I needed.",
            "Thank you, V — that helped.",
            "Thanks, V. That meant a lot.",
            "Thank you, V. That meant a lot.",
            "Thanks, V. I really needed that.",
            "Thank you, V. I really needed that.",
            "Thanks, V. I needed that so much.",
            "Thank you, V. I needed that so much.",
            "Thanks, V. I needed that, truly.",
            "Thank you, V. I needed that, truly.",
            "Thanks, V. I needed that — for real.",
            "Thank you, V. I needed that — for real.",
            "Thanks, V. That hit the spot.",
            "Thank you, V. That hit the spot.",
            "Thanks, V. That helped more than you know.",
            "Thank you, V. That helped more than you know.",
            "Thanks, V. I appreciate this.",
            "Thank you, V. I appreciate this."
        },
        BeachPreJoin = {
            "Hey V. Before you join me, can you grab some drinks from my trunk?",
            "Quick favor, V — before you join me, grab some drinks from my trunk.",
            "Before you head over, can you snag some drinks from my trunk?",
            "Hey. Before you join me, mind grabbing some drinks from my trunk?",
            "V, grab some drinks from my trunk before you come over?",
            "Before you roll up, can you pull some drinks from my trunk?",
            "Small ask: grab some drinks from my trunk before you join.",
            "Hey V, quick pit stop — trunk has the drinks. Grab them?",
            "Before you join me, swing by my trunk and grab the drinks.",
            "V, trunk’s got the drinks. Can you grab them before you come?"
        },
        Autofix = {
            "Hey V. I am at The Red Dirt. If you want, you can swing by.",
            "I am heading to The Red Dirt to lay low. Join me if you want.",
            "Hey. I am at The Red Dirt. You can swing by if you want.",
            "V. The Red Dirt. Quiet booth. If you feel like it, swing by.",
            "Needed to breathe. I am at The Red Dirt. Swing by if you want.",
            "I wanted something calm. I am at The Red Dirt. If you want, you can swing by.",
            "Spending some time at The Red Dirt. If you want, you can swing by.",
            "No rush. No job. Just The Red Dirt. Swing by if you want."
        },
        AutofixReplies = {
            "Yeah, I get why you’d want another take on it. Custom work can feel different once it’s moving. I might swing by.",
            "Sounds like you put real time into it. A second opinion never hurts. I’ll see if I can drop in.",
            "Makes sense not trusting just your own feel. I might come by and take a look.",
            "That kind of tuning usually needs a real run. I’ll see if I can swing by near Dakota.",
            "Yeah, I get the ask. Testing it properly matters. I might stop by if I’m nearby.",
            "Sounds like something worth checking. I’ll keep it in mind and maybe swing by.",
            "I trust your work, but I get wanting feedback. I might drop in for a bit.",
            "Custom add-ons always change the balance. I’ll see if I can come by and feel it out.",
            "That kind of work deserves a clean test. I might swing by when I’ve got a minute.",
            "Yeah, I get why you’d want another set of hands. I’ll see if I can stop by."
        },
        Panamdirttext = {
            "Hey V. I already placed our order. It's on the other counter, far end by the bartender — on your tab ;P",
            "Hey V. Order's in. Other counter, far end by the bartender — on your tab ;P",
            "Hey V. Got our order placed. It's waiting on the other counter, far end — on your tab ;P",
            "Hey V. Our order's set. Check the other counter at the far end by the bartender — on your tab ;P",
            "Yo V. Already put in our order. Other counter, far end by the bartender — on your tab ;P",
            "V, order's already placed. It's on the other counter, far end near the bartender — on your tab ;P",
            "Hey V. I put the order in. Other counter, far end by the bartender — on your tab ;P",
            "V. Order's done. Other counter, far end — bartender side — on your tab ;P",
            "Hey V. Already queued our order. It's on the other counter, far end by the bartender — on your tab ;P",
            "V, I already placed our order. Other counter, far end by the bartender — on your tab ;P"
        },
        Shootingrange = {
            "Hey V. I am setting up some targets near camp. If you want, you can swing by.",
            "Got some time for target practice near camp. Swing by if you feel like it.",
            "I am out by camp putting rounds on targets. If you want to join, you can swing by.",
            "Doing some shooting practice near camp. If you want in, swing by.",
            "I am lining up targets outside camp. You can swing by if you want to keep sharp.",
            "Got targets up near camp. If you feel like shooting, swing by.",
            "I am spending some time on the range near camp. You can swing by if you want.",
            "Setting up a few targets near camp. No rush. Swing by if you feel like it.",
            "Out near camp working on my aim. If you are around, you can swing by.",
            "I am by camp doing target practice. Swing by if you want to shoot."
        },
        ShootingRangeReplies = {
            "Yeah, practice never hurts. I might swing by if I’m free.",
            "Sounds like a good way to stay sharp. I’ll see if I can drop in.",
            "Range time clears the head. I might come by for a bit.",
            "That kind of routine makes sense. I’ll keep it in mind.",
            "Targets don’t lie. I might swing by if I’m nearby.",
            "Always room to tighten things up. I’ll see how the timing looks.",
            "Sounds steady. I might stop by and put a few rounds down.",
            "Yeah, I get the appeal. I’ll think about it.",
            "Practice like that adds up. I might come by for a bit.",
            "That sounds low-pressure enough. I’ll see if I can swing by."
        },
        Beach = {
            "Hey V. I am heading to Coast View beach in Pacifica. If you want, you can swing by.",
            "V. I am by the water at Coast View. If you feel like it, you can swing by.",
            "I needed a break from the city. I am at the beach in Coast View, Pacifica. Swing by if you want.",
            "I set aside some time at Coast View beach. If you want to join me, you can swing by.",
            "Pacifica tonight. Coast View beach. If you want company, swing by.",
            "Hey. I am heading to the beach in Coast View. You can swing by if you want.",
            "V. Coast View. By the water. Swing by if you feel like disappearing for a bit.",
            "I wanted something quiet. I am at the Coast View beach in Pacifica. Swing by if you want.",
            "I am spending some time at Coast View beach tonight. If you want, you can swing by.",
            "No rush. No job. Just Coast View beach. Swing by if you want."
        },
        BeachReplies = {
            "Yeah, I get needing space from the city. I might swing by later.",
            "Coast View does that to people. I’ll see if I can drop in.",
            "Quiet by the water sounds right. I might come by for a bit.",
            "That kind of night has its pull. I’ll keep it in mind.",
            "Pacifica hits different after dark. I might swing by.",
            "Sounds calm enough to be worth it. I’ll see how the night goes.",
            "Yeah, disappearing for a bit sounds good. I might stop by.",
            "I get wanting something low-key. I’ll think about coming down.",
            "Water usually helps clear things out. I might swing by later.",
            "No rush sounds good. I’ll see if I end up there."
        },
        panamcampfire = {
            "Hey V, let's make a campfire. Grab some branches.",
            "Hey V, want to make a campfire? Grab some branches.",
            "Hey V, let's build a campfire — can you grab some branches?",
            "Hey V, campfire time. Grab some branches.",
            "Hey V, help me make a campfire. Grab some branches.",
            "Hey V, let's get a campfire going. Grab some branches.",
            "Hey V, up for a campfire? Grab some branches.",
            "Hey V, let's light a campfire — grab some branches.",
            "Hey V, I’ll set the spot; you grab some branches.",
            "Hey V, meet me by the pit and grab some branches.",
            "Hey V, I’ll handle the fire, you get the branches.",
            "Hey V, we’re making a campfire — can you grab branches?",
            "Hey V, grab some branches; let’s make a campfire.",
            "Hey V, let’s do a campfire. Bring branches.",
            "Hey V, quick favor — grab some branches for a campfire."
        },
        panamshooting = {
            "V, get into position.",
            "V, move into position.",
            "V, take up your position.",
            "V, get in position, now.",
            "V, set up in position."
        },
        panamcarm1 = {
            "Hey V, spin it around — let’s see what this beast can do.",
            "Give it a whirl, V; I want to feel this power.",
            "Take it for a spin, V — show me the punch it’s got.",
            "Spin her up, V; let’s test how strong she pulls.",
            "Let’s see the muscle, V — give the ride a good spin.",
            "Take her around the block, V; I want to hear her roar.",
            "Roll it out, V — let’s taste the torque on this thing.",
            "Fire it up and spin, V; show me the power under the hood.",
            "Put your foot down, V — let’s see this beast wake up.",
            "One quick spin, V; I want to feel how hard she kicks."
        },
        panamcarm2 = {
            "Okay, V — thanks! You can head back.",
            "Nice run. Thanks, V; you can head back now.",
            "That’s plenty. Thanks, V — head back when ready.",
            "Perfect. Thanks, V; you can bring it back.",
            "That’ll do. Thanks, V — go ahead and head back.",
            "Looks good. Thanks, V; you can return now.",
            "That’s enough. Thanks, V — you can head back.",
            "Good stuff. Thanks, V; bring it back in.",
            "Got it. Thanks, V — you can head back now.",
            "We’re set. Thanks, V; you can head back."
        },

        waittime = {
            "V, had to bounce. We'll catch up another time.",
            "V, couldn't wait forever. Let's do this again.",
            "V, I'm gone. No hard feelings, yeah?",
            "V, had to take off. Next time."
        },

        -- UI Strings
        ["ui_coastview"] = "Coastview",
        ["ui_grab_picnic"] = "Grab the picnic supplies",
        ["ui_prepare_meat"] = "Prepare the meat",
        ["ui_join_panam"] = "Join Panam",
        ["ui_practice"] = "Practice Makes Perfect",
        ["ui_gather_branches"] = "Gather branches",
        ["ui_campfire"] = "Campfire",
        ["ui_build_campfire"] = "Build a camp fire",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "Buy drinks (50.00)",
        ["ui_place_drink"] = "Place the drink",
        ["ui_watch_performance"] = "Watch Live Performance",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Enjoy the performance",
        ["ui_end_date"] = "End the Date",
        ["ui_meet_panam_caption"] = "PanamDate|Meet Panam|Panam is waiting for you",
        ["ui_shooting_title"] = "Practice Makes Perfect",
        ["ui_short_range"] = "Short range",
        ["ui_long_range"] = "Long range",
        ["ui_cook_meat"] = "Cook the meat",

        ["contactName"] = "Panam Palmer"
    },
	
["fr-fr"] = {
    Ending = {
        "Merci, V. J’en avais besoin.",
        "Merci, V. Ça m’a fait du bien.",
        "Merci, V — c’était exactement ce qu’il me fallait.",
        "Merci, V — ça m’a aidée.",
        "Merci, V. Ça comptait beaucoup pour moi.",
        "Merci, V. Ça compte vraiment.",
        "Merci, V. J’en avais vraiment besoin.",
        "Merci, V. Ça m’a vraiment aidée.",
        "Merci, V. J’en avais tellement besoin.",
        "Merci, V. Ça m’a tellement aidée.",
        "Merci, V. J’en avais besoin, vraiment.",
        "Merci, V. Vraiment.",
        "Merci, V. J’en avais besoin — pour de vrai.",
        "Merci, V. Pour de vrai.",
        "Merci, V. Ça a fait mouche.",
        "Merci, V. En plein dans le mille.",
        "Merci, V. Ça m’a aidée plus que tu ne le crois.",
        "Merci, V. Plus que tu ne l’imagines.",
        "Merci, V. J’apprécie vraiment.",
        "Merci, V. Je t’en suis reconnaissante."
    },

    BeachPreJoin = {
        "Hé V. Avant de me rejoindre, tu peux prendre quelques boissons dans mon coffre ?",
        "Petit service, V — avant de me rejoindre, prends quelques boissons dans mon coffre.",
        "Avant d’arriver, tu peux récupérer des boissons dans mon coffre ?",
        "Hé. Avant de me rejoindre, ça te dérange de prendre des boissons dans mon coffre ?",
        "V, prends des verres dans mon coffre avant d’arriver ?",
        "Avant d’arriver, tu peux sortir des verres de mon coffre ?",
        "Petite demande : prends des boissons dans mon coffre avant de me rejoindre.",
        "Hé V, arrêt rapide — les boissons sont dans le coffre. Tu les prends ?",
        "Avant de me rejoindre, passe par mon coffre et prends les boissons.",
        "V, les verres sont dans le coffre. Tu peux les prendre avant d’arriver ?"
    },

    Autofix = {
        "Hé V. Je suis au Red Dirt. Si tu veux, passe me voir.",
        "Je vais au Red Dirt pour me poser un peu. Rejoins-moi si tu veux.",
        "Hé. Je suis au Red Dirt. Tu peux passer si tu veux.",
        "V. Red Dirt. Coin tranquille. Passe si ça te dit.",
        "J’avais besoin de respirer. Je suis au Red Dirt. Passe si tu veux.",
        "Je voulais quelque chose de calme. Je suis au Red Dirt. Passe si tu veux.",
        "Je passe un peu de temps au Red Dirt. Passe si tu veux.",
        "Pas de pression. Pas de boulot. Juste le Red Dirt. Passe si tu veux."
    },

    AutofixReplies = {
        "Ouais, je comprends que tu veuilles un autre avis. Le boulot custom change quand ça roule. Je passerai peut-être.",
        "On dirait que t’y as vraiment mis du temps. Un second avis ne fait jamais de mal. Je verrai si je peux passer.",
        "C’est logique de ne pas se fier qu’à son ressenti. Je passerai peut-être jeter un œil.",
        "Ce genre de réglage a besoin d’un vrai test. Je verrai si je peux passer près de Dakota.",
        "Ouais, je comprends. Tester correctement, c’est important. Je passerai peut-être si je suis dans le coin.",
        "Ça a l’air de valoir le coup d’œil. Je garde ça en tête et je passerai peut-être.",
        "J’ai confiance en ton taf, mais je comprends le besoin de retours. Je passerai peut-être un moment.",
        "Les ajouts custom changent toujours l’équilibre. Je verrai si je peux passer et me faire une idée.",
        "Ce genre de boulot mérite un test propre. Je passerai peut-être quand j’aurai une minute.",
        "Ouais, je comprends pourquoi tu veux une autre paire de mains. Je verrai si je peux passer."
    },

    Panamdirttext = {
        "Hé V. J’ai déjà passé la commande. C’est à l’autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "Hé V. Commande passée. Autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "Hé V. J’ai passé la commande. Elle t’attend à l’autre comptoir, tout au fond — sur ton compte ;P",
        "Hé V. La commande est prête. Regarde à l’autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "Yo V. J’ai déjà commandé. Autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "V, la commande est déjà faite. À l’autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "Hé V. J’ai passé la commande. Autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "V. Commande faite. Autre comptoir, tout au fond — côté barman — sur ton compte ;P",
        "Hé V. J’ai déjà lancé la commande. À l’autre comptoir, tout au fond près du barman — sur ton compte ;P",
        "V, j’ai déjà passé la commande. Autre comptoir, tout au fond près du barman — sur ton compte ;P"
    },

    Shootingrange = {
        "Hé V. Je mets des cibles près du camp. Passe si tu veux.",
        "J’ai un peu de temps pour tirer près du camp. Passe si ça te dit.",
        "Je suis près du camp à tirer sur des cibles. Passe si tu veux te joindre.",
        "Je fais un peu d’entraînement au tir près du camp. Passe si tu veux.",
        "J’aligne des cibles à l’extérieur du camp. Passe si tu veux rester affûté.",
        "Les cibles sont prêtes près du camp. Passe si tu veux tirer.",
        "Je passe un moment au stand près du camp. Passe si tu veux.",
        "Je mets quelques cibles près du camp. Pas de pression. Passe si tu veux.",
        "Je suis près du camp à travailler ma précision. Passe si tu es dans le coin.",
        "Je suis au camp pour m’entraîner au tir. Passe si tu veux tirer."
    },

    ShootingRangeReplies = {
        "Ouais, s’entraîner ne fait jamais de mal. Je passerai peut-être si je suis libre.",
        "Ça a l’air d’un bon moyen de rester affûté. Je verrai si je peux passer.",
        "Le stand aide à se vider la tête. Je passerai peut-être un moment.",
        "Ce genre de routine a du sens. Je garde ça en tête.",
        "Les cibles ne mentent pas. Je passerai peut-être si je suis dans le coin.",
        "Il y a toujours moyen d’améliorer. Je verrai niveau timing.",
        "Ça a l’air tranquille. Je passerai peut-être tirer quelques balles.",
        "Ouais, je vois l’intérêt. J’y réfléchirai.",
        "Ce genre de pratique paie. Je passerai peut-être un moment.",
        "Ça a l’air assez détendu. Je verrai si je peux passer."
    },

    Beach = {
        "Hé V. Je vais à la plage de Coast View à Pacifica. Passe si tu veux.",
        "V. Je suis près de l’eau à Coast View. Passe si ça te dit.",
        "J’avais besoin de m’éloigner de la ville. Je suis à la plage de Coast View, à Pacifica. Passe si tu veux.",
        "Je me suis réservé du temps à la plage de Coast View. Passe si tu veux me rejoindre.",
        "Pacifica ce soir. Plage de Coast View. Passe si tu veux de la compagnie.",
        "Hé. Je vais à la plage de Coast View. Passe si tu veux.",
        "V. Coast View. Près de l’eau. Passe si tu veux disparaître un moment.",
        "Je voulais quelque chose de calme. Je suis à la plage de Coast View, à Pacifica. Passe si tu veux.",
        "Je passe un moment ce soir à la plage de Coast View. Passe si tu veux.",
        "Pas de pression. Pas de boulot. Juste Coast View. Passe si tu veux."
    },

    BeachReplies = {
        "Ouais, je comprends le besoin de s’éloigner de la ville. Je passerai peut-être plus tard.",
        "Coast View a cet effet-là. Je verrai si je peux passer.",
        "Calme, près de l’eau… ça sonne bien. Je passerai peut-être un moment.",
        "Ce genre de nuit a quelque chose. Je garde ça en tête.",
        "Pacifica est différente après la tombée de la nuit. Je passerai peut-être.",
        "Ça a l’air assez calme pour valoir le coup. Je verrai comment la soirée se passe.",
        "Ouais, disparaître un moment, ça me parle. Je passerai peut-être.",
        "Je comprends l’envie de quelque chose de posé. Je verrai si je descends.",
        "L’eau aide à clarifier les choses. Je passerai peut-être plus tard.",
        "Pas de pression, j’aime bien. Je verrai si je finis par y aller."
    },

    panamcampfire = {
        "Hé V, faisons un feu de camp. Prends des branches.",
        "Hé V, ça te dit un feu de camp ? Prends des branches.",
        "Hé V, construisons un feu de camp — tu peux prendre des branches ?",
        "Hé V, c’est l’heure du feu de camp. Prends des branches.",
        "Hé V, aide-moi à faire un feu de camp. Prends des branches.",
        "Hé V, lançons un feu de camp. Prends des branches.",
        "Hé V, partant pour un feu de camp ? Prends des branches.",
        "Hé V, allumons un feu de camp — prends des branches.",
        "Hé V, je prépare l’endroit ; toi, prends les branches.",
        "Hé V, retrouve-moi près du foyer et prends des branches.",
        "Hé V, je m’occupe du feu, toi des branches.",
        "Hé V, on fait un feu de camp — tu peux prendre des branches ?",
        "Hé V, prends des branches ; faisons un feu de camp.",
        "Hé V, feu de camp. Apporte des branches.",
        "Hé V, petit service — prends des branches pour le feu."
    },

    panamshooting = {
        "V, en position.",
        "V, mets-toi en position.",
        "V, prends position.",
        "V, en position, maintenant.",
        "V, place-toi en position."
    },

    panamcarm1 = {
        "Hé V, fais un tour — voyons ce que cette bête a dans le ventre.",
        "Fais-la tourner, V ; je veux sentir la puissance.",
        "Emmène-la faire un tour, V — montre-moi ce qu’elle a dans le ventre.",
        "Fais-la rugir, V ; testons sa traction.",
        "Montre-moi ses muscles, V — fais un vrai tour.",
        "Fais le tour du bloc, V ; je veux l’entendre rugir.",
        "Sors-la, V — je veux sentir le couple.",
        "Démarre et fais un tour, V ; montre-moi la puissance sous le capot.",
        "Appuie, V — réveillons la bête.",
        "Un petit tour, V ; je veux sentir comment elle pousse."
    },

    panamcarm2 = {
        "Ok, V — merci ! Tu peux revenir.",
        "Beau tour. Merci, V ; tu peux revenir maintenant.",
        "Ça suffit. Merci, V — reviens quand tu veux.",
        "Parfait. Merci, V ; ramène-la.",
        "Ça ira. Merci, V — tu peux revenir.",
        "Ça a l’air bon. Merci, V ; tu peux revenir.",
        "C’est bon. Merci, V — tu peux revenir.",
        "Bien vu. Merci, V ; ramène-la.",
        "Reçu. Merci, V — tu peux revenir maintenant.",
        "On est bons. Merci, V ; tu peux revenir."
    },

    waittime = {
        "V, j'ai dû décoller. La prochaine fois, d'accord?",
        "V, j'ai pas pu attendre éternellement. On essaye un autre jour.",
        "V, faut que je me tire. Pas de rancœur.",
        "V, je me suis cassée. On se reparle quand même."
    },

    -- UI Strings
    ["ui_coastview"] = "Côte Vue",
    ["ui_grab_picnic"] = "Prendre le pique-nique",
    ["ui_prepare_meat"] = "Préparer la viande",
    ["ui_join_panam"] = "Rejoindre Panam",
    ["ui_practice"] = "La Pratique Rend Parfait",
    ["ui_gather_branches"] = "Ramasser des branches",
    ["ui_campfire"] = "Feu de camp",
    ["ui_build_campfire"] = "Construire un feu de camp",
    ["ui_autofix"] = "Autofix",
    ["ui_buy_drinks"] = "Acheter des verres (50,00)",
    ["ui_place_drink"] = "Placer le verre",
    ["ui_watch_performance"] = "Regarder le spectacle",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "Profiter du spectacle",
    ["ui_end_date"] = "Terminer la sortie",
    ["ui_meet_panam_caption"] = "PanamDate|Rencontrer Panam|Panam t'attend",
    ["ui_shooting_title"] = "La Pratique Rend Parfait",
    ["ui_short_range"] = "Courte portée",
    ["ui_long_range"] = "Longue portée",
    ["ui_cook_meat"] = "Préparer la viande",

    ["contactName"] = "Panam Palmer"
},

["es-es"] = {
    Ending = {
        "Gracias, V. Lo necesitaba.",
        "Gracias, V. Me hacía falta.",
        "Gracias, V — era justo lo que necesitaba.",
        "Gracias, V — me ayudó.",
        "Gracias, V. Significó mucho para mí.",
        "Gracias, V. De verdad significó mucho.",
        "Gracias, V. Lo necesitaba de verdad.",
        "Gracias, V. Me ayudó de verdad.",
        "Gracias, V. Lo necesitaba muchísimo.",
        "Gracias, V. Me hacía muchísima falta.",
        "Gracias, V. Lo necesitaba, de verdad.",
        "Gracias, V. De verdad.",
        "Gracias, V. Lo necesitaba — en serio.",
        "Gracias, V. En serio.",
        "Gracias, V. Dio justo en el blanco.",
        "Gracias, V. Fue perfecto.",
        "Gracias, V. Me ayudó más de lo que crees.",
        "Gracias, V. Más de lo que imaginas.",
        "Gracias, V. Lo aprecio.",
        "Gracias, V. De verdad lo aprecio."
    },

    BeachPreJoin = {
        "Oye V. Antes de reunirte conmigo, ¿puedes coger unas bebidas de mi maletero?",
        "Un favor rápido, V — antes de venir, coge unas bebidas de mi maletero.",
        "Antes de llegar, ¿puedes sacar unas bebidas de mi maletero?",
        "Oye. Antes de reunirte conmigo, ¿te importa coger unas bebidas del maletero?",
        "V, ¿coges unas bebidas del maletero antes de venir?",
        "Antes de aparecer por aquí, ¿puedes sacar unas bebidas del maletero?",
        "Pequeña petición: coge unas bebidas del maletero antes de reunirte conmigo.",
        "Oye V, parada rápida — las bebidas están en el maletero. ¿Las coges?",
        "Antes de reunirte conmigo, pasa por el maletero y coge las bebidas.",
        "V, el maletero tiene las bebidas. ¿Las coges antes de venir?"
    },

    Autofix = {
        "Oye V. Estoy en el Red Dirt. Si quieres, pásate.",
        "Voy al Red Dirt para relajarme un poco. Únete si quieres.",
        "Oye. Estoy en el Red Dirt. Puedes pasarte si te apetece.",
        "V. Red Dirt. Mesa tranquila. Pásate si te apetece.",
        "Necesitaba respirar. Estoy en el Red Dirt. Pásate si quieres.",
        "Quería algo tranquilo. Estoy en el Red Dirt. Pásate si te apetece.",
        "Estoy pasando un rato en el Red Dirt. Pásate si quieres.",
        "Sin prisas. Sin trabajo. Solo el Red Dirt. Pásate si quieres."
    },

    AutofixReplies = {
        "Sí, entiendo que quieras otra opinión. El trabajo personalizado se siente distinto en marcha. Puede que me pase.",
        "Parece que le has dedicado tiempo. Una segunda opinión nunca viene mal. Veré si puedo pasarme.",
        "Tiene sentido no fiarse solo del instinto. Puede que me pase a echar un vistazo.",
        "Ese tipo de ajuste suele necesitar una prueba real. Veré si puedo pasar cerca de Dakota.",
        "Sí, entiendo la petición. Probarlo bien importa. Puede que me pase si estoy cerca.",
        "Suena a algo que merece la pena revisar. Lo tendré en cuenta y quizá me pase.",
        "Confío en tu trabajo, pero entiendo querer opiniones. Puede que me pase un rato.",
        "Los añadidos personalizados siempre cambian el equilibrio. Veré si puedo pasar y probarlo.",
        "Ese trabajo merece una prueba limpia. Puede que me pase cuando tenga un momento.",
        "Sí, entiendo por qué quieres otro par de manos. Veré si puedo pasarme."
    },

    Panamdirttext = {
        "Oye V. Ya he hecho nuestro pedido. Está en el otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "Oye V. Pedido hecho. Otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "Oye V. He hecho el pedido. Está esperando en el otro mostrador, al fondo — a tu cuenta ;P",
        "Oye V. Nuestro pedido está listo. Mira en el otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "Ey V. Ya he pedido. Otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "V, el pedido ya está hecho. Está en el otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "Oye V. He hecho el pedido. Otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "V. Pedido listo. Otro mostrador, al fondo — lado del camarero — a tu cuenta ;P",
        "Oye V. Ya he puesto nuestro pedido en cola. Está en el otro mostrador, al fondo junto al camarero — a tu cuenta ;P",
        "V, ya he hecho nuestro pedido. Otro mostrador, al fondo junto al camarero — a tu cuenta ;P"
    },

    Shootingrange = {
        "Oye V. Estoy colocando unos blancos cerca del campamento. Pásate si quieres.",
        "Tengo algo de tiempo para practicar tiro cerca del campamento. Pásate si te apetece.",
        "Estoy fuera del campamento disparando a blancos. Si quieres unirte, pásate.",
        "Estoy haciendo práctica de tiro cerca del campamento. Pásate si quieres.",
        "Estoy alineando blancos fuera del campamento. Pásate si quieres mantenerte fino.",
        "Los blancos están listos cerca del campamento. Pásate si quieres disparar.",
        "Estoy pasando un rato en el campo de tiro cerca del campamento. Pásate si quieres.",
        "Estoy montando algunos blancos cerca del campamento. Sin prisas. Pásate si te apetece.",
        "Estoy cerca del campamento trabajando la puntería. Si estás por la zona, pásate.",
        "Estoy en el campamento haciendo práctica de tiro. Pásate si quieres disparar."
    },

    ShootingRangeReplies = {
        "Sí, practicar nunca viene mal. Puede que me pase si estoy libre.",
        "Suena a una buena forma de mantenerse afilado. Veré si puedo pasarme.",
        "El campo de tiro despeja la cabeza. Puede que me pase un rato.",
        "Ese tipo de rutina tiene sentido. Lo tendré en cuenta.",
        "Los blancos no mienten. Puede que me pase si estoy cerca.",
        "Siempre hay margen para mejorar. Veré cómo ando de tiempo.",
        "Suena tranquilo. Puede que me pase a disparar unas rondas.",
        "Sí, entiendo el atractivo. Me lo pensaré.",
        "La práctica suma. Puede que me pase un rato.",
        "Suena lo bastante relajado. Veré si puedo pasarme."
    },

    Beach = {
        "Oye V. Voy a la playa de Coast View en Pacifica. Pásate si quieres.",
        "V. Estoy junto al agua en Coast View. Pásate si te apetece.",
        "Necesitaba un descanso de la ciudad. Estoy en la playa de Coast View, Pacifica. Pásate si quieres.",
        "He reservado algo de tiempo en la playa de Coast View. Pásate si quieres unirte.",
        "Pacifica esta noche. Playa de Coast View. Pásate si quieres compañía.",
        "Oye. Voy a la playa de Coast View. Pásate si te apetece.",
        "V. Coast View. Junto al agua. Pásate si te apetece desaparecer un rato.",
        "Quería algo tranquilo. Estoy en la playa de Coast View, Pacifica. Pásate si quieres.",
        "Estoy pasando un rato esta noche en la playa de Coast View. Pásate si quieres.",
        "Sin prisas. Sin trabajo. Solo Coast View. Pásate si quieres."
    },

    BeachReplies = {
        "Sí, entiendo lo de alejarse de la ciudad. Puede que me pase más tarde.",
        "Coast View tiene ese efecto. Veré si puedo pasarme.",
        "Tranquilo junto al agua suena bien. Puede que me pase un rato.",
        "Ese tipo de noche tiene algo. Lo tendré en cuenta.",
        "Pacifica es distinta después de anochecer. Puede que me pase.",
        "Suena lo bastante tranquilo como para merecer la pena. Veré cómo va la noche.",
        "Sí, desaparecer un rato suena bien. Puede que me pase.",
        "Entiendo querer algo relajado. Veré si bajo.",
        "El agua ayuda a aclarar la cabeza. Puede que me pase más tarde.",
        "Sin prisas suena bien. Veré si acabo allí."
    },

    panamcampfire = {
        "Oye V, hagamos una hoguera. Coge unas ramas.",
        "Oye V, ¿te apetece una hoguera? Coge unas ramas.",
        "Oye V, construyamos una hoguera — ¿puedes coger unas ramas?",
        "Oye V, hora de la hoguera. Coge unas ramas.",
        "Oye V, ayúdame a hacer una hoguera. Coge unas ramas.",
        "Oye V, encendamos una hoguera. Coge unas ramas.",
        "Oye V, ¿te apetece una hoguera? Coge unas ramas.",
        "Oye V, encendamos una hoguera — coge unas ramas.",
        "Oye V, yo preparo el sitio; tú coges las ramas.",
        "Oye V, nos vemos junto al fuego y coge unas ramas.",
        "Oye V, yo me encargo del fuego, tú coges las ramas.",
        "Oye V, estamos haciendo una hoguera — ¿puedes coger ramas?",
        "Oye V, coge unas ramas; hagamos una hoguera.",
        "Oye V, hoguera. Trae ramas.",
        "Oye V, favor rápido — coge unas ramas para la hoguera."
    },

    panamshooting = {
        "V, en posición.",
        "V, muévete a posición.",
        "V, toma posición.",
        "V, en posición, ahora.",
        "V, colócate en posición."
    },

    panamcarm1 = {
        "Oye V, da una vuelta — veamos de qué es capaz esta bestia.",
        "Dale una vuelta, V; quiero sentir la potencia.",
        "Llévala a dar una vuelta, V — enséñame el golpe que tiene.",
        "Exprímela, V; probemos cuánto tira.",
        "Enséñame los músculos, V — dale una buena vuelta.",
        "Da la vuelta a la manzana, V; quiero oírla rugir.",
        "Sácala, V — quiero sentir el par de esta cosa.",
        "Arráncala y da una vuelta, V; enséñame la potencia bajo el capó.",
        "Pisa a fondo, V — despertemos a la bestia.",
        "Una vuelta rápida, V; quiero sentir cómo empuja."
    },

    panamcarm2 = {
        "Vale, V — ¡gracias! Puedes volver.",
        "Buena vuelta. Gracias, V; puedes volver ahora.",
        "Es suficiente. Gracias, V — vuelve cuando quieras.",
        "Perfecto. Gracias, V; tráela de vuelta.",
        "Eso vale. Gracias, V — puedes volver.",
        "Tiene buena pinta. Gracias, V; puedes volver ahora.",
        "Es suficiente. Gracias, V — puedes volver.",
        "Buen trabajo. Gracias, V; tráela.",
        "Recibido. Gracias, V — puedes volver ahora.",
        "Todo listo. Gracias, V; puedes volver."
    },

    waittime = {
        "V, tuve que largarme. Otra vez, vale?",
        "V, no podía esperar más. Nos vemos cuando sea.",
        "V, me tengo que ir. Sin rencores.",
        "V, tuve que irme. La próxima, seguro."
    },

    -- UI Strings
    ["ui_coastview"] = "Costa Vista",
    ["ui_grab_picnic"] = "Coger el pícnic",
    ["ui_prepare_meat"] = "Preparar la carne",
    ["ui_join_panam"] = "Reunirse con Panam",
    ["ui_practice"] = "La Práctica Hace al Maestro",
    ["ui_gather_branches"] = "Recoger ramas",
    ["ui_campfire"] = "Hoguera",
    ["ui_build_campfire"] = "Hacer una hoguera",
    ["ui_autofix"] = "Autofix",
    ["ui_buy_drinks"] = "Comprar bebidas (50,00)",
    ["ui_place_drink"] = "Poner la bebida",
    ["ui_watch_performance"] = "Ver el espectáculo",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "Disfrutar del espectáculo",
    ["ui_end_date"] = "Terminar la cita",
    ["ui_meet_panam_caption"] = "PanamDate|Reúnete con Panam|Panam te espera",
    ["ui_shooting_title"] = "La Práctica Hace al Maestro",
    ["ui_short_range"] = "Corto alcance",
    ["ui_long_range"] = "Largo alcance",
    ["ui_cook_meat"] = "Cocinar la carne",

    ["contactName"] = "Panam Palmer"
},

["pl-pl"] = {
    Ending = {
        "Dzięki, V. Tego mi było trzeba.",
        "Dzięki, V. Naprawdę tego potrzebowałam.",
        "Dzięki, V — dokładnie tego mi było trzeba.",
        "Dzięki, V — to mi pomogło.",
        "Dzięki, V. To wiele dla mnie znaczy.",
        "Dzięki, V. To naprawdę dużo znaczy.",
        "Dzięki, V. Naprawdę tego potrzebowałam.",
        "Dzięki, V. Bardzo mi to pomogło.",
        "Dzięki, V. Bardzo tego potrzebowałam.",
        "Dzięki, V. To było mi naprawdę potrzebne.",
        "Dzięki, V. Potrzebowałam tego — serio.",
        "Dzięki, V. Serio.",
        "Dzięki, V. Potrzebowałam tego — na serio.",
        "Dzięki, V. Naprawdę.",
        "Dzięki, V. Trafiło w punkt.",
        "Dzięki, V. Idealnie.",
        "Dzięki, V. Pomogło mi bardziej, niż myślisz.",
        "Dzięki, V. Bardziej, niż sobie wyobrażasz.",
        "Dzięki, V. Doceniam to.",
        "Dzięki, V. Naprawdę to doceniam."
    },

    BeachPreJoin = {
        "Hej V. Zanim do mnie dołączysz, możesz wziąć kilka drinków z mojego bagażnika?",
        "Mała przysługa, V — zanim przyjdziesz, weź kilka drinków z bagażnika.",
        "Zanim tu dotrzesz, możesz zgarnąć drinki z mojego bagażnika?",
        "Hej. Zanim do mnie dołączysz, możesz wziąć drinki z bagażnika?",
        "V, weź drinki z bagażnika, zanim przyjdziesz?",
        "Zanim się pojawisz, możesz wyciągnąć drinki z bagażnika?",
        "Mała prośba: weź drinki z mojego bagażnika, zanim dołączysz.",
        "Hej V, szybki przystanek — drinki są w bagażniku. Weźmiesz je?",
        "Zanim do mnie dołączysz, zajrzyj do bagażnika i weź drinki.",
        "V, drinki są w bagażniku. Weźmiesz je, zanim przyjdziesz?"
    },

    Autofix = {
        "Hej V. Jestem w Red Dirt. Jeśli chcesz, wpadnij.",
        "Idę do Red Dirt trochę się wyciszyć. Dołącz, jeśli chcesz.",
        "Hej. Jestem w Red Dirt. Możesz wpaść, jeśli masz ochotę.",
        "V. Red Dirt. Spokojny stolik. Wpadnij, jeśli chcesz.",
        "Musiałam złapać oddech. Jestem w Red Dirt. Wpadnij, jeśli chcesz.",
        "Chciałam czegoś spokojnego. Jestem w Red Dirt. Wpadnij, jeśli chcesz.",
        "Spędzam trochę czasu w Red Dirt. Wpadnij, jeśli chcesz.",
        "Bez pośpiechu. Bez roboty. Tylko Red Dirt. Wpadnij, jeśli chcesz."
    },

    AutofixReplies = {
        "Tak, rozumiem, że chcesz drugiej opinii. Przy przeróbkach wszystko czuje się inaczej w ruchu. Może wpadnę.",
        "Brzmi, jakbyś włożył w to sporo pracy. Druga opinia nigdy nie zaszkodzi. Zobaczę, czy dam radę wpaść.",
        "Ma sens, żeby nie ufać tylko własnemu przeczuciu. Może wpadnę i rzucę okiem.",
        "Takie strojenie zwykle wymaga porządnej jazdy próbnej. Zobaczę, czy wpadnę w okolicach Dakoty.",
        "Tak, rozumiem. Porządne testy są ważne. Może wpadnę, jeśli będę w pobliżu.",
        "Brzmi jak coś wartego sprawdzenia. Wezmę to pod uwagę i może wpadnę.",
        "Ufam twojej robocie, ale rozumiem potrzebę opinii. Może wpadnę na chwilę.",
        "Dodatki customowe zawsze zmieniają balans. Zobaczę, czy mogę wpaść i to poczuć.",
        "Taka robota zasługuje na czysty test. Może wpadnę, jak będę mieć chwilę.",
        "Tak, rozumiem, czemu chcesz dodatkowych rąk. Zobaczę, czy dam radę wpaść."
    },

    Panamdirttext = {
        "Hej V. Już złożyłam zamówienie. Jest na drugim blacie, na końcu przy barmanie — na twoje konto ;P",
        "Hej V. Zamówienie złożone. Drugi blat, na końcu przy barmanie — na twoje konto ;P",
        "Hej V. Złożyłam zamówienie. Czeka na drugim blacie, na końcu — na twoje konto ;P",
        "Hej V. Zamówienie gotowe. Sprawdź drugi blat na końcu przy barmanie — na twoje konto ;P",
        "Yo V. Już zamówiłam. Drugi blat, na końcu przy barmanie — na twoje konto ;P",
        "V, zamówienie już złożone. Jest na drugim blacie, na końcu przy barmanie — na twoje konto ;P",
        "Hej V. Złożyłam zamówienie. Drugi blat, na końcu przy barmanie — na twoje konto ;P",
        "V. Zamówienie gotowe. Drugi blat, na końcu — strona barmana — na twoje konto ;P",
        "Hej V. Już ustawiłam nasze zamówienie. Drugi blat, na końcu przy barmanie — na twoje konto ;P",
        "V, już złożyłam zamówienie. Drugi blat, na końcu przy barmanie — na twoje konto ;P"
    },

    Shootingrange = {
        "Hej V. Ustawiam cele w pobliżu obozu. Wpadnij, jeśli chcesz.",
        "Mam trochę czasu na strzelanie w pobliżu obozu. Wpadnij, jeśli masz ochotę.",
        "Jestem przy obozie i strzelam do celów. Jeśli chcesz dołączyć, wpadnij.",
        "Robię trochę treningu strzeleckiego przy obozie. Wpadnij, jeśli chcesz.",
        "Ustawiam cele poza obozem. Wpadnij, jeśli chcesz zachować formę.",
        "Cele stoją przy obozie. Wpadnij, jeśli chcesz postrzelać.",
        "Spędzam trochę czasu na strzelnicy przy obozie. Wpadnij, jeśli chcesz.",
        "Ustawiam kilka celów przy obozie. Bez pośpiechu. Wpadnij, jeśli chcesz.",
        "Jestem przy obozie i pracuję nad celnością. Jeśli jesteś w okolicy, wpadnij.",
        "Jestem przy obozie i ćwiczę strzelanie. Wpadnij, jeśli chcesz postrzelać."
    },

    ShootingRangeReplies = {
        "Tak, trening zawsze się przyda. Może wpadnę, jeśli będę wolna.",
        "Brzmi jak dobry sposób, żeby utrzymać formę. Zobaczę, czy dam radę wpaść.",
        "Strzelnica pomaga oczyścić głowę. Może wpadnę na chwilę.",
        "Taka rutyna ma sens. Wezmę to pod uwagę.",
        "Cele nie kłamią. Może wpadnę, jeśli będę w pobliżu.",
        "Zawsze jest miejsce na poprawę. Zobaczę, jak z czasem.",
        "Brzmi spokojnie. Może wpadnę oddać kilka strzałów.",
        "Tak, rozumiem, czemu to kusi. Pomyślę o tym.",
        "Taki trening się opłaca. Może wpadnę na chwilę.",
        "Brzmi wystarczająco na luzie. Zobaczę, czy wpadnę."
    },

    Beach = {
        "Hej V. Jadę na plażę Coast View w Pacifica. Wpadnij, jeśli chcesz.",
        "V. Jestem przy wodzie w Coast View. Wpadnij, jeśli masz ochotę.",
        "Potrzebowałam przerwy od miasta. Jestem na plaży Coast View w Pacifica. Wpadnij, jeśli chcesz.",
        "Zarezerwowałam sobie trochę czasu na plaży Coast View. Wpadnij, jeśli chcesz dołączyć.",
        "Pacifica dziś wieczorem. Plaża Coast View. Wpadnij, jeśli chcesz towarzystwa.",
        "Hej. Jadę na plażę Coast View. Wpadnij, jeśli masz ochotę.",
        "V. Coast View. Przy wodzie. Wpadnij, jeśli chcesz na chwilę zniknąć.",
        "Chciałam czegoś spokojnego. Jestem na plaży Coast View w Pacifica. Wpadnij, jeśli chcesz.",
        "Spędzam dziś wieczorem trochę czasu na plaży Coast View. Wpadnij, jeśli chcesz.",
        "Bez pośpiechu. Bez roboty. Tylko Coast View. Wpadnij, jeśli chcesz."
    },

    BeachReplies = {
        "Tak, rozumiem potrzebę ucieczki od miasta. Może wpadnę później.",
        "Coast View ma taki efekt. Zobaczę, czy mogę wpaść.",
        "Spokojnie, przy wodzie brzmi dobrze. Może wpadnę na chwilę.",
        "Taka noc ma w sobie coś. Wezmę to pod uwagę.",
        "Pacifica po zmroku jest inna. Może wpadnę.",
        "Brzmi wystarczająco spokojnie, żeby było warto. Zobaczę, jak potoczy się wieczór.",
        "Tak, zniknąć na chwilę brzmi dobrze. Może wpadnę.",
        "Rozumiem chęć czegoś na luzie. Zobaczę, czy zjadę.",
        "Woda pomaga oczyścić myśli. Może wpadnę później.",
        "Bez pośpiechu brzmi dobrze. Zobaczę, czy tam trafię."
    },

    panamcampfire = {
        "Hej V, zróbmy ognisko. Weź kilka gałęzi.",
        "Hej V, masz ochotę na ognisko? Weź kilka gałęzi.",
        "Hej V, zbudujmy ognisko — możesz wziąć kilka gałęzi?",
        "Hej V, czas na ognisko. Weź kilka gałęzi.",
        "Hej V, pomóż mi zrobić ognisko. Weź kilka gałęzi.",
        "Hej V, rozpalmy ognisko. Weź kilka gałęzi.",
        "Hej V, chcesz ognisko? Weź kilka gałęzi.",
        "Hej V, rozpalmy ognisko — weź kilka gałęzi.",
        "Hej V, ja przygotuję miejsce; ty weź gałęzie.",
        "Hej V, spotkajmy się przy palenisku i weź gałęzie.",
        "Hej V, ja zajmę się ogniem, ty weź gałęzie.",
        "Hej V, robimy ognisko — możesz wziąć gałęzie?",
        "Hej V, weź gałęzie; zróbmy ognisko.",
        "Hej V, ognisko. Przynieś gałęzie.",
        "Hej V, szybka przysługa — weź gałęzie na ognisko."
    },

    panamshooting = {
        "V, na pozycję.",
        "V, przesuń się na pozycję.",
        "V, zajmij pozycję.",
        "V, na pozycję, teraz.",
        "V, ustaw się na pozycję."
    },

    panamcarm1 = {
        "Hej V, zrób rundkę — zobaczmy, na co stać tę bestię.",
        "Zakreć nią, V; chcę poczuć tę moc.",
        "Zabierz ją na przejażdżkę, V — pokaż, jaki ma pazur.",
        "Daj jej ognia, V; sprawdźmy, jak mocno ciągnie.",
        "Pokaż mięśnie, V — zrób porządną rundę.",
        "Zrób kółko, V; chcę usłyszeć, jak ryczy.",
        "Wyjedź nią, V — chcę poczuć ten moment obrotowy.",
        "Odpal ją i zrób rundkę, V; pokaż moc pod maską.",
        "Depnij, V — obudźmy bestię.",
        "Szybka rundka, V; chcę poczuć, jak kopie."
    },

    panamcarm2 = {
        "Dobra, V — dzięki! Możesz wracać.",
        "Dobra jazda. Dzięki, V; możesz wracać.",
        "Wystarczy. Dzięki, V — wracaj, jak będziesz gotowy.",
        "Idealnie. Dzięki, V; przywieź ją z powrotem.",
        "Starczy. Dzięki, V — możesz wracać.",
        "Wygląda dobrze. Dzięki, V; możesz wracać.",
        "To wystarczy. Dzięki, V — możesz wracać.",
        "Dobra robota. Dzięki, V; przywieź ją.",
        "Przyjęte. Dzięki, V — możesz wracać.",
        "Skończone. Dzięki, V; możesz wracać."
    },

    waittime = {
        "V, musiałam się zbierać. Następnym razem.",
        "V, nie mogłam czekać wiecznie. Spóbujemy innym razem.",
        "V, muszę się zwijać. Bez urazy.",
        "V, już się zbierałem. Potem."
    },

    -- UI Strings
    ["ui_coastview"] = "Widok Brzegu",
    ["ui_grab_picnic"] = "Wziąć piknik",
    ["ui_prepare_meat"] = "Przygotować mięso",
    ["ui_join_panam"] = "Dołączyć do Panam",
    ["ui_practice"] = "Praktyka Czyni Mistrza",
    ["ui_gather_branches"] = "Zbierać gałęzie",
    ["ui_campfire"] = "Ognisko",
    ["ui_build_campfire"] = "Zbudować ognisko",
    ["ui_autofix"] = "Autofix",
    ["ui_buy_drinks"] = "Kupić napoje (50,00)",
    ["ui_place_drink"] = "Postawić napój",
    ["ui_watch_performance"] = "Obserwować występ",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "Cieszyć się występem",
    ["ui_end_date"] = "Zakończyć randkę",
    ["ui_meet_panam_caption"] = "PanamDate|Spotkaj się z Panam|Panam na ciebie czeka",
    ["ui_shooting_title"] = "Praktyka Czyni Mistrza",
    ["ui_short_range"] = "Krótki dystans",
    ["ui_long_range"] = "Długi dystans",
    ["ui_cook_meat"] = "Gotować mięso",

    ["contactName"] = "Panam Palmer"
},
["pt-br"] = {
    Ending = {
        "Valeu, V. Eu precisava disso.",
        "Obrigado, V. Eu precisava disso.",
        "Valeu, V — era exatamente o que eu precisava.",
        "Obrigado, V — isso ajudou.",
        "Valeu, V. Isso significou muito pra mim.",
        "Obrigado, V. Isso significou muito pra mim.",
        "Valeu, V. Eu realmente precisava disso.",
        "Obrigado, V. Eu realmente precisava disso.",
        "Valeu, V. Eu precisava muito disso.",
        "Obrigado, V. Eu precisava muito disso.",
        "Valeu, V. Eu precisava disso, de verdade.",
        "Obrigado, V. Eu precisava disso, de verdade.",
        "Valeu, V. Eu precisava disso — pra valer.",
        "Obrigado, V. Eu precisava disso — pra valer.",
        "Valeu, V. Acertou em cheio.",
        "Obrigado, V. Acertou em cheio.",
        "Valeu, V. Isso ajudou mais do que você imagina.",
        "Obrigado, V. Isso ajudou mais do que você imagina.",
        "Valeu, V. Eu agradeço.",
        "Obrigado, V. Eu agradeço."
    },

    BeachPreJoin = {
        "Ei V. Antes de se juntar a mim, você pode pegar algumas bebidas no meu porta-malas?",
        "Favor rápido, V — antes de vir, pega algumas bebidas no meu porta-malas.",
        "Antes de chegar, pode pegar algumas bebidas no meu porta-malas?",
        "Ei. Antes de se juntar a mim, se importa de pegar algumas bebidas no porta-malas?",
        "V, pega algumas bebidas no meu porta-malas antes de vir?",
        "Antes de aparecer, pode tirar algumas bebidas do meu porta-malas?",
        "Pedido rápido: pega algumas bebidas no meu porta-malas antes de se juntar a mim.",
        "Ei V, parada rápida — as bebidas estão no porta-malas. Pega pra mim?",
        "Antes de se juntar a mim, passa no porta-malas e pega as bebidas.",
        "V, o porta-malas tem as bebidas. Pode pegar antes de vir?"
    },

    Autofix = {
        "Ei V. Estou no Red Dirt. Se quiser, passa aqui.",
        "Estou indo pro Red Dirt dar uma relaxada. Se quiser, vem junto.",
        "Ei. Estou no Red Dirt. Pode passar se quiser.",
        "V. Red Dirt. Mesa tranquila. Passa aqui se quiser.",
        "Precisava respirar um pouco. Estou no Red Dirt. Passa aqui se quiser.",
        "Queria algo calmo. Estou no Red Dirt. Se quiser, passa aqui.",
        "Passando um tempo no Red Dirt. Se quiser, passa aqui.",
        "Sem pressa. Sem trabalho. Só o Red Dirt. Passa aqui se quiser."
    },

    AutofixReplies = {
        "É, entendo querer outra opinião. Trabalho custom muda quando tá rodando. Talvez eu passe aí.",
        "Parece que você colocou tempo nisso. Uma segunda opinião nunca faz mal. Vou ver se consigo passar.",
        "Faz sentido não confiar só no próprio feeling. Talvez eu passe pra dar uma olhada.",
        "Esse tipo de ajuste geralmente precisa de um teste de verdade. Vou ver se passo perto da Dakota.",
        "É, entendo o pedido. Testar direito importa. Talvez eu pare aí se estiver por perto.",
        "Parece algo que vale conferir. Vou manter em mente e talvez passe.",
        "Confio no seu trabalho, mas entendo querer feedback. Talvez eu passe um pouco.",
        "Extras custom sempre mudam o equilíbrio. Vou ver se consigo passar e sentir como ficou.",
        "Esse tipo de trabalho merece um teste limpo. Talvez eu passe quando tiver um tempo.",
        "É, entendo por que você quer mais um par de mãos. Vou ver se consigo passar."
    },

    Panamdirttext = {
        "Ei V. Já fiz nosso pedido. Tá no outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "Ei V. Pedido feito. Outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "Ei V. Já coloquei nosso pedido. Tá esperando no outro balcão, lá no fundo — na sua conta ;P",
        "Ei V. Nosso pedido tá pronto. Dá uma olhada no outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "Yo V. Já pedi. Outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "V, o pedido já foi feito. Tá no outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "Ei V. Fiz o pedido. Outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "V. Pedido pronto. Outro balcão, lá no fundo — lado do bartender — na sua conta ;P",
        "Ei V. Já coloquei nosso pedido na fila. Tá no outro balcão, lá no fundo perto do bartender — na sua conta ;P",
        "V, já fiz nosso pedido. Outro balcão, lá no fundo perto do bartender — na sua conta ;P"
    },

    Shootingrange = {
        "Ei V. Tô montando uns alvos perto do acampamento. Passa aqui se quiser.",
        "Tenho um tempo pra praticar tiro perto do acampamento. Passa aqui se quiser.",
        "Tô fora do acampamento atirando nos alvos. Se quiser se juntar, passa aqui.",
        "Tô fazendo um treino de tiro perto do acampamento. Passa aqui se quiser.",
        "Tô alinhando alvos fora do acampamento. Passa aqui se quiser manter a pontaria.",
        "Os alvos já tão montados perto do acampamento. Passa aqui se quiser atirar.",
        "Tô passando um tempo no estande perto do acampamento. Passa aqui se quiser.",
        "Tô montando alguns alvos perto do acampamento. Sem pressa. Passa aqui se quiser.",
        "Tô perto do acampamento trabalhando a mira. Se estiver na área, passa aqui.",
        "Tô no acampamento praticando tiro. Passa aqui se quiser atirar."
    },

    ShootingRangeReplies = {
        "É, praticar nunca faz mal. Talvez eu passe se estiver livre.",
        "Parece um bom jeito de manter a forma. Vou ver se consigo passar.",
        "Tempo no estande ajuda a limpar a cabeça. Talvez eu passe um pouco.",
        "Esse tipo de rotina faz sentido. Vou manter em mente.",
        "Os alvos não mentem. Talvez eu passe se estiver por perto.",
        "Sempre dá pra melhorar. Vou ver como tá o tempo.",
        "Parece tranquilo. Talvez eu passe pra atirar umas balas.",
        "É, entendo o apelo. Vou pensar a respeito.",
        "Prática assim dá resultado. Talvez eu passe um pouco.",
        "Parece sem pressão o suficiente. Vou ver se consigo passar."
    },

    Beach = {
        "Ei V. Tô indo pra praia de Coast View em Pacifica. Passa aqui se quiser.",
        "V. Tô perto da água em Coast View. Passa aqui se quiser.",
        "Precisava de um tempo longe da cidade. Tô na praia de Coast View, Pacifica. Passa aqui se quiser.",
        "Separei um tempo na praia de Coast View. Passa aqui se quiser se juntar.",
        "Pacifica hoje à noite. Praia de Coast View. Passa aqui se quiser companhia.",
        "Ei. Tô indo pra praia de Coast View. Passa aqui se quiser.",
        "V. Coast View. Perto da água. Passa aqui se quiser sumir um pouco.",
        "Queria algo tranquilo. Tô na praia de Coast View em Pacifica. Passa aqui se quiser.",
        "Tô passando um tempo hoje à noite na praia de Coast View. Passa aqui se quiser.",
        "Sem pressa. Sem trabalho. Só Coast View. Passa aqui se quiser."
    },

    BeachReplies = {
        "É, entendo precisar se afastar da cidade. Talvez eu passe mais tarde.",
        "Coast View faz isso com a gente. Vou ver se consigo passar.",
        "Tranquilo, perto da água soa certo. Talvez eu passe um pouco.",
        "Esse tipo de noite tem seu charme. Vou manter em mente.",
        "Pacifica fica diferente depois de escurecer. Talvez eu passe.",
        "Parece calmo o bastante pra valer a pena. Vou ver como a noite vai.",
        "É, sumir um pouco soa bem. Talvez eu passe.",
        "Entendo querer algo mais de boa. Vou pensar se desço.",
        "Água ajuda a clarear a cabeça. Talvez eu passe mais tarde.",
        "Sem pressa soa bem. Vou ver se acabo indo."
    },

    panamcampfire = {
        "Ei V, vamos fazer uma fogueira. Pega alguns galhos.",
        "Ei V, anima uma fogueira? Pega alguns galhos.",
        "Ei V, vamos montar uma fogueira — pode pegar alguns galhos?",
        "Ei V, hora da fogueira. Pega alguns galhos.",
        "Ei V, me ajuda a fazer uma fogueira. Pega alguns galhos.",
        "Ei V, vamos acender a fogueira. Pega alguns galhos.",
        "Ei V, afim de uma fogueira? Pega alguns galhos.",
        "Ei V, vamos acender uma fogueira — pega alguns galhos.",
        "Ei V, eu preparo o lugar; você pega os galhos.",
        "Ei V, me encontra na fogueira e pega os galhos.",
        "Ei V, eu cuido do fogo, você pega os galhos.",
        "Ei V, estamos fazendo uma fogueira — pode pegar os galhos?",
        "Ei V, pega os galhos; vamos fazer uma fogueira.",
        "Ei V, fogueira. Traz galhos.",
        "Ei V, favor rápido — pega galhos pra fogueira."
    },

    panamshooting = {
        "V, em posição.",
        "V, vai pra posição.",
        "V, toma posição.",
        "V, em posição, agora.",
        "V, se posiciona."
    },

    panamcarm1 = {
        "Ei V, dá uma volta — vamos ver do que essa fera é capaz.",
        "Dá uma volta nela, V; quero sentir essa potência.",
        "Leva ela pra dar uma volta, V — mostra o tranco que ela tem.",
        "Espreme ela, V; vamos testar o quanto ela puxa.",
        "Mostra os músculos, V — dá uma boa volta.",
        "Dá a volta no quarteirão, V; quero ouvir ela rugir.",
        "Tira ela pra fora, V — quero sentir o torque dessa coisa.",
        "Liga ela e dá uma volta, V; mostra a potência debaixo do capô.",
        "Pisa fundo, V — vamos acordar a fera.",
        "Uma volta rápida, V; quero sentir o coice."
    },

    panamcarm2 = {
        "Beleza, V — valeu! Pode voltar.",
        "Boa volta. Valeu, V; pode voltar agora.",
        "Tá bom. Valeu, V — volta quando estiver pronto.",
        "Perfeito. Valeu, V; traz de volta.",
        "Isso já dá. Valeu, V — pode voltar.",
        "Parece bom. Valeu, V; pode voltar agora.",
        "Já é suficiente. Valeu, V — pode voltar.",
        "Bom trabalho. Valeu, V; traz de volta.",
        "Recebido. Valeu, V — pode voltar agora.",
        "Fechado. Valeu, V; pode voltar."
    },

    waittime = {
        "V, precisei me mandar. Volta outra hora.",
        "V, não podia ficar esperando para sempre. Tentamos depois.",
        "V, tenho que ir. Sem rancor.",
        "V, já era. Depois a gente vê."
    },

    -- UI Strings
    ["ui_coastview"] = "Vista da Costa",
    ["ui_grab_picnic"] = "Pegar o piquenique",
    ["ui_prepare_meat"] = "Preparar a carne",
    ["ui_join_panam"] = "Reunir-se com Panam",
    ["ui_practice"] = "A Prática Leva à Perfeição",
    ["ui_gather_branches"] = "Coletar galhos",
    ["ui_campfire"] = "Fogueira",
    ["ui_build_campfire"] = "Construir uma fogueira",
    ["ui_autofix"] = "Autofix",
    ["ui_buy_drinks"] = "Comprar bebidas (50,00)",
    ["ui_place_drink"] = "Colocar a bebida",
    ["ui_watch_performance"] = "Assistir o Show",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "Aproveitar o Show",
    ["ui_end_date"] = "Encerrar o Encontro",
    ["ui_meet_panam_caption"] = "PanamDate|Encontre a Panam|Panam está esperando por você",
    ["ui_shooting_title"] = "A Prática Leva à Perfeição",
    ["ui_short_range"] = "Curto alcance",
    ["ui_long_range"] = "Longo alcance",
    ["ui_cook_meat"] = "Cozinhar a carne",

    ["contactName"] = "Panam Palmer"
},

["ru-ru"] = {
    Ending = {
        "Спасибо, V. Мне это было нужно.",
        "Спасибо, V. Мне правда это было нужно.",
        "Спасибо, V — это было именно то, что нужно.",
        "Спасибо, V — это помогло.",
        "Спасибо, V. Это многое для меня значит.",
        "Спасибо, V. Это правда много значит.",
        "Спасибо, V. Мне действительно это было нужно.",
        "Спасибо, V. Это действительно помогло.",
        "Спасибо, V. Мне это было очень нужно.",
        "Спасибо, V. Это было мне очень нужно.",
        "Спасибо, V. Мне это было нужно — правда.",
        "Спасибо, V. Правда.",
        "Спасибо, V. Мне это было нужно — по-настоящему.",
        "Спасибо, V. По-настоящему.",
        "Спасибо, V. Прямо в точку.",
        "Спасибо, V. Именно так.",
        "Спасибо, V. Это помогло больше, чем ты думаешь.",
        "Спасибо, V. Больше, чем ты можешь представить.",
        "Спасибо, V. Я это ценю.",
        "Спасибо, V. Правда ценю."
    },

    BeachPreJoin = {
        "Эй, V. Прежде чем подойдёшь ко мне, можешь взять напитки из багажника?",
        "Небольшая просьба, V — прежде чем прийти, захвати напитки из багажника.",
        "Перед тем как прийти, можешь забрать напитки из моего багажника?",
        "Эй. Прежде чем подойти, не возьмёшь напитки из багажника?",
        "V, возьмёшь напитки из багажника перед тем как прийти?",
        "Перед тем как появишься, можешь достать напитки из багажника?",
        "Маленькая просьба: возьми напитки из багажника, прежде чем подойдёшь.",
        "Эй, V, быстрая остановка — напитки в багажнике. Заберёшь?",
        "Перед тем как подойти, загляни в багажник и возьми напитки.",
        "V, напитки в багажнике. Заберёшь их перед тем как прийти?"
    },

    Autofix = {
        "Эй, V. Я в Red Dirt. Если хочешь, заходи.",
        "Иду в Red Dirt немного перевести дух. Присоединяйся, если хочешь.",
        "Эй. Я в Red Dirt. Можешь зайти, если хочешь.",
        "V. Red Dirt. Тихий столик. Заходи, если будет желание.",
        "Нужно было передохнуть. Я в Red Dirt. Заходи, если хочешь.",
        "Хотелось чего-то спокойного. Я в Red Dirt. Заходи, если хочешь.",
        "Провожу немного времени в Red Dirt. Заходи, если хочешь.",
        "Без спешки. Без работы. Просто Red Dirt. Заходи, если хочешь."
    },

    AutofixReplies = {
        "Да, понимаю, почему тебе нужен ещё один взгляд. Кастом в движении ощущается иначе. Может, загляну.",
        "Похоже, ты вложил в это много времени. Второе мнение не помешает. Посмотрю, смогу ли заехать.",
        "Логично не полагаться только на свои ощущения. Может, заеду взглянуть.",
        "Такую настройку обычно нужно нормально прогнать. Посмотрю, смогу ли заехать рядом с Дакотой.",
        "Да, понимаю. Правильные тесты важны. Может, заеду, если буду рядом.",
        "Звучит как то, что стоит проверить. Возьму на заметку и, возможно, заеду.",
        "Я доверяю твоей работе, но понимаю желание фидбэка. Может, загляну ненадолго.",
        "Кастомные дополнения всегда меняют баланс. Посмотрю, смогу ли заехать и прочувствовать.",
        "Такой работе нужен чистый тест. Может, заеду, когда будет минутка.",
        "Да, понимаю, почему тебе нужны ещё одни руки. Посмотрю, смогу ли заехать."
    },

    Panamdirttext = {
        "Эй, V. Я уже сделала заказ. Он на другом баре, в самом конце у бармена — за твой счёт ;P",
        "Эй, V. Заказ сделан. Другой бар, в самом конце у бармена — за твой счёт ;P",
        "Эй, V. Я оформила заказ. Он ждёт на другом баре, в конце — за твой счёт ;P",
        "Эй, V. Заказ готов. Смотри на другом баре, в самом конце у бармена — за твой счёт ;P",
        "Йо, V. Я уже заказала. Другой бар, в конце у бармена — за твой счёт ;P",
        "V, заказ уже оформлен. Он на другом баре, в конце у бармена — за твой счёт ;P",
        "Эй, V. Я сделала заказ. Другой бар, в конце у бармена — за твой счёт ;P",
        "V. Заказ готов. Другой бар, в конце — со стороны бармена — за твой счёт ;P",
        "Эй, V. Я уже поставила наш заказ в очередь. Другой бар, в конце у бармена — за твой счёт ;P",
        "V, я уже сделала заказ. Другой бар, в конце у бармена — за твой счёт ;P"
    },

    Shootingrange = {
        "Эй, V. Я ставлю мишени рядом с лагерем. Заходи, если хочешь.",
        "Есть немного времени пострелять рядом с лагерем. Заходи, если будет желание.",
        "Я возле лагеря стреляю по мишеням. Если хочешь присоединиться — заходи.",
        "Занимаюсь стрельбой рядом с лагерем. Заходи, если хочешь.",
        "Выставляю мишени за лагерем. Заходи, если хочешь оставаться в форме.",
        "Мишени готовы рядом с лагерем. Заходи, если хочешь пострелять.",
        "Провожу время на стрельбище рядом с лагерем. Заходи, если хочешь.",
        "Ставлю несколько мишеней рядом с лагерем. Без спешки. Заходи, если хочешь.",
        "Я рядом с лагерем, работаю над точностью. Если будешь поблизости — заходи.",
        "Я в лагере, тренирую стрельбу. Заходи, если хочешь пострелять."
    },

    ShootingRangeReplies = {
        "Да, практика никогда не лишняя. Может, зайду, если буду свободна.",
        "Хороший способ оставаться в форме. Посмотрю, смогу ли заехать.",
        "Стрельбище помогает прочистить голову. Может, загляну ненадолго.",
        "Такая рутина имеет смысл. Возьму на заметку.",
        "Мишени не врут. Может, заеду, если буду рядом.",
        "Всегда есть куда улучшаться. Посмотрю по времени.",
        "Звучит спокойно. Может, заеду выпустить пару очередей.",
        "Да, понимаю, чем это цепляет. Подумаю.",
        "Такая практика даёт результат. Может, заеду ненадолго.",
        "Звучит достаточно расслабленно. Посмотрю, смогу ли заехать."
    },

    Beach = {
        "Эй, V. Я еду на пляж Coast View в Пасифике. Заходи, если хочешь.",
        "V. Я у воды на Coast View. Заходи, если будет желание.",
        "Нужно было отдохнуть от города. Я на пляже Coast View, Пасифика. Заходи, если хочешь.",
        "Я выделила время для пляжа Coast View. Заходи, если хочешь присоединиться.",
        "Пасифика сегодня вечером. Пляж Coast View. Заходи, если нужна компания.",
        "Эй. Я еду на пляж Coast View. Заходи, если хочешь.",
        "V. Coast View. У воды. Заходи, если хочешь немного исчезнуть.",
        "Хотелось тишины. Я на пляже Coast View в Пасифике. Заходи, если хочешь.",
        "Я сегодня вечером на пляже Coast View. Заходи, если хочешь.",
        "Без спешки. Без работы. Просто Coast View. Заходи, если хочешь."
    },

    BeachReplies = {
        "Да, понимаю желание уйти от города. Может, загляну позже.",
        "Coast View так действует. Посмотрю, смогу ли заехать.",
        "Тихо, у воды — звучит правильно. Может, загляну ненадолго.",
        "В такой ночи что-то есть. Возьму на заметку.",
        "Пасифика ночью другая. Может, заеду.",
        "Звучит достаточно спокойно, чтобы стоило того. Посмотрю, как пойдёт вечер.",
        "Да, немного исчезнуть — звучит хорошо. Может, заеду.",
        "Понимаю желание чего-то простого. Посмотрю, спущусь ли.",
        "Вода помогает всё разложить по полочкам. Может, загляну позже.",
        "Без спешки — звучит хорошо. Посмотрю, окажусь ли там."
    },

    panamcampfire = {
        "Эй, V, давай разведём костёр. Возьми ветки.",
        "Эй, V, хочешь костёр? Возьми ветки.",
        "Эй, V, давай сделаем костёр — можешь взять ветки?",
        "Эй, V, время для костра. Возьми ветки.",
        "Эй, V, помоги мне развести костёр. Возьми ветки.",
        "Эй, V, давай зажжём костёр. Возьми ветки.",
        "Эй, V, не против костра? Возьми ветки.",
        "Эй, V, давай зажжём костёр — возьми ветки.",
        "Эй, V, я подготовлю место, ты возьми ветки.",
        "Эй, V, встретимся у костра и возьми ветки.",
        "Эй, V, я займусь огнём, ты возьми ветки.",
        "Эй, V, мы делаем костёр — можешь взять ветки?",
        "Эй, V, возьми ветки; давай разведём костёр.",
        "Эй, V, костёр. Принеси ветки.",
        "Эй, V, маленькая просьба — возьми ветки для костра."
    },

    panamshooting = {
        "V, в позицию.",
        "V, переместись в позицию.",
        "V, займи позицию.",
        "V, в позицию, сейчас.",
        "V, становись в позицию."
    },

    panamcarm1 = {
        "Эй, V, прокатись — посмотрим, на что способна эта зверюга.",
        "Прокрути её, V; хочу почувствовать эту мощь.",
        "Прокатись на ней, V — покажи, как она бьёт.",
        "Выжми из неё всё, V; проверим, как она тянет.",
        "Покажи мускулы, V — сделай хороший заезд.",
        "Прокатись вокруг квартала, V; хочу услышать, как она рычит.",
        "Выкати её, V — хочу почувствовать крутящий момент.",
        "Заводи и прокатись, V; покажи мощь под капотом.",
        "Дави, V — разбудим зверя.",
        "Короткий заезд, V; хочу почувствовать, как она пинается."
    },

    panamcarm2 = {
        "Ладно, V — спасибо! Можешь возвращаться.",
        "Хороший заезд. Спасибо, V; можешь возвращаться.",
        "Хватит. Спасибо, V — возвращайся, когда будешь готов.",
        "Идеально. Спасибо, V; возвращай её.",
        "Достаточно. Спасибо, V — можешь возвращаться.",
        "Выглядит хорошо. Спасибо, V; можешь возвращаться.",
        "Этого хватит. Спасибо, V — можешь возвращаться.",
        "Хорошая работа. Спасибо, V; возвращай.",
        "Принято. Спасибо, V — можешь возвращаться.",
        "Готово. Спасибо, V; можешь возвращаться."
    },

    waittime = {
        "V, мне нужно было уйти. В другой раз.",
        "V, не могла ждать вечно. Давай в другой раз.",
        "V, я уже ушла. Без обид, ладно?",
        "V, мне пришлось свалить. Потом ещё, ладно?"
    },

    -- UI Strings
    ["ui_coastview"] = "Вид на побережье",
    ["ui_grab_picnic"] = "Взять пикник",
    ["ui_prepare_meat"] = "Приготовить мясо",
    ["ui_join_panam"] = "Присоединиться к Панам",
    ["ui_practice"] = "Практика делает совершенство",
    ["ui_gather_branches"] = "Собрать ветки",
    ["ui_campfire"] = "Костёр",
    ["ui_build_campfire"] = "Построить костёр",
    ["ui_autofix"] = "Автомастерская",
    ["ui_buy_drinks"] = "Купить напитки (50,00)",
    ["ui_place_drink"] = "Поставить напиток",
    ["ui_watch_performance"] = "Смотреть представление",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "Наслаждаться представлением",
    ["ui_end_date"] = "Закончить свидание",
    ["ui_meet_panam_caption"] = "PanamDate|Встреться с Панам|Панам ждёт тебя",
    ["ui_shooting_title"] = "Практика делает совершенство",
    ["ui_short_range"] = "Ближняя дистанция",
    ["ui_long_range"] = "Дальняя дистанция",
    ["ui_cook_meat"] = "Готовить мясо",

    ["contactName"] = "Panam Palmer"
},

["ja-jp"] = {
    Ending = {
        "ありがとう、V。必要だった。",
        "ありがとう、V。本当に助かった。",
        "ありがとう、V — まさに必要だった。",
        "ありがとう、V — 助かったよ。",
        "ありがとう、V。本当に大きかった。",
        "ありがとう、V。本当に感謝してる。",
        "ありがとう、V。本当に必要だった。",
        "ありがとう、V。本当に助けられた。",
        "ありがとう、V。すごく必要だった。",
        "ありがとう、V。すごく助かった。",
        "ありがとう、V。本当に必要だった、心から。",
        "ありがとう、V。本当に。",
        "ありがとう、V。必要だった — 本当に。",
        "ありがとう、V。本気で。",
        "ありがとう、V。ちょうどよかった。",
        "ありがとう、V。ぴったりだった。",
        "ありがとう、V。思ってる以上に助けられた。",
        "ありがとう、V。想像以上に助かった。",
        "ありがとう、V。感謝してる。",
        "ありがとう、V。本当に感謝してる。"
    },

    BeachPreJoin = {
        "ねえ、V。合流する前に、トランクから飲み物を取ってきてくれる？",
        "ちょっとお願い、V — 来る前にトランクから飲み物を取ってきて。",
        "来る前に、トランクから飲み物を取ってきてくれる？",
        "ねえ。合流する前に、トランクから飲み物を取ってきてくれる？",
        "V、来る前にトランクから飲み物を取ってきてくれる？",
        "来る前に、トランクから飲み物を出してきてくれる？",
        "小さなお願い：合流する前にトランクから飲み物を取ってきて。",
        "ねえ V、ちょっと寄り道 — 飲み物はトランクにある。取ってきてくれる？",
        "合流する前に、トランクに寄って飲み物を取ってきて。",
        "V、飲み物はトランクにある。来る前に取ってきてくれる？"
    },

    Autofix = {
        "ねえ V。レッド・ダートにいる。よかったら来て。",
        "レッド・ダートに行くところ。少し落ち着きたい。よかったら合流して。",
        "ねえ。レッド・ダートにいる。よかったら来て。",
        "V。レッド・ダート。静かな席。気が向いたら来て。",
        "息抜きが必要だった。レッド・ダートにいる。よかったら来て。",
        "静かな場所が欲しかった。レッド・ダートにいる。よかったら来て。",
        "レッド・ダートで少し過ごしてる。よかったら来て。",
        "急ぎじゃない。仕事もなし。レッド・ダートだけ。よかったら来て。"
    },

    AutofixReplies = {
        "うん、別の意見が欲しいのは分かる。カスタムは走らせると感触が変わるから。行けたら寄るよ。",
        "ちゃんと時間をかけたみたいだね。セカンドオピニオンは悪くない。行けたら寄る。",
        "自分の感覚だけを信じないのも当然だね。時間があれば見に行くよ。",
        "ああいう調整はちゃんと走らせないと分からない。ダコタの近くに行けたら寄る。",
        "分かるよ。ちゃんとテストするのは大事だ。近くにいたら寄るかも。",
        "確認する価値はありそうだね。覚えておいて、行けたら寄る。",
        "君の仕事は信頼してるけど、フィードバックが欲しいのも分かる。少し寄るかも。",
        "カスタム追加はバランスを変えるからね。行けたら寄って確かめる。",
        "ああいう仕事はきれいなテストが必要だ。時間があれば寄る。",
        "うん、もう一組の手が欲しい理由は分かる。行けたら寄るよ。"
    },

    Panamdirttext = {
        "ねえ V。もう注文は済ませた。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "ねえ V。注文済み。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "ねえ V。注文は入れてある。向こうのカウンター、奥 — あなたのツケで ;P",
        "ねえ V。注文は準備できてる。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "よっ V。もう注文した。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "V、注文はもう済んでる。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "ねえ V。注文したよ。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "V。注文完了。向こうのカウンター、奥 — バーテンダー側 — あなたのツケで ;P",
        "ねえ V。もう注文を通してある。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P",
        "V、もう注文は済ませた。向こうのカウンター、奥のバーテンダー側 — あなたのツケで ;P"
    },

    Shootingrange = {
        "ねえ V。キャンプの近くで的を設置してる。よかったら来て。",
        "キャンプの近くで射撃の時間がある。気が向いたら来て。",
        "キャンプの外で的撃ちしてる。参加したければ来て。",
        "キャンプの近くで射撃練習してる。よかったら来て。",
        "キャンプの外で的を並べてる。腕を鈍らせたくなければ来て。",
        "キャンプの近くに的を置いた。撃ちたければ来て。",
        "キャンプの近くの射撃場で過ごしてる。よかったら来て。",
        "キャンプの近くにいくつか的を置いてる。急ぎじゃない。よかったら来て。",
        "キャンプの近くで照準を調整してる。近くにいたら来て。",
        "キャンプで射撃練習してる。撃ちたければ来て。"
    },

    ShootingRangeReplies = {
        "うん、練習は無駄にならない。空いてたら行くかも。",
        "腕を保つにはいいね。行けるか見てみる。",
        "射撃場は頭がすっきりする。少し寄るかも。",
        "そういうルーティンは大事だね。覚えておく。",
        "的は正直だ。近くにいたら寄るかも。",
        "まだ詰められるところはある。時間を見てみる。",
        "落ち着いてていいね。少し撃ちに行くかも。",
        "うん、魅力は分かる。考えてみる。",
        "練習は積み重なる。少し寄るかも。",
        "プレッシャーが少なそうでいいね。行けるか見てみる。"
    },

    Beach = {
        "ねえ V。パシフィカのコースト・ビュー・ビーチに行く。よかったら来て。",
        "V。コースト・ビューで海のそばにいる。気が向いたら来て。",
        "街から離れたかった。パシフィカのコースト・ビュー・ビーチにいる。よかったら来て。",
        "コースト・ビュー・ビーチで時間を取ってる。よかったら合流して。",
        "今夜はパシフィカ。コースト・ビュー・ビーチ。よかったら来て。",
        "ねえ。コースト・ビュー・ビーチに向かってる。よかったら来て。",
        "V。コースト・ビュー。海のそば。少し消えたくなったら来て。",
        "静かな場所が欲しかった。パシフィカのコースト・ビュー・ビーチにいる。よかったら来て。",
        "今夜はコースト・ビュー・ビーチで過ごしてる。よかったら来て。",
        "急ぎじゃない。仕事もなし。コースト・ビューだけ。よかったら来て。"
    },

    BeachReplies = {
        "うん、街から離れたくなる気持ちは分かる。あとで寄るかも。",
        "コースト・ビューにはそういう力がある。行けたら寄る。",
        "海のそばで静かに…いいね。少し寄るかも。",
        "そういう夜には引きがある。覚えておく。",
        "夜のパシフィカは違う。寄るかも。",
        "落ち着いてて行く価値はありそう。夜の流れ次第かな。",
        "うん、少し消えたくなるのは分かる。寄るかも。",
        "静かな時間が欲しいのは分かる。行くか考えてみる。",
        "水は頭を整理してくれる。あとで寄るかも。",
        "急がないのはいいね。行き着くかも。"
    },

    panamcampfire = {
        "ねえ V、焚き火をしよう。枝を取ってきて。",
        "ねえ V、焚き火どう？枝を取ってきて。",
        "ねえ V、焚き火を作ろう — 枝を取ってきてくれる？",
        "ねえ V、焚き火の時間。枝を取ってきて。",
        "ねえ V、焚き火を手伝って。枝を取ってきて。",
        "ねえ V、焚き火を起こそう。枝を取ってきて。",
        "ねえ V、焚き火やる？枝を取ってきて。",
        "ねえ V、焚き火を灯そう — 枝を取ってきて。",
        "ねえ V、場所は私が用意する。枝を取ってきて。",
        "ねえ V、焚き火場で会って、枝を取ってきて。",
        "ねえ V、火は私が見る。枝を取ってきて。",
        "ねえ V、焚き火をする — 枝を取ってきてくれる？",
        "ねえ V、枝を取ってきて。焚き火をしよう。",
        "ねえ V、焚き火。枝を持ってきて。",
        "ねえ V、ちょっとお願い — 焚き火用の枝を取ってきて。"
    },

    panamshooting = {
        "V、位置について。",
        "V、ポジションに移動。",
        "V、ポジションを取って。",
        "V、位置について、今。",
        "V、位置につけ。"
    },

    panamcarm1 = {
        "ねえ V、一周してみて — この獣の実力を見せて。",
        "回してみて、V。このパワーを感じたい。",
        "一周走って、V — どれだけパンチがあるか見せて。",
        "踏み込んで、V。どれだけ引っ張るか試そう。",
        "筋肉を見せて、V — しっかり走って。",
        "ブロックを一周して、V。吠える音を聞かせて。",
        "出してきて、V — このトルクを感じたい。",
        "エンジンをかけて一周、V。ボンネット下の力を見せて。",
        "踏み込め、V — 獣を起こそう。",
        "短く一周、V。どれだけ蹴るか感じたい。"
    },

    panamcarm2 = {
        "オーケー、V — ありがとう！戻ってきて。",
        "いい走りだった。ありがとう、V。戻ってきて。",
        "それで十分。ありがとう、V — 戻ってきて。",
        "完璧。ありがとう、V。戻して。",
        "いいよ。ありがとう、V — 戻ってきて。",
        "問題なさそう。ありがとう、V。戻ってきて。",
        "十分だ。ありがとう、V — 戻ってきて。",
        "いい感じ。ありがとう、V。戻して。",
        "了解。ありがとう、V — 戻ってきて。",
        "これで終わり。ありがとう、V。戻ってきて。"
    },

    -- UI Strings
    ["ui_coastview"] = "海岸ビュー",
    ["ui_grab_picnic"] = "ピクニックを取る",
    ["ui_prepare_meat"] = "肉を準備する",
    ["ui_join_panam"] = "パナムと合流",
    ["ui_practice"] = "練習は完璧を作る",
    ["ui_gather_branches"] = "枝を集める",
    ["ui_campfire"] = "焚き火",
    ["ui_build_campfire"] = "焚き火を作る",
    ["ui_autofix"] = "オートフィックス",
    ["ui_buy_drinks"] = "飲み物を購入 (50.00)",
    ["ui_place_drink"] = "飲み物を置く",
    ["ui_watch_performance"] = "パフォーマンスを見る",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "パフォーマンスを楽しむ",
    ["ui_end_date"] = "デートを終わりにする",
    ["ui_meet_panam_caption"] = "PanamDate|パナムに会う|パナムが待っている",
    ["ui_shooting_title"] = "練習は完璧を作る",
    ["ui_short_range"] = "短距離",
    ["ui_long_range"] = "長距離",
    ["ui_cook_meat"] = "肉を調理する",

    ["contactName"] = "パナム・パーマー"
},

["zh-cn"] = {
    Ending = {
        "谢谢你，V。我真的需要这个。",
        "谢谢，V。这对我很重要。",
        "谢谢你，V——这正是我需要的。",
        "谢谢你，V——这帮了我大忙。",
        "谢谢你，V。这对我意义很大。",
        "谢谢你，V。我真的很感激。",
        "谢谢你，V。我真的需要这个。",
        "谢谢你，V。你真的帮到我了。",
        "谢谢你，V。我太需要这个了。",
        "谢谢你，V。真的帮了我。",
        "谢谢你，V。我真的需要这个，真的。",
        "谢谢你，V。真的。",
        "谢谢你，V。我需要这个——真的。",
        "谢谢你，V。说真的。",
        "谢谢你，V。正中要害。",
        "谢谢你，V。刚刚好。",
        "谢谢你，V。这帮了我比你想象的还多。",
        "谢谢你，V。比你想的还多。",
        "谢谢你，V。我很感激。",
        "谢谢你，V。真的很感激。"
    },

    BeachPreJoin = {
        "嘿，V。在过来之前，能帮我从后备箱拿点喝的吗？",
        "小忙一个，V——来之前从我后备箱拿点喝的。",
        "过来之前，能从我后备箱拿点饮料吗？",
        "嘿。在过来之前，能帮我从后备箱拿点喝的吗？",
        "V，来之前能从后备箱拿点喝的吗？",
        "在你到之前，能从后备箱把饮料拿出来吗？",
        "小请求：来之前从我后备箱拿点喝的。",
        "嘿 V，顺路一下——饮料在后备箱。能拿吗？",
        "过来之前，顺便去后备箱把饮料拿上。",
        "V，饮料在后备箱。来之前能拿一下吗？"
    },

    Autofix = {
        "嘿，V。我在红土酒吧（Red Dirt）。想来就来。",
        "我去红土酒吧待会儿，想清静一下。想来就来。",
        "嘿。我在红土酒吧。想来的话就来。",
        "V。红土酒吧。安静的位子。想来就来。",
        "需要喘口气。我在红土酒吧。想来就来。",
        "想找个安静的地方。我在红土酒吧。想来就来。",
        "在红土酒吧待一会儿。想来就来。",
        "不急。没活。就红土酒吧。想来就来。"
    },

    AutofixReplies = {
        "嗯，我懂你为什么想再听个意见。定制的东西跑起来感觉会不一样。我可能会过去。",
        "听起来你花了不少时间。多听个意见没坏处。我看看能不能过去。",
        "不只相信自己的感觉也很正常。我可能会过去看看。",
        "这种调校一般得真正跑一跑才知道。我看看能不能在达科塔那边顺路过去。",
        "嗯，懂你的意思。好好测试很重要。我如果在附近可能会过去。",
        "听起来值得看看。我记着，可能会过去。",
        "我信你的手艺，但想要反馈我也懂。我可能会过去待一会儿。",
        "定制加装总会改变平衡。我看看能不能过去亲自感受一下。",
        "这种活儿值得一次干净的测试。我有空的话可能会过去。",
        "嗯，我懂你为什么想再多一双手。我看看能不能过去。"
    },

    Panamdirttext = {
        "嘿，V。我已经下好单了。在另一边的吧台，最里面靠近酒保那边——记你账上 ;P",
        "嘿，V。已经点好了。另一边吧台，最里面靠近酒保——记你账上 ;P",
        "嘿，V。我已经下单了。东西在另一边吧台，最里面——记你账上 ;P",
        "嘿，V。订单好了。去另一边吧台最里面靠近酒保那儿——记你账上 ;P",
        "哟，V。我已经点好了。另一边吧台，最里面靠近酒保——记你账上 ;P",
        "V，订单已经下好了。在另一边吧台，最里面靠近酒保——记你账上 ;P",
        "嘿，V。我下好单了。另一边吧台，最里面靠近酒保——记你账上 ;P",
        "V。订单完成。另一边吧台，最里面——酒保那边——记你账上 ;P",
        "嘿，V。我已经把我们的单子排上了。在另一边吧台最里面靠近酒保——记你账上 ;P",
        "V，我已经下好单了。另一边吧台，最里面靠近酒保——记你账上 ;P"
    },

    Shootingrange = {
        "嘿，V。我在营地附近布置靶子。想来就来。",
        "有点时间在营地附近练射击。想来就来。",
        "我在营地外对着靶子开枪。想一起就过来。",
        "在营地附近做射击练习。想来就来。",
        "我在营地外摆靶子。想保持手感就过来。",
        "靶子已经在营地附近准备好了。想打就来。",
        "我在营地附近的射击点待着。想来就来。",
        "在营地附近摆了几个靶子。不急。想来就来。",
        "我在营地附近练准头。要是在附近就过来。",
        "我在营地练射击。想打就来。"
    },

    ShootingRangeReplies = {
        "嗯，练练总没坏处。有空我可能会过去。",
        "听起来是保持状态的好办法。我看看能不能过去。",
        "射击场能让人清醒一下。我可能会过去一会儿。",
        "这种例行练习挺合理的。我记着。",
        "靶子不会骗人。我在附近的话可能会过去。",
        "总还有提升空间。我看看时间安排。",
        "听起来挺轻松的。我可能会过去打几枪。",
        "嗯，我懂吸引力。我考虑一下。",
        "这种练习很有用。我可能会过去一会儿。",
        "听起来压力不大。我看看能不能过去。"
    },

    Beach = {
        "嘿，V。我去帕西菲卡的海岸景观海滩（Coast View）。想来就来。",
        "V。我在海岸景观那边靠水的地方。想来就来。",
        "我需要离开城市一下。我在帕西菲卡的海岸景观海滩。想来就来。",
        "我给自己留了点时间在海岸景观海滩。想来就来。",
        "今晚去帕西菲卡。海岸景观海滩。想要陪伴就来。",
        "嘿。我正去海岸景观海滩。想来就来。",
        "V。海岸景观。靠水那边。想消失一会儿就来。",
        "我想要点安静的。我在帕西菲卡的海岸景观海滩。想来就来。",
        "今晚我会在海岸景观海滩待一会儿。想来就来。",
        "不急。没活。只有海岸景观。想来就来。"
    },

    BeachReplies = {
        "嗯，我懂想离开城市的感觉。我可能晚点过去。",
        "海岸景观就是有这种效果。我看看能不能过去。",
        "靠着水安静一下听起来不错。我可能会过去一会儿。",
        "这种夜晚挺有吸引力的。我记着。",
        "夜里的帕西菲卡不一样。我可能会过去。",
        "听起来够安静，值得一去。我看看夜里情况。",
        "嗯，消失一会儿听起来不错。我可能会过去。",
        "我懂想要低调点的感觉。我看看会不会过去。",
        "水能让人理清思路。我可能晚点过去。",
        "不急挺好。我看看会不会到那儿。"
    },

    panamcampfire = {
        "嘿，V，来生个篝火吧。去拿点树枝。",
        "嘿，V，想生个篝火吗？去拿点树枝。",
        "嘿，V，我们来搭个篝火——能去拿点树枝吗？",
        "嘿，V，篝火时间。去拿点树枝。",
        "嘿，V，帮我生个篝火。去拿点树枝。",
        "嘿，V，来点篝火吧。去拿点树枝。",
        "嘿，V，来个篝火？去拿点树枝。",
        "嘿，V，点个篝火——去拿点树枝。",
        "嘿，V，我来准备地方；你去拿树枝。",
        "嘿，V，在火坑那儿见，顺便拿点树枝。",
        "嘿，V，我看火；你去拿树枝。",
        "嘿，V，我们要生篝火——能去拿树枝吗？",
        "嘿，V，去拿树枝；我们生个篝火。",
        "嘿，V，篝火。带点树枝。",
        "嘿，V，小忙——去拿点篝火用的树枝。"
    },

    panamshooting = {
        "V，就位。",
        "V，移动到位。",
        "V，占据位置。",
        "V，立刻就位。",
        "V，站好位置。"
    },

    panamcarm1 = {
        "嘿，V，开一圈看看——看看这家伙能干嘛。",
        "转一圈，V；我想感受下这股动力。",
        "开出去转转，V——让我看看它的冲劲。",
        "狠狠干，V；试试它的拉力。",
        "让我看看它的肌肉，V——好好跑一圈。",
        "绕街区跑一圈，V；我想听听它的咆哮。",
        "开出去，V——我想感受这玩意儿的扭矩。",
        "点火跑一圈，V；让我看看引擎盖下的实力。",
        "踩下去，V——把这家伙唤醒。",
        "快速跑一圈，V；我想感受下它的爆发。"
    },

    panamcarm2 = {
        "好了，V——谢谢！可以回来了。",
        "跑得不错。谢谢，V；可以回来了。",
        "够了。谢谢，V——回来吧。",
        "完美。谢谢，V；把车开回来。",
        "可以了。谢谢，V——回来吧。",
        "看起来不错。谢谢，V；可以回来了。",
        "这样就行。谢谢，V——回来吧。",
        "干得好。谢谢，V；把车带回来。",
        "收到。谢谢，V——可以回来了。",
        "搞定了。谢谢，V；回来吧。"
    },

    waittime = {
        "V，我得走了。下次见。",
        "V，没办法一直等。将就吧。",
        "V，得拉开。没事儿。",
        "V，我溜了。下回再整。"
    },

    -- UI Strings
    ["ui_coastview"] = "海岸景观",
    ["ui_grab_picnic"] = "拿上野餐",
    ["ui_prepare_meat"] = "准备肉类",
    ["ui_join_panam"] = "与帕南汇合",
    ["ui_practice"] = "熟能生巧",
    ["ui_gather_branches"] = "收集树枝",
    ["ui_campfire"] = "篝火",
    ["ui_build_campfire"] = "生篝火",
    ["ui_autofix"] = "自动维修",
    ["ui_buy_drinks"] = "购买饮料 (50.00)",
    ["ui_place_drink"] = "放下饮料",
    ["ui_watch_performance"] = "观看表演",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "享受表演",
    ["ui_end_date"] = "结束约会",
    ["ui_meet_panam_caption"] = "PanamDate|见帕南|帕南在等你",
    ["ui_shooting_title"] = "熟能生巧",
    ["ui_short_range"] = "近距离",
    ["ui_long_range"] = "远距离",
    ["ui_cook_meat"] = "烹饪肉类",

    ["contactName"] = "帕南·帕尔默"
},

["zh-tw"] = {
    Ending = {
        "謝了，V。我真的需要這個。",
        "謝謝，V。這對我很重要。",
        "謝謝你，V——這正是我需要的。",
        "謝謝你，V——這真的幫了我。",
        "謝謝你，V。這對我意義很大。",
        "謝謝你，V。我真的很感激。",
        "謝謝你，V。我真的需要這個。",
        "謝謝你，V。你真的幫到我了。",
        "謝謝你，V。我太需要這個了。",
        "謝謝你，V。真的幫了我。",
        "謝謝你，V。我真的需要這個，真的。",
        "謝謝你，V。真的。",
        "謝謝你，V。我需要這個——真的。",
        "謝謝你，V。說真的。",
        "謝謝你，V。正中要害。",
        "謝謝你，V。剛剛好。",
        "謝謝你，V。這幫了我比你想像的還多。",
        "謝謝你，V。比你想的還多。",
        "謝謝你，V。我很感激。",
        "謝謝你，V。真的很感激。"
    },

    BeachPreJoin = {
        "嘿，V。在過來之前，能幫我從後車廂拿點喝的嗎？",
        "小忙一個，V——來之前從我後車廂拿點喝的。",
        "過來之前，能從我後車廂拿點飲料嗎？",
        "嘿。在過來之前，能幫我從後車廂拿點喝的嗎？",
        "V，來之前能從後車廂拿點喝的嗎？",
        "在你到之前，能從後車廂把飲料拿出來嗎？",
        "小請求：來之前從我後車廂拿點喝的。",
        "嘿 V，順路一下——飲料在後車廂。能拿嗎？",
        "過來之前，順便去後車廂把飲料拿上。",
        "V，飲料在後車廂。來之前能拿一下嗎？"
    },

    Autofix = {
        "嘿，V。我在紅土酒吧（Red Dirt）。想來就來。",
        "我去紅土酒吧待會兒，想清靜一下。想來就來。",
        "嘿。我在紅土酒吧。想來的話就來。",
        "V。紅土酒吧。安靜的位子。想來就來。",
        "需要喘口氣。我在紅土酒吧。想來就來。",
        "想找個安靜的地方。我在紅土酒吧。想來就來。",
        "在紅土酒吧待一會兒。想來就來。",
        "不急。沒活。就紅土酒吧。想來就來。"
    },

    AutofixReplies = {
        "嗯，我懂你為什麼想再聽個意見。客製的東西跑起來感覺會不一樣。我可能會過去。",
        "聽起來你花了不少時間。多一個意見沒壞處。我看看能不能過去。",
        "不只相信自己的感覺也很正常。我可能會過去看看。",
        "這種調校通常得真正跑一跑才知道。我看看能不能在達科塔那邊順路過去。",
        "嗯，懂你的意思。好好測試很重要。我如果在附近可能會過去。",
        "聽起來值得看看。我記著，可能會過去。",
        "我信你的手藝，但想要回饋我也懂。我可能會過去待一會兒。",
        "客製加裝總會改變平衡。我看看能不能過去親自感受一下。",
        "這種活兒值得一次乾淨的測試。我有空的話可能會過去。",
        "嗯，我懂你為什麼想再多一雙手。我看看能不能過去。"
    },

    Panamdirttext = {
        "嘿，V。我已經下好單了。在另一邊的吧台，最裡面靠近酒保那邊——記你帳上 ;P",
        "嘿，V。已經點好了。另一邊吧台，最裡面靠近酒保——記你帳上 ;P",
        "嘿，V。我已經下單了。東西在另一邊吧台，最裡面——記你帳上 ;P",
        "嘿，V。訂單好了。去另一邊吧台最裡面靠近酒保那兒——記你帳上 ;P",
        "喲，V。我已經點好了。另一邊吧台，最裡面靠近酒保——記你帳上 ;P",
        "V，訂單已經下好了。在另一邊吧台，最裡面靠近酒保——記你帳上 ;P",
        "嘿，V。我下好單了。另一邊吧台，最裡面靠近酒保——記你帳上 ;P",
        "V。訂單完成。另一邊吧台，最裡面——酒保那邊——記你帳上 ;P",
        "嘿，V。我已經把我們的單子排上了。在另一邊吧台最裡面靠近酒保——記你帳上 ;P",
        "V，我已經下好單了。另一邊吧台，最裡面靠近酒保——記你帳上 ;P"
    },

    Shootingrange = {
        "嘿，V。我在營地附近佈置靶子。想來就來。",
        "有點時間在營地附近練射擊。想來就來。",
        "我在營地外對著靶子開槍。想一起就過來。",
        "在營地附近做射擊練習。想來就來。",
        "我在營地外擺靶子。想保持手感就過來。",
        "靶子已經在營地附近準備好了。想打就來。",
        "我在營地附近的射擊點待著。想來就來。",
        "在營地附近擺了幾個靶子。不急。想來就來。",
        "我在營地附近練準頭。要是在附近就過來。",
        "我在營地練射擊。想打就來。"
    },

    ShootingRangeReplies = {
        "嗯，練練總沒壞處。有空我可能會過去。",
        "聽起來是保持狀態的好辦法。我看看能不能過去。",
        "射擊場能讓人清醒一下。我可能會過去一會兒。",
        "這種例行練習挺合理的。我記著。",
        "靶子不會騙人。我在附近的話可能會過去。",
        "總還有進步空間。我看看時間安排。",
        "聽起來挺輕鬆的。我可能會過去打幾槍。",
        "嗯，我懂吸引力。我考慮一下。",
        "這種練習很有用。我可能會過去一會兒。",
        "聽起來壓力不大。我看看能不能過去。"
    },

    Beach = {
        "嘿，V。我去帕西菲卡的海岸景觀海灘（Coast View）。想來就來。",
        "V。我在海岸景觀那邊靠水的地方。想來就來。",
        "我需要離開城市一下。我在帕西菲卡的海岸景觀海灘。想來就來。",
        "我給自己留了點時間在海岸景觀海灘。想來就來。",
        "今晚去帕西菲卡。海岸景觀海灘。想要陪伴就來。",
        "嘿。我正去海岸景觀海灘。想來就來。",
        "V。海岸景觀。靠水那邊。想消失一會兒就來。",
        "我想要點安靜的。我在帕西菲卡的海岸景觀海灘。想來就來。",
        "今晚我會在海岸景觀海灘待一會兒。想來就來。",
        "不急。沒活。只有海岸景觀。想來就來。"
    },

    BeachReplies = {
        "嗯，我懂想離開城市的感覺。我可能晚點過去。",
        "海岸景觀就是有這種效果。我看看能不能過去。",
        "靠著水安靜一下聽起來不錯。我可能會過去一會兒。",
        "這種夜晚挺有吸引力的。我記著。",
        "夜裡的帕西菲卡不一樣。我可能會過去。",
        "聽起來夠安靜，值得一去。我看看夜裡情況。",
        "嗯，消失一會兒聽起來不錯。我可能會過去。",
        "我懂想要低調點的感覺。我看看會不會過去。",
        "水能讓人理清思路。我可能晚點過去。",
        "不急挺好。我看看會不會到那兒。"
    },

    panamcampfire = {
        "嘿，V，來生個營火吧。去拿點樹枝。",
        "嘿，V，想生個營火嗎？去拿點樹枝。",
        "嘿，V，我們來搭個營火——能去拿點樹枝嗎？",
        "嘿，V，營火時間。去拿點樹枝。",
        "嘿，V，幫我生個營火。去拿點樹枝。",
        "嘿，V，來點營火吧。去拿點樹枝。",
        "嘿，V，來個營火？去拿點樹枝。",
        "嘿，V，點個營火——去拿點樹枝。",
        "嘿，V，我來準備地方；你去拿樹枝。",
        "嘿，V，在火坑那兒見，順便拿點樹枝。",
        "嘿，V，我顧火；你去拿樹枝。",
        "嘿，V，我們要生營火——能去拿樹枝嗎？",
        "嘿，V，去拿樹枝；我們生個營火。",
        "嘿，V，營火。帶點樹枝。",
        "嘿，V，小忙——去拿點營火用的樹枝。"
    },

    panamshooting = {
        "V，就位。",
        "V，移動到位。",
        "V，占據位置。",
        "V，立刻就位。",
        "V，站好位置。"
    },

    panamcarm1 = {
        "嘿，V，開一圈看看——看看這傢伙能幹嘛。",
        "轉一圈，V；我想感受下這股動力。",
        "開出去轉轉，V——讓我看看它的衝勁。",
        "狠狠干，V；試試它的拉力。",
        "讓我看看它的肌肉，V——好好跑一圈。",
        "繞街區跑一圈，V；我想聽聽它的咆哮。",
        "開出去，V——我想感受這玩意兒的扭矩。",
        "點火跑一圈，V；讓我看看引擎蓋下的實力。",
        "踩下去，V——把這傢伙喚醒。",
        "快速跑一圈，V；我想感受下它的爆發。"
    },

    panamcarm2 = {
        "好了，V——謝謝！可以回來了。",
        "跑得不錯。謝謝，V；可以回來了。",
        "夠了。謝謝，V——回來吧。",
        "完美。謝謝，V；把車開回來。",
        "可以了。謝謝，V——回來吧。",
        "看起來不錯。謝謝，V；可以回來了。",
        "這樣就行。謝謝，V——回來吧。",
        "幹得好。謝謝，V；把車帶回來。",
        "收到。謝謝，V——可以回來了。",
        "搞定了。謝謝，V；回來吧。"
    },

    waittime = {
        "V，我不在這兒了。咱們下次見。",
        "V，得走了。待會再聊。",
        "V，沒辦法一直等。等會再試試。",
        "V，我已經走了。回頭再試。"
    },

    -- UI Strings
    ["ui_coastview"] = "海岸景觀",
    ["ui_grab_picnic"] = "拿上野餐",
    ["ui_prepare_meat"] = "準備肉類",
    ["ui_join_panam"] = "與帕南匯合",
    ["ui_practice"] = "熟能生巧",
    ["ui_gather_branches"] = "收集樹枝",
    ["ui_campfire"] = "篝火",
    ["ui_build_campfire"] = "生篝火",
    ["ui_autofix"] = "自動維修",
    ["ui_buy_drinks"] = "購買飲料 (50.00)",
    ["ui_place_drink"] = "放下飲料",
    ["ui_watch_performance"] = "觀看表演",
    ["ui_red_dirt"] = "Red Dirt",
    ["ui_enjoy_performance"] = "享受表演",
    ["ui_end_date"] = "結束約會",
    ["ui_meet_panam_caption"] = "PanamDate|見帕南|帕南在等你",
    ["ui_shooting_title"] = "熟能生巧",
    ["ui_short_range"] = "近距離",
    ["ui_long_range"] = "遠距離",
    ["ui_cook_meat"] = "烹飪肉類",

    ["contactName"] = "帕南·帕爾默"
},


    ["de-de"] = {
        Ending = {
            "Danke, V. Das hab ich gebraucht.",
            "Danke dir, V. Das hab ich gebraucht.",
            "Danke, V — genau das hab ich gebraucht.",
            "Danke, V — das hat geholfen.",
            "Danke, V. Das bedeutet mir viel.",
            "Danke dir, V. Das bedeutet mir viel.",
            "Danke, V. Das hab ich wirklich gebraucht.",
            "Danke dir, V. Das hab ich wirklich gebraucht.",
            "Danke, V. Das hab ich so sehr gebraucht.",
            "Danke dir, V. Das hab ich so sehr gebraucht.",
            "Danke, V. Das hab ich gebraucht — wirklich.",
            "Danke dir, V. Das hab ich gebraucht — wirklich.",
            "Danke, V. Das hab ich gebraucht — ohne Scheiß.",
            "Danke dir, V. Das hab ich gebraucht — ohne Scheiß.",
            "Danke, V. Genau das hat gesessen.",
            "Danke dir, V. Genau das hat gesessen.",
            "Danke, V. Das hat mehr geholfen, als du denkst.",
            "Danke dir, V. Das hat mehr geholfen, als du denkst.",
            "Danke, V. Ich weiß das zu schätzen.",
            "Danke dir, V. Ich weiß das zu schätzen."
        },
        BeachPreJoin = {
            "Hey V. Bevor du zu mir kommst, kannst du ein paar Drinks aus meinem Kofferraum holen?",
            "Kleine Bitte, V — bevor du zu mir kommst: hol ein paar Drinks aus meinem Kofferraum.",
            "Bevor du rüberkommst, kannst du ein paar Drinks aus meinem Kofferraum schnappen?",
            "Hey. Bevor du zu mir kommst, kannst du kurz Drinks aus meinem Kofferraum holen?",
            "V, holst du Drinks aus meinem Kofferraum, bevor du rüberkommst?",
            "Bevor du auftauchst, kannst du ein paar Drinks aus meinem Kofferraum holen?",
            "Kleine Sache: Hol Drinks aus meinem Kofferraum, bevor du dazustößt.",
            "Hey V, kurzer Zwischenstopp — im Kofferraum sind die Drinks. Holst du sie?",
            "Bevor du zu mir kommst, schwing kurz am Kofferraum vorbei und hol die Drinks.",
            "V, im Kofferraum sind die Drinks. Kannst du sie holen, bevor du kommst?"
        },
        Autofix = {
            "Hey V. Ich bin im Red Dirt. Wenn du willst, komm vorbei.",
            "Ich geh ins Red Dirt, ein bisschen abtauchen. Wenn du willst, komm dazu.",
            "Hey. Ich bin im Red Dirt. Wenn du willst, kannst du vorbeikommen.",
            "V. Red Dirt. Ruhige Ecke. Wenn du Bock hast, komm vorbei.",
            "Musste kurz Luft holen. Ich bin im Red Dirt. Komm vorbei, wenn du willst.",
            "Ich wollte’s ruhig. Ich bin im Red Dirt. Wenn du willst, komm vorbei.",
            "Hänge ein bisschen im Red Dirt rum. Wenn du willst, komm vorbei.",
            "Kein Stress. Kein Job. Nur Red Dirt. Komm vorbei, wenn du willst."
        },
        AutofixReplies = {
            "Ja, ich versteh schon, warum du noch ’ne Meinung willst. Custom-Kram fühlt sich in Bewegung manchmal anders an. Vielleicht komm ich vorbei.",
            "Klingt, als hättest du da echt Arbeit reingesteckt. ’Ne zweite Meinung schadet nie. Ich schau, ob ich’s schaffe.",
            "Ergibt Sinn, sich nicht nur aufs Bauchgefühl zu verlassen. Vielleicht komm ich vorbei und schau’s mir an.",
            "So ein Tuning braucht meistens ’ne richtige Runde. Ich schau, ob ich bei Dakota in der Nähe vorbeikomme.",
            "Ja, ich versteh den Wunsch. Richtig testen ist wichtig. Vielleicht komm ich vorbei, wenn ich in der Nähe bin.",
            "Klingt nach was, das man sich anschauen sollte. Ich behalt’s im Kopf und komm vielleicht vorbei.",
            "Ich trau deiner Arbeit, aber Feedback ist Feedback. Vielleicht komm ich kurz vorbei.",
            "Custom-Add-ons verschieben immer das Gleichgewicht. Ich schau, ob ich vorbeikomme und ein Gefühl dafür krieg.",
            "So was verdient einen sauberen Testlauf. Vielleicht komm ich vorbei, wenn ich ’ne Minute hab.",
            "Ja, ich versteh, warum du noch ein Paar Hände willst. Ich schau, ob ich vorbeikomme."
        },
        Panamdirttext = {
            "Hey V. Ich hab schon bestellt. Steht am anderen Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "Hey V. Bestellung ist raus. Anderer Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "Hey V. Hab für uns bestellt. Wartet am anderen Tresen, ganz hinten — auf deine Rechnung ;P",
            "Hey V. Unsere Bestellung steht. Schau am anderen Tresen ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "Yo V. Hab schon für uns bestellt. Anderer Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "V, Bestellung ist schon durch. Am anderen Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "Hey V. Ich hab bestellt. Anderer Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "V. Bestellung erledigt. Anderer Tresen, ganz hinten — Barkeeper-Seite — auf deine Rechnung ;P",
            "Hey V. Hab unsere Bestellung schon angestoßen. Am anderen Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P",
            "V, ich hab schon bestellt. Anderer Tresen, ganz hinten beim Barkeeper — auf deine Rechnung ;P"
        },
        Shootingrange = {
            "Hey V. Ich stell ein paar Ziele nahe am Camp auf. Wenn du willst, komm vorbei.",
            "Hab etwas Zeit fürs Zielschießen nahe am Camp. Wenn du Bock hast, komm vorbei.",
            "Bin draußen beim Camp und baller auf Ziele. Wenn du mitmachen willst, komm vorbei.",
            "Mach ein bisschen Schießtraining nahe am Camp. Wenn du willst, komm vorbei.",
            "Ich richte draußen vorm Camp Ziele aus. Komm vorbei, wenn du scharf bleiben willst.",
            "Ziele stehen nahe am Camp. Wenn du schießen willst, komm vorbei.",
            "Ich bin am Schießstand nahe am Camp. Wenn du willst, komm vorbei.",
            "Stell ein paar Ziele nahe am Camp auf. Kein Stress. Komm vorbei, wenn du willst.",
            "Bin nahe am Camp und arbeite an meinem Ziel. Wenn du in der Gegend bist, komm vorbei.",
            "Ich bin beim Camp und mach Zielschießen. Komm vorbei, wenn du schießen willst."
        },
        ShootingRangeReplies = {
            "Ja, Training schadet nie. Vielleicht komm ich vorbei, wenn ich frei bin.",
            "Klingt nach ’nem guten Weg, scharf zu bleiben. Ich schau, ob ich kurz rüberkomme.",
            "Zeit am Stand macht den Kopf frei. Vielleicht komm ich kurz vorbei.",
            "So eine Routine ergibt Sinn. Ich behalt’s im Hinterkopf.",
            "Ziele lügen nicht. Vielleicht schau ich vorbei, wenn ich in der Nähe bin.",
            "Da geht immer noch was. Ich schau, wie’s zeitlich aussieht.",
            "Klingt solide. Vielleicht komm ich vorbei und hau ein paar Schuss raus.",
            "Ja, ich versteh den Reiz. Ich überleg’s mir.",
            "So ein Training zahlt sich aus. Vielleicht komm ich kurz vorbei.",
            "Klingt entspannt genug. Ich schau, ob ich vorbeikomme."
        },
        Beach = {
            "Hey V. Ich fahr zum Coast-View-Strand in Pacifica. Wenn du willst, komm vorbei.",
            "V. Ich bin am Wasser bei Coast View. Wenn du willst, komm vorbei.",
            "Ich brauchte ’ne Pause von der Stadt. Bin am Strand bei Coast View, Pacifica. Komm vorbei, wenn du willst.",
            "Hab mir Zeit am Coast-View-Strand genommen. Wenn du willst, komm dazu.",
            "Pacifica heute Nacht. Coast-View-Strand. Wenn du Gesellschaft willst, komm vorbei.",
            "Hey. Ich fahr zum Strand bei Coast View. Wenn du willst, komm vorbei.",
            "V. Coast View. Am Wasser. Komm vorbei, wenn du kurz verschwinden willst.",
            "Ich wollte’s ruhig. Ich bin am Coast-View-Strand in Pacifica. Komm vorbei, wenn du willst.",
            "Ich bin heute Nacht am Coast-View-Strand. Wenn du willst, komm vorbei.",
            "Kein Stress. Kein Job. Nur Coast-View-Strand. Komm vorbei, wenn du willst."
        },
        BeachReplies = {
            "Ja, ich versteh das mit Abstand zur Stadt. Vielleicht komm ich später vorbei.",
            "Coast View wirkt so auf Leute. Ich schau, ob ich kurz rüberkomme.",
            "Ruhig am Wasser klingt richtig. Vielleicht komm ich kurz vorbei.",
            "So eine Nacht hat was. Ich behalt’s im Hinterkopf.",
            "Pacifica ist nach Einbruch der Dunkelheit anders. Vielleicht komm ich vorbei.",
            "Klingt ruhig genug, um’s zu machen. Ich schau, wie der Abend läuft.",
            "Ja, kurz verschwinden klingt gut. Vielleicht komm ich vorbei.",
            "Ich versteh den Wunsch nach was Low-Key. Ich überleg, ob ich runterkomme.",
            "Wasser räumt den Kopf auf. Vielleicht komm ich später vorbei.",
            "Kein Stress klingt gut. Mal sehen, ob ich da lande."
        },
        panamcampfire = {
            "Hey V, lass ein Lagerfeuer machen. Hol ein paar Äste.",
            "Hey V, Bock auf ein Lagerfeuer? Hol ein paar Äste.",
            "Hey V, lass ein Lagerfeuer bauen — kannst du ein paar Äste holen?",
            "Hey V, Lagerfeuer-Zeit. Hol ein paar Äste.",
            "Hey V, hilf mir beim Lagerfeuer. Hol ein paar Äste.",
            "Hey V, lass das Feuer ankriegen. Hol ein paar Äste.",
            "Hey V, Lust auf ein Lagerfeuer? Hol ein paar Äste.",
            "Hey V, lass ein Lagerfeuer anzünden — hol ein paar Äste.",
            "Hey V, ich mach den Platz klar; du holst die Äste.",
            "Hey V, triff mich an der Feuerstelle und hol ein paar Äste.",
            "Hey V, ich kümmer mich ums Feuer, du holst die Äste.",
            "Hey V, wir machen ein Lagerfeuer — kannst du Äste holen?",
            "Hey V, hol ein paar Äste; lass ein Lagerfeuer machen.",
            "Hey V, lass Lagerfeuer machen. Bring Äste.",
            "Hey V, kleine Bitte — hol ein paar Äste fürs Lagerfeuer."
        },
        panamshooting = {
            "V, geh in Position.",
            "V, beweg dich in Position.",
            "V, nimm deine Position ein.",
            "V, in Position, sofort.",
            "V, stell dich in Position."
        },
        panamcarm1 = {
            "Hey V, dreh ’ne Runde — mal sehen, was das Biest kann.",
            "Dreh sie aus, V; ich will die Power spüren.",
            "Fahr ’ne Runde, V — zeig mir, wie hart sie zuschlägt.",
            "Gib ihr Feuer, V; testen wir, wie stark sie zieht.",
            "Zeig mir die Muskeln, V — dreh ’ne ordentliche Runde.",
            "Fahr um den Block, V; ich will sie brüllen hören.",
            "Roll raus, V — ich will das Drehmoment schmecken.",
            "Start sie und dreh ’ne Runde, V; zeig mir die Power unter der Haube.",
            "Tritt drauf, V — weck das Biest auf.",
            "Eine kurze Runde, V; ich will spüren, wie hart sie kickt."
        },
        panamcarm2 = {
            "Okay, V — danke! Du kannst zurück.",
            "Gute Runde. Danke, V; du kannst jetzt zurück.",
            "Reicht. Danke, V — komm zurück, wenn du bereit bist.",
            "Perfekt. Danke, V; bring sie zurück.",
            "Passt. Danke, V — kannst zurückfahren.",
            "Sieht gut aus. Danke, V; du kannst jetzt zurück.",
            "Das reicht. Danke, V — du kannst zurück.",
            "Gutes Zeug. Danke, V; bring sie rein.",
            "Alles klar. Danke, V — du kannst jetzt zurück.",
            "Wir sind durch. Danke, V; du kannst zurück."
        },

        waittime = {
            "V, musste mich verpissen. Morgen vielleicht.",
            "V, konnte nicht ewig warten. Versuch's später.",
            "V, muss los. Keine Hartgefühle.",
            "V, bin schon weg. Dann halt nächstes Mal."
        },

        -- UI Strings
        ["ui_coastview"] = "Küstenblick",
        ["ui_grab_picnic"] = "Picknick greifen",
        ["ui_prepare_meat"] = "Fleisch zubereiten",
        ["ui_join_panam"] = "Panam beitreten",
        ["ui_practice"] = "Übung macht den Meister",
        ["ui_gather_branches"] = "Äste sammeln",
        ["ui_campfire"] = "Lagerfeuer",
        ["ui_build_campfire"] = "Lagerfeuer machen",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "Getränke kaufen (50,00)",
        ["ui_place_drink"] = "Getränk abstellen",
        ["ui_watch_performance"] = "Vorstellung ansehen",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Vorstellung genießen",
        ["ui_end_date"] = "Verabredung beenden",
        ["ui_meet_panam_caption"] = "PanamDate|Triff Panam|Panam wartet auf dich",
        ["ui_shooting_title"] = "Übung macht den Meister",
        ["ui_short_range"] = "Kurze Distanz",
        ["ui_long_range"] = "Lange Distanz",

        ["contactName"] = "Panam Palmer"
    },

    ["it-it"] = {
        Ending = {
            "Grazie, V. Ne avevo bisogno.",
            "Grazie, V. Mi serviva davvero.",
            "Grazie, V — era esattamente quello che mi serviva.",
            "Grazie, V — mi ha aiutato.",
            "Grazie, V. Ha significato molto per me.",
            "Grazie, V. Conta davvero tanto.",
            "Grazie, V. Ne avevo davvero bisogno.",
            "Grazie, V. Mi serviva sul serio.",
            "Grazie, V. Ne avevo bisogno tantissimo.",
            "Grazie, V. Mi serviva tantissimo.",
            "Grazie, V. Ne avevo bisogno, davvero.",
            "Grazie, V. Mi serviva, davvero.",
            "Grazie, V. Ne avevo bisogno — sul serio.",
            "Grazie, V. Mi serviva — sul serio.",
            "Grazie, V. È andata dritta al punto.",
            "Grazie, V. Ha centrato il bersaglio.",
            "Grazie, V. Mi ha aiutato più di quanto pensi.",
            "Grazie, V. Mi hai aiutata più di quanto credi.",
            "Grazie, V. Lo apprezzo.",
            "Grazie, V. Lo apprezzo davvero."
        },
        BeachPreJoin = {
            "Ehi V. Prima di raggiungermi, puoi prendere un po’ di drink dal mio bagagliaio?",
            "Piccolo favore, V — prima di raggiungermi, prendi un po’ di drink dal bagagliaio.",
            "Prima di venire qui, puoi recuperare dei drink dal mio bagagliaio?",
            "Ehi. Prima di raggiungermi, ti va di prendere dei drink dal bagagliaio?",
            "V, prendi dei drink dal mio bagagliaio prima di venire?",
            "Prima di arrivare, puoi tirare fuori dei drink dal mio bagagliaio?",
            "Richiesta piccola: prendi dei drink dal mio bagagliaio prima di raggiungermi.",
            "Ehi V, pit stop rapido — i drink sono nel bagagliaio. Li prendi?",
            "Prima di raggiungermi, passa dal mio bagagliaio e prendi i drink.",
            "V, i drink sono nel bagagliaio. Li prendi prima di venire?"
        },
        Autofix = {
            "Ehi V. Sono al Red Dirt. Se vuoi, passa.",
            "Sto andando al Red Dirt per starmene tranquilla. Se vuoi, raggiungimi.",
            "Ehi. Sono al Red Dirt. Se vuoi, puoi passare.",
            "V. Red Dirt. Un posto tranquillo. Se ti va, passa.",
            "Avevo bisogno di respirare. Sono al Red Dirt. Passa se vuoi.",
            "Volevo qualcosa di calmo. Sono al Red Dirt. Se vuoi, passa.",
            "Sto passando un po’ di tempo al Red Dirt. Se vuoi, passa.",
            "Niente fretta. Niente lavoro. Solo Red Dirt. Passa se ti va."
        },
        AutofixReplies = {
            "Sì, capisco perché vorresti un’altra opinione. Il lavoro custom cambia quando lo porti su strada. Potrei passare.",
            "Sembra che ci hai messo tempo vero. Un secondo parere non fa mai male. Vedrò se riesco a fare un salto.",
            "Ci sta non fidarsi solo della propria sensazione. Potrei passare a dare un’occhiata.",
            "Quel tipo di messa a punto di solito vuole una prova seria. Vedrò se riesco a passare vicino a Dakota.",
            "Sì, capisco la richiesta. Testarlo bene conta. Potrei fermarmi se sono nei paraggi.",
            "Sembra una cosa che vale la pena controllare. Me lo tengo a mente e magari passo.",
            "Mi fido del tuo lavoro, ma capisco voler feedback. Potrei passare un attimo.",
            "Gli extra custom cambiano sempre l’equilibrio. Vedrò se riesco a passare e sentirlo di persona.",
            "Quel lavoro merita un test pulito. Potrei passare quando ho un minuto.",
            "Sì, capisco perché vorresti un altro paio di mani. Vedrò se riesco a fare un salto."
        },
        Panamdirttext = {
            "Ehi V. Ho già fatto l’ordine. È sull’altro bancone, in fondo vicino al barista — a tuo conto ;P",
            "Ehi V. Ordine fatto. Altro bancone, in fondo vicino al barista — a tuo conto ;P",
            "Ehi V. Ho piazzato l’ordine. Ti aspetta sull’altro bancone, in fondo — a tuo conto ;P",
            "Ehi V. L’ordine è pronto. Guarda sull’altro bancone in fondo vicino al barista — a tuo conto ;P",
            "Yo V. Ho già messo l’ordine. Altro bancone, in fondo vicino al barista — a tuo conto ;P",
            "V, l’ordine è già stato fatto. È sull’altro bancone, in fondo vicino al barista — a tuo conto ;P",
            "Ehi V. Ho fatto l’ordine. Altro bancone, in fondo vicino al barista — a tuo conto ;P",
            "V. Ordine fatto. Altro bancone, in fondo — lato barista — a tuo conto ;P",
            "Ehi V. Ho già messo in coda l’ordine. È sull’altro bancone, in fondo vicino al barista — a tuo conto ;P",
            "V, ho già fatto l’ordine. Altro bancone, in fondo vicino al barista — a tuo conto ;P"
        },
        Shootingrange = {
            "Ehi V. Sto sistemando dei bersagli vicino al campo. Se vuoi, passa.",
            "Ho un po’ di tempo per fare pratica vicino al campo. Passa se ti va.",
            "Sono fuori dal campo a tirare sui bersagli. Se vuoi unirti, passa.",
            "Sto facendo un po’ di pratica di tiro vicino al campo. Se ti va, passa.",
            "Sto allineando i bersagli fuori dal campo. Passa se vuoi restare in forma.",
            "Ho messo su dei bersagli vicino al campo. Se ti va di sparare, passa.",
            "Sto passando un po’ di tempo al poligono vicino al campo. Se vuoi, passa.",
            "Sto sistemando qualche bersaglio vicino al campo. Nessuna fretta. Passa se ti va.",
            "Sono vicino al campo e lavoro sulla mira. Se sei in zona, passa.",
            "Sono al campo a fare pratica di tiro. Passa se vuoi sparare."
        },
        ShootingRangeReplies = {
            "Sì, un po’ di pratica non guasta. Potrei passare se sono libera.",
            "Sembra un buon modo per restare sul pezzo. Vedrò se riesco a fare un salto.",
            "Il poligono schiarisce la testa. Potrei passare un attimo.",
            "Quel tipo di routine ha senso. Me lo tengo a mente.",
            "I bersagli non mentono. Potrei passare se sono nei paraggi.",
            "C’è sempre margine per migliorare. Vedrò come sono messa coi tempi.",
            "Sembra tranquillo. Potrei passare a scaricare qualche colpo.",
            "Sì, capisco il fascino. Ci penso.",
            "La pratica paga. Potrei passare un attimo.",
            "Sembra abbastanza senza pressione. Vedrò se riesco a passare."
        },
        Beach = {
            "Ehi V. Sto andando alla spiaggia di Coast View a Pacifica. Se vuoi, passa.",
            "V. Sono vicino all’acqua a Coast View. Se ti va, passa.",
            "Avevo bisogno di una pausa dalla città. Sono alla spiaggia di Coast View, Pacifica. Passa se vuoi.",
            "Mi sono ritagliata un po’ di tempo a Coast View. Se vuoi raggiungermi, passa.",
            "Pacifica stasera. Spiaggia di Coast View. Se vuoi compagnia, passa.",
            "Ehi. Sto andando alla spiaggia di Coast View. Se vuoi, passa.",
            "V. Coast View. Vicino all’acqua. Passa se ti va di sparire un po’.",
            "Volevo qualcosa di tranquillo. Sono alla spiaggia di Coast View a Pacifica. Passa se vuoi.",
            "Sto passando un po’ di tempo alla spiaggia di Coast View stasera. Se vuoi, passa.",
            "Niente fretta. Niente lavoro. Solo Coast View. Passa se ti va."
        },
        BeachReplies = {
            "Sì, capisco il bisogno di staccare dalla città. Potrei passare più tardi.",
            "Coast View fa quell’effetto. Vedrò se riesco a fare un salto.",
            "Tranquillo, vicino all’acqua… ci sta. Potrei passare un attimo.",
            "Una notte così tira. Me lo tengo a mente.",
            "Pacifica di notte è diversa. Potrei passare.",
            "Sembra abbastanza calmo da valerne la pena. Vedrò come va la serata.",
            "Sì, sparire un po’ suona bene. Potrei passare.",
            "Capisco la voglia di qualcosa di low-key. Ci penso, magari scendo.",
            "L’acqua aiuta a schiarire. Potrei passare più tardi.",
            "Niente fretta mi piace. Vedrò se finisco lì."
        },
        panamcampfire = {
            "Ehi V, facciamo un falò. Prendi dei rami.",
            "Ehi V, ti va un falò? Prendi dei rami.",
            "Ehi V, costruiamo un falò — puoi prendere dei rami?",
            "Ehi V, è ora del falò. Prendi dei rami.",
            "Ehi V, aiutami a fare un falò. Prendi dei rami.",
            "Ehi V, accendiamo un falò. Prendi dei rami.",
            "Ehi V, ti va un falò? Prendi dei rami.",
            "Ehi V, accendiamo un falò — prendi dei rami.",
            "Ehi V, io preparo il posto; tu prendi i rami.",
            "Ehi V, ci vediamo alla buca e prendi dei rami.",
            "Ehi V, io gestisco il fuoco, tu prendi i rami.",
            "Ehi V, stiamo facendo un falò — puoi prendere dei rami?",
            "Ehi V, prendi dei rami; facciamo un falò.",
            "Ehi V, falò. Porta dei rami.",
            "Ehi V, favore veloce — prendi dei rami per un falò."
        },
        panamshooting = {
            "V, in posizione.",
            "V, spostati in posizione.",
            "V, prendi posizione.",
            "V, in posizione, ora.",
            "V, sistemati in posizione."
        },
        panamcarm1 = {
            "Ehi V, fai un giro — vediamo cosa sa fare questa bestia.",
            "Falle fare un giro, V; voglio sentire questa potenza.",
            "Portala a fare un giro, V — fammi vedere che botta ha.",
            "Spremila, V; testiamo quanto tira forte.",
            "Fammi vedere i muscoli, V — fai un giro fatto bene.",
            "Fai il giro dell’isolato, V; voglio sentirla ruggire.",
            "Portala fuori, V — voglio assaggiare la coppia di questo coso.",
            "Accendila e fai un giro, V; fammi vedere la potenza sotto il cofano.",
            "Giù il piede, V — svegliamo la bestia.",
            "Un giro veloce, V; voglio sentire quanto spinge."
        },
        panamcarm2 = {
            "Ok, V — grazie! Puoi tornare indietro.",
            "Bel giro. Grazie, V; puoi tornare ora.",
            "Basta così. Grazie, V — torna quando sei pronto.",
            "Perfetto. Grazie, V; riportala indietro.",
            "Va bene. Grazie, V — torna pure indietro.",
            "Sembra a posto. Grazie, V; puoi rientrare ora.",
            "È abbastanza. Grazie, V — puoi tornare.",
            "Ottimo. Grazie, V; riportala dentro.",
            "Ricevuto. Grazie, V — puoi tornare ora.",
            "Ci siamo. Grazie, V; puoi tornare."
        },

        waittime = {
            "V, dovevo andarmene. Prossima volta.",
            "V, non potevo aspettare in eterno. Ritentiamo.",
            "V, devo andare. Niente rancore.",
            "V, sono scappata. Dopo magari."
        },

        -- UI Strings
        ["ui_coastview"] = "Vista Costiera",
        ["ui_grab_picnic"] = "Prendi il picnic",
        ["ui_prepare_meat"] = "Prepara la carne",
        ["ui_join_panam"] = "Unisciti a Panam",
        ["ui_practice"] = "La Pratica Rende Perfetti",
        ["ui_gather_branches"] = "Raccogli rami",
        ["ui_campfire"] = "Fuoco da campo",
        ["ui_build_campfire"] = "Costruisci un fuoco",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "Compra bevande (50,00)",
        ["ui_place_drink"] = "Posiziona la bevanda",
        ["ui_watch_performance"] = "Guarda l'esibizione",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Goditi l'esibizione",
        ["ui_end_date"] = "Termina l'appuntamento",
        ["ui_meet_panam_caption"] = "PanamDate|Incontra Panam|Panam ti sta aspettando",
        ["ui_shooting_title"] = "La Pratica Rende Perfetti",
        ["ui_short_range"] = "Corto raggio",
        ["ui_long_range"] = "Lungo raggio",

        ["contactName"] = "Panam Palmer"
    },

    ["ar-ar"] = {
        Ending = {
            "شكراً يا V. كنت بحاجة لهذا.",
            "شكراً لك يا V، هذا كان بالضبط ما أحتاجه.",
            "شكراً يا V. هذا ساعدني أكثر مما تظن.",
            "شكراً يا V. أقدّر هذا حقاً."
        },
        BeachPreJoin = {
            "هيه V، قبل ما تجي لعندي خذ لك شوية مشروبات من الشنطة.",
            "V، لو تقدر قبل ما توصل تاخذ المشروبات من شنطة السيارة يكون تمام."
        },
        Autofix = {
            "هيه V، أنا في حانة \"ريد ديرت\". لو حاب تمر، تعال.",
            "طلعت أغيّر جو في الريد ديرت. لو حاب، تعال اجلس معي."
        },
        AutofixReplies = {
            "فاهمة ليه تبغى رأي ثاني. الشغل المخصص يحسّ مختلف لما تمشي السيارة. يمكن أمر عليك.",
            "يبان أنك تعبت على هالشغل. ما يضر نلقي نظرة ثانية. بشوف لو أقدر أعدّي."
        },
        Panamdirttext = {
            "هيه V، طلبنا جاهز. تلاقيه على الكونتر الثاني، آخره عند الساقي — وعلى حسابك ;P",
            "V، طلبنا موجود على الكونتر الثاني، آخر الممر جنب البارمان — محطوط على فاتورتك ;P"
        },
        Shootingrange = {
            "هيه V، حاطة أهداف قريبة من المعسكر. لو حاب تطلق شوية، تعال.",
            "عندي شوية وقت للتدريب على الرماية جنب المخيم. مر لو نفسك تجرّب."
        },
        ShootingRangeReplies = {
            "التدريب عمره ما يضر. يمكن أمر لو فضيت.",
            "فكرة كويسة عشان نضل جاهزين. بشوف لو أقدر أطلّ."
        },
        Beach = {
            "هيه V، رايحة على شاطئ كوست فيو في باسيفيكا. لو حاب تهرب من المدينة شوي، تعال.",
            "اليوم على كوست فيو، جنب الميّة. لو حاب الجو الهادي، مر."
        },
        BeachReplies = {
            "فهمانة إحساس إنك تبغى تبعد عن المدينة شوية. يمكن أعدّي بعدين.",
            "هدوء جنب البحر يسمع حلو. بشوف لو أجي أقعد شوي."
        },
        panamcampfire = {
            "هيه V، خلينا نسوي نار مخيم. جيب لك شوية أغصان.",
            "V، لو فاضي، جمع لنا شوية عيدان عشان النار."
        },
        panamshooting = {
            "V، خذ مكانك.",
            "V، تحرك على الوضعية."
        },
        panamcarm1 = {
            "هيه V، لفّة سريعة — خلينا نشوف هالوحش إيش يقدر يسوي.",
            "دوّرها شوية يا V، أبغى أحس بقوة المكينة."
        },
        panamcarm2 = {
            "تمام V، شكراً. رجّعها الآن.",
            "جولة حلوة. شكراً يا V، تقدر ترجع."
        },
        waittime = {
            "V، اضطرّيت أمشي. نخليها لمرّة ثانية.",
            "V، ما قدرت أستنى للأبد. نعيدها وقت ثاني."
        },

        ["ui_coastview"] = "كوست فيو",
        ["ui_grab_picnic"] = "خذ أغراض النزهة",
        ["ui_prepare_meat"] = "حضّر اللحم",
        ["ui_join_panam"] = "انضم إلى بانام",
        ["ui_practice"] = "التدريب يصنع الإتقان",
        ["ui_gather_branches"] = "اجمع الأغصان",
        ["ui_campfire"] = "نار مخيم",
        ["ui_build_campfire"] = "أشعل نار المخيم",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "اشتري مشروبات (50.00)",
        ["ui_place_drink"] = "ضع المشروب",
        ["ui_watch_performance"] = "شاهد العرض",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "استمتع بالعرض",
        ["ui_end_date"] = "انهِ الموعد",
        ["ui_meet_panam_caption"] = "PanamDate|قابل بانام|بانام بانتظارك",
        ["ui_shooting_title"] = "التدريب يصنع الإتقان",
        ["ui_short_range"] = "مدى قصير",
        ["ui_long_range"] = "مدى بعيد",
        ["ui_cook_meat"] = "اطبخ اللحم",

        ["contactName"] = "بانام بالمر"
    },

    ["cz-cz"] = {
        Ending = {
            "Díky, V. Tohle jsem potřebovala.",
            "Děkuju, V, vážně mi to pomohlo.",
            "Díky, V. Pomohlo to víc, než si myslíš.",
            "Děkuju, V. Vážím si toho."
        },
        BeachPreJoin = {
            "Hele V, než dorazíš, skoč prosím do kufru pro nějaký pití.",
            "V, kdybys předtím mohl vzít z kufru pár drinků, bylo by to super."
        },
        Autofix = {
            "Hele V. Jsem v Red Dirt. Jestli chceš, stav se.",
            "Jdu se schovat do Red Dirt. Když budeš chtít, přijď za mnou."
        },
        AutofixReplies = {
            "Chápu, že chceš druhý názor. Custom úpravy se za jízdy chovají jinak. Možná se stavím.",
            "Zní to, že sis s tím fakt pohrála. Druhý pohled neuškodí. Uvidím, jestli se zvládnu zastavit."
        },
        Panamdirttext = {
            "Hele V, objednávka je hotová. Je na druhým pultu, úplně vzadu u barmana — na tvůj účet ;P",
            "V, naše objednávka čeká na druhým pultu, vzadu u baru — a jde to na tebe ;P"
        },
        Shootingrange = {
            "Hele V, stavím pár terčů u kempu. Jestli si chceš zastřílet, přijď.",
            "Mám chvilku na střelbu u tábora. Stav se, jestli máš náladu."
        },
        ShootingRangeReplies = {
            "Jo, trénink nikdy neuškodí. Možná se stavím, když budu mít čas.",
            "Zní to jako dobrej způsob, jak nezrezivět. Uvidím, jestli to stihnu."
        },
        Beach = {
            "Hele V. Mířím na pláž Coast View v Pacificě. Jestli chceš vypadnout z města, doraz.",
            "Jsem u vody na Coast View. Jestli máš chuť na klid, stav se."
        },
        BeachReplies = {
            "Rozumím, že potřebuješ pauzu od města. Třeba se později ukážu.",
            "Klid u vody zní dobře. Uvidím, jestli se za tebou zastavím."
        },
        panamcampfire = {
            "Hele V, uděláme oheň. Sežeň nějaké větve.",
            "V, jestli máš čas, posbírej trochu dřeva na oheň."
        },
        panamshooting = {
            "V, zaujmi pozici.",
            "V, běž na svou pozici."
        },
        panamcarm1 = {
            "Hele V, dej jí jedno kolečko — ať vidíme, co umí.",
            "Rozjeď ji, V, chci cítit, jak zabírá."
        },
        panamcarm2 = {
            "Dobře, V — díky. Můžeš ji přivézt zpátky.",
            "Pěkná jízda. Díky, V, vrať se."
        },
        waittime = {
            "V, musela jsem jít. Příště to zkusíme znovu.",
            "V, nemohla jsem čekat věčně. Necháme to na jindy."
        },

        ["ui_coastview"] = "Coast View",
        ["ui_grab_picnic"] = "Vezmi věci na piknik",
        ["ui_prepare_meat"] = "Připrav maso",
        ["ui_join_panam"] = "Přidej se k Panam",
        ["ui_practice"] = "Cvičení dělá mistra",
        ["ui_gather_branches"] = "Nasbírej větve",
        ["ui_campfire"] = "Táborák",
        ["ui_build_campfire"] = "Rozdělej oheň",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "Kup pití (50.00)",
        ["ui_place_drink"] = "Polož pití",
        ["ui_watch_performance"] = "Sleduj vystoupení",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Užij si vystoupení",
        ["ui_end_date"] = "Ukonči schůzku",
        ["ui_meet_panam_caption"] = "PanamDate|Sejdi se s Panam|Panam na tebe čeká",
        ["ui_shooting_title"] = "Cvičení dělá mistra",
        ["ui_short_range"] = "Krátká vzdálenost",
        ["ui_long_range"] = "Dlouhá vzdálenost",
        ["ui_cook_meat"] = "Uvař maso",

        ["contactName"] = "Panam Palmer"
    },

    ["es-mx"] = {
        Ending = {
            "Gracias, V. Necesitaba esto.",
            "Gracias, V, de verdad me hacía falta.",
            "Gracias, V. Me ayudó más de lo que crees.",
            "Gracias, V. En serio lo aprecio."
        },
        BeachPreJoin = {
            "Oye V. Antes de venir, ¿puedes agarrar unas bebidas de mi cajuela?",
            "V, favor rápido: antes de llegar, toma unas bebidas de la cajuela."
        },
        Autofix = {
            "Oye V. Estoy en el Red Dirt. Si quieres, cáele.",
            "Voy al Red Dirt a relajarme un rato. Si te late, ven."
        },
        AutofixReplies = {
            "Entiendo que quieras otra opinión. El trabajo custom cambia cuando el carro va en marcha. A lo mejor me paso.",
            "Suena a que le metiste tiempo. Una segunda mirada no cae mal. Veré si puedo caer."
        },
        Panamdirttext = {
            "Oye V. Ya pedí por los dos. Está en el otro mostrador, hasta el fondo con el bartender — a tu cuenta ;P",
            "V, nuestro pedido te espera en el otro mostrador, al fondo junto al bar — y va a tu cuenta ;P"
        },
        Shootingrange = {
            "Oye V. Estoy poniendo blancos cerca del campamento. Si quieres tirar unas balas, cáele.",
            "Tengo un rato para practicar tiro junto al campamento. Pásate si se te antoja."
        },
        ShootingRangeReplies = {
            "Sí, practicar nunca sobra. Igual me doy la vuelta si tengo chance.",
            "Suena como buena forma de no oxidarse. Veré si alcanzo a ir."
        },
        Beach = {
            "Oye V. Voy a la playa de Coast View en Pacifica. Si quieres salirte de la ciudad, cáele.",
            "Estoy por el agua en Coast View. Si se te antoja algo tranquilo, pásate."
        },
        BeachReplies = {
            "Te entiendo, alejarse de la ciudad ayuda. Igual me paso más tarde.",
            "Tranquilo junto al agua suena bien. Veré si alcanzo a ir."
        },
        panamcampfire = {
            "Oye V, armemos una fogata. Consigue unas ramas.",
            "Si tienes chance, junta algo de leña para la fogata, V."
        },
        panamshooting = {
            "V, ponte en posición.",
            "V, muévete a tu puesto."
        },
        panamcarm1 = {
            "Oye V, dale una vuelta — a ver de qué es capaz esta bestia.",
            "Hazla rugir, V, quiero sentir la fuerza."
        },
        panamcarm2 = {
            "Listo, V — gracias. Ya puedes regresar.",
            "Buena vuelta. Gracias, V, tráela de regreso."
        },
        waittime = {
            "V, tuve que irme. Lo dejamos para la próxima.",
            "V, no podía esperar para siempre. Luego lo intentamos de nuevo."
        },

        ["ui_coastview"] = "Coast View",
        ["ui_grab_picnic"] = "Tomar el pícnic",
        ["ui_prepare_meat"] = "Preparar la carne",
        ["ui_join_panam"] = "Reunirse con Panam",
        ["ui_practice"] = "La práctica hace al maestro",
        ["ui_gather_branches"] = "Juntar ramas",
        ["ui_campfire"] = "Fogata",
        ["ui_build_campfire"] = "Hacer una fogata",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "Comprar bebidas (50.00)",
        ["ui_place_drink"] = "Poner la bebida",
        ["ui_watch_performance"] = "Ver el show",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Disfrutar el show",
        ["ui_end_date"] = "Terminar la cita",
        ["ui_meet_panam_caption"] = "PanamDate|Reúnete con Panam|Panam te espera",
        ["ui_shooting_title"] = "La práctica hace al maestro",
        ["ui_short_range"] = "Corto alcance",
        ["ui_long_range"] = "Largo alcance",
        ["ui_cook_meat"] = "Cocinar la carne",

        ["contactName"] = "Panam Palmer"
    },

    ["hu-hu"] = {
        Ending = {
            "Köszi, V. Pont erre volt szükségem.",
            "Köszönöm, V, ez tényleg sokat segített.",
            "Köszi, V. Többet segített, mint hinnéd.",
            "Köszönöm, V. Nagyon értékelem."
        },
        BeachPreJoin = {
            "Figyelj V, mielőtt idejössz, kapj fel pár italt a csomagtartóból.",
            "V, ha tudsz, indulás előtt hozz ki pár piát a csomagtartóból."
        },
        Autofix = {
            "Hé V. A Red Dirtben vagyok. Ha van kedved, ugorj be.",
            "Lemenjek kicsit megnyugodni a Red Dirtbe. Ha akarsz, gyere utánam."
        },
        AutofixReplies = {
            "Értem, hogy jól jönne még egy vélemény. A custom cucc mozgás közben máshogy viselkedik. Lehet, hogy benézek.",
            "Hallatszik, hogy sok munka van benne. Egy második kör ránézés nem árt. Meglátom, belefér-e."
        },
        Panamdirttext = {
            "Hé V, a rendelésünk kész. A másik pultnál van, hátul a pultosnál — természetesen a te számládon ;P",
            "V, a cuccunk a másik pulton vár, hátul a bárnál — és igen, te fizetsz ;P"
        },
        Shootingrange = {
            "Hé V, célpontokat rakok ki a tábor mellett. Ha lőnél párat, gyere.",
            "Van egy kis időm gyakorlásra a tábor közelében. Nézz be, ha van kedved."
        },
        ShootingRangeReplies = {
            "Ja, egy kis gyakorlás sosem árt. Lehet, hogy beugrom, ha lesz időm.",
            "Jól hangzik, jó formában tart. Meglátom, belefér-e."
        },
        Beach = {
            "Hé V. A pacificai Coast View strandra megyek. Ha menekülnél a város elől, gyere.",
            "V, a vízparton vagyok Coast View-nál. Ha kell egy kis nyugi, ugorj be."
        },
        BeachReplies = {
            "Megértem, kell néha kis szünet a várostól. Lehet, hogy később benézek.",
            "Csend a víz mellett jól hangzik. Meglátom, odaérek-e."
        },
        panamcampfire = {
            "Hé V, csináljunk tábortüzet. Szerezz pár ágat.",
            "Ha ráérsz, hozz egy kis fát a tűzhöz, V."
        },
        panamshooting = {
            "V, állj pozícióba.",
            "V, menj a helyedre."
        },
        panamcarm1 = {
            "Hé V, menj vele egy kört — nézzük, mit tud ez a dög.",
            "Nyomd meg neki, V, érezni akarom az erőt."
        },
        panamcarm2 = {
            "Oké V, köszi. Hozd vissza.",
            "Szép kör volt. Köszi, V, jöhetsz vissza."
        },
        waittime = {
            "V, mennem kellett. Legközelebb folytatjuk.",
            "V, nem várhattam a végtelenségig. Majd máskor."
        },

        ["ui_coastview"] = "Coast View",
        ["ui_grab_picnic"] = "Vidd a piknikcuccot",
        ["ui_prepare_meat"] = "Készítsd elő a húst",
        ["ui_join_panam"] = "Csatlakozz Panamhoz",
        ["ui_practice"] = "Gyakorlat teszi a mestert",
        ["ui_gather_branches"] = "Gyűjts ágakat",
        ["ui_campfire"] = "Tábortűz",
        ["ui_build_campfire"] = "Rakj tábortüzet",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "Végy italokat (50.00)",
        ["ui_place_drink"] = "Tedd le az italt",
        ["ui_watch_performance"] = "Nézd az előadást",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Élvezd az előadást",
        ["ui_end_date"] = "Fejezd be a randit",
        ["ui_meet_panam_caption"] = "PanamDate|Találkozz Panammal|Panam rád vár",
        ["ui_shooting_title"] = "Gyakorlat teszi a mestert",
        ["ui_short_range"] = "Rövid táv",
        ["ui_long_range"] = "Hosszú táv",
        ["ui_cook_meat"] = "Süsd meg a húst",

        ["contactName"] = "Panam Palmer"
    },

    ["kr-kr"] = {
        Ending = {
            "고마워, V. 이게 필요했어.",
            "고마워 V, 생각보다 큰 도움이 됐어.",
            "고마워 V. 네가 생각하는 것보다 많이 위로가 됐어.",
            "고마워 V. 진심이야."
        },
        BeachPreJoin = {
            "V, 오기 전에 트렁크에서 마실 것 좀 챙겨 줄래?",
            "헤이 V, 나한테 오기 전에 트렁크에서 술 몇 병만 꺼내 와."
        },
        Autofix = {
            "V, 나 레드 더트에 있어. 오고 싶으면 와.",
            "레드 더트에서 좀 쉬고 있을게. 시간 되면 들러."
        },
        AutofixReplies = {
            "두 번째 의견이 필요하다는 거 이해해. 튜닝은 달리면서 느낌이 달라지니까. 시간 되면 한 번 볼게.",
            "꽤 손 많이 간 것 같네. 한 번 더 확인해 주는 것도 나쁘지 않지. 기회 되면 들를게."
        },
        Panamdirttext = {
            "V, 우리 주문은 이미 나갔어. 반대쪽 바 끝에 있는 바텐더 쪽에 있어 — 물론 네 카드로 ;P",
            "V, 주문 준비됐어. 반대편 바 맨 끝, 바텐더 옆에서 받아 — 계산은 네가 ;P"
        },
        Shootingrange = {
            "V, 캠프 근처에 표적 좀 세워 놨어. 쏘고 싶으면 와.",
            "캠프 옆에서 사격 연습 중이야. 끌리면 들러."
        },
        ShootingRangeReplies = {
            "그래, 연습해 나쁠 건 없지. 시간 나면 한 번 가볼게.",
            "폼 유지하기엔 딱이네. 나중에 한 번 들를지도."
        },
        Beach = {
            "V, 퍼시피카 코스트 뷰 해변으로 갈 거야. 도시가 답답하면 한 번 와봐.",
            "지금 코스트 뷰 물가에 있어. 조용한 데 필요하면 들러."
        },
        BeachReplies = {
            "도시에서 좀 떨어지고 싶은 기분 알아. 나중에 들를지도 몰라.",
            "물가에서 조용히 있는 거 좋지. 시간 되면 한 번 가볼게."
        },
        panamcampfire = {
            "V, 모닥불 하나 피우자. 나뭇가지 좀 모아 와.",
            "시간 되면 불 피울 나무 조금만 가져와, V."
        },
        panamshooting = {
            "V, 자리 잡아.",
            "V, 포지션으로 이동."
        },
        panamcarm1 = {
            "V, 한 바퀴 돌려 봐 — 이 괴물이 뭐 할 수 있는지 보자.",
            "밟아 봐 V, 힘 좀 느껴보자."
        },
        panamcarm2 = {
            "좋아 V, 고마워. 이제 돌아와도 돼.",
            "나이스. 고마워 V, 차 끌고 돌아와."
        },
        waittime = {
            "V, 먼저 갈 수밖에 없었어. 다음에 보자.",
            "V, 계속 기다릴 순 없었어. 다음 기회에."
        },

        ["ui_coastview"] = "코스트 뷰",
        ["ui_grab_picnic"] = "피크닉 준비물 챙기기",
        ["ui_prepare_meat"] = "고기 준비하기",
        ["ui_join_panam"] = "파남에게 가기",
        ["ui_practice"] = "연습이 완성을 만든다",
        ["ui_gather_branches"] = "나뭇가지 모으기",
        ["ui_campfire"] = "모닥불",
        ["ui_build_campfire"] = "모닥불 피우기",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "음료 사기 (50.00)",
        ["ui_place_drink"] = "음료 내려놓기",
        ["ui_watch_performance"] = "공연 보기",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "공연 즐기기",
        ["ui_end_date"] = "데이트 끝내기",
        ["ui_meet_panam_caption"] = "PanamDate|파남 만나기|파남이 널 기다리고 있다",
        ["ui_shooting_title"] = "연습이 완성을 만든다",
        ["ui_short_range"] = "근거리",
        ["ui_long_range"] = "원거리",
        ["ui_cook_meat"] = "고기 굽기",

        ["contactName"] = "파남 팔머"
    },

    ["th-th"] = {
        Ending = {
            "ขอบใจนะ V เราต้องการแบบนี้จริง ๆ",
            "ขอบคุณ V มันช่วยเราได้เยอะเลย",
            "ขอบใจ V มันช่วยมากกว่าที่คิดนะ",
            "ขอบคุณ V เราซึ้งจริง ๆ"
        },
        BeachPreJoin = {
            "V ก่อนมาหา ช่วยแวะหยิบเครื่องดื่มจากท้ายรถให้หน่อยได้ไหม",
            "เฮ้ V ระหว่างทางมานี่ แวะเปิดท้ายรถเอาเครื่องดื่มมาด้วยนะ"
        },
        Autofix = {
            "เฮ้ V เราอยู่ที่ Red Dirt ถ้าอยากมาก็มาได้เลย",
            "จะไปนั่งชิลที่ Red Dirt ถ้าอยากมาด้วยก็มาเลย"
        },
        AutofixReplies = {
            "เข้าใจนะที่อยากได้มุมมองเพิ่ม งานแต่งรถพอวิ่งจริง ๆ มันเปลี่ยนฟีลได้ ไว้มีโอกาสจะไปดูให้.",
            "ฟังดูเหมือนตั้งใจทำมาก ๆ เลย ขออีกคนช่วยดูให้ก็ไม่เสียหาย เดี๋ยวดูว่าพอจะแวะไปได้ไหม."
        },
        Panamdirttext = {
            "V เราสั่งของไว้แล้วนะ อยู่ที่เคาน์เตอร์อีกฝั่ง ด้านในสุดตรงบาร์เทนเดอร์ — ตัดบิลชื่อเธอ ;P",
            "V ออเดอร์รออยู่ที่เคาน์เตอร์อีกฝั่ง ด้านในสุดใกล้บาร์ — แล้วก็คิดเงินเธอไว้แล้วนะ ;P"
        },
        Shootingrange = {
            "V เราตั้งเป้าแถวแคมป์อยู่ ถ้าอยากมาลองยิงก็มาดิ",
            "มีเวลาซ้อมยิงแถวค่ายนิดหน่อย ถ้าอยากมาก็แวะมาได้"
        },
        ShootingRangeReplies = {
            "ซ้อมไว้ไม่เสียหาย เดี๋ยวถ้ามีเวลาจะลองแวะไป.",
            "ฟังดูดีนะ ไว้ดูเวลาก่อนว่าพอไปได้ไหม."
        },
        Beach = {
            "V เราจะไปชายหาด Coast View ที่ Pacifica ถ้าอยากหนีเมืองซักพักก็มาด้วยกันได้",
            "ตอนนี้เราอยู่ริมน้ำที่ Coast View ถ้าอยากหาที่เงียบ ๆ แวะมาได้เลย"
        },
        BeachReplies = {
            "เข้าใจเลยว่าบางทีก็อยากออกห่างจากเมือง เดี๋ยวลองดูว่าพอจะแวะไปได้ไหม.",
            "เงียบ ๆ ริมน้ำนี่ฟังดูดีเลย ไว้มีจังหวะจะลองไปดู."
        },
        panamcampfire = {
            "V มาก่อกองไฟกัน หาไม้กิ่งไม้มาให้หน่อย",
            "ถ้าว่างก็ช่วยเก็บกิ่งไม้สำหรับกองไฟให้หน่อยนะ V"
        },
        panamshooting = {
            "V เข้าประจำตำแหน่ง.",
            "V ขยับไปยืนตรงจุดของเธอ."
        },
        panamcarm1 = {
            "V ลองขับวนซักรอบสิ อยากเห็นว่าหล่อนทำได้แค่ไหน",
            "กดคันเร่งดูหน่อย V อยากรู้แรงส่งจริง ๆ"
        },
        panamcarm2 = {
            "โอเค V ขอบใจนะ เอากลับมาได้เลย",
            "ขับดีเลย ขอบใจ V พาเธอกลับมาได้แล้ว"
        },
        waittime = {
            "V เราต้องไปก่อน ไว้เจอกันใหม่ครั้งหน้า",
            "V รอได้ไม่นานขนาดนั้น ไว้ค่อยลองใหม่อีกที"
        },

        ["ui_coastview"] = "Coast View",
        ["ui_grab_picnic"] = "หยิบของปิกนิก",
        ["ui_prepare_meat"] = "เตรียมเนื้อ",
        ["ui_join_panam"] = "ไปหา Panam",
        ["ui_practice"] = "ยิ่งฝึกยิ่งเก่ง",
        ["ui_gather_branches"] = "เก็บกิ่งไม้",
        ["ui_campfire"] = "กองไฟ",
        ["ui_build_campfire"] = "ก่อกองไฟ",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "ซื้อเครื่องดื่ม (50.00)",
        ["ui_place_drink"] = "วางเครื่องดื่ม",
        ["ui_watch_performance"] = "ดูการแสดง",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "สนุกกับการแสดง",
        ["ui_end_date"] = "จบเดต",
        ["ui_meet_panam_caption"] = "PanamDate|ไปหา Panam|Panam กำลังรออยู่",
        ["ui_shooting_title"] = "ยิ่งฝึกยิ่งเก่ง",
        ["ui_short_range"] = "ระยะใกล้",
        ["ui_long_range"] = "ระยะไกล",
        ["ui_cook_meat"] = "ปรุงเนื้อ",

        ["contactName"] = "Panam Palmer"
    },

    ["tr-tr"] = {
        Ending = {
            "Sağ ol V. Buna gerçekten ihtiyacım vardı.",
            "Teşekkürler V, düşündüğünden daha çok iyi geldi.",
            "Sağ ol V. Sandığından fazla yardımcı oldun.",
            "Teşekkürler V. Bunu gerçekten takdir ediyorum."
        },
        BeachPreJoin = {
            "V, gelmeden önce bagajdan biraz içecek alabilir misin?",
            "Hey V, buraya gelmeden önce bagajdaki içecekleri kap gel, olur mu?"
        },
        Autofix = {
            "Hey V. Red Dirt'teyim. İstersen uğra.",
            "Biraz kafa dinlemek için Red Dirt'e geçiyorum. Canın isterse gel."
        },
        AutofixReplies = {
            "Başka bir göz daha istemeni anlıyorum. Özel iş, araba yolda olunca bambaşka hissedilir. Belki uğrarım.",
            "Üzerinde baya çalışmışsın belli. İkinci bir bakış hiç fena olmaz. Bakalım yolum düşer mi."
        },
        Panamdirttext = {
            "Hey V, siparişimizi çoktan verdim. Diğer tezgahta, en uçta barmenin yanında — hesabı da sana yazdırdım ;P",
            "V, bizimki diğer taraftaki tezgâhta bekliyor, en uçta barın orada — ve evet, sen ödüyorsun ;P"
        },
        Shootingrange = {
            "Hey V, kampın yanında birkaç hedef kuruyorum. Biraz ateş etmek istersen uğra.",
            "Kamp yakınında atış talimi için biraz vaktim var. Canın isterse uğra."
        },
        ShootingRangeReplies = {
            "Aynen, pratik her zaman işe yarar. Boş kalırsam belki gelirim.",
            "Formu korumak için iyi fikir. Zaman bulursam uğramaya çalışırım."
        },
        Beach = {
            "Hey V. Pacifica'daki Coast View sahiline gidiyorum. Şehirden kaçmak istersen gel.",
            "Şu an Coast View'da, suyun kenarındayım. Sessizlik istiyorsan uğra."
        },
        BeachReplies = {
            "Şehirden uzaklaşma isteğini anlıyorum. Belki sonra gelirim.",
            "Suyun kenarında sakinlik fena fikir değil. Zaman bulursam uğrayabilirim."
        },
        panamcampfire = {
            "Hey V, hadi kamp ateşi yakalım. Biraz dal getir.",
            "V, vaktin olursa kamp ateşi için birkaç dal topla."
        },
        panamshooting = {
            "V, pozisyonunu al.",
            "V, yerini al ve bekle."
        },
        panamcarm1 = {
            "Hey V, bir tur at — şu canavar ne yapabiliyor görelim.",
            "Bas gaza V, gücünü hissetmek istiyorum."
        },
        panamcarm2 = {
            "Tamam V, sağ ol. Artık geri dönebilirsin.",
            "Güzel turdu. Sağ ol V, arabayı geri getir."
        },
        waittime = {
            "V, gitmem gerekti. Bir dahaki sefere.",
            "V, sonsuza kadar bekleyemezdim. Sonra tekrar deneriz."
        },

        ["ui_coastview"] = "Coast View",
        ["ui_grab_picnic"] = "Piknik malzemelerini al",
        ["ui_prepare_meat"] = "Eti hazırla",
        ["ui_join_panam"] = "Panam'e katıl",
        ["ui_practice"] = "Pratik ustalaştırır",
        ["ui_gather_branches"] = "Daldan toplama",
        ["ui_campfire"] = "Kamp ateşi",
        ["ui_build_campfire"] = "Kamp ateşi yak",
        ["ui_autofix"] = "Autofix",
        ["ui_buy_drinks"] = "İçecek al (50.00)",
        ["ui_place_drink"] = "İçeceği bırak",
        ["ui_watch_performance"] = "Gösteriyi izle",
        ["ui_red_dirt"] = "Red Dirt",
        ["ui_enjoy_performance"] = "Gösterinin tadını çıkar",
        ["ui_end_date"] = "Buluşmayı bitir",
        ["ui_meet_panam_caption"] = "PanamDate|Panam'le buluş|Panam seni bekliyor",
        ["ui_shooting_title"] = "Pratik ustalaştırır",
        ["ui_short_range"] = "Kısa menzil",
        ["ui_long_range"] = "Uzun menzil",
        ["ui_cook_meat"] = "Eti pişir",

        ["contactName"] = "Panam Palmer"
    }
}

local LEAVING_MESSAGES = {
    ["en-us"] = {
        "V, if you had to leave, you should've told me before setting this up.",
        "V, next time give me a warning.",
        "Well... guess I'll see you around.",
        "You could've just said you needed to go, V.",
        "V, don't make plans with me if you're going to bail.",
        "If something came up, just tell me next time.",
        "I waited for you, V. That's not great.",
        "V, I can handle the truth. Just say you have to leave.",
        "Alright, V. We'll call it here.",
        "Fine. Next time, just give me a heads-up."
    },
    ["fr-fr"] = {
        "V, si tu devais partir, tu aurais dû me le dire avant d'organiser ça.",
        "V, la prochaine fois, préviens-moi.",
        "Bon... on se recroisera.",
        "Tu pouvais simplement dire que tu devais partir, V.",
        "V, ne fais pas de plans avec moi si c'est pour partir comme ça.",
        "S'il y a un imprévu, dis-le-moi la prochaine fois.",
        "Je t'ai attendu, V. C'est pas terrible.",
        "V, je préfère la vérité. Dis juste que tu dois y aller.",
        "D'accord, V. On en reste là.",
        "Très bien. La prochaine fois, un petit avertissement."
    },
    ["es-es"] = {
        "V, si tenías que irte, deberías haberme avisado antes de organizar esto.",
        "V, la próxima vez avísame.",
        "Bueno... supongo que nos veremos.",
        "Podías haber dicho que te tenías que ir, V.",
        "V, no hagas planes conmigo si vas a desaparecer así.",
        "Si surgió algo, dímelo la próxima vez.",
        "Te estuve esperando, V. No estuvo bien.",
        "V, prefiero que me lo digas claro: si te vas, dímelo.",
        "Vale, V. Lo dejamos aquí.",
        "Está bien. La próxima, dame un aviso."
    },
    ["pl-pl"] = {
        "V, jeśli musiałaś iść, trzeba było powiedzieć przed umawianiem tego.",
        "V, następnym razem daj znać wcześniej.",
        "No cóż... chyba do zobaczenia.",
        "Mogłaś po prostu powiedzieć, że musisz iść, V.",
        "V, nie umawiaj się ze mną, jeśli masz zniknąć.",
        "Jeśli coś wyskoczyło, po prostu powiedz następnym razem.",
        "Czekałam na ciebie, V. To nie było okej.",
        "V, wolę szczerość. Powiedz po prostu, że musisz lecieć.",
        "Dobra, V. Na tym kończymy.",
        "W porządku. Następnym razem uprzedź mnie."
    },
    ["pt-br"] = {
        "V, se você tinha que ir, devia ter avisado antes de marcar isso.",
        "V, da próxima vez me dá um aviso.",
        "Bom... acho que te vejo por aí.",
        "Você podia ter só dito que precisava sair, V.",
        "V, não marca comigo se for pra sumir assim.",
        "Se apareceu algo, só me fala da próxima vez.",
        "Fiquei te esperando, V. Não foi legal.",
        "V, prefiro sinceridade. Se for sair, só fala.",
        "Tá bom, V. Vamos encerrar por aqui.",
        "Beleza. Na próxima, me avisa antes."
    },
    ["ru-ru"] = {
        "V, если тебе нужно было уйти, надо было сказать до того, как мы это устроили.",
        "V, в следующий раз предупреждай.",
        "Ладно... увидимся где-нибудь.",
        "Ты могла просто сказать, что тебе надо уйти, V.",
        "V, не строй планы со мной, если собираешься так уйти.",
        "Если что-то случилось, просто скажи в следующий раз.",
        "Я ждала тебя, V. Это так себе.",
        "V, я нормально отношусь к правде. Просто скажи, что уходишь.",
        "Хорошо, V. На этом закончим.",
        "Ладно. В следующий раз просто предупреди."
    },
    ["ja-jp"] = {
        "V、帰る必要があったなら、約束する前に言ってほしかった。",
        "V、次は先にひと言ちょうだい。",
        "まあ…またそのうちね。",
        "帰るなら、そう言ってくれればよかったのに、V。",
        "V、抜けるつもりなら最初から約束しないで。",
        "用事ができたなら、次はちゃんと言って。",
        "待ってたんだよ、V。正直きつい。",
        "V、私は正直に言ってくれれば平気。帰るならそう言って。",
        "わかった、V。今日はここまで。",
        "いいよ。次はちゃんと知らせて。"
    },
    ["zh-cn"] = {
        "V，你要走的话，安排之前就该告诉我。",
        "V，下次提前打个招呼。",
        "行吧……有缘再见。",
        "你本来可以直接说你要走，V。",
        "V，要是要中途走，就别先约我。",
        "如果临时有事，下次直接说。",
        "我一直在等你，V。这感觉不太好。",
        "V，我接受实话。要走就直说。",
        "好吧，V。今天就到这。",
        "行。下次至少提前说一声。"
    },
    ["zh-tw"] = {
        "V，你要離開的話，安排之前就該先說。",
        "V，下次先打聲招呼。",
        "好吧……那就改天見。",
        "你其實可以直接說你要走，V。",
        "V，如果會中途離開，就別先約我。",
        "如果臨時有事，下次直接說。",
        "我一直在等你，V。這感覺不太好。",
        "V，我接受實話。要走就直說。",
        "好，V。今天就到這裡。",
        "行。下次至少先說一聲。"
    },
    ["de-de"] = {
        "V, wenn du gehen musstest, hättest du es vorab sagen sollen.",
        "V, gib mir nächstes Mal vorher Bescheid.",
        "Na gut... man sieht sich wohl.",
        "Du hättest einfach sagen können, dass du wegmusst, V.",
        "V, mach keine Pläne mit mir, wenn du dann einfach abhaust.",
        "Wenn was dazwischenkommt, sag es mir nächstes Mal.",
        "Ich habe auf dich gewartet, V. Das war nicht gut.",
        "V, ich komme mit Ehrlichkeit klar. Sag einfach, dass du gehen musst.",
        "Alles klar, V. Dann lassen wir es hier.",
        "Schon gut. Aber nächstes Mal sag vorher Bescheid."
    },
    ["it-it"] = {
        "V, se dovevi andare via, dovevi dirmelo prima di organizzare tutto questo.",
        "V, la prossima volta avvisami prima.",
        "Beh... immagino ci vedremo in giro.",
        "Potevi semplicemente dire che dovevi andare, V.",
        "V, non fare programmi con me se poi te ne vai così.",
        "Se è successo qualcosa, la prossima volta dimmelo.",
        "Ti ho aspettato, V. Non è stato il massimo.",
        "V, con la verità non ho problemi. Dimmi solo che devi andare.",
        "Va bene, V. Chiudiamola qui.",
        "D'accordo. La prossima volta almeno avvisami."
    },
    ["ar-ar"] = {
        "V، إذا كان لازم تمشي، كان لازم تقول قبل ما نرتب كل هذا.",
        "V، المرة الجاية نبّهني قبلها.",
        "طيب... شكلنا بنلتقي لاحقًا.",
        "كان فيك بس تقول إنك لازم تمشي يا V.",
        "V، لا ترتب معي إذا كنت رح تتركها وتمشي.",
        "إذا صار شيء طارئ، بس خبرني المرة الجاية.",
        "استنيتك يا V. ما كان شعور حلو.",
        "V، أنا بتقبل الصراحة. بس قل إنك لازم تمشي.",
        "تمام يا V. خلينا ننهيها هون.",
        "ماشي. بس المرة الجاية عطيني خبر مسبق."
    },
    ["cz-cz"] = {
        "V, jestli jsi musel*a odejít, měl*a jsi to říct dřív, než jsme to domluvili.",
        "V, příště mi dej vědět předem.",
        "No... asi se uvidíme jindy.",
        "Mohl*a jsi prostě říct, že musíš jít, V.",
        "V, neplánuj to se mnou, když pak zmizíš.",
        "Jestli něco přišlo do cesty, příště mi to řekni.",
        "Čekala jsem na tebe, V. To nebylo moc fér.",
        "V, pravdu zvládnu. Prostě řekni, že musíš odejít.",
        "Dobře, V. Tím to končíme.",
        "Fajn. Příště aspoň dej vědět dopředu."
    },
    ["es-mx"] = {
        "V, si te tenías que ir, debiste decirlo antes de armar todo esto.",
        "V, la próxima avísame antes.",
        "Bueno... supongo que nos vemos luego.",
        "Podías solo decir que te tenías que ir, V.",
        "V, no hagas planes conmigo si te vas a ir así.",
        "Si te salió algo, solo dímelo la próxima vez.",
        "Me quedé esperándote, V. No estuvo chido.",
        "V, yo aguanto la verdad. Solo dime que te tienes que ir.",
        "Está bien, V. Aquí lo dejamos.",
        "Va. Pero la próxima sí avísame con tiempo."
    },
    ["hu-hu"] = {
        "V, ha menned kellett, ezt előbb kellett volna mondanod.",
        "V, legközelebb szólj előre.",
        "Na... majd összefutunk.",
        "Csak megmondhattad volna, hogy menned kell, V.",
        "V, ne tervezz velem, ha aztán csak lelépsz.",
        "Ha közbejött valami, legközelebb csak szólj.",
        "Vártam rád, V. Ez így nem volt túl korrekt.",
        "V, elbírom az igazat. Mondd ki, ha menned kell.",
        "Rendben, V. Akkor itt lezárjuk.",
        "Jó. De legközelebb legalább szólj előre."
    },
    ["kr-kr"] = {
        "V, 가야 했으면 이렇게 잡기 전에 말했어야지.",
        "V, 다음엔 미리 말해 줘.",
        "뭐... 또 보겠지.",
        "가야 하면 그냥 그렇다고 말하면 됐잖아, V.",
        "V, 이렇게 빠질 거면 나랑 약속 잡지 마.",
        "무슨 일이 생겼으면 다음엔 그냥 말해.",
        "기다렸어, V. 기분 좋진 않네.",
        "V, 난 솔직한 거 괜찮아. 가야 하면 그냥 말해.",
        "알겠어, V. 여기서 끝내자.",
        "좋아. 다음엔 적어도 미리 알려 줘."
    },
    ["th-th"] = {
        "V ถ้าต้องไป ก็น่าจะบอกก่อนจะนัดกันแบบนี้",
        "V ครั้งหน้าบอกกันล่วงหน้าหน่อย",
        "ก็ได้... ไว้คงได้เจอกัน",
        "แค่บอกมาก็ได้ว่าต้องไปนะ V",
        "V อย่านัดฉันถ้าสุดท้ายจะเทกันแบบนี้",
        "ถ้ามีอะไรแทรก ก็บอกฉันครั้งหน้า",
        "ฉันรอเธออยู่นะ V มันไม่ค่อยโอเคเลย",
        "V ฉันรับความจริงได้ แค่บอกว่าต้องไป",
        "โอเค V งั้นจบแค่นี้",
        "ได้ แต่ครั้งหน้าช่วยบอกล่วงหน้าด้วย"
    },
    ["tr-tr"] = {
        "V, gitmen gerekiyorsa bunu planlamadan önce söylemeliydin.",
        "V, bir dahakine önceden haber ver.",
        "Pekâlâ... herhalde yine görüşürüz.",
        "Gitmen gerekiyorsa söyleyebilirdin, V.",
        "V, sonra ortadan kaybolacaksan benimle plan yapma.",
        "Araya bir şey girdiyse bir dahakine söyle yeter.",
        "Seni bekledim, V. Hoş değildi.",
        "V, gerçeği kaldırırım. Gitmen gerekiyorsa açıkça söyle.",
        "Tamam, V. Burada kapatalım.",
        "Peki. Ama bir dahakine en azından önceden haber ver."
    }
}

function lang.getLang()
    local l = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    if lang[l] == nil then
        return "en-us"
    else
        return l
    end
end

-- Language-aware random incoming picker (with fallback to en-us)
function lang.panamIncoming(category)
    local l = lang.getLang()
    local pool = lang[l] and lang[l][category]

    if type(pool) ~= "table" or #pool == 0 then
        pool = lang["en-us"] and lang["en-us"][category]
    end
    if type(pool) ~= "table" or #pool == 0 then
        return nil
    end

    return pool[math.random(#pool)]
end

function lang.getText(key, category)
    if key == "panamIncoming" and category then
        return lang.panamIncoming(category)
    end

    local l = lang.getLang()
    local text = lang[l] and lang[l][key]
    if not text then
        return lang["en-us"][key]
    end
    return text
end

function lang.getKey(text)
    for k, v in pairs(lang[lang.getLang()]) do
        if v == text then return k end
    end
end

function lang.getRandomFromCategory(category)
    local l = lang.getLang()

    if category == "Leaving" then
        local rawLang = nil
        local ok, val = pcall(function()
            return Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
        end)
        if ok then rawLang = val end

        local leavePool = LEAVING_MESSAGES[rawLang] or LEAVING_MESSAGES[l] or LEAVING_MESSAGES["en-us"]
        if type(leavePool) == "table" and #leavePool > 0 then
            return leavePool[math.random(#leavePool)]
        end
    end

    local pool = lang[l] and lang[l][category]

    if type(pool) ~= "table" or #pool == 0 then
        return ""
    end

    return pool[math.random(#pool)]
end

return lang