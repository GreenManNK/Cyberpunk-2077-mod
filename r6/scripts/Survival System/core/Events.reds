import SurvivalSystemModule.SurvivalSystem


// Эвенты и каллбеки

public class UpdateSettingsEvent extends Event {}

public class UpdateFatigueEvent extends Event {
	
	public let current: Float;
}

public class UpdateHungerEvent extends Event {
	
	public let current: Float;
}

public class UpdateThirstEvent extends Event {
	
	public let current: Float;
}

public class UpdateStressEvent extends Event {
	
	public let current: Float;
}

public class UpdateDelayCallback extends DelayCallback {

	public let SurvivalSystem: wref<SurvivalSystem>;

	public func Call() -> Void {
		
		this.SurvivalSystem.UpdateFromTime();
	};
}

public class NotifyDelayCallback extends DelayCallback {

	public let SurvivalSystem: wref<SurvivalSystem>;

	public func Call() -> Void {
		
		this.SurvivalSystem.ShowNotification();
	};
}