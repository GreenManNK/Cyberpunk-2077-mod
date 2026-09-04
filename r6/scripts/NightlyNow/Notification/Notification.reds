module NightlyNow.Notification

import Codeware.UI.VirtualResolutionWatcher
import NightlyNow.Settings.SettingsSystem

// -----------------------------------------------------------------------------
// Notification - NightlyNow Core
// -----------------------------------------------------------------------------
// Just so the abstract inkBorder can be instantiated
public final class NNInkBorder extends inkBorder {
}

public enum NotificationStyle {
    Penalty = 0,
    Reward = 1,
    PartialReward = 2,
    Product = 3,
    Research = 4,
    Ncpd = 5,
    Ambush = 6,
    Disabled = 7,
}

private func PenaltyColor() -> HDRColor = HDRColor(1.0324, 0.13, 0.26, 1.0);

private func RewardColor() -> HDRColor = HDRColor(0.26, 1.1512, 0.5, 1.0);

private func PartialRewardColor() -> HDRColor = HDRColor(1.108, 1.108, 0.0, 1.0);

private func ProductColor() -> HDRColor = HDRColor(1.0432, 0.2, 1.1728, 1.0);

private func ResearchColor() -> HDRColor = HDRColor(0.2, 1.0, 1.1728, 1.0);

private func NcpdColor() -> HDRColor = HDRColor(0.6, 1.0864, 1.216, 1.0);

private func AmbushColor() -> HDRColor = HDRColor(1.216, 1.0, 0.0, 1.0);

private func DisabledColor() -> HDRColor = HDRColor(1.0864, 1.0864, 1.0864, 1.0);

private func SideNotificationBaseX() -> Float = 420.0;

private func SideNotificationBaseY() -> Float = -418.0;

private func SideNotificationYIncrement() -> Float = -80.0;

private func GetNotificationColor(style: NotificationStyle) -> HDRColor {
    if Equals(style, NotificationStyle.Reward) {
        return RewardColor();
    }
    if Equals(style, NotificationStyle.PartialReward) {
        return PartialRewardColor();
    }
    if Equals(style, NotificationStyle.Product) {
        return ProductColor();
    }
    if Equals(style, NotificationStyle.Research) {
        return ResearchColor();
    }
    if Equals(style, NotificationStyle.Ncpd) {
        return NcpdColor();
    }
    if Equals(style, NotificationStyle.Ambush) {
        return AmbushColor();
    }
    if Equals(style, NotificationStyle.Disabled) {
        return DisabledColor();
    }

    return PenaltyColor();
}

private func GetProgressBarIcon(style: NotificationStyle) -> ResRef {
    return r"base\\gameplay\\gui\\widgets\\healthbar\\atlas_nameplate_new.inkatlas";
}

private func GetProgressBarIconTexturePart(style: NotificationStyle) -> CName {
    return n"icon_boss";
}

public struct SideNotification {
    let texts: array<String>;
    let styles: array<SideNotificationStyle>;
}

public enum SideNotificationStyle {
    Drug = 0,
    Positive = 1,
    Danger = 2,
    Warning = 3,
    Information = 4,
    Partial = 5,
}

private func GetSideNotificationColor(style: SideNotificationStyle) -> HDRColor {
    if Equals(style, SideNotificationStyle.Positive) {
        return RewardColor();
    }
    if Equals(style, SideNotificationStyle.Danger) {
        return PenaltyColor();
    }
    if Equals(style, SideNotificationStyle.Warning) {
        return AmbushColor();
    }
    if Equals(style, SideNotificationStyle.Information) {
        return ResearchColor();
    }
    if Equals(style, SideNotificationStyle.Drug) {
        return ProductColor();
    }
    if Equals(style, SideNotificationStyle.Partial) {
        return PartialRewardColor();
    }

    return PenaltyColor();
}

public class NotificationSystem extends ScriptableSystem {
    // Main notification text & anim
    private let mainNotification: wref<inkText>;
    private let anim: ref<inkAnimProxy>;
    // Sub notification text & anim
    private let subNotification: wref<inkText>;
    private let subAnim: ref<inkAnimProxy>;
    // Side notification text (lines)
    private let sideNotifications: array<wref<inkText>>;
    // Progress bar fill widget
    private let progressBar: wref<inkRectangle>;
    // Progress bar border (always full width when visible)
    private let progressBarBorder: wref<inkBorder>;
    // Progress bar icon (left of bar)
    private let progressBarIcon: wref<inkImage>;
    // Progress bar label
    private let progressBarLabel: wref<inkText>;
    // Watcher
    private let resWatcher: ref<VirtualResolutionWatcher>;

