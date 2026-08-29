module NightCityAllies.UI

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*
import NightCityAllies.Npc.*

// reference: https://codeberg.org/adamsmasher/cyberpunk/src/branch/master/cyberpunk/UI/widgets/healthbar/nameplateVisuals.swift
// https://codeberg.org/adamsmasher/cyberpunk/src/branch/master/cyberpunk/NPC/NPCPuppet.swift

// SetVisualData

@addField(NameplateVisualsLogicController)
private let m_isNcaNpc: Bool;

@wrapMethod(NameplateVisualsLogicController)
private final func SetNPCType(puppet: wref<ScriptedPuppet>) -> Void {
    let npc = this.m_cachedPuppet as NPCPuppet;
    if NCA.Settings().experimentalFeaturesEnabled && NCA.Settings().companionHpBarsEnabled && 
    IsDefined(npc) && NCA.NPC().IsSquad(npc.GetEntityID()) {
        this.m_isBoss = false;
        this.m_canCallReinforcements = false;
        this.m_isElite = false;
        this.m_isRare = false;
        this.m_isNCPD = false;
        this.m_isNcaNpc = true;
    } else {
        wrappedMethod(puppet);
        this.m_isNcaNpc = false;
    }
}

@addMethod(NameplateVisualsLogicController)
public func IsNcaNpc() -> Bool {
    return this.m_isNcaNpc;

    let npc = this.m_cachedPuppet as NPCPuppet;
    return IsDefined(npc) && NCA.NPC().IsCompanion(npc.GetEntityID());
}

@wrapMethod(NameplateVisualsLogicController)
private final func UpdateHealthbarVisibility() -> Void {
    if this.IsNcaNpc() && NCA.Settings().experimentalFeaturesEnabled && NCA.Settings().companionHpBarsEnabled {
        inkWidgetRef.SetVisible(this.m_healthbarWidget, true);
        inkWidgetRef.SetScale(this.m_healthbarWidget, new Vector2(0.85, 0.9));
        this.m_healthbarVisible = true;

        inkWidgetRef.SetVisible(this.m_rarityHolder, true);
        inkWidgetRef.SetVisible(this.m_rarities[0], true); // 1 bar
        inkWidgetRef.SetVisible(this.m_rarities[1], false); // 2 bars
        //inkWidgetRef.SetVisible(this.m_rarities[2], true); // skull
    } else {
        wrappedMethod();
    }
}

@wrapMethod(NameplateVisualsLogicController)
public final func SetVisualData(puppet: ref<GameObject>, const incomingData: script_ref<NPCNextToTheCrosshair>, opt isNewNpc: Bool) -> Void {
    wrappedMethod(puppet, incomingData, isNewNpc);
    if NCA.Settings().experimentalFeaturesEnabled && NCA.Settings().companionHpBarsEnabled && 
    this.IsNcaNpc() {
        let companionColor = new HDRColor(0.2, 1.3, 0.1, 0.9); 
        inkWidgetRef.SetState(this.m_healthbarWidget, n"NcaNpc"); // I THINK this tells cyberpunk to re-render the widget when the state changes ..?
        //inkWidgetRef.SetState(this.m_healthbarWidget, n"Default");
        inkWidgetRef.SetTintColor(this.m_healthbarWidget, companionColor);
        inkWidgetRef.SetTintColor(this.m_healthBarFull, companionColor);
    }
}
