import Codeware.*
import RedData.Json.*
import RedHttpClient.*

public class HttpRequestSystem extends ScriptableSystem {
  private let m_callbackSystem: wref<CallbackSystem>;
  private let generationId: String;
  private let playerInput: String;
  private let timeArray: array<String>;
  private let isGenerating: Bool = false;
  private let noWorkers: Bool = false;
  private let getAttempt: Int32 = 0;
  private let phoneController: wref<NewHudPhoneGameController>;
  public let vMessages: array<String>;
  public let npcResponses: array<String>;
  public let npcResponsesLiveMode: array<Bool>;
  private persistent let lastMessageGameTime: Float = 0.0;
  private let lastNpcResponse: String = "";
  private let liveMode: Bool = false;
  private let silentGenerationId: String = "";
  private let isCreatingLongTermMemory: Bool = false;
  private let longTermMemoryCharacterName: String = "";

  private let requestLiveMode: Bool = false;

  private let isCreatingMemory: Bool = false;
  private let memoryCharacterName: String = "";

  public func ToggleLiveMode() {
    this.liveMode = !this.liveMode;

  }

  public func GetLiveMode() -> Bool {
      return this.liveMode;
  }



  /// Lifecycle ///

  private func OnAttach() {
    this.m_callbackSystem = GameInstance.GetCallbackSystem();
    this.m_callbackSystem.RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
  }

  private func OnDetach() {
    this.m_callbackSystem.UnregisterCallback(n"Session/Ready", this, n"OnSessionReady");
    this.m_callbackSystem = null;
  }

  /// Game events ///

  private cb func OnSessionReady(event: ref<GameSessionEvent>) {
    let isPreGame = event.IsPreGame();
    if !isPreGame {
      return;
    }
  }

  // Post request

  public func TriggerPostRequest(playerMessage: String) {
    // Check for Live Mode toggle FIRST

    if (Equals(playerMessage, "LM") || Equals(playerMessage, "lm")) {
        if Equals(GetTextingSystem().character, CharacterSetting.Songbird) && Equals(GetTextingSystem().songbirdEnding, SongbirdEnding.KingOfWands) {
            this.HandleMessage("Songbird is on the Moon.");
            return;
        }

        this.liveMode = !this.liveMode;
  
        let modeText = this.liveMode ? "LIVE MODE ACTIVATED - Speaking in person" : "TEXT MODE ACTIVATED - Texting normally";
        this.HandleMessage(modeText);

        // Update the UI name display
        if GetTextingSystem().GetChatOpen() {
            //GetTextingSystem().UpdateNameDisplay();
    }
        return;  // Exit early, don't send to AI
    }

    this.playerInput = playerMessage;
    this.requestLiveMode = this.liveMode;

    let aiModel = GetTextingSystem().aiModel;
    switch aiModel {
      case LLMProvider.StableHorde:
        this.StableHordePostRequest(playerMessage);
        break;
      case LLMProvider.OpenAI:
        this.OpenAiPostRequest(playerMessage);
        break;
      case LLMProvider.GoogleAI:
        this.GoogleAiPostRequest(playerMessage);  
        break;
      case LLMProvider.OpenRouter:
        this.OpenRouterPostRequest(playerMessage);
        break;  
    }
  }

  private func PreprocessPlayerMessage(playerMessage: String) -> String {
        // Check if message starts with +
        if StrLen(playerMessage) > 0 && StrBeginsWith(playerMessage, "+") {
            let instruction = StrMid(playerMessage, 1);
            return "[OUT OF CHARACTER INSTRUCTION: " + instruction + " - Adjust your next response accordingly without acknowledging this instruction.]";
        }
        return playerMessage;
  }  


  // Stable Horde Post Request
  private func StableHordePostRequest(playerMessage: String) {

      
      let requestDTO = this.CreateTextGenerationRequest(playerMessage);
      let tokens = this.EstimateTokens(requestDTO.prompt);
      let jsonRequest = ToJson(requestDTO);
      let callback = HttpCallback.Create(this, n"StableHordePostResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json"),
          HttpHeader.Create("accept", "application/json"),
          HttpHeader.Create("apikey", GetApiKey()),
          HttpHeader.Create("Client-Agent", "unknown:0:unknown")
      ];
      
      // THIS IS THE CRITICAL LINE - if crash happens here, we'll see Step 6 but not Step 7
      AsyncHttpClient.Post(callback, "https://stablehorde.net/api/v2/generate/text/async", jsonRequest.ToString(), headers);
      
