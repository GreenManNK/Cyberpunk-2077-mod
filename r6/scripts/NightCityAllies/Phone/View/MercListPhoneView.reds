module NightCityAllies.Phone.View

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Localization.*
import NightCityAllies.Persistence.*
import NightCityAllies.Phone.*
import NightCityAllies.Settings.*

public class MercListPhoneView extends PhoneView {
    public func GetHash() -> Int32 = 13371338;
    public func GetId() -> String = "DEFMERCCNT";
    public func GetPreview() -> String = NCA.Labels().Call_someone();
    public func GetName() -> String = NCA.Labels().Night_city_allies();
    public func PositionSetting() -> NCAPhoneEntryPosition = NCA.Settings().phoneMercAppPosition;
    public func GetColor() -> HDRColor = new HDRColor(0.9, 0.2, 1.2, 0.9);
    public func GetTime() -> GameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();
    public func IsImportant() -> Bool = true;

    private let currentPage: Int32 = 0;
    private let currentIndex: Int32 = 0;
    private let pageSize: Int32 = 7;
    private let hasSeenInitialMessge: Bool = false;

    public func IsActive() -> Bool {
        let acquiredCharacters = NCA.Persistence().GetStandbyCompanions();
        let totalStandby = ArraySize(acquiredCharacters);
        return totalStandby > 0;
    }

    public func Render(mdvController: ref<MessengerDialogViewController>) -> Void {
        if (this.currentPage == 0 && !this.hasSeenInitialMessge) {
            //mdvController.AddReceivedMessage(NCA.Labels().Call_someone());
            this.hasSeenInitialMessge = true;
        }

        let acquiredCharacters = NCA.Persistence().GetStandbyCompanions();
        let totalContacts = ArraySize(acquiredCharacters);
        let startIndex = this.currentPage * this.pageSize;
        let endIndex = Min(startIndex + this.pageSize, totalContacts);
        let localIndex = 0;

        // Render page contacts
        let i = startIndex;
        while i < endIndex {
            let contact = acquiredCharacters[i];
            mdvController.AddReplyOption(localIndex, acquiredCharacters[i].name, true, this.currentIndex == localIndex);
            localIndex += 1;
            i += 1;
        }

        // Basically when next-ing to the last page
        if (this.currentIndex > localIndex + 1) {
            this.currentIndex = localIndex;
        }

        // Previous Page
        if startIndex > 0 {
            mdvController.AddReplyOption(localIndex, s"< " + NCA.Labels().Previous_page(), false, this.currentIndex == localIndex);
            localIndex += 1;
        }

        // Next Page
        if endIndex < totalContacts {
            mdvController.AddReplyOption(localIndex, NCA.Labels().Next_page() + s" >", false, this.currentIndex == localIndex);
            localIndex += 1;
        }

        // Always add return option at the end
        mdvController.AddReplyOption(localIndex, NCA.Labels().Return_all(), false, this.currentIndex == localIndex);
    }

    public func Select(mdvController: ref<MessengerDialogViewController>, selectedIndex: Int32) -> Void {
        let acquiredCharacters = NCA.Persistence().GetStandbyCompanions();
        let totalContacts = ArraySize(acquiredCharacters);
        let startIndex = this.currentPage * this.pageSize;
        let endIndex = Min(startIndex + this.pageSize, totalContacts);
        let contactsOnPage = endIndex - startIndex;
        let hasPrevious = startIndex > 0;
        let hasNext = endIndex < totalContacts;
        let previousIndex = contactsOnPage;
        let nextIndex = contactsOnPage + (hasPrevious ? 1 : 0);
        let returnIndex = contactsOnPage + (hasPrevious ? 1 : 0) + (hasNext ? 1 : 0);
        let isLastPage = this.currentPage == (totalContacts / this.pageSize);

        switch true {
            // Contact selected
            case selectedIndex < contactsOnPage:
                let globalIndex = startIndex + selectedIndex;
                let selectedContact = acquiredCharacters[globalIndex];
                let name = acquiredCharacters[globalIndex].name;

                let npc = NCA.NPC().Commute(selectedContact.recordID);
                this.currentIndex = selectedIndex;
                this.Render(mdvController);
                break;

            // Previous Page
            case hasPrevious && selectedIndex == previousIndex:
                if (isLastPage) {
                    this.currentIndex = this.pageSize;
                } else {
                    this.currentIndex = selectedIndex;
                }
                this.currentPage -= 1;
                this.Render(mdvController);
                break;

            // Next Page
            case hasNext && selectedIndex == nextIndex:
                if (this.currentPage == 0) {
                    this.currentIndex = selectedIndex + 1;
                } else {
                    this.currentIndex = selectedIndex;
                }
                this.currentPage += 1;
                this.Render(mdvController);
                break;

            // Return all
            case selectedIndex == returnIndex:
                NCA.NPC().DespawnSquad();
                this.currentIndex = selectedIndex;
                this.Render(mdvController);
                break;
        }
    }

    private func Reset() {
        this.hasSeenInitialMessge = false;
        this.currentPage = 0;
        this.currentIndex = 0;
    }
}