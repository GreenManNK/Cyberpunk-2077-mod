import AmmoLimiter.Localization.Packages.*
import Codeware.Localization.*

public class LocalizationProvider extends ModLocalizationProvider{
	public func GetPackage(language:CName) -> ref<ModLocalizationPackage>{
		switch language{
			case n"ar-ar":return new Arabic();
			case n"zh-cn":return new ChineseSimplified();
			case n"zh-tw":return new ChineseTraditional();
			case n"cs-cz":return new Czech();
			case n"en-us":return new English();
			case n"fr-fr":return new French();
			case n"de-de":return new German();
			case n"hu-hu":return new Hungarian();
			case n"it-it":return new Italian();
			case n"ja-jp":return new Japanese();
			case n"ko-kr":return new Korean();
			case n"pl-pl":return new Polish();
			case n"pt-br":return new PortugueseBrazil();
			case n"ru-ru":return new Russian();
			case n"es-es":return new Spanish();
			case n"th-th":return new Thai();
			case n"tr-tr":return new Turkish();
			case n"uk-ua":return new Ukrainian();
			default:return null;
		}
	}
	public func GetFallback() -> CName{
		return n"en-us";
	}
}