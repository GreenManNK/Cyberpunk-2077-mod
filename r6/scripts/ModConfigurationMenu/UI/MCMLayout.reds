module ModConfigurationMenu.UI

public class MCMLayoutRect extends IScriptable {
  public let x: Float;
  public let y: Float;
  public let width: Float;
  public let height: Float;
}

public class MCMLayoutSpec extends IScriptable {
  public let hostWidth: Float;
  public let hostHeight: Float;
  public let safeLeft: Float;
  public let safeTop: Float;
  public let safeRight: Float;
  public let safeBottom: Float;
  public let hostDensity: Float;
  public let requestedScale: Float;
  public let requestedProfile: Int32;
  public let showDescription: Bool;
  public let bottomActionRows: Int32;
  public let sidebarActionRows: Int32;
}

public class MCMLayoutSnapshot extends IScriptable {
  public let profile: Int32;
  public let uniformScale: Float;
  public let offsetX: Float;
  public let offsetY: Float;
  public let frameVisible: Bool;
  public let descriptionVisible: Bool;
  public let canvas: ref<MCMLayoutRect>;
  public let headerTitle: ref<MCMLayoutRect>;
  public let headerSubtitle: ref<MCMLayoutRect>;
  public let sidebarTitle: ref<MCMLayoutRect>;
  public let sidebarSearch: ref<MCMLayoutRect>;
  public let sidebar: ref<MCMLayoutRect>;
  public let contentTitle: ref<MCMLayoutRect>;
  public let contentSearch: ref<MCMLayoutRect>;
  public let content: ref<MCMLayoutRect>;
  public let description: ref<MCMLayoutRect>;
  public let status: ref<MCMLayoutRect>;
  public let modal: ref<MCMLayoutRect>;
  public let sidebarInnerWidth: Float;
  public let sidebarRowHeight: Float;
  public let contentInnerWidth: Float;
  public let contentRowHeight: Float;
  public let contentControlHeight: Float;
  public let contentMarkerX: Float;
  public let contentMarkerWidth: Float;
  public let contentMarkerGap: Float;
  public let contentLabelX: Float;
  public let contentLabelWidth: Float;
  public let contentControlLeft: Float;
  public let contentControlRight: Float;
  public let contentLabelControlGap: Float;
  public let bottomActionY: Float;
  public let actionRightX: Float;
  public let topActionMinX: Float;
  public let topActionY: Float;
  public let topActionMaxWidth: Float;
  public let modalVerticalOffset: Float;
  public let modalMessageMaxHeight: Float;
  public let modalInputMessageMaxHeight: Float;
}

public abstract class MCMLayout {
  private static func Rect(
    x: Float,
    y: Float,
    width: Float,
    height: Float
  ) -> ref<MCMLayoutRect> {
    let result: ref<MCMLayoutRect> = new MCMLayoutRect();
    result.x = x;
    result.y = y;
    result.width = MaxF(0.0, width);
    result.height = MaxF(0.0, height);
    return result;
  }

  private static func Contains(
    parent: ref<MCMLayoutRect>,
    child: ref<MCMLayoutRect>
  ) -> Bool {
    return IsDefined(parent) && IsDefined(child)
      && child.x >= parent.x && child.y >= parent.y
      && child.x + child.width <= parent.x + parent.width
      && child.y + child.height <= parent.y + parent.height;
  }

  private static func CanvasWidth() -> Float {
    return 1920.0;
  }

  private static func CanvasHeight() -> Float {
    return 1080.0;
  }

  private static func ProfileScale(profile: Int32) -> Float {
    if profile == 2 {
      return 0.83333333;
    };
    if profile == 3 {
      return 0.625;
    };
    return 1.0;
  }

  private static func FitScale(
    availableWidth: Float,
    availableHeight: Float
  ) -> Float {
    return MinF(
      availableWidth / MCMLayout.CanvasWidth(),
      availableHeight / MCMLayout.CanvasHeight()
    );
  }

  private static func RequestedScale(
    spec: ref<MCMLayoutSpec>,
    profile: Int32
  ) -> Float {
    return MaxF(
      0.10,
      spec.hostDensity * spec.requestedScale * MCMLayout.ProfileScale(profile)
    );
  }

