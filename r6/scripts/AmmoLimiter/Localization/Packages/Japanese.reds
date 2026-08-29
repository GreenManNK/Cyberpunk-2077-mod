module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Japanese extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === 一般オプション ===
		this.Text("AmmoLimiter-Settings-Title","弾薬制限装置");
		this.Text("AmmoLimiter-Settings-Options","• 一般オプション");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","メッセージを表示");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","弾薬の変換、保管、または回収メッセージを表示します。");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","インベントリの弾薬の厳格な制限");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","デフォルトのソフト制限とは異なり、インベントリへの転送、購入、弾薬の作成を厳格に制限できます。");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","弾薬不足警告（閾値％）");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","閾値が0％より大きい場合、抜いた武器の残り弾薬量が閾値を下回ったときに警告できます。");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","手動弾薬分解を無効化");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","MODの他の機構を無効化することなく、手動で弾薬を分解する可能性を無効化できます。");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","分解からの回収（マガジンの％）");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","壊れた武器でも、武器を分解するときに弾薬を得ることができます。そのマガジンの最大容量の0からこの％までのランダムな量。ハンディキャップシステムを補完します。");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","弾薬表示カテゴリ");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","弾薬とレシピを表示するインベントリカテゴリを選択してください。");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","遠距離武器");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","武器アタッチメント");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","戦闘消耗品");

		// === 弾薬制限 ===
		this.Text("AmmoLimiter-Settings-Limits","• インベントリの弾薬制限");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","休眠弾薬制御");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","アクティブ武器にマッチしない弾薬を拾うことによる蓄積を防ぎ、直接変換または地面に落とします。");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","アクティブ武器制限ボーナス（％）");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","装備した武器に対応する弾薬の制限を超えることができます。");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","インベントリのハンドガン弾薬の最大値、拾得と作成にのみ適用されます。");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","インベントリの重火器弾薬の最大値、拾得と作成にのみ適用されます。");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","インベントリのショットガン弾薬の最大値、拾得と作成にのみ適用されます。");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","インベントリのスナイパー弾薬の最大値、拾得と作成にのみ適用されます。");

		// === 弾薬ボックス ===
		this.Text("AmmoLimiter-Settings-Box","• ボックスで見つかる最大量");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","世界の各ボックスのハンドガン弾薬の最大量。");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","世界の各ボックスの重火器弾薬の最大量。");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","世界の各ボックスのショットガン弾薬の最大量。");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","世界の各ボックスのスナイパー弾薬の最大量。");

		// === ハンディキャップシステム ===
		this.Text("AmmoLimiter-Settings-Hand","• ハンディキャップシステム");
		this.Text("AmmoLimiter-Settings-HandMode-Name","ハンディキャップモード");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","現在の量に応じて敵からの弾薬回収を調整します。「最適化」モードは設定から計算され、バランスが取れています。");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","最適化（推奨）");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","無効");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","カスタム");

		// === 弾薬別カスタムハンディキャップ ===
		this.Text("AmmoLimiter-Settings-CustomHand","• 弾薬別カスタムハンディキャップ");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","ハンドガン - ハンディキャップ閾値");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","ハンドガン - 最小値");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","ハンドガン - 最大値");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","重火器 - ハンディキャップ閾値");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","重火器 - 最小値");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","重火器 - 最大値");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","ショットガン - ハンディキャップ閾値");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","ショットガン - 最小値");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","ショットガン - 最大値");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","スナイパー - ハンディキャップ閾値");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","スナイパー - 最小値");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","スナイパー - 最大値");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","戦利品が弾薬を隠すことができるハンディキャップトリガー閾値。");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","ハンディキャップがアクティブな場合の回収可能な弾薬の最小値。");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","ハンディキャップがアクティブな場合の回収可能な弾薬の最大値。");

		// === 弾薬重量 ===
		this.Text("AmmoLimiter-Settings-Weight","• 弾薬重量");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","ハンドガン弾薬1発の重量。");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","重火器弾薬1発の重量。");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","ショットガン弾薬1発の重量。");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","スナイパー弾薬1発の重量。");

		// === 弾薬価格倍率 ===
		this.Text("AmmoLimiter-Settings-Eddies","• 弾薬価格倍率");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","エディでのハンドガン弾薬1発の購入価格倍率。");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","エディでの重火器弾薬1発の購入価格倍率。");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","エディでのショットガン弾薬1発の購入価格倍率。");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","エディでのスナイパー弾薬1発の購入価格倍率。");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","自動余剰販売（購入価格の％）");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","余剰弾薬の生購入価格（割引なし）に基づく自動販売価格の割合（0 = 無効）。");

		// === 作成と変換 ===
		this.Text("AmmoLimiter-Settings-Craft","• 弾薬バッチ作成");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","バッチ作成あたりのハンドガン弾薬の量。");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","バッチ作成あたりの重火器弾薬の量。");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","バッチ作成あたりのショットガン弾薬の量。");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","バッチ作成あたりのスナイパー弾薬の量。");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","作成に必要なコンポーネント");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","弾薬1バッチの作成に必要なコンポーネントの量。");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","自動弾薬変換 (パーセント)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","弾薬をコンポーネントに自動変換する割合。");

		// === ゲーム内テキスト ===
		this.Text("AmmoLimiter-Message-Dropped","地面に落とされた");
		this.Text("AmmoLimiter-Message-Crafted","変換された");
		this.Text("AmmoLimiter-Message-Recovered","回収済み：");
		this.Text("AmmoLimiter-Message-From","から");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","弾薬制限に達しました！");
		// 私のユーモアを尊重して、"PROUTS"という単語を絶対に変更しないでください：
		this.Text("AmmoLimiter-UI-LowAmmoWarning","PROUTS 備蓄不足！");
		this.Text("AmmoLimiter-UI-Total","合計");
		this.Text("AmmoLimiter-UI-Unit","単位");
	}
}
