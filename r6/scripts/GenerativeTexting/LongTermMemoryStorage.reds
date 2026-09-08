import Codeware.*

// ============================================================
// LONG TERM MEMORY STORAGE
// Maintains a single character_memories.json file containing
// anchor memories (player-written, never overwritten) and
// long term memories (AI-maintained, max 30 per NPC).
// ============================================================

public class LongTermMemoryStorage extends ScriptableSystem {

    private let maxLongTermEntries: Int32 = 30;

    // --------------------------------------------------------
    // PUBLIC: Load anchor memories for a character
    // These are player-written and injected first into prompt
    // --------------------------------------------------------
    public func GetAnchorMemories(characterName: String) -> String {
        let json = this.ReadJsonFile("character_memories.json");
        if StrLen(json) == 0 {
            return "";
        }
        return this.ExtractSection(json, StrLower(characterName), "anchors");
    }

    // --------------------------------------------------------
    // PUBLIC: Load long term memories for a character
    // These are AI-maintained, max 30 entries
    // --------------------------------------------------------
    public func GetLongTermMemories(characterName: String) -> String {
        let json = this.ReadJsonFile("character_memories.json");
        if StrLen(json) == 0 {
            return "";
        }
        return this.ExtractSection(json, StrLower(characterName), "longterm");
    }

    // --------------------------------------------------------
    // PUBLIC: Called after memory snapshot trigger
    // Scans last 20 exchanges and updates long term memories
    // --------------------------------------------------------
    public func UpdateLongTermMemory(characterName: String, vMessages: array<String>, npcResponses: array<String>) {

        // Build conversation text from last 20 exchanges
        let totalMessages = ArraySize(vMessages);
        let startIndex = totalMessages > 20 ? totalMessages - 20 : 0;
        let conversationText = "";
        let i = startIndex;

        while i < totalMessages {
            conversationText += "V: " + vMessages[i] + "\n";
            if i < ArraySize(npcResponses) && StrLen(npcResponses[i]) > 0 {
                conversationText += characterName + ": " + npcResponses[i] + "\n\n";
            }
            i += 1;
        }

        if StrLen(conversationText) == 0 {
            ConsoleLog("[LongTerm] No conversation to scan");
            return;
        }

        ConsoleLog(s"[LongTerm] Scanning \(ArraySize(vMessages)) exchanges for \(characterName)");
        ConsoleLog(s"[LongTerm] Conversation length: \(StrLen(conversationText)) chars");


        let existing = this.GetLongTermMemories(characterName);

        ConsoleLog(s"[LongTerm] Existing memories length: \(StrLen(existing))");

        // Build the scanning prompt
        let prompt = "You are updating a long term memory file for " + characterName + " in a Cyberpunk 2077 roleplay.\n\n";

        if StrLen(existing) > 0 {
            prompt += "EXISTING LONG TERM MEMORIES:\n" + existing + "\n\n";
        }

        prompt += "STRICT RULES - scan the conversation and:\n";
        prompt += "- REPLACE any existing memory that the conversation directly contradicts\n";
        prompt += "- SKIP anything already recorded or similar to existing memories\n";
        prompt += "- SKIP casual small talk, greetings, jokes, banter and anything with no lasting consequence\n";
        prompt += "- RECORD ONLY: important plot points, significant story events, relationship status changes, emotional breakthroughs or confessions, major decisions made, things V or the NPC revealed that permanently change the dynamic\n";
        prompt += "- Summarize each entry in one clean, complete sentence. Never cut off mid-sentence.\n";
        prompt += "- Maximum 3 new entries per scan\n";
        prompt += "- If nothing is worth recording, output the existing list unchanged\n";
        prompt += "- Output ONLY a bullet point list. No preamble. No explanation.\n\n";
        prompt += "CONVERSATION:\n" + conversationText;

        // Fire silently via existing infrastructure
        ConsoleLog(s"[LongTerm] Firing silent request for \(characterName)");
        GetHttpRequestSystem().CreateLongTermMemorySummary(characterName, prompt);
    }

