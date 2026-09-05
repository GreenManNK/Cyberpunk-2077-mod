
class PRME extends ScriptableSystem {
  private let m_questSystem: ref<QuestsSystem>;
  private let m_gameInstance: GameInstance;
  private let m_prmeActivationListenerID: Uint32;
  private let m_postFuneralMitchFixListenerID: Uint32;
  private let m_postPanamHelpFixListenerID: Uint32;
  private let m_player: ref<PlayerPuppet>;
  private let m_axlversion: String;
  private let m_txlversion: String;
  private let m_cwversion: String;

  private func VersionCheck() -> Bool {
    let axlversion = ArchiveXL.Version();
    let txlversion = TweakXL.Version();
    let cwversion = Codeware.Version();

    this.m_axlversion = axlversion;
    this.m_txlversion = txlversion;
    this.m_cwversion = cwversion;
    return true;
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    if GameInstance.GetSystemRequestsHandler().IsPreGame() {
      if this.VersionCheck() {
        FTLog(s"PRME Requirements installed:");
        FTLog(s"ArchiveXL: " + this.m_axlversion);
        FTLog(s"TweakXL: " + this.m_txlversion);
        FTLog(s"Codeware: " + this.m_cwversion);
      }
      return;
    }

    FTLog(s"Attached to player");

    let player: ref<PlayerPuppet> = request.owner as PlayerPuppet;

    if IsDefined(player) {
      this.m_questSystem = GameInstance.GetQuestsSystem(player.GetGame());
      this.m_prmeActivationListenerID = this
        .m_questSystem
        .RegisterListener(n"prme_tutorial_bill", this, n"OnPrmeActivationListenerChange");
      this.m_postFuneralMitchFixListenerID = this
        .m_questSystem
        .RegisterListener(n"post_funeral_mitch_fix", this, n"OnPostFuneralMitchFixChange");
      this.m_postPanamHelpFixListenerID = this
        .m_questSystem
        .RegisterListener(n"post_panam_help_fix", this, n"OnPostPanamHelpFixChange");
      this.m_player = player;
    }
  }

  public cb final func OnPrmeActivationListenerChange(factVal: Int32) -> Void {
    if factVal == 1 {
      FTLog(
          "prme_tutorial_bill = " + this.m_questSystem.GetFactStr("prme_tutorial_bill")
        );
    } else {
      FTLog(
          "prme_tutorial_bill = " + this.m_questSystem.GetFactStr("prme_tutorial_bill")
        );
    }
  }

  public cb final func OnPostFuneralMitchFixChange(factVal: Int32) -> Void {
    if factVal == 1 {
      FTLog(
          "post_funeral_mitch_fix = " + this.m_questSystem.GetFactStr("post_funeral_mitch_fix")
        );
    } else {
      FTLog(
          "post_funeral_mitch_fix = " + this.m_questSystem.GetFactStr("post_funeral_mitch_fix")
        );
    }
  }

  public cb final func OnPostPanamHelpFixChange(factVal: Int32) -> Void {
    if factVal == 1 {
      FTLog(
          "post_panam_help_fix = " + this.m_questSystem.GetFactStr("post_panam_help_fix")
        );
    } else {
      FTLog(
          "post_panam_help_fix = " + this.m_questSystem.GetFactStr("post_panam_help_fix")
        );
    }
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    this
      .m_questSystem
      .UnregisterListener(n"prme_tutorial_bill", this.m_prmeActivationListenerID);
    this
      .m_questSystem
      .UnregisterListener(n"post_funeral_mitch_fix", this.m_postFuneralMitchFixListenerID);
    this
      .m_questSystem
      .UnregisterListener(n"post_panam_help_fix", this.m_postPanamHelpFixListenerID);
  }
}

