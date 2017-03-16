package states 
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import flash.utils.setTimeout;
	import global.enums.MouseStates;
	import global.GameSounds;
	import global.map.mapTypes.Board;
	import global.Parameters;
	import global.utilities.FileSaver;
	import global.utilities.GlobalEventDispatcher;
	import starling.events.Event;
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
			view.y = Parameters.flashStage.stageHeight - view.height;
			ButtonManager.setButton(view.menuBTN, "TOUCH", onMenuBTNClicked);
			
			ButtonManager.setButton(view.moveMapBTN, "TOUCH", onmoveMapBTNClicked);
			view.moveMapBTN.visible = false;
			GlobalEventDispatcher.getInstance().addEventListener("GAME_STATE_CHANGED", onGameStateChanged);
		}
		
		private function onGameStateChanged(e:Event):void 
		{
			if (MouseStates.currentState == MouseStates.PLACE_BUILDING)
			{
				view.moveMapBTN.visible = true;
			}
			else
			{
				view.moveMapBTN.visible = false;
			}
			
		}
		
		public function init():void
		{
			Parameters.gameHolder.addChild(view);
		}
		
		private function onmoveMapBTNClicked(caller:GameSprite):void 
		{
			if (view.moveMapBTN.visible)
			{
				view.moveMapBTN.visible = false;
				MouseStates.currentState = MouseStates.REG_PLAY;
			}
		}
		
		private function onMenuBTNClicked(caller:GameSprite):void 
		{
			Parameters.gameHolder.game.freezeGame();
			if (optionsMenu == null)
			{
				optionsMenu = TemplateLoader.get("OptionsMenuMC");
				optionsMenu.loadMC.textBox.text = "LOAD GAME";
				optionsMenu.saveMC.textBox.text = "SAVE GAME";
				optionsMenu.restartMC.textBox.text = "RESTART";
				optionsMenu.abortMC.textBox.text = "ABORT";
				optionsMenu.width = Parameters.flashStage.stageWidth;
				optionsMenu.height = Parameters.flashStage.stageHeight;
			}
			Parameters.gameHolder.addChild(optionsMenu);
			ButtonManager.setButton(optionsMenu.xButton, "TOUCH", onXClicked);
			ButtonManager.setButton(optionsMenu.loadMC, "TOUCH", onLoadClicked);
			ButtonManager.setButton(optionsMenu.saveMC, "TOUCH", onSaveClicked);
			ButtonManager.setButton(optionsMenu.restartMC, "TOUCH", onRestartClicked);
			ButtonManager.setButton(optionsMenu.abortMC, "TOUCH", onAbortClicked);
			
			optionsMenu.foreGround.visible = false;
			optionsMenu.topMessage.visible = false;
		}
		
		private function onAbortClicked(caller:GameSprite):void 
		{
			removeMenu();
			dispatchEvent(new Event("ABORT_GAME"))
			
		}
		
		private function onRestartClicked(caller:GameSprite):void 
		{
			removeMenu();
			dispatchEvent(new Event("RESTART_GAME"))
		}
		
		
		private function onSaveClicked(caller:GameSprite):void 
		{
			optionsMenu.foreGround.visible = true;
			optionsMenu.topMessage.visible = true;
			optionsMenu.topMessage.textBox.text = "SAVING";
			setTimeout(saveGame, 1000);
			
		}
		
		private function onLoadClicked(caller:GameSprite):void 
		{
			removeMenu();
			dispatchEvent(new Event("LOAD_GAME"))
		}
		
		private function removeMenu():void
		{
			ButtonManager.removeButtonEvents(optionsMenu.xButton);
			ButtonManager.removeButtonEvents(optionsMenu.loadMC);
			ButtonManager.removeButtonEvents(optionsMenu.saveMC);
			ButtonManager.removeButtonEvents(optionsMenu.resumeMC);
			ButtonManager.removeButtonEvents(optionsMenu.restartMC);
			ButtonManager.removeButtonEvents(optionsMenu.abortMC);
			optionsMenu.removeFromParent();
		}
		
		private function onXClicked(caller:GameSprite = null):void 
		{
			removeMenu();
			Parameters.gameHolder.game.resumeGame();
		}
		
		private function saveGame():void 
		{
			var o:Object = { };
			
			o.aiData = { buildCount : Parameters.gameHolder.game.ai1Controller.buildCount, turretCount : Parameters.gameHolder.game.ai1Controller.turretCount }
			o.levelNum  = Parameters.gameHolder.game.levelNum;
			o.playerSide = Parameters.gameHolder.game.playerSide;
			o.tech = LevelManager.currentlevelData.tech;
			o.resourceStates = Board.getInstance().getResources();
			o.visibleTiles = Board.getInstance().getVisibleTiles();
			o.currX = Parameters.mapHolder.x;
			o.currY = Parameters.mapHolder.y;
			
			var teams:Array = [Parameters.team1Obj, Parameters.team2Obj];
			for (var i:int = 0; i < teams.length; i++ )
			{
				var team:TeamObject = teams[i];
				var saveObj:Object = team.getSaveObj();
				
				o["team" + saveObj.teamNum] = saveObj;
			}
			var jsonObj:String = JSON.stringify(o);
			FileSaver.getInstance().save("save.json", jsonObj );
			optionsMenu.foreGround.visible = false;
			optionsMenu.topMessage.visible = false;
		}
		
	}

}