local lang = {
    ["de-de"] = {
        -- Einstellungen
        ["techie_truck/logo-displayName"] = "Techie Truck - Leuchtendes Logo",
        ["showers/immersive_curtains_opacity"] = "Duschen - Immersive Vorhänge",
        ["v_tent/box-displayName"] = "Panams Zelt – Große Kiste auf dem Tisch",
    },
    ["en-us"] = {
        -- settings
        ["techie_truck/logo-displayName"] = "Techie truck - Emissive logo",
        ["showers/immersive_curtains_opacity"] = "Showers - Immersive curtains",
        ["v_tent/box-displayName"] = "Panam's Tent - Large box on the table",
    },
    ["fr-fr"] = {
        -- paramètres
        ["techie_truck/logo-displayName"] = "Camion Techie - Logo lumineux",
        ["showers/immersive_curtains_opacity"] = "Douches - Rideaux immersifs",
        ["v_tent/box-displayName"] = "Tente de Panam - Grande boîte sur la table"
    },
    ["pl-pl"] = {
        -- ustawienia
        ["techie_truck/logo-displayName"] = "Techie truck - Podświetlone logo",
        ["showers/immersive_curtains_opacity"] = "Prysznice - Zanurzające zasłony",
        ["v_tent/box-displayName"] = "Namiot Panam – Duże pudełko na stole"
    },
    ["es-es"] = {
        -- configuraciones
        ["techie_truck/logo-displayName"] = "Techie truck - Logo luminoso",
        ["showers/immersive_curtains_opacity"] = "Duchas - Cortinas inmersivas",
        ["v_tent/box-displayName"] = "Tienda de Panam – Caja grande sobre la mesa"
    },
    ["es-mx"] = {
        -- configuraciones
        ["techie_truck/logo-displayName"] = "Techie truck - Logo luminoso",
        ["showers/immersive_curtains_opacity"] = "Regaderas - Cortinas inmersivas",
        ["v_tent/box-displayName"] = "Tienda de Panam – Caja grande sobre la mesa"
    },
    ["it-it"] = {
        -- impostazioni
        ["techie_truck/logo-displayName"] = "Techie truck - Logo luminoso",
        ["showers/immersive_curtains_opacity"] = "Docce - Tende immersive",
        ["v_tent/box-displayName"] = "Tenda di Panam – Scatola grande sul tavolo",
    },
    ["kr-kr"] = {
        -- 설정
        ["techie_truck/logo-displayName"] = "테크 트럭 - 발광 로고",
        ["showers/immersive_curtains_opacity"] = "샤워 - 몰입형 커튼",
        ["v_tent/box-displayName"] = "파남의 텐트 - 테이블 위의 큰 상자"
    },
    ["zh-cn"] = {
        -- 设置
        ["techie_truck/logo-displayName"] = "科技卡车 - 发光标志",
        ["showers/immersive_curtains_opacity"] = "淋浴 - 沉浸式窗帘",
        ["v_tent/box-displayName"] = "帕南的帐篷 - 桌子上的大箱子",
    },
	["zh-tw"] = {
        -- 設定
        ["techie_truck/logo-displayName"] = "科技卡車 - 發光標誌",
        ["showers/immersive_curtains_opacity"] = "淋浴 - 沉浸式窗簾",
        ["v_tent/box-displayName"] = "帕南的帳篷 - 桌子上的大箱子",
    },
    ["ru-ru"] = {
        -- настройки
        ["techie_truck/logo-displayName"] = "Techie Truck - Светящийся логотип",
        ["showers/immersive_curtains_opacity"] = "Душевые - иммерсивные шторы",
        ["v_tent/box-displayName"] = "Палатка Панам — большая коробка на столе",
    },
    ["jp-jp"] = {
        -- 設定
        ["techie_truck/logo-displayName"] = "テックトラック - 発光ロゴ",
        ["showers/immersive_curtains_opacity"] = "シャワー - 没入型カーテン",
        ["v_tent/box-displayName"] = "パナムのテント - テーブルの上の大きな箱",
    },
    ["ar-ar"] = {
        -- الإعدادات
        ["techie_truck/logo-displayName"] = "شاحنة Techie - شعار مشع",
        ["showers/immersive_curtains_opacity"] = "الدش - ستائر غامرة",
        ["v_tent/box-displayName"] = "خيمة بانام - صندوق كبير على الطاولة",
    },
    ["cz-cz"] = {
        -- nastavení
        ["techie_truck/logo-displayName"] = "Techie Truck - Svítící logo",
        ["showers/immersive_curtains_opacity"] = "Sprchy - Pohlcující závěsy",
        ["v_tent/box-displayName"] = "Panamův stan – Velká krabice na stole",
    },
    ["hu-hu"] = {
        -- beállítások
        ["techie_truck/logo-displayName"] = "Techie Truck - Világító logó",
        ["showers/immersive_curtains_opacity"] = "Zuhanyok - Elmélyítő függönyök",
        ["v_tent/box-displayName"] = "Panam sátra – Nagy doboz az asztalon",
    },
    ["tr-tr"] = {
        -- ayarlar
        ["techie_truck/logo-displayName"] = "Techie Truck - Işıklı Logo",
        ["showers/immersive_curtains_opacity"] = "Duşlar - Sürükleyici perdeler",
        ["v_tent/box-displayName"] = "Panam’ın çadırı - Masanın üstündeki büyük kutu"
    },
    ["pt-br"] = {
        -- configurações
        ["techie_truck/logo-displayName"] = "Techie Truck - Logotipo iluminado",
        ["showers/immersive_curtains_opacity"] = "Chuveiros - Cortinas imersivas",
        ["v_tent/box-displayName"] = "Tenda da Panam – Caixa grande sobre a mesa",
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

function lang.getText(key)
    local localizedText = key:find("^LocKey") and GetLocalizedText(key) or lang.getCustomText(key)

    return localizedText
end

function lang.getCustomText(key)
    local text = lang[lang.getLang()][key]
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

return lang