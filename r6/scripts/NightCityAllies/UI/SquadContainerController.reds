module NightCityAllies.UI

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Settings.*
import NightCityAllies.Persistence.*
import NightCityAllies.Persistence.*
import NightCityAllies.Localization.*

public class SquadContainerController extends inkLogicController {
    private let m_squadList: inkCompoundRef;
	private let m_root: wref<inkCanvas>;
	private let m_header: wref<inkText>;
	private let m_squadRoot: wref<inkVerticalPanel>;
    private let m_anim: ref<inkAnimProxy>;
    private let m_hasAnyMembers: Bool;
    private let m_isOpen: Bool;
    private let m_shouldOpen: Bool;

    private let m_memberWidgetControllers: array<ref<SquadMemberController>>;

    public func Setup() {
        this.m_root = this.GetChildWidgetByPath(n"Main") as inkCanvas;
        this.m_header = this.GetChildWidgetByPath(n"Main/Header") as inkText;
        this.m_squadRoot = this.GetChildWidgetByPath(n"Main/SquadRoot") as inkVerticalPanel;
        this.m_hasAnyMembers = false;
        this.m_isOpen = false;
        this.m_shouldOpen = false;
        this.m_root.SetOpacity(0.0);
        this.RefreshHeader();
        this.ApplyTransform();
	}

    public func ApplyTransform() -> Void {
        if !IsDefined(this.m_root) {
            return;
        }

        let factor: Float = NCA.Settings().squadHUDSize;
        this.m_root.renderTransform.scale = new Vector2(factor, factor);
        this.m_root.SetTranslation(NCA.Settings().squadHUDOffsetX, NCA.Settings().squadHUDOffsetY);
    }

    // TODO make event driven or just use widget count
    public func RefreshHeader() -> Void {
        if !IsDefined(this.m_header) {
            return;
        }

        let text: String = NCA.Labels().Squad() + " (" + ToString(NCA.NPC().GetSquadSize()) + "/" + ToString(NCAConstants.DisplaySquadCap()) + ")";
        this.m_header.SetText(text);
    }

    public func HasMember(npc: ref<NpcHandle>) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_memberWidgetControllers) {
            if this.m_memberWidgetControllers[i].GetNpc() == npc {
                return true;
            }
            i += 1;
        }
        return false;
    }

    public func GetMember(npc: ref<NpcHandle>) -> ref<SquadMemberController> {
        let i: Int32 = 0;
        while i < ArraySize(this.m_memberWidgetControllers) {
            if this.m_memberWidgetControllers[i].GetNpc() == npc {
                return this.m_memberWidgetControllers[i];
            }
            i += 1;
        }
        return null;
    }

    public func AddMember(npc: ref<NpcHandle>) -> ref<SquadMemberController> {
        if this.HasMember(npc) {
            //NCA.CETLog("WARNING Trying to add widget for NPC that already has a widget: " + npc.GetName());
            return this.GetMember(npc);
        }

        if NCA.Persistence().GetIndex(npc.recordID) < 0 {
            NCA.CETLog("WARNING Attempting add widget for a companion that doenst exist: " + TDBID.ToStringDEBUG(npc.recordID));
            return null;
        }

        let widget: wref<inkWidget> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_squadList), r"nca\\gameplay\\gui\\widgets\\member.inkwidget", n"Root");
        widget.Reparent(this.m_squadRoot);
        let widgetController: ref<SquadMemberController> = widget.GetController() as SquadMemberController;
        widgetController.Setup(npc);
        this.m_hasAnyMembers = true;

        if (this.m_shouldOpen) {
            this.FadeIn();
        }

        npc.SetSquadWidgetController(widgetController);

        if npc.IsCommuting() {
            npc.CommuteSquadWidget();
        } else if npc.IsSquad() {
            npc.IntroSquadWidget();
        }

        ArrayPush(this.m_memberWidgetControllers, widgetController);

        return widgetController;
    }

    public func ClearMembers() -> Void {
        this.m_squadRoot.RemoveAllChildren();
        inkCompoundRef.RemoveAllChildren(this.m_squadList);

        if (this.m_shouldOpen) {
            this.FadeOut();
        }

        this.m_hasAnyMembers = false;
        this.m_memberWidgetControllers = [];
    }

    public func ShowNotification(data: ref<inkGameNotificationData>) -> ref<inkGameNotificationToken> {
        return this.ShowGameNotification(data);
    }

    public func Open() -> Void {
        this.m_shouldOpen = true;
        this.FadeIn();
    }

    public func Close() -> Void {
        this.m_shouldOpen = false;

        this.FadeOut();
    }

    protected func FadeIn() -> Void {
        if (!this.m_hasAnyMembers || this.m_isOpen) {
            return;
        }

        if IsDefined(this.m_anim) && this.m_anim.IsPlaying() {
            this.m_anim.Stop();
        }

        let def = new inkAnimDef();
        let fadeIn = new inkAnimTransparency();
        fadeIn.SetStartTransparency(0.0);
        fadeIn.SetEndTransparency(1.0);
        fadeIn.SetStartDelay(0.0);
        fadeIn.SetDuration(0.5);
        fadeIn.SetType(inkanimInterpolationType.Linear);
        fadeIn.SetMode(inkanimInterpolationMode.EasyOut);
        def.AddInterpolator(fadeIn);

        this.m_anim = this.m_root.PlayAnimation(def);
        this.m_isOpen = true;
    }

    protected func FadeOut() -> Void {
        if (!this.m_isOpen) {
            return;
        }

        if IsDefined(this.m_anim) && this.m_anim.IsPlaying() {
            this.m_anim.Stop();
        }

        let def = new inkAnimDef();
        let fadeOut = new inkAnimTransparency();
        fadeOut.SetStartTransparency(1.0);
        fadeOut.SetEndTransparency(0.0);
        fadeOut.SetStartDelay(0.0);
        fadeOut.SetDuration(0.5);
        fadeOut.SetType(inkanimInterpolationType.Linear);
        fadeOut.SetMode(inkanimInterpolationMode.EasyOut);
        def.AddInterpolator(fadeOut);

        this.m_anim = this.m_root.PlayAnimation(def);
        this.m_isOpen = false;
    }
}
