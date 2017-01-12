package global.ui.hud
{
	
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.geom.Point;
	import global.enums.MouseStates;
	import global.utilities.DragScroll;
	import global.utilities.GameTimer;
	import global.GameAtlas;
	import states.game.stats.BuildingsStats;
	import states.game.stats.InfantryStats;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;
	import states.game.teamsData.TeamObject;
	
	import starling.display.Image;
	
	import global.Parameters;
	import global.ui.hud.slotIcons.BuildingSlotHolder;
	import global.ui.hud.slotIcons.SlotHolder;
	import global.ui.hud.slotIcons.UnitSlotHolder;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	import com.dynamicTaMaker.views.GameSprite;
	import com.dynamicTaMaker.loaders.TemplateLoader;


	public class HUDView extends Sprite
	{
		public static var hudWidth:int = 0;
		public static var currentTeam:int = 1;
		private var targetBalance:int;
		//private var bg:Image;
		private var miniMap:MiniMap;
		private var powerGreenMC:Quad;
		private var teamObj:TeamObject;
		
		
		
		
		//private var costTf:TextField;
		public var buildingsContainer:PaneColumn; 
		public var unitsContainer:PaneColumn; 
		
		static private var instance:HUDView = new HUDView();
		
		
		private var ui:GameSprite;
		private var cashUi:GameSprite;
		private var powerMC:GameSprite;
		//private var moveButtons:GameSprite;
		
		public function HUDView()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():HUDView
		{
			return instance;
		}
		
		public function init():void
		{
			var i:int = 0;
			if(ui == null)
			{
				ui = TemplateLoader.get("HudUI");
				ui.nodSymbolMC.visible = false;
				//ui.powerGridMC
				
				cashUi = TemplateLoader.get("CashContMC")
				Parameters.gameHolder.addChild(cashUi);
				
				/*moveButtons = TemplateLoader.get("TouchOptionsBox");
				Parameters.gameHolder.addChild(moveButtons);
				moveButtons.y = Parameters.flashStage.stageHeight - moveButtons.height;
				
				moveButtons.buttonCoverMC.touchable = false;
				
				if (MouseStates.currentState == MouseStates.SELECT)
				{
					moveButtons.buttonCoverMC.x = moveButtons.unitSelectBTN.x;
					moveButtons.buttonCoverMC.x -= (moveButtons.buttonCoverMC.width/2)
				}
				else
				{
					moveButtons.buttonCoverMC.x = moveButtons.mapMoveBTN.x;
					moveButtons.buttonCoverMC.x -= (moveButtons.buttonCoverMC.width/2)
				}
				
				
				ButtonManager.setButton(moveButtons.unitSelectBTN, "TOUCH", onSelectClicked);
				ButtonManager.setButton(moveButtons.mapMoveBTN, "TOUCH", onMapMoveClicked);*/
				
				//bg = new Image(GameAtlas.getTexture("hudUI"));//paneBG
				ui.height = Parameters.flashStage.stageHeight;
				ui.width  = Parameters.flashStage.stageWidth * 0.25;
				addChildAt(ui, 0);
				
				buildingsContainer = new PaneColumn(BuildingSlotHolder, "buildings", ui);
				unitsContainer     = new PaneColumn(UnitSlotHolder, "units", ui);
				
				hudWidth = ui.width;
			}
		}
		
		public function showNavButtons():void
		{
			return;
			/*if (moveButtons.y != (Parameters.flashStage.stageHeight - moveButtons.height))
			{
				TweenLite.to(moveButtons, 0.5, {y : (Parameters.flashStage.stageHeight - moveButtons.height)})
			}*/
		}
		
		public function hideNavButtons():void
		{
			return;
			/*if (moveButtons.y != (Parameters.flashStage.stageHeight))
			{
				onSelectClicked();
				TweenLite.to(moveButtons, 0.5, {y : (Parameters.flashStage.stageHeight)})
			}*/
		}
		
		private function onSelectClicked(caller:GameSprite = null):void
		{
			/*MouseStates.currentState = MouseStates.SELECT;
			moveButtons.buttonCoverMC.x = moveButtons.unitSelectBTN.x;
			moveButtons.buttonCoverMC.x -= (moveButtons.buttonCoverMC.width/2)*/
		}
		
		private function onMapMoveClicked(caller:GameSprite = null):void
		{
			/*MouseStates.currentState = MouseStates.REG_PLAY;
			moveButtons.buttonCoverMC.x = moveButtons.mapMoveBTN.x;
			moveButtons.buttonCoverMC.x -= (moveButtons.buttonCoverMC.width/2)*/
		}
		
		
		public function initEdit():void
		{
			buildingsContainer.init(BuildingsStats.dict, false, "building");
			buildingsContainer.init(TurretStats.dict, false, "turret");
			unitsContainer.init(InfantryStats.dict, false, "infantry");
			unitsContainer.init(VehicleStats.dict, false, "vehicle");
		}
		
		public function setHUD(infantry:Object, vehicles:Object, buildings:Object, turrets:Object, _teamObj:TeamObject):void
		{
			teamObj = _teamObj;
			addMiniMap();
			buildingsContainer.init(buildings, true, "building");
			buildingsContainer.init(turrets, true, "turret");
			
			unitsContainer.init(infantry, true, "infantry");
			unitsContainer.init(vehicles, true, "vehicle");
			
			//costTf = new TextField(170, 15, teamObj.cash + "$", "Verdana", 10, 0xffcc00, true);//- Starling 1_7;
			//addChild(costTf);
			//costTf.y = miniMap.y + miniMap.height;
			//costTf.x = (ui.width - costTf.width) / 2;
			
			cashUi.tf.text = "$" + teamObj.cash;
			
			if (teamObj.teamName == "nod")
			{
				ui.nodSymbolMC.visible = true;
			}
			
			
		}
		
		override public function dispose():void
		{
			buildingsContainer.dispose();
			unitsContainer.dispose();
			
			if (miniMap)
			{
				miniMap.dispose();
				miniMap.removeFromParent(true)
			}
			
			miniMap = null;
			

		}
		
		public function getWidth():int
		{
			return ui.width;
		}
		
		
		public function reduceCash(_reduceAmount:int):void
		{	
			targetBalance = teamObj.cash - _reduceAmount;
			teamObj.cash = targetBalance;
			cashUi.tf.text = "$" + teamObj.cash;
		}
		
		public function addCash(_amount:int):void
		{	
			targetBalance = teamObj.cash + _amount;
			teamObj.cash = targetBalance;
			cashUi.tf.text = "$" + teamObj.cash;
		}
		
		public function getBalance():int
		{
			return teamObj.cash;
		}
		
		

		public function addMiniMap():void 
		{
			miniMap = new MiniMap(ui.nodSymbolMC.width * ui.scaleX, ui.nodSymbolMC.height * ui.scaleY);
			miniMap.x = (ui.width - miniMap.width) / 2;
			miniMap.y = 5;
			addChildAt(miniMap,1);
		}
		
		public function moveMiniMap(rowsPer:Number, colsPer:Number):void 
		{
			if (miniMap)
			{
				miniMap.moveMiniMap(rowsPer, colsPer);
			}
		}
		
		public function updateUnitsAndBuildings(infantry:Object, vehicles:Object, buildings:Object, turrets:Object):void 
		{
			unitsContainer.init(infantry, true, "infantry");
			unitsContainer.init(vehicles, true, "vehicle");
			
			buildingsContainer.init(buildings, true, "building");
			buildingsContainer.init( turrets, true, "turret");
			
		}
		
		public function removeUnitsAndBuildings(infantry:Object, vehicles:Object, buildings:Object, turrets:Object):void 
		{
			buildingsContainer.removeSlots(buildings);
			buildingsContainer.removeSlots(turrets);
			unitsContainer.removeSlots(infantry);
			unitsContainer.removeSlots(vehicles);
		}
		
		public function updatePower(totalPowerIn:int, totalPowerOut:int):void 
		{
			if (powerGreenMC == null)
			{
				powerGreenMC = new Quad(10, 1, 0x00cc00);
				powerGreenMC.alpha = 0.7;
				ui.powerPlaceolder.addChild(powerGreenMC);
			}
			
			powerGreenMC.y = 0;
			powerGreenMC.height = totalPowerOut;
			powerGreenMC.y -= totalPowerOut;
			
			if (powerMC == null)
			{
				powerMC = TemplateLoader.get("PowerMC");
				ui.powerPlaceolder.addChild(powerMC);
			}
			
			var currentPowerY:int = powerMC.y;
			powerMC.y = 0;
			powerMC.y -= totalPowerIn;
			
			
			if (totalPowerIn > totalPowerOut)
			{
				powerGreenMC.color = 0xff0000;//red
			}
			else
			{
				powerGreenMC.color = 0x00cc00;//green
			}
			
			//powerMC
			//powerPlaceolder
		}
		


	}
}