    // --------------------------------------------------------
    // PUBLIC: Called when AI returns updated memory list
    // Saves it back to character_memories.json
    // --------------------------------------------------------
    public func SaveUpdatedLongTermMemories(characterName: String, updatedMemories: String) {

        // Clean and parse the bullet points
        let cleaned = this.CleanMemoryText(updatedMemories);
        let bullets: array<String>;
        this.ParseBulletPoints(cleaned, bullets);

        if ArraySize(bullets) == 0 {
            ConsoleLog("[LongTerm] No valid memories returned, skipping save");
            return;
        }

        // Load existing memories and merge with new ones
        let existingRaw = this.GetLongTermMemories(characterName);
        let existing: array<String>;
        if StrLen(existingRaw) > 0 {
            this.ParseBulletPoints(existingRaw, existing);
        }

        // Append new entries to existing
        let merged: array<String> = existing;
        let j = 0;
        while j < ArraySize(bullets) {
            ArrayPush(merged, bullets[j]);
            j += 1;
        }

        // Deduplicate - compare stripped versions, store clean entries
        let deduped: array<String>;
        let dedupedStripped: array<String>;
        let k = 0;
        while k < ArraySize(merged) {
            let entry = merged[k];
            let stripped = this.StripBulletPrefix(entry);
            if StrLen(stripped) > 0 {
                let found = false;
                let m = 0;
                while m < ArraySize(dedupedStripped) {
                    if Equals(stripped, dedupedStripped[m]) {
                        found = true;
                        break;
                    }
                    m += 1;
                }
                if !found {
                    ArrayPush(deduped, "• " + stripped);
                    ArrayPush(dedupedStripped, stripped);
                }
            }
            k += 1;
        }

        // Enforce 30 entry cap - keep most recent
        let trimmed: array<String>;
        let startIdx = ArraySize(deduped) > this.maxLongTermEntries ? ArraySize(deduped) - this.maxLongTermEntries : 0;
        let i = startIdx;
        while i < ArraySize(deduped) {
            ArrayPush(trimmed, deduped[i]);
            i += 1;
        }

        // Load full file, update just this character's longterm section, save
        let fullJson = this.ReadJsonFile("character_memories.json");
        let updatedJson = this.UpdateLongTermSection(fullJson, characterName, trimmed);
        this.WriteJsonFile("character_memories.json", updatedJson);

        ConsoleLog(s"[LongTerm] Saved \(ArraySize(trimmed)) long term memories for \(characterName)");
    }

    // --------------------------------------------------------
    // PRIVATE: Extract a section (anchors or longterm) for a character
    // --------------------------------------------------------
    private func ExtractSection(json: String, characterName: String, sectionName: String) -> String {
        // Find character block: "characterName": {
        let charKey = "\"" + characterName + "\"";
        let charPos = StrFindFirst(json, charKey);
        if charPos < 0 {
            return "";
        }

        // Find opening { of character object
        let blockStart = charPos + StrLen(charKey);
        while blockStart < StrLen(json) && !Equals(StrMid(json, blockStart, 1), "{") {
            blockStart += 1;
        }

        // Find closing } of character object (respecting nesting)
        let depth = 0;
        let blockEnd = blockStart;
        let i = blockStart;
        while i < StrLen(json) {
            let char = StrMid(json, i, 1);
            if Equals(char, "{") { depth += 1; }
            else if Equals(char, "}") {
                depth -= 1;
                if depth == 0 {
                    blockEnd = i;
                    break;
                }
            }
            i += 1;
        }

        let characterBlock = StrMid(json, blockStart, blockEnd - blockStart + 1);

        // Find the section within the character block
        let sectionKey = "\"" + sectionName + "\"";
        let sectionPos = StrFindFirst(characterBlock, sectionKey);
        if sectionPos < 0 {
            return "";
        }

        // Find opening [ of section array
        let arrStart = sectionPos + StrLen(sectionKey);
        while arrStart < StrLen(characterBlock) && !Equals(StrMid(characterBlock, arrStart, 1), "[") {
            arrStart += 1;
        }

        // Find closing ] of section array
        let arrDepth = 0;
        let arrEnd = arrStart;
        let j = arrStart;
        while j < StrLen(characterBlock) {
            let char = StrMid(characterBlock, j, 1);
            if Equals(char, "[") { arrDepth += 1; }
            else if Equals(char, "]") {
                arrDepth -= 1;
                if arrDepth == 0 {
                    arrEnd = j;
                    break;
                }
            }
            j += 1;
        }

        // Extract entries from array
        let arrayContent = StrMid(characterBlock, arrStart + 1, arrEnd - arrStart - 1);
        return this.ParseJsonStringArray(arrayContent);
    }

