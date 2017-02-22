package states.game.ui
{
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	public class TeamsListingWindow
	{
		public var view:Sprite = new Sprite();
		private var bg:Quad;
		private var team1TF:TextField;
		private var team2TF:TextField;
		
		public function TeamsListingWindow()
		{
			bg = new Quad(50 , 40, 0x000000);
			
			team1TF = new TextField(50, 20, "");//- Starling 1_7;
			team1TF.color = 0xffffff;
			
			team2TF = new TextField(50, 20, "");//- Starling 1_7;
			team2TF.color = 0xffffff;
			
			view.addChild(bg);
			view.addChild(team1TF);
			view.addChild(team2TF);
			team2TF.y = 20;
		}
		
		public function updateTeams(team1:int, team2:int):void
		{
			team1TF.text = String(team1);
			team2TF.text = String(team2);
		}
		
		public function dispose():void 
		{
			bg.removeFromParent();
			bg = null;
			team1TF.removeFromParent();
			team2TF.removeFromParent();
			team1TF= null;
			team2TF= null;
			view.removeFromParent();
			view = null;
		}
	}
}