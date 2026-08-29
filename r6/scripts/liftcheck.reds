@wrapMethod(LiftDevice)
private final func SetPlayerInsideElevatorBlackboard(isInside: Bool, opt isElevatorMoving: Bool) -> Void 
{
	wrappedMethod(isInside,isElevatorMoving);
	GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("in_elevator", isInside?1:0);
	GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("in_moving_elevator", isElevatorMoving?1:0);
}