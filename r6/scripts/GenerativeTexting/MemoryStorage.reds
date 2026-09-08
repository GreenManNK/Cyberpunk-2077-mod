import Codeware.*

public class MemoryFormatter {
    
    // Simple pass-through - let Lua handle the AI summarization
    public static func FormatMemorySummary(vMessages: array<String>, npcResponses: array<String>, characterName: String) -> String {
        // Build the conversation text for Lua to summarize
        let conversationText = "";
        let i = 0;
        while i < ArraySize(vMessages) {
            conversationText += "V: " + vMessages[i] + "\n";
            if i < ArraySize(npcResponses) && StrLen(npcResponses[i]) > 0 {
                conversationText += characterName + ": " + npcResponses[i] + "\n\n";
            }
            i += 1;
        }
        
        return conversationText;
    }
}

public class MemoryStorage extends ScriptableSystem {
    private let maxMemories: Int32 = 30;
    private let saveDirectory: String = "chats";
    private let lastProcessedMessages: array<Int32>;
    private let lastProcessedNames: array<String>;
    private let lastReplacedMemory: array<String>; // Character names
    private let lastReplacedIndex: array<Int32>;   // Memory numbers

    public func SaveMemory(characterName: String, vMessages: array<String>, npcResponses: array<String>) {
      
        let totalMessages = ArraySize(vMessages);
        
        if totalMessages == 0 {
            ConsoleLog("[Memory] No messages to summarize");
            return;
        }
        
        // Get last 10 exchanges
        let startIndex = totalMessages > 10 ? totalMessages - 10 : 0;
        let endIndex = totalMessages;
        
        ConsoleLog(s"[Memory] Processing messages from index \(startIndex) to \(endIndex)");
        
        // Build conversation text from last 10 exchanges
        let conversationText = "";
        let i = startIndex;
        
        while i < endIndex {
            conversationText += "V: " + vMessages[i] + "\n";
            if i < ArraySize(npcResponses) && StrLen(npcResponses[i]) > 0 {
                conversationText += characterName + ": " + npcResponses[i] + "\n\n";
            }
            i += 1;
        }
        
        // Always trigger memory creation
        GetHttpRequestSystem().CreateMemorySummary(characterName, conversationText);
    }

