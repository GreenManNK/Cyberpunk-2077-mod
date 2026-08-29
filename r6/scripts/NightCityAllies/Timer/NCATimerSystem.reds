module NightCityAllies.Timer

import NightCityAllies.*
import NightCityAllies.Effect.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*

public final class NCATimerSystem extends ScriptableSystem {
    public func StartTimerString(id: String, days: Int32, hours: Int32, minutes: Int32, effect: String, subject: String) -> Void {
        this.StartTimer(StringToName(id), days, hours, minutes, StringToName(effect), TDBID.Create(subject));
    }

    public func StartTimer(id: CName, days: Int32, hours: Int32, minutes: Int32, effect: CName, opt subject: TweakDBID) -> Void {
        if this.GetTimerIndex(id) >= 0 {
            NCA.CETLog("WARNING Timer with id " + ToString(id) + " already exists");
            return;
        }

        if NCA.Settings().skipAllTimers {
            //NCA.CETLog("WARNING Skipping timer " + ToString(id) + " because skipAllTimers is enabled");
            NCA.Effect().Trigger(effect, subject);
            return;
        }

        let totalMinutes = days * 24 * 60 + hours * 60 + minutes;
        ArrayPush(NCA.Persistence().m_timerRegistry, new NCATimerData(id, totalMinutes, effect, subject));
        //NCA.CETLog("Started timer " + ToString(id) + " with effect " + ToString(effect) + " subject " + TDBID.ToStringDEBUG(subject) + " for " + IntToString(totalMinutes) + " minutes");
    }

    public func StopTimerString(id: String) -> Void {
        this.StopTimer(StringToName(id));
    }

    public func StopTimer(id: CName) -> Void {
        let timers = NCA.Persistence().m_timerRegistry;
        
        let index: Int32 = this.GetTimerIndex(id);

        if index < 0 {
            NCA.CETLog("ERROR Timer not found by id: " + ToString(id));
            return;
        }

        ArrayErase(NCA.Persistence().m_timerRegistry, index);
    }

    public func TickTimers(minutes: Int32) -> Void {
        let PS = NCA.Persistence();
        let i: Int32 = ArraySize(PS.m_timerRegistry) - 1;
        while i >= 0 {
            PS.m_timerRegistry[i].timeLeft -= minutes;

            if PS.m_timerRegistry[i].timeLeft <= 0 || NCA.Settings().skipAllTimers {
                //NCA.CETLog("Timer " + ToString(PS.m_timerRegistry[i].id) + " finished, applying effect " + ToString(PS.m_timerRegistry[i].effect));

                let effect = PS.m_timerRegistry[i].effect;
                let subject = PS.m_timerRegistry[i].subject;

                ArrayErase(NCA.Persistence().m_timerRegistry, i);
                NCA.Effect().Trigger(effect, subject);
            } else {
                //NCA.CETLog("Ticking timer " + ToString(PS.m_timerRegistry[i].id) + ", time left: " + IntToString(PS.m_timerRegistry[i].timeLeft));
            }
            i -= 1;
        }
    }

    private func GetTimerIndex(id: CName) -> Int32 {
        let timers = NCA.Persistence().m_timerRegistry;
        let i: Int32 = 0;
        while i < ArraySize(timers) {
            if Equals(timers[i].id, id) {
                return i;
            }
            i += 1;
        }
        return -1;
    }
}