    public static func Get() -> ref<NotificationSystem> {
        return GameInstance
            .GetScriptableSystemsContainer(GetGameInstance())
            .Get(n"NightlyNow.Notification.NotificationSystem") as NotificationSystem;
    }

    public func RegisterWidget(
        widget: wref<inkText>,
        subWidget: wref<inkText>,
        sideNotifications: array<wref<inkText>>,
        progressBar: wref<inkRectangle>,
        progressBarBorder: wref<NNInkBorder>,
        progressBarIcon: wref<inkImage>,
        progressBarLabel: wref<inkText>,
        fullScreenSlot: ref<inkCompoundWidget>
    ) {
        this.mainNotification = widget;
        this.subNotification = subWidget;
        this.sideNotifications = sideNotifications;
        this.progressBar = progressBar;
        this.progressBarBorder = progressBarBorder;
        this.progressBarIcon = progressBarIcon;
        this.progressBarLabel = progressBarLabel;
        this.resWatcher = new VirtualResolutionWatcher();
        this.resWatcher.Initialize(GetGameInstance());
        this.resWatcher.ScaleWidget(fullScreenSlot);
    }

    public func ShowNotification(
        text: String,
        style: NotificationStyle,
        opt delayInSeconds: Float,
        opt subText: String
    ) {
        if !IsDefined(this.mainNotification) {
            return;
        }

        // Delay the notification if requested
        if delayInSeconds > 0.0 {
            let notificationDelayCallback = new NotificationDelayCallback();
            notificationDelayCallback.text = text;
            notificationDelayCallback.style = style;
            notificationDelayCallback.subText = subText;
            GameInstance
                .GetDelaySystem(GetGameInstance())
                .DelayCallback(notificationDelayCallback, delayInSeconds, false);
            return;
        }

        this.anim = this
            .AnimateNotificationWidget(this.mainNotification, this.anim, text, GetNotificationColor(style));

        // Sub text - same animations and color, smaller font
        if StrLen(subText) > 0 {
            this.subAnim = this
                .AnimateNotificationWidget(
                    this.subNotification,
                    this.subAnim,
                    subText,
                    GetNotificationColor(style)
                );
        } else {
            if IsDefined(this.subAnim) && this.subAnim.IsPlaying() {
                this.subAnim.Stop();
            }
            this.subNotification.SetVisible(false);
        }
    }

    // Applies text/color and plays the standard notification animation
    private func AnimateNotificationWidget(
        widget: wref<inkText>,
        currentAnim: ref<inkAnimProxy>,
        text: String,
        color: HDRColor
    ) -> ref<inkAnimProxy> {
        if IsDefined(currentAnim) && currentAnim.IsPlaying() {
            currentAnim.Stop();
        }

        widget.SetTintColor(color);
        widget.SetText(text);
        widget.SetVisible(true);

        return widget.PlayAnimation(CreateNotificationAnimDef());
    }

    public func ShowSideNotification(sideNotification: SideNotification, opt multiInteraction: Bool) {
        let settings = SettingsSystem.Get();
        if !settings.enableInformationWidget {
            // Widget disabled
            return;
        }

        let texts = sideNotification.texts;
        let styles = sideNotification.styles;

        // Sort both arrays by SideNotificationStyle value ascending, bubble sort alg, we meet again
        let n = ArraySize(texts);
        let swapped = true;
        while swapped {
            swapped = false;
            let j = 1;
            while j < n {
                if EnumInt(styles[j - 1]) > EnumInt(styles[j]) {
                    let tempText = texts[j - 1];
                    texts[j - 1] = texts[j];
                    texts[j] = tempText;
                    let tempStyle = styles[j - 1];
                    styles[j - 1] = styles[j];
                    styles[j] = tempStyle;
                    swapped = true;
                }
                j += 1;
            }
            n -= 1;
        }

        if multiInteraction {
            // For multi interaction, we need to apply correction so it doesn't nastily overlap the in-game interactions prompts
            this.ApplyMultiInteractionCorretionForSideNotifications(-620, -100);
        }

        let i = 0;
        let sideNotificationCount = ArraySize(this.sideNotifications);
        let textCount = ArraySize(texts);
        while i < sideNotificationCount {
            if i < textCount {
                let sideNotification = this.sideNotifications[i];
                sideNotification.SetVisible(true);
                sideNotification.SetText(texts[i]);
                sideNotification.SetTintColor(GetSideNotificationColor(styles[i]));
            } else {
                this.sideNotifications[i].SetVisible(false);
            }

            i += 1;
        }
    }

