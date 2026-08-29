module TriggerModeControl.AudioFixes

class FillMissingGunSounds extends ScriptableService {

  private cb func OnLoad() {
    GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnAudioMetadataLoad").AddTarget(ResourceTarget.Type(n"audioCookedMetadataResource"));
  }

  private cb func OnAudioMetadataLoad(event: ref<ResourceEvent>) {
    let cookedMetadata = event.GetResource() as audioCookedMetadataResource;
    for audioData in cookedMetadata.entries {
      let audioWeaponSet = audioData as audioWeaponSettingsGroup;
      if IsDefined(audioWeaponSet) {
        if !Equals(audioWeaponSet.playerSettings, n"") && Equals(audioWeaponSet.playerSilenced, n"") {
          audioWeaponSet.playerSilenced = n"wea_pla_yukimura";
        };
        if Equals(audioWeaponSet.playerSettings, n"wea_pla_grad_suppressor") {
          audioWeaponSet.playerSilenced = n"wea_pla_grad_suppressor";
        };
        if Equals(audioWeaponSet.playerSettings, n"wea_pla_ticon_reed") || Equals(audioWeaponSet.playerSilenced, n"wea_pla_ticon_suppressor") {
          audioWeaponSet.playerSilenced = n"wea_pla_ticon_reed";
        };
      };
      let audioPlayerSet = audioData as audioPlayerWeaponSettings;
      if IsDefined(audioPlayerSet) && StrContains(NameToString(audioPlayerSet.name), "wea_pla_") {
        if Equals(audioPlayerSet.chargeStartSound, n"") {
          audioPlayerSet.chargeStartSound = n"w_gun_revol_tech_burya_charge";
        };
        if !Equals(audioPlayerSet.name, n"wea_pla_missile_vehicle") && !Equals(audioPlayerSet.name, n"wea_pla_vehicle") {
          if !Equals(audioPlayerSet.fireSound, n"") {
            audioPlayerSet.preFireSound = audioPlayerSet.fireSound;
            audioPlayerSet.fireSound = n"";
          };
          audioPlayerSet.burstFireSound = n"";
          audioPlayerSet.autoFireSound = n"";
        };
      };
    };
  }

}