module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Spanish extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === OPCIONES GENERALES ===
		this.Text("AmmoLimiter-Settings-Title","Limitador de Munición");
		this.Text("AmmoLimiter-Settings-Options","• Opciones generales");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Mostrar mensajes");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Mostrar mensajes de conversión, almacenamiento o recuperación de munición.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Limitación estricta de munición en el inventario");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Permite limitar estrictamente las transferencias al inventario, compras y fabricación de munición, a diferencia de la limitación suave por defecto.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Aviso de munición baja (umbral en %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Cuando el umbral es mayor que 0%, permite avisar cuando la cantidad restante de munición del arma desenfundada está por debajo del umbral.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Desactivar desmontaje manual de munición");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Permite desactivar la posibilidad de desmontar manualmente la munición, sin desactivar otros mecanismos del mod.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Recuperación del desmontaje (% del cargador)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Permite obtener munición al desmontar un arma, incluso rota. Cantidad aleatoria entre 0 y este % de la capacidad máxima de su cargador. Complementa el sistema de handicap.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Categoría de visualización de munición");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Elige en qué categoría del inventario mostrar munición y recetas.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Armas a distancia");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Accesorios de armas");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Consumibles de combate");

		// === LÍMITES DE MUNICIÓN ===
		this.Text("AmmoLimiter-Settings-Limits","• Límites de munición en el inventario");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Control de munición inactiva");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Previene la acumulación al recoger munición que no coincide con el arma activa, directamente convertida o tirada al suelo.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Bonificación de límite de arma activa (en %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Permite exceder el límite para munición correspondiente al arma equipada.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Máximo de munición de pistola en el inventario, se aplica solo a recolección y fabricación.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Máximo de munición de arma pesada en el inventario, se aplica solo a recolección y fabricación.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Máximo de munición de escopeta en el inventario, se aplica solo a recolección y fabricación.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Máximo de munición de francotirador en el inventario, se aplica solo a recolección y fabricación.");

		// === CAJAS DE MUNICIÓN ===
		this.Text("AmmoLimiter-Settings-Box","• Cantidades máximas encontradas en cajas");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Cantidad máxima de munición de pistola en cada caja en el mundo.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Cantidad máxima de munición de arma pesada en cada caja en el mundo.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Cantidad máxima de munición de escopeta en cada caja en el mundo.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Cantidad máxima de munición de francotirador en cada caja en el mundo.");

		// === SISTEMA DE HANDICAP ===
		this.Text("AmmoLimiter-Settings-Hand","• Sistema de handicap");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Modo de handicap");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Regula la recuperación de munición de enemigos según tu cantidad actual. El modo \"Optimizado\" se calcula desde tus configuraciones y está balanceado.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimizado (recomendado)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Deshabilitado");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Personalizado");

		// === HANDICAP PERSONALIZADO POR MUNICIÓN ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Handicap personalizado por munición");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Pistola - umbral de handicap");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Pistola - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Pistola - máximo");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Arma pesada - umbral de handicap");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Arma pesada - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Arma pesada - máximo");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Escopeta - umbral de handicap");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Escopeta - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Escopeta - máximo");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Francotirador - umbral de handicap");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Francotirador - mínimo");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Francotirador - máximo");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Umbral de activación del handicap por debajo del cual el botín puede ocultar munición.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Mínimo de munición recuperable si el handicap está activo.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Máximo de munición recuperable si el handicap está activo.");

		// === PESO DE MUNICIÓN ===
		this.Text("AmmoLimiter-Settings-Weight","• Peso de munición");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Peso de una munición de pistola.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Peso de una munición de arma pesada.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Peso de una munición de escopeta.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Peso de una munición de francotirador.");

		// === MULTIPLICADORES DE PRECIO DE MUNICIÓN ===
		this.Text("AmmoLimiter-Settings-Eddies","• Multiplicadores de precio de munición");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Multiplicador de precio de compra para una munición de pistola en eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Multiplicador de precio de compra para una munición de arma pesada en eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Multiplicador de precio de compra para una munición de escopeta en eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Multiplicador de precio de compra para una munición de francotirador en eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Venta automática de exceso (en % del precio de compra)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Porcentaje del precio de venta automática basado en el precio de compra bruto (sin descuento) para munición excedente (0 = deshabilitado).");

		// === FABRICACIÓN Y CONVERSIÓN ===
		this.Text("AmmoLimiter-Settings-Craft","• Fabricación de lotes de munición");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Cantidad de munición de pistola por fabricación de lote.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Cantidad de munición de arma pesada por fabricación de lote.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Cantidad de munición de escopeta por fabricación de lote.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Cantidad de munición de francotirador por fabricación de lote.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Componentes requeridos para fabricación");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Cantidad de componentes necesarios para fabricar 1 lote de munición.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Conversión automática de munición (en %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Porcentaje de conversión automática de munición a componentes.");

		// === TEXTOS EN JUEGO ===
		this.Text("AmmoLimiter-Message-Dropped","tirado al suelo");
		this.Text("AmmoLimiter-Message-Crafted","convertido a");
		this.Text("AmmoLimiter-Message-Recovered","Recuperado:");
		this.Text("AmmoLimiter-Message-From","de");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","¡Límite de munición alcanzado!");
		// Por favor respeten mi humor nunca modificando la palabra "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","¡RESERVA INSUFICIENTE DE PROUTS!");
		this.Text("AmmoLimiter-UI-Total","total");
		this.Text("AmmoLimiter-UI-Unit","unidad");
	}
}
