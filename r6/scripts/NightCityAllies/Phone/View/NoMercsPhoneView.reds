module NightCityAllies.Phone.View

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Localization.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*

public class NoMercsPhoneView extends PhoneView {
    public func GetId() -> String = "DEFMERCCNT";
    public func GetHash() -> Int32 = 13371339;
    public func GetPreview() -> String = NCA.Labels().Call_someone();
    public func GetName() -> String = NCA.Labels().Night_city_allies();
    public func PositionSetting() -> NCAPhoneEntryPosition = NCA.Settings().phoneMercAppPosition;
    public func GetColor() -> HDRColor = new HDRColor(0.9, 0.2, 1.2, 0.5);
    public func GetTime() -> GameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();
    public func IsImportant() -> Bool = false;

    public func IsActive() -> Bool {
        let acquiredCharacters = NCA.Persistence().GetStandbyCompanions();
        let activeCharacters = NCA.Persistence().GetSquadCompanions();
        let unavailableCharacters = NCA.Persistence().GetUnavailableCompanions();
        let commutingCharacters = NCA.Persistence().GetCommutingCompanions();

        let totalStandby = ArraySize(acquiredCharacters);
        let totalSquad = ArraySize(activeCharacters);
        let totalUnavailable = ArraySize(unavailableCharacters);
        let totalCommuting = ArraySize(commutingCharacters);

        return totalStandby == 0 && ((totalSquad + totalCommuting + totalUnavailable) > 0);
    }

    public func Render(mdvController: ref<MessengerDialogViewController>) -> Void {
        mdvController.AddReceivedMessage(NCA.Labels().Nobody_on_standby());
        mdvController.AddReplyOption(0, NCA.Labels().Return_all(), false, true);
    }

    public func Select(mdvController: ref<MessengerDialogViewController>, selectedIndex: Int32) -> Void {
        switch selectedIndex {
            case 0:
                mdvController.AddSentMessage(NCA.Labels().Return_all());
                mdvController.AddDelayedReceivedMessage(1.0, NCA.Labels().Thank_you_for_your_business());
                NCA.NPC().DespawnSquad();
                break;
        }
    }
}