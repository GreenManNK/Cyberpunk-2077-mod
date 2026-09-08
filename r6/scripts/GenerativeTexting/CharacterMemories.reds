// Character Memory Storage System
// This file contains persistent memories for each NPC based on player interactions
// Manually update these sections as conversations progress to maintain consistency

// Main function to get character-specific memories
public func GetCharacterMemories(character: CharacterSetting) -> String {
    switch character {
        case CharacterSetting.Panam:
            return GetPanamMemories();
        case CharacterSetting.Judy:
            return GetJudyMemories();
        case CharacterSetting.River:
            return GetRiverMemories();
        case CharacterSetting.Kerry:
            return GetKerryMemories();
        case CharacterSetting.Songbird:
            return GetSongbirdMemories();
        case CharacterSetting.Rogue:
            return GetRogueMemories();
        case CharacterSetting.BlueMoon:
            return GetBlueMoonMemories();
        case CharacterSetting.RitaWheeler:
            return GetRitaWheelerMemories();
        case CharacterSetting.LizzyWizzy:
            return GetLizzyWizzyMemories();
        case CharacterSetting.HanakoArasaka:
            return GetHanakoArasakaMemories();
        case CharacterSetting.ElizabethPeralez:
            return GetElizabethPeralezMemories();
        case CharacterSetting.JossKutcher:
            return GetJossKutcherMemories();
        case CharacterSetting.ClaireRussell:
            return GetClaireRussellMemories();
        case CharacterSetting.ViktorVektor:
            return GetViktorVektorMemories();
        case CharacterSetting.Reed:
            return GetReedMemories();
        case CharacterSetting.Alex:
            return GetAlexMemories();
        case CharacterSetting.IrisTanner:
            return GetIrisTannerMemories();
        case CharacterSetting.AuroreCassel:
            return GetAuroreCasselMemories();
        case CharacterSetting.ChloeVendranord:
            return GetChloeVendranordMemories();
        case CharacterSetting.EvelynParker:
            return GetEvelynParkerMemories();    
        default:
            return "";
    }
}

// ============================================
// PANAM PALMER MEMORIES
// ============================================
private func GetPanamMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// JUDY ALVAREZ MEMORIES
// ============================================
private func GetJudyMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}


// ============================================
// RIVER WARD MEMORIES
// ============================================
private func GetRiverMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// KERRY EURODYNE MEMORIES
// ============================================
private func GetKerryMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// SONGBIRD MEMORIES
// ============================================
private func GetSongbirdMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// ROGUE AMENDIARES MEMORIES
// ============================================
private func GetRogueMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// BLUE MOON MEMORIES
// ============================================
private func GetBlueMoonMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// RITA WHEELER MEMORIES
// ============================================
private func GetRitaWheelerMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// =// ============================================
// LIZZY WIZZY MEMORIES
// ============================================
private func GetLizzyWizzyMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// HANAKO ARASAKA MEMORIES - UPDATED
// ============================================
private func GetHanakoArasakaMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// ELIZABETH PERALEZ MEMORIES
// ============================================
private func GetElizabethPeralezMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// EVELYN PARKER MEMORIES
// ============================================
private func GetEvelynParkerMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}


// ============================================
// JOSS KUTCHER MEMORIES
// ============================================
private func GetJossKutcherMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";

}
// ============================================
// CLAIRE RUSSELL MEMORIES
// ============================================
private func GetClaireRussellMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}


// ============================================
// VIKTOR VEKTOR MEMORIES
// ============================================
private func GetViktorVektorMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";

}
// ============================================
// SOLOMON REED MEMORIES
// ============================================
private func GetReedMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";

}
// ============================================
// ALEX MEMORIES
// ============================================
private func GetAlexMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";

}
// ============================================
// IRIS TANNER MEMORIES
// ============================================
private func GetIrisTannerMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// AURORE CASSEL MEMORIES
// ============================================
private func GetAuroreCasselMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}

// ============================================
// CHLOE VENDRANORD MEMORIES
// ============================================
private func GetChloeVendranordMemories() -> String {
    return "\n\n=== PERSISTENT MEMORIES ===\n" +
    "Reference these naturally when relevant in conversation:\n\n" +
    "CORE MEMORIES:\n" +
    "• [Add relationship milestones]\n" +
    "• [Add significant shared experiences]\n" +
    "• [Add important promises or commitments]\n" +
    "• [Add ongoing situations or challenges]\n" +
    "• [Add personal details V shared with you]\n" +
    "• [Add personal details you shared with V]\n" +
    "• [Add first times or special moments]\n" +
    "• [Add inside jokes or teasing moments]\n" +
    "• [Add preferences V mentioned]\n" +
    "• [Add your opinions or feelings you expressed]\n" +
    "• [Add plans you made together]\n" +
    "• [Add memorable conversations or exchanges]\n" +
    "• [Add unresolved topics or ongoing discussions]\n" +
    "• [Add things V asked you to do or check on]\n\n" +
    "[Use these memories naturally - don't list them out. Reference when contextually appropriate.]";
}
