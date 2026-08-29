// ************************************************************************************************
// ***  Lizzie's Braindances
// ***    Author: ArmanIII
// ***
// *** Please, if you will have unconquerable lust to edit this file (which I don't recommend),
// *** then please do not report any bugs you will encounter in the mod, because I don't want
// *** then spend X hours of searching of a bug which doesn't exist and in the end we find that
// *** it's all your fault. Help me save my nerves. Thanks.
// ***
// ************************************************************************************************

module LizziesBDs.ChoiceHubsActiveTweak

import LizziesBDs.Classes.*

@wrapMethod(DefaultTransition)
protected final const func AreChoiceHubsActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
	let menuJeZobrazene: Int32 = GameInstance.GetQuestsSystem(scriptInterface.executionOwner.GetGame()).GetFact(Konstanty.FaktMenuUI());
	if menuJeZobrazene > 0 {
		return true;
	}
	return wrappedMethod(scriptInterface);
}
