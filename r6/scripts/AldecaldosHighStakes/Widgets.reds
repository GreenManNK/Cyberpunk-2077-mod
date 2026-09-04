module AldecaldosHighStakes.Widgets

import AldecaldosHighStakes.Workbench.*
import Codeware.Localization.LocalizationSystem
import Codeware.Localization.*
import Codeware.UI.*

public class InGamePopupHSHeader extends inkCustomController {
    protected let m_title: wref<inkText>;
    protected let m_fluffLeft: wref<inkText>;
    protected let m_fluffRight: wref<inkText>;

    protected cb func OnCreate() {
        let header: ref<inkFlex> = new inkFlex();
        header.SetName(n"header");
        header.SetMargin(new inkMargin(76.0, 32.0, 76.0, 0.0));
        header.SetAnchor(inkEAnchor.TopFillHorizontaly);

        let bar: ref<inkFlex> = new inkFlex();
        bar.SetName(n"bar");
        bar.SetMargin(new inkMargin(24.0, 0.0, 0.0, 0.0));
        bar.SetRenderTransformPivot(new Vector2(0.0, 0.5));
        bar.Reparent(header);

        let bg: ref<inkImage> = new inkImage();
        bg.SetName(n"bg");
        bg
            .SetAtlasResource(
                r"base\\gameplay\\gui\\widgets\\notifications\\notification_assets.inkatlas"
            );
        bg.SetTexturePart(n"Plate_main");
        bg.SetNineSliceScale(true);
        bg.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        bg.SetAnchorPoint(new Vector2(1.0, 1.0));
        bg.SetOpacity(0.61);
        bg.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        bg
            .BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
        bg.Reparent(bar);

        let bgr: ref<inkImage> = new inkImage();
        bgr.SetName(n"bgr");
        bgr
            .SetAtlasResource(
                r"base\\gameplay\\gui\\widgets\\notifications\\notification_assets.inkatlas"
            );
        bgr.SetTexturePart(n"Plate_main");
        bgr.SetNineSliceScale(true);
        bgr.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        bgr.SetAnchorPoint(new Vector2(1.0, 1.0));
        bgr.SetOpacity(0.07);
        bgr.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        bgr.BindProperty(n"tintColor", n"MainColors.PanelDarkRed");
        bgr.SetRenderTransformPivot(new Vector2(1.0, 1.0));
        bgr.Reparent(bar);

        let frame: ref<inkImage> = new inkImage();
        frame.SetName(n"frame");
        frame
            .SetAtlasResource(
                r"base\\gameplay\\gui\\widgets\\notifications\\notification_assets.inkatlas"
            );
        frame.SetTexturePart(n"Plate_main_Stroke");
        frame.SetNineSliceScale(true);
        frame.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        frame.SetAnchorPoint(new Vector2(1.0, 1.0));
        frame.SetOpacity(0.217);
        frame.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        frame.BindProperty(n"tintColor", n"MainColors.Blue");
        frame.SetRenderTransformPivot(new Vector2(1.0, 1.0));
        frame.Reparent(bar);

        let bracketBg: ref<inkImage> = new inkImage();
        bracketBg.SetName(n"bracketBg");
        bracketBg
            .SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        bracketBg.SetTexturePart(n"notification_bracket_bg");
        bracketBg.SetNineSliceScale(true);
        bracketBg.SetFitToContent(true);
        bracketBg.SetHAlign(inkEHorizontalAlign.Left);
        bracketBg.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        bracketBg.SetAnchorPoint(new Vector2(1.0, 1.0));
        bracketBg.SetOpacity(0.61);
        bracketBg.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        bracketBg
            .BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
        bracketBg.SetRenderTransformPivot(new Vector2(1.0, 1.0));
        bracketBg.Reparent(header);

        let bracketBgr: ref<inkImage> = new inkImage();
        bracketBgr.SetName(n"bracketBgr");
        bracketBgr
            .SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        bracketBgr.SetTexturePart(n"notification_bracket_bg");
        bracketBgr.SetNineSliceScale(true);
        bracketBgr.SetFitToContent(true);
        bracketBgr.SetHAlign(inkEHorizontalAlign.Left);
        bracketBgr.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        bracketBgr.SetAnchorPoint(new Vector2(1.0, 1.0));
        bracketBgr.SetOpacity(0.217);
        bracketBgr.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        bracketBgr.BindProperty(n"tintColor", n"MainColors.Blue");
        bracketBgr.Reparent(header);

        let bracketFg: ref<inkImage> = new inkImage();
        bracketFg.SetName(n"bracketFg");
        bracketFg
            .SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        bracketFg.SetTexturePart(n"notification_bracket_fg");
        bracketFg.SetNineSliceScale(true);
        bracketFg.SetFitToContent(true);
        bracketFg.SetHAlign(inkEHorizontalAlign.Left);
        bracketFg.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        bracketFg.SetAnchorPoint(new Vector2(1.0, 1.0));
        bracketFg.SetOpacity(0.217);
        bracketFg.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        bracketFg.BindProperty(n"tintColor", n"MainColors.Blue");
        bracketFg.Reparent(header);

        let title: ref<inkText> = new inkText();
        title.SetName(n"title");
        title.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        title.SetFontStyle(n"Medium");
        title.SetFontSize(50);
        title.SetLetterCase(textLetterCase.UpperCase);
        title.SetFitToContent(true);
        title.SetMargin(new inkMargin(48.0, 8.0, 200.0, 6.0));
        title.SetHAlign(inkEHorizontalAlign.Left);
        title.SetVAlign(inkEVerticalAlign.Center);
        title.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        title.BindProperty(n"tintColor", n"MainColors.Blue");
        title.Reparent(header);

        let fluffTextL: ref<inkText> = new inkText();
        fluffTextL.SetName(n"fluffTextL");
        fluffTextL.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        fluffTextL.SetFontStyle(n"Medium");
        fluffTextL.SetFontSize(20);
        fluffTextL.SetLetterCase(textLetterCase.UpperCase);
        fluffTextL.SetText("TRN_TCLAS_800095");
        fluffTextL.SetFitToContent(true);
        fluffTextL.SetMargin(new inkMargin(0.0, -30.0, 0.0, 0.0));
        fluffTextL.SetHAlign(inkEHorizontalAlign.Left);
        fluffTextL.SetAnchor(inkEAnchor.TopRight);
        fluffTextL.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        fluffTextL.BindProperty(n"tintColor", n"MainColors.Red");
        fluffTextL.SetRenderTransformPivot(new Vector2(0.0, 0.5));
        fluffTextL.Reparent(header);

        let fluffTextR: ref<inkText> = new inkText();
        fluffTextR.SetName(n"fluffTextR");
        fluffTextR.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        fluffTextR.SetFontStyle(n"Medium");
        fluffTextR.SetFontSize(20);
        fluffTextR.SetLetterCase(textLetterCase.UpperCase);
        fluffTextR.SetHorizontalAlignment(textHorizontalAlignment.Right);
        fluffTextR.SetFitToContent(true);
        fluffTextR.SetMargin(new inkMargin(0.0, -30.0, 0.0, 0.0));
        fluffTextR.SetHAlign(inkEHorizontalAlign.Right);
        fluffTextR.SetAnchor(inkEAnchor.TopRight);
        fluffTextR.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        fluffTextR.BindProperty(n"tintColor", n"MainColors.Red");
        fluffTextR.SetRenderTransformPivot(new Vector2(1.0, 0.5));
        fluffTextR.Reparent(header);

        this.m_title = title;
        this.m_fluffLeft = fluffTextL;
        this.m_fluffRight = fluffTextR;
        this.SetRootWidget(header);
    }

