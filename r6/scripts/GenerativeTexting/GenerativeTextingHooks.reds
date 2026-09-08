// Initialize the texting system when the player spawns in
@wrapMethod(PlayerPuppet)
protected cb func OnMakePlayerVisibleAfterSpawn(evt: ref<EndGracePeriodAfterSpawn>) -> Bool { 
    wrappedMethod(evt);
    if !GameInstance.GetSystemRequestsHandler().IsPreGame() {
        if IsDefined(GetTextingSystem()) {
            GetTextingSystem().InitializeSystem();
        } else {
            ConsoleLog("Texting system not defined.");
        }
    }
}

@wrapMethod(PhoneDialerLogicController)
protected cb func OnAllElementsSpawned() -> Bool {
    wrappedMethod();

    if GetTextingSystem().GetUnread() {
        GetTextingSystem().HidePhoneUi();
    }
}

// Update the input hints based on the selected character
@wrapMethod(PhoneDialerLogicController)
private final func RefreshInputHints(contactData: wref<ContactData>) -> Void {
    wrappedMethod(contactData);

    if contactData != null {
        let contactName = contactData.contactId;
        ConsoleLog(s"Contact name: \(contactName)");

        // Tell the system which contact is hovered
        if GetTextingSystem() != null {
            GetTextingSystem().SetHoveredContact(contactName);
        }

        // If not a mod character, just clear npcSelected and exit
        if !IsModCharacterContact(contactName) {
            if GetTextingSystem() != null {
                GetTextingSystem().ToggleNpcSelected(false);
                GetTextingSystem().UnregisterSwitchKey();
            }
            return;
        }

        // Register T key for all mod NPCs
        if GetTextingSystem() != null {
            GetTextingSystem().RegisterSwitchKey();
        }

        // If it's the active character, also set npcSelected
        if Equals(contactName, GetCharacterContactName(GetTextingSystem().character)) {
            if !GetTextingSystem().isGroupChat {
                GetTextingSystem().ToggleNpcSelected(true);
            }
        }

        // Add T hint icon to this contact entry
        let contactListWidget = inkWidgetRef.Get(this.m_contactsList) as inkCompoundWidget;
        if IsDefined(contactListWidget) {
            let numChildren = contactListWidget.GetNumChildren();
            let i = 0;
            while i < numChildren {
                let contactEntry = contactListWidget.GetWidgetByIndex(i) as inkCompoundWidget;
                if IsDefined(contactEntry) {
                    let contactLabel = FindWidgetWithName(contactEntry, n"contactLabel") as inkText;
                    if IsDefined(contactLabel) && Equals(contactLabel.GetText(), GetCharacterLocalizedName(GetCharacterFromContactName(contactName))) {
                        let hintsHolderWidget = FindWidgetWithName(contactEntry, n"hints_holder") as inkHorizontalPanel;
                        if IsDefined(hintsHolderWidget) {
                            if NotEquals(s"\(hintsHolderWidget.parentWidget.GetName())", "horiz_holder") {
                                return;
                            }
                            let hintMod = FindWidgetWithName(hintsHolderWidget, n"hint_mod") as inkHorizontalPanel;
                            if !IsDefined(hintMod) {
                                hintMod = hintsHolderWidget.AddChild(n"inkHorizontalPanel") as inkHorizontalPanel;
                                if IsDefined(hintMod) {
                                    hintMod.SetName(n"hint_mod");
                                    hintMod.SetVisible(true);
                                    hintMod.SetAnchor(inkEAnchor.TopRight);
                                    hintMod.SetVAlign(inkEVerticalAlign.Center);
                                    hintMod.SetHAlign(inkEHorizontalAlign.Right);
                                    let keyWidget = hintMod.AddChild(n"inkImage") as inkImage;
                                    if IsDefined(keyWidget) {
                                        keyWidget.SetName(n"inputIcon");
                                        keyWidget.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
                                        keyWidget.SetTexturePart(n"kb_t");
                                        keyWidget.SetSize(new Vector2(58.0, 58.0));
                                        keyWidget.SetScale(new Vector2(1, 1));
                                        keyWidget.SetAnchor(inkEAnchor.Centered);
                                        keyWidget.SetVisible(true);
                                        keyWidget.SetVAlign(inkEVerticalAlign.Center);
                                        keyWidget.SetHAlign(inkEHorizontalAlign.Center);
                                        keyWidget.BindProperty(n"tintColor", n"ContactListItem.fontColor");
                                        keyWidget.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
                                    }
                                    let iconWidget = hintMod.AddChild(n"inkImage") as inkImage;
                                    if IsDefined(iconWidget) {
                                        iconWidget.SetName(n"fluff");
                                        iconWidget.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas");
                                        iconWidget.SetTexturePart(n"ico_envelelope_reply1");
                                        iconWidget.SetSize(new Vector2(43.0, 43.0));
                                        iconWidget.SetScale(new Vector2(1, 1));
                                        iconWidget.SetAnchor(inkEAnchor.TopLeft);
                                        iconWidget.SetVAlign(inkEVerticalAlign.Center);
                                        iconWidget.SetHAlign(inkEHorizontalAlign.Center);
                                        iconWidget.SetMargin(new inkMargin(7.0, 9.0, 8.0, 0.0));
                                        iconWidget.SetFitToContent(true);
                                        iconWidget.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
                                        iconWidget.BindProperty(n"tintColor", n"MainColors.Blue");
                                        iconWidget.BindProperty(n"opacity", n"MenuLabel.MainOpacity");
                                        iconWidget.SetVisible(true);
                                    }
                                    // G key hint for group chat
                                    let hintGroup = FindWidgetWithName(hintsHolderWidget, n"hint_group") as inkHorizontalPanel;
                                    if !IsDefined(hintGroup) {
                                        hintGroup = hintsHolderWidget.AddChild(n"inkHorizontalPanel") as inkHorizontalPanel;
                                        if IsDefined(hintGroup) {
                                            hintGroup.SetName(n"hint_group");
                                            hintGroup.SetVisible(true);
                                            hintGroup.SetAnchor(inkEAnchor.TopRight);
                                            hintGroup.SetVAlign(inkEVerticalAlign.Center);
                                            hintGroup.SetHAlign(inkEHorizontalAlign.Right);
                                            let gKeyWidget = hintGroup.AddChild(n"inkImage") as inkImage;
                                            if IsDefined(gKeyWidget) {
                                                gKeyWidget.SetName(n"inputIcon");
                                                gKeyWidget.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
                                                gKeyWidget.SetTexturePart(n"kb_g");
                                                gKeyWidget.SetSize(new Vector2(58.0, 58.0));
                                                gKeyWidget.SetScale(new Vector2(1, 1));
                                                gKeyWidget.SetAnchor(inkEAnchor.Centered);
                                                gKeyWidget.SetVisible(true);
                                                gKeyWidget.SetVAlign(inkEVerticalAlign.Center);
                                                gKeyWidget.SetHAlign(inkEHorizontalAlign.Center);
                                            }
                                            let gIconWidget = hintGroup.AddChild(n"inkImage") as inkImage;
                                            if IsDefined(gIconWidget) {
                                                gIconWidget.SetName(n"fluff");
                                                gIconWidget.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas");
                                                gIconWidget.SetTexturePart(n"ico_group");
                                                gIconWidget.SetSize(new Vector2(43.0, 43.0));
                                                gIconWidget.SetScale(new Vector2(1, 1));
                                                gIconWidget.SetAnchor(inkEAnchor.TopLeft);
                                                gIconWidget.SetVAlign(inkEVerticalAlign.Center);
                                                gIconWidget.SetHAlign(inkEHorizontalAlign.Center);
                                                gIconWidget.SetMargin(new inkMargin(7.0, 9.0, 8.0, 0.0));
                                                gIconWidget.SetFitToContent(true);
                                            }
                                            hintsHolderWidget.ReorderChild(hintGroup, 0);
                                        }
                                    }

                                    // Update color based on group selection state (runs on create AND on re-hover)
                                    if IsDefined(hintGroup) {
                                        let gColor: Color = GetTextingSystem().GetGroupFirstSelected()
                                            ? new Color(Cast(0u), Cast(210u), Cast(80u), Cast(255u))   // green - first NPC selected
                                            : new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u)); // yellow - awaiting first press
                                        let gKey = FindWidgetWithName(hintGroup, n"inputIcon") as inkImage;
                                        let gIcon = FindWidgetWithName(hintGroup, n"fluff") as inkImage;
                                        if IsDefined(gKey) { gKey.SetTintColor(gColor); }
                                        if IsDefined(gIcon) { gIcon.SetTintColor(gColor); }
                                    }



                                    hintsHolderWidget.ReorderChild(hintMod, 0);  
                                }
                            }
                        }

                        // Always update G hint color on every hover
                        let hintGroup = FindWidgetWithName(hintsHolderWidget, n"hint_group") as inkHorizontalPanel;
                        if IsDefined(hintGroup) {
                            let gColor: Color = GetTextingSystem().GetGroupFirstSelected()
                                ? new Color(Cast(0u), Cast(210u), Cast(80u), Cast(255u))
                                : new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u));
                            let gKey = FindWidgetWithName(hintGroup, n"inputIcon") as inkImage;
                            let gIcon = FindWidgetWithName(hintGroup, n"fluff") as inkImage;
                            if IsDefined(gKey) { gKey.SetTintColor(gColor); }
                            if IsDefined(gIcon) { gIcon.SetTintColor(gColor); }
                        }

                         
                        break;
                    }
                }
                i += 1;
            }
        } else {
            ConsoleLog("contactListWidget not found.");
        }
    }
}

