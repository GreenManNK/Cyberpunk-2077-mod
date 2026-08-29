import LizziesBDs.Classes.*

@addMethod(gameuiInGameMenuGameController)
protected cb func f80hCharJudy(event: ref<CustomCharacterLoaderEvent>) -> Bool {

	let f80hCateg = event.AddCategoryPic(
        "f80h Judy",
        "This is the f80h Judy category",
        "f80h",
        r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
        n"judy_def",
        0
    );



    event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\quest\\secondary_characters\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy with tattoos",
                "Judy with tattoos",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_def",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	 event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\notattoo\\judy_notatt.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy without tattoos",
                "Judy without tattoos",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_def",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	 event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\alt_body\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy alternative body with tattoos",
                "Judy alternative body with tattoos",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_def",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );

	 event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\alt_body_notatt\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy alternative body without tattoos",
                "Judy alternative body without tattoos",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_def",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	 event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\slutty\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy slutty",
                "Judy slutty",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_def",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	 event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\nude\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy nude",
                "Judy nude",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_def",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\skirt\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy with skirt",
                "Judy with skirt",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_skirt",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );

	event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\outfits\\gym\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy gym outfit",
                "Judy gym outfit",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_gym",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\pijama\\gym\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy pijama outfit",
                "Judy pijama outfit",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_pj",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
	
	event.AddCharacterCateg(
        GenderType.Female,
        300,
        r"base\\characters\\main_npc\\judy\\pijama\\monokini\\judy.ent",
        "f80h",
        [
            CustomCharacterApp.CreatePic(
                "Judy monokini outfit",
                "Judy monokini outfit",
                r"base\\characters\\main_npc\\judy\\lbd\\f80h_lbd_judy.inkatlas",
                n"judy_swim",
                0,
                n"judy_glove",
                n"judy_nude"
            )
        ],
        [
            f80hCateg
        ]
    );
}
