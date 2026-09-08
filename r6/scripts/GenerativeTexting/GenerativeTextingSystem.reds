import Codeware.*
import Codeware.UI.*

enum SongbirdEnding {
    Default = 0,
    KingOfWands = 1,
    KingOfSwords = 2,
    KingOfPentacles = 3
}

public class GenerativeTextingSystem extends ScriptableService {
    private let initialized: Bool = false;
    private let callbackSystem: wref<CallbackSystem>;
    private let npcSelected: Bool = false;
    private let chatOpen: Bool = false;
    private let parent: wref<inkCanvas>;
    private let contactListSlot: wref<inkCanvas>;
    private let chatContainer: wref<inkCanvas>;
    private let defaultPhoneController: wref<NewHudPhoneGameController>;
    private let defaultChatUi: wref<inkCanvas>;
    private let messageParent: wref<inkVerticalPanel>;
    private let rootAnim: wref<inkAnimDef>;
    private let messageAnim: wref<inkAnimDef>;
    private let player: wref<PlayerPuppet>;
    private let isTyping: Bool = false;
    private let typedMessage: String = "";
    private let typedMessageText: wref<inkText>;
    private let typedMessageWrapper: wref<inkHorizontalPanel>;
    private let chatInputHint: wref<inkImage>;
    private let messengerSlotRoot: wref<inkCanvas>;
    private let chatScrollController: wref<inkScrollController>;
    private let typingIndicator: wref<inkFlex>;
    private let lastActiveCharacter: CharacterSetting = CharacterSetting.Panam;
    private let unread: Bool = false;
    private let disabled: Bool = false;
    private let liveModeHintIcon: wref<inkImage>;
    private let liveModeHintText: wref<inkText>;

    private let hintMemoryText: wref<inkText>;
    private let hintMemoryIcon: wref<inkImage>;
    private let hoveredContactId: String = "";

    public let lastCalloutScheduledTime: Float = 0.0;

    public let isGroupChat: Bool = false;

    public let groupCharacter1: CharacterSetting = CharacterSetting.Panam;
    public let groupCharacter2: CharacterSetting = CharacterSetting.Panam;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Player Gender")
    @runtimeProperty("ModSettings.description", "Controls the gender you will be referred to as.")
    @runtimeProperty("ModSettings.displayValues.Male", "Male")
    @runtimeProperty("ModSettings.displayValues.Female", "Female")
    public let gender: PlayerGender = PlayerGender.Male;



    // @runtimeProperty("ModSettings.mod", "Generative Texting")
    // @runtimeProperty("ModSettings.displayName", "Character")
    // @runtimeProperty("ModSettings.description", "Controls the character you can chat with.")
    // @runtimeProperty("ModSettings.displayValues.Panam", "Panam Palmer")
    // @runtimeProperty("ModSettings.displayValues.Judy", "Judy Alvarez")
    // @runtimeProperty("ModSettings.displayValues.River", "River Ward")
    // @runtimeProperty("ModSettings.displayValues.Kerry", "Kerry Eurodyne")
    // @runtimeProperty("ModSettings.displayValues.Songbird", "Songbird")
    // @runtimeProperty("ModSettings.displayValues.Rogue", "Rogue Amendiares")
    // @runtimeProperty("ModSettings.displayValues.BlueMoon", "Blue Moon")
    // @runtimeProperty("ModSettings.displayValues.RitaWheeler", "Rita Wheeler")
    // @runtimeProperty("ModSettings.displayValues.LizzyWizzy", "Lizzy Wizzy")
    // @runtimeProperty("ModSettings.displayValues.HanakoArasaka", "Hanako Arasaka")
    // @runtimeProperty("ModSettings.displayValues.ElizabethPeralez", "Elizabeth Peralez")
    // @runtimeProperty("ModSettings.displayValues.JossKutcher", "Joss Kutcher")
    // @runtimeProperty("ModSettings.displayValues.ClaireRussell", "Claire Russell")
    // @runtimeProperty("ModSettings.displayValues.ViktorVektor", "Viktor Vektor")
    // @runtimeProperty("ModSettings.displayValues.Reed", "Reed")
    // @runtimeProperty("ModSettings.displayValues.Alex", "Alex")
    // @runtimeProperty("ModSettings.displayValues.IrisTanner", "Iris Tanner")
    // @runtimeProperty("ModSettings.displayValues.MaikoMaeda", "Maiko Maeda")
    // @runtimeProperty("ModSettings.displayValues.MichikoArasaka", "Michiko Arasaka")
    // @runtimeProperty("ModSettings.displayValues.AuroreCassel", "Aurore Cassel")
    // @runtimeProperty("ModSettings.displayValues.PurpleForce", "Purple Force")
    // @runtimeProperty("ModSettings.displayValues.RedMenace", "Red Menace")
    // @runtimeProperty("ModSettings.displayValues.Imogen", "Imogen")
    // @runtimeProperty("ModSettings.displayValues.CheriNowlin", "Cheri Nowlin")
    // @runtimeProperty("ModSettings.displayValues.ChloeVendranord", "Chloe Vendranord")
    // @runtimeProperty("ModSettings.displayValues.EvelynParker", "Evelyn Parker")
    // @runtimeProperty("ModSettings.displayValues.AngelicaWhelan", "Angelica Whelan")