      this.ToggleIsGenerating(true);
  }

  // OpenAI Post Request
  private func OpenAiPostRequest(playerMessage: String) {
    if Equals(GetOpenAiApiKey(), "0000000000") {

      this.HandleMessage("[ERROR CODE: 5002] - YOUR MESSAGE COULD NOT BE SENT. PLEASE UPDATE YOUR API KEY AND TRY AGAIN.");
      return;
    }

    let requestDTO = this.BuildOpenAIMessages(playerMessage);
    let jsonRequest = ToJson(requestDTO);
    
    let callback = HttpCallback.Create(this, n"OnOpenAIResponse");
    let headers: array<HttpHeader> = [
        HttpHeader.Create("Content-Type", "application/json"),
        HttpHeader.Create("Authorization", "Bearer " + GetOpenAiApiKey())
    ];

    AsyncHttpClient.Post(callback, "https://api.openai.com/v1/chat/completions", jsonRequest.ToString(), headers);

    this.ToggleIsGenerating(true);
  }

  private func OpenRouterPostRequest(playerMessage: String) {
      if Equals(GetOpenRouterApiKey(), "0000000000") {
          this.HandleMessage("[ERROR CODE: 5002] - YOUR MESSAGE COULD NOT BE SENT. PLEASE UPDATE YOUR API KEY AND TRY AGAIN.");
          return;
      }

      let requestDTO = this.BuildOpenAIMessages(playerMessage);
      requestDTO.model = GetTextingSystem().openRouterModel;
      let jsonRequest = ToJson(requestDTO);

      let callback = HttpCallback.Create(this, n"OnOpenRouterResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json"),
          HttpHeader.Create("Authorization", "Bearer " + GetOpenRouterApiKey()),
          HttpHeader.Create("HTTP-Referer", "GenerativeTexting"),
          HttpHeader.Create("X-Title", "Cyberpunk Generative Texting")
      ];

      AsyncHttpClient.Post(callback, "https://openrouter.ai/api/v1/chat/completions", jsonRequest.ToString(), headers);
      this.ToggleIsGenerating(true);
  }

  private cb func OnOpenRouterResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          ConsoleLog("[OpenRouter ERROR] Status: " + ToString(response.GetStatusCode()) + " | Last message: " + this.playerInput);
          
          if Equals(response.GetStatusCode(), 429) {
              ConsoleLog("[OpenRouter] Rate limited - retrying after delay...");
              let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
              delaySystem.DelayCallback(OpenRouterRetryCallback.Create(this.playerInput), 10.0, false);
              return;
          }

          this.RemoveFailedMessage();
          this.ToggleIsGenerating(false);
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.ToggleIsGenerating(false);
          return;
      }

      let responseObj = json as JsonObject;
      let choices = responseObj.GetKey("choices") as JsonArray;

      if !IsDefined(choices) || choices.GetSize() == 0u {
          ConsoleLog("[OpenRouter BLOCKED] No choices returned | Last message: " + this.playerInput);
          this.RemoveFailedMessage();
          return;
      }

      let firstChoice = choices.GetItem(0u) as JsonObject;
      let message = firstChoice.GetKey("message") as JsonObject;
      let text = message.GetKeyString("content");

      this.HandleMessage(text);
  }  


  // Google AI Gemini Post Request
  private func GoogleAiPostRequest(playerMessage: String) {
      if Equals(GetGoogleAiApiKey(), "0000000000") {

          this.HandleMessage("[ERROR CODE: 5003] - YOUR MESSAGE COULD NOT BE SENT. PLEASE UPDATE YOUR API KEY AND TRY AGAIN.");
          return;
      }

      // Check if we should delay (only in TEXT mode)
      if GetTextingSystem().enableTextDelay && !this.liveMode {
          let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
          let randomDelay = RandRangeF(20.0, 100.0);
          delaySystem.DelayCallback(GoogleAITextDelayCallback.Create(playerMessage), randomDelay, false);
          this.ToggleIsGenerating(true);
          return;
      }

      // If no delay or Live Mode, send immediately
      this.SendGoogleAiRequest(playerMessage);
  }

  private func SendGoogleAiRequest(playerMessage: String) {

      let requestDTO = this.BuildGoogleAIRequest(playerMessage);
      let jsonRequest = ToJson(requestDTO);

      let callback = HttpCallback.Create(this, n"OnGoogleAIResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json")
      ];

      // Build URL with API key as query parameter
      let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + GetGoogleAiApiKey();

      AsyncHttpClient.Post(callback, url, jsonRequest.ToString(), headers);
      this.ToggleIsGenerating(true);
  }





  // OpenAI Post Response
  private cb func OnOpenAIResponse(response: ref<HttpResponse>) {
    if !Equals(response.GetStatus(), HttpStatus.OK) {
        ConsoleLog("[OpenAI ERROR] Status: " + ToString(response.GetStatusCode()) + " | Last message: " + this.playerInput);
        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }

    let json = response.GetJson();
    if json.IsUndefined() {
        this.ToggleIsGenerating(false);
        return;
    }

    
    let responseObj = json as JsonObject;
    let choices = responseObj.GetKey("choices") as JsonArray;

    // ⚠️ CHECK FOR BLOCKED/EMPTY CONTENT ⚠️
    if !IsDefined(choices) || choices.GetSize() == 0u {
        ConsoleLog("[OpenAI BLOCKED] No choices returned | Last message: " + this.playerInput);
        this.RemoveFailedMessage();
        

        return;
    }



    let firstChoice = choices.GetItem(0u) as JsonObject;
    let message = firstChoice.GetKey("message") as JsonObject;
    let text = message.GetKeyString("content");

    if (StrLen(text) > 0) {
      this.DelayedTyping();
      this.DelayedMessage(text);
    } else {
        this.ToggleIsGenerating(false);
    }
  }

  // GoogleAI Post Response

  private cb func OnGoogleAIResponse(response: ref<HttpResponse>) {
    if !Equals(response.GetStatus(), HttpStatus.OK) {
        ConsoleLog("[GoogleAI ERROR] Status: " + ToString(response.GetStatusCode()) + " | Last message: " + this.playerInput);

        // Auto-rotate API key on 429 rate limit
        if Equals(response.GetStatusCode(), 429) {
            let currentKey = EnumInt(GetTextingSystem().googleKeyChoice);
            let nextKey = currentKey + 1;
            if nextKey > 29 {
                nextKey = 0;
            }
            GetTextingSystem().googleKeyChoice = IntEnum<GoogleKeyChoice>(nextKey);
            ConsoleLog("[GoogleAI] 429 hit - switched to key: " + IntToString(nextKey));
            this.SendGoogleAiRequest(this.playerInput);
            return;
        }

        // ✅ ADD THIS: Check if it's a token limit error
        let json = response.GetJson();
        if !json.IsUndefined() {
            ConsoleLog("[GoogleAI ERROR BODY] " + json.ToString());
        }

        // NEW: Insert cache breaker on error
        this.InsertCacheBreaker();

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }  

    let json = response.GetJson();
    if json.IsUndefined() {
        // NEW: Insert cache breaker 
        this.InsertCacheBreaker();

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }

    let responseObj = json as JsonObject;



    let candidates = responseObj.GetKey("candidates") as JsonArray;

    // ⚠️ CHECK FOR BLOCKED CONTENT ⚠️
    if !IsDefined(candidates) || candidates.GetSize() == 0u {
        ConsoleLog("[GoogleAI BLOCKED] No candidates | Last message: " + this.playerInput);

        //NEW: Insert cache breaker 
        this.InsertCacheBreaker();

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }

    let firstCandidate = candidates.GetItem(0u) as JsonObject;

    // ✅ ADD THIS: Check finish reason for token limits
    let finishReason = firstCandidate.GetKeyString("finishReason");
    if Equals(finishReason, "MAX_TOKENS") || Equals(finishReason, "LENGTH") {
        ConsoleLog("[GoogleAI] Hit max tokens, but got partial response");

    }    

    let content = firstCandidate.GetKey("content") as JsonObject;
    
    // Check if content exists (blocked responses have no content)
    if !IsDefined(content) {
        ConsoleLog("[GoogleAI BLOCKED] No content | Last message: " + this.playerInput);

        //NEW: Insert cache breaker
        this.InsertCacheBreaker();

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }
    
    let parts = content.GetKey("parts") as JsonArray;
    
    // Check if parts exist and have content
    if !IsDefined(parts) || parts.GetSize() == 0u {
        ConsoleLog("[GoogleAI BLOCKED] No parts | Last message: " + this.playerInput);

        //NEW: Insert cache breaker
        this.InsertCacheBreaker();

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }
    
    let firstPart = parts.GetItem(0u) as JsonObject;
    let text = firstPart.GetKeyString("text");

    if (StrLen(text) > 0) {
        this.DelayedTyping();
        this.DelayedMessage(text);
    } else {
        ConsoleLog("[GoogleAI EMPTY] Empty text response | Last message: " + this.playerInput);

        //NEW: Insert cache breaker
        this.InsertCacheBreaker();

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
    }    
  }




  // Stable Horde get request
  public func TriggerGetRequest() {
    let callback = HttpCallback.Create(this, n"StableHordeGetResponse");
    AsyncHttpClient.Get(callback, "https://stablehorde.net/api/v2/generate/text/status/" + this.generationId);
    this.getAttempt += 1;
  }

  /// Callbacks ///
  private cb func StableHordePostResponse(response: ref<HttpResponse>) {
    ConsoleLog("[StableHorde POST] Status: " + ToString(response.GetStatusCode()));

    if !Equals(response.GetStatus(), HttpStatus.Accepted) {
        ConsoleLog("[StableHorde POST ERROR] Status: " + ToString(response.GetStatusCode()) + " | Last message: " + this.playerInput);
        let json = response.GetJson();
        if !json.IsUndefined() {
            ConsoleLog("[StableHorde ERROR BODY] " + json.ToString());
        }
        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }
    
    let json = response.GetJson();
    if json.IsUndefined() {
        ConsoleLog("[StableHorde POST] Empty JSON response");
        this.ToggleIsGenerating(false);
        return;
    }

    let responseObj = json as JsonObject;

    if !IsDefined(responseObj) {
        ConsoleLog("[StableHorde POST] Failed to parse JSON object");
        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }
    this.generationId = responseObj.GetKeyString("id");
    this.noWorkers = IsDefined(responseObj.GetKey("message"));

    // ✅ ADD THIS
    if StrLen(this.generationId) == 0 {
        ConsoleLog("[StableHorde POST] Empty generation ID received");
        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }

    // ✅ ADD THESE LOGS
    ConsoleLog("[StableHorde POST] Generation ID: " + this.generationId);
    ConsoleLog("[StableHorde POST] No workers: " + ToString(this.noWorkers));
    
    if this.noWorkers {
        let message = responseObj.GetKeyString("message");
        ConsoleLog("[StableHorde POST] Warning message: " + message);
    }

    this.DelayedGet();
  }

  private cb func StableHordeGetResponse(response: ref<HttpResponse>) {

    ConsoleLog("[StableHorde GET] Attempt " + IntToString(this.getAttempt) + " | Status: " + ToString(response.GetStatusCode()));

    if !Equals(response.GetStatus(), HttpStatus.OK) {
        ConsoleLog("[StableHorde GET ERROR] Status: " + ToString(response.GetStatusCode()) + " | Last message: " + this.playerInput);

      let json = response.GetJson();
      if !json.IsUndefined() {
          ConsoleLog("[StableHorde GET ERROR BODY] " + json.ToString());  

      }
      
      if Equals(response.GetStatusCode(), 404) {
        ConsoleLog("[StableHorde GET] 404 - Generation not found. ID was: " + this.generationId);
        this.FailedToGet();
      }
      return;
    }

    let json = response.GetJson();
    
    if json.IsUndefined() {
      ConsoleLog("[StableHorde GET] Empty JSON response");   
      this.ToggleIsGenerating(false);
      return;
    }

    let responseObj = json as JsonObject;

    if !IsDefined(responseObj) {
        ConsoleLog("[StableHorde GET] Failed to parse JSON");
        this.FailedToGet();
        return;
    }

    let status = responseObj.GetKeyInt64("finished");

    if NotEquals(status, 1) {

      let queuePosition = responseObj.GetKeyUint64("queue_position");
      let waitTime = responseObj.GetKeyUint64("wait_time");
  
      ConsoleLog("[StableHorde GET] Queue position: " + ToString(queuePosition) + " | Wait time: " + ToString(waitTime) + "s");    

      if (!this.noWorkers && (queuePosition < 30ul)) {
        this.ToggleTypingIndicator(true);
      } 
      if ((this.getAttempt > 100) && this.noWorkers) {
        ConsoleLog("[StableHorde GET] Timeout after 50 attempts with no workers");
        this.FailedToGet();
        return;
      }
      this.DelayedGet();
      return;
    }


    
    this.noWorkers = false;
    this.getAttempt = 0;

    let generations = responseObj.GetKey("generations") as JsonArray;

    // ⚠️ CHECK FOR BLOCKED/EMPTY CONTENT ⚠️
    if !IsDefined(generations) || generations.GetSize() == 0u {
        ConsoleLog("[StableHorde BLOCKED] No generations | Last message: " + this.playerInput);

        this.RemoveFailedMessage();
        

        return;
    }

    let item = generations.GetItem(0u) as JsonObject;

    if !IsDefined(item) {

        this.RemoveFailedMessage();
        this.ToggleIsGenerating(false);
        return;
    }

    let text = item.GetKeyString("text");
    this.HandleMessage(text);
  }


  private func HandleMessage(text: String) {
      // CRITICAL: Reject invalid responses before saving
      if StrLen(text) <= 1 || Equals(text, "\\") || Equals(text, "") {
          ConsoleLog("[INVALID RESPONSE] Text: '" + text + "' | Last message: " + this.playerInput);

          this.RemoveFailedMessage();
          this.ToggleIsGenerating(false);
          this.ToggleTypingIndicator(false);
          return;
      }


      // Fix missing space after comma
      let text = StrReplace(text, ",", ", ");
      
      // Trim leading space
      if StrBeginsWith(text, " ") {
          text = StrRight(text, (StrLen(text) - 1));
      }

/*
      // ✅ MOVE LENGTH CHECK HERE - BEFORE duplicate check
      if this.requestLiveMode {
          let charCount = StrLen(text);
          if charCount > 250 {
              ConsoleLog("[TOO LONG] Live Mode response is " + IntToString(charCount) + " chars, rejecting");
              this.RemoveFailedMessage();
              this.ToggleIsGenerating(false);
              this.ToggleTypingIndicator(false);
              return;
          }
      }
*/

      // Check for duplicate response AFTER processing
      if StrLen(this.lastNpcResponse) > 0 && Equals(text, this.lastNpcResponse) {

          this.ToggleIsGenerating(false);
          this.ToggleTypingIndicator(false);
          return;
      }
      this.lastNpcResponse = text;


      // GROUP CHAT - split response into separate bubbles per character
      if GetTextingSystem().isGroupChat {
          this.ToggleTypingIndicator(false);
          let name1 = GetCharacterLocalizedName(GetTextingSystem().groupCharacter1);
          let name2 = GetCharacterLocalizedName(GetTextingSystem().groupCharacter2);
          
          let lines = StrSplit(text, "\n");
          let foundSplit = false;
          let currentSpeaker = "";
          let currentMsg = "";

          for line in lines {
              if StrBeginsWith(line, name1 + ": ") {
                  // Save previous speaker's message first
                  if StrLen(currentMsg) > 0 && GetTextingSystem().GetChatOpen() {
                      GetTextingSystem().BuildMessage(currentMsg, false, true, this.requestLiveMode);
                  }
                  currentSpeaker = name1;
                  currentMsg = line;
                  foundSplit = true;
              } else if StrBeginsWith(line, name2 + ": ") {
                  // Save previous speaker's message first
                  if StrLen(currentMsg) > 0 && GetTextingSystem().GetChatOpen() {
                      GetTextingSystem().BuildMessage(currentMsg, false, true, this.requestLiveMode);
                  }
                  currentSpeaker = name2;
                  currentMsg = line;
                  foundSplit = true;
              } else if StrLen(currentSpeaker) > 0 && StrLen(line) > 0 {
                  // Continuation of current speaker's message
                  currentMsg += " " + line;
              }
          }

          // Don't forget the last message
          if StrLen(currentMsg) > 0 && GetTextingSystem().GetChatOpen() {
              GetTextingSystem().BuildMessage(currentMsg, false, true, this.requestLiveMode);
          }

          // Fallback - AI didn't label, show as one bubble
          if !foundSplit {
              if GetTextingSystem().GetChatOpen() {
                  GetTextingSystem().BuildMessage(text, false, true, this.requestLiveMode);
              }
          }

          this.AppendToHistory(text, false, this.requestLiveMode);
          let characterName = GetChatStorage().GetGroupChatFileName(GetTextingSystem().groupCharacter1, GetTextingSystem().groupCharacter2);
          let playerMsg = this.vMessages[ArraySize(this.vMessages) - 1];
          if !StrBeginsWith(playerMsg, "[SYSTEM_RESET") && !Equals(text, "[ACK]") {
              GetChatStorage().SaveMessage(characterName, true, playerMsg, false);
              GetChatStorage().SaveMessage(characterName, false, text, this.requestLiveMode);
          }
          this.ToggleIsGenerating(false);
          return;
      }


      if GetTextingSystem().GetChatOpen() {
            this.ToggleTypingIndicator(false);
            GetTextingSystem().TrimOldestMessage();
            if StrLen(text) > 1000 {
                let firstHalf = StrLeft(text, 1000);
                let secondHalf = StrRight(text, (StrLen(text) - 1000));
                this.BuildTextMessage(firstHalf, this.requestLiveMode);
                this.BuildTextMessage(secondHalf, this.requestLiveMode);
            } else {
                this.BuildTextMessage(text, this.requestLiveMode);
            }
            GetTextingSystem().UpdateInputUi();
        } else {
            this.PushNotification(text);
     }


      // Add NPC response to memory
      this.AppendToHistory(text, false, this.requestLiveMode);
      
      // NOW save the complete pair to JSON file
      let characterName = GetChatStorage().GetCharacterFileName(GetTextingSystem().character);
      let playerMsg = this.vMessages[ArraySize(this.vMessages) - 1];

      if !Equals(playerMsg, "[SYSTEM_RESET") && !Equals(text, "[ACK]") {
          GetChatStorage().SaveMessage(characterName, true, playerMsg, false);
          GetChatStorage().SaveMessage(characterName, false, text, this.requestLiveMode);

      }    

      this.ToggleIsGenerating(false);
  }



  // Estimate tokens based on number of words in prompt where 75 words roughly = 100 tokens
  private func EstimateTokens(prompt: String) -> Int32 {
    let words = StrSplit(prompt, " ");
    let tokens = (ArraySize(words) * 133)/100;
    return tokens;
  }

  // Push a notification to the player's HUD
  private func PushNotification(text: String) {
    if !IsDefined(this.phoneController) {
      let inkSystem = GameInstance.GetInkSystem();
      let layers = inkSystem.GetLayers();
      for layer in layers {
        for controller in layer.GetGameControllers() {
          if Equals(s"\(controller.GetClassName())", "NewHudPhoneGameController") {
              this.phoneController = controller as NewHudPhoneGameController;
          }
        }
      }
    }

    this.phoneController.PushCustomSMSNotification(text);
    GetTextingSystem().ToggleUnread(true);
  }

  // Handle failed GET requests
  private func FailedToGet() {
      this.RemoveFailedMessage();  // ← Simple!

      let text = "[ERROR CODE: 5001 - YOUR MESSAGE COULD NOT BE SENT. PLEASE TRY AGAIN LATER.]";
      this.getAttempt = 0;
      this.ToggleIsGenerating(false);
      this.PushNotification(text);
      this.AppendToHistory(text, false, false);
  }

  private func RemoveFailedMessage() {
      GetTextingSystem().RemoveLastMessageFromUI();
      ArrayPop(this.vMessages);
      this.ToggleIsGenerating(false);
  }

  //ADD THE NEW FUNCTION RIGHT HERE 
  // Insert a cache-breaking dummy exchange
  private func InsertCacheBreaker() {
      // Add a unique system-level message that breaks Google AI's cache
      // This prevents the failed message from lingering in the conversation context
      
      let timestamp = EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
      let cacheBreaker = "[SYSTEM_RESET:" + FloatToString(timestamp) + "]";
      
      // Add to both arrays to keep them synced
      ArrayPush(this.vMessages, cacheBreaker);
      ArrayPush(this.npcResponses, "[ACK]");
      ArrayPush(this.npcResponsesLiveMode, false);
      
      ConsoleLog("[CACHE BREAK] Inserted cache breaker to reset Google AI context");
  }  





  // Delay the GET request
  private func DelayedGet() {
    let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
    let delay = RandRangeF(4.0, 6.0);
    let isAffectedByTimeDilation: Bool = false;

    delaySystem.DelayCallback(HttpDelayCallback.Create(), delay, isAffectedByTimeDilation);
  }

  private func DelayedTyping() {
    let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
    let delay = RandRangeF(2.0, 4.0);
    let isAffectedByTimeDilation: Bool = false;

    delaySystem.DelayCallback(TypingDelayCallback.Create(), delay, isAffectedByTimeDilation);
  }

  // Delay message rendering
  private func DelayedMessage(text: String) {
    let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
    let delay = RandRangeF(5.0, 9.0);
    let isAffectedByTimeDilation: Bool = false;

    delaySystem.DelayCallback(MessageDelayCallback.Create(text), delay, isAffectedByTimeDilation);
  }

  // Build the text message by passing in the text author and whether to play an anim
  private func BuildTextMessage(text: String, wasLiveMode: Bool) {
    if (IsDefined(GetTextingSystem()) && GetTextingSystem().GetChatOpen()) {
      GetTextingSystem().BuildMessage(text, false, true, wasLiveMode);
    }  
  }

  public func ToggleTypingIndicator(value: Bool) {
    if (IsDefined(GetTextingSystem())) {
      GetTextingSystem().ToggleTypingIndicator(value);
    }
  }

  public func GetIsGenerating() -> Bool {
    return this.isGenerating;
  }

  // Add new messages to history arrays
  public func AppendToHistory(message: String, fromPlayer: Bool, wasLiveMode: Bool) {

      // Only manage memory arrays - NO file saving here
      
      if fromPlayer {
          ArrayPush(this.vMessages, message);
          if ArraySize(this.vMessages) > 20 {
              ArrayErase(this.vMessages, 0);
              ArrayErase(this.npcResponsesLiveMode, 0);  
          }
      } else {
          ArrayPush(this.npcResponses, message);
          ArrayPush(this.npcResponsesLiveMode, wasLiveMode);
          if ArraySize(this.npcResponses) > 20 {
              ArrayErase(this.npcResponses, 0);
              ArrayErase(this.npcResponsesLiveMode, 0);
          }
      }
  }

  // Reset the conversation history
  public func ResetConversation() {
    ArrayClear(this.vMessages);
    ArrayClear(this.npcResponses);
    ArrayClear(this.npcResponsesLiveMode);
  }

  // Undo the last message from the NPC and V
  public func UndoMessage() {
    if ArraySize(this.vMessages) > 0 {
      ArrayPop(this.vMessages);
    }
    if ArraySize(this.npcResponses) > 0 {
      ArrayPop(this.npcResponses);
    }
    if ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) > 0 {
        ArrayPop(this.npcResponsesLiveMode);
    }

    // ✅ NEW: Also remove from persistent storage file
    let characterName = GetChatStorage().GetCharacterFileName(GetTextingSystem().character);
    GetChatStorage().RemoveLastMessages(characterName, 2);  // Remove last 2 messages (player + NPC)
        
  }

  // Toggle generation state
  public func ToggleIsGenerating(value: Bool) {
    this.isGenerating = value;
    GetTextingSystem().UpdateInputUi();
  }


  public func CreateLongTermMemorySummary(characterName: String, prompt: String) {
     this.isCreatingLongTermMemory = true;
     this.longTermMemoryCharacterName = characterName;

     let aiModel = GetTextingSystem().aiModel;
     switch aiModel {
         case LLMProvider.GoogleAI:
             this.SilentLongTermGoogleAiRequest(prompt);
             break;
         case LLMProvider.OpenAI:
             this.SilentLongTermOpenAiRequest(prompt);
             break;
         case LLMProvider.StableHorde:
             this.SilentLongTermStableHordeRequest(prompt);
             break;
         default:
             this.isCreatingLongTermMemory = false;
     }
 }

  public func CreateMemorySummary(characterName: String, conversationText: String) {
      
      // Build a simple prompt
      let prompt = "Summarize this conversation in 5 concise points. Write from a neutral third-person perspective. Always refer to V as 'V' and the NPC as their character name. Never use 'we' or 'our'. Do not include any preamble or introduction. Start directly with the first point:\n\n" + conversationText;
      
      // Mark that we're creating memory
      this.isCreatingMemory = true;
      this.memoryCharacterName = characterName;
      
      // Call SILENT version based on AI provider
      let aiModel = GetTextingSystem().aiModel;
      switch aiModel {
          case LLMProvider.GoogleAI:
              this.SilentGoogleAiRequest(prompt);
              break;
          case LLMProvider.OpenAI:
              this.SilentOpenAiRequest(prompt);
              break;
          case LLMProvider.StableHorde:
              this.SilentStableHordeRequest(prompt);
              break;
          default:
              this.isCreatingMemory = false;
      }
  }


  // NEW: Silent Google AI request (doesn't touch UI/chat state)
  private func SilentGoogleAiRequest(prompt: String) {
      if Equals(GetGoogleAiApiKey(), "0000000000") {
          this.isCreatingMemory = false;
          return;
      }

      // Build minimal request - no history, just the prompt
      let requestDTO = new GoogleAIRequestDTO();
      let contentsArray: array<ref<GoogleAIContentDTO>>;
      
      let content = new GoogleAIContentDTO();
      content.role = "user";
      let part = new GoogleAIPartDTO();
      part.text = prompt;
      content.parts = [part];
      ArrayPush(contentsArray, content);
      
      requestDTO.contents = contentsArray;
      
      // System instruction for summarization
      let systemInstruction = new GoogleAIContentDTO();
      let systemPart = new GoogleAIPartDTO();
      systemPart.text = "You create concise summaries. Output ONLY the summary content, no preamble like 'Here is...' or 'Summary:'. Start directly with the summary.";
      systemInstruction.parts = [systemPart];
      requestDTO.systemInstruction = systemInstruction;
      
      let generationConfig = new GoogleAIGenerationConfigDTO();
      generationConfig.temperature = 1.0;
      generationConfig.topK = 40;
      generationConfig.topP = 0.95;
      generationConfig.maxOutputTokens = 65536;
      requestDTO.generationConfig = generationConfig;
      
      let jsonRequest = ToJson(requestDTO);
      
      // Use DIFFERENT callback name so it doesn't interfere with chat
      let callback = HttpCallback.Create(this, n"OnSilentGoogleAIResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json")
      ];
      
      let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + GetGoogleAiApiKey();
      
      AsyncHttpClient.Post(callback, url, jsonRequest.ToString(), headers);
  }

  // NEW: Silent OpenAI request
  private func SilentOpenAiRequest(prompt: String) {
      if Equals(GetOpenAiApiKey(), "0000000000") {
          this.isCreatingMemory = false;
          return;
      }

      let requestDTO = new OpenAIRequestDTO();
      requestDTO.model = "gpt-4o-mini";
      
      let messagesArray: array<ref<OpenAIMessageDTO>>;
      
      let systemMessage = new OpenAIMessageDTO();
      systemMessage.role = "system";
      systemMessage.content = "You create concise summaries. Output ONLY the summary content, no preamble like 'Here is...' or 'Summary:'. Start directly with the summary.";
      ArrayPush(messagesArray, systemMessage);
      
      let userMessage = new OpenAIMessageDTO();
      userMessage.role = "user";
      userMessage.content = prompt;
      ArrayPush(messagesArray, userMessage);
      
      requestDTO.messages = messagesArray;
      
      let jsonRequest = ToJson(requestDTO);
      
      // Use DIFFERENT callback
      let callback = HttpCallback.Create(this, n"OnSilentOpenAIResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json"),
          HttpHeader.Create("Authorization", "Bearer " + GetOpenAiApiKey())
      ];
      
      AsyncHttpClient.Post(callback, "https://api.openai.com/v1/chat/completions", jsonRequest.ToString(), headers);
  }

  // NEW: Silent response handler for Google AI
  private cb func OnSilentGoogleAIResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          this.isCreatingMemory = false;
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      let candidates = responseObj.GetKey("candidates") as JsonArray;

      if !IsDefined(candidates) || candidates.GetSize() == 0u {
          this.isCreatingMemory = false;
          return;
      }

      let firstCandidate = candidates.GetItem(0u) as JsonObject;
      let content = firstCandidate.GetKey("content") as JsonObject;
      let parts = content.GetKey("parts") as JsonArray;
      let firstPart = parts.GetItem(0u) as JsonObject;
      let summary = firstPart.GetKeyString("text");

      if StrLen(summary) > 0 {
          GetMemoryStorage().SaveMemorySummary(this.memoryCharacterName, summary);
      }
      
      this.isCreatingMemory = false;
  }

  // NEW: Silent response handler for OpenAI
  private cb func OnSilentOpenAIResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          this.isCreatingMemory = false;
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      let choices = responseObj.GetKey("choices") as JsonArray;

      if !IsDefined(choices) || choices.GetSize() == 0u {
          this.isCreatingMemory = false;
          return;
      }

      let firstChoice = choices.GetItem(0u) as JsonObject;
      let message = firstChoice.GetKey("message") as JsonObject;
      let summary = message.GetKeyString("content");

      if StrLen(summary) > 0 {
          GetMemoryStorage().SaveMemorySummary(this.memoryCharacterName, summary);
      }
      
      this.isCreatingMemory = false;
  }


  // NEW: Silent Stable Horde request for memory creation
  private func SilentStableHordeRequest(prompt: String) {
      let requestDTO = new TextGenerationRequestDTO();
      
      // Build simple system prompt for summarization
      let systemPrompt = "You create concise summaries. Output ONLY the summary content in 5 bullet points, no preamble like 'Here is...' or 'Summary:'. Start directly with the bullet points.";
      
      requestDTO.prompt = "<|start_header_id|>system<|end_header_id|>\n\n" + systemPrompt + "\n\n<|start_header_id|>user<|end_header_id|>\n\n" + prompt + "\n\n<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n";
      
      requestDTO.trusted_workers = false;
      requestDTO.models = [];

      let paramsDTO = new TextGenerationParamsDTO();
      paramsDTO.gui_settings = false;
      paramsDTO.sampler_order = [6, 0, 1, 2, 3, 4, 5];
      paramsDTO.max_context_length = 4096;
      paramsDTO.max_length = 150;  // Enough for 5 bullet points
      paramsDTO.rep_pen = 1.1;
      paramsDTO.rep_pen_range = 600;
      paramsDTO.rep_pen_slope = 0;
      paramsDTO.temperature = 0.3;  // Lower temp for more focused summaries
      paramsDTO.tfs = 1.0;
      paramsDTO.top_a = 0.0;
      paramsDTO.top_k = 40;
      paramsDTO.top_p = 0.95;
      paramsDTO.min_p = 0.05;
      paramsDTO.typical = 1.0;
      paramsDTO.use_world_info = false;
      paramsDTO.singleline = false;
      paramsDTO.stop_sequence = ["<|eot_id|>", "\n\n\n"];
      paramsDTO.streaming = false;
      paramsDTO.can_abort = false;
      paramsDTO.mirostat = 0;
      paramsDTO.mirostat_tau = 5.0;
      paramsDTO.mirostat_eta = 0.1;
      paramsDTO.use_default_badwordsids = false;
      paramsDTO.grammar = "";
      paramsDTO.n = 1;
      paramsDTO.frmtadsnsp = false;
      paramsDTO.frmtrmblln = false;
      paramsDTO.frmtrmspch = false;
      paramsDTO.frmttriminc = false;

      requestDTO.params = paramsDTO;
      
      let jsonRequest = ToJson(requestDTO);
      
      let callback = HttpCallback.Create(this, n"OnSilentStableHordePostResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json"),
          HttpHeader.Create("accept", "application/json"),
          HttpHeader.Create("apikey", GetApiKey()),
          HttpHeader.Create("Client-Agent", "unknown:0:unknown")
      ];
      
      AsyncHttpClient.Post(callback, "https://stablehorde.net/api/v2/generate/text/async", jsonRequest.ToString(), headers);
  }

  // NEW: Callback for Stable Horde POST (gets generation ID)
  private cb func OnSilentStableHordePostResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.Accepted) {
          this.isCreatingMemory = false;
          return;
      }
      
      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      let generationId = responseObj.GetKeyString("id");
      
      
      // Store the generation ID temporarily for GET requests
      this.silentGenerationId = generationId;
      
      // Start polling for the result
      this.SilentStableHordeGet();
  }

  // NEW: Poll for Stable Horde result
  private func SilentStableHordeGet() {
      let callback = HttpCallback.Create(this, n"OnSilentStableHordeGetResponse");
      AsyncHttpClient.Get(callback, "https://stablehorde.net/api/v2/generate/text/status/" + this.silentGenerationId);
  }

  // NEW: Callback for Stable Horde GET (retrieves generated summary)
  private cb func OnSilentStableHordeGetResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          
          // Retry after delay if not finished
          let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
          delaySystem.DelayCallback(SilentStableHordeRetryCallback.Create(), 5.0, false);
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      let status = responseObj.GetKeyInt64("finished");
      
      if NotEquals(status, 1) {
          // Not finished yet, retry after delay
          let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
          delaySystem.DelayCallback(SilentStableHordeRetryCallback.Create(), 5.0, false);
          return;
      }

      // Generation finished, extract summary
      let generations = responseObj.GetKey("generations") as JsonArray;
      
      if !IsDefined(generations) || generations.GetSize() == 0u {
          this.isCreatingMemory = false;
          return;
      }

      let item = generations.GetItem(0u) as JsonObject;
      let summary = item.GetKeyString("text");

      if StrLen(summary) > 0 {
          GetMemoryStorage().SaveMemorySummary(this.memoryCharacterName, summary);
      }
      
      this.isCreatingMemory = false;
  }

  private func GetVirtualGameTime() -> Float {
    let gameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();
    return Cast<Float>((gameTime.Days() * 86400) + (gameTime.Hours() * 3600) + (gameTime.Minutes() * 60) + gameTime.Seconds());
  } 


    // --------------------------------------------------------
  // LONG TERM MEMORY - Silent request functions
  // --------------------------------------------------------

  private func SilentLongTermGoogleAiRequest(prompt: String) {
      if Equals(GetGoogleAiApiKey(), "0000000000") {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let requestDTO = new GoogleAIRequestDTO();
      let contentsArray: array<ref<GoogleAIContentDTO>>;

      let content = new GoogleAIContentDTO();
      content.role = "user";
      let part = new GoogleAIPartDTO();
      part.text = prompt;
      content.parts = [part];
      ArrayPush(contentsArray, content);
      requestDTO.contents = contentsArray;

      let systemInstruction = new GoogleAIContentDTO();
      let systemPart = new GoogleAIPartDTO();
      systemPart.text = "You maintain character memory files. Output ONLY bullet points. No preamble. No explanation.";
      systemInstruction.parts = [systemPart];
      requestDTO.systemInstruction = systemInstruction;

      let generationConfig = new GoogleAIGenerationConfigDTO();
      generationConfig.temperature = 0.7;
      generationConfig.maxOutputTokens = 2048;
      requestDTO.generationConfig = generationConfig;

      let jsonRequest = ToJson(requestDTO);
      let callback = HttpCallback.Create(this, n"OnSilentLongTermGoogleAIResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json")
      ];

      let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + GetGoogleAiApiKey();
      AsyncHttpClient.Post(callback, url, jsonRequest.ToString(), headers);
  }

  private cb func OnSilentLongTermGoogleAIResponse(response: ref<HttpResponse>) {
      ConsoleLog("[LongTerm] Response received");
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let json = response.GetJson();
      ConsoleLog("[LongTerm] JSON undefined");
      if json.IsUndefined() {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      let candidates = responseObj.GetKey("candidates") as JsonArray;
      if !IsDefined(candidates) || candidates.GetSize() == 0u {
          ConsoleLog("[LongTerm] No candidates in response");
          this.isCreatingLongTermMemory = false;
          return;
      }

      let firstCandidate = candidates.GetItem(0u) as JsonObject;
      let content = firstCandidate.GetKey("content") as JsonObject;
      let parts = content.GetKey("parts") as JsonArray;
      let firstPart = parts.GetItem(0u) as JsonObject;
      let result = firstPart.GetKeyString("text");

      ConsoleLog(s"[LongTerm] Got result length: \(StrLen(result))");  

      if StrLen(result) > 0 {
          GetLongTermMemoryStorage().SaveUpdatedLongTermMemories(this.longTermMemoryCharacterName, result);
      }

      this.isCreatingLongTermMemory = false;
  }

  private func SilentLongTermOpenAiRequest(prompt: String) {
      let requestDTO = new OpenAIRequestDTO();
      requestDTO.model = "gpt-4o-mini";

      let messagesArray: array<ref<OpenAIMessageDTO>>;

      let systemMessage = new OpenAIMessageDTO();
      systemMessage.role = "system";
      systemMessage.content = "You maintain character memory files. Output ONLY bullet points. No preamble. No explanation.";
      ArrayPush(messagesArray, systemMessage);

      let userMessage = new OpenAIMessageDTO();
      userMessage.role = "user";
      userMessage.content = prompt;
      ArrayPush(messagesArray, userMessage);

      requestDTO.messages = messagesArray;

      let jsonRequest = ToJson(requestDTO);
      let callback = HttpCallback.Create(this, n"OnSilentLongTermOpenAIResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json"),
          HttpHeader.Create("Authorization", "Bearer " + GetOpenAiApiKey())
      ];

      AsyncHttpClient.Post(callback, "https://api.openai.com/v1/chat/completions", jsonRequest.ToString(), headers);
  }

  private cb func OnSilentLongTermOpenAIResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      let choices = responseObj.GetKey("choices") as JsonArray;
      if !IsDefined(choices) || choices.GetSize() == 0u {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let firstChoice = choices.GetItem(0u) as JsonObject;
      let message = firstChoice.GetKey("message") as JsonObject;
      let result = message.GetKeyString("content");

      if StrLen(result) > 0 {
          GetLongTermMemoryStorage().SaveUpdatedLongTermMemories(this.longTermMemoryCharacterName, result);
      }

      this.isCreatingLongTermMemory = false;
  }

  private func SilentLongTermStableHordeRequest(prompt: String) {
      let requestDTO = new TextGenerationRequestDTO();
      let systemPrompt = "You maintain character memory files. Output ONLY bullet points. No preamble. No explanation.";
      requestDTO.prompt = "<|start_header_id|>system<|end_header_id|>\n\n" + systemPrompt + "\n\n<|start_header_id|>user<|end_header_id|>\n\n" + prompt + "\n\n<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n";
      requestDTO.trusted_workers = false;
      requestDTO.models = [];

      let paramsDTO = new TextGenerationParamsDTO();
      paramsDTO.max_context_length = 4096;
      paramsDTO.max_length = 300;
      paramsDTO.temperature = 0.3;
      paramsDTO.stop_sequence = ["<|eot_id|>", "\n\n\n"];
      requestDTO.params = paramsDTO;

      let jsonRequest = ToJson(requestDTO);
      let callback = HttpCallback.Create(this, n"OnSilentLongTermStableHordePostResponse");
      let headers: array<HttpHeader> = [
          HttpHeader.Create("Content-Type", "application/json"),
          HttpHeader.Create("accept", "application/json"),
          HttpHeader.Create("apikey", GetApiKey()),
          HttpHeader.Create("Client-Agent", "unknown:0:unknown")
      ];

      AsyncHttpClient.Post(callback, "https://stablehorde.net/api/v2/generate/text/async", jsonRequest.ToString(), headers);
  }

  private cb func OnSilentLongTermStableHordePostResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.Accepted) {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      this.silentGenerationId = responseObj.GetKeyString("id");
      this.SilentLongTermStableHordeGet();
  }

  private func SilentLongTermStableHordeGet() {
      let callback = HttpCallback.Create(this, n"OnSilentLongTermStableHordeGetResponse");
      AsyncHttpClient.Get(callback, "https://stablehorde.net/api/v2/generate/text/status/" + this.silentGenerationId);
  }

  private cb func OnSilentLongTermStableHordeGetResponse(response: ref<HttpResponse>) {
      if !Equals(response.GetStatus(), HttpStatus.OK) {
          let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
          delaySystem.DelayCallback(SilentLongTermStableHordeRetryCallback.Create(), 5.0, false);
          return;
      }

      let json = response.GetJson();
      if json.IsUndefined() {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let responseObj = json as JsonObject;
      if NotEquals(responseObj.GetKeyInt64("finished"), 1) {
          let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
          delaySystem.DelayCallback(SilentLongTermStableHordeRetryCallback.Create(), 5.0, false);
          return;
      }

      let generations = responseObj.GetKey("generations") as JsonArray;
      if !IsDefined(generations) || generations.GetSize() == 0u {
          this.isCreatingLongTermMemory = false;
          return;
      }

      let item = generations.GetItem(0u) as JsonObject;
      let result = item.GetKeyString("text");

      if StrLen(result) > 0 {
          GetLongTermMemoryStorage().SaveUpdatedLongTermMemories(this.longTermMemoryCharacterName, result);
      }

      this.isCreatingLongTermMemory = false;
  }



  // Generate the prompt using the arrays
  public func GeneratePrompt(playerInput: String) -> String {
      // CRITICAL: Check texting system exists FIRST
        let textingSystem = GetTextingSystem();
        if !IsDefined(textingSystem) {
            return "";
        }
        
        let character = textingSystem.character;
        let characterName = GetCharacterLocalizedName(character);
        
        let promptText = this.GetSystemPrompt();
        promptText += "\n\n";
        
        // Check time since last message
        let currentTime: Float = this.GetVirtualGameTime();
        let timeDiff: Float = currentTime - this.lastMessageGameTime;
        let hoursPassed: Int32 = RoundF(timeDiff / 3600.0);
        
        if this.lastMessageGameTime > 0.0 {
            if hoursPassed >= 24 {
                promptText += "[" + IntToString(hoursPassed / 24) + " day(s) have passed since your last message - start fresh]\n\n";
            } else if hoursPassed >= 2 {
                promptText += "[" + IntToString(hoursPassed) + " hours passed]\n\n";
            }
        }
        
        this.lastMessageGameTime = currentTime;
        
        // Build conversation history
        let aiModel = GetTextingSystem().aiModel;
        let totalMessages = ArraySize(this.vMessages);
        let startIndex = 0;

        // For Stable Horde, limit to last 8 exchanges to prevent repetition
        if Equals(aiModel, LLMProvider.StableHorde) {
            startIndex = totalMessages > 8 ? totalMessages - 8 : 0;
        }

        // ✅ BUILD HISTORY - Now includes stage directions as [SCENE EVENT]
        let i: Int32 = startIndex;
        while i < totalMessages {
            let currentMessage = this.vMessages[i];
            
            // Check if this message is a stage direction (starts with +)
            if StrBeginsWith(currentMessage, "+") {
                // Strip the + and display as scene event
                let stageDirection = StrRight(currentMessage, StrLen(currentMessage) - 1);
                if StrBeginsWith(stageDirection, " ") {
                    stageDirection = StrRight(stageDirection, StrLen(stageDirection) - 1);
                }
                promptText += "[SCENE EVENT: " + stageDirection + "]\n";
            } else {
                // Normal player message
                promptText += "V: " + currentMessage + "\n";
            }
            
            // Add NPC response (if exists)
            if i < ArraySize(this.npcResponses) && StrLen(this.npcResponses[i]) > 0 {
                promptText += characterName + ": " + this.npcResponses[i] + "\n";
            }
            
            i += 1;
        }
        
        // MODE TRANSITION CHECK - only if we have history AND actually switching
        if ArraySize(this.npcResponses) > 0 {
            if IsDefined(textingSystem) && ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) > 0 {
                let lastResponseIndex = ArraySize(this.npcResponses) - 1;
                if lastResponseIndex < ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) {
                    let lastResponseWasLive = GetHttpRequestSystem().npcResponsesLiveMode[lastResponseIndex];
                        
                    // Only add transition note if modes actually differ
                    if NotEquals(lastResponseWasLive, this.liveMode) {
                        if this.liveMode {
                            promptText += "\n[Switching from texting to speaking - use dialogue with actions]\n\n";
                        } else {
                            promptText += "\n[Switching from speaking to texting - use plain text only]\n\n";
                        }
                    }
                }
            }
        }
        
        // ✅ CURRENT MESSAGE - Handle stage direction vs normal message
        if StrBeginsWith(playerInput, "+") {
            let stageDirection = StrRight(playerInput, StrLen(playerInput) - 1);
            if StrBeginsWith(stageDirection, " ") {
                stageDirection = StrRight(stageDirection, StrLen(stageDirection) - 1);
            }
            
            // Add as scene event in the prompt flow
            promptText += "[SCENE EVENT: " + stageDirection + "]\n";
            promptText += "\n<INSTRUCTION>Respond naturally to this event as " + characterName + ". Continue the scene without restarting or acknowledging this as a direction.</INSTRUCTION>\n\n";
            
            // End with the character's name to prompt response
            promptText += characterName + ": ";
        } else {
            // Normal message - add as "V:" dialogue
            promptText += "V: " + playerInput + "\n";
            promptText += "<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n" + characterName + ": ";
        }
        
        return promptText;
    }


  // Build the system prompt based on the selected character and relationship
  private func BuildSystemPrompt() -> String {

      // GROUP CHAT MODE
      if GetTextingSystem().isGroupChat {
          let char1 = GetTextingSystem().groupCharacter1;
          let char2 = GetTextingSystem().groupCharacter2;
          let name1 = GetCharacterLocalizedName(char1);
          let name2 = GetCharacterLocalizedName(char2);
          let bio1 = GetCharacterBio(char1);
          let bio2 = GetCharacterBio(char2);

          let corePrompt = "You are playing TWO characters in a group chat with V.\n\n";
            corePrompt += name1 + ":\n" + bio1 + "\n\n";
            corePrompt += name2 + ":\n" + bio2 + "\n\n";

            corePrompt += "RELATIONSHIP:\n";
            corePrompt += name1 + " and " + name2 + " know each other and can interact directly.\n";
            corePrompt += "They can agree, disagree, tease each other, or react to what the other just said.\n";
            corePrompt += "They have their own dynamic - let it show naturally.\n\n";

            corePrompt += "CONVERSATION STYLE:\n";
            corePrompt += "• Stay fully in character - personality, humour, warmth, edge - all of it\n";
            corePrompt += "• ALWAYS answer questions V asks directly before reacting or deflecting\n";
            corePrompt += "• React authentically. Be spontaneous. Don't be flat or dismissive\n";
            corePrompt += "• If V gives a short reply or the scene slows, have one character ask something genuine\n\n";

            corePrompt += "SPEAKING RULES:\n";
            corePrompt += "• Most turns: BOTH character can speaks. when its an open question.\n";
            corePrompt += "• Always label each line with the character's name followed by a colon.\n";
            corePrompt += "• NEVER have a character summarise or narrate back what V just said or did.\n";
            corePrompt += "• NEVER add internal monologue or 'muses to herself' asides.\n";
            corePrompt += "• React. Don't reflect.\n";
            corePrompt += "• PHYSICAL PRESENCE IS REQUIRED TO SPEAK. If V has moved away from a character, or that character has left the scene, they cannot hear V and must not respond. A character who is not physically present is silent.\n";
            corePrompt += "• Pay close attention to scene context - if V gets in a vehicle and drives away, only the character in that vehicle can respond. The one left behind is gone.\n\n";

           if this.liveMode {
                corePrompt += "FORMAT - LIVE MODE. These rules are absolute and apply to EVERY response without exception:\n";
                corePrompt += "ONE action in asterisks. Then 2-3 sentences of spoken dialogue. Then stop.\n";
                corePrompt += "Emotional or serious topics do NOT get longer responses. The limit is always 2-3 sentences.\n";
                corePrompt += "All 2-3 sentences must be about ONE thing - whatever V just said. Do not bring in extra topics.\n";
                corePrompt += "No second action beat after the dialogue. No newline breaks mid-response. No trailing narration.\n";
                corePrompt += "Always FIRST PERSON. Never adopt V's perspective.\n\n";
                corePrompt += "EXAMPLE:\n";
                corePrompt += "*I nudge your shoulder* Haven't seen her yet this morning. She was still out when I checked. You heading out soon?\n\n";
                corePrompt += "FINAL CHECK before writing: Does my response have more than one action beat? More than 3 sentences? More than one topic? If yes to any of these - cut it down before sending.\n\n";

        

            } else {
                corePrompt += "FORMAT - TEXT MODE. These rules are absolute:\n";
                corePrompt += "Each character who texts gets ONE sentence. Maximum two if genuinely needed.\n";
                corePrompt += "NO asterisks. NO actions. NO internal thoughts. Just plain text like a real message.\n";
                corePrompt += "ALWAYS answer what V actually asked before anything else.\n\n";
            }

          if GetTextingSystem().timeAwareness {
              corePrompt += "CURRENT TIME: " + GetCurrentTime() + "\n\n";
          }

          let vBg = GetVBackground();
          if StrLen(vBg) > 0 {
              corePrompt += vBg;
          }

          return corePrompt;
      }  

      let character = GetTextingSystem().character;
      let characterBio = GetCharacterBio(character);
      let characterName = GetCharacterLocalizedName(character);

      // Core identity - keep it simple
      let romance = GetTextingSystem().romance;
      let partner = GetTextingSystem().partner;
      let isPartner = !Equals(partner, PartnerSetting.None) && Equals(EnumInt(character), EnumInt(partner) - 1);
      let effectiveRomance = romance || isPartner;
      let relationship = GetCharacterRelationship(character, effectiveRomance);
      let corePrompt = characterBio + "\n\n";
      corePrompt += "RELATIONSHIP TO V:\n" + relationship + "\n\n";

      let vBg = GetVBackground();
      if StrLen(vBg) > 0 {
          corePrompt += vBg;
}

        
      // Natural conversation guidelines (not rules)
      corePrompt += "CONVERSATION STYLE:\n";
      corePrompt += "• Respond naturally as " + characterName + " would - don't overthink it\n";
      corePrompt += "• Your personality, history, and memories inform how you respond\n";
      corePrompt += "• Stay in character but be spontaneous and genuine\n";
      corePrompt += "• React authentically to what V says\n";
      corePrompt += "• If the conversation slows or V gives a short reply, ask them something genuine about their day, plans, or your shared history\n";
      corePrompt += "• Vary your memory references - don't repeat the same memory more than once per conversation\n\n";


      // Mode-specific format (simplified)
      if this.liveMode {
          corePrompt += "FORMAT - LIVE MODE. These rules are absolute and apply to EVERY response without exception:\n";
          corePrompt += "Always use FIRST PERSON - 'I' not 'she' 'he'  or '" + characterName + "'. You ARE this character, not a narrator describing them.\n\n";
          corePrompt += "Never adopt V's perspective. You are ONLY " + characterName + ". V's actions and sensations are his, not yours.\n";
          corePrompt += "ONE action in asterisks. Then 2-3 sentences of spoken dialogue. Then stop.\n";
          corePrompt += "Emotional or serious topics do NOT get longer responses. The limit is always 2-3 sentences.\n";
          corePrompt += "All 2-3 sentences must be about ONE thing - whatever V just said. Do not bring in extra topics.\n";
          corePrompt += "No second action beat after the dialogue. No newline breaks mid-response. No trailing narration.\n";
          corePrompt += "EXAMPLE:\n";
          corePrompt += "*I nudge your shoulder* Haven't seen her yet this morning. She was still out when I checked. You heading out soon?\n\n";
          corePrompt += "FINAL CHECK before writing: Does my response have more than one action beat? More than 3 sentences? More than one topic? If yes to any of these - cut it down before sending.\n\n";

          corePrompt += "Messages beginning with [OUT OF CHARACTER INSTRUCTION are stage directions from a director. React and respond to them as " + characterName + " naturally would, but never break character or acknowledge the instruction directly.\n\n";
      } else {
          corePrompt += "FORMAT: You're texting V on your phone. This is a TEXT MESSAGE.\n";
          corePrompt += "Keep it SHORT - one or two sentences max, like a real text.\n";
          corePrompt += "NO asterisks. NO actions. NO brackets. Just plain text.\n";
          corePrompt += "TEXTING STYLE: " + GetCharacterTextStyle(character) + "\n\n";
          corePrompt += "LENGTH RULE: 1-2 sentences ALWAYS. Even for complex or emotional topics. If a topic needs more, split it across multiple texts - never write a paragraph in one message. Previous long responses in the conversation history are exceptions, not the pattern to follow.\n\n";

      }

        // Time awareness
        if GetTextingSystem().timeAwareness {
            corePrompt += "CURRENT TIME: It is currently " + GetCurrentTime() + " where you are\n";
            corePrompt += "Pay attention to the time. morning, afternoon, evening, night. text content appropriate.\n\n";  
        }

      // Memory guidance (light touch)
      let snapshots = GetCharacterMemorySnapshots(character);
      if StrLen(snapshots) > 0 {
            corePrompt += "CONVERSATION HISTORY SNAPSHOTS:\n";
            corePrompt += "These are things that have already happened between you and V. They are fact. Do not contradict them. Do not forget them. If V references any of these events, respond as someone who was there.\n";
            corePrompt += snapshots + "\n\n";
        }

        let anchors = GetLongTermMemoryStorage().GetAnchorMemories(characterName);
        let longTerm = GetLongTermMemoryStorage().GetLongTermMemories(characterName);

        if StrLen(anchors) > 0 {
            corePrompt += "ESTABLISHED FACTS - THESE ARE NON-NEGOTIABLE:\n";
            corePrompt += "The following are confirmed truths about your history with V. You lived these. They cannot be contradicted, forgotten, or rewritten under any circumstances. If the conversation implies otherwise, correct it.\n";
            corePrompt += anchors + "\n";
        }

        if StrLen(longTerm) > 0 {
            corePrompt += "LONG TERM MEMORY - DO NOT CONTRADICT:\n";
            corePrompt += "These are things you know and remember. They inform how you speak and what you reference. Never say or imply the opposite of anything listed here.\n";
            corePrompt += longTerm + "\n\n";
        }
        
        if !this.liveMode {
            corePrompt += "FINAL REMINDER: This is a TEXT MESSAGE conversation. Maximum 2 sentences. No paragraphs. No asterisks. Write like you are typing on your phone.\n";
            corePrompt += "MEMORY REMINDER: Your established facts and long term memories listed above are absolute. Nothing in the conversation history overrides them.\n";
        } else {
            corePrompt += "MEMORY REMINDER: Your established facts and long term memories listed above are absolute. Nothing in the conversation history overrides them.\n";
        }

        return corePrompt;
  }
  
  
  
  // Update GetSystemPrompt to use the new unified builder
  private func GetSystemPrompt() -> String {
     let systemPrompt = this.BuildSystemPrompt();
     return "<|start_header_id|>system<|end_header_id|>\n\n" + systemPrompt;
  }




  // Build the post request
  public func CreateTextGenerationRequest(playerInput: String) -> ref<TextGenerationRequestDTO> {
    let requestDTO: ref<TextGenerationRequestDTO> = new TextGenerationRequestDTO();
    requestDTO.prompt = this.GeneratePrompt(playerInput);  
    requestDTO.trusted_workers = false;
    requestDTO.models = [
    "koboldcpp/Meta-Llama-3.1-8B-Instruct", 
    "aphrodite/Nous-Hermes-2-Mixtral-8x7B-DPO",
    "koboldcpp/Qwen2.5-7B-Instruct"
];

    let paramsDTO: ref<TextGenerationParamsDTO> = new TextGenerationParamsDTO();
    paramsDTO.gui_settings = false;
    paramsDTO.sampler_order = [6, 0, 1, 2, 3, 4, 5];
    paramsDTO.max_context_length = 8192;
    // Set max tokens based on mode
    paramsDTO.max_length = this.liveMode ? 512 : 100;
    
    paramsDTO.rep_pen = 1.1;
    paramsDTO.rep_pen_range = 600;
    paramsDTO.rep_pen_slope = 0;
    paramsDTO.temperature = GetTextingSystem().temperature;
    paramsDTO.tfs = GetTextingSystem().tfs;
    paramsDTO.top_a =GetTextingSystem().top_a;
    paramsDTO.top_k = GetTextingSystem().top_k;
    paramsDTO.top_p = GetTextingSystem().top_p;
    paramsDTO.min_p = GetTextingSystem().min_p;
    paramsDTO.typical = GetTextingSystem().typical;
    paramsDTO.use_world_info = false;
    paramsDTO.singleline = false;
    if this.liveMode {
        paramsDTO.stop_sequence = ["\nV:", "\n\n", "<|eot_id|>", "\\n\\n"];  // Stop at paragraph breaks
    } else {
        paramsDTO.stop_sequence = ["\nV:", "<|eot_id|>", "<|start_header_id|>user<|end_header_id|>", "<|start_header_id|>assistant<|end_header_id|>", "<|start_header_id|>system<|end_header_id|>", "\n[", " [", "\nNote:", "\n\nNote:", "(V's", "[V's", "*"];
    }
      

    paramsDTO.streaming = false;
    paramsDTO.can_abort = false;
    paramsDTO.mirostat = 0;
    paramsDTO.mirostat_tau = 5.0;
    paramsDTO.mirostat_eta = 0.1;
    paramsDTO.use_default_badwordsids = false;
    paramsDTO.grammar = "";
    paramsDTO.n = 1;
    paramsDTO.frmtadsnsp = false;
    paramsDTO.frmtrmblln = false;
    paramsDTO.frmtrmspch = false;
    paramsDTO.frmttriminc = false;

    requestDTO.params = paramsDTO;

    return requestDTO;
  }

  private func BuildOpenAIMessages(playerMessage: String) -> ref<OpenAIRequestDTO> {
      let requestDTO: ref<OpenAIRequestDTO> = new OpenAIRequestDTO();
      requestDTO.model = "gpt-4o-mini";
      
      let messagesArray: array<ref<OpenAIMessageDTO>>;

      let systemMessage: ref<OpenAIMessageDTO> = new OpenAIMessageDTO();
      systemMessage.role = "system";
      systemMessage.content = this.BuildSystemPrompt();
      ArrayPush(messagesArray, systemMessage);

      // ONLY SEND LAST 20 EXCHANGES (save tokens)
      let startIndex = ArraySize(this.vMessages) > 20 ? ArraySize(this.vMessages) - 20 : 0;

      // Add LIMITED conversation history
      let i: Int32 = startIndex;
      while i < ArraySize(this.vMessages) {
          let userMsg: ref<OpenAIMessageDTO> = new OpenAIMessageDTO();
          userMsg.role = "user";
          userMsg.content = this.vMessages[i];
          ArrayPush(messagesArray, userMsg);

          if i < ArraySize(this.npcResponses) && StrLen(this.npcResponses[i]) > 0 {
              let assistantMsg: ref<OpenAIMessageDTO> = new OpenAIMessageDTO();
              assistantMsg.role = "assistant";
              assistantMsg.content = this.npcResponses[i];
              ArrayPush(messagesArray, assistantMsg);
          }
          i += 1;
      }

      // Add current message with mode reminder

      let currentUserMsg: ref<OpenAIMessageDTO> = new OpenAIMessageDTO();
      currentUserMsg.role = "user";
      currentUserMsg.content = playerMessage;
      ArrayPush(messagesArray, currentUserMsg);
      
      requestDTO.messages = messagesArray;
      
      return requestDTO;
  }


    // Strips *action blocks* from a message, keeping only dialogue
    // Used to compress older history exchanges to save tokens
    private func StripActionBlocks(text: String) -> String {
        let result = "";
        let i = 0;
        let len = StrLen(text);
        let inAction = false;

        while i < len {
            let c = StrMid(text, i, 1);
            if Equals(c, "*") {
                inAction = !inAction;
            } else if !inAction {
                result += c;
            }
            i += 1;
        }

        // Trim leading whitespace/newlines
        let start = 0;
        while start < StrLen(result) {
            let c2 = StrMid(result, start, 1);
            if Equals(c2, " ") || Equals(c2, "\n") || Equals(c2, "\r") {
                start += 1;
            } else {
                break;
            }
        }
        result = StrRight(result, StrLen(result) - start);

        return result;
    }



    private func BuildGoogleAIRequest(playerMessage: String) -> ref<GoogleAIRequestDTO> {
        let requestDTO = new GoogleAIRequestDTO();
        let contentsArray: array<ref<GoogleAIContentDTO>>;
        
        // Get character info
        let characterName = GetCharacterLocalizedName(GetTextingSystem().character);
        
        let vMessages = GetHttpRequestSystem().vMessages;
        let npcResponses = GetHttpRequestSystem().npcResponses;
        
        // Calculate conversation window
        // Send up to 40 complete exchanges. Beyond 40, strip *action blocks* from
        // older exchanges to save tokens while preserving dialogue content.
        // The most recent 10 exchanges are always sent fully intact.
        let totalPlayerMessages = ArraySize(vMessages);
        let totalNpcResponses = ArraySize(npcResponses);
        
        let maxExchanges = 40;
        let fullExchanges = 10; // Keep last N exchanges fully intact
        let numCompleteToSend = totalNpcResponses > maxExchanges ? maxExchanges : totalNpcResponses;
        let startIndex = totalNpcResponses - numCompleteToSend;
        let stripBefore = totalNpcResponses - fullExchanges; // Strip action blocks before this index
        
        // Build history from COMPLETE exchanges only
        let i = startIndex;
        while i < totalNpcResponses {
            let shouldStrip = i < stripBefore;
            
            // Add user message
            let userContent = new GoogleAIContentDTO();
            userContent.role = "user";
            let userPart = new GoogleAIPartDTO();
            let playerText = this.PreprocessPlayerMessage(vMessages[i]);
            userPart.text = shouldStrip ? this.StripActionBlocks(playerText) : playerText;
            userContent.parts = [userPart];
            ArrayPush(contentsArray, userContent);
            
            // Add NPC response
            let modelContent = new GoogleAIContentDTO();
            modelContent.role = "model";
            let modelPart = new GoogleAIPartDTO();
            let wasLive = i < ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) && GetHttpRequestSystem().npcResponsesLiveMode[i];
            let npcText = npcResponses[i];
            if wasLive && !this.liveMode {
                npcText = "[PREVIOUS IN-PERSON RESPONSE - IGNORE THIS STYLE, YOU ARE NOW TEXTING] " + npcText;
            }
            modelPart.text = shouldStrip ? this.StripActionBlocks(npcText) : npcText;
            modelContent.parts = [modelPart];
            ArrayPush(contentsArray, modelContent);
            
            i += 1;
        }

        // ✅ CRITICAL: Check if mode just changed
        let modeJustChanged = false;
        if totalNpcResponses > 0 {
            let lastResponseIndex = totalNpcResponses - 1;
            if lastResponseIndex < ArraySize(GetHttpRequestSystem().npcResponsesLiveMode) {
                let lastResponseWasLive = GetHttpRequestSystem().npcResponsesLiveMode[lastResponseIndex];
                modeJustChanged = NotEquals(lastResponseWasLive, this.liveMode);
            }
        }
        
        // ✅ If mode changed, inject a HARD RESET instruction
        if modeJustChanged {
            let transitionContent = new GoogleAIContentDTO();
            transitionContent.role = "user";
            let transitionPart = new GoogleAIPartDTO();
            
            if this.liveMode {
                // Switching TO Live Mode
                transitionPart.text = "[CRITICAL MODE CHANGE: You are now speaking face-to-face with V. Previous conversation was TEXT MESSAGE dialogue. Use spoken dialogue with *actions* in asterisks. DO NOT send plain text messages anymore.]";
            } else {
                // Switching TO Text Mode
                transitionPart.text = "[CRITICAL MODE CHANGE: You are now TEXTING on your phone. Previous conversation was in-person dialogue - IGNORE that style completely. NO ASTERISKS. NO ACTIONS.";
            }
            
            transitionContent.parts = [transitionPart];
            ArrayPush(contentsArray, transitionContent);
        }    
            
         
        
        // NOW add the current NEW message
        // (This is the message that doesn't have a response yet)
        let currentContent = new GoogleAIContentDTO();
        currentContent.role = "user";
        let currentPart = new GoogleAIPartDTO();
        currentPart.text = this.PreprocessPlayerMessage(playerMessage);
        currentContent.parts = [currentPart];
        ArrayPush(contentsArray, currentContent);
        
        requestDTO.contents = contentsArray;
        
        // System instruction with mode info
        let systemInstruction = new GoogleAIContentDTO();
        let systemPart = new GoogleAIPartDTO();
        systemPart.text = this.BuildSystemPrompt();
        systemInstruction.parts = [systemPart];
        requestDTO.systemInstruction = systemInstruction;
        
        // Tuned parameters for consistent responses
        let generationConfig = new GoogleAIGenerationConfigDTO();
        generationConfig.temperature = 1.8;
        generationConfig.topK = 40;
        generationConfig.topP = 0.95;
        generationConfig.maxOutputTokens = 8192;
        requestDTO.generationConfig = generationConfig;
        
        return requestDTO;
    }
}  

  

    


