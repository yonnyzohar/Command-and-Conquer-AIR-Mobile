package states 
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import global.map.mapTypes.Board;
	import global.Parameters;
	import global.utilities.FileSaver;
	import starling.events.EventDispatcher;
	import states.game.stats.LevelManager;
	import states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class MenuScreen extends EventDispatcher
	{
		private var view:GameSprite;
		private var optionsMenu:GameSprite;
		
		public function MenuScreen() 
		{
			view = TemplateLoader.get("TouchOptionsBox");
			Parameters.gameHolder.addChild(view);
			view.y = Parameters.flashStage.stageHeight - view.height;
			ButtonManager.setButton(view.menuBTN, "TOUCH", onMenuBTNClicked);
		}
		
		private function onMenuBTNClicked(caller:GameSprite):void 
		{
			Parameters.gameHolder.game.freezeGame();
			if (optionsMenu == null)
			{
				optionsMenu = TemplateLoader.get("OptionsMenuMC");
				optionsMenu.loadMC.textBox.text = "LOAD GAME";
				optionsMenu.saveMC.textBox.text = "SAVE GAME";
				optionsMenu.resumeMC.textBox.text = "RESUME";
				optionsMenu.restartMC.textBox.text = "RESTART";
				optionsMenu.width = Parameters.flashStage.stageWidth;
				optionsMenu.height = Parameters.flashStage.stageHeight;
			}
			Parameters.gameHolder.addChild(optionsMenu);
			ButtonManager.setButton(optionsMenu.xButton, "TOUCH", onXClicked);
			ButtonManager.setButton(optionsMenu.loadMC, "TOUCH", onLoadClicked);
			ButtonManager.setButton(optionsMenu.saveMC, "TOUCH", onSaveClicked);
			ButtonManager.setButton(optionsMenu.resumeMC, "TOUCH", onResumeClicked);
			ButtonManager.setButton(optionsMenu.restartMC, "TOUCH", onRestartClicked);
		}
		
		private function onRestartClicked(caller:GameSprite):void 
		{
			
		}
		
		private function onResumeClicked(caller:GameSprite):void 
		{
			
		}
		
		private function onSaveClicked(caller:GameSprite):void 
		{
			saveGame();
		}
		
		private function onLoadClicked(caller:GameSprite):void 
		{
			
		}
		
		private function onXClicked(caller:GameSprite):void 
		{
			ButtonManager.removeButtonEvents(optionsMenu.xButton);
			ButtonManager.removeButtonEvents(optionsMenu.loadMC);
			ButtonManager.removeButtonEvents(optionsMenu.saveMC);
			ButtonManager.removeButtonEvents(optionsMenu.resumeMC);
			ButtonManager.removeButtonEvents(optionsMenu.restartMC);
			optionsMenu.removeFromParent();
			Parameters.gameHolder.game.resumeGame();
		}
		
		private function saveGame():void 
		{
			var o:Object = { };

			o.levelNum  = Parameters.gameHolder.game.levelNum;
			o.playerSide = Parameters.gameHolder.game.playerSide;
			o.tech = LevelManager.currentlevelData.tech;
			o.resourceStates = Board.getInstance().getResources();
			o.visibleTiles = Board.getInstance().getVisibleTiles();
			o.currX = Parameters.mapHolder.x;
			o.currY = Parameters.mapHolder.y;
			
			var teams:Array = [Parameters.humaTeamObject, Parameters.pcTeamObject];
			for (var i:int = 0; i < teams.length; i++ )
			{
				var team:TeamObject = teams[i];
				var saveObj:Object = team.getSaveObj();
				
				o["team" + saveObj.teamNum] = saveObj;
			}
			var jsonObj:String = JSON.stringify(o);
			FileSaver.getInstance().save("save.json", jsonObj );
		}
		
	}

}