    public let character: CharacterSetting = CharacterSetting.Panam;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Model")
    @runtimeProperty("ModSettings.description", "Controls the LLM powering the character.")
    @runtimeProperty("ModSettings.displayValues.StableHorde", "Stable Horde")
    @runtimeProperty("ModSettings.displayValues.OpenAI", "ChatGPT")
    @runtimeProperty("ModSettings.displayValues.OpenRouter", "Open Router")
    public let aiModel: LLMProvider = LLMProvider.StableHorde;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Google API Key")
    @runtimeProperty("ModSettings.displayValues.Primary", "Primary Key")
    @runtimeProperty("ModSettings.displayValues.Backup", "Backup Key")
    @runtimeProperty("ModSettings.displayValues.Third", "Third Key")
    @runtimeProperty("ModSettings.displayValues.Fourth", "Fourth Key")
    @runtimeProperty("ModSettings.displayValues.Fifth", "Fifth Key")
    @runtimeProperty("ModSettings.displayValues.Sixth", "Sixth Key")
    @runtimeProperty("ModSettings.displayValues.Seventh", "Seventh Key")
    @runtimeProperty("ModSettings.displayValues.Eighth", "Eighth Key")
    @runtimeProperty("ModSettings.displayValues.Ninth", "Ninth Key")
    @runtimeProperty("ModSettings.displayValues.Tenth", "Tenth Key")
    @runtimeProperty("ModSettings.displayValues.Eleventh", "Eleventh Key")
    @runtimeProperty("ModSettings.displayValues.Twelfth", "Twelfth Key")
    @runtimeProperty("ModSettings.displayValues.Thirteenth", "Thirteenth Key")
    @runtimeProperty("ModSettings.displayValues.Fourteenth", "Fourteenth Key")
    @runtimeProperty("ModSettings.displayValues.Fifteenth", "Fifteenth Key")
    @runtimeProperty("ModSettings.displayValues.Sixteenth", "Sixteenth Key")
    @runtimeProperty("ModSettings.displayValues.Seventeenth", "Seventeenth Key")
    @runtimeProperty("ModSettings.displayValues.Eighteenth", "Eighteenth Key")
    @runtimeProperty("ModSettings.displayValues.Nineteenth", "Nineteenth Key")
    @runtimeProperty("ModSettings.displayValues.Twentieth", "Twentieth Key")
    @runtimeProperty("ModSettings.displayValues.Twentieth", "Twentieth Key")
    @runtimeProperty("ModSettings.displayValues.TwentyFirst", "Twenty-First Key")
    @runtimeProperty("ModSettings.displayValues.TwentySecond", "Twenty-Second Key")
    @runtimeProperty("ModSettings.displayValues.TwentyThird", "Twenty-Third Key")
    @runtimeProperty("ModSettings.displayValues.TwentyFourth", "Twenty-Fourth Key")
    @runtimeProperty("ModSettings.displayValues.TwentyFifth", "Twenty-Fifth Key")
    @runtimeProperty("ModSettings.displayValues.TwentySixth", "Twenty-Sixth Key")
    @runtimeProperty("ModSettings.displayValues.TwentySeventh", "Twenty-Seventh Key")
    @runtimeProperty("ModSettings.displayValues.TwentyEighth", "Twenty-Eighth Key")
    @runtimeProperty("ModSettings.displayValues.TwentyNinth", "Twenty-Ninth Key")
    @runtimeProperty("ModSettings.displayValues.Thirtieth", "Thirtieth Key")
    public let googleKeyChoice: GoogleKeyChoice = GoogleKeyChoice.Primary;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Language")
    @runtimeProperty("ModSettings.description", "Controls the language of the generated text. Works more consistently with ChatGPT.")
    @runtimeProperty("ModSettings.displayValues.English", "English")
    @runtimeProperty("ModSettings.displayValues.Spanish", "Spanish")
    @runtimeProperty("ModSettings.displayValues.French", "French")
    @runtimeProperty("ModSettings.displayValues.German", "German")
    @runtimeProperty("ModSettings.displayValues.Italian", "Italian")
    @runtimeProperty("ModSettings.displayValues.Portuguese", "Portuguese")
    public let language: PlayerLanguage = PlayerLanguage.English;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Romance")
    @runtimeProperty("ModSettings.description", "Controls whether the responses are predisposed to romance.")
    public let romance: Bool = false;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Partner")
    @runtimeProperty("ModSettings.description", "This character will always be in romantic mode regardless of the romance toggle.")
    @runtimeProperty("ModSettings.displayValues.None", "None")
    @runtimeProperty("ModSettings.displayValues.Panam", "Panam Palmer")
    @runtimeProperty("ModSettings.displayValues.Judy", "Judy Alvarez")
    @runtimeProperty("ModSettings.displayValues.River", "River Ward")
    @runtimeProperty("ModSettings.displayValues.Kerry", "Kerry Eurodyne")
    @runtimeProperty("ModSettings.displayValues.Songbird", "Songbird")
    @runtimeProperty("ModSettings.displayValues.Rogue", "Rogue Amendiares")
    @runtimeProperty("ModSettings.displayValues.BlueMoon", "Blue Moon")
    @runtimeProperty("ModSettings.displayValues.RitaWheeler", "Rita Wheeler")
    @runtimeProperty("ModSettings.displayValues.LizzyWizzy", "Lizzy Wizzy")
    @runtimeProperty("ModSettings.displayValues.HanakoArasaka", "Hanako Arasaka")
    @runtimeProperty("ModSettings.displayValues.ElizabethPeralez", "Elizabeth Peralez")
    @runtimeProperty("ModSettings.displayValues.JossKutcher", "Joss Kutcher")
    @runtimeProperty("ModSettings.displayValues.ClaireRussell", "Claire Russell")
    @runtimeProperty("ModSettings.displayValues.ViktorVektor", "Viktor Vektor")
    @runtimeProperty("ModSettings.displayValues.Reed", "Reed")
    @runtimeProperty("ModSettings.displayValues.Alex", "Alex")
    @runtimeProperty("ModSettings.displayValues.IrisTanner", "Iris Tanner")
    @runtimeProperty("ModSettings.displayValues.MaikoMaeda", "Maiko Maeda")
    @runtimeProperty("ModSettings.displayValues.MichikoArasaka", "Michiko Arasaka")
    @runtimeProperty("ModSettings.displayValues.AuroreCassel", "Aurore Cassel")
    @runtimeProperty("ModSettings.displayValues.PurpleForce", "Purple Force")
    @runtimeProperty("ModSettings.displayValues.RedMenace", "Red Menace")
    @runtimeProperty("ModSettings.displayValues.Imogen", "Imogen")
    @runtimeProperty("ModSettings.displayValues.CheriNowlin", "Cheri Nowlin")
    @runtimeProperty("ModSettings.displayValues.ChloeVendranord", "Chloe Vendranord")
    @runtimeProperty("ModSettings.displayValues.EvelynParker", "Evelyn Parker")
    @runtimeProperty("ModSettings.displayValues.AngelicaWhelan", "Angelica Whelan")
    @runtimeProperty("ModSettings.displayValues.Bugbear", "Bugbear")
    @runtimeProperty("ModSettings.displayValues.Takemura", "Takemura")
    @runtimeProperty("ModSettings.displayValues.MeredithStout", "Meredith Stout")
    public let partner: PartnerSetting = PartnerSetting.None;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Courting Mode *Romance switch off* ")
    @runtimeProperty("ModSettings.description", "Enables a flirty, uncertain 'will they/won't they' dynamic.")
    public let courting: Bool = false;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Time Awareness")
    @runtimeProperty("ModSettings.description", "Tells the AI the current in-game time and day.")
    public let timeAwareness: Bool = true;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "V Background")
    @runtimeProperty("ModSettings.description", "Includes V's appearance, personality, background and events in the AI prompt. Edit v_background.json in your chats folder to customise.")
    public let vBackground: Bool = true;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "NPC Callout")
    @runtimeProperty("ModSettings.description", "NPCs will randomly send you an unprompted text to start a conversation.")
    public let npcCallout: Bool = false;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Callout Delay (minutes)")
    @runtimeProperty("ModSettings.description", "How many minutes between NPC callout messages. Set low for testing.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "15")
    @runtimeProperty("ModSettings.max", "60")
    public let npcCalloutDelay: Int32 = 15;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Songbird Ending")
    @runtimeProperty("ModSettings.description", "Sets the outcome of Songbird's questline. Affects her context and chat behaviour.")
    @runtimeProperty("ModSettings.displayValues.Default", "Default")
    @runtimeProperty("ModSettings.displayValues.KingOfWands", "King of Wands")
    @runtimeProperty("ModSettings.displayValues.KingOfSwords", "King of Swords")
    @runtimeProperty("ModSettings.displayValues.KingOfPentacles", "King of Pentacles")
    public let songbirdEnding: SongbirdEnding = SongbirdEnding.Default;


    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Temperature")
    @runtimeProperty("ModSettings.description", "Controls the randomness of the generated text. Lower = more predictable, higher = more random.")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "2.0")
    public let temperature: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Top K")
    @runtimeProperty("ModSettings.description", "Limits the token pool to the K most likely tokens. A lower number is more consistent but less creative.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "100")
    public let top_k: Int32 = 0;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Top P")
    @runtimeProperty("ModSettings.description", "Limits the token pool to however many tokens it takes for their probabilities to add up to P. A lower number is more consistent but less creative.")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    public let top_p: Float = 0.95;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Top A")
    @runtimeProperty("ModSettings.description", "The number of tokens chosen from the most likely options is automatically determined based on the likelihood distribution of the options, but instead of choosing the Top P or Top K tokens, it chooses all tokens with probabilities above a certain threshold.")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    public let top_a: Float = 0.0;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Tail Free Sampling (TFS)")
    @runtimeProperty("ModSettings.description", "Removes the least probable tokens from consideration during text generation, which can improve the quality and coherence of the generated text.")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    public let tfs: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Minimum Probability (Min P)")
    @runtimeProperty("ModSettings.description", "Limits the token pool by cutting off low-probability tokens relative to the top token. Produces more coherent responses but can also worsen repetition if set too high.")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    public let min_p: Float = 0.05;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Typical P")
    @runtimeProperty("ModSettings.description", "Selects tokens randomly from the list of possible tokens, with each token having an equal chance of being selected. Produces responses that are more diverse but may also be less coherent.")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    public let typical: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Enable Logs")
    @runtimeProperty("ModSettings.description", "Allows you to view logs in the CET console.")
    public let logging: Bool = false;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "Enable Random Delay (Google AI Text Mode)")
    @runtimeProperty("ModSettings.description", "Adds 20 sec - 5 min delay before Google AI sends text messages. Does not affect Live Mode.")
    public let enableTextDelay: Bool = false;

    @runtimeProperty("ModSettings.mod", "Generative Texting")
    @runtimeProperty("ModSettings.displayName", "OpenRouter Model")
    @runtimeProperty("ModSettings.description", "The model to use with OpenRouter e.g. mistralai/mistral-7b-instruct")
    // openrouterhere
    public let openRouterModel: String = "xxx";

    public func OnCharacterSelected(characterName: String) -> Void {
        // Hooked by Lua
    }


    // Load chat history for current character
    public func LoadCurrentChat() {
        if !this.initialized || this.disabled {
            return;
        }

        ConsoleLog(s"[LoadCurrentChat] this.character = \(this.character)");
        let characterName: String = this.isGroupChat 
        ? GetChatStorage().GetGroupChatFileName(this.groupCharacter1, this.groupCharacter2)
        : GetChatStorage().GetCharacterFileName(this.character);
        let messages: array<ref<ChatMessage>> = GetChatStorage().LoadChatHistory(characterName);

        ConsoleLog(s"[LoadCurrentChat] Loading \(ArraySize(messages)) messages for \(characterName)");

        // Clear existing messages
        GetHttpRequestSystem().vMessages = [];
        GetHttpRequestSystem().npcResponses = [];
        ArrayClear(GetHttpRequestSystem().npcResponsesLiveMode);  // ✅ USE HttpRequestSystem version

        // Load only last 40 messages
        let totalMessages: Int32 = ArraySize(messages);
        let startIndex: Int32 = totalMessages > 100 ? totalMessages - 100 : 0;

        // Rebuild conversation from loaded messages
        let i: Int32 = startIndex;
        while i < totalMessages {
            let msg: ref<ChatMessage> = messages[i];
            
            if msg.fromPlayer {
                // Add player message
                ArrayPush(GetHttpRequestSystem().vMessages, msg.text);
                
                // Check if next message is NPC response
                if i + 1 < totalMessages && !messages[i + 1].fromPlayer {
                    ArrayPush(GetHttpRequestSystem().npcResponses, messages[i + 1].text);
                    ArrayPush(GetHttpRequestSystem().npcResponsesLiveMode, messages[i + 1].isLiveMode);  // ✅ CORRECT
                    i += 2;  // Skip both player and NPC message (we processed them)
                } else {
                    // No NPC response for this player message yet
                    ArrayPush(GetHttpRequestSystem().npcResponses, "");
                    ArrayPush(GetHttpRequestSystem().npcResponsesLiveMode, false);  // ✅ CORRECT
                    i += 1;  // Only skip player message
                }
            } else {
                // Orphaned NPC message (shouldn't happen, but handle it)
                ConsoleLog(s"[WARNING] Found orphaned NPC message at index \(i)");
                i += 1;
            }
        }

        ConsoleLog(s"[LoadCurrentChat] Loaded \(ArraySize(GetHttpRequestSystem().vMessages)) player messages, \(ArraySize(GetHttpRequestSystem().npcResponses)) NPC responses");
    }



    // Initialize callbacks, widgets, and other necessary components
    private func InitializeSystem() {
        this.player = GetPlayer(GetGameInstance());
        this.npcSelected = false;
        this.chatOpen = false;
        this.isTyping = false;
        this.isGroupChat = false;
        this.callbackSystem = GameInstance.GetCallbackSystem();
        this.callbackSystem.UnregisterCallback(n"Input/Key", this, n"OnKeyInput");
        this.callbackSystem.UnregisterCallback(n"Input/Axis", this, n"OnAxisInput");
        ModSettings.RegisterListenerToClass(this);
        this.GetWidgetReferences(54);
        this.InitializeDefaultPhoneController();
        this.SetupChatContainer();
        this.initialized = true;
        GetHttpRequestSystem().ToggleIsGenerating(false);
        this.LoadCurrentChat();
        this.lastActiveCharacter = this.character;
        this.StartCalloutTimer();

    }

    private func GetWidgetReferences(middleWidgetIndex: Int32) {
        let inkSystem = GameInstance.GetInkSystem();
        let virtualWindow = inkSystem.GetLayer(n"inkHUDLayer").GetVirtualWindow();
        let virtualWindowRoot = virtualWindow.GetWidget(0) as inkCanvas;
        let hudMiddleWidget = virtualWindowRoot.GetWidget(middleWidgetIndex) as inkCanvas;
        this.parent = hudMiddleWidget.GetWidget(0) as inkCanvas;
        this.contactListSlot = FindWidgetWithName(this.parent, n"contact_list_slot") as inkCanvas;
        this.defaultChatUi = FindWidgetWithName(this.parent, n"sms_messenger_slot") as inkCanvas;
        if !IsDefined(this.contactListSlot) {
            if middleWidgetIndex < 45 {
                this.disabled = true;
                return;
            }
            this.GetWidgetReferences(middleWidgetIndex - 1);
        } else {
            this.disabled = false;
        }
    }

    // Handle key input events
    private cb func OnKeyInput(event: ref<KeyInputEvent>) {
        if NotEquals(s"\(event.GetAction())", "IACT_Press") {
            return;
        }

        if this.isTyping {
            if Equals(s"\(event.GetKey())", "IK_Enter") {
                this.isTyping = false;
                let message = this.GetInputText();
                if Equals(StrLen(message), 0) {
                    this.UpdateInputUi();
                    return;
                }
                
                // CRITICAL: Check if HttpRequestSystem is ready
                let httpSystem = GetHttpRequestSystem();
                if !IsDefined(httpSystem) {
                    this.PlaySound(n"ui_menu_onpress");
                    this.UpdateInputUi();
                    return;
                }
                
                this.BuildMessage(message, true, true, httpSystem.GetLiveMode());
            } else {
                this.PlaySound(n"ui_menu_mouse_click");
            }
            return;
        }

        if Equals(s"\(event.GetKey())", "IK_T") {
            if this.disabled {
                return;
            }
            if !this.chatOpen {
                if IsModCharacterContact(this.hoveredContactId) {
                    if !this.isGroupChat {
                        this.character = GetCharacterFromContactName(this.hoveredContactId);
                        this.ToggleNpcSelected(true);
                        this.HidePhoneUi();
                        this.OnCharacterSelected(ToString(this.character));
                        ModSettings.AcceptChanges();
                    }
                }
            }
        }

        if Equals(s"\(event.GetKey())", "IK_G") {
            if this.disabled { return; }
            if !this.chatOpen {
                if IsModCharacterContact(this.hoveredContactId) {
                    if !this.isGroupChat {
                        // First press - set char 1 and enable group mode
                        this.groupCharacter1 = GetCharacterFromContactName(this.hoveredContactId);
                        this.groupCharacter2 = CharacterSetting.Panam; // reset char 2 so it can't accidentally match char 1
                        this.isGroupChat = true;
                        this.PlaySound(n"ui_menu_onpress");
                    } else {
                        // Second press - must be a different character than char 1
                        let selectedChar = GetCharacterFromContactName(this.hoveredContactId);
                        if Equals(EnumInt(selectedChar), EnumInt(this.groupCharacter1)) {
                            // Same character selected twice - ignore and play error sound
                            this.PlaySound(n"ui_menu_map_pin_off");
                        } else {
                            this.groupCharacter2 = selectedChar;
                            this.character = this.groupCharacter1;
                            this.ToggleNpcSelected(true);
                            this.HidePhoneUi();
                        }
                    }
                }
            } else {
                // Close and reset group chat
                this.isGroupChat = false;
                this.npcSelected = false;
                this.chatOpen = false;
                this.ShowPhoneUI();
            }
        }

        if Equals(s"\(event.GetKey())", "IK_C") {
            if this.chatOpen {
                this.npcSelected = false;
                this.chatOpen = false;
                this.isGroupChat = false;
                this.ShowPhoneUI();
            } else {
                return;
            }
        }

        if Equals(s"\(event.GetKey())", "IK_R") {
            if (this.chatOpen && !this.isTyping) {
                this.ResetConversation(true);
            } else {
                return;
            }
        }

        if Equals(s"\(event.GetKey())", "IK_Z") {
            if (this.chatOpen && !this.isTyping) {
                this.UndoMessage();
            } else {
                return;
            }
        }

        if Equals(s"\(event.GetKey())", "IK_L") {
            if (this.chatOpen && !this.isTyping) {
                this.ToggleLiveMode();
            } else {
                return;
            }
        }

        if Equals(s"\(event.GetKey())", "IK_1") {
            if (this.chatOpen && !this.isTyping && !GetHttpRequestSystem().GetIsGenerating()) {
                this.CreateMemory();
            }
        }

        if Equals(s"\(event.GetKey())", "IK_O") {
            if (this.chatOpen && !this.isTyping && !GetHttpRequestSystem().GetIsGenerating()) {
                this.TriggerAIFirstContact();
            }
        } 





        if Equals(s"\(event.GetKey())", "IK_LeftMouse") {
            if (!this.chatOpen || this.isTyping ) {
                return;
            } 

            if GetHttpRequestSystem().GetIsGenerating() {
                return;
            }

            this.isTyping = true;
            this.typedMessageText.SetText("Start Typing...");
            this.typedMessageText.SetVisible(false);
            this.chatInputHint.SetTexturePart(n"kb_enter");

            this.BuildInput();
        }
    }

    // Handle scrolling messages
    private cb func OnAxisInput(event: ref<AxisInputEvent>) {
        if Equals(s"\(event.GetKey())", "IK_MouseZ") {
            if Equals(event.GetValue(), 1.0) {
                this.chatScrollController.Scroll(1.0, true);
            } else if Equals(event.GetValue(), -1.0) {
                this.chatScrollController.Scroll(-1.0, true);
            }
        }
    }

    // Reset the conversation history and remove all messages
    private func ResetConversation(playSound: Bool) {
        GetHttpRequestSystem().ResetConversation();
        this.messageParent.RemoveAllChildren();

        // Clear persistent storage
        let characterName = this.isGroupChat
            ? GetChatStorage().GetGroupChatFileName(this.groupCharacter1, this.groupCharacter2)
            : GetChatStorage().GetCharacterFileName(this.character);
        GetChatStorage().ClearChatHistory(characterName);
        
        if playSound {
            this.PlaySound(n"ui_menu_map_pin_off");
        }
    }

    // Undo the last message sent from the NPC and V
    private func UndoMessage() {
        GetHttpRequestSystem().UndoMessage();
        let len = this.messageParent.GetNumChildren();
        if len > 0 {
            this.messageParent.RemoveChild(this.messageParent.GetWidget(len - 1));
            this.messageParent.RemoveChild(this.messageParent.GetWidget(len - 2));
            this.PlaySound(n"ui_menu_map_pin_off");
        }
    }

    private func TriggerAIFirstContact() {
        // Create a fake player message that tells AI to initiate
        let fakeMessage = "+It's been a while. Reach out to V naturally in context with conversation history - ask how they're doing or share something on your mind.";
        
        // Send directly to AI WITHOUT showing in chat UI
        GetHttpRequestSystem().TriggerPostRequest(fakeMessage);
        GetHttpRequestSystem().AppendToHistory("[AI initiated contact]", true, false);
        this.PlaySound(n"ui_menu_onpress");
    }


    public func OnModSettingsChange() -> Void {
    }    


    public func StartCalloutTimer() -> Void {
    this.lastCalloutScheduledTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTimeStamp();
    let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
    let delaySeconds: Float = Cast<Float>(this.npcCalloutDelay) * 60.0;
    delaySystem.DelayCallback(NpcCalloutCallback.Create(this), delaySeconds, false);
}


    public func TrimOldestMessage() -> Void {
        if !IsDefined(this.messageParent) {
            return;
        }

        let numChildren: Int32 = this.messageParent.GetNumChildren();
        if numChildren >= 20 {
            this.messageParent.RemoveChild(this.messageParent.GetWidget(0));
            this.messageParent.RemoveChild(this.messageParent.GetWidget(0));
        }
    }

    // Store which contact is currently hovered in the phonebook
    public func SetHoveredContact(contactId: String) -> Void {
        this.hoveredContactId = contactId;
    }


    public func RegisterSwitchKey() -> Void {
        this.callbackSystem.RegisterCallback(n"Input/Key", this, n"OnKeyInput", true)
            .AddTarget(InputTarget.Key(EInputKey.IK_T));
        this.callbackSystem.RegisterCallback(n"Input/Key", this, n"OnKeyInput", true)
            .AddTarget(InputTarget.Key(EInputKey.IK_G));
    }

    public func UnregisterSwitchKey() -> Void {
        this.callbackSystem.UnregisterCallback(n"Input/Key", this, n"OnKeyInput");
    }


    // Handle selecting an NPC
    public func ToggleNpcSelected(value: Bool) {
        if !this.initialized {
            this.InitializeSystem();
        } 

        this.npcSelected = value;
        // Keep menu selection in sync with active chat character
        if value {
            this.hoveredContactId = GetChatStorage().GetCharacterFileName(this.character);
        }

        if this.npcSelected {
            if NotEquals(this.lastActiveCharacter, this.character) || this.isGroupChat {
                this.lastActiveCharacter = this.character;

                // Clear UI
                if IsDefined(this.messageParent) {
                    this.messageParent.RemoveAllChildren();
                }

                // Clear in-memory arrays
                GetHttpRequestSystem().vMessages = [];
                GetHttpRequestSystem().npcResponses = [];
                ArrayClear(GetHttpRequestSystem().npcResponsesLiveMode);

                // Load the new character's chat from JSON
                this.LoadCurrentChat();
            }
            this.callbackSystem.RegisterCallback(n"Input/Key", this, n"OnKeyInput", true)
                .AddTarget(InputTarget.Key(EInputKey.IK_T));
            this.callbackSystem.RegisterCallback(n"Input/Key", this, n"OnKeyInput", true)
                .AddTarget(InputTarget.Key(EInputKey.IK_G));
        } else {
            this.callbackSystem.UnregisterCallback(n"Input/Key", this, n"OnKeyInput");
            this.callbackSystem.UnregisterCallback(n"Input/Axis", this, n"OnAxisInput");
        }
    }


    public func ToggleIsTyping(value: Bool) {
        this.isTyping = value;
    }

    public func ToggleUnread(value: Bool) {
        this.unread = value;
    }

    public func GetUnread() -> Bool {
        return this.unread;
    }

    public final func GetGroupFirstSelected() -> Bool {
        return this.isGroupChat;
    }

    // Update the input UI based on the current state
    public func UpdateInputUi() {
        let input = this.typedMessageWrapper.GetWidget(2) as inkCompoundWidget;
        if GetHttpRequestSystem().GetIsGenerating() {
            this.typedMessageWrapper.RemoveChildByName(input.GetName());
            this.typedMessageText.SetVisible(true);
            this.typedMessageText.SetText("Send a message.");
            this.typedMessageText.SetOpacity(0.2);
            this.chatInputHint.SetTexturePart(n"mouse_left");
            this.chatInputHint.SetOpacity(0.2);
        } else if !this.isTyping {
            this.typedMessageWrapper.RemoveChildByName(input.GetName());
            this.typedMessageText.SetVisible(true);
            this.typedMessageText.SetText("Send a message.");
            this.typedMessageText.SetOpacity(1);
            this.chatInputHint.SetTexturePart(n"mouse_left");
            this.chatInputHint.SetOpacity(1);
        } else {
            this.typedMessageText.SetOpacity(1);
            this.chatInputHint.SetOpacity(1);
        }
    }

    // Show the mod chat UI
    private func ShowModChat() {
        this.chatOpen = true;
        this.parent.ReorderChild(this.chatContainer, 12);
        this.parent.ReorderChild(this.defaultChatUi, 14);
        GetTextingSystem().ToggleUnread(false);
        this.BuildChatUi();
        this.BuildConversation();
        this.UpdateLiveModeUI();
        this.PlaySound(n"ui_menu_map_pin_created");
        this.callbackSystem.RegisterCallback(n"Input/Key", this, n"OnKeyInput", true);
        this.callbackSystem.RegisterCallback(n"Input/Axis", this, n"OnAxisInput", true);
        if IsDefined(this.chatScrollController) {
            this.chatScrollController.SetScrollPosition(1.0);
            
        }
    }

    // Hide the mod chat UI
    public func HideModChat() {
        this.parent.ReorderChild(this.defaultChatUi, 12);
        this.parent.ReorderChild(this.chatContainer, 14);
        this.chatContainer.RemoveAllChildren();
        this.chatOpen = false;
    }

    // Hide the default phone UI
    public func HidePhoneUi() {
        if IsDefined(this.defaultPhoneController) {            
            this.defaultPhoneController.DisableContactsInput();
            this.ToggleContactList(false);
            this.ShowModChat();
        } else {
            this.InitializeDefaultPhoneController();
        }
    }

    // Show the default phone UI
    private func ShowPhoneUI() {
        if (IsDefined(this.defaultPhoneController) && IsDefined(this.contactListSlot)) {            
            this.defaultPhoneController.EnableContactsInput();
            this.ToggleContactList(true);
        } else {
            this.InitializeDefaultPhoneController();
            this.ShowPhoneUI();
        }
        this.HideModChat();
    }

    private func ToggleContactList(value: Bool) {
        let contactListRoot = this.contactListSlot.GetWidget(0) as inkCanvas;
        let contactListContainer = contactListRoot.GetWidget(0) as inkCanvas;
        let contactCentralContainer = contactListContainer.GetWidget(1) as inkVerticalPanel;
        if !IsDefined(contactCentralContainer) {
            return;
        }
        if value {
            contactCentralContainer.SetVisible(true);
        } else {
            contactCentralContainer.SetVisible(false);
        }
    }

    // Build the widget containing the chat message list
    private func SetupChatContainer() {
        if this.parent.GetNumChildren() > 14 {
            this.parent.RemoveChildByName(n"mod_messenger_slot");
        }

        let modMessengerSlot = new inkCanvas();
        modMessengerSlot.Reparent(this.parent);
        modMessengerSlot.SetMargin(new inkMargin(80.0, 480.0, 0.0, 0.0));
        modMessengerSlot.SetChildOrder(inkEChildOrder.Backward);
        modMessengerSlot.SetName(n"mod_messenger_slot");

        this.chatContainer = modMessengerSlot;
    }

    // Get a reference to the phone controller
    private func InitializeDefaultPhoneController() {
        let inkSystem = GameInstance.GetInkSystem();

        for controller in inkSystem.GetLayer(n"inkHUDLayer").GetGameControllers() {
            if Equals(s"\(controller.GetClassName())", "NewHudPhoneGameController") {
                this.defaultPhoneController = controller as NewHudPhoneGameController;
            }
        }
    }

    private func PlaySound(sound: CName) {
        GameObject.PlaySoundEvent(this.player, sound);
    }

    // Build the input widget for the chat
    private func BuildInput() {
        let inkSystem = GameInstance.GetInkSystem();
        let input = HubTextInput.Create();
        input.SetText("");
        input.Reparent(this.typedMessageWrapper);

        let inputWidget = this.typedMessageWrapper.GetWidget(2) as inkCompoundWidget;
        inputWidget.RemoveChildByName(n"theme");
        inputWidget.SetTranslation(new Vector2(0.0, -9.0));

        let inputChild1 = inputWidget.GetWidget(1) as inkCompoundWidget;
        let inputChild2 = inputChild1.GetWidget(0) as inkCompoundWidget;
        let inputChild3 = inputChild2.GetWidget(1) as inkText;
        inputChild3.SetTintColor(new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u)));

        inkSystem.SetFocus(input.GetRootWidget());
    }

    // Get the text from the input widget
    private func GetInputText() -> String {
        let input = this.typedMessageWrapper.GetWidget(2) as inkCompoundWidget;
        let inputChild1 = input.GetWidget(1) as inkCompoundWidget;
        let inputChild2 = inputChild1.GetWidget(0) as inkCompoundWidget;
        let inputChild3 = inputChild2.GetWidget(1) as inkText;
        let message = inputChild3.GetText();
        return message;
    }

    public func GetChatOpen() -> Bool {
        return this.chatOpen;
    }

    public func ToggleTypingIndicator(value: Bool) {
        if value {
            this.typingIndicator.SetVisible(!this.typingIndicator.IsVisible());
            if this.typingIndicator.IsVisible() {
                this.PlaySound(n"ui_messenger_typing");
            }
        } else {
            this.typingIndicator.SetVisible(false);
        }
    }

    private func ToggleLiveMode() {
        // Toggle the mode in HttpRequestSystem
        GetHttpRequestSystem().ToggleLiveMode();
    
        // Update the UI
        this.UpdateLiveModeUI();
    
        // Play sound
        this.PlaySound(n"ui_menu_onpress");
    }

    public func UpdateLiveModeUI() {
        if !IsDefined(this.liveModeHintIcon) || !IsDefined(this.liveModeHintText) {
            return;
        }
        
        // ✅ Get CURRENT toggle state from HttpRequestSystem
        let isLiveMode = GetHttpRequestSystem().GetLiveMode();
        
        // Find the contact name text widget by traversing the hierarchy
        if IsDefined(this.messengerSlotRoot) {
            let rootContainer = this.messengerSlotRoot.GetWidget(0) as inkCanvas;
            
            if IsDefined(rootContainer) {
                let topHolder = rootContainer.GetWidget(0) as inkFlex;
                
                if IsDefined(topHolder) {
                    let horizontalPanel = topHolder.GetWidget(0) as inkHorizontalPanel;
                    
                    if IsDefined(horizontalPanel) {
                        let nameHolder = horizontalPanel.GetWidget(1) as inkFlex;
                        
                        if IsDefined(nameHolder) {
                            let nameText = nameHolder.GetWidget(1) as inkText;
                            
                            if IsDefined(nameText) {
                                // ✅ Use CURRENT toggle state
                                if isLiveMode {
                                    // LIVE MODE - Yellow
                                    nameText.SetTintColor(new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u)));
                                } else {
                                    // TEXT MODE - Blue
                                    nameText.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Update the mode indicator based on CURRENT state
        if isLiveMode {
            // LIVE MODE
            this.liveModeHintIcon.SetTexturePart(n"ico_speaker");
            this.liveModeHintText.SetText("LIVE MODE");
            this.liveModeHintText.SetTintColor(new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u)));
        } else {
            // TEXT MODE
            this.liveModeHintIcon.SetTexturePart(n"ico_envelelope_reply1");
            this.liveModeHintText.SetText("TEXT MODE");
            this.liveModeHintText.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        }
    }

    // Build a message for the player or NPC
    private func BuildMessage(text: String, fromPlayer: Bool, useAnim: Bool, wasLiveMode: Bool) {
        if !IsDefined(this.messageParent) {
            return;
        }

        let message = new inkFlex();
        message.SetName(n"Root");
        message.SetHAlign(inkEHorizontalAlign.Left);
        message.SetSize(new Vector2(100.0, 100.0));
        message.SetStyle(r"base\\gameplay\\gui\\fullscreen\\phone_quest_menu\\messenger.inkstyle");
        message.Reparent(this.messageParent);

        let wide = new inkCanvas();
        wide.SetName(n"wide");
        wide.SetHAlign(inkEHorizontalAlign.Left);
        wide.SetSize(new Vector2(1200.0, 600.0));
        wide.SetChildOrder(inkEChildOrder.Backward);
        wide.Reparent(message);

        let messageContainer = new inkFlex();
        messageContainer.SetName(n"container");
        messageContainer.SetVAlign(inkEVerticalAlign.Top);
        messageContainer.SetSize(new Vector2(100.0, 100.0));
        messageContainer.Reparent(message);

        let messageBackground = new inkImage();
        messageBackground.SetName(n"background");
        messageBackground.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\phone\\new_phone_assets.inkatlas");
        messageBackground.SetNineSliceScale(true);
        messageBackground.SetTileHAlign(inkEHorizontalAlign.Left);
        messageBackground.SetTileVAlign(inkEVerticalAlign.Top);
        messageBackground.SetSize(new Vector2(32.0, 32.0));
        messageBackground.SetFitToContent(true);
    //    messageBackground.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    //    messageBackground.BindProperty(n"tintColor", n"Message.BackgroundColor");
        messageBackground.BindProperty(n"opacity", n"Message.BackgroundOpacity");
        messageBackground.Reparent(messageContainer);

        let messageBorder = new inkImage();
        messageBorder.SetName(n"border");
        messageBorder.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\phone\\new_phone_assets.inkatlas");
        messageBorder.SetNineSliceScale(true);
        messageBorder.SetTileHAlign(inkEHorizontalAlign.Left);
        messageBorder.SetTileVAlign(inkEVerticalAlign.Top);
        messageBorder.SetOpacity(0.5);
        messageBorder.SetSize(new Vector2(32.0, 32.0));
        messageBorder.SetFitToContent(true);
      //  messageBorder.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
     //   messageBorder.BindProperty(n"tintColor", n"Message.BorderColor");
        messageBorder.Reparent(messageContainer);

        let messageContent = new inkVerticalPanel();
        messageContent.SetName(n"container");
        messageContent.SetHAlign(inkEHorizontalAlign.Left);
        messageContent.SetVAlign(inkEVerticalAlign.Top);
        messageContent.SetMargin(new inkMargin(24.0, 20.0, 20.0, 30.0));
        messageContent.SetFitToContent(true);
        messageContent.Reparent(messageContainer);

        let messageText = new inkText();
        messageText.SetName(n"Message");
        messageText.SetText(text);
        messageText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        messageText.SetFontStyle(n"Medium");
        messageText.SetFontSize(42);
        messageText.SetLetterCase(textLetterCase.OriginalCase);
        messageText.SetContentVAlign(inkEVerticalAlign.Top);
        messageText.SetWrapping(true);
        messageText.SetWrappingAtPosition(1000);
        messageText.SetHAlign(inkEHorizontalAlign.Left);
        messageText.SetVAlign(inkEVerticalAlign.Top);
        messageText.SetMargin(new inkMargin(0.0, 0.0, 10.0, 0.0));
        messageText.SetSize(new Vector2(0.0, 32.0));
        messageText.SetFitToContent(true);
    //    messageText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
     //   messageText.BindProperty(n"tintColor", n"Message.TextColor");
     //   messageText.BindProperty(n"fontSize", n"MainColors.ReadableMedium");
        messageText.Reparent(messageContent);

        if fromPlayer {
            message.SetState(n"Player");
            messageContainer.SetHAlign(inkEHorizontalAlign.Right);
            messageBackground.SetTexturePart(n"msgBuble_reply_bg");
            messageBackground.SetTintColor(new Color(Cast(0u), Cast(255u), Cast(198u), Cast(255u)));
            messageBackground.SetOpacity(0.05);
            messageBorder.SetTexturePart(n"msgBuble_reply_fg");
            messageBorder.SetTintColor(new Color(Cast(0u), Cast(255u), Cast(198u), Cast(255u)));
            messageText.SetTintColor(new Color(Cast(0u), Cast(255u), Cast(188u), Cast(255u)));
            
            if useAnim {
                GetHttpRequestSystem().lastNpcResponse = "";
                
                this.StartCalloutTimer();
                
                GetHttpRequestSystem().TriggerPostRequest(text);
                GetHttpRequestSystem().AppendToHistory(text, true, GetHttpRequestSystem().GetLiveMode());
            }
        } else {
            // NPC message - use the saved mode state, not current mode
            let isLiveMode = wasLiveMode;
            
            messageContainer.SetHAlign(inkEHorizontalAlign.Left);
            messageBackground.SetTexturePart(n"msgBuble_bg");
            messageBorder.SetTexturePart(n"msgBuble_fg");
            
            if isLiveMode {
                // LIVE MODE - Yellow/Orange colors
                messageBackground.SetTintColor(new Color(Cast(50u), Cast(40u), Cast(10u), Cast(255u)));
                messageBackground.SetOpacity(0.35);
                messageBorder.SetTintColor(new Color(Cast(161u), Cast(126u), Cast(51u), Cast(255u)));
                messageText.SetTintColor(new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u)));
            } else {
                // TEXT MODE - Blue colors (original)
                messageBackground.SetTintColor(new Color(Cast(23u), Cast(44u), Cast(46u), Cast(255u)));
                messageBackground.SetOpacity(0.35);
                messageBorder.SetTintColor(new Color(Cast(52u), Cast(145u), Cast(151u), Cast(255u)));
                messageText.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
            }
        }

        

        if useAnim {
            let translateAnimMessage = new inkAnimTranslation();
            translateAnimMessage.SetStartTranslation(new Vector2(0.0, 50.0));
            translateAnimMessage.SetEndTranslation(new Vector2(0, 0));
            translateAnimMessage.SetType(inkanimInterpolationType.Linear);
            translateAnimMessage.SetMode(inkanimInterpolationMode.EasyOut);
            translateAnimMessage.SetDuration(0.15);

            let alphaAnim = new inkAnimTransparency();
            alphaAnim.SetStartTransparency(0.0);
            alphaAnim.SetEndTransparency(1.0);
            alphaAnim.SetType(inkanimInterpolationType.Linear);
            alphaAnim.SetMode(inkanimInterpolationMode.EasyOut);
            alphaAnim.SetDuration(0.15);
            
            let animDefMessage = new inkAnimDef();
            animDefMessage.AddInterpolator(translateAnimMessage);
            animDefMessage.AddInterpolator(alphaAnim);

            message.PlayAnimation(animDefMessage);
            this.PlaySound(n"ui_messenger_recieved");
        }

        this.chatScrollController.SetScrollPosition(1.0);
    }

    // Retrieve and build the conversation based on the current history
    private func BuildConversation() {
        let vMessages = GetHttpRequestSystem().vMessages;
        let npcResponses = GetHttpRequestSystem().npcResponses;

        ConsoleLog(s"[BuildConversation] Building UI with \(ArraySize(vMessages)) player messages");
        let i = 0;

        while i < ArraySize(vMessages) {
            // Always build the player message
            this.BuildMessage(vMessages[i], true, false, false);
            
            // Check if there's a corresponding NPC response
            if i < ArraySize(npcResponses) && StrLen(npcResponses[i]) > 0 && !Equals(npcResponses[i], "[ACK]") {
                // Get the mode from HttpRequestSystem
                let npcLiveMode: Bool = false;

                if i < ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) {  // ✅ CORRECT
                    npcLiveMode = GetHttpRequestSystem().npcResponsesLiveMode[i];  // ✅ CORRECT
                }
            
                ConsoleLog(s"[BuildConversation] NPC response \(i): LiveMode=\(npcLiveMode)");
            
                if StrLen(npcResponses[i]) > 1000 {
                    let firstHalf = StrLeft(npcResponses[i], 1000);
                    let secondHalf = StrRight(npcResponses[i], StrLen(npcResponses[i]) - 1000);
                    this.BuildMessage(firstHalf, false, false, npcLiveMode);
                    this.BuildMessage(secondHalf, false, false, npcLiveMode);
                } else {
                    this.BuildMessage(npcResponses[i], false, false, npcLiveMode);
                }
            }

            i += 1;
        }

        this.UpdateInputUi();
    }

    // Build all widgets for the chat UI
    private func BuildChatUi() {

        let modMessengerSlotRoot = new inkCanvas();
        modMessengerSlotRoot.SetName(n"Root");
        modMessengerSlotRoot.SetStyle(r"base\\gameplay\\gui\\common\\styles\\panel.inkstyle");
        modMessengerSlotRoot.BindProperty(n"tintColor", n"MainColors.Blue");
        modMessengerSlotRoot.SetChildOrder(inkEChildOrder.Backward);
        modMessengerSlotRoot.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        modMessengerSlotRoot.SetSize(new Vector2(1500.0, 1500.0));
        modMessengerSlotRoot.Reparent(this.chatContainer);
        this.messengerSlotRoot = modMessengerSlotRoot;

        // Widgets under Root/container
        let rootContainer = new inkCanvas();
        rootContainer.SetName(n"container");
        rootContainer.SetMargin(new inkMargin(100.0, 0.0, 0.0, 0.0));
        rootContainer.SetSize(new Vector2(1550.0, 1200.0));
        rootContainer.SetChildOrder(inkEChildOrder.Backward);
        rootContainer.Reparent(modMessengerSlotRoot);

        let topHolder = new inkFlex();
        topHolder.SetName(n"top_holder");
        topHolder.SetAnchor(inkEAnchor.TopFillHorizontaly);
        topHolder.SetHAlign(inkEHorizontalAlign.Left);
        topHolder.SetVAlign(inkEVerticalAlign.Top);
        topHolder.SetMargin(new inkMargin(120.0, -60.0, 0.0, 0.0));
        topHolder.SetSize(new Vector2(100.0, 100.0));
        topHolder.Reparent(rootContainer);

        let horizontalPanelWidget5 = new inkHorizontalPanel();
        horizontalPanelWidget5.SetName(n"inkHorizontalPanelWidget5");
        horizontalPanelWidget5.SetSize(new Vector2(100.0, 100.0));
        horizontalPanelWidget5.SetFitToContent(true);
        horizontalPanelWidget5.SetVAlign(inkEVerticalAlign.Top);
        horizontalPanelWidget5.Reparent(topHolder);

        let pathContainer = new inkVerticalPanel();
        pathContainer.SetName(n"pathContainer");
        pathContainer.SetHAlign(inkEHorizontalAlign.Left);
        pathContainer.SetVAlign(inkEVerticalAlign.Top);
        pathContainer.SetPadding(new inkMargin(0.0, 0.0, 20.0, 0.0));
        pathContainer.SetFitToContent(true);
        pathContainer.Reparent(horizontalPanelWidget5);

        let messagesPath = new inkHorizontalPanel();
        messagesPath.SetName(n"messagesPath");
        messagesPath.SetOpacity(0.6);
        messagesPath.SetHAlign(inkEHorizontalAlign.Left);
        messagesPath.SetVAlign(inkEVerticalAlign.Top);
        messagesPath.SetSizeRule(inkESizeRule.Stretch);
        messagesPath.SetFitToContent(true);
        messagesPath.SetChildMargin(new inkMargin(0.0, 20.0, 0.0, 20.0));
        messagesPath.Reparent(pathContainer);

        let messagesLine = new inkRectangle();
        messagesLine.SetName(n"line");
        messagesLine.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        messagesLine.SetMargin(new inkMargin(-20.0, 0.0, -20.0, 0.0));
        messagesLine.SetSize(new Vector2(0.0, 7.0));
        messagesLine.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        messagesLine.BindProperty(n"tintColor", n"MainColors.Blue");
        messagesLine.Reparent(pathContainer);

        let messagesFluff = new inkImage();
        messagesFluff.SetName(n"fluff");
        messagesFluff.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas");
        messagesFluff.SetTexturePart(n"ico_envelelope");
        messagesFluff.SetTileHAlign(inkEHorizontalAlign.Left);
        messagesFluff.SetTileVAlign(inkEVerticalAlign.Top);
        messagesFluff.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        messagesFluff.SetHAlign(inkEHorizontalAlign.Center);
        messagesFluff.SetVAlign(inkEVerticalAlign.Center);
        messagesFluff.SetSize(new Vector2(48.0, 48.0));
        messagesFluff.SetFitToContent(true);
        messagesFluff.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        messagesFluff.BindProperty(n"tintColor", n"MainColors.Blue");
        messagesFluff.BindProperty(n"opacity", n"MenuLabel.MainOpacity");
        messagesFluff.Reparent(messagesPath);

        let messagesPathText = new inkText();
        messagesPathText.SetName(n"txtValue");
        messagesPathText.SetText("Messages");
        messagesPathText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        messagesPathText.SetFontStyle(n"Medium");
        messagesPathText.SetFontSize(50);
        messagesPathText.SetLetterCase(textLetterCase.UpperCase);
        messagesPathText.SetVerticalAlignment(textVerticalAlignment.Center);
        messagesPathText.SetContentHAlign(inkEHorizontalAlign.Center);
        messagesPathText.SetContentVAlign(inkEVerticalAlign.Center);
        messagesPathText.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        messagesPathText.SetHAlign(inkEHorizontalAlign.Left);
        messagesPathText.SetVAlign(inkEVerticalAlign.Center);
        messagesPathText.SetAnchor(inkEAnchor.Centered);
        messagesPathText.SetAnchorPoint(new Vector2(0.5, 0.5));
        messagesPathText.SetMargin(new inkMargin(10.0, 0.0, 0.0, 0.0));
        messagesPathText.SetFitToContent(true);
        messagesPathText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        messagesPathText.BindProperty(n"tintColor", n"MainColors.Blue");
        messagesPathText.BindProperty(n"fontSize", n"MainColors.ReadableFontSize");
        messagesPathText.BindProperty(n"opacity", n"MenuLabel.MainOpacity");
        messagesPathText.Reparent(messagesPath);

        let arrowIcon = new inkImage();
        arrowIcon.SetName(n"arrow");
        arrowIcon.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\hud_johnny\\notification_assets.inkatlas");
        arrowIcon.SetTexturePart(n"+1");
        arrowIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        arrowIcon.SetTileVAlign(inkEVerticalAlign.Top);
        arrowIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        arrowIcon.SetHAlign(inkEHorizontalAlign.Center);
        arrowIcon.SetVAlign(inkEVerticalAlign.Center);
        arrowIcon.SetMargin(new inkMargin(0.0, -20.0, 0.0, 0.0));
        arrowIcon.SetSize(new Vector2(20.0, 20.0));
        arrowIcon.SetFitToContent(true);
        arrowIcon.SetRotation(90);
        arrowIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        arrowIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        arrowIcon.Reparent(horizontalPanelWidget5);

        let nameHolder = new inkFlex();
        nameHolder.SetName(n"name_holder");
        nameHolder.SetMargin(new inkMargin(20.0, 0.0, 0.0, 0.0));
        nameHolder.SetSize(new Vector2(100.0, 100.0));
        nameHolder.Reparent(horizontalPanelWidget5);

        let nameLine = new inkRectangle();
        nameLine.SetName(n"line");
        nameLine.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        nameLine.SetVAlign(inkEVerticalAlign.Bottom);
        nameLine.SetMargin(new inkMargin(-20.0, 0.0, -20.0, 0.0));
        nameLine.SetSize(new Vector2(300.0, 7.0));
        nameLine.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        nameLine.BindProperty(n"tintColor", n"MainColors.Blue");
        nameLine.Reparent(nameHolder);

        let nameText = new inkText();
        nameText.SetName(n"contact_name");
        nameText.SetText(GetCharacterLocalizedName(this.character));
        nameText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        nameText.SetFontStyle(n"Medium");
        nameText.SetFontSize(50);
        nameText.SetLetterCase(textLetterCase.UpperCase);
        nameText.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        nameText.SetHorizontalAlignment(textHorizontalAlignment.Center);
        nameText.SetVerticalAlignment(textVerticalAlignment.Center);
        nameText.SetContentHAlign(inkEHorizontalAlign.Left);
        nameText.SetOverflowPolicy(textOverflowPolicy.AutoScroll);
        nameText.SetWrappingAtPosition(700);
        nameText.SetHAlign(inkEHorizontalAlign.Left);
        nameText.SetVAlign(inkEVerticalAlign.Center);
        nameText.SetMargin(new inkMargin(0.0, -12.0, 0.0, 0.0));
        nameText.SetSizeRule(inkESizeRule.Stretch);
        nameText.SetSize(new Vector2(900.0, 63.0));
        nameText.SetFitToContent(true);
        nameText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        nameText.BindProperty(n"tintColor", n"MainColors.Blue");
        nameText.Reparent(nameHolder);

        let rectangleRight = new inkRectangle();
        rectangleRight.SetName(n"right");
        rectangleRight.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        rectangleRight.SetVAlign(inkEVerticalAlign.Center);
        rectangleRight.SetMargin(new inkMargin(30.0, 92.0, 270.0, 0.0));
        rectangleRight.SetSizeRule(inkESizeRule.Stretch);
        rectangleRight.SetSize(new Vector2(0.0, 2.0));
        rectangleRight.SetRenderTransformPivot(new Vector2(1, 0.5));
        rectangleRight.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        rectangleRight.BindProperty(n"tintColor", n"MainColors.PanelRed");
        rectangleRight.Reparent(horizontalPanelWidget5);

        let fluffNameL = new inkText();
        fluffNameL.SetName(n"fluff_name-l");
        fluffNameL.SetText("TRN_TCLAS_800095");
        fluffNameL.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        fluffNameL.SetFontStyle(n"Medium");
        fluffNameL.SetFontSize(20);
        fluffNameL.SetLetterCase(textLetterCase.UpperCase);
        fluffNameL.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        fluffNameL.SetAnchor(inkEAnchor.TopRight);
        fluffNameL.SetHAlign(inkEHorizontalAlign.Left);
        fluffNameL.SetVAlign(inkEVerticalAlign.Top);
        fluffNameL.SetMargin(new inkMargin(0.0, -20.0, 0.0, 0.0));
        fluffNameL.SetSize(new Vector2(100.0, 32.0));
        fluffNameL.SetFitToContent(true);
        fluffNameL.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        fluffNameL.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
        fluffNameL.BindProperty(n"tintColor", n"MainColors.Red");
        fluffNameL.Reparent(topHolder);

        let fluffNameR = new inkText();
        fluffNameR.SetName(n"fluff_name-r");
        fluffNameR.SetText("VER_M6A6T6I");
        fluffNameR.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        fluffNameR.SetFontStyle(n"Medium");
        fluffNameR.SetFontSize(20);
        fluffNameR.SetLetterCase(textLetterCase.UpperCase);
        fluffNameR.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        fluffNameR.SetAnchor(inkEAnchor.TopRight);
        fluffNameR.SetHAlign(inkEHorizontalAlign.Right);
        fluffNameR.SetVAlign(inkEVerticalAlign.Bottom);
        fluffNameR.SetMargin(new inkMargin(0.0, 0.0, 269.00, 10.00));
        fluffNameR.SetRenderTransformPivot(new Vector2(1, 0.5));
        fluffNameR.SetSize(new Vector2(100.0, 32.0));
        fluffNameR.SetFitToContent(true);
        fluffNameR.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        fluffNameR.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
        fluffNameR.BindProperty(n"tintColor", n"MainColors.Red");
        fluffNameR.Reparent(topHolder);

        // Widgets under Root/wrapper
        let rootWrapper = new inkVerticalPanel();
        rootWrapper.SetName(n"wrapper");
        rootWrapper.SetMargin(new inkMargin(100.0, 50.0, 0.0, 0.0));
        rootWrapper.SetFitToContent(true);
        rootWrapper.Reparent(modMessengerSlotRoot);

        let wrapperContent = new inkFlex();
        wrapperContent.SetName(n"content");
        wrapperContent.SetAnchor(inkEAnchor.BottomLeft);
        wrapperContent.SetHAlign(inkEHorizontalAlign.Left);
        wrapperContent.SetVAlign(inkEVerticalAlign.Top);
        wrapperContent.SetMargin(new inkMargin(120.0, 0.0, 0.0, 0.0));
        wrapperContent.SetSizeRule(inkESizeRule.Stretch);
        wrapperContent.SetSize(new Vector2(100.0, 100.0));
        wrapperContent.SetAffectsLayoutWhenHidden(true);
        wrapperContent.Reparent(rootWrapper);

        let innerWrapper = new inkVerticalPanel();
        innerWrapper.SetName(n"wrapper");
        innerWrapper.SetMargin(new inkMargin(0.0, 0.0, 24.0, 0.0));
        innerWrapper.SetFitToContent(false);
        innerWrapper.Reparent(wrapperContent);

        let conversation = new inkCanvas();
        conversation.SetName(n"Conversation");
        conversation.SetSizeRule(inkESizeRule.Stretch);
        conversation.SetSize(new Vector2(1300.0, 1400.0));
        conversation.SetAffectsLayoutWhenHidden(true);
        conversation.SetChildOrder(inkEChildOrder.Backward);
        conversation.SetInteractive(true);
        conversation.Reparent(innerWrapper);

        let messageScrollArea = new inkScrollArea();
        messageScrollArea.SetName(n"MessagesScrollArea");
        messageScrollArea.SetMargin(new inkMargin(20.0, 0.0, 35.0, 0.0));
        messageScrollArea.SetAnchor(inkEAnchor.Fill);
        messageScrollArea.SetUseInternalMask(false);
        messageScrollArea.SetSize(new Vector2(600.0, 600.0));
        messageScrollArea.Reparent(conversation);

        let scrollAreaWrapper = new inkFlex();
        scrollAreaWrapper.SetName(n"wrapper");
        scrollAreaWrapper.SetSize(new Vector2(100.0, 100.0));
        scrollAreaWrapper.Reparent(messageScrollArea);

        let scrollAreaContainer = new inkVerticalPanel();
        scrollAreaContainer.SetName(n"container");
        scrollAreaContainer.SetHAlign(inkEHorizontalAlign.Left);
        scrollAreaContainer.SetVAlign(inkEVerticalAlign.Top);
        scrollAreaContainer.SetFitToContent(true);
        scrollAreaContainer.Reparent(scrollAreaWrapper);

        let messagesList = new inkVerticalPanel();
        messagesList.SetName(n"MessagesList");
        messagesList.SetHAlign(inkEHorizontalAlign.Left);
        messagesList.SetVAlign(inkEVerticalAlign.Top);
        messagesList.SetFitToContent(true);
        messagesList.SetMargin(new inkMargin(0.0, 40.0, 0.0, 40.0));
        messagesList.SetChildMargin(new inkMargin(0.0, 5.0, 0.0, 0.0));
        messagesList.Reparent(scrollAreaContainer);
        this.messageParent = messagesList;
        
        let typingIndicator = new inkFlex();
        typingIndicator.SetName(n"typing_indicator");
        typingIndicator.SetVAlign(inkEVerticalAlign.Bottom);
        typingIndicator.SetSize(new Vector2(100.0, 100.0));
        typingIndicator.SetVisible(false);
        typingIndicator.Reparent(scrollAreaContainer);
        this.typingIndicator = typingIndicator;

        let indicatorContainer = new inkFlex();
        indicatorContainer.SetName(n"container");
        indicatorContainer.SetVAlign(inkEVerticalAlign.Top);
        indicatorContainer.SetMargin(new inkMargin(0.0, 0.0, 0.0, 25.0));
        indicatorContainer.SetSize(new Vector2(100.0, 100.0));
        indicatorContainer.Reparent(typingIndicator);

        let indicatorContainer2 = new inkVerticalPanel();
        indicatorContainer2.SetName(n"container");
        indicatorContainer2.SetHAlign(inkEHorizontalAlign.Left);
        indicatorContainer2.SetVAlign(inkEVerticalAlign.Top);
        indicatorContainer2.SetFitToContent(true);
        indicatorContainer2.SetStyle(r"base\\gameplay\\gui\\fullscreen\\phone_quest_menu\\messenger.inkstyle");
        indicatorContainer2.Reparent(indicatorContainer);

        let horizontalPanelWidget16 = new inkHorizontalPanel();
        horizontalPanelWidget16.SetName(n"inkHorizontalPanelWidget16");
        horizontalPanelWidget16.SetHAlign(inkEHorizontalAlign.Left);
        horizontalPanelWidget16.SetFitToContent(true);
        horizontalPanelWidget16.SetChildMargin(new inkMargin(0.0, 0.0, 4.0, 0.0));
        horizontalPanelWidget16.Reparent(indicatorContainer2);

        let isTyping = new inkText();
        isTyping.SetName(n"isTyping");
        isTyping.SetText(GetCharacterLocalizedName(this.character) + " is typing");
        isTyping.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        isTyping.SetFontStyle(n"Medium");
        isTyping.SetFontSize(38);
        isTyping.SetLetterCase(textLetterCase.OriginalCase);
        isTyping.SetContentVAlign(inkEVerticalAlign.Top);
        isTyping.SetWrappingAtPosition(800);
        isTyping.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        isTyping.SetHAlign(inkEHorizontalAlign.Left);
        isTyping.SetVAlign(inkEVerticalAlign.Top);
        isTyping.SetSize(new Vector2(0.0, 32.0));
        isTyping.SetFitToContent(true);
        isTyping.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        isTyping.BindProperty(n"tintColor", n"Message.TextColor");
        isTyping.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        isTyping.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
        isTyping.Reparent(horizontalPanelWidget16);

        let dot1 = new inkText();
        dot1.SetName(n"isTyping");
        dot1.SetText(".");
        dot1.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dot1.SetFontStyle(n"Semi-Bold");
        dot1.SetFontSize(38);
        dot1.SetLetterCase(textLetterCase.OriginalCase);
        dot1.SetContentVAlign(inkEVerticalAlign.Top);
        dot1.SetWrappingAtPosition(800);
        dot1.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        dot1.SetHAlign(inkEHorizontalAlign.Left);
        dot1.SetVAlign(inkEVerticalAlign.Top);
        dot1.SetSize(new Vector2(0.0, 32.0));
        dot1.SetFitToContent(true);
        dot1.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        dot1.BindProperty(n"tintColor", n"Message.TextColor");
        dot1.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        dot1.BindProperty(n"fontStyle", n"MainColors.HeaderFontWeight");
        dot1.Reparent(horizontalPanelWidget16);

        let dot2 = new inkText();
        dot2.SetName(n"isTyping");
        dot2.SetText(".");
        dot2.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dot2.SetFontStyle(n"Semi-Bold");
        dot2.SetFontSize(38);
        dot2.SetLetterCase(textLetterCase.OriginalCase);
        dot2.SetContentVAlign(inkEVerticalAlign.Top);
        dot2.SetWrappingAtPosition(800);
        dot2.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        dot2.SetHAlign(inkEHorizontalAlign.Left);
        dot2.SetVAlign(inkEVerticalAlign.Top);
        dot2.SetSize(new Vector2(0.0, 32.0));
        dot2.SetFitToContent(true);
        dot2.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        dot2.BindProperty(n"tintColor", n"Message.TextColor");
        dot2.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        dot2.BindProperty(n"fontStyle", n"MainColors.HeaderFontWeight");
        dot2.Reparent(horizontalPanelWidget16);

        let dot3 = new inkText();
        dot3.SetName(n"isTyping");
        dot3.SetText(".");
        dot3.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dot3.SetFontStyle(n"Semi-Bold");
        dot3.SetFontSize(38);
        dot3.SetLetterCase(textLetterCase.OriginalCase);
        dot3.SetContentVAlign(inkEVerticalAlign.Top);
        dot3.SetWrappingAtPosition(800);
        dot3.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        dot3.SetHAlign(inkEHorizontalAlign.Left);
        dot3.SetVAlign(inkEVerticalAlign.Top);
        dot3.SetSize(new Vector2(0.0, 32.0));
        dot3.SetFitToContent(true);
        dot3.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        dot3.BindProperty(n"tintColor", n"Message.TextColor");
        dot3.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        dot3.BindProperty(n"fontStyle", n"MainColors.HeaderFontWeight");
        dot3.Reparent(horizontalPanelWidget16);

        let conversationMask = new inkMask();
        conversationMask.SetName(n"mask");
        conversationMask.SetDataSource(inkMaskDataSource.TextureAtlas);
        conversationMask.SetTextureAtlas(r"base\\gameplay\\gui\\common\\masks.inkatlas");
        conversationMask.SetTexturePart(n"gradMask_journal_description");
        conversationMask.SetDynamicTexture(n"entry_mask");
        conversationMask.SetOpacity(0.01);
        conversationMask.SetAnchor(inkEAnchor.Fill);
        conversationMask.SetSize(new Vector2(1920.0, 1500.0));
        conversationMask.Reparent(conversation);

        let slider = new inkVerticalPanel();
        slider.SetName(n"Slider");
        slider.SetAnchor(inkEAnchor.RightFillVerticaly);
        slider.SetMargin(new inkMargin(0.0, 0.0, -5.0, 0.0));
        slider.SetSize(new Vector2(8.0, 1125.0));
        slider.Reparent(conversation);

        let slidingArea = new inkCanvas();
        slidingArea.SetName(n"slidingArea");
        slidingArea.SetSize(new Vector2(8.0, 1125.0));
        slidingArea.SetChildOrder(inkEChildOrder.Backward);
        slidingArea.Reparent(slider);

        let handle = new inkRectangle();
        handle.SetName(n"Handle");
        handle.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        handle.SetOpacity(0.3);
        handle.SetAnchor(inkEAnchor.TopFillHorizontaly);
        handle.SetMargin(new inkMargin(0.0, 788.07, 0.0, 0.0));
        handle.SetSize(new Vector2(64.0, 20.0));
        handle.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        handle.BindProperty(n"tintColor", n"MainColors.Red");
        handle.Reparent(slidingArea);

        let sliderBackground = new inkRectangle();
        sliderBackground.SetName(n"Background");
        sliderBackground.SetTintColor(new Color(Cast(14u), Cast(14u), Cast(23u), Cast(255u)));
        sliderBackground.SetOpacity(0.8);
        sliderBackground.SetSize(new Vector2(64.0, 64.0));
        sliderBackground.SetAnchor(inkEAnchor.Fill);
        sliderBackground.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        sliderBackground.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
        sliderBackground.Reparent(slidingArea);

        let sliderController = new inkSliderController();
        sliderController.slidingAreaRef = inkWidgetRef.Create(slidingArea);
        sliderController.handleRef = inkWidgetRef.Create(handle);
        sliderController.direction = inkESliderDirection.Vertical;
        sliderController.autoSizeHandle = true;
        sliderController.percentHandleSize = 0.4;
        sliderController.minHandleSize = 40.0;
        sliderController.Setup(0, 1, 0, 0);

        let scrollController = new inkScrollController();
        scrollController.ScrollArea = inkScrollAreaRef.Create(messageScrollArea);
        scrollController.VerticalScrollBarRef = inkWidgetRef.Create(slidingArea);
        scrollController.autoHideVertical = true;

        slidingArea.AttachController(sliderController);
        conversation.AttachController(scrollController);
        this.chatScrollController = scrollController;

        let contentFill = new inkImage();
        contentFill.SetName(n"contentFill");
        contentFill.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        contentFill.SetTexturePart(n"item_bg");
        contentFill.SetNineSliceScale(true);
        contentFill.SetTileHAlign(inkEHorizontalAlign.Left);
        contentFill.SetTileVAlign(inkEVerticalAlign.Top);
        contentFill.SetTintColor(new Color(Cast(20u), Cast(20u), Cast(20u), Cast(255u)));
        contentFill.SetOpacity(0.2);
        contentFill.SetAnchor(inkEAnchor.Fill);
        contentFill.SetAnchorPoint(new Vector2(0.5, 0.5));
        contentFill.SetSize(new Vector2(500.0, 500.0));
        contentFill.SetFitToContent(true);
        contentFill.SetAffectsLayoutWhenHidden(true);
        contentFill.Reparent(conversation);

        let contentBorder = new inkImage();
        contentBorder.SetName(n"contentBorder");
        contentBorder.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        contentBorder.SetTexturePart(n"item_fg");
        contentBorder.SetNineSliceScale(true);
        contentBorder.SetTileHAlign(inkEHorizontalAlign.Left);
        contentBorder.SetTileVAlign(inkEVerticalAlign.Top);
        contentBorder.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        contentBorder.SetOpacity(0.007);
        contentBorder.SetAnchor(inkEAnchor.Fill);
        contentBorder.SetAnchorPoint(new Vector2(0.5, 0.5));
        contentBorder.SetSize(new Vector2(500.0, 500.0));
        contentBorder.SetFitToContent(true);
        contentBorder.SetAffectsLayoutWhenHidden(true);
        contentBorder.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        contentBorder.BindProperty(n"tintColor", n"MainColors.Red");
        contentBorder.Reparent(conversation);

        let replyOptions = new inkVerticalPanel();
        replyOptions.SetName(n"ReplyOptions");
        replyOptions.SetAnchor(inkEAnchor.BottomLeft);
        replyOptions.SetMargin(new inkMargin(0.0, 10.0, 0.0, 10.0));
        replyOptions.SetSizeCoefficient(0.5);
        replyOptions.SetFitToContent(true);
        replyOptions.Reparent(innerWrapper);

        let choicesList = new inkVerticalPanel();
        choicesList.SetName(n"ChoicesList");
        choicesList.SetHAlign(inkEHorizontalAlign.Right);
        choicesList.SetVAlign(inkEVerticalAlign.Top);
        choicesList.SetFitToContent(true);
        choicesList.SetChildMargin(new inkMargin(0.0, 10.0, 0.0, 0.0));
        choicesList.Reparent(replyOptions);

        let choice1 = new inkHorizontalPanel();
        choice1.SetName(n"item");
        choice1.SetFitToContent(true);
        choice1.SetStyle(r"base\\gameplay\\gui\\fullscreen\\phone_quest_menu\\messenger.inkstyle");
        choice1.SetState(n"QuestSelected");
        choice1.SetChildMargin(new inkMargin(0.0, 0.0, 0.0, 7.0));
        choice1.Reparent(choicesList);

        let flexWidget20 = new inkFlex();
        flexWidget20.SetName(n"inkFlexWidget20");
        flexWidget20.SetHAlign(inkEHorizontalAlign.Right);
        flexWidget20.SetVAlign(inkEVerticalAlign.Top);
        flexWidget20.SetMargin(new inkMargin(10.0, 0.0, 0.0, 0.0));
        flexWidget20.SetSizeRule(inkESizeRule.Stretch);
        flexWidget20.SetFitToContent(true);
        flexWidget20.Reparent(choice1);

        let textFlex = new inkFlex();
        textFlex.SetName(n"textFlex");
        textFlex.SetHAlign(inkEHorizontalAlign.Right);
        textFlex.SetVAlign(inkEVerticalAlign.Top);
        textFlex.SetSize(new Vector2(100.0, 100.0));
        textFlex.Reparent(flexWidget20);

        let textBackground = new inkImage();
        textBackground.SetName(n"background");
        textBackground.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\phone\\new_phone_assets.inkatlas");
        textBackground.SetTexturePart(n"msgBuble_reply_bg");
        textBackground.SetNineSliceScale(true);
        textBackground.SetTileHAlign(inkEHorizontalAlign.Left);
        textBackground.SetTileVAlign(inkEVerticalAlign.Top);
        textBackground.SetTintColor(new Color(Cast(161u), Cast(126u), Cast(51u), Cast(255u)));
        textBackground.SetOpacity(0.15);
        textBackground.SetSize(new Vector2(32.0, 32.0));
        textBackground.SetFitToContent(true);
        textBackground.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        textBackground.BindProperty(n"tintColor", n"MessageReply.BackgroundColor");
        textBackground.BindProperty(n"opacity", n"MessageReply.BackgroundOpacity");
        textBackground.Reparent(textFlex);

        let activeTextWrapper = new inkHorizontalPanel();
        activeTextWrapper.SetName(n"active_text_wrapper");
        activeTextWrapper.SetHAlign(inkEHorizontalAlign.Right);
        activeTextWrapper.SetVAlign(inkEVerticalAlign.Center);
        activeTextWrapper.SetFitToContent(true);
        activeTextWrapper.Reparent(textFlex);
        this.typedMessageWrapper = activeTextWrapper;

        let captionImage = new inkHorizontalPanel();
        captionImage.SetName(n"captionImageHorz_primary");
        captionImage.SetHAlign(inkEHorizontalAlign.Right);
        captionImage.SetVAlign(inkEVerticalAlign.Center);
        captionImage.SetMargin(new inkMargin(20.0, 0.0, 0.0, 0.0));
        captionImage.SetFitToContent(true);
        captionImage.SetChildMargin(new inkMargin(0.0, 0.0, 5.0, 0.0));
        captionImage.Reparent(activeTextWrapper);

        let activeItemText = new inkText();
        activeItemText.SetName(n"activeItemText");
        activeItemText.SetText("Send a message.");
        activeItemText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        activeItemText.SetFontStyle(n"Medium");
        activeItemText.SetFontSize(42);
        activeItemText.SetLetterCase(textLetterCase.OriginalCase);
        activeItemText.SetOverflowPolicy(textOverflowPolicy.DotsEnd);
        activeItemText.SetWrappingAtPosition(1000);
        activeItemText.SetTintColor(new Color(Cast(255u), Cast(255u), Cast(78u), Cast(255u)));
        activeItemText.SetHAlign(inkEHorizontalAlign.Left);
        activeItemText.SetVAlign(inkEVerticalAlign.Center);
        activeItemText.SetMargin(new inkMargin(17.0, 17.0, 30.0, 30.0));
        activeItemText.SetSize(new Vector2(750.0, 63.0));
        activeItemText.SetFitToContent(true);
        activeItemText.SetTranslation(new Vector2(0.50, 0.50));
        activeItemText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        activeItemText.BindProperty(n"fontSize", n"MainColors.ReadableMedium");
        activeItemText.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
        activeItemText.BindProperty(n"tintColor", n"MessageReply.TextColor");
        activeItemText.BindProperty(n"opacity", n"MessageReply.TextOpacity");
        activeItemText.Reparent(activeTextWrapper);
        this.typedMessageText = activeItemText;

        let textBorder = new inkImage();
        textBorder.SetName(n"border");
        textBorder.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\phone\\new_phone_assets.inkatlas");
        textBorder.SetTexturePart(n"msgBuble_reply_fg");
        textBorder.SetNineSliceScale(true);
        textBorder.SetTileHAlign(inkEHorizontalAlign.Left);
        textBorder.SetTileVAlign(inkEVerticalAlign.Top);
        textBorder.SetTintColor(new Color(Cast(161u), Cast(126u), Cast(51u), Cast(255u)));
        textBorder.SetSize(new Vector2(32.0, 32.0));
        textBorder.SetFitToContent(true);
        textBorder.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        textBorder.BindProperty(n"tintColor", n"MessageReply.BorderColor");
        textBorder.BindProperty(n"opacity", n"MessageReply.BorderOpacity");
        textBorder.Reparent(textFlex);

        let sqQuestCanvas = new inkCanvas();
        sqQuestCanvas.SetName(n"SQ_quest_canvas");
        sqQuestCanvas.SetVAlign(inkEVerticalAlign.Bottom);
        sqQuestCanvas.SetMargin(new inkMargin(10.0, 0.0, 0.0, 0.0));
        sqQuestCanvas.SetSize(new Vector2(43.0, 43.0));
        sqQuestCanvas.SetAffectsLayoutWhenHidden(true);
        sqQuestCanvas.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        sqQuestCanvas.BindProperty(n"opacity", n"MessageReply.SelectionBulletOpacity");
        sqQuestCanvas.SetChildOrder(inkEChildOrder.Backward);
        sqQuestCanvas.Reparent(choice1);

        let hintReply = new inkHorizontalPanel();
        hintReply.SetName(n"hint_reply");
        hintReply.SetAnchor(inkEAnchor.CenterRight);
        hintReply.SetAnchorPoint(new Vector2(1, 1));
        hintReply.SetHAlign(inkEHorizontalAlign.Left);
        hintReply.SetVAlign(inkEVerticalAlign.Top);
        hintReply.SetMargin(new inkMargin(0.0, 0.0, -36.0, 0.0));
        hintReply.SetFitToContent(true);
        hintReply.SetChildMargin(new inkMargin(0.0, 0.0, 10.0, 0.0));
        hintReply.Reparent(sqQuestCanvas);

        let hintReplyIcon = new inkImage();
        hintReplyIcon.SetName(n"inputIcon");
        hintReplyIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintReplyIcon.SetTexturePart(n"mouse_left");
        hintReplyIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintReplyIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintReplyIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintReplyIcon.SetAnchor(inkEAnchor.Centered);
        hintReplyIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintReplyIcon.SetVAlign(inkEVerticalAlign.Center);
        hintReplyIcon.SetSize(new Vector2(64.0, 64.0));
        hintReplyIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintReplyIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintReplyIcon.Reparent(hintReply);
        this.chatInputHint = hintReplyIcon;

        let contentSizeProvider = new inkCanvas();
        contentSizeProvider.SetName(n"sizeProvider");
        contentSizeProvider.SetHAlign(inkEHorizontalAlign.Left);
        contentSizeProvider.SetVAlign(inkEVerticalAlign.Top);
        contentSizeProvider.SetMargin(new inkMargin(24.0, 0.0, 24.0, 0.0));
        contentSizeProvider.SetSize(new Vector2(1250.0, 1250.0));
        contentSizeProvider.SetChildOrder(inkEChildOrder.Backward);
        contentSizeProvider.Reparent(wrapperContent);

        let hrUnderContent = new inkRectangle();
        hrUnderContent.SetName(n"hrUnderContent");
        hrUnderContent.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        hrUnderContent.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        hrUnderContent.SetVAlign(inkEVerticalAlign.Bottom);
        hrUnderContent.SetOpacity(0.2);
        hrUnderContent.SetMargin(new inkMargin(120.0, 10.0, 20.0, 0.0));
        hrUnderContent.SetSize(new Vector2(0.0, 2.0));
        hrUnderContent.SetRenderTransformPivot(new Vector2(0, 0.5));
        hrUnderContent.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hrUnderContent.BindProperty(n"tintColor", n"MainColors.Red");
        hrUnderContent.Reparent(rootWrapper);

        let wrapperInputHints = new inkHorizontalPanel();
        wrapperInputHints.SetName(n"inputHints");
        wrapperInputHints.SetHAlign(inkEHorizontalAlign.Right);
        wrapperInputHints.SetVAlign(inkEVerticalAlign.Top);
        wrapperInputHints.SetFitToContent(true);
        wrapperInputHints.SetTranslation(new Vector2(0.0, 25.0));
        wrapperInputHints.SetChildMargin(new inkMargin(30.0, 0.0, 0.0, 0.0));
        wrapperInputHints.Reparent(rootWrapper);

        let hintUndo = new inkHorizontalPanel();
        hintUndo.SetName(n"hint_undo");
        hintUndo.SetAnchor(inkEAnchor.TopRight);
        hintUndo.SetAnchorPoint(new Vector2(1, 0));
        hintUndo.SetHAlign(inkEHorizontalAlign.Left);
        hintUndo.SetVAlign(inkEVerticalAlign.Top);
        hintUndo.SetFitToContent(true);
        hintUndo.Reparent(wrapperInputHints);

        let hintUndoIcon = new inkImage();
        hintUndoIcon.SetName(n"inputIcon");
        hintUndoIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintUndoIcon.SetTexturePart(n"kb_z");
        hintUndoIcon.SetSize(new Vector2(64.0, 64.0));
        hintUndoIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintUndoIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintUndoIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintUndoIcon.SetAnchor(inkEAnchor.Centered);
        hintUndoIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintUndoIcon.SetVAlign(inkEVerticalAlign.Center);
        hintUndoIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintUndoIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintUndoIcon.Reparent(hintUndo);

        let hintUndoText = new inkText();
        hintUndoText.SetName(n"action");
        hintUndoText.SetText("Undo");
        hintUndoText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        hintUndoText.SetFontStyle(n"Semi-Bold");
        hintUndoText.SetFontSize(38);
        hintUndoText.SetLetterCase(textLetterCase.UpperCase);
        hintUndoText.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        hintUndoText.SetAnchor(inkEAnchor.TopRight);
        hintUndoText.SetAnchorPoint(new Vector2(1, 0));
        hintUndoText.SetVAlign(inkEVerticalAlign.Center);
        hintUndoText.SetMargin(new inkMargin(7.5, 5.0, 5.0, 0.0));
        hintUndoText.SetSize(new Vector2(100.0, 32.0));
        hintUndoText.SetFitToContent(true);
        hintUndoText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintUndoText.BindProperty(n"fontStyle", n"MainColors.ReadableSmall");
        hintUndoText.BindProperty(n"tintColor", n"MainColors.Red");
        hintUndoText.Reparent(hintUndo);

        let hintReset = new inkHorizontalPanel();
        hintReset.SetName(n"hint_reset");
        hintReset.SetAnchor(inkEAnchor.TopRight);
        hintReset.SetAnchorPoint(new Vector2(1, 0));
        hintReset.SetHAlign(inkEHorizontalAlign.Left);
        hintReset.SetVAlign(inkEVerticalAlign.Top);
        hintReset.SetFitToContent(true);
        hintReset.Reparent(wrapperInputHints);

        let hintResetIcon = new inkImage();
        hintResetIcon.SetName(n"inputIcon");
        hintResetIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintResetIcon.SetTexturePart(n"kb_r");
        hintResetIcon.SetSize(new Vector2(64.0, 64.0));
        hintResetIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintResetIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintResetIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintResetIcon.SetAnchor(inkEAnchor.Centered);
        hintResetIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintResetIcon.SetVAlign(inkEVerticalAlign.Center);
        hintResetIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintResetIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintResetIcon.Reparent(hintReset);

        let hintResetText = new inkText();
        hintResetText.SetName(n"action");
        hintResetText.SetText("Reset");
        hintResetText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        hintResetText.SetFontStyle(n"Semi-Bold");
        hintResetText.SetFontSize(38);
        hintResetText.SetLetterCase(textLetterCase.UpperCase);
        hintResetText.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        hintResetText.SetAnchor(inkEAnchor.TopRight);
        hintResetText.SetAnchorPoint(new Vector2(1, 0));
        hintResetText.SetVAlign(inkEVerticalAlign.Center);
        hintResetText.SetMargin(new inkMargin(7.5, 5.0, 5.0, 0.0));
        hintResetText.SetSize(new Vector2(100.0, 32.0));
        hintResetText.SetFitToContent(true);
        hintResetText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintResetText.BindProperty(n"fontStyle", n"MainColors.ReadableSmall");
        hintResetText.BindProperty(n"tintColor", n"MainColors.Red");
        hintResetText.Reparent(hintReset);

        let hintClose = new inkHorizontalPanel();
        hintClose.SetName(n"hint_close");
        hintClose.SetAnchor(inkEAnchor.TopRight);
        hintClose.SetAnchorPoint(new Vector2(1, 0));
        hintClose.SetHAlign(inkEHorizontalAlign.Left);
        hintClose.SetVAlign(inkEVerticalAlign.Top);
        hintClose.SetFitToContent(true);
        hintClose.Reparent(wrapperInputHints);

        let hintCloseIcon = new inkImage();
        hintCloseIcon.SetName(n"inputIcon");
        hintCloseIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintCloseIcon.SetTexturePart(n"kb_c");
        hintCloseIcon.SetSize(new Vector2(64.0, 64.0));
        hintCloseIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintCloseIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintCloseIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintCloseIcon.SetAnchor(inkEAnchor.Centered);
        hintCloseIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintCloseIcon.SetVAlign(inkEVerticalAlign.Center);
        hintCloseIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintCloseIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintCloseIcon.Reparent(hintClose);

        let hintCloseText = new inkText();
        hintCloseText.SetName(n"action");
        hintCloseText.SetText("Close");
        hintCloseText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        hintCloseText.SetFontStyle(n"Semi-Bold");
        hintCloseText.SetFontSize(38);
        hintCloseText.SetLetterCase(textLetterCase.UpperCase);
        hintCloseText.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        hintCloseText.SetAnchor(inkEAnchor.TopRight);
        hintCloseText.SetAnchorPoint(new Vector2(1, 0));
        hintCloseText.SetVAlign(inkEVerticalAlign.Center);
        hintCloseText.SetMargin(new inkMargin(7.5, 5.0, 5.0, 0.0));
        hintCloseText.SetSize(new Vector2(100.0, 32.0));
        hintCloseText.SetFitToContent(true);
        hintCloseText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintCloseText.BindProperty(n"fontStyle", n"MainColors.ReadableSmall");
        hintCloseText.BindProperty(n"tintColor", n"MainColors.Red");
        hintCloseText.Reparent(hintClose);

        let hintLiveMode = new inkHorizontalPanel();
        hintLiveMode.SetName(n"hint_livemode");
        hintLiveMode.SetAnchor(inkEAnchor.TopRight);
        hintLiveMode.SetAnchorPoint(new Vector2(1, 0));
        hintLiveMode.SetHAlign(inkEHorizontalAlign.Left);
        hintLiveMode.SetVAlign(inkEVerticalAlign.Top);
        hintLiveMode.SetFitToContent(true);
        hintLiveMode.Reparent(wrapperInputHints);

        let hintLiveModeIcon = new inkImage();
        hintLiveModeIcon.SetName(n"inputIcon");
        hintLiveModeIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintLiveModeIcon.SetTexturePart(n"kb_l");
        hintLiveModeIcon.SetSize(new Vector2(64.0, 64.0));
        hintLiveModeIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintLiveModeIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintLiveModeIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintLiveModeIcon.SetAnchor(inkEAnchor.Centered);
        hintLiveModeIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintLiveModeIcon.SetVAlign(inkEVerticalAlign.Center);
        hintLiveModeIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintLiveModeIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintLiveModeIcon.Reparent(hintLiveMode);

        let hintLiveModeText = new inkText();
        hintLiveModeText.SetName(n"action");
        hintLiveModeText.SetText("TEXT MODE");
        hintLiveModeText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        hintLiveModeText.SetFontStyle(n"Semi-Bold");
        hintLiveModeText.SetFontSize(38);
        hintLiveModeText.SetLetterCase(textLetterCase.UpperCase);
        hintLiveModeText.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintLiveModeText.SetAnchor(inkEAnchor.TopRight);
        hintLiveModeText.SetAnchorPoint(new Vector2(1, 0));
        hintLiveModeText.SetVAlign(inkEVerticalAlign.Center);
        hintLiveModeText.SetMargin(new inkMargin(7.5, 5.0, 5.0, 0.0));
        hintLiveModeText.SetSize(new Vector2(100.0, 32.0));
        hintLiveModeText.SetFitToContent(true);
        hintLiveModeText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintLiveModeText.BindProperty(n"fontStyle", n"MainColors.ReadableSmall");
        hintLiveModeText.Reparent(hintLiveMode);
        this.liveModeHintText = hintLiveModeText;

        // Store reference for mode icon (add after the message icon)
        let liveModeIndicator = new inkImage();
        liveModeIndicator.SetName(n"mode_indicator");
        liveModeIndicator.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas");
        liveModeIndicator.SetTexturePart(n"ico_envelelope_reply1");
        liveModeIndicator.SetTileHAlign(inkEHorizontalAlign.Left);
        liveModeIndicator.SetTileVAlign(inkEVerticalAlign.Top);
        liveModeIndicator.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        liveModeIndicator.SetHAlign(inkEHorizontalAlign.Center);
        liveModeIndicator.SetVAlign(inkEVerticalAlign.Center);
        liveModeIndicator.SetMargin(new inkMargin(15.0, 0.0, 0.0, 0.0));
        liveModeIndicator.SetSize(new Vector2(48.0, 48.0));
        liveModeIndicator.SetFitToContent(true);
        liveModeIndicator.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        liveModeIndicator.BindProperty(n"tintColor", n"MainColors.Blue");
        liveModeIndicator.BindProperty(n"opacity", n"MenuLabel.MainOpacity");
        liveModeIndicator.Reparent(messagesPath);
        this.liveModeHintIcon = liveModeIndicator;

        let translateAnimRoot = new inkAnimTranslation();
        translateAnimRoot.SetStartTranslation(new Vector2(250.0, 0.0));
        translateAnimRoot.SetEndTranslation(new Vector2(0, 0));
        translateAnimRoot.SetType(inkanimInterpolationType.Linear);
        translateAnimRoot.SetMode(inkanimInterpolationMode.EasyOut);
        translateAnimRoot.SetDuration(0.1);

        let alphaAnim = new inkAnimTransparency();
        alphaAnim.SetStartTransparency(0.0);
        alphaAnim.SetEndTransparency(1.0);
        alphaAnim.SetType(inkanimInterpolationType.Linear);
        alphaAnim.SetMode(inkanimInterpolationMode.EasyOut);
        alphaAnim.SetDuration(0.1);

        let animDefRoot = new inkAnimDef();
        animDefRoot.AddInterpolator(translateAnimRoot);
        animDefRoot.AddInterpolator(alphaAnim);

        let hintAIContact = new inkHorizontalPanel();
        hintAIContact.SetName(n"hint_aicontact");
        hintAIContact.SetAnchor(inkEAnchor.TopRight);
        hintAIContact.SetAnchorPoint(new Vector2(1, 0));
        hintAIContact.SetHAlign(inkEHorizontalAlign.Left);
        hintAIContact.SetVAlign(inkEVerticalAlign.Top);
        hintAIContact.SetFitToContent(true);
        hintAIContact.Reparent(wrapperInputHints);

        let hintAIContactIcon = new inkImage();
        hintAIContactIcon.SetName(n"inputIcon");
        hintAIContactIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintAIContactIcon.SetTexturePart(n"kb_o");
        hintAIContactIcon.SetSize(new Vector2(64.0, 64.0));
        hintAIContactIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintAIContactIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintAIContactIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintAIContactIcon.SetAnchor(inkEAnchor.Centered);
        hintAIContactIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintAIContactIcon.SetVAlign(inkEVerticalAlign.Center);
        hintAIContactIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintAIContactIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintAIContactIcon.Reparent(hintAIContact);

        let hintAIContactText = new inkText();
        hintAIContactText.SetName(n"action");
        hintAIContactText.SetText("AI Reach Out");
        hintAIContactText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        hintAIContactText.SetFontStyle(n"Semi-Bold");
        hintAIContactText.SetFontSize(38);
        hintAIContactText.SetLetterCase(textLetterCase.UpperCase);
        hintAIContactText.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        hintAIContactText.SetAnchor(inkEAnchor.TopRight);
        hintAIContactText.SetAnchorPoint(new Vector2(1, 0));
        hintAIContactText.SetVAlign(inkEVerticalAlign.Center);
        hintAIContactText.SetMargin(new inkMargin(7.5, 5.0, 5.0, 0.0));
        hintAIContactText.SetSize(new Vector2(100.0, 32.0));
        hintAIContactText.SetFitToContent(true);
        hintAIContactText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintAIContactText.BindProperty(n"fontStyle", n"MainColors.ReadableSmall");
        hintAIContactText.BindProperty(n"tintColor", n"MainColors.Red");
        hintAIContactText.Reparent(hintAIContact);

        let hintMemory = new inkHorizontalPanel();
        hintMemory.SetName(n"hint_memory");
        hintMemory.SetAnchor(inkEAnchor.TopRight);
        hintMemory.SetAnchorPoint(new Vector2(1, 0));
        hintMemory.SetHAlign(inkEHorizontalAlign.Left);
        hintMemory.SetVAlign(inkEVerticalAlign.Top);
        hintMemory.SetFitToContent(true);
        hintMemory.Reparent(wrapperInputHints);

        let hintMemoryIcon = new inkImage();
        hintMemoryIcon.SetName(n"inputIcon");
        hintMemoryIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas");
        hintMemoryIcon.SetTexturePart(n"kb_1");
        hintMemoryIcon.SetSize(new Vector2(64.0, 64.0));
        hintMemoryIcon.SetTileHAlign(inkEHorizontalAlign.Left);
        hintMemoryIcon.SetTileVAlign(inkEVerticalAlign.Top);
        hintMemoryIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
        hintMemoryIcon.SetAnchor(inkEAnchor.Centered);
        hintMemoryIcon.SetHAlign(inkEHorizontalAlign.Center);
        hintMemoryIcon.SetVAlign(inkEVerticalAlign.Center);
        hintMemoryIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintMemoryIcon.BindProperty(n"tintColor", n"MainColors.Blue");
        hintMemoryIcon.Reparent(hintMemory);
        this.hintMemoryIcon = hintMemoryIcon;

     

        let hintMemoryText = new inkText();
        hintMemoryText.SetName(n"action");
        hintMemoryText.SetText("Save Memory");
        hintMemoryText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        hintMemoryText.SetFontStyle(n"Semi-Bold");
        hintMemoryText.SetFontSize(38);
        hintMemoryText.SetLetterCase(textLetterCase.UpperCase);
        hintMemoryText.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        hintMemoryText.SetAnchor(inkEAnchor.TopRight);
        hintMemoryText.SetAnchorPoint(new Vector2(1, 0));
        hintMemoryText.SetVAlign(inkEVerticalAlign.Center);
        hintMemoryText.SetMargin(new inkMargin(7.5, 5.0, 5.0, 0.0));
        hintMemoryText.SetSize(new Vector2(100.0, 32.0));
        hintMemoryText.SetFitToContent(true);
        hintMemoryText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        hintMemoryText.BindProperty(n"fontStyle", n"MainColors.ReadableSmall");
        hintMemoryText.BindProperty(n"tintColor", n"MainColors.Red");
        hintMemoryText.Reparent(hintMemory);
        this.hintMemoryText = hintMemoryText;

        modMessengerSlotRoot.PlayAnimation(animDefRoot);
    }

    public func RemoveLastPlayerMessage() {
        if !IsDefined(this.messageParent) || this.messageParent.GetNumChildren() == 0 {
            return;
        }
        let lastIndex = this.messageParent.GetNumChildren() - 1;
        this.messageParent.RemoveChild(this.messageParent.GetWidget(lastIndex));
    }

    public func AutoSaveChat() {
        let characterName = this.isGroupChat
        ? GetChatStorage().GetGroupChatFileName(this.groupCharacter1, this.groupCharacter2)
        : GetChatStorage().GetCharacterFileName(this.character);
        let vMessages = GetHttpRequestSystem().vMessages;
        let npcResponses = GetHttpRequestSystem().npcResponses;

        let i = 0;
        while i < ArraySize(vMessages) {
            GetChatStorage().SaveMessage(characterName, true, vMessages[i], false);
            if i < ArraySize(npcResponses) && StrLen(npcResponses[i]) > 0 {
                let msgWasLiveMode = i < ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) ? GetHttpRequestSystem().npcResponsesLiveMode[i] : false;  // ✅ CHANGED THIS LINE
                GetChatStorage().SaveMessage(characterName, false, npcResponses[i], msgWasLiveMode);
            }
            i += 1;
        }
    }

    // Remove last message bubble from UI
    public func RemoveLastMessageFromUI() {
        if IsDefined(this.messageParent) && this.messageParent.GetNumChildren() > 0 {
            let lastIndex = this.messageParent.GetNumChildren() - 1;
            this.messageParent.RemoveChild(this.messageParent.GetWidget(lastIndex));
        }
    }


    private func CreateMemory() {
        let characterName = this.isGroupChat
            ? GetChatStorage().GetGroupChatFileName(this.groupCharacter1, this.groupCharacter2)
            : GetChatStorage().GetCharacterFileName(this.character);
        GetMemoryStorage().SaveMemory(characterName, GetHttpRequestSystem().vMessages, GetHttpRequestSystem().npcResponses);
        GetLongTermMemoryStorage().UpdateLongTermMemory(characterName, GetHttpRequestSystem().vMessages, GetHttpRequestSystem().npcResponses);

        // Visual feedback - change to checkmark
        if IsDefined(this.hintMemoryIcon) && IsDefined(this.hintMemoryText) {
            this.hintMemoryIcon.SetTexturePart(n"kb_1");
            this.hintMemoryIcon.SetTintColor(new Color(Cast(0u), Cast(255u), Cast(0u), Cast(255u)));
            this.hintMemoryIcon.SetOpacity(1.0);
            this.hintMemoryText.SetText("Memory Saved!");
            this.hintMemoryText.SetTintColor(new Color(Cast(0u), Cast(255u), Cast(0u), Cast(255u)));
            
            // Reset after 2 seconds
            let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
            delaySystem.DelayCallback(MemoryFeedbackResetCallback.Create(), 2.0, false);
        }
        
        this.PlaySound(n"ui_menu_onpress");
    }

    public func ResetMemoryHint() {
        if IsDefined(this.hintMemoryIcon) && IsDefined(this.hintMemoryText) {
            this.hintMemoryIcon.SetTexturePart(n"kb_1");
            this.hintMemoryIcon.SetTintColor(new Color(Cast(94u), Cast(246u), Cast(255u), Cast(255u)));
            this.hintMemoryIcon.SetOpacity(1.0);
            this.hintMemoryText.SetText("Save Memory");
            this.hintMemoryText.SetTintColor(new Color(Cast(255u), Cast(97u), Cast(89u), Cast(255u)));
        }
    }

}   