    // Show top-center progress bar, percent based
    public func ShowProgressBar(percent: Float, label: String, style: NotificationStyle) {
        let settings = SettingsSystem.Get();
        if !settings.enableProgressBar {
            // Progress bar disabled
            return;
        }

        if !IsDefined(this.progressBar) {
            return;
        }

        if percent <= 0.0 {
            this.HideProgressBar();
            return;
        }

        let clampedPercent = percent;
        if clampedPercent > 100.0 {
            clampedPercent = 100.0;
        }

        let color = GetNotificationColor(style);
        let filledWidth = 1000.0 * clampedPercent / 100.0;

        this.progressBar.SetSize(Vector2(filledWidth, 50.0));
        this.progressBar.SetTintColor(color);
        this.progressBar.SetVisible(true);

        if IsDefined(this.progressBarBorder) {
            this.progressBarBorder.SetTintColor(color);
            this.progressBarBorder.SetVisible(true);
        }

        if IsDefined(this.progressBarIcon) {
            this.progressBarIcon.SetAtlasResource(GetProgressBarIcon(style));
            this
                .progressBarIcon
                .SetTexturePart(GetProgressBarIconTexturePart(style));
            this.progressBarIcon.SetTintColor(color);
            this.progressBarIcon.SetVisible(true);
        }

        if IsDefined(this.progressBarLabel) {
            this.progressBarLabel.SetText(label);
            this.progressBarLabel.SetTintColor(color);
            this.progressBarLabel.SetVisible(true);
        }
    }

    // Hide that motherfucker
    public func HideProgressBar() {
        if !IsDefined(this.progressBar) {
            return;
        }
        this.progressBar.SetVisible(false);
        if IsDefined(this.progressBarBorder) {
            this.progressBarBorder.SetVisible(false);
        }
        if IsDefined(this.progressBarIcon) {
            this.progressBarIcon.SetVisible(false);
        }
        if IsDefined(this.progressBarLabel) {
            this.progressBarLabel.SetVisible(false);
        }
    }

    // Hide that motherfucker
    public func HideSideNotification() {
        for sideNotification in this.sideNotifications {
            sideNotification.SetVisible(false);
        }

        // Remove possibly applied correction for multi interaction
        this.RemoveMultiInteractionCorretionForSideNotifications();
    }

    private func ApplyMultiInteractionCorretionForSideNotifications(xOffset: Int32, yOffset: Int32) {
        for sideNotification in this.sideNotifications {
            sideNotification.SetFitToContent(false);
            sideNotification.SetSize(Vector2(500.0, 80.0));
            sideNotification.SetHorizontalAlignment(textHorizontalAlignment.Center);
            let translation = sideNotification.GetTranslation();
            sideNotification
                .SetTranslation(
                    Vector2(
                        translation.X + Cast<Float>(xOffset),
                        translation.Y + Cast<Float>(yOffset)
                    )
                );
        }
    }

    private func RemoveMultiInteractionCorretionForSideNotifications() {
        let settings = SettingsSystem.Get();
        if !IsDefined(settings) {
            return;
        }

        let i = 0.0;
        for sideNotification in this.sideNotifications {
            // Revert to the left aligned, content sized text
            sideNotification.SetHorizontalAlignment(textHorizontalAlignment.Left);
            sideNotification.SetFitToContent(true);
            sideNotification
                .SetTranslation(
                    Vector2(
                        SideNotificationBaseX() + settings.informationWidgetX,
                        SideNotificationBaseY()
                            + settings.informationWidgetY
                            + i * SideNotificationYIncrement()
                    )
                );
            i += 1.0;
        }
    }
}

