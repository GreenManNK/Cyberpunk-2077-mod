local lang = {
    ["de-de"] = {
        ["takeShower"] = "Duschen",
        ["leaveShower"] = "Dusche verlassen",
        ["lean"] = "Anlehnen"
    },
    ["en-us"] = {
        ["takeShower"] = "Take Shower",
        ["leaveShower"] = "Leave Shower",
        ["lean"] = "Lean"
    },
    ["fr-fr"] = {
        ["takeShower"] = "Prendre une douche",
        ["leaveShower"] = "Quitter la douche",
        ["lean"] = "S'appuyer sur"
    },
    ["pl-pl"] = {
        ["takeShower"] = "Weź prysznic",
        ["leaveShower"] = "Prysznic wyjściowy",
        ["lean"] = "Pochylając się"
    },
    ["es-es"] = {
        ["takeShower"] = "Dúchate",
        ["leaveShower"] = "Ducha de salida",
        ["lean"] = "Inclinación"
    },
    ["es-mx"] = {
        ["takeShower"] = "Dúchate",
        ["leaveShower"] = "Ducha de salida",
        ["lean"] = "Inclinación"
    },
    ["it-it"] = {
        ["takeShower"] = "Uscita dalla doccia",
        ["leaveShower"] = "Fare una doccia",
        ["lean"] = "Appoggiarsi"
    },
    ["kr-kr"] = {
        ["takeShower"] = "샤워를하다",
        ["leaveShower"] = "샤워를 떠나",
        ["lean"] = "경향"
    },
    ["zh-cn"] = {
        ["takeShower"] = "洗个澡",
        ["leaveShower"] = "出口淋浴",
        ["lean"] = "倾斜"
    },
	["zh-tw"] = {
        ["takeShower"] = "洗个澡",
        ["leaveShower"] = "出口淋浴",
        ["lean"] = "倾斜"
    },
    ["ru-ru"] = {
        ["takeShower"] = "Примите душ",
        ["leaveShower"] = "Выходной душ",
        ["lean"] = ""
    },
    ["jp-jp"] = {
        ["takeShower"] = "シャワーを浴びる",
        ["leaveShower"] = "出口シャワー",
        ["lean"] = "опираясь"
    },
    ["ar-ar"] = {
        ["takeShower"] = "خذ حماما",
        ["leaveShower"] = "اترك الحمام",
        ["lean"] = "يميل"
    },
    ["cz-cz"] = {
        ["takeShower"] = "Osprchujte se",
        ["leaveShower"] = "Výstupní sprcha",
        ["lean"] = ""
    },
    ["hu-hu"] = {
        ["takeShower"] = "Zuhanyozzon le",
        ["leaveShower"] = "Kijárati zuhany",
        ["lean"] = "Dőlés"
    },
    ["tr-tr"] = {
        ["takeShower"] = "Duş al",
        ["leaveShower"] = "Çıkış duşu",
        ["lean"] = "Eğilmek"
    },
    ["pt-br"] = {
        ["takeShower"] = "Chuveiros",
        ["leaveShower"] = "Chuveiro de saída",
        ["lean"] = "Inclinado"
    }
}

lang.lean = "lean"

function lang.getLang()
    local l = Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    if lang[l] == nil then
        return "en-us"
    else
        return l
    end
end

function lang.getText(key)
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