// Delay callback for resetting memory hint
public class MemoryFeedbackResetCallback extends DelayCallback {
    public func Call() {
        let textingSystem = GetTextingSystem();
        if IsDefined(textingSystem) {
            textingSystem.ResetMemoryHint();
        }
    }

    public static func Create() -> ref<MemoryFeedbackResetCallback> {
        let self = new MemoryFeedbackResetCallback();
        return self;
    }
}

// NPC Random timed callout
public class NpcCalloutCallback extends DelayCallback {
    private let m_system: wref<GenerativeTextingSystem>;

    public static func Create(system: wref<GenerativeTextingSystem>) -> ref<NpcCalloutCallback> {
        let cb = new NpcCalloutCallback();
        cb.m_system = system;
        return cb;
    }

    public func Call() -> Void {
        if !IsDefined(this.m_system) { return; }
        if !this.m_system.npcCallout { return; }

        let allChars: array<CharacterSetting> = [
            CharacterSetting.Panam, CharacterSetting.Judy, CharacterSetting.River,
            CharacterSetting.Kerry, CharacterSetting.Songbird, CharacterSetting.Rogue,
            CharacterSetting.BlueMoon, CharacterSetting.RitaWheeler, CharacterSetting.LizzyWizzy,
            CharacterSetting.HanakoArasaka, CharacterSetting.ElizabethPeralez,
            CharacterSetting.MaikoMaeda, CharacterSetting.MichikoArasaka,
            CharacterSetting.AuroreCassel, CharacterSetting.EvelynParker,
            CharacterSetting.ChloeVendranord, CharacterSetting.AngelicaWhelan,
            CharacterSetting.Bugbear, CharacterSetting.Takemura, CharacterSetting.MeredithStout
        ];

        let eligible: array<CharacterSetting>;
        for c in allChars {
            let characterName = GetChatStorage().GetCharacterFileName(c);
            let messages = GetChatStorage().LoadChatHistory(characterName);
            if ArraySize(messages) > 0 {
                ArrayPush(eligible, c);
            }
        }

        if ArraySize(eligible) == 0 {
            this.m_system.StartCalloutTimer();
            return;
        }

        let timeHash: Int32 = Cast<Int32>(GameInstance.GetTimeSystem(GetGameInstance()).GetGameTimeStamp()) % ArraySize(eligible);
        this.m_system.character = eligible[timeHash];

        this.m_system.LoadCurrentChat();
        GetHttpRequestSystem().TriggerPostRequest("+It's been a while. Reach out to V naturally in context with conversation history - ask how they're doing or share something on your mind.");
        GetHttpRequestSystem().AppendToHistory("[AI initiated contact]", true, false);

        this.m_system.StartCalloutTimer();
    }
}