// Creates the warp-in + fade-in + fade-out animation used by notifications
private func CreateNotificationAnimDef() -> ref<inkAnimDef> {
    let def = new inkAnimDef();

    // Warp correction. Stretched wide + squished = normal.
    let scale = new inkAnimScale();
    scale.SetStartScale(Vector2(1.8, 0.4));
    scale.SetEndScale(Vector2(1.0, 1.0));
    scale.SetDuration(1);
    scale.SetType(inkanimInterpolationType.Exponential);
    scale.SetMode(inkanimInterpolationMode.EasyOut);
    def.AddInterpolator(scale);

    // Quick fade in. Start above 0 so HDR bloom is preserved.
    let fadeIn = new inkAnimTransparency();
    fadeIn.SetStartTransparency(0.3);
    fadeIn.SetEndTransparency(1.0);
    fadeIn.SetDuration(0.4);
    fadeIn.SetType(inkanimInterpolationType.Exponential);
    fadeIn.SetMode(inkanimInterpolationMode.EasyOut);
    def.AddInterpolator(fadeIn);

    // Fade out. Hold then quickly disappear.
    let fadeOut = new inkAnimTransparency();
    fadeOut.SetStartTransparency(1.0);
    fadeOut.SetEndTransparency(0.0);
    fadeOut.SetStartDelay(5.0);
    fadeOut.SetDuration(0.5);
    fadeOut.SetType(inkanimInterpolationType.Exponential);
    fadeOut.SetMode(inkanimInterpolationMode.EasyIn);
    def.AddInterpolator(fadeOut);

    return def;
}

// Used to fire a delayed notification
private class NotificationDelayCallback extends DelayCallback {
    public let text: String;
    public let style: NotificationStyle;
    public let subText: String;

    public func Call() {
        NotificationSystem.Get().ShowNotification(this.text, this.style, 0.0, this.subText);
    }
}