    public func SaveMemorySummary(characterName: String, summary: String) {
        ConsoleLog("[Memory] === Starting SaveMemorySummary ===");
    
        // Load existing file content
        let existingJson = this.ReadJsonFile(s"memory_\(characterName).json");
        ConsoleLog(s"[Memory] Loaded existing JSON length: \(StrLen(existingJson))");
        
        // Clean the new summary
        let cleanSummary = this.CleanSummaryText(summary);
        ConsoleLog(s"[Memory] Cleaned summary preview: \(StrLeft(cleanSummary, 80))...");

        // Convert to NPC perspective
        let npcPerspective = this.ConvertToNPCPerspective(cleanSummary, characterName);
        
        // Count existing memories
        let memoryCount = this.CountExistingMemories(existingJson);
        
        // Calculate next memory number with proper wrapping
        let newMemoryNum = 1;
        
        if memoryCount == 0 {
            // First memory ever
            newMemoryNum = 1;
            ConsoleLog(s"[Memory] Creating first memory for \(characterName)");
        } else if memoryCount < this.maxMemories {
            // Still adding new memories (haven't reached max yet)
            let highestMemoryNum = this.FindHighestMemoryNumber(existingJson);
            newMemoryNum = highestMemoryNum + 1;
            ConsoleLog(s"[Memory] Creating Memory\(newMemoryNum) (total: \(memoryCount + 1)/\(this.maxMemories))");
        } else {
            // We've reached max - wrap around and replace oldest
            // Get last replaced memory for this character
            let lastReplaced = this.GetLastReplacedMemory(characterName);
            
            if lastReplaced == 0 {
                // First time wrapping - start at 1
                newMemoryNum = 1;
            } else {
                // Continue from last replaced
                newMemoryNum = (lastReplaced % this.maxMemories) + 1;
            }
            
            ConsoleLog(s"[Memory] Max memories reached, replacing Memory\(newMemoryNum) (last was \(lastReplaced))");
            
            // Store this as the last replaced memory
            this.SetLastReplacedMemory(characterName, newMemoryNum);
        }
        
        // Build the new memory object
        let bulletPoints: array<String>;
        this.ParseBulletPoints(npcPerspective, bulletPoints);
        ConsoleLog(s"[Memory] Parsed \(ArraySize(bulletPoints)) bullet points");
        
        let newMemoryJson = "  {\n";
        newMemoryJson += s"    \"Memory\(newMemoryNum)\": \"" + characterName + "\",\n";
        
        let j = 0;
        while j < ArraySize(bulletPoints) {
            let pointNum = j + 1;
            newMemoryJson += s"    \"\(pointNum)\": \"" + this.EscapeJsonString(bulletPoints[j]) + "\"";
            
            if j < ArraySize(bulletPoints) - 1 {
                newMemoryJson += ",";
            }
            newMemoryJson += "\n";
            j += 1;
        }
        
        newMemoryJson += "  }";
        
        ConsoleLog(s"[Memory] New memory object preview: \(StrLeft(newMemoryJson, 100))...");
        
        // Build final JSON
        let finalJson = "";
        
        if memoryCount == 0 {
            // First memory - create new array
            ConsoleLog("[Memory] First memory - creating new array");
            finalJson = "[\n" + newMemoryJson + "\n]";
        } else if memoryCount >= this.maxMemories {
            // Replace existing memory
            ConsoleLog(s"[Memory] Replacing Memory\(newMemoryNum)");
            finalJson = this.ReplaceMemoryInJson(existingJson, newMemoryJson, newMemoryNum);
        } else {
            // Append to existing array
            ConsoleLog("[Memory] Appending to existing array");

            // Remove the closing ] from existing JSON
            let trimmed = existingJson;
            let lastBracket = StrFindLast(trimmed, "]");
            ConsoleLog(s"[Memory] Last bracket found at position: \(lastBracket)");
            
            if lastBracket > 0 {
                trimmed = StrLeft(trimmed, lastBracket);
            }
            
            // Add comma and new memory
            finalJson = trimmed + ",\n" + newMemoryJson + "\n]";
        }
        
        ConsoleLog(s"[Memory] Final JSON length: \(StrLen(finalJson))");
        ConsoleLog(s"[Memory] Final JSON preview (first 200 chars): \(StrLeft(finalJson, 200))...");
        
        this.WriteJsonFile(s"memory_\(characterName).json", finalJson);
        ConsoleLog(s"[Memory] ✓ Saved Memory\(newMemoryNum) for \(characterName)");
        ConsoleLog("[Memory] === SaveMemorySummary Complete ===");
    }
    
    public func ParseMemoriesFromJson(json: String) -> array<String> {
        let memories: array<String>;
        
        if StrLen(json) == 0 {
            return memories;
        }
        
        // Find all memory objects in the JSON
        let currentPos = 0;
        let depth = 0;
        let memoryStart = -1;
        
        let i = 0;
        while i < StrLen(json) {
            let char = StrMid(json, i, 1);
            
            if Equals(char, "{") {
                if depth == 0 {
                    memoryStart = i;
                }
                depth += 1;
            } else if Equals(char, "}") {
                depth -= 1;
                if depth == 0 && memoryStart >= 0 {
                    let memoryJson = StrMid(json, memoryStart, i - memoryStart + 1);
                    let reconstructed = this.ReconstructMemoryText(memoryJson);
                    if StrLen(reconstructed) > 0 {
                        ArrayPush(memories, reconstructed);
                    }
                    memoryStart = -1;
                }
            }
            i += 1;
        }
        
        return memories;
    }
    
    private func ReconstructMemoryText(memoryJson: String) -> String {
        return memoryJson;
    }

