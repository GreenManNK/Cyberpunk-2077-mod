// QJF — Language-agnostic quest filter (ALL / MAIN / SIDE / MINOR / STREET / PSYCHOS / CONTRACTS)
// This version relies only on QuestListItemData.m_questType and never compares localized titles.
//
// Works alongside your localized button labels in QJF.Filter.Buttons.reds (ArchiveXL).
// No string caches, no per-locale lists, no enum equality operators.
//
// Integration: wrap QuestListVirtualDataView.FilterItem and AND our filter with vanilla filter.
// Mode is stored as a QuestsSystem fact "QJF_FilterMode" (0=ALL, 1=MAIN, 2=SIDE, 3=MINOR, 4=STREET, 5=PSYCHOS, 6=CONTRACTS)

module QJF

// -------- current mode (stored as fact) --------
private func QJF_Mode() -> Int32 {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  if IsDefined(qs) { return qs.GetFact(n"QJF_FilterMode"); }
  return 0;
}

// ---- Language-agnostic: map QuestListItemType -> filter mode Int32 ----
// 0=ALL, 1=MAIN, 2=SIDE, 3=MINOR, 4=STREET, 5=PSYCHOS, 6=CONTRACTS
private func QJF_MapTypeToMode(t: QuestListItemType) -> Int32 {
  switch t {
    case QuestListItemType.MainQuest:     return 1;
    case QuestListItemType.SideQuest:     return 2;
    case QuestListItemType.Courier:       return 3; // treat as MINOR
    case QuestListItemType.Apartment:     return 3; // treat as MINOR
    case QuestListItemType.NCPDQuest:     return 4; // STREET / Scanner Hustles
    case QuestListItemType.Cyberpsycho:   return 5; // PSYCHOS
    case QuestListItemType.Gig:           return 6; // CONTRACTS (fixer gigs)
    default:
      return 0; // ALL / unknown (don’t filter these out)
  }
}

// -------- main filter hook --------
// We AND our result with the vanilla filter: if vanilla hides a row, we keep it hidden.
// If mode is 0 (ALL), or the row isn’t a quest row, we don’t filter it out.
@wrapMethod(QuestListVirtualDataView)
public func FilterItem(data: ref<IScriptable>) -> Bool {
  let vanilla: Bool = wrappedMethod(data);
  if !vanilla {
    return false; // preserve base game filtering behavior
  }

  let mode: Int32 = QJF_Mode();
  if mode == 0 {
    return true; // ALL
  }

  // Only filter quest list rows
  let questData = data as QuestListItemData;
  if !IsDefined(questData) {
    return true; // not a quest row -> leave untouched
  }

  // Language-agnostic classification via QuestListItemType
  // Note: field uses the 'm_' style in your environment (e.g., m_questData, m_journalManager)
  let tMode: Int32 = QJF_MapTypeToMode(questData.m_questType);

  // Unknown/ALL-mapped types are not filtered out
  if tMode == 0 {
    return true;
  }

  // Show only when type mapping matches the active mode
  return tMode == mode;
}
