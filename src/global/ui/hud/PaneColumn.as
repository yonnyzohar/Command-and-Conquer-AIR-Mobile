package global.ui.hud
{
	import com.dynamicTaMaker.views.GameSprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import global.sounds.GameSounds;
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
		private var arr:Array = [];
		private var SlotHolderCLS:Class;
		public var selectedSlot:SlotHolder;
		public var unitsDict:Object = { };
		private var ui:GameSprite;
		
		public function PaneColumn(_SlotHolderCLS:Class,_contextType:String, _ui:GameSprite)
		{
			ui = _ui;
			contextType = _contextType;
			SlotHolderCLS = _SlotHolderCLS;
			upBTN = ui[_contextType + "UpBTN"];
			downBTN = ui[_contextType + "DownBTN"];
			

			downBTN.visible = false;
			upBTN.visible = false;
			upBTN.addEventListener(TouchEvent.TOUCH, onUpBTNClicked);
			downBTN.addEventListener(TouchEvent.TOUCH, onDownBTNClicked);
			
		}
		
		
		public function init(obj:Object , realGame:Boolean, assetFamily:String):void
		{
			var i:int = arr.length;
			for (var unit:String in obj)
			{
				var exists:Boolean = false;
				
				for (var j:int = 0; j <  arr.length; j++ )
				{
					if (unit == arr[j].assetName)
					{
						exists = true;
						break;
					}
					
				}
				if (!exists)
				{
					var slot = new SlotHolderCLS(unit, assetFamily);//contextType
				
					if(realGame)
					{
						slot.setup(obj[unit]);
					}
					arr.push(slot);
					unitsDict[unit] = slot;
					slot.addEventListener(TouchEvent.TOUCH, onSlotClicked);
					
					if (ui[contextType + i])
					{
						ui[contextType + i].addChild(slot)
					}

					i++;
				}
			
			}
			
						
			if(arr.length > 4)
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
		
		public function removeSlots(assets:Object):void
		{
			for (var unit:String in assets)
			{
				for (var i:int = arr.length - 1; i >= 0; i-- )
				{
					var slot:SlotHolder = SlotHolder(arr[i]);
					if (slot.assetName == unit)
					{
						delete unitsDict[unit];
						slot.dispose();
						slot.removeFromParent(true);
						slot = null;
						arr.splice(i, 1 );
					}
				}
			}
			
			if(arr.length > 4)
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
		
		private function onSlotClicked(e:TouchEvent):void 
		{
			var begin:Touch  = e.getTouch(ui, TouchPhase.BEGAN);
			
			if(begin)
			{
				if(e.currentTarget is SlotHolder)
				{
					selectedSlot = SlotHolder(e.currentTarget);
					currentUnit = SlotHolder(e.currentTarget).getUnit();
					currentUnitName = SlotHolder(e.currentTarget).assetName;
					
					if(e.currentTarget is UnitSlotHolder)
					{
						currentUnitType = "unit";
					}
					else
					{
						currentUnitType = "building";
					}
					
					
					dispatchEvent(new Event("SLOT_SELECTED"));
					e.stopPropagation();
				}
			}
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
			for (i = 0; i < arr.length; i++)
			{
				if (arr[i] != _selectedSlot)
				{
					arr[i].disable();
				}
			}
		}
		
		public function enableAllSlots():void 
		{
			var i:int = 0;
			for (i = 0; i < arr.length; i++)
			{
				arr[i].enable();
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
				GameSounds.playSound("HUD8");
				arr.unshift(arr.pop());
				
			
				for (var i:int = 0; i < arr.length; i++)
				{
					arr[i].removeFromParent();
					if (ui[contextType + i])
					{
						ui[contextType + i].addChild(arr[i])
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
				GameSounds.playSound("HUD8");
				
				arr.push(arr.shift());
				
			
				for (var i:int = 0; i < arr.length; i++)
				{
					arr[i].removeFromParent();
					if (ui[contextType + i])
					{
						ui[contextType + i].addChild(arr[i])
					}
				}
			}
			
			e.stopPropagation();
		}
		
		
		
		public function dispose():void
		{
			if(arr != null)
			{
				for(var i:int = 0; i < arr.length; i++)
				{
					arr[i].removeEventListener(TouchEvent.TOUCH, onSlotClicked);
					arr[i].removeFromParent(true);
					arr[i] = null;
				}
				arr.splice(0);
			}
			
		}
		
		
	}
}