    private func ReplaceMemoryInJson(json: String, newMemory: String, memoryNum: Int32) -> String {
        // Find and replace the specific memory object
        let searchKey = s"\"Memory\(memoryNum)\"";
        let startPos = StrFindFirst(json, searchKey);
        
        if startPos < 0 {
            // Memory not found, just append
            let trimmed = json;
            let lastBracket = StrFindLast(trimmed, "]");
            if lastBracket > 0 {
                trimmed = StrLeft(trimmed, lastBracket);
            }
            return trimmed + ",\n" + newMemory + "\n]";
        }
        
        // Find the start of this memory object
        let objStart = startPos;
        while objStart > 0 && !Equals(StrMid(json, objStart, 1), "{") {
            objStart -= 1;
        }
        
        // Find the end of this memory object
        let depth = 0;
        let objEnd = objStart;
        let i = objStart;
        while i < StrLen(json) {
            let char = StrMid(json, i, 1);
            if Equals(char, "{") {
                depth += 1;
            } else if Equals(char, "}") {
                depth -= 1;
                if depth == 0 {
                    objEnd = i;
                    break;
                }
            }
            i += 1;
        }
        
        // Replace the old memory with the new one
        let before = StrLeft(json, objStart);
        let after = StrRight(json, StrLen(json) - objEnd - 1);
        
        return before + newMemory + after;
    }
    
    private func CountExistingMemories(json: String) -> Int32 {
        if StrLen(json) == 0 {
            ConsoleLog("[Memory] Empty JSON, count = 0");
            return 0;
        }
        
        let count = 0;
        let searchStr = "\"Memory";
        let searchPos = 0;
        
        while searchPos < StrLen(json) {
            let foundPos = StrFindFirst(StrRight(json, StrLen(json) - searchPos), searchStr);
            
            if foundPos < 0 {
                break;
            }
            
            count += 1;
            searchPos = searchPos + foundPos + StrLen(searchStr);
        }
        
        ConsoleLog(s"[Memory] Found \(count) existing memories in JSON");
        return count;
    }