    // --------------------------------------------------------
    // PRIVATE: Parse a JSON string array into bullet points
    // --------------------------------------------------------
    private func ParseJsonStringArray(arrayContent: String) -> String {
        let result = "";
        let i = 0;
        let inString = false;
        let currentEntry = "";
        let escapeNext = false;

        while i < StrLen(arrayContent) {
            let char = StrMid(arrayContent, i, 1);

            if escapeNext {
                currentEntry += char;
                escapeNext = false;
            } else if Equals(char, "\\") && inString {
                escapeNext = true;
                currentEntry += char;
            } else if Equals(char, "\"") {
                if inString {
                    // End of string entry
                    if StrLen(currentEntry) > 0 {
                        let clean = currentEntry;
                        let si = 0;
                        while si < StrLen(clean) {
                            let c = StrMid(clean, si, 1);
                            if Equals(c, "•") || Equals(c, "-") || Equals(c, "*") || Equals(c, " ") {
                                si += 1;
                            } else {
                                clean = StrRight(clean, StrLen(clean) - si);
                                si = StrLen(clean) + 1;
                            }
                        }
                        if StrLen(clean) > 0 {
                            result += "• " + clean + "\n";
                        }
                        currentEntry = "";
                    }
                    inString = false;
                } else {
                    inString = true;
                }
            } else if inString {
                currentEntry += char;
            }
            i += 1;
        }

        return result;
    }

    // --------------------------------------------------------
    // PRIVATE: Update the longterm section for a character in the full JSON
    // --------------------------------------------------------
    private func UpdateLongTermSection(fullJson: String, characterName: String, entries: array<String>) -> String {

        // Build the new longterm array string
        let newLongTermArray = "[\n";
        let i = 0;
        while i < ArraySize(entries) {
            newLongTermArray += "        \"" + this.EscapeJsonString(entries[i]) + "\"";
            if i < ArraySize(entries) - 1 {
                newLongTermArray += ",";
            }
            newLongTermArray += "\n";
            i += 1;
        }
        newLongTermArray += "      ]";

        // Check if character already exists in JSON
        let charKey = "\"" + characterName + "\"";
        let charPos = StrFindFirst(fullJson, charKey);

        if charPos < 0 {
            // Character doesn't exist yet - add new entry
            return this.AddNewCharacterEntry(fullJson, characterName, newLongTermArray);
        }

        // Character exists - find and replace just the longterm array
        // Find character block start
        let blockStart = charPos + StrLen(charKey);
        while blockStart < StrLen(fullJson) && !Equals(StrMid(fullJson, blockStart, 1), "{") {
            blockStart += 1;
        }

        // Find longterm key within character block
        let longtermKey = "\"longterm\"";
        let searchFrom = blockStart;
        let longtermPos = StrFindFirst(StrRight(fullJson, StrLen(fullJson) - searchFrom), longtermKey);

        if longtermPos < 0 {
            // No longterm section yet - this shouldn't happen but handle gracefully
            return fullJson;
        }

        let actualLongtermPos = searchFrom + longtermPos + StrLen(longtermKey);

        // Find the opening [ of the longterm array
        let arrStart = actualLongtermPos;
        while arrStart < StrLen(fullJson) && !Equals(StrMid(fullJson, arrStart, 1), "[") {
            arrStart += 1;
        }

        // Find the closing ] of the longterm array
        let arrDepth = 0;
        let arrEnd = arrStart;
        let j = arrStart;
        while j < StrLen(fullJson) {
            let char = StrMid(fullJson, j, 1);
            if Equals(char, "[") { arrDepth += 1; }
            else if Equals(char, "]") {
                arrDepth -= 1;
                if arrDepth == 0 {
                    arrEnd = j;
                    break;
                }
            }
            j += 1;
        }

        // Replace old longterm array with new one
        let before = StrLeft(fullJson, arrStart);
        let after = StrRight(fullJson, StrLen(fullJson) - arrEnd - 1);
        return before + newLongTermArray + after;
    }

    // --------------------------------------------------------
    // PRIVATE: Add a new character entry to the JSON
    // --------------------------------------------------------
    private func AddNewCharacterEntry(fullJson: String, characterName: String, longTermArray: String) -> String {
        let newEntry = "    \"" + characterName + "\": {\n";
        newEntry += "      \"anchors\": [],\n";
        newEntry += "      \"longterm\": " + longTermArray + "\n";
        newEntry += "    }";

        // Find last } in memories object and insert before it
        let lastBrace = StrFindLast(fullJson, "}");
        let secondLastBrace = StrFindLast(StrLeft(fullJson, lastBrace), "}");

        if secondLastBrace < 0 {
            // Empty or malformed - create fresh
            return "{\n  \"memories\": {\n" + newEntry + "\n  }\n}";
        }

        let before = StrLeft(fullJson, secondLastBrace + 1);
        let after = StrRight(fullJson, StrLen(fullJson) - secondLastBrace - 1);
        return before + ",\n" + newEntry + after;
    }


