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
	import starling.events.EventDispatcher;
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


	public class HUD extends EventDispatcher
	{
		public static var hudWidth:int = 0;
		public static var currentTeam:int = 1;
		
		public var miniMap:MiniMap;
		private var powerGreenMC:Quad;
		private var teamObj:TeamObject;
		
		public var ui:GameSprite;
		private var cashUi:GameSprite;
		private var powerMC:GameSprite;
		public var buildingsContainer:PaneColumn; 
		public var unitsContainer:PaneColumn; 
		private var showUI:Boolean;
		private var hudIn:Boolean;
		
		
		public function HUD(_showUI:Boolean = false, _teamObj:TeamObject = null)
		{
			showUI =  _showUI;
			teamObj = _teamObj;
		}
		
		
		public function init():void
		{
			var i:int = 0;
			if(ui == null && showUI)
			{
				ui = TemplateLoader.get("HudUI");
				ui.nodSymbolMC.visible = false;
				//ui.powerGridMC
				
				cashUi = TemplateLoader.get("CashContMC")
				Parameters.gameHolder.addChild(cashUi);
				ui.height = Parameters.flashStage.stageHeight;
				ui.width  = Parameters.flashStage.stageWidth * 0.25;
				
				hudIn = true;
				exitHud();
			}
			
			initPanelColumns();
		}
		
		public function exitHud():void
		{
			if (hudIn)
			{
				ui.x = Parameters.flashStage.stageWidth;
				hudWidth = 0;
				if (ui.parent) ui.removeFromParent();
				hudIn = false;
				if(miniMap)miniMap.x = ui.x;
			}
			
		}
		
		public function enterHud():void
		{
			if (hudIn == false)
			{
				hudIn = true;
				hudWidth = getWidth();
				ui.x = Parameters.flashStage.stageWidth - getWidth();
				Parameters.gameHolder.addChild(ui);
				if (miniMap)
				{
					miniMap.x = ui.x;
					Parameters.gameHolder.addChild(miniMap);
				}
			}
			
				
		}
		
		public function updateCashUI(_cash:int):void
		{
			cashUi.tf.text = "$" + _cash;
		}
		
		public function initPanelColumns():void
		{
			buildingsContainer = new PaneColumn(BuildingSlotHolder, "buildings", ui, teamObj);
			unitsContainer     = new PaneColumn(UnitSlotHolder, "units", ui, teamObj);
		}	
		
		public function initEdit():void
		{
			buildingsContainer.init(BuildingsStats.dict, false, "building");
			buildingsContainer.init(TurretStats.dict, false, "turret");
			unitsContainer.init(InfantryStats.dict, false, "infantry");
			unitsContainer.init(VehicleStats.dict, false, "vehicle");
		}
		
		public function setHUD(infantry:Object, vehicles:Object, buildings:Object, turrets:Object):void
		{
			
			
			
			buildingsContainer.init(buildings, true, "building");
			buildingsContainer.init(turrets, true, "turret");
			unitsContainer.init(infantry, true, "infantry");
			unitsContainer.init(vehicles, true, "vehicle");
			
			if (showUI)
			{
				addMiniMap();
				cashUi.tf.text = "$" + teamObj.cash;
				if (teamObj.teamName == "nod")
				{
					ui.nodSymbolMC.visible = true;
				}
			}
		}
		
		public function dispose():void
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
		
		
		public function getSlot(_name:String):SlotHolder
		{
			var mySlot:SlotHolder;
			
			for (var i:int = 0; i < buildingsContainer.slotsArr.length; i++ )
			{
				var slot:SlotHolder = buildingsContainer.slotsArr[i];
				
				if (slot && slot.assetName == _name)
				{
					mySlot = slot;
					break;
				}
			}
			
			if (mySlot == null)
			{
				for (i = 0; i < unitsContainer.slotsArr.length; i++ )
				{
					var slot:SlotHolder = unitsContainer.slotsArr[i];
					
					if (slot && slot.assetName == _name)
					{
						mySlot = slot;
						break;
					}
				}
			}
			
			return mySlot;
		}
		
		
		

		public function addMiniMap():void 
		{
			miniMap = MiniMap.getInstance();
			miniMap.init(ui.nodSymbolMC.width * ui.scaleX, ui.nodSymbolMC.height * ui.scaleY);
			miniMap.x = ui.x;
			miniMap.y = 5;
			Parameters.gameHolder.addChild(miniMap);
		}
		
		
		public function updateUnitsAndBuildings(infantry:Object, vehicles:Object, buildings:Object, turrets:Object):Boolean 
		{
			var a:Boolean = unitsContainer.init(infantry, true, "infantry");
			var b:Boolean = unitsContainer.init(vehicles, true, "vehicle");
			var c:Boolean = buildingsContainer.init(buildings, true, "building");
			var d:Boolean = buildingsContainer.init( turrets, true, "turret");
			
			if (a || b|| c || d)
			{
				return true;
			}
			else {
				return false;
			}
			
			
			
			
			
			
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
			if (showUI)
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
			}
		}
	}
}