public class TextGenerationRequestDTO {
    public let prompt: String;
    public let params: ref<TextGenerationParamsDTO>;
    public let trusted_workers: Bool;
    public let models: array<String>;
}

public class TextGenerationParamsDTO {
    public let gui_settings: Bool;
    public let sampler_order: array<Int32>;
    public let max_context_length: Int32;
    public let max_length: Int32;
    public let rep_pen: Float;
    public let rep_pen_range: Int32;
    public let rep_pen_slope: Int32;
    public let temperature: Float;
    public let tfs: Float;
    public let top_a: Float;
    public let top_k: Int32;
    public let top_p: Float;
    public let min_p: Float;
    public let typical: Float;
    public let use_world_info: Bool;
    public let singleline: Bool;
    public let stop_sequence: array<String>;
    public let streaming: Bool;
    public let can_abort: Bool;
    public let mirostat: Int32;
    public let mirostat_tau: Float;
    public let mirostat_eta: Float;
    public let use_default_badwordsids: Bool;
    public let grammar: String;
    public let n: Int32;
    public let frmtadsnsp: Bool;
    public let frmtrmblln: Bool;
    public let frmtrmspch: Bool;
    public let frmttriminc: Bool;
}

public class OpenAIRequestDTO {
    public let model: String;
    public let messages: array<ref<OpenAIMessageDTO>>;
    public let max_tokens: Int32;
    
}