    private func FindHighestMemoryNumber(json: String) -> Int32 {
        if StrLen(json) == 0 {
            return 0;
        }
        
        let highestNum = 0;
        let searchStr = "\"Memory";
        let searchPos = 0;
        
        while searchPos < StrLen(json) {
            let foundPos = StrFindFirst(StrRight(json, StrLen(json) - searchPos), searchStr);
            
            if foundPos < 0 {
                break;
            }
            
            // Move to the position after "Memory"
            let actualPos = searchPos + foundPos + StrLen(searchStr);
            
            // Extract the number after "Memory"
            let numStr = "";
            let i = actualPos;
            while i < StrLen(json) && this.IsDigit(StrMid(json, i, 1)) {
                numStr += StrMid(json, i, 1);
                i += 1;
            }
            
            if StrLen(numStr) > 0 {
                let memoryNum = StringToInt(numStr);
                if memoryNum > highestNum {
                    highestNum = memoryNum;
                }
            }
            
            searchPos = actualPos;
        }
        
        ConsoleLog(s"[Memory] Highest existing memory number: \(highestNum)");
        return highestNum;
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
    
    private func ParseBulletPoints(text: String, out bulletPoints: array<String>) {
        ArrayClear(bulletPoints);
        
        let lines: array<String>;
        this.SplitByNewline(text, lines);
        
        let i = 0;
        while i < ArraySize(lines) {
            let line = lines[i];
            
            // Trim whitespace
            while StrBeginsWith(line, " ") || StrBeginsWith(line, "\t") {
                line = StrRight(line, StrLen(line) - 1);
            }
            
            // Check if it starts with a bullet point marker
            if StrLen(line) > 2 {
                let firstChar = StrLeft(line, 1);
                let secondChar = StrMid(line, 1, 1);
                
                // Remove bullet markers: "* ", "- ", "1. ", "2. ", etc.
                if (Equals(firstChar, "*") || Equals(firstChar, "-")) && Equals(secondChar, " ") {
                    line = StrRight(line, StrLen(line) - 2);
                    ArrayPush(bulletPoints, line);
                } else if this.IsDigit(firstChar) {
                    // Handle "1. " or "1 "
                    let trimStart = 2;
                    if Equals(StrMid(line, 2, 1), " ") {
                        trimStart = 3;
                    }
                    line = StrRight(line, StrLen(line) - trimStart);
                    ArrayPush(bulletPoints, line);
                } else if StrLen(line) > 0 {
                    // No bullet marker, just add as-is if not empty
                    ArrayPush(bulletPoints, line);
                }
            }
            
            i += 1;
        }
    }
    
    private func SplitByNewline(text: String, out lines: array<String>) {
        ArrayClear(lines);
        let remaining = text;
        
        while StrLen(remaining) > 0 {
            let newlinePos = StrFindFirst(remaining, "\n");
            
            if newlinePos < 0 {
                if StrLen(remaining) > 0 {
                    ArrayPush(lines, remaining);
                }
                break;
            }
            
            let line = StrLeft(remaining, newlinePos);
            if StrLen(line) > 0 {
                ArrayPush(lines, line);
            }
            remaining = StrRight(remaining, StrLen(remaining) - newlinePos - 1);
        }
    }
    
    private func IsDigit(char: String) -> Bool {
        return Equals(char, "0") || Equals(char, "1") || Equals(char, "2") || 
               Equals(char, "3") || Equals(char, "4") || Equals(char, "5") || 
               Equals(char, "6") || Equals(char, "7") || Equals(char, "8") || 
               Equals(char, "9");
    }

    private func CleanSummaryText(text: String) -> String {
        let cleaned = text;
        
        // Remove common AI preambles
        if StrBeginsWith(cleaned, "Here's a 5-bullet point summary of the conversation:") {
            cleaned = StrRight(cleaned, StrLen(cleaned) - 52);
        }
        if StrBeginsWith(cleaned, "Here's a 5-bullet point summary:") {
            cleaned = StrRight(cleaned, StrLen(cleaned) - 32);
        }
        if StrBeginsWith(cleaned, "Here is a 5-bullet point summary:") {
            cleaned = StrRight(cleaned, StrLen(cleaned) - 33);
        }
        if StrBeginsWith(cleaned, "Summary:") {
            cleaned = StrRight(cleaned, StrLen(cleaned) - 8);
        }
        
        // Trim whitespace
        while StrBeginsWith(cleaned, " ") || StrBeginsWith(cleaned, "\n") || StrBeginsWith(cleaned, "\r") {
            cleaned = StrRight(cleaned, StrLen(cleaned) - 1);
        }
        while StrEndsWith(cleaned, " ") || StrEndsWith(cleaned, "\n") || StrEndsWith(cleaned, "\r") {
            cleaned = StrLeft(cleaned, StrLen(cleaned) - 1);
        }
        
        return cleaned;
    }

    private func ConvertToNPCPerspective(text: String, characterName: String) -> String {
        let result = text;
        
        // Replace "V and [NPC]" with "Me and V" or "V and me"
        result = StrReplace(result, "V and " + characterName, "Me and V");
        result = StrReplace(result, characterName + " and V", "V and me");
        
        // Replace character name with "I" at start of sentences
        result = StrReplace(result, " " + characterName + " ", " I ");
        result = StrReplace(result, characterName + " ", "I ");
        
        // Replace "they" with "we" 
        result = StrReplace(result, " they ", " we ");
        result = StrReplace(result, " They ", " We ");
        
        // Replace "their" with "our"
        result = StrReplace(result, " their ", " our ");
        result = StrReplace(result, " Their ", " Our ");
        
        // Replace "them" with "us"
        result = StrReplace(result, " them", " us");
        
        return result;
    }

    public func LoadMemories(characterName: String) -> array<String> {
        let memories: array<String>;
        return memories;
    }

    public func WriteJsonFile(filePath: String, content: String) -> Bool {
        ConsoleLog(s"[Memory] Writing file: \(filePath)");
        return true;
    }

    public func ReadJsonFile(filePath: String) -> String {
        return "";
    }
    
    private func GetLastReplacedMemory(characterName: String) -> Int32 {
        let i = 0;
        while i < ArraySize(this.lastReplacedMemory) {
            if Equals(this.lastReplacedMemory[i], characterName) {
                return this.lastReplacedIndex[i];
            }
            i += 1;
        }
        return 0; // Not found - first time wrapping
    }

    private func SetLastReplacedMemory(characterName: String, memoryNum: Int32) {
        // Check if character already exists
        let i = 0;
        let found = false;
        while i < ArraySize(this.lastReplacedMemory) {
            if Equals(this.lastReplacedMemory[i], characterName) {
                this.lastReplacedIndex[i] = memoryNum;
                found = true;
                break;
            }
            i += 1;
        }
        
        // If not found, add new entry
        if !found {
            ArrayPush(this.lastReplacedMemory, characterName);
            ArrayPush(this.lastReplacedIndex, memoryNum);
        }
    }
}

public static func GetMemoryStorage() -> ref<MemoryStorage> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"MemoryStorage") as MemoryStorage;
}