    // Strip bullet prefix and leading/trailing whitespace from a memory entry
    private func StripBulletPrefix(entry: String) -> String {
        let s = entry;
        let going = true;
        while going && StrLen(s) > 0 {
            let c = StrLeft(s, 1);
            if Equals(c, " ") || Equals(c, "•") || Equals(c, "-") || Equals(c, "*") || Equals(c, "\t") {
                s = StrRight(s, StrLen(s) - 1);
            } else {
                going = false;
            }
        }
        going = true;
        while going && StrLen(s) > 0 {
            let c = StrRight(s, 1);
            if Equals(c, " ") || Equals(c, "\n") || Equals(c, "\r") || Equals(c, "\t") {
                s = StrLeft(s, StrLen(s) - 1);
            } else {
                going = false;
            }
        }
        return s;
    }

    // --------------------------------------------------------
    // PRIVATE: Utility functions
    // --------------------------------------------------------
    private func CleanMemoryText(text: String) -> String {
        let cleaned = text;
        while StrBeginsWith(cleaned, " ") || StrBeginsWith(cleaned, "\n") || StrBeginsWith(cleaned, "\r") {
            cleaned = StrRight(cleaned, StrLen(cleaned) - 1);
        }
        while StrEndsWith(cleaned, " ") || StrEndsWith(cleaned, "\n") || StrEndsWith(cleaned, "\r") {
            cleaned = StrLeft(cleaned, StrLen(cleaned) - 1);
        }
        return cleaned;
    }

    private func ParseBulletPoints(text: String, out bullets: array<String>) {
        ArrayClear(bullets);
        let lines: array<String>;
        this.SplitByNewline(text, lines);

        let i = 0;
        while i < ArraySize(lines) {
            let line = lines[i];
            // Trim leading whitespace
            while StrBeginsWith(line, " ") || StrBeginsWith(line, "\t") {
                line = StrRight(line, StrLen(line) - 1);
            }
            if StrLen(line) > 2 {
                let first = StrLeft(line, 1);
                let second = StrMid(line, 1, 1);
                if (Equals(first, "•") || Equals(first, "*") || Equals(first, "-")) && Equals(second, " ") {
                    ArrayPush(bullets, StrRight(line, StrLen(line) - 2));
                } else if this.IsDigit(first) {
                    let trimStart = Equals(StrMid(line, 2, 1), " ") ? 3 : 2;
                    ArrayPush(bullets, StrRight(line, StrLen(line) - trimStart));
                } else if StrLen(line) > 0 {
                    ArrayPush(bullets, line);
                }
            }
            i += 1;
        }
    }

    private func SplitByNewline(text: String, out lines: array<String>) {
        ArrayClear(lines);
        let remaining = text;
        while StrLen(remaining) > 0 {
            let pos = StrFindFirst(remaining, "\n");
            if pos < 0 {
                if StrLen(remaining) > 0 { ArrayPush(lines, remaining); }
                break;
            }
            let line = StrLeft(remaining, pos);
            if StrLen(line) > 0 { ArrayPush(lines, line); }
            remaining = StrRight(remaining, StrLen(remaining) - pos - 1);
        }
    }

    private func IsDigit(char: String) -> Bool {
        return Equals(char, "0") || Equals(char, "1") || Equals(char, "2") ||
               Equals(char, "3") || Equals(char, "4") || Equals(char, "5") ||
               Equals(char, "6") || Equals(char, "7") || Equals(char, "8") ||
               Equals(char, "9");
    }

    private func EscapeJsonString(str: String) -> String {
        let result = "";
        let i = 0;
        while i < StrLen(str) {
            let char = StrMid(str, i, 1);
            if Equals(char, "\\") { result += "\\\\"; }
            else if Equals(char, "\"") { result += "\\\""; }
            else if Equals(char, "\n") { result += "\\n"; }
            else if Equals(char, "\r") { result += "\\r"; }
            else if Equals(char, "\t") { result += "\\t"; }
            else { result += char; }
            i += 1;
        }
        return result;
    }

    // File I/O stubs - CET Lua handles actual reading/writing
    public func WriteJsonFile(filePath: String, content: String) -> Bool {
        ConsoleLog(s"[LongTerm] Writing: \(filePath)");
        return true;
    }

    public func ReadJsonFile(filePath: String) -> String {
        ConsoleLog(s"[LongTerm] Reading: \(filePath)");
        return "";
    }
}

public static func GetLongTermMemoryStorage() -> ref<LongTermMemoryStorage> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"LongTermMemoryStorage") as LongTermMemoryStorage;
}
