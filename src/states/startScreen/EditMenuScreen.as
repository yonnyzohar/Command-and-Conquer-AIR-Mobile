package states.startScreen 
{
	import starling.events.EventDispatcher;
	import starling.events.Event;
	import com.dynamicTaMaker.views.GameSprite;
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import states.game.stats.LevelManager;
	
	public class EditMenuScreen extends EventDispatcher
	{
		public var view:GameSprite
		public var numTiles:int = 40;
		
		public function EditMenuScreen() 
		{
			view = TemplateLoader.get("MapSizeMC");
			view.editMenuNew.visible = false;
			view.editMenuNew.tilesTXT.text = numTiles;
			ButtonManager.setButton(view.xButtonBTN, "TOUCH", closeMe);
			
			ButtonManager.setButton(view.editMenu.newMapBTN, "TOUCH", onNewClicked);
			ButtonManager.setButton(view.editMenu.loadMapBTN, "TOUCH", onLoadClicked);
		}
		
		private function onNewClicked(caller:GameSprite):void
		{
			view.editMenuNew.visible = true;
			view.editMenu.visible = false;
			ButtonManager.removeButtonEvents(view.editMenu.newMapBTN);
			ButtonManager.removeButtonEvents(view.editMenu.loadMapBTN);
			
			ButtonManager.setButton(view.editMenuNew.removeRowBTN, "TOUCH", removeRow);
			ButtonManager.setButton(view.editMenuNew.addRowBTN, "TOUCH", addRow);
			ButtonManager.setButton(view.editMenuNew.gameBTN, "TOUCH", playMe);
		}
		
		private function onLoadClicked(caller:GameSprite):void
		{
			view.editMenuNew.visible = true;
			view.editMenu.visible = false;
			dispatchEvent(new Event("LAUNCH_EDIT_LOAD_SCREEN"))
		}
		
		public function dispose():void 
		{
			ButtonManager.removeButtonEvents(view.editMenuNew.removeRowBTN);
			ButtonManager.removeButtonEvents(view.editMenuNew.addRowBTN);
			ButtonManager.removeButtonEvents(view.editMenuNew.gameBTN);
			ButtonManager.removeButtonEvents(view.xButtonBTN);
			
			view.dispose();
			
		}
		
		private function closeMe(caller:GameSprite):void
		{
			dispatchEvent(new Event("CLOSE_CHOOSE_SIZE"))
		}
		
		private function removeRow(caller:GameSprite):void
		{
			numTiles -= 10;
			
			if (numTiles < 40)
			{
				numTiles = 40;
			}
			view.editMenuNew.tilesTXT.text = numTiles;
		}
		
		private function addRow(caller:GameSprite):void
		{
			numTiles += 10;
			
			if (numTiles > 120)
			{
				numTiles = 120;
			}
			view.editMenuNew.tilesTXT.text = numTiles;
		}
		
		private function playMe(caller:GameSprite):void
		{
			dispatchEvent(new Event("LAUNCH_EDIT_NEW_SCREEN"))
		}
	}
}