module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_pt_br extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Habilitado");
        this.Text("GibbonGR-EnabledInCombat-Name", "Habilitado quando o jogador está em combate");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Habilitado quando o jogador é passageiro");
        this.Text("GibbonGR-GracePeriodMin-Name", "Período de graça mínimo");
        this.Text("GibbonGR-GracePeriodMin-Description", "Tempo mínimo antes de uma gang poder chamar reforços pela primeira vez em uma luta");
        this.Text("GibbonGR-GracePeriodMax-Name", "Período de graça máximo");
        this.Text("GibbonGR-GracePeriodMax-Description", "Tempo máximo antes de uma gang poder chamar reforços pela primeira vez em uma luta");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Cooldown de chamada mínimo");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Tempo mínimo que uma gang deve esperar antes de chamar reforços novamente na mesma luta");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Cooldown de chamada máximo");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Tempo máximo que uma gang deve esperar antes de chamar reforços novamente na mesma luta");
        this.Text("GibbonGR-InitialHeat-Name", "Calor inicial");
        this.Text("GibbonGR-InitialHeat-Description", "Quão forte será a primeira chamada de reforços");
        this.Text("GibbonGR-HeatEscalation-Name", "Escalação de calor");
        this.Text("GibbonGR-HeatEscalation-Description", "Quanto o calor aumenta por gang por chamada");
        this.Text("GibbonGR-CallsLimit-Name", "Limite de chamadas");
        this.Text("GibbonGR-CallsLimit-Description", "O número de chamadas que uma gang pode fazer antes de ter que esperar o cooldown limite");
        this.Text("GibbonGR-StrongCallChance-Name", "Chance de chamada forte");
        this.Text("GibbonGR-StrongCallChance-Description", "Chance de que a próxima chamada de reforços seja mais forte que o nível atual de calor");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Bônus de calor para chamada forte");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Quanto calor extra a chamada forte terá");
        this.Text("GibbonGR-GracePeriod-Category", "Período de graça");
        this.Text("GibbonGR-Cooldowns-Category", "Cooldowns");
        this.Text("GibbonGR-Heat-Category", "Calor");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Modo Predefinido");
        this.Text("GibbonGR-PresetMode-Description", "Escolha entre modos predefinidos para diferentes experiências de jogo");
        this.Text("GibbonGR-PresetMode-Limited", "Limitado");
        this.Text("GibbonGR-PresetMode-Balanced", "Equilibrado");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Batalhas Grandes Raras");
        this.Text("GibbonGR-PresetMode-Chaos", "Caos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Mostrar Configurações Avançadas");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Mostrar configurações avançadas para ajustar parâmetros individuais. Substitui o modo predefinido.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Mínimo de Veículos por Chamada");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Número mínimo de veículos que aparecem em uma única chamada de reforços");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Máximo de Veículos por Chamada");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Número máximo de veículos que podem aparecer em uma única chamada de reforços");
	}
}
