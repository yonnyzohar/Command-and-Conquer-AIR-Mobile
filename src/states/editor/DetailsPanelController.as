package states.editor
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import starling.events.EventDispatcher;
	import global.Parameters;
	import states.game.stats.LevelManager;

	public class DetailsPanelController extends EventDispatcher
	{
		public var view:GameSprite;
		
		private var colorsArr:Array = [];
		private var controllers:Array = [];
		private var weaponsProviders:Array = [];
		private var boxesCont:GameSprite;
		private var teamCount:int = 0;
		
		public var teamsArr:Array = [];
		public var currentTech:int = 1;
		
		private var currentObj:Object;

		
		public function DetailsPanelController()
		{
			view = TemplateLoader.get("DetailsPanelMC");
			//teamPane = new TeamDetailsPane(view.playerBlock, 0);
			boxesCont = new GameSprite();
			view.tilesTXT.text = currentTech;
			ButtonManager.setButton(view.addRowBTN, "TOUCH", increateTech);
			ButtonManager.setButton(view.removeRowBTN, "TOUCH", decreaseTech);
			
			
			view.playerBlock.teamMC.text = "";
			
			
			ButtonManager.setButton(view.playerBlock.humanMC  , "TOUCH", onControllerClicked);
			ButtonManager.setButton(view.playerBlock.pcMC	  , "TOUCH", onControllerClicked);
			
			ButtonManager.setButton(view.playerBlock.yellowMC , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.redMC	  , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.tealMC	  , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.orangeMC , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.greenMC	 , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.grayMC	  , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.brownMC	 , "TOUCH", onColorClicked);
			
			ButtonManager.setButton(view.playerBlock.gdiSide	 , "TOUCH", onWeaponsProviderClicked);
			ButtonManager.setButton(view.playerBlock.nodSide	 , "TOUCH", onWeaponsProviderClicked);
			
			
			view.playerBlock.humanMC.textBox.text = "HUMAN";
			view.playerBlock.pcMC.textBox.text = "PC";
			
			controllers = [
				view.playerBlock.humanMC,
			    view.playerBlock.pcMC	
			];
			
			colorsArr = [
			
				view.playerBlock.yellowMC ,
				view.playerBlock.redMC	 ,
				view.playerBlock.tealMC	 ,
				view.playerBlock.orangeMC ,
				view.playerBlock.greenMC	 ,
				view.playerBlock.grayMC	 ,
				view.playerBlock.brownMC	 

			];
			
			weaponsProviders = [
			
				view.playerBlock.gdiSide,
				view.playerBlock.nodSide
			
			];
			

			
			
			view.playerBlock.gdiSide.textBox.text = "GDI";
			view.playerBlock.nodSide.textBox.text = "NOD";
			
			view.goMC.textBox.text = "GO";
			
			ButtonManager.setButton(view.goMC, "TOUCH", onGoClicked);
			ButtonManager.setButton(view.plusBtn, "TOUCH", addTeam);
			ButtonManager.setButton(view.minusBtn, "TOUCH", removeTeam);


			ButtonManager.setButton(view.xButton, "TOUCH", onXClicked);
			
			
			
			view.addChild(boxesCont);
			boxesCont.x = view.bg.x;
			boxesCont.y = view.bg.y;
			
			view.playerBlock.visible = false;
			
			
			
			addTeam(null);
			
		}
		
		
		
		private function removeTeam(caller:GameSprite):void 
		{
			var obj:Object = teamsArr.pop();
			if (obj && obj.btn)
			{
				ButtonManager.removeButtonEvents(obj.btn);
				obj.btn.removeFromParent(true);
				teamCount--;
			}
			else
			{
				view.playerBlock.visible = false;
			}
			
		}
		
		private function addTeam(caller:GameSprite):void 
		{
			teamCount++;
			var box:GameSprite = TemplateLoader.get("SmallText");
			ButtonManager.setButton(box, "TOUCH", onBoxClicked);
			box.width = view.bg.width;
			box.textBox.text = "Team" + teamCount;
			box.y = box.height * teamsArr.length;
			box.alpha = 0.8;
			teamsArr.push( {btn: box, obj : getDefaultObj()});
			boxesCont.addChild(box);
		}
		
		private function getDefaultObj():Object 
		{
			var o:Object = { };
			o.weaponsProvider = "gdiSide";
			o.controller = "humanMC";
			o.color = "yellowMC";
			
			return o;
		}
		
		private function onBoxClicked(caller:GameSprite):void 
		{
			var o:Object;
			for (var i:int = 0; i < teamsArr.length; i++ )
			{
				teamsArr[i].btn.alpha = 0.8;
				if (caller == teamsArr[i].btn)
				{
					caller.alpha = 1;
					o = teamsArr[i].obj;
				}
			}
			
			view.playerBlock.visible = true;
			currentObj = o;
			view.playerBlock.teamMC.text = caller.textBox.text;
			o.teamName = caller.textBox.text;
			onControllerClicked(view.playerBlock[o.controller]);
			onColorClicked(view.playerBlock[o.color]);
			onWeaponsProviderClicked(view.playerBlock[o.weaponsProvider]);
			
			
		}
		
		private function onWeaponsProviderClicked(caller:GameSprite):void 
		{
			for (var i:int = 0; i < weaponsProviders.length; i++ )
			{
				weaponsProviders[i].alpha = 0.2;
			}
			caller.alpha = 1;
			currentObj.weaponsProvider = caller.name;
		}
		
		
		private function onControllerClicked(caller:GameSprite):void 
		{
			for (var i:int = 0; i < controllers.length; i++ )
			{
				controllers[i].alpha = 0.2;
			}
			caller.alpha = 1;
			currentObj.controller = caller.name;
		}
		
		private function onColorClicked(caller:GameSprite):void 
		{
			for (var i:int = 0; i < colorsArr.length; i++ )
			{
				colorsArr[i].alpha = 0.2;
			}
			caller.alpha = 1;
			currentObj.color = caller.name;
		}
		
		private function increateTech(caller:GameSprite):void
		{
			currentTech++;
			view.tilesTXT.text = currentTech;
		}
		
		private function decreaseTech(caller:GameSprite):void
		{
			currentTech--;
			view.tilesTXT.text = currentTech;
		}
		
		private function onXClicked(caller:GameSprite):void
		{
			view.visible = false;
		}
		
		
		private function onGoClicked(caller:GameSprite):void
		{
			LevelManager.createEditData(teamsArr, currentTech);
			
			dispatchEventWith("TEAMS_SELECTED");
		}
		

		
		
		public function dispose():void
		{
			
			ButtonManager.removeButtonEvents(view.xButton);
			view.dispose();
			view = null;
		}
			
		
	}
}