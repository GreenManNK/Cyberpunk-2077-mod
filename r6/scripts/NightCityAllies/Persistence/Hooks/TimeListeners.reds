module NightCityAllies.Event.Hooks

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Event.*

// Blackboard Listeners
public class TimeListeners extends ScriptableSystem {
    private let m_shouldStop: Bool;
    private let m_isStarted: Bool;
    private let m_lastTickAt: Float;
    public static func TickDelay() -> Float = 0.75;

    private func MeasureTick() -> Float {
        let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
        let elapsed: Float = now - this.m_lastTickAt;
        this.m_lastTickAt = now;

        // First tick has nothing to measure from
        if elapsed <= 0.0 || elapsed > TimeListeners.TickDelay() * 5.0 {
            return TimeListeners.TickDelay();
        }
        return elapsed;
    }

    public static func Get() -> ref<TimeListeners> {
        return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<TimeListeners>()) as TimeListeners;
    }

    public final func Start() {
        this.m_shouldStop = false;
        if (this.m_isStarted) {
            return;
        }
        this.m_isStarted = true;
        this.m_lastTickAt = EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
        GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(NCATickDelayCallback.Create(), TimeListeners.TickDelay(), true);
    }

    public final func Stop() {
        this.m_shouldStop = true;
    }

    public final func Update() -> Void {
        let timeSystem = GameInstance.GetTimeSystem(GetGameInstance());
        let now: GameTime = timeSystem.GetGameTime();

        let currentDay: Int32 = GameTime.Days(now);
        let currentHour: Int32 = GameTime.Hours(now);
        let currentMinute: Int32 = GameTime.Minutes(now);

        NCA.Events().OnTick(this.MeasureTick());
        let now: GameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();

        if !Equals(NCA.Context().day, currentDay) {
            NCA.Context().day = currentDay;
            NCA.Events().OnDayPassed();
        }

        if !Equals(NCA.Context().hour, currentHour) {
            NCA.Context().hour = currentHour;
            NCA.Events().OnHourPassed();
        }

        if !Equals(NCA.Context().minute, currentMinute) {
            NCA.Context().minute = currentMinute;
            NCA.Events().OnMinutePassed();
        }

        if !this.m_shouldStop {
            GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(NCATickDelayCallback.Create(), TimeListeners.TickDelay(), true); 
        } else {
            this.m_isStarted = false;
        }
    }
}

public class NCATickDelayCallback extends DelayCallback {
	public static func Create() -> ref<NCATickDelayCallback> {
		return new NCATickDelayCallback();
	}

    public func Call() -> Void {
        TimeListeners.Get().Update();
    }
}

public class TimeSkipMemory extends ScriptableSystem {
    let m_startTime: GameTime;

     public static func Get() -> ref<TimeSkipMemory> {
        return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<TimeSkipMemory>()) as TimeSkipMemory;
    }

    public final func SetStartTime() -> Void {
        this.m_startTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();
    }

    public final func GetTimeSkipped() -> Int32 {
        let now: GameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();
        //NCA.CETLog("Time skipped, start time: " + IntToString(this.GetTotalMinutes(this.m_startTime)) + " now: " + IntToString(this.GetTotalMinutes(now)));
        return this.GetTotalMinutes(now) - this.GetTotalMinutes(this.m_startTime);
    }

    public func GetTotalMinutes(time: GameTime) -> Int32 {
        let d: Int32 = GameTime.Days(time);
        let h: Int32 = GameTime.Hours(time);
        let m: Int32 = GameTime.Minutes(time);
        return d * 24 * 60 + h * 60 + m;
    }
}

@wrapMethod(TimeskipGameController)
private final func Apply() -> Void {
    TimeSkipMemory.Get().SetStartTime();
    wrappedMethod();
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnTimeSkip(evt: ref<TimeSkipFinishEvent>) -> Bool {
    NCA.Events().OnTimeSkip(TimeSkipMemory.Get().GetTimeSkipped());
    return wrappedMethod(evt);
}