// Toggle flags when the phone is put away
@wrapMethod(PhoneDialerLogicController)
public final func Hide() -> Void {
    wrappedMethod();

    if IsDefined(GetTextingSystem()) {
        GetTextingSystem().ToggleNpcSelected(false);
        GetTextingSystem().ToggleIsTyping(false);
        GetTextingSystem().isGroupChat = false;
    }
}

// Toggle flags when other menus are opened
@wrapMethod(MenuHubLogicController)
public final func SetActive(isActive: Bool) -> Void {
    wrappedMethod(isActive);

    if (IsDefined(GetTextingSystem()) && GetTextingSystem().GetChatOpen()) {
        GetTextingSystem().ToggleNpcSelected(false);
        GetTextingSystem().ToggleIsTyping(false);
        GetTextingSystem().HideModChat();
    }
}

// Toggle flags when the player enters combat
@wrapMethod(PlayerPuppet)
protected cb func OnCombatStateChanged(newState: Int32) -> Bool {  // newState uses the values specified in enum PlayerCombatState
    let r: Bool = wrappedMethod(newState);
    
    if Equals(newState, 1) {
        if (IsDefined(GetTextingSystem()) && GetTextingSystem().GetChatOpen()) {
            GetTextingSystem().ToggleNpcSelected(false);
            GetTextingSystem().ToggleIsTyping(false);
            GetTextingSystem().HideModChat();
        }
    }

    return r;
}

// Push a custom SMS notification based on the selected character and LLM response
@addMethod(NewHudPhoneGameController)
public final func PushCustomSMSNotification(text: String) -> Void {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<PhoneMessageNotificationViewData> = new PhoneMessageNotificationViewData();
    let action = new OpenPhoneMessageAction();
    action.m_phoneSystem = this.m_PhoneSystem;
    let notifCharacter = GetTextingSystem().character;
    userData.title = GetCharacterLocalizedName(notifCharacter);
    userData.SMSText = text;
    userData.animation = n"notification_phone_MSG";
    userData.soundEvent = n"PhoneSmsPopup";
    userData.soundAction = n"OnOpen";
    userData.action = action;
    notificationData.time = 6.70;
    notificationData.widgetLibraryItemName = n"notification_message";
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
}