// --- Widget injection via HUD hook ---
@wrapMethod(healthbarWidgetGameController)
protected cb func OnInitialize() -> Bool {
    let result = wrappedMethod();

    // Parent to the HUD layer root
    let inkHUD = GameInstance
        .GetInkSystem()
        .GetLayer(n"inkHUDLayer")
        .GetVirtualWindow();
    let hudRoot = inkHUD.GetWidgetByPathName(n"Root") as inkCompoundWidget;
    if !IsDefined(hudRoot) {
        return result;
    }

    // NightlyNow Core settings
    let settings = SettingsSystem.Get();

    // Full-screen overlay canvas (4k, scaled by VirtualResolutionWatcher)
    let canvas = new inkCanvas();
    canvas.SetName(n"NNNotificationCanvas");
    canvas.SetSize(Vector2(3840.0, 2160.0));
    canvas.SetRenderTransformPivot(Vector2(0.0, 0.0));
    canvas.SetInteractive(false);
    canvas.Reparent(hudRoot);

    // Centered notification text
    let text = new inkText();
    text.SetName(n"NNNotificationMainText");
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Medium");
    text.SetFontSize(130);
    text.SetTintColor(RewardColor());
    text.SetAnchor(inkEAnchor.TopCenter);
    text.SetAnchorPoint(Vector2(0.5, 0.0));
    text.SetHAlign(inkEHorizontalAlign.Center);
    text.SetTranslation(Vector2(0.0, 600.0));
    text.SetVisible(false);
    text.SetOpacity(0.0);
    text.Reparent(canvas);

    // Sub notification text (below main, smaller font)
    let subText = new inkText();
    subText.SetName(n"NNNotificationSubText");
    subText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    subText.SetFontStyle(n"Medium");
    subText.SetFontSize(80);
    subText.SetTintColor(RewardColor());
    subText.SetAnchor(inkEAnchor.TopCenter);
    subText.SetAnchorPoint(Vector2(0.5, 0.0));
    subText.SetHAlign(inkEHorizontalAlign.Center);
    subText.SetTranslation(Vector2(0.0, 800.0));
    subText.SetVisible(false);
    subText.SetOpacity(0.0);
    subText.Reparent(canvas);

    // Progress bar fill (top center)
    let progressBar = new inkRectangle();
    progressBar.SetName(n"NNProgressBarFill");
    progressBar.SetSize(Vector2(1000.0, 50.0));
    progressBar.SetTintColor(ResearchColor());
    progressBar.SetAnchor(inkEAnchor.TopCenter);
    progressBar.SetAnchorPoint(Vector2(0.0, 0.0));
    progressBar.SetTranslation(Vector2(-500.0, 140.0 + settings.progressBarY));
    progressBar.SetVisible(false);
    progressBar.Reparent(canvas);

    // Progress bar border
    let progressBarBorder = new NNInkBorder();
    progressBarBorder.SetName(n"NNProgressBarBorder");
    progressBarBorder.SetSize(Vector2(1000.0, 50.0));
    progressBarBorder.SetThickness(3.0);
    progressBarBorder.SetTintColor(ResearchColor());
    progressBarBorder.SetAnchor(inkEAnchor.TopCenter);
    progressBarBorder.SetAnchorPoint(Vector2(0.5, 0.0));
    progressBarBorder.SetTranslation(Vector2(0.0, 140.0 + settings.progressBarY));
    progressBarBorder.SetVisible(false);
    progressBarBorder.Reparent(canvas);

    // Progress bar icon
    let progressBarIcon = new inkImage();
    progressBarIcon.SetName(n"NNProgressBarIcon");
    progressBarIcon.SetSize(Vector2(60.0, 60.0));
    progressBarIcon.SetTintColor(ResearchColor());
    progressBarIcon.SetAnchor(inkEAnchor.TopCenter);
    progressBarIcon.SetAnchorPoint(Vector2(1.0, 0.0));
    progressBarIcon.SetTranslation(Vector2(-515.0, 135.0 + settings.progressBarY));
    progressBarIcon.SetVisible(false);
    progressBarIcon.Reparent(canvas);

    // Progress bar label
    let progressBarLabel = new inkText();
    progressBarLabel.SetName(n"NNProgressBarLabel");
    progressBarLabel.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    progressBarLabel.SetFontStyle(n"Medium");
    progressBarLabel.SetFontSize(50);
    progressBarLabel.SetTintColor(ResearchColor());
    progressBarLabel.SetAnchor(inkEAnchor.TopCenter);
    progressBarLabel.SetAnchorPoint(Vector2(0.5, 1.0));
    progressBarLabel.SetHAlign(inkEHorizontalAlign.Center);
    progressBarLabel.SetTranslation(Vector2(-40.0, 120.0 + settings.progressBarY));
    progressBarLabel.SetVisible(false);
    progressBarLabel.Reparent(canvas);

    // Side notification texts (lines)
    let sideNotifications: array<wref<inkText>> = [];

    let i = 0.0;
    while i < 5.0 {
        ArrayPush(
            sideNotifications,
            InitSideNotification(
                StringToName("NNSideNotificationLine" + ToString(Cast<Int32>(i))),
                Vector2(
                    SideNotificationBaseX() + settings.informationWidgetX,
                    SideNotificationBaseY()
                        + settings.informationWidgetY
                        + i * SideNotificationYIncrement()
                ),
                canvas
            )
        );
        i += 1.0;
    }

    NotificationSystem
        .Get()
        .RegisterWidget(
            text,
            subText,
            sideNotifications,
            progressBar,
            progressBarBorder,
            progressBarIcon,
            progressBarLabel,
            canvas
        );

    return result;
}

// Initialization of side notification text widget (line)
private func InitSideNotification(widgetName: CName, translation: Vector2, canvas: ref<inkCanvas>) -> ref<inkText> {
    let sideNotification = new inkText();
    sideNotification.SetName(widgetName);
    sideNotification.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    sideNotification.SetFontStyle(n"Medium");
    sideNotification.SetFontSize(50);
    sideNotification.SetTintColor(AmbushColor());
    sideNotification.SetAnchor(inkEAnchor.BottomCenter);
    sideNotification.SetHAlign(inkEHorizontalAlign.Left);
    sideNotification.SetTranslation(translation);
    sideNotification.SetVisible(false);
    sideNotification.SetOpacity(1.0);
    sideNotification.Reparent(canvas);

    return sideNotification;
}