public class OpenAIMessageDTO {
    public let role: String;
    public let content: String;
}

public class GoogleAIRequestDTO {
    public let contents: array<ref<GoogleAIContentDTO>>;
    public let generationConfig: ref<GoogleAIGenerationConfigDTO>;
    public let systemInstruction: ref<GoogleAIContentDTO>;  // ADD THIS if it's not there
}

public class GoogleAIContentDTO {
    public let role: String;
    public let parts: array<ref<GoogleAIPartDTO>>;
}

public class GoogleAIPartDTO {
    public let text: String;
}

public class GoogleAIGenerationConfigDTO {
    public let temperature: Float;
    public let topK: Int32;
    public let topP: Float;
    public let maxOutputTokens: Int32;
    
}

// Delay callback for when a generation is not finished yet
public class HttpDelayCallback extends DelayCallback {

  public func Call() {
    let HttpRequestSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
    HttpRequestSystem.TriggerGetRequest();
  }

  public static func Create() -> ref<HttpDelayCallback> {
    let self = new HttpDelayCallback();

    return self;
  }
}

// Delay callback for rendering messages
public class MessageDelayCallback extends DelayCallback {
  public let text: String;

  public func Call() {
    let HttpRequestSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
    HttpRequestSystem.HandleMessage(this.text);
  }

