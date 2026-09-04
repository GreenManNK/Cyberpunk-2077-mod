return {
    -- Mounted/on-foot prompts shown during zone/shop interaction flow.
    prompt = {
        transaction_leave_shop = "Leave the Shop Area on foot to finalize transaction.",
        mounted_zone_transaction = "Exit the vehicle, then leave the zone on foot to finish the transaction.",
        raw_records_claim = "Unsupported Configuration: Raw Records Enabled",
        smuggler_paperwork = "You don't own this vehicle. We only take vehicles with clean papers.",
        mounted_paint_preview = "Stay in the vehicle while the paint preview cycles. Exit the vehicle to apply the selected paint.",
    },

    -- Sale appraisal flavor messages.
    pricing = {
        condition_low = "The shop paid less for the vehicle's condition.",
        gang_low = "The shop paid less for the gang vehicle.",
        parts_low = "The shop paid less because the vehicle is only good for parts.",
        police_bonus = "There is always a buyer for a good masquerade.",
        corporate_bonus = "The shop paid more for the corporate vehicle.",
        premium_bonus = "The shop paid more for the premium package.",
        suburban_bonus = "The shop paid more for the suburban package.",
        clean_condition_bonus = "The shop paid slightly more for the clean condition.",
        wraith_discount = "The shop paid less for the Wraiths' reputation.",
        nomad_bonus = "The shop paid more for the nomad build.",
    },

    notify = {
        system = {
            vehicle_system_error = "Unable to complete transaction - Vehicle System Error. Save the game session, exit Cyberpunk 2077 completely and restart the game.",
        },
        backup = {
            manual_saved = "COSV manual backup saved. Stored {count} mod vehicles from your garage.",
            manual_failed = "COSV manual backup failed.",
            manual_restored = "COSV manual restore completed. Restored {restored} of {total} backed-up mod vehicles.",
            manual_restore_failed = "COSV manual restore failed.",
            last_transaction_restored = "COSV last transaction state restored. Restored {restored} of {total} backed-up mod vehicles.",
            last_transaction_restore_failed = "COSV last transaction restore failed.",
        },
        unlock = {
            not_enough_eddies = "Not enough eddies to hack this vehicle's access key.",
            already_managed = "This vehicle is already managed as a unique owned vehicle.",
            cannot_register = "This vehicle cannot be claimed safely.",
            success_fee = "We unlocked your car, choomba. Call it from your garage. Charged you E${fee}.",
            success_fee_with_repair = "We unlocked your car, choomba. Call it from your garage. Repaired your car too.\nKey hack: E${fee}    Repair: E${repair}    Total: E${total}",
            lemon_warning = "Car's in your garage, choom. Raw record though — no identity rewrite. It's a lemon. Flip it at the junk shop unless it is your grandma's ride.",
            protected_firmware = "Claim denied. The vehicle's firmware blocked the exploit.",
        },
        sale = {
            already_sold = "This vehicle has already been sold.",
            smuggler_premium = "Smuggler premium: +10%",
            receipt = "You sold your vehicle for E$${payout}.",
        },
        -- Paint preview and repaint transaction notifications.
        paint = {
            applied = "Paint applied: {appearance}",
            preview_current = "Paint preview: {appearance}",
            preview_intro = "Stay in your car while we show you the paints. If you like something cost will be {cost}",
            farewell = "Call your fresh-looking wheels from the garage, choomba.",
            canceled = "Paint preview canceled.",
            unavailable = "I couldn't find supported paint variants for this vehicle. Try a different COSV service vehicle.",
            unsupported_vehicle = "This paint service only works on COSV garage slots from this mod.",
            claim_failure = "The selected paint could not be saved to your garage slot.",
            insufficient_funds = "Sorry Choomba you don't have enough money. Come when you do!",
        },
        shop = {
            closed = "{shop} is still processing the last vehicle you brought in. Come back later.",
            garage_alteration_warning = "Unsupported Configuration: Altered Garage",
        },
    },

    -- World-map names, descriptions, and rejection text for shops/drop-offs.
    shop = {
        -- Hack shops that convert stolen vehicles into owned garage entries.
        watsonKeyHackShop = {
            name = "Watson Key Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        pacificaHackShop = {
            name = "Pacifica Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        westWindHackShop = {
            name = "Pacifica West Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        japanTownHackShop = {
            name = "Japan Town Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        ranchoCoronadoHackShop = {
            name = "Rancho Coronado Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        heywoodHackShop = {
            name = "Heywood Wellsprings Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        vistaDelReyHackShop = {
            name = "Vista Del Rey Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        rockyRidgeHackShop = {
            name = "Rocky Ridge Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        watsonOldShop = {
            name = "Watson Old Hack Shop",
            description = "Bring stolen vehicles here to rewrite access and add them to your garage.",
        },
        badlandsJunkShop = {
            name = "Badlands Junk Shop",
            description = "Bring vehicles here if you are done asking questions about ownership.",
        },
        -- Smuggler drop-off locations.
        badlands_east_smuggler = {
            name = "Badlands East Smuggler",
            description = "Car Smugglers Drop-Off.",
        },
        badlands_west_smuggler = {
            name = "Biotechnica Flats Smuggler Drop-Off",
            description = "Car Smugglers Drop-Off.",
        },
        dakota_smuggler_shop = {
            name = "Aldecaldos Smugglers",
            description = "Car Smugglers Drop-Off.",
        },
        dakota_smuggler_shop_north = {
            name = "Aldecaldos Smugglers (North)",
            description = "Car Smugglers Drop-Off.",
        },
        dakota_smuggler_shop_highlands = {
            name = "Aldecaldos Smugglers (Highlands)",
            description = "Car Smugglers Drop-Off.",
        },
        north101_smuggler_shop_oilfields = {
            name = "Aldecaldos Smugglers Drop-Off (Oilfields)",
            description = "Car Smugglers Drop-Off.",
        },
        -- Main chop/junk buyers.
        southernBadlandsChopShop = {
            name = "Southern Badlands Chop Shop",
            description = "Bring vehicles here if you are done asking questions about ownership.",
        },
        biotechnicaFlatsChopShop = {
            name = "Biotechnica Flats Chop Shop",
            description = "Bring vehicles here if you are done asking questions about ownership.",
        },
        -- Bike-only flat-rate buyer.
        watsonBikeBuyer = {
            name = "Watson Bike Buyer",
            description = "Bike-only buyer. Flat rate, no negotiation.",
            reject = "We only accept these models: Arch, Kusanagi, and Apollo. Flat rate: 3500 per bike. Not negotiable.",
        },
        -- Low-payout anonymous drop-offs.
        northWatsonDropoff = {
            name = "No Questions Asked Drop-Off",
            description = "Cheap local drop-off for stolen vehicles.",
            reject = "This drop-off does not accept Rayfield or Herrera vehicles.",
        },
        heywoodWellspringsDropoff = {
            name = "No Questions Asked Drop-Off",
            description = "Cheap local drop-off for stolen vehicles.",
            reject = "This drop-off does not accept Rayfield or Herrera vehicles.",
        },
        ranchoCoronadoDropoff = {
            name = "No Questions Asked Drop-Off",
            description = "Cheap local drop-off for stolen vehicles.",
            reject = "This drop-off does not accept Rayfield or Herrera vehicles.",
        },
        japanTownDropoff = {
            name = "No Questions Asked Drop-Off",
            description = "Cheap local drop-off for stolen vehicles.",
            reject = "This drop-off does not accept Rayfield or Herrera vehicles.",
        },
        pacificaChapelDropoff = {
            name = "No Questions Asked Drop-Off",
            description = "Cheap local drop-off for stolen vehicles.",
            reject = "This drop-off does not accept Rayfield or Herrera vehicles.",
        },
        -- Paint shops for COSV repaint flow.
        cityPaintShop = {
            name = "Watson Paint Shop",
            description = "COSV Paint Shop.",
        },
        ranchoCoronadoPaintShop = {
            name = "Rancho Coronado Paint Shop",
            description = "COSV Paint Shop.",
        },
        vistaDelReyPaintShop = {
            name = "Vista Del Rey Paint Shop",
            description = "COSV Paint Shop.",
        },
        sunsetMotelPaintshop = {
            name = "Sunset Motel Paint Shop",
            description = "Cosmetic repaint service for COSV-owned vehicles.",
        },
        japantownPainShop = {
            name = "Japantown Paint Shop",
            description = "Cosmetic repaint service for COSV-owned vehicles.",
        },
        pacificaPaintShop = {
            name = "Pacifica Paint Shop",
            description = "Cosmetic repaint service for COSV-owned vehicles.",
        },
        -- Optional Dogtown quick drop-off for Phantom Liberty area.
        dogtownDropoff = {
            name = "No Questions Asked Drop-Off",
            description = "Cheap local drop-off for stolen vehicles.",
            reject = "This drop-off does not accept Rayfield or Herrera vehicles.",
        },
    },

    -- CET settings overlay labels.
    overlay = {
        sliders = {
            hack_shop_fee = "Hack Shop Fee",
            vehicle_sale_payout = "Vehicle Sale Payout",
        },
        toggles = {
            appearance_refresh_debug = "Enable Appearance Refresh Debug",
            dogtown_dropoff = "Enable Dogtown Drop-Off",
            raw_records = "Enable Raw Records (NO SUPPORT! Restart required)",
            use_slots_as_paint_source = "Use Slots As Paint Source (Use declared COSV slots for repaint preview candidates)",
            apply_remote_hack = "Apply Remote Hack (Debug function)",
            enable_stubborn_claim = "Enable Stubborn Claim (Check this if you actively claim and sell)",
        },
        buttons = {
            create_manual_backup = "Create Manual Backup",
            restore_manual_backup = "Restore Manual Backup",
            restore_last_transaction_state = "Restore Last Transaction State",
        },
    },

    -- CET hotkey display labels.
    hotkey = {
        paint_next = "COSV Paint: Next Skin",
        paint_prev = "COSV Paint: Previous Skin",
    },
}