    public func SetTitle(text: String) {
        this.m_title.SetText(text);
    }

    public func SetFluffLeft(text: String) {
        this.m_fluffLeft.SetText(text);
    }

    public func SetFluffRight(text: String) {
        this.m_fluffRight.SetText(text);
    }

    public static func Create() -> ref<InGamePopupHSHeader> {
        let self: ref<InGamePopupHSHeader> = new InGamePopupHSHeader();
        self.CreateInstance();
        return self;
    }
}

public class VideoSourceWidget extends Practice {
    protected let m_inkVid: wref<inkVideo>;
    protected let m_root: wref<inkCanvas>;

    protected cb func OnCreate() {
        let root = new inkCanvas();
        root.SetName(this.GetClassName());
        root.SetAnchor(inkEAnchor.Fill);

        let video = new inkVideo();
        video.SetVisible(true);
        video.SetVideoPath(r"mod\\assets\\brief_scene_out.bk2");
        video.SetSize(new Vector2(2560, 1340));
        video.SetMargin(new inkMargin(5, 5, 5, 5));
        video.Reparent(root);
        this.m_inkVid = video;
        this.m_root = root;
        this.SetRootWidget(root);
    }

    protected cb func OnInitialize() {
        if IsDefined(this.m_inkVid) {
            this.m_inkVid.Play();
        }

        if IsDefined(this.m_root) {
            let effectName = n"Glitch";
            let effect = new inkGlitchEffect();
            effect.effectName = effectName;
            effect.intensity = 0;
            effect.isEnabled = true;

            let ccEffect = new inkColorCorrectionEffect();
            ccEffect.isEnabled = true;
            ccEffect.effectName = n"ccEffect";
            ccEffect.saturation = 0.4;

            this.m_root.AddEffect(effect);
            this.m_root.AddEffect(ccEffect);

            let i = 0.0;
            let animDef = new inkAnimDef();
            while i < 15.0 {
                let animOpts = new inkAnimOptions();
                let delay = RandRangeF(i * 3.0, i * 8.0);
                let duration = 0.5;
                let value = 0.2;
                animOpts.executionDelay = delay;

                let animEffect = new inkAnimEffect();
                animEffect.SetEffectName(effectName);
                animEffect.SetEffectType(inkEffectType.Glitch);
                animEffect.SetParamName(n"intensity");
                animEffect.SetStartValue(0);
                animEffect.SetEndValue(value);
                animEffect.SetDuration(duration);

                let outEffect = new inkAnimEffect();
                animEffect.SetEffectName(effectName);
                animEffect.SetEffectType(inkEffectType.Glitch);
                animEffect.SetParamName(n"intensity");
                animEffect.SetStartValue(value);
                animEffect.SetEndValue(0.0);
                animEffect.SetDuration(duration);

                animDef.AddInterpolator(animEffect);
                animDef.AddInterpolator(outEffect);

                this.m_root.PlayAnimationWithOptions(animDef, animOpts);
                i += 1.0;
            }
        }
    }
}

