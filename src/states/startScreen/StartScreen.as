package states.startScreen
{
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import global.Parameters;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import global.GameAtlas;

	public class StartScreen extends EventDispatcher
	{
		public var view:GameSprite;
		private var chooseSideScreen:GameSprite;
		
		private var disclaimer:String = "DISCLAIMER: This project is only intended as a technical POC demonstration of the basic working elements of an RTS game on a mobile device, written in As3 Starling. No commercial use is intended. All images and sounds used are from C&C - Tiberian Dawn and are property of the original game creators.";
		
		public function StartScreen()
		{
			view = TemplateLoader.get("MenuScreenMC");
			view.looping = false;
			view.gotoAndPlay(0)
			view.gameBTN.addEventListener(TouchEvent.TOUCH, onGameClicked);
			view.loadBTN.addEventListener(TouchEvent.TOUCH, onLoadClicked);
			view.multiplayerBTN.addEventListener(TouchEvent.TOUCH, onMultiplayerClicked);
			//view.editBTN.addEventListener(TouchEvent.TOUCH, onEditClicked);
			view.disclaimerTXT.text = disclaimer;

		}
		
		private function onGameClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			
			if(end)
			{
				chooseSideScreen = TemplateLoader.get("ChooseSideMC");
				chooseSideScreen.width = Parameters.flashStage.stageWidth;
				chooseSideScreen.height = Parameters.flashStage.stageHeight;
				Parameters.gameHolder.addChild(chooseSideScreen);
				view.visible = false; 
				ButtonManager.setButton(chooseSideScreen.gdiSymbolMC, "TOUCH", onTeam1Clicked);
				ButtonManager.setButton(chooseSideScreen.nodSymbolMC, "TOUCH", onTeam2Clicked);
			}
			
		}
		
		private function onTeam1Clicked(caller:GameSprite):void 
		{
			dispatchEventWith("GAME_CLICKED", false, {playerSide : 1});
		}
		
		private function onTeam2Clicked(caller:GameSprite):void 
		{
			dispatchEventWith("GAME_CLICKED", false, {playerSide : 2});
		}
		
		
		private function onLoadClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			
			if(end)
			{
				dispatchEvent(new Event("LOAD_CLICKED"));
			}
			
		}
		
		private function onMultiplayerClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			
			if(end)
			{
				dispatchEvent(new Event("MULTIPLAYER_CLICKED"));
			}
			
		}
		
		private function onEditClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			
			if(end)
			{
				dispatchEvent(new Event("EDIT_CLICKED"));
			}
			
		}
		
		
		
		public function dispose():void
		{
			view.gameBTN.removeEventListener(TouchEvent.TOUCH, onGameClicked);
			view.loadBTN.removeEventListener(TouchEvent.TOUCH, onLoadClicked);
			view.multiplayerBTN.removeEventListener(TouchEvent.TOUCH, onMultiplayerClicked);
			if (chooseSideScreen)
			{
				ButtonManager.removeButtonEvents(chooseSideScreen.gdiSymbolMC);
				ButtonManager.removeButtonEvents(chooseSideScreen.nodSymbolMC);
				chooseSideScreen.dispose();
				chooseSideScreen.removeFromParent(true);
				chooseSideScreen = null;
			}
			//view.editBTN.removeEventListener(TouchEvent.TOUCH, onEditClicked);
			view.dispose();
			view.removeFromParent(true);
			view = null;
		}
				
	}
}