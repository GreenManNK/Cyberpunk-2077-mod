module NightCityAllies.Localization

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.UI.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.Hooks.*

// 
// Localization / Translations
//

public class NCALabels extends ScriptableSystem {
    public func T(key: CName) -> String {
      let value = GetLocalizedTextByKey(key);
      if Equals(value, "") {
        return NameToString(key);
      };
      return value;
    }

    // For Lua
    public func TranslateFromString(text: String) -> String {
      return this.T(StringToName(text));
    }

	public func Stop() -> String = this.T(n"Stop") // unused atm
	public func Greet() -> String = this.T(n"Greet")
	public func Social() -> String = this.T(n"Social") // unused atm
	public func Follow() -> String = this.T(n"Follow")
	public func Gear() -> String = this.T(n"Gear")
	public func Wait_here() -> String = this.T(n"Wait here")
	public func Equip_primary() -> String = this.T(n"Equip primary")
	public func Equip_secondary() -> String = this.T(n"Equip secondary")
	public func Stow_weapon() -> String = this.T(n"Stow weapon")
	public func Return_weapon() -> String = this.T(n"Return weapon") // unused atm
	public func Give_weapon() -> String = this.T(n"Give weapon") // unused atm
	public func Outfit() -> String = this.T(n"Outfit")
	public func Outfits() -> String = this.T(n"Outfits")
	public func Send_away() -> String = this.T(n"Send away")
	public func Call_someone() -> String = this.T(n"Call someone")
	public func Previous_page() -> String = this.T(n"Previous page")
	public func Next_page() -> String = this.T(n"Next page")
	public func Return_all() -> String = this.T(n"Return all")
	public func Weapon() -> String = this.T(n"Weapon") // unused atm

	public func Friendship() -> String = this.T(n"Friendship")
	public func Love() -> String = this.T(n"Love")
	public func Faction() -> String = this.T(n"Faction")
	public func Archetype() -> String = this.T(n"Archetype")
	public func Type() -> String = this.T(n"Type")
	public func Rarity() -> String = this.T(n"Rarity")
	public func Power_level() -> String = this.T(n"Power level")
	public func Squad() -> String = this.T(n"Squad")
	public func Interact() -> String = this.T(n"Interact")

	public func Stranger() -> String = this.T(n"Stranger")
	public func Acquaintance() -> String = this.T(n"Acquaintance")
	public func Buddy() -> String = this.T(n"Buddy")
	public func Friend() -> String = this.T(n"Friend")
	public func Best_friend() -> String = this.T(n"Best friend")

	public func Indifferent() -> String = this.T(n"Indifferent")
	public func Curious() -> String = this.T(n"Curious")
	public func Attracted() -> String = this.T(n"Attracted")
	public func In_love() -> String = this.T(n"In love")
	public func Devoted() -> String = this.T(n"Devoted")

	public func Join_me() -> String = this.T(n"Join me")
	public func Stay_here() -> String = this.T(n"Stay here")
	public func Hire() -> String = this.T(n"Hire")
	public func Deny() -> String = this.T(n"Deny") // unused atm
	public func Equip() -> String = this.T(n"Equip") // unused atm
	public func Appearance() -> String = this.T(n"Appearance")
	public func Wardrobe() -> String = this.T(n"Wardrobe")
	public func Select_category() -> String = this.T(n"Select category")
	public func More() -> String = this.T(n"More ...") // unused atm

	public func Casual() -> String = this.T(n"Casual")
	public func Mission() -> String = this.T(n"Mission")
	public func Home() -> String = this.T(n"Home")
	public func Bed() -> String = this.T(n"Bed")
	public func Shower() -> String = this.T(n"Shower")

	public func Night_city_allies() -> String = this.T(n"Night City Allies")
	public func Unknown() -> String = this.T(n"UNKNOWN")
	public func Nobody_on_standby() -> String = this.T(n"Looks like nobody is on standby at this time.")
	public func Thank_you_for_your_business() -> String = this.T(n"Thank you for using our services.")
}