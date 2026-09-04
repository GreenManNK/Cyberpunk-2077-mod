module NightlyNow.Tutorial

import NightlyNow.Utils.{IsPlayerInDialogOrCutscene, IsPlayerInPhotoMode, IsPlayerInMenu}

// -----------------------------------------------------------------------------
// Tutorial - NightlyNow Core
// -----------------------------------------------------------------------------
public struct Tutorial {
    public let title: CName;
    public let content: CName;
    public let image: TweakDBID;
}

public class TutorialSystem extends ScriptableSystem {
    // Contains titles of watched tutorials, is persisted
    public persistent let watchedTutorials: array<CName>;

    // Tutorial list, override in impl
    public func GetTutorials() -> array<Tutorial> = [];

    // Tutorials enabled, override in impl
    public func AreTutorialsEnabled() -> Bool = true;

    public func PlayTutorial(title: CName, opt forceWatch: Bool) {
        if !forceWatch && !this.AreTutorialsEnabled() {
            // Tutorials disabled
            return;
        }
        if ArrayContains(this.watchedTutorials, title) {
            // Already watched this one
            return;
        }
        for tutorial in this.GetTutorials() {
            if Equals(tutorial.title, title) {
                let displayCallback = new DisplayTutorialCallback();
                displayCallback.tutorialSystem = this;
                displayCallback.title = tutorial.title;
                displayCallback.content = tutorial.content;
                displayCallback.image = tutorial.image;
                GameInstance
                    .GetDelaySystem(GetGameInstance())
                    .DelayCallback(displayCallback, 3.0, false);
                return;
            }
        }
    }

    public func DisplayTutorial(title: CName, content: CName, image: TweakDBID) {
        if IsPlayerInDialogOrCutscene() || IsPlayerInPhotoMode() || IsPlayerInMenu() {
            // Tutorial can not be displayed now
            return;
        }

        let bb = GameInstance
            .GetBlackboardSystem(GetGameInstance())
            .Get(GetAllBlackboardDefs().UIGameData);

        // Popup settings
        let popupSettings: PopupSettings;
        popupSettings.fullscreen = true;
        popupSettings.position = PopupPosition.LowerLeft;
        popupSettings.closeAtInput = true;
        popupSettings.pauseGame = true;

        // Popup data
        let popupData: PopupData;
        popupData.title = GetLocalizedTextByKey(title);
        popupData.message = GetLocalizedTextByKey(content);
        popupData.isModal = true;
        popupData.iconID = image;

        bb
            .SetVariant(
                GetAllBlackboardDefs().UIGameData.Popup_Settings,
                ToVariant(popupSettings)
            );
        bb
            .SetVariant(GetAllBlackboardDefs().UIGameData.Popup_Data, ToVariant(popupData));
        bb.SignalVariant(GetAllBlackboardDefs().UIGameData.Popup_Data);

        // Add to watched
        ArrayPush(this.watchedTutorials, title);
    }
}

// Fires DisplayTutorial after a delay
public class DisplayTutorialCallback extends DelayCallback {
    public let tutorialSystem: wref<TutorialSystem>;
    public let title: CName;
    public let content: CName;
    public let image: TweakDBID;

    public func Call() {
        this.tutorialSystem.DisplayTutorial(this.title, this.content, this.image);
    }
}

