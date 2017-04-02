package states.editor
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import starling.events.EventDispatcher;
	import global.Parameters;

	public class DetailsPanelController extends EventDispatcher
	{
		public var view:GameSprite;
		private var teamPane:TeamDetailsPane;

		
		public function DetailsPanelController()
		{
			view = TemplateLoader.get("DetailsPanelMC");
			//teamPane = new TeamDetailsPane(view.playerBlock, 0);

			ButtonManager.setButton(view.xButton, "TOUCH", onXClicked);
			
		}
		
		private function onXClicked(caller:GameSprite):void
		{
			view.visible = false;
		}
		

		
		
		public function dispose():void
		{
			
			ButtonManager.removeButtonEvents(view.xButton);
			

			teamPane = null
			view.dispose();
			view = null;
		}
			
		
	}
}