  private static func ResolveProfile(
    spec: ref<MCMLayoutSpec>,
    availableWidth: Float,
    availableHeight: Float
  ) -> Int32 {
    let requestedProfile: Int32 = Clamp(spec.requestedProfile, 0, 3);
    if requestedProfile > 0 {
      return requestedProfile;
    };
    let fitScale: Float = MCMLayout.FitScale(availableWidth, availableHeight);
    if fitScale + 0.001 >= MCMLayout.RequestedScale(spec, 1) {
      return 1;
    };
    if fitScale + 0.001 >= MCMLayout.RequestedScale(spec, 2) {
      return 2;
    };
    return 3;
  }

  public static func HostSpec(
    hostWidth: Float,
    hostHeight: Float,
    safeLeft: Float,
    safeTop: Float,
    safeRight: Float,
    safeBottom: Float,
    hostDensity: Float,
    requestedScale: Float,
    requestedProfile: Int32,
    showDescription: Bool,
    bottomActionRows: Int32,
    sidebarActionRows: Int32
  ) -> ref<MCMLayoutSpec> {
    let spec: ref<MCMLayoutSpec> = new MCMLayoutSpec();
    spec.hostWidth = MaxF(1.0, hostWidth);
    spec.hostHeight = MaxF(1.0, hostHeight);
    spec.safeLeft = MaxF(0.0, safeLeft);
    spec.safeTop = MaxF(0.0, safeTop);
    spec.safeRight = MaxF(0.0, safeRight);
    spec.safeBottom = MaxF(0.0, safeBottom);
    if spec.safeLeft + spec.safeRight >= spec.hostWidth {
      spec.safeLeft = 0.0;
      spec.safeRight = 0.0;
    };
    if spec.safeTop + spec.safeBottom >= spec.hostHeight {
      spec.safeTop = 0.0;
      spec.safeBottom = 0.0;
    };
    spec.hostDensity = hostDensity > 0.0 ? hostDensity : 1.0;
    spec.requestedScale = ClampF(requestedScale, 0.50, 1.50);
    spec.requestedProfile = Clamp(requestedProfile, 0, 3);
    spec.showDescription = showDescription;
    spec.bottomActionRows = Max(1, bottomActionRows);
    spec.sidebarActionRows = Max(0, sidebarActionRows);
    return spec;
  }

