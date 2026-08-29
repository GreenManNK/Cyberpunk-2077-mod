import LizziesBDs.Classes.*

@addMethod(gameuiInGameMenuGameController)
protected cb func f80hCharSOmi(event: ref<CustomCharacterLoaderEvent>) -> Bool {

	let f80hCateg = event.AddCategoryPic(
        "f80h Songbird",
        "This is the f80h Songbird category",
        "f80h",
        r"ep1\\characters\\main_npc\\songbird\\lbd\\f80h_lbd_songbird.inkatlas",
        n"somi_def",
        0
    );

    event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"ep1\\quest\\primary_characters\\songbird.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "default",
                "default",
                r"ep1\\characters\\main_npc\\songbird\\lbd\\f80h_lbd_songbird.inkatlas",
                n"somi_def",
                0,
                n"songbird_default",
                n"songbird_nude"
            )
        ],
        [
            f80hCateg
        ]
    );

    event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"ep1\\quest\\primary_characters\\songbird.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Paradise outfit",
                "Paradise outfit",
                r"ep1\\characters\\main_npc\\songbird\\lbd\\f80h_lbd_songbird.inkatlas",
                n"somi_def",
                0,
                n"songbird_paradise",
                n"songbird_nude"
            )
        ],
        [
            f80hCateg
        ]
    );	
	
    event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"ep1\\quest\\primary_characters\\songbird.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Jacket",
                "Jacket",
                r"ep1\\characters\\main_npc\\songbird\\lbd\\f80h_lbd_songbird.inkatlas",
                n"somi_def",
                0,
                n"songbird_blendable",
                n"songbird_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
    event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"ep1\\quest\\primary_characters\\songbird.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Possessed",
                "Possessed",
                r"ep1\\characters\\main_npc\\songbird\\lbd\\f80h_lbd_songbird.inkatlas",
                n"somi_def",
                0,
                n"songbird__q305__possessed",
                n"songbird_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
}
