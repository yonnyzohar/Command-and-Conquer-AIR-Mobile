package global.ui.hud
{
	import com.dynamicTaMaker.views.GameSprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import global.GameSounds;
	import global.ui.hud.slotIcons.SlotHolder;
	import global.ui.hud.slotIcons.UnitSlotHolder;
	import starling.display.Quad;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.InfantryStats;
	import states.game.stats.InfantryStatsObj;
	import states.game.stats.VehicleStats;
	import states.game.stats.VehicleStatsObj;
	import states.game.teamsData.TeamObject;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class PaneColumn extends EventDispatcher
	{
		public var currentUnit:String;
		public var currentUnitName:String;
		public var currentUnitType:String;
		
		
		private var contextType:String; // units or buildings
		private var upBTN:GameSprite;
		private var downBTN:GameSprite;
		public var slotsArr:Array = [];
		private var SlotHolderCLS:Class;
		public var selectedSlot:SlotHolder;
		public var unitsDict:Object = { };
		private var ui:GameSprite;
		private var teamObj:TeamObject;
		private var showUI:Boolean;
		
		public function PaneColumn(_SlotHolderCLS:Class,_contextType:String, _ui:GameSprite = null, _teamObj:TeamObject = null)
		{
			ui = _ui;
			contextType = _contextType;
			SlotHolderCLS = _SlotHolderCLS;
			teamObj = _teamObj;
			
			if (ui)
			{
				showUI = true;
				upBTN = ui[_contextType + "UpBTN"];
				downBTN = ui[_contextType + "DownBTN"];
				downBTN.visible = false;
				upBTN.visible = false;
				upBTN.addEventListener(TouchEvent.TOUCH, onUpBTNClicked);
				downBTN.addEventListener(TouchEvent.TOUCH, onDownBTNClicked);
			}
			else
			{
				showUI = false;
			}
		}
		
		
		public function freeze():void
		{
			if (ui)
			{
				upBTN.removeEventListener(TouchEvent.TOUCH, onUpBTNClicked);
				downBTN.removeEventListener(TouchEvent.TOUCH, onDownBTNClicked);
				for (var i:int = 0; i < slotsArr.length; i++ )
				{
					slotsArr[i].freeze();
				}
			}
		}
		
		public function resume():void
		{
			if (ui)
			{
				upBTN.addEventListener(TouchEvent.TOUCH, onUpBTNClicked);
				downBTN.addEventListener(TouchEvent.TOUCH, onDownBTNClicked);
				for (var i:int = 0; i < slotsArr.length; i++ )
				{
					slotsArr[i].resume();
				}
			}
		}
		
		
		public function init(obj:Object , realGame:Boolean, assetFamily:String):Boolean
		{
			var newOptionsAdded:Boolean = false;
			var i:int = slotsArr.length;
			for (var unit:String in obj)
			{
				var exists:Boolean = false;
				
				for (var j:int = 0; j <  slotsArr.length; j++ )
				{
					if (unit == slotsArr[j].assetName)
					{
						exists = true;
						break;
					}
					
				}
				if (!exists)
				{
					newOptionsAdded = true;
					var slot = new SlotHolderCLS(unit, assetFamily, teamObj, showUI);//contextType
				
					if(realGame)
					{
						slot.setup(obj[unit]);
					}
					slotsArr.push(slot);
					unitsDict[unit] = slot;
					
					slot.addEventListener("SLOT_SELECTED", onSlotSelected);
					if (ui && ui[contextType + i])
					{
						
						ui[contextType + i].addChild(slot.view)
					}

					i++;
				}
			
			}
			
			showHideButtons();
			
			return newOptionsAdded;
		}
		
		private function onSlotSelected(e:Event):void 
		{
			var o:Object = e.data;
			
			selectedSlot = o.selectedSlot;
			currentUnit = o.currentUnit;
			currentUnitName = o.currentUnitName;
			currentUnitType = o.currentUnitType;
			
			dispatchEvent(new Event("SLOT_SELECTED") );
			e.stopPropagation();
		}
		
		private function showHideButtons():void 
		{
			if (ui)
			{
				if(slotsArr.length > 4)
				{
					downBTN.visible = true;
					upBTN.visible = true;
				}
				else
				{
					downBTN.visible = false;
					upBTN.visible = false;
				}
			}
		}
		
		public function removeSlots(assets:Object):void
		{
			for (var unit:String in assets)
			{
				for (var i:int = slotsArr.length - 1; i >= 0; i-- )
				{
					var slot:SlotHolder = SlotHolder(slotsArr[i]);
					if (slot.assetName == unit)
					{
						delete unitsDict[unit];
						slot.dispose();
						if(slot.view)slot.view.removeFromParent(true);
						slot = null;
						slotsArr.splice(i, 1 );
					}
				}
			}
			
			showHideButtons();
		}
		
		
		
		public function disableAllOtherSlotsBuiltWithSameBuilding(_selectedSlot:SlotHolder):void 
		{
			var k:String;
			var assetName:String = _selectedSlot.assetName;
				//constructedIn
			var currentDict:Dictionary;
			var slotsToHide:Array = [];
			
				
			if (InfantryStats.dict[assetName])
			{
				currentDict = InfantryStats.dict;
			}
			else if(VehicleStats.dict[assetName])
			{
				currentDict = VehicleStats.dict;
			}
			
			var constructingArr:Array = currentDict[assetName].constructedIn;
				
			for (k in currentDict)
			{
				if (k != assetName)
				{
					var curUnit:AssetStatsObj = currentDict[k];
					
					for (var i:int = 0; i < constructingArr.length; i++ )
					{
						if (curUnit.constructedIn.indexOf(constructingArr[i]) != -1)
						{
							if (unitsDict[k] is SlotHolder)
							{
								if (slotsToHide.indexOf(unitsDict[k]) == -1)
								{
									slotsToHide.push(unitsDict[k]);
								}
							}
						}
					}
				}
			}
			
			
			for (i = 0; i < slotsToHide.length; i++)
			{
				if (slotsToHide[i] != _selectedSlot)
				{
					slotsToHide[i].disable();
				}
			}
			
			_selectedSlot.disabledSlots = slotsToHide;
		}
		
		public function disableAllSlotsExceptSelected(_selectedSlot:SlotHolder):void 
		{
			var i:int = 0;
			for (i = 0; i < slotsArr.length; i++)
			{
				if (slotsArr[i] != _selectedSlot)
				{
					slotsArr[i].disable();
				}
			}
		}
		
		public function enableAllSlots():void 
		{
			var i:int = 0;
			for (i = 0; i < slotsArr.length; i++)
			{
				slotsArr[i].enable();
			}
		}
		
		
		public function enableSelectedSlots(disabledSlots:Array):void 
		{
			var i:int = 0;
			for (i = 0; i < disabledSlots.length; i++)
			{
				disabledSlots[i].enable();
			}
		}
		
		private function onUpBTNClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(upBTN, TouchPhase.ENDED);
			
			if(end)
			{
				GameSounds.playSound("btnClick");
				slotsArr.unshift(slotsArr.pop());
				
			
				for (var i:int = 0; i < slotsArr.length; i++)
				{
					slotsArr[i].view.removeFromParent();
					if (ui[contextType + i])
					{
						ui[contextType + i].addChild(slotsArr[i].view)
					}
					
				}
			}
			
			e.stopPropagation();
		}
		
		private function onDownBTNClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(downBTN, TouchPhase.ENDED);
			
			if(end)
			{
				GameSounds.playSound("btnClick");
				
				slotsArr.push(slotsArr.shift());
				
			
				for (var i:int = 0; i < slotsArr.length; i++)
				{
					slotsArr[i].view.removeFromParent();
					if (ui[contextType + i])
					{
						ui[contextType + i].addChild(slotsArr[i].view)
					}
				}
			}
			
			e.stopPropagation();
		}
		
		
		
		public function dispose():void
		{
			if(slotsArr != null)
			{
				var length:int = slotsArr.length;
				for(var i:int = 0; i < length; i++)
				{
					slotsArr[i].removeEventListener("SLOT_SELECTED", onSlotSelected);
					slotsArr[i].dispose();
					slotsArr[i] = null;
				}
				slotsArr.splice(0);
			}
			
			if (upBTN)
			{
				upBTN.removeEventListener(TouchEvent.TOUCH, onUpBTNClicked);
				downBTN.removeEventListener(TouchEvent.TOUCH, onDownBTNClicked);
			}
			teamObj = null;
			if (ui)
			{
				ui.removeFromParent();
				ui = null;
			}
			unitsDict = null;
			SlotHolderCLS = null;
			selectedSlot = null;
		}
	}
}