  public static func Build(spec: ref<MCMLayoutSpec>) -> ref<MCMLayoutSnapshot> {
    let snapshot: ref<MCMLayoutSnapshot> = new MCMLayoutSnapshot();
    let availableWidth: Float = MaxF(
      1.0,
      spec.hostWidth - spec.safeLeft - spec.safeRight
    );
    let availableHeight: Float = MaxF(
      1.0,
      spec.hostHeight - spec.safeTop - spec.safeBottom
    );
    let profile: Int32 = MCMLayout.ResolveProfile(
      spec,
      availableWidth,
      availableHeight
    );
    let requestedUniformScale: Float = MCMLayout.RequestedScale(spec, profile);
    let canvasWidth: Float = MCMLayout.CanvasWidth();
    let canvasHeight: Float = MCMLayout.CanvasHeight();
    let uniformScale: Float = MaxF(
      0.10,
      MinF(
        requestedUniformScale,
        MCMLayout.FitScale(availableWidth, availableHeight)
      )
    );

    let bodyY: Float = 198.0;
    let outerInset: Float = 16.0;
    let sidebarWidth: Float = 440.0;
    let sidebarContentGap: Float = 29.0;
    let preferredContentWidth: Float = 980.0;
    let descriptionGap: Float = 25.0;
    let sidebarSearchWidth: Float = 190.0;
    let contentSearchWidth: Float = 250.0;
    let headerTitleX: Float = 88.0;
    let headerTitleY: Float = 48.0;
    let headerTitleWidth: Float = 700.0;
    let actionRightInset: Float = 144.0;
    let topActionMaxWidth: Float = 176.0;
    let modalVerticalOffset: Float = -125.0;
    let modalMessageMaxHeight: Float = 450.0;
    let modalInputMessageMaxHeight: Float = 400.0;

    let bodyHeight: Float = MaxF(1.0, canvasHeight - bodyY - 120.0);
    let effectiveBottomActionRows: Int32 = Max(1, spec.bottomActionRows);
    let contentHeight: Float = MaxF(
      1.0,
      bodyHeight
        - Cast<Float>(Max(0, effectiveBottomActionRows - 1)) * 54.0
    );
    let sidebarHeight: Float = MaxF(
      1.0,
      bodyHeight - Cast<Float>(Max(0, spec.sidebarActionRows - 1)) * 54.0
    );
    let contentX: Float = outerInset + sidebarWidth + sidebarContentGap;
    let descriptionVisible: Bool = spec.showDescription;
    let contentWidth: Float = descriptionVisible
      ? preferredContentWidth
      : canvasWidth - contentX - outerInset;

    snapshot.profile = profile;
    snapshot.uniformScale = uniformScale;
    snapshot.offsetX = spec.safeLeft
      + MaxF(0.0, (availableWidth - (canvasWidth * uniformScale)) / 2.0);
    snapshot.offsetY = spec.safeTop
      + MaxF(0.0, (availableHeight - (canvasHeight * uniformScale)) / 2.0);
    snapshot.frameVisible = uniformScale + 0.001 < spec.hostDensity;
    snapshot.descriptionVisible = descriptionVisible;
    snapshot.canvas = MCMLayout.Rect(0.0, 0.0, canvasWidth, canvasHeight);
    snapshot.headerTitle = MCMLayout.Rect(
      headerTitleX,
      headerTitleY,
      headerTitleWidth,
      64.0
    );
    snapshot.headerSubtitle = MCMLayout.Rect(
      headerTitleX + 2.0,
      headerTitleY + 52.0,
      headerTitleWidth,
      38.0
    );
    snapshot.sidebar = MCMLayout.Rect(
      outerInset,
      bodyY,
      sidebarWidth,
      sidebarHeight
    );
    snapshot.sidebarTitle = MCMLayout.Rect(
      snapshot.sidebar.x + 2.0,
      bodyY - 48.0,
      snapshot.sidebar.width - 40.0,
      46.0
    );
    snapshot.sidebarSearch = MCMLayout.Rect(
      snapshot.sidebar.x + snapshot.sidebar.width - 6.0 - sidebarSearchWidth,
      snapshot.sidebarTitle.y + 4.0,
      sidebarSearchWidth,
      38.0
    );
    snapshot.content = MCMLayout.Rect(
      contentX,
      bodyY,
      contentWidth,
      contentHeight
    );
    snapshot.contentTitle = MCMLayout.Rect(
      snapshot.content.x,
      bodyY - 48.0,
      snapshot.content.width,
      46.0
    );
    snapshot.contentSearch = MCMLayout.Rect(
      snapshot.content.x + snapshot.content.width - 6.0 - contentSearchWidth,
      snapshot.contentTitle.y + 4.0,
      contentSearchWidth,
      38.0
    );
    if descriptionVisible {
      snapshot.description = MCMLayout.Rect(
        snapshot.content.x + snapshot.content.width + descriptionGap,
        bodyY,
        canvasWidth
          - (snapshot.content.x + snapshot.content.width + descriptionGap)
          - outerInset,
        bodyHeight
      );
    } else {
      snapshot.description = MCMLayout.Rect(
        snapshot.content.x + snapshot.content.width,
        bodyY,
        0.0,
        bodyHeight
      );
    };
    snapshot.status = MCMLayout.Rect(
      snapshot.headerTitle.x + 2.0,
      canvasHeight - 68.0,
      canvasWidth - ((snapshot.headerTitle.x + 2.0) * 2.0) - 20.0,
      36.0
    );

    let modalWidth: Float = MinF(540.0, canvasWidth - 64.0);
    snapshot.modal = MCMLayout.Rect(
      (canvasWidth - modalWidth) / 2.0,
      0.0,
      modalWidth,
      canvasHeight
    );
    snapshot.sidebarInnerWidth = MaxF(1.0, snapshot.sidebar.width - 34.0);
    snapshot.sidebarRowHeight = 48.0;
    snapshot.contentInnerWidth = MaxF(1.0, snapshot.content.width - 50.0);
    snapshot.contentRowHeight = 48.0;
    snapshot.contentControlHeight = 42.0;
    snapshot.contentMarkerX = 20.0;
    snapshot.contentMarkerWidth = 20.0;
    snapshot.contentMarkerGap = 8.0;
    snapshot.contentLabelX = snapshot.contentMarkerX
      + snapshot.contentMarkerWidth + snapshot.contentMarkerGap;
    snapshot.contentLabelControlGap = 16.0;
    snapshot.contentControlRight = snapshot.contentInnerWidth;
    snapshot.contentControlLeft = ClampF(
      snapshot.content.width * 0.48979592,
      snapshot.contentLabelX + snapshot.contentLabelControlGap + 220.0,
      snapshot.contentControlRight - 240.0
    );
    snapshot.contentLabelWidth = MaxF(
      1.0,
      snapshot.contentControlLeft
        - snapshot.contentLabelX - snapshot.contentLabelControlGap
    );
    snapshot.bottomActionY = bodyY + bodyHeight + 6.0;
    snapshot.actionRightX = canvasWidth - actionRightInset;
    snapshot.topActionMinX = snapshot.headerTitle.x
      + snapshot.headerTitle.width + 20.0;
    snapshot.topActionY = 62.0;
    snapshot.topActionMaxWidth = topActionMaxWidth;
    snapshot.modalVerticalOffset = modalVerticalOffset;
    snapshot.modalMessageMaxHeight = modalMessageMaxHeight;
    snapshot.modalInputMessageMaxHeight = modalInputMessageMaxHeight;
    return snapshot;
  }

