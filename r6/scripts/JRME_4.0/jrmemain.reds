
class JRME extends ScriptableSystem {
  private let m_questSystem: ref<QuestsSystem>;
  private let m_gameInstance: GameInstance;
  private let m_jrmeActivationListenerID: Uint32;
  private let m_postMoxMsgFixListenerID: Uint32;
  private let m_player: ref<PlayerPuppet>;
  private let m_axlversion: String;
  private let m_txlversion: String;
  private let m_cwversion: String;

  private func VersionCheck() -> Bool {
    let axlversion = ArchiveXL.Version();
    let txlversion = TweakXL.Version();
    let cwversion = Codeware.Version();
    //GameInstance.GetAudioSystemExt(gi).Version(); 

    this.m_axlversion = axlversion;
    this.m_txlversion = txlversion;
    this.m_cwversion = cwversion;
    return true;
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    if GameInstance.GetSystemRequestsHandler().IsPreGame() {
      if this.VersionCheck() {
        FTLog(s"JRME Requirements installed:");
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
      this.m_jrmeActivationListenerID = this
        .m_questSystem
        .RegisterListener(n"jrme_tutorial_bill", this, n"OnJrmeActivationListenerChange");
      this.m_postMoxMsgFixListenerID = this
        .m_questSystem
        .RegisterListener(n"post_mox_msg_fix", this, n"OnPostMoxMsgFixChange");
      this.m_player = player;
    }
  }

  public cb final func OnJrmeActivationListenerChange(factVal: Int32) -> Void {
    if factVal == 1 {
      FTLog(
          "jrme_tutorial_bill = " + this.m_questSystem.GetFactStr("jrme_tutorial_bill")
        );
    } else {
      FTLog(
          "jrme_tutorial_bill = " + this.m_questSystem.GetFactStr("jrme_tutorial_bill")
        );
    }
  }

  public cb final func OnPostMoxMsgFixChange(factVal: Int32) -> Void {
    if factVal == 1 {
      FTLog(
          "post_mox_msg_fix = " + this.m_questSystem.GetFactStr("post_mox_msg_fix")
        );
    } else {
      FTLog(
          "post_mox_msg_fix = " + this.m_questSystem.GetFactStr("post_mox_msg_fix")
        );
    }
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    this
      .m_questSystem
      .UnregisterListener(n"jrme_tutorial_bill", this.m_jrmeActivationListenerID);
    this
      .m_questSystem
      .UnregisterListener(n"post_mox_msg_fix", this.m_postMoxMsgFixListenerID);
  }
}

