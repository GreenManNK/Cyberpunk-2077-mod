module PhoneExtension.DataStructures
import PhoneExtension.Classes.*
import PhoneExtension.System.*

/**
Use this data structure to define your custom messages...
...or ignore it and do something else - it's not directly used in any of the core methods.
**/

public struct CustomMessageEntry {
	public let text: String;
	public let type: MessageViewType; //Sent or Received
	public let quest: Bool;
}