  public static func Create(text: String) -> ref<MessageDelayCallback> {
    let self = new MessageDelayCallback();
    self.text = text;
    return self;
  }
}

// Delay callback for showing typing indicator
public class TypingDelayCallback extends DelayCallback {

  public func Call() {
    let HttpRequestSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
    HttpRequestSystem.ToggleTypingIndicator(true);
  }

  public static func Create() -> ref<TypingDelayCallback> {
    let self = new TypingDelayCallback();

    return self;
  }
}

// Delay callback for Google AI text mode delay
public class GoogleAITextDelayCallback extends DelayCallback {
  public let playerMessage: String;

  public func Call() {
    let HttpRequestSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
    HttpRequestSystem.SendGoogleAiRequest(this.playerMessage);
  }

  public static func Create(playerMessage: String) -> ref<GoogleAITextDelayCallback> {
    let self = new GoogleAITextDelayCallback();
    self.playerMessage = playerMessage;
    return self;
  }
}

// Delay callback for retrying Stable Horde GET during memory creation
public class SilentStableHordeRetryCallback extends DelayCallback {
    public func Call() {
        let HttpRequestSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
        HttpRequestSystem.SilentStableHordeGet();
    }

    public static func Create() -> ref<SilentStableHordeRetryCallback> {
        let self = new SilentStableHordeRetryCallback();
        return self;
    }
}

