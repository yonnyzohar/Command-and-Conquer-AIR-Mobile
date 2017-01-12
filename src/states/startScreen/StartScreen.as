package states.startScreen
{
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
		
		private var disclaimer:String = "DISCLAIMER: This project is only intended as a technical POC demonstration of the basic working elements of an RTS game on a mobile device, written in As3 Starling. No commercial use is intended. All images and sounds used are from C&C - Tiberian Dawn and are property of the original game creators.";
		
		public function StartScreen()
		{
			view = TemplateLoader.get("MenuScreenMC");
			view.looping = false;
			view.gotoAndPlay(0)
			view.gameBTN.addEventListener(TouchEvent.TOUCH, onGameClicked);
			view.editBTN.addEventListener(TouchEvent.TOUCH, onEditClicked);
			view.disclaimerTXT.text = disclaimer;

		}
		
		private function onEditClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			
			if(end)
			{
				dispatchEvent(new Event("EDIT_CLICKED"));
			}
			
		}
		
		private function onGameClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			
			if(end)
			{
				dispatchEvent(new Event("GAME_CLICKED"));
			}
			
		}
		
		public function dispose():void
		{
			view.gameBTN.removeEventListener(TouchEvent.TOUCH, onGameClicked);
			view.editBTN.removeEventListener(TouchEvent.TOUCH, onEditClicked);
			view.dispose();
			view.removeFromParent(true);
			view = null;
		}
				
	}
}