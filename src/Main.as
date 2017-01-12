package
{
	import com.dynamicTaMaker.views.GameSprite;
	import flash.display.BitmapData;
	import flash.text.Font;
	import flash.utils.setTimeout;
	import global.enums.MouseStates;
	import global.Methods;
	import global.Parameters;
	import global.GameAtlas;
	import global.pools.PoolsManager;
	import global.sounds.GameSounds;
	import global.utilities.GlobalEventDispatcher;
	import starling.text.TextField;
	import states.game.stats.BuildingsStats;
	import states.game.stats.BulletStats;
	import states.game.stats.InfantryStats;
	import states.game.stats.LevelManager;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;
	import states.game.stats.WarheadStats;
	import states.game.stats.WeaponStats;
	import states.startScreen.EditMenuScreen;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import flash.events.Event;
	
	import states.LoadingScreen;
	import states.editor.EditController;
	import states.game.Game;
	import states.startScreen.StartScreen;
	import com.dynamicTaMaker.loaders.DynamicTaCreator;
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.atlases.MyTA;
	import com.emibap.textureAtlas.DynamicAtlas;
	
	public class Main extends Sprite
	{
		private var q:Quad;
		private var startScreen:StartScreen;
		private var chooseSizeView:EditMenuScreen;
		private var game:Game;
		private var edit:EditController;
		private var dymanicTaCreator:DynamicTaCreator;
		
		private var tf:starling.text.TextField;
		
		
		public function Main()
		{
			addEventListener(starling.events.Event.ADDED_TO_STAGE, onAdded);
			
		}
		
		private function onAdded(e:starling.events.Event):void
		{
			removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAdded);
			
			setTimeout(function():void
			{
				var origWidth:int = 400//480;
				MouseStates.currentState = MouseStates.REG_PLAY;
				Parameters.gameScale = Parameters.flashStage.fullScreenWidth / origWidth ; //stage.stageWidth / origWidth;
				Parameters.theStage = stage;
				Methods.isAndroid();
				Methods.isIOS();
				
				
				WarheadStats.init();
				BulletStats.init();
				WeaponStats.init();
				//2 - need to init pools before units!!!
				InfantryStats.init();//3
				VehicleStats.init();
				BuildingsStats.init();//3
				TurretStats.init();
				
				//GameSounds.init();  --deal with this later!!!
				Parameters.mapHolder = new Sprite()
				Parameters.mapHolder.scaleX = Parameters.mapHolder.scaleY = 1;
				init();
				
				
				
			},500);
		}
		
		
		private function init():void
		{
			Parameters.gameHolder = this;
			//get fonts
			/*var embeddedFont1:Font = new OCRAStd();
			var chars2Add:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			chars2Add += chars2Add.toLowerCase() + ",.-_!?1234567890: ";
			//trace"ADDING " + embeddedFont1.fontName);
			
			DynamicAtlas.bitmapFontFromString(chars2Add, embeddedFont1.fontName, 16, false, false, -2);
			DynamicAtlas.bitmapFontFromString(chars2Add, "_sans", 16, false, false, -2);*/
			
			dymanicTaCreator = new DynamicTaCreator();
			dymanicTaCreator.addEventListener("TA_CREATED", onTACreated);
			dymanicTaCreator.init(new AssetsMC());//this is the menu ui fla
		}
		
		private function onTACreated(event:flash.events.Event):void
		{
			var bitmapData:BitmapData = dymanicTaCreator.TAbitmapData;
			var taPlacementsXML:XML = new XML(dymanicTaCreator.taPlacements)
			MyTA.init(bitmapData, taPlacementsXML);
			TemplateLoader.init(MyTA.ta, dymanicTaCreator.viewHeirarchyObj);

			initStartScreen(); 
			
			Parameters.loadingScreen = new LoadingScreen();
			Parameters.loadingScreen.init();
			GameAtlas.initGlobalAssets();
			//trace"flash stage " , Parameters.flashStage.stageWidth,  Parameters.flashStage.stageHeight);
			//trace"starling stage " , Parameters.theStage.stageWidth,  Parameters.theStage.stageHeight);
		}
		
		
		private function initStartScreen():void
		{
			startScreen = new StartScreen();
			startScreen.addEventListener("EDIT_CLICKED", onEditClicked);
			startScreen.addEventListener("GAME_CLICKED", onGameClicked);
			
			addChild(startScreen.view);
			startScreen.view.width = Parameters.flashStage.stageWidth;
			startScreen.view.height = Parameters.flashStage.stageHeight;
			
		}
		
		private function onEditClicked(e:starling.events.Event):void
		{
			startScreen.view.touchable = false;
			initMapSizePopUp();
		}
		
		private function initMapSizePopUp():void 
		{
			chooseSizeView = new EditMenuScreen();
			addChild(chooseSizeView.view);
			chooseSizeView.addEventListener("CLOSE_CHOOSE_SIZE", onCloseChooseTiles);
			chooseSizeView.addEventListener("LAUNCH_EDIT_NEW_SCREEN", onLaunchEditNew);
			chooseSizeView.addEventListener("LAUNCH_EDIT_LOAD_SCREEN", onLaunchEditLoad);
			chooseSizeView.view.x = (Parameters.flashStage.stageWidth - chooseSizeView.view.width) / 2;
			chooseSizeView.view.y = (Parameters.flashStage.stageHeight - chooseSizeView.view.height) / 2;
		}
		
		private function onLaunchEditLoad(e:starling.events.Event):void 
		{
			Parameters.editLoad = true;
			LevelManager.init();
			LevelManager.currentlevelData = LevelManager.getLevelData(0);
			Parameters.numRows = LevelManager.currentlevelData.numTiles;
			Parameters.numCols = LevelManager.currentlevelData.numTiles
			loadEdit();
		}
		
		private function loadEdit():void 
		{
			removeEditPopUp();
			Parameters.editMode = true;
			removeStartScreen();
			edit = new EditController();
			edit.addEventListener("DONE_EDITING", onDoneEditing);
			edit.addEventListener("EDITING_CANCELED", editingCanceled);
		}
		
		private function onLaunchEditNew(e:starling.events.Event):void 
		{
			Parameters.numRows = chooseSizeView.numTiles;
			Parameters.numCols = chooseSizeView.numTiles;
			loadEdit();
		}
		
		private function removeEditPopUp():void 
		{
			chooseSizeView.removeEventListener("CLOSE_CHOOSE_SIZE", onCloseChooseTiles);
			chooseSizeView.removeEventListener("LAUNCH_EDIT_NEW_SCREEN", onLaunchEditNew);
			chooseSizeView.removeEventListener("LAUNCH_EDIT_LOAD_SCREEN", onLaunchEditLoad);
			chooseSizeView.dispose();
			chooseSizeView.view.removeFromParent(true)
		}
		
		private function onCloseChooseTiles(e:starling.events.Event):void 
		{
			startScreen.view.touchable = true;
			removeEditPopUp()
		}
		
		private function editingCanceled(e:starling.events.Event):void
		{
			edit.removeEventListener("EDITING_CANCELED", editingCanceled);
			removeEditScreen();
			initStartScreen();
		}
		
		private function onDoneEditing(e:starling.events.Event):void
		{
			edit.removeEventListener("DONE_EDITING", onDoneEditing);
			//Parameters.editMode = false;
			removeEditScreen();
			onGameClicked();
		}
		
		private function removeEditScreen():void
		{
			if(edit != null)
			{
				
				edit.dispose();
			}
			
			edit = null;
			
		}
		
		private function onGameClicked(e:starling.events.Event = null):void
		{
			removeStartScreen();
			if (e != null) Parameters.editMode = false;
			Parameters.editLoad = false;
			game = new Game();
			//if(e != null)game.randomPlacement = true;
			game.init();
			addChild(Parameters.mapHolder);
		}
		
		private function removeStartScreen():void
		{
			if(startScreen)
			{
				startScreen.removeEventListener("EDIT_CLICKED", onEditClicked);
				startScreen.removeEventListener("GAME_CLICKED", onGameClicked);
				startScreen.dispose();
				startScreen = null;
			}
			
		}
	}
}