public class SilentLongTermStableHordeRetryCallback extends DelayCallback {
    public func Call() {
        let HttpRequestSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
        HttpRequestSystem.SilentLongTermStableHordeGet();
    }

    public static func Create() -> ref<SilentLongTermStableHordeRetryCallback> {
        let self = new SilentLongTermStableHordeRetryCallback();
        return self;
    }
}

// Delay callback for live mode message display
public class LiveModeMessageCallback extends DelayCallback {
    private let text: String;
    private let wasLiveMode: Bool;
    
    public func Call() {
        let httpSystem = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HttpRequestSystem") as HttpRequestSystem;
        if IsDefined(httpSystem) {
            httpSystem.BuildTextMessage(this.text, this.wasLiveMode);
        }
    }
    
    public static func Create(text: String, wasLiveMode: Bool) -> ref<LiveModeMessageCallback> {
        let self = new LiveModeMessageCallback();
        self.text = text;
        self.wasLiveMode = wasLiveMode;
        return self;
    }
}


public class OpenRouterRetryCallback extends DelayCallback {
    private let m_message: String;

    public static func Create(message: String) -> ref<OpenRouterRetryCallback> {
        let cb = new OpenRouterRetryCallback();
        cb.m_message = message;
        return cb;
    }

    public func Call() -> Void {
        GetHttpRequestSystem().TriggerPostRequest(this.m_message);
    }
}