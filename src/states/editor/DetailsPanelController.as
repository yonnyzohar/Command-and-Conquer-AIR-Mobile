package states.editor
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import com.greensock.TweenLite;
	import starling.events.EventDispatcher;
	import global.Parameters;

	public class DetailsPanelController extends EventDispatcher
	{
		public var view:GameSprite;
		private var state:String = "out";
		private var team1Pane:TeamDetailsPane;
		private var team2Pane:TeamDetailsPane;
		
		public static var team1Controller:int;
		public static var team2Controller:int;
		
		public static var team1StartCash:int;
		public static var team2StartCash:int;
		
		public static var team1Behaviour:int;
		public static var team2Behaviour:int;
		
		
		public function DetailsPanelController()
		{
			view = TemplateLoader.get("DetailsPanelMC");
			var arr:Array = [view.player1, view.player2];
			
			team1Pane = new TeamDetailsPane(view.player1, 0);
			team2Pane = new TeamDetailsPane(view.player2, 1);
			
			
			ButtonManager.setButton(view.xButton, "TOUCH", onXClicked);
			//view.detailsMC.addEventListener(MouseEvent.CLICK, onDetailsClicked)
			setData();
			
		}
		
		private function onXClicked(caller:GameSprite):void
		{
			setData();
			view.visible = false;
		}
		

		
		public function setData():void
		{
			team1Controller = team1Pane.getController();
			team2Controller = team2Pane.getController();
			
			team1StartCash = team1Pane.getStartCash();
			team2StartCash = team2Pane.getStartCash();
			
			team1Behaviour = team1Pane.getBehaviour();
			team2Behaviour = team2Pane.getBehaviour();
		}
		
		public function dispose():void
		{
			
			ButtonManager.removeButtonEvents(view.xButton);
			ButtonManager.removeButtonEvents(view.detailsMC);
			

			team1Pane.dispose();
			team2Pane.dispose();
			team1Pane = null
			team2Pane = null;
			view.dispose();
			view = null;
		}
			
		
	}
}