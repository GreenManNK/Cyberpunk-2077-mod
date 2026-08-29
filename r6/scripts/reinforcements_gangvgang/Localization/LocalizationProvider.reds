import Gibbon.GR.Localization.Packages.*
import Codeware.Localization.*

public class GRLocalizationProvider extends ModLocalizationProvider{
	public func GetPackage(language:CName) -> ref<ModLocalizationPackage>{
		switch language{
			case n"ar-ar":return new GR_ar_ar();
			case n"cz-cz":return new GR_cz_cz();
			case n"en-us":return new GR_en_us();
			case n"de-de":return new GR_de_de();
			case n"es-es":return new GR_es_es();
            case n"es-mx":return new GR_es_mx();
			case n"fr-fr":return new GR_fr_fr();
			case n"hu-hu":return new GR_hu_hu();
			case n"it-it":return new GR_it_it();
			case n"jp-jp":return new GR_jp_jp();
			case n"kr-kr":return new GR_kr_kr();
			case n"pl-pl":return new GR_pl_pl();
			case n"pt-br":return new GR_pt_br();
			case n"ru-ru":return new GR_ru_ru();
			case n"th-th":return new GR_th_th();
			case n"tr-tr":return new GR_tr_tr();
			case n"ua-ua":return new GR_ua_ua();
			case n"zh-cn":return new GR_zh_cn();
			case n"zh-tw":return new GR_zh_tw();
			default:return null;
		}
	}
	public func GetFallback() -> CName{
		return n"en-us";
	}
}