module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class ChineseSimplified extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === 通用选项 ===
		this.Text("AmmoLimiter-Settings-Title","弹药限制器");
		this.Text("AmmoLimiter-Settings-Options","• 通用选项");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","显示消息");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","显示弹药转换、存放或回收消息。");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","库存中弹药的严格限制");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","允许严格限制向库存的转移、购买和制造弹药，与默认的软限制相反。");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","低弹药量警告（百分比阈值）");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","当阈值大于0%时，允许在所拔出武器的剩余弹药量低于阈值时发出警告。");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","禁用手动拆解弹药");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","允许禁用手动拆解弹药的可能性，而不禁用模组的其他机制。");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","从拆解中回收（弹匣百分比）");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","允许在拆解武器时获得弹药，即使是破损的武器。介于0和其弹匣最大容量百分比之间的随机数量。补充残疾系统。");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","弹药显示类别");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","选择在哪个库存类别中显示弹药和配方。");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","远程武器");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","武器附件");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","战斗消耗品");

		// === 弹药限制 ===
		this.Text("AmmoLimiter-Settings-Limits","• 库存中的弹药限制");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","休眠弹药控制");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","防止通过拾取不匹配活动武器的弹药进行累积，直接转换或掉落到地面。");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","活动武器限制奖励（百分比）");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","允许为装备武器对应的弹药超过限制。");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","库存中手枪弹药的最大值，仅适用于拾取和制造。");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","库存中重型武器弹药的最大值，仅适用于拾取和制造。");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","库存中霰弹枪弹药的最大值，仅适用于拾取和制造。");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","库存中狙击枪弹药的最大值，仅适用于拾取和制造。");

		// === 弹药箱 ===
		this.Text("AmmoLimiter-Settings-Box","• 箱子中发现的最大数量");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","世界中每个箱子里手枪弹药的最大数量。");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","世界中每个箱子里重型武器弹药的最大数量。");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","世界中每个箱子里霰弹枪弹药的最大数量。");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","世界中每个箱子里狙击枪弹药的最大数量。");

		// === 残疾系统 ===
		this.Text("AmmoLimiter-Settings-Hand","• 残疾系统");
		this.Text("AmmoLimiter-Settings-HandMode-Name","残疾模式");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","根据您当前的数量调节从敌人那里回收弹药。\"优化\"模式是根据您的设置计算的，并且是平衡的。");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","优化（推荐）");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","禁用");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","自定义");

		// === 按弹药自定义残疾 ===
		this.Text("AmmoLimiter-Settings-CustomHand","• 按弹药自定义残疾");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","手枪 - 残疾阈值");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","手枪 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","手枪 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","重型武器 - 残疾阈值");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","重型武器 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","重型武器 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","霰弹枪 - 残疾阈值");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","霰弹枪 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","霰弹枪 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","狙击枪 - 残疾阈值");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","狙击枪 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","狙击枪 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","残疾触发阈值，低于此值战利品可以隐藏弹药。");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","如果残疾处于活动状态，可回收弹药的最小值。");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","如果残疾处于活动状态，可回收弹药的最大值。");

		// === 弹药重量 ===
		this.Text("AmmoLimiter-Settings-Weight","• 弹药重量");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","一发手枪弹药的重量。");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","一发重型武器弹药的重量。");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","一发霰弹枪弹药的重量。");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","一发狙击枪弹药的重量。");

		// === 弹药价格倍数 ===
		this.Text("AmmoLimiter-Settings-Eddies","• 弹药价格倍数");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","一发手枪弹药的购买价格倍数（欧元）。");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","一发重型武器弹药的购买价格倍数（欧元）。");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","一发霰弹枪弹药的购买价格倍数（欧元）。");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","一发狙击枪弹药的购买价格倍数（欧元）。");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","自动出售过量（购买价格的百分比）");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","基于原始购买价格（无折扣）的自动销售价格百分比，用于过量弹药（0 = 禁用）。");

		// === 制造和转换 ===
		this.Text("AmmoLimiter-Settings-Craft","• 弹药批次制造");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","每个制造批次的手枪弹药数量。");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","每个制造批次的重型武器弹药数量。");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","每个制造批次的霰弹枪弹药数量。");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","每个制造批次的狙击枪弹药数量。");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","制造所需组件");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","制造1批弹药所需的组件数量。");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","自动弹药转换 (百分比)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","弹药自动转换为组件的百分比。");

		// === 游戏内文本 ===
		this.Text("AmmoLimiter-Message-Dropped","丢弃到地面");
		this.Text("AmmoLimiter-Message-Crafted","转换为");
		this.Text("AmmoLimiter-Message-Recovered","已回收：");
		this.Text("AmmoLimiter-Message-From","自");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","已达到弹药限制！");
		// 请尊重我的幽默感，永远不要修改"PROUTS"这个词：
		this.Text("AmmoLimiter-UI-LowAmmoWarning","PROUTS 储备不足！");
		this.Text("AmmoLimiter-UI-Total","总计");
		this.Text("AmmoLimiter-UI-Unit","单位");
	}
}
