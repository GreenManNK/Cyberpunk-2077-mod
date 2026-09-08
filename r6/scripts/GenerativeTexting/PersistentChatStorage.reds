import Codeware.*


// Structure to hold a single chat message
public class ChatMessage {
    public let fromPlayer: Bool;
    public let text: String;
    // REMOVED: public let timestamp: String;
    // REMOVED: public let day: Int32; 
    public let isLiveMode: Bool; // Track if message was sent in Live Mode

    public static func Create(fromPlayer: Bool, text: String, isLiveMode: Bool) -> ref<ChatMessage> {
        let msg = new ChatMessage();
        msg.fromPlayer = fromPlayer;
        msg.text = text;
        // REMOVED: timestamp and day assignments
        msg.isLiveMode = isLiveMode;
        return msg;
    }
}


// Structure to hold chat history for a specific character
public class CharacterChatHistory {
    public let characterName: String;
    public let messages: array<ref<ChatMessage>>;
    public let isLoaded: Bool; // Tracks whether this history has been loaded from disk

    public static func Create(characterName: String) -> ref<CharacterChatHistory> {
        let history = new CharacterChatHistory();
        history.characterName = characterName;
        history.isLoaded = false;
        return history;
    }
}

public class PersistentChatStorage extends ScriptableSystem {
    private persistent let chatHistories: array<ref<CharacterChatHistory>>;
    private let saveDirectory: String = "generative_texting_chats";
    private let maxMessagesPerCharacter: Int32 = 100; // Limit to prevent file bloat

    // Get the full path for a character's chat file
    private func GetChatFilePath(characterName: String) -> String {
        return s"chat_\(characterName).json";
    }

    // Save a single message to a character's history
    public func SaveMessage(characterName: String, fromPlayer: Bool, text: String, isLiveMode: Bool) {
        // DON'T SAVE EMPTY MESSAGES - SAFETY CHECK
        if StrLen(text) == 0 || Equals(text, "\\") {
            ConsoleLog(s"[ChatStorage] Refusing to save empty/corrupted message for \(characterName)");
            return;
        }
        
        // NEW: Strip all double quotes from the text before saving
        let cleanedText = StrReplace(text, "\"", "");
        
        let history = this.GetOrCreateHistory(characterName);
        
        // REMOVED: All timestamp and day logic
        
        let message = ChatMessage.Create(fromPlayer, cleanedText, isLiveMode);
        ArrayPush(history.messages, message);
        
        this.SaveHistoryToFile(history);
        ConsoleLog(s"Saved message for \(characterName): '\(cleanedText)'");
    }

    // Load chat history for a specific character
    public func LoadChatHistory(characterName: String) -> array<ref<ChatMessage>> {
        let history = this.GetOrCreateHistory(characterName);
        ConsoleLog(s"Loaded \(ArraySize(history.messages)) messages for \(characterName)");
        return history.messages;
    }


    // Clear chat history for a specific character
    public func ClearChatHistory(characterName: String) {
        let history = this.GetOrCreateHistory(characterName);
        ArrayClear(history.messages);
        this.SaveHistoryToFile(history);
        ConsoleLog(s"Cleared chat history for \(characterName)");
    }


    // Remove the last N messages from chat history
    public func RemoveLastMessages(characterName: String, count: Int32) {
        if count <= 0 {
            return;
        }
        
        let history = this.GetOrCreateHistory(characterName);
        
        let messagesToRemove = Min(count, ArraySize(history.messages));
        let i = 0;
        while i < messagesToRemove {
            ArrayPop(history.messages);
            i += 1;
        }
        
        this.SaveHistoryToFile(history);
        ConsoleLog(s"Removed last \(messagesToRemove) messages for \(characterName)");
    }



    // Get or create a character's history
    private func GetOrCreateHistory(characterName: String) -> ref<CharacterChatHistory> {
        let i = 0;
        while i < ArraySize(this.chatHistories) {
            if Equals(this.chatHistories[i].characterName, characterName) {
                // Guard: only load from file once. If we returned this entry before
                // it was fully loaded, a stale save would have wiped the file.
                if !this.chatHistories[i].isLoaded {
                    this.LoadHistoryFromFile(this.chatHistories[i]);
                    this.chatHistories[i].isLoaded = true;
                }
                return this.chatHistories[i];
            }
            i += 1;
        }
        
        // Load from file BEFORE pushing to the array so there is never a window
        // where an empty history exists in chatHistories and could be saved over
        // a real file.
        let newHistory = CharacterChatHistory.Create(characterName);
        this.LoadHistoryFromFile(newHistory);
        newHistory.isLoaded = true;
        ArrayPush(this.chatHistories, newHistory);
        return newHistory;
    }

