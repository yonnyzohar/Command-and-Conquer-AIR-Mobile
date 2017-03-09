package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import global.GameAtlas;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
	import Main;
	import global.Methods;
	import global.Parameters;
	import global.utilities.GlobalEventDispatcher;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	[SWF(frameRate="60", width="800", height="480",backgroundColor="0x000000")]
	public class RTS extends Sprite 
	{
		private var _starling:Starling;
		

		public function RTS():void 
		{
			if (stage) 
			{
				init();
			}
			else addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:flash.events.Event = null):void 
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			Parameters.flashStage = stage;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			stage.addEventListener(flash.events.MouseEvent.RIGHT_CLICK, onRightMouseClicked);
			
			setTimeout(initStarlingContext,1000);
	
		}
		
		private function initStarlingContext():void
		{
			var screenWidth:int = stage.stageWidth;
			var screenHeight:int = stage.stageHeight;
			var viewPort:Rectangle = new Rectangle(0, 0, screenWidth, screenHeight);
			
			Starling.handleLostContext = true;  //- Starling 1_7;
			//Starling.multitouchEnabled = true;
			//
			_starling = new Starling(Main, stage, viewPort);
			//_starling.showStats=true;
			//_starling.simulateMultitouch = true;
			
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated );
		}
		
		private function onRootCreated(e:starling.events.Event):void 
		{
			_starling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated );
			_starling.start();
			Starling.current.addEventListener(starling.events.Event.CONTEXT3D_CREATE, onContext3DEventCreate);
		}
		
		protected function onRightMouseClicked(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			//trace"RIGHT CLICKED!!!");
			if (Methods.rightClickFNCTN != null)
			{
				Methods.rightClickFNCTN();
			}
			//onContext3DEventCreate();
			
		}
		
		
 
		private function onContext3DEventCreate():void
		{
			Starling.current.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, onContext3DEventCreate);
			Starling.current.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated );
			if (Main(Parameters.gameHolder).game)
			{
				Main(Parameters.gameHolder).disposeGame();
			}
			Starling.current.dispose();
			GameAtlas.reset();
			initStarlingContext();
		}
		 
		private function onAssetManagerEventTexturesRestored():void
		{
			//remove loading (texture restoration)screen
		}
				

			
	}
}