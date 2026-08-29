module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Korean extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === 일반 옵션 ===
		this.Text("AmmoLimiter-Settings-Title","탄약 제한기");
		this.Text("AmmoLimiter-Settings-Options","• 일반 옵션");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","메시지 표시");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","탄약 변환, 저장 또는 회수 메시지를 표시합니다.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","인벤토리의 엄격한 탄약 제한");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","기본 소프트 제한과 달리 인벤토리로의 전송, 구매 및 탄약 제작을 엄격하게 제한할 수 있습니다.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","탄약 부족 경고 (임계값 %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","임계값이 0%보다 클 때, 뽑은 무기의 남은 탄약량이 임계값 아래일 때 경고할 수 있습니다.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","수동 탄약 분해 비활성화");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","모드의 다른 메커니즘을 비활성화하지 않고 수동으로 탄약을 분해하는 가능성을 비활성화할 수 있습니다.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","분해에서 회수 (탄창의 %)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","부서진 무기라도 무기를 분해할 때 탄약을 얻을 수 있습니다. 그 탄창의 최대 용량의 0에서 이 %까지의 무작위 량. 핸디캡 시스템을 보완합니다.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","탄약 표시 카테고리");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","탄약과 레시피를 표시할 인벤토리 카테고리를 선택하세요.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","원거리 무기");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","무기 부착물");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","전투 소모품");

		// === 탄약 제한 ===
		this.Text("AmmoLimiter-Settings-Limits","• 인벤토리의 탄약 제한");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","휴면 탄약 제어");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","활성 무기와 맞지 않는 탄약을 줍는 것으로 인한 축적을 방지하고, 직접 변환하거나 땅에 떨어뜨립니다.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","활성 무기 제한 보너스 (%)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","장착된 무기에 해당하는 탄약의 제한을 초과할 수 있습니다.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","인벤토리의 최대 핸드건 탄약, 줍기와 제작에만 적용됩니다.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","인벤토리의 최대 중화기 탄약, 줍기와 제작에만 적용됩니다.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","인벤토리의 최대 산탄총 탄약, 줍기와 제작에만 적용됩니다.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","인벤토리의 최대 저격총 탄약, 줍기와 제작에만 적용됩니다.");

		// === 탄약 상자 ===
		this.Text("AmmoLimiter-Settings-Box","• 상자에서 발견되는 최대 수량");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","월드의 각 상자에서 핸드건 탄약의 최대 수량.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","월드의 각 상자에서 중화기 탄약의 최대 수량.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","월드의 각 상자에서 산탄총 탄약의 최대 수량.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","월드의 각 상자에서 저격총 탄약의 최대 수량.");

		// === 핸디캡 시스템 ===
		this.Text("AmmoLimiter-Settings-Hand","• 핸디캡 시스템");
		this.Text("AmmoLimiter-Settings-HandMode-Name","핸디캡 모드");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","현재 수량에 따라 적으로부터의 탄약 회수를 조절합니다. \"최적화\" 모드는 설정에서 계산되며 균형이 잡혀 있습니다.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","최적화 (권장)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","비활성화");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","사용자 정의");

		// === 탄약별 사용자 정의 핸디캡 ===
		this.Text("AmmoLimiter-Settings-CustomHand","• 탄약별 사용자 정의 핸디캡");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","핸드건 - 핸디캡 임계값");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","핸드건 - 최소값");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","핸드건 - 최대값");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","중화기 - 핸디캡 임계값");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","중화기 - 최소값");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","중화기 - 최대값");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","산탄총 - 핸디캡 임계값");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","산탄총 - 최소값");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","산탄총 - 최대값");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","저격총 - 핸디캡 임계값");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","저격총 - 최소값");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","저격총 - 최대값");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","전리품이 탄약을 숨길 수 있는 핸디캡 트리거 임계값.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","핸디캡이 활성일 때 회수 가능한 탄약의 최소값.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","핸디캡이 활성일 때 회수 가능한 탄약의 최대값.");

		// === 탄약 무게 ===
		this.Text("AmmoLimiter-Settings-Weight","• 탄약 무게");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","핸드건 탄약 1발의 무게.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","중화기 탄약 1발의 무게.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","산탄총 탄약 1발의 무게.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","저격총 탄약 1발의 무게.");

		// === 탄약 가격 배수 ===
		this.Text("AmmoLimiter-Settings-Eddies","• 탄약 가격 배수");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","에디에서 핸드건 탄약 1발의 구매 가격 배수.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","에디에서 중화기 탄약 1발의 구매 가격 배수.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","에디에서 산탄총 탄약 1발의 구매 가격 배수.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","에디에서 저격총 탄약 1발의 구매 가격 배수.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","자동 초과 판매 (구매 가격의 %)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","초과 탄약에 대한 원시 구매 가격(할인 없음)을 기반으로 한 자동 판매 가격의 백분율 (0 = 비활성화).");

		// === 제작 & 변환 ===
		this.Text("AmmoLimiter-Settings-Craft","• 탄약 배치 제작");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","배치 제작당 핸드건 탄약 수량.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","배치 제작당 중화기 탄약 수량.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","배치 제작당 산탄총 탄약 수량.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","배치 제작당 저격총 탄약 수량.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","제작에 필요한 구성 요소");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","탄약 1배치를 제작하는데 필요한 구성 요소의 수량.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","자동 탄약 변환 (퍼센트)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","탄약을 구성 요소로 자동 변환하는 백분율.");

		// === 게임 내 텍스트 ===
		this.Text("AmmoLimiter-Message-Dropped","땅에 떨어뜨림");
		this.Text("AmmoLimiter-Message-Crafted","변환됨");
		this.Text("AmmoLimiter-Message-Recovered","회수됨:");
		this.Text("AmmoLimiter-Message-From","에서");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","탄약 제한에 도달했습니다!");
		// 제 유머를 존중해서 "PROUTS"라는 단어를 절대 수정하지 마세요:
		this.Text("AmmoLimiter-UI-LowAmmoWarning","PROUTS 비축량 부족!");
		this.Text("AmmoLimiter-UI-Total","총");
		this.Text("AmmoLimiter-UI-Unit","단위");
	}
}