    // Save history to file using JSON format
    private func SaveHistoryToFile(history: ref<CharacterChatHistory>) {
        let json = this.SerializeHistory(history);
        let filePath = this.GetChatFilePath(history.characterName);
        
        // Use CET's file writing capability
        let success = this.WriteJsonFile(filePath, json);
        if success {
            ConsoleLog(s"Successfully saved chat to file: \(filePath)");
        } else {
            ConsoleLog(s"Failed to save chat to file: \(filePath)");
        }
    }

    // Load history from file
    private func LoadHistoryFromFile(history: ref<CharacterChatHistory>) {
        let filePath = this.GetChatFilePath(history.characterName);
        let json = this.ReadJsonFile(filePath);
        
        if StrLen(json) > 0 {
            this.DeserializeHistory(history, json);
            ConsoleLog(s"Loaded chat history from file: \(filePath)");
        }
    }

    // Load all character chats on system initialization
    private func LoadAllChats() {
        ConsoleLog("Loading all saved chats...");
        // Note: This would require directory listing which isn't directly available
        // Instead, we'll load on-demand when a character is selected
    }

    // Serialize chat history to JSON string (NO TIMESTAMPS)
    private func SerializeHistory(history: ref<CharacterChatHistory>) -> String {
        let json = "{\"character\":\"" + history.characterName + "\",\"messages\":[";
        let i = 0;
        while i < ArraySize(history.messages) {
            let msg = history.messages[i];
            if i > 0 {
                json += ",";
            }
            json += "    {\n";
            json += "      \"fromPlayer\": " + (msg.fromPlayer ? "true" : "false") + ",\n";
            json += "      \"text\": \"" + this.EscapeJsonString(msg.text) + "\",\n";
            // REMOVED: timestamp line
            json += "      \"isLiveMode\": " + (msg.isLiveMode ? "true" : "false") + "\n";
            json += "    }";
            i += 1;
        }
        json += "\n  ]\n}";
        return json;
    }

    // Deserialize JSON string to chat history
    private func DeserializeHistory(history: ref<CharacterChatHistory>, json: String) {
        ArrayClear(history.messages);
        
        // Simple JSON parsing (this is a simplified version)
        // In production, you'd want more robust JSON parsing
        let messagesStart = StrFindFirst(json, "\"messages\":[") + 12;
        let messagesEnd = StrFindLast(json, "]");
        
        if messagesStart > 12 && messagesEnd > messagesStart {
            let messagesJson = StrMid(json, messagesStart, messagesEnd - messagesStart);
            this.ParseMessages(history, messagesJson);
        }
    }

    // Parse individual messages from JSON
    private func ParseMessages(history: ref<CharacterChatHistory>, messagesJson: String) {
        // Split by message objects
        let currentPos = 0;
        let depth = 0;
        let messageStart = -1;
        
        let i = 0;
        while i < StrLen(messagesJson) {
            let char = StrMid(messagesJson, i, 1);
            
            if Equals(char, "{") {
                if depth == 0 {
                    messageStart = i;
                }
                depth += 1;
            } else if Equals(char, "}") {
                depth -= 1;
                if depth == 0 && messageStart >= 0 {
                    let messageJson = StrMid(messagesJson, messageStart, i - messageStart + 1);
                    this.ParseSingleMessage(history, messageJson);
                    messageStart = -1;
                }
            }
            i += 1;
        }
    }

    // Parse a single message JSON object (NO TIMESTAMPS)
    private func ParseSingleMessage(history: ref<CharacterChatHistory>, messageJson: String) {
        let fromPlayer = StrContains(messageJson, "\"fromPlayer\":true");
        let text = this.ExtractJsonValue(messageJson, "text");
        // REMOVED: timestamp and day extraction

        // Handle both old and new field names
        let isLiveMode = false;
        if StrContains(messageJson, "\"isLiveMode\":true") {
            isLiveMode = true;
        } else if StrContains(messageJson, "\"wasLiveMode\":true") {
            isLiveMode = true;
        }
        
        let message = ChatMessage.Create(fromPlayer, text, isLiveMode);
        ArrayPush(history.messages, message);
    }