  public static func IsValid(snapshot: ref<MCMLayoutSnapshot>) -> Bool {
    if !IsDefined(snapshot) || !IsDefined(snapshot.canvas)
      || snapshot.profile < 1 || snapshot.profile > 3
      || snapshot.uniformScale <= 0.0
      || snapshot.canvas.width <= 0.0 || snapshot.canvas.height <= 0.0 {
      return false;
    };
    if !MCMLayout.Contains(snapshot.canvas, snapshot.headerTitle)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.headerSubtitle)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.sidebarTitle)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.sidebarSearch)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.sidebar)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.contentTitle)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.contentSearch)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.content)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.description)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.status)
      || !MCMLayout.Contains(snapshot.canvas, snapshot.modal) {
      return false;
    };
    if snapshot.sidebar.x + snapshot.sidebar.width > snapshot.content.x {
      return false;
    };
    if snapshot.descriptionVisible
      && snapshot.content.x + snapshot.content.width > snapshot.description.x {
      return false;
    };
    if snapshot.contentControlLeft <= snapshot.contentLabelX
      || snapshot.contentControlRight <= snapshot.contentControlLeft
      || snapshot.contentControlRight > snapshot.content.width
      || snapshot.contentLabelWidth <= 0.0
      || snapshot.actionRightX <= snapshot.content.x
      || snapshot.actionRightX > snapshot.canvas.width
      || snapshot.topActionMinX < 0.0
      || snapshot.topActionMinX >= snapshot.actionRightX
      || snapshot.topActionY < 0.0
      || snapshot.topActionY >= snapshot.canvas.height
      || snapshot.topActionMaxWidth <= 0.0
      || snapshot.modalMessageMaxHeight <= 0.0
      || snapshot.modalInputMessageMaxHeight <= 0.0 {
      return false;
    };
    return true;
  }

  public static func PanelTitleFontSize() -> Int32 {
    return 34;
  }

  public static func LeftProviderWidth() -> Float {
    return 40.0;
  }

  public static func LeftProviderGap() -> Float {
    return 0.0;
  }

  public static func LeftFavoriteWidth() -> Float {
    return 32.0;
  }

  public static func LeftFavoriteGap() -> Float {
    return 4.0;
  }

  public static func ListRowTextLeftInset(textOnly: Bool) -> Float {
    return textOnly ? 4.0 : 16.0;
  }

  public static func ListRowTextRightInset(textOnly: Bool) -> Float {
    return textOnly ? 8.0 : 32.0;
  }

  public static func SearchInputHeight() -> Float {
    return 38.0;
  }

  public static func SearchInputFontSize() -> Int32 {
    return 19;
  }

  public static func SearchInputInactiveOpacity() -> Float {
    return 0.30;
  }

  public static func SearchTitleGap() -> Float {
    return 16.0;
  }

  public static func NativeSettingsRowWidth() -> Float {
    return 1800.0;
  }

  public static func NativeSettingsRowHeight() -> Float {
    return 80.0;
  }

  public static func ContentMessageInsetX() -> Float {
    return 20.0;
  }

  public static func ContentMessagePaddingY() -> Float {
    return 4.0;
  }

  public static func ContentTextFontSize() -> Int32 {
    return 22;
  }

  public static func DescriptionFontSize() -> Int32 {
    return 20;
  }

  public static func DescriptionPreviewSideInset() -> Float {
    return 12.0;
  }

  public static func DescriptionPreviewTopInset() -> Float {
    return 86.0;
  }

  public static func DescriptionPreviewBottomInset() -> Float {
    return 12.0;
  }

  public static func ActionGap() -> Float {
    return 20.0;
  }

  public static func ActionTextNativeFontSize() -> Int32 {
    return 50;
  }

  public static func ActionTextNativeScale() -> Float {
    return 0.5;
  }

  public static func ActionPaddingX() -> Float {
    return 20.0;
  }

  public static func ActionMinWidth() -> Float {
    return 80.0;
  }

  public static func ActionMaxWidth() -> Float {
    return 280.0;
  }

  public static func ActionFallbackWidth() -> Float {
    return 180.0;
  }

  public static func TextMeasurementCacheLimit() -> Int32 {
    return 512;
  }

  public static func TextMeasurementPassLimit() -> Int32 {
    return 12;
  }

  public static func TextMeasurementSettlePassLimit() -> Int32 {
    return 6;
  }

  public static func ModalPaddingX() -> Float {
    return 24.0;
  }

  public static func ModalTitleY() -> Float {
    return 14.0;
  }

  public static func ModalIconX() -> Float {
    return 20.0;
  }

  public static func ModalIconY() -> Float {
    return 15.0;
  }

  public static func ModalIconWidth() -> Float {
    return 32.0;
  }

  public static func ModalIconHeight() -> Float {
    return 28.0;
  }

  public static func ModalTitleSeparatorX() -> Float {
    return 64.0;
  }

  public static func ModalTitleX() -> Float {
    return 78.0;
  }

  public static func ModalMessageY() -> Float {
    return 58.0;
  }

  public static func ModalMessageMinHeight() -> Float {
    return 32.0;
  }

  public static func ModalSectionGap() -> Float {
    return 12.0;
  }

  public static func ModalInputHeight() -> Float {
    return 40.0;
  }

  public static func ModalInputFontSize() -> Int32 {
    return 20;
  }

  public static func ModalActionHeight() -> Float {
    return 44.0;
  }

  public static func ModalBottomPadding() -> Float {
    return 18.0;
  }

  public static func ModalActionGap() -> Float {
    return 6.0;
  }

  public static func ModalTitleAccentWidth() -> Float {
    return 12.0;
  }

  public static func ModalTitleAccentHeight() -> Float {
    return 34.0;
  }
}

public abstract class MCMColors {
  public static func Background() -> CName {
    return n"MainColors.Fullscreen_PrimaryBackgroundDarkest";
  }

  public static func Panel() -> CName {
    return n"MainColors.Fullscreen_PrimaryBackgroundDark";
  }

  public static func PanelSelected() -> CName {
    return n"MainColors.DarkBlue";
  }

  public static func Blue() -> CName {
    return n"MainColors.Blue";
  }

  public static func Red() -> CName {
    return n"MainColors.Red";
  }

  public static func Success() -> CName {
    return n"MainColors.Green";
  }

  public static func Modified() -> CName {
    return n"MainColors.LightPurple";
  }

  public static func Favorite() -> CName {
    return n"MainColors.Gold";
  }

  public static func Text() -> CName {
    return n"MainColors.White";
  }

  public static func Muted() -> CName {
    return n"MainColors.MildBlue";
  }
}
