@addMethod(JournalManager)
public final func GetNumberUnreadMessages() -> Int32 {
    let context: JournalRequestContext;
    context.stateFilter.active = true;
    let contacts: array<wref<JournalEntry>>;
    let messages: array<wref<JournalEntry>>;
    let choiceEntries: array<wref<JournalEntry>>;

    let unreadMessagesCount: Int32;
    unreadMessagesCount = 0;

    this.GetContacts(context, contacts);

    for contact in contacts {
        this.GetFlattenedMessagesAndChoices(contact, messages, choiceEntries);
        for message in messages {
            if (!this.IsEntryVisited(message)) {
                unreadMessagesCount += 1;
            }
        }
    }

    return unreadMessagesCount;
}