    // Extract value from JSON key
    private func ExtractJsonValue(json: String, key: String) -> String {
        let searchStr = s"\"\(key)\":\"";
        let startPos = StrFindFirst(json, searchStr);
        if startPos < 0 {
            return "";
        }
        
        startPos += StrLen(searchStr);
        
        // Find closing quote, skipping escaped quotes
        let i = startPos;
        let escapeNext = false;
        let endPos = -1;
        
        while i < StrLen(json) {
            let char = StrMid(json, i, 1);
            
            if escapeNext {
                // This character is escaped, skip it
                escapeNext = false;
            } else if Equals(char, "\\") {
                // Next character will be escaped
                escapeNext = true;
            } else if Equals(char, "\"") {
                // Found unescaped closing quote
                endPos = i;
                break;
            }
            
            i += 1;
        }
        
        if endPos < 0 {
            ConsoleLog(s"[ExtractJsonValue] Could not find closing quote for key: \(key)");
            return "";
        }
        
        let extracted = StrMid(json, startPos, endPos - startPos);
        return this.UnescapeJsonString(extracted);
    }

    // Escape special characters for JSON
    private func UnescapeJsonString(str: String) -> String {
        let result = "";
        let i = 0;
        
        while i < StrLen(str) {
            let char = StrMid(str, i, 1);
            
            // Check if this is an escape sequence
            if Equals(char, "\\") && i + 1 < StrLen(str) {
                let nextChar = StrMid(str, i + 1, 1);
                
                if Equals(nextChar, "\\") {
                    result += "\\";
                    i += 2; // Skip both backslashes
                } else if Equals(nextChar, "\"") {
                    result += "\"";
                    i += 2; // Skip backslash and quote
                } else if Equals(nextChar, "n") {
                    result += "\n";
                    i += 2;
                } else if Equals(nextChar, "r") {
                    result += "\r";
                    i += 2;
                } else if Equals(nextChar, "t") {
                    result += "\t";
                    i += 2;
                } else {
                    // Unknown escape sequence, keep the backslash
                    result += char;
                    i += 1;
                }
            } else {
                // Normal character
                result += char;
                i += 1;
            }
        }
        
        return result;
    }

    private func EscapeJsonString(str: String) -> String {
        let result = "";
        let i = 0;

        while i < StrLen(str) {
            let char = StrMid(str, i, 1);
            
            if Equals(char, "\\") {
                result += "\\\\";
            } else if Equals(char, "\"") {
                result += "\\\"";
            } else if Equals(char, "\n") {
                result += "\\n";
            } else if Equals(char, "\r") {
                result += "\\r";
            } else if Equals(char, "\t") {
                result += "\\t";
            } else {
                result += char;
            }
            
            i += 1;
        }
        
        return result;
    }

    // File I/O functions (using CET's file system)
    private func WriteJsonFile(filePath: String, content: String) -> Bool {
        // CET file writing through native calls
        // For now, just log - CET will override this
        ConsoleLog(s"Attempting to write file: \(filePath)");
        return true;
    }

    private func ReadJsonFile(filePath: String) -> String {
        // CET file reading through native calls
        // For now, just return empty - CET will override this
        ConsoleLog(s"Attempting to read file: \(filePath)");
        return "";
    }

    // REMOVED: GetCurrentTimestamp function (no longer needed)
    
    // REMOVED: SplitString function (no longer needed)
    
    // REMOVED: IsTimeEarlier function (no longer needed)

    // Get character display name for file naming
    public func GetCharacterFileName(character: CharacterSetting) -> String {
        return GetCharacterContactName(character);
    }

    public func HasLoadedChatHistory(characterName: String) -> Bool {
        let i = 0;
        while i < ArraySize(this.chatHistories) {
            if Equals(this.chatHistories[i].characterName, characterName) {
                return ArraySize(this.chatHistories[i].messages) > 0;
            }
            i += 1;
        }
        return false;
    }

    public func GetGroupChatFileName(char1: CharacterSetting, char2: CharacterSetting) -> String {
        return s"group_\(GetCharacterContactName(char1))_\(GetCharacterContactName(char2))";
    }

}