public class BriefPopupContent extends InGamePopupContent {
    protected cb func OnCreate() {
        super.OnCreate();
    }

    protected cb func OnInitialize() {
        super.OnInitialize();
    }

    public static func Create() -> ref<BriefPopupContent> {
        let self: ref<BriefPopupContent> = new BriefPopupContent();
        self.CreateInstance();
        return self;
    }
}

public class BriefPopup extends CustomPopup {
    protected let m_header: wref<InGamePopupHSHeader>;
    protected let m_container: wref<inkCompoundWidget>;
    protected let m_content: ref<BriefPopupContent>;
    protected let m_workbench: ref<Workbench>;
    protected let m_translator: ref<LocalizationSystem>;

    protected cb func OnCreate() {
        super.OnCreate();
        this.CreateContainer();
        this.m_translator = LocalizationSystem.GetInstance(this.GetGame());

        this.m_content = BriefPopupContent.Create();
        this.m_content.Reparent(this);

        this.m_header = InGamePopupHSHeader.Create();
        this.m_header.SetTitle(this.m_translator.GetText("SQ-HS-Brief-Title"));
        this.m_header.SetFluffRight(this.m_translator.GetText("(CCXS-COMPRESSED)"));
        this.m_header.Reparent(this);

        this.m_workbench = Workbench.Create();
        this.m_workbench.SetTranslator(this.m_translator);
        this.m_workbench.Reparent(this.m_content);

        this.m_workbench.AddPractice(new VideoSourceWidget());
    }

    protected func CreateContainer() {
        let container: ref<inkCanvas> = new inkCanvas();
        container.SetName(n"container");
        container.SetMargin(new inkMargin(0, 0, 0, 50.0));
        container.SetAnchor(inkEAnchor.Centered);
        container.SetAnchorPoint(new Vector2(0.55, 0.5));
        container.SetSize(new Vector2(2650, 1605));
        container.Reparent(this.GetRootCompoundWidget());
        this.m_container = container;
        this.SetContainerWidget(container);
    }

    public func GetQueueName() -> CName {
        return n"sq_hs_brief_popup";
    }

    protected cb func OnShow() {
        super.OnShow();
        this.SetBackgroundBlur();
    }

    protected cb func OnHide() {
        super.OnHide();
        this.ResetBackgroundBlur();
    }

    protected func SetBackgroundBlur() {
        PopupStateUtils.SetBackgroundBlur(this.m_gameController, true);
    }

    protected func ResetBackgroundBlur() {
        PopupStateUtils.SetBackgroundBlur(this.m_gameController, false);
    }

    public static func Show(requester: ref<inkGameController>) -> ref<BriefPopup> {
        let popup = new BriefPopup();
        popup.Open(requester);
        return popup;
    }

    protected cb func OnGlobalReleaseInput(evt: ref<inkPointerEvent>) -> Bool {
        /*
        if evt.IsAction(this.m_closeAction) && !evt.IsHandled() && this.IsTopPopup() {
            this.Close();
            evt.Handle();
            return true;
        }
        if this.UseCursor() && evt.IsAction(n"mouse_left") {
            if !IsDefined(evt.GetTarget()) || !evt.GetTarget().CanSupportFocus() {
                this.GetGameController().RequestSetFocus(null);
            }
        }
        return false;
        */
        return false;
    }
}
