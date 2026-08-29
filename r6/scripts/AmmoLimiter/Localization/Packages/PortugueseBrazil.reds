module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class PortugueseBrazil extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === OPÇÕES GERAIS ===
		this.Text("AmmoLimiter-Settings-Title","Limitador de Munição");
		this.Text("AmmoLimiter-Settings-Options","• Opções gerais");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Exibir mensagens");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Exibir mensagens de conversão, armazenamento ou recuperação de munição.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Limitação rigorosa de munição no inventário");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Permite limitar rigorosamente transferências para o inventário, compras e fabricação de munição, ao contrário da limitação suave padrão.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Aviso de munição baixa (limite em %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Quando o limite for maior que 0%, permite avisar quando a quantidade restante de munição da arma sacada estiver abaixo do limite.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Desativar desmontagem manual de munição");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Permite desativar a possibilidade de desmontar manualmente a munição, sem desativar outros mecanismos do mod.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Recuperação da desmontagem (% do carregador)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Permite obter munição ao desmontar uma arma, mesmo quebrada. Quantidade aleatória entre 0 e esta % da capacidade máxima do carregador. Complementa o sistema de desvantagem.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Categoria de exibição de munição");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Escolha em qual categoria do inventário exibir munição e receitas.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Armas à distância");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Acessórios de armas");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Consumíveis de combate");

		// === LIMITES DE MUNIÇÃO ===
		this.Text("AmmoLimiter-Settings-Limits","• Limites de munição no inventário");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Controle de munição inativa");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Previne acumulação ao pegar munição que não corresponde à arma ativa, diretamente convertida ou derrubada no chão.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Bônus de limite da arma ativa (em %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Permite exceder o limite para munição correspondente à arma equipada.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Máximo de munição de pistola no inventário, aplica-se apenas a coleta e fabricação.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Máximo de munição de arma pesada no inventário, aplica-se apenas a coleta e fabricação.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Máximo de munição de espingarda no inventário, aplica-se apenas a coleta e fabricação.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Máximo de munição de sniper no inventário, aplica-se apenas a coleta e fabricação.");

		// === CAIXAS DE MUNIÇÃO ===
		this.Text("AmmoLimiter-Settings-Box","• Quantidades máximas encontradas em caixas");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Quantidade máxima de munição de pistola em cada caixa no mundo.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Quantidade máxima de munição de arma pesada em cada caixa no mundo.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Quantidade máxima de munição de espingarda em cada caixa no mundo.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Quantidade máxima de munição de sniper em cada caixa no mundo.");

		// === SISTEMA DE DESVANTAGEM ===
		this.Text("AmmoLimiter-Settings-Hand","• Sistema de desvantagem");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Modo de desvantagem");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Regula a recuperação de munição de inimigos de acordo com sua quantidade atual. O modo \"Otimizado\" é calculado a partir de suas configurações e é balanceado.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Otimizado (recomendado)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Desabilitado");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Personalizado");

		// === DESVANTAGEM PERSONALIZADA POR MUNIÇÃO ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Desvantagem personalizada por munição");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Pistola - limite de desvantagem");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Pistola - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Pistola - máximo");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Arma pesada - limite de desvantagem");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Arma pesada - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Arma pesada - máximo");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Espingarda - limite de desvantagem");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Espingarda - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Espingarda - máximo");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Sniper - limite de desvantagem");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Sniper - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Sniper - máximo");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Limite de ativação da desvantagem abaixo do qual o saque pode esconder munição.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Mínimo de munição recuperável se a desvantagem estiver ativa.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Máximo de munição recuperável se a desvantagem estiver ativa.");

		// === PESO DA MUNIÇÃO ===
		this.Text("AmmoLimiter-Settings-Weight","• Peso da munição");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Peso de uma munição de pistola.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Peso de uma munição de arma pesada.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Peso de uma munição de espingarda.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Peso de uma munição de sniper.");

		// === MULTIPLICADORES DE PREÇO DE MUNIÇÃO ===
		this.Text("AmmoLimiter-Settings-Eddies","• Multiplicadores de preço de munição");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Multiplicador de preço de compra para uma munição de pistola em eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Multiplicador de preço de compra para uma munição de arma pesada em eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Multiplicador de preço de compra para uma munição de espingarda em eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Multiplicador de preço de compra para uma munição de sniper em eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Venda automática de excesso (em % do preço de compra)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Porcentagem do preço de venda automática baseada no preço de compra bruto (sem desconto) para munição excessiva (0 = desabilitado).");

		// === FABRICAÇÃO E CONVERSÃO ===
		this.Text("AmmoLimiter-Settings-Craft","• Fabricação de lotes de munição");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Quantidade de munição de pistola por fabricação de lote.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Quantidade de munição de arma pesada por fabricação de lote.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Quantidade de munição de espingarda por fabricação de lote.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Quantidade de munição de sniper por fabricação de lote.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Componentes necessários para fabricação");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Quantidade de componentes necessários para fabricar 1 lote de munição.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Conversão automática de munição (em %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Porcentagem de conversão automática de munição para componentes.");

		// === TEXTOS NO JOGO ===
		this.Text("AmmoLimiter-Message-Dropped","derrubado no chão");
		this.Text("AmmoLimiter-Message-Crafted","convertido em");
		this.Text("AmmoLimiter-Message-Recovered","Recuperado:");
		this.Text("AmmoLimiter-Message-From","de");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Limite de munição atingido!");
		// Por favor respeitem meu humor nunca modificando a palavra "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","RESERVA INSUFICIENTE DE PROUTS!");
		this.Text("AmmoLimiter-UI-Total","total");
		this.Text("AmmoLimiter-UI-Unit","unidade");
	}
}
