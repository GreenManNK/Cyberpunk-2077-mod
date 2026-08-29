//Cyberpunk 2077 Browser Extension Framework
//by r457 & gh057

//temporary solution, need to rework to use scroll widget

module HomePagePagination

public class CustomBrowserInputListener {
	private let m_gameController: wref<BrowserGameController>;
	
	public let m_pageNumber: Int32 = 0;
	
	public final func Init(gameController: ref<BrowserGameController>) -> Void {
		this.m_gameController = gameController;
	}
	
	protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
		if !this.m_gameController.IsHomePage() {
			return false;
		};
		
		if Equals(ListenerAction.GetName(action), n"UI_MoveDown") {
			if ListenerAction.IsButtonJustPressed(action) {
				this.m_pageNumber = this.m_gameController.HomePageScrollDown();
			};
		} else {
			if Equals(ListenerAction.GetName(action), n"UI_MoveUp") {
				if ListenerAction.IsButtonJustPressed(action) {
					this.m_pageNumber = this.m_gameController.HomePageScrollUp();
				};
			};
		};
	}
}
