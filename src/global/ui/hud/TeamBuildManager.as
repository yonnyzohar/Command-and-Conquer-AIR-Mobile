package global.ui.hud
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import global.enums.Agent;
	import global.enums.MouseStates;
	import global.GameAtlas;
	import global.map.Node;
	import global.Parameters;
	import global.ui.hud.HUDView;
	import global.ui.hud.slotIcons.SlotHolder;
	import global.utilities.DragScroll;
	import global.utilities.GlobalEventDispatcher;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.BuildingView;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.BuildingsStatsObj;
	import states.game.stats.InfantryStats;
	import states.game.stats.InfantryStatsObj;
	import states.game.stats.LevelManager;
	import states.game.stats.TurretStats;
	import states.game.stats.TurretStatsObj;
	import states.game.stats.VehicleStats;
	import states.game.stats.VehicleStatsObj;
	import states.game.teamsData.TeamObject;
	
	import states.game.stats.BuildingsStats;

	public class TeamBuildManager extends EventDispatcher
	{
		private var teamObj:TeamObject;
		public var targetRow:int;
		public var targetCol:int;
		private var view:HUDView;
		public var completedAsset:Object;
		
		
		
		
		private var buildingPlacementMarker:BuidingPlacementMarker;
		
		
		public function TeamBuildManager()
		{
			
		}
		
		public function init(teamStartParams:Object, _teamObj:TeamObject):void
		{
			//get starting buildings
			//turn into dictionary for build que
			teamObj = _teamObj;
			
			
			var infantry:Object = getAvaliableInfantry(teamStartParams.startBuildings);
			var vehicles:Object = getAvaliableVehicles(teamStartParams.startBuildings);
			
			var buildings:Object = getAvaliableBuildings(teamStartParams.startBuildings);
			var turrets:Object   = getAvaliableTurrets(teamStartParams.startBuildings);
			
			
			if(teamStartParams.Agent == Agent.HUMAN)
			{
				view = HUDView.getInstance();
				view.setHUD(infantry, vehicles, buildings, turrets, teamObj);
				view.unitsContainer.addEventListener("SLOT_SELECTED", onUnitSelected);
				view.buildingsContainer.addEventListener("SLOT_SELECTED", onBuildingSelected);
			}

			buildingPlacementMarker = new BuidingPlacementMarker();
			buildingPlacementMarker.addEventListener(BuidingPlacementMarker.BUILDNG_SPOT_FOUND, onSpotFound);
			
			
		}
		
		public function updateUnitsAndBuildings(_assetName:String):void
		{
			var infantry:Object = getAvaliableInfantry([ { name : _assetName } ]);
			var vehicles:Object = getAvaliableVehicles([ { name : _assetName } ]);
			var buildings:Object = getAvaliableBuildings([{name : _assetName}]);
			var turrets:Object   = getAvaliableTurrets([ { name : _assetName } ]);
			
			if (teamObj.agent == Agent.HUMAN)
			{
				view.updateUnitsAndBuildings(infantry, vehicles, buildings, turrets);
			}
			
		}
		
		public function removeDependantUnitsAndBuildings(_assetName:String):void 
		{
			var infantry:Object = getAvaliableInfantry([ { name : _assetName } ]);
			var vehicles:Object = getAvaliableVehicles([ { name : _assetName } ]);
			var buildings:Object = getAvaliableBuildings([{name : _assetName}]);
			var turrets:Object   = getAvaliableTurrets([ { name : _assetName } ]);
			
			if (teamObj.agent == Agent.HUMAN)
			{
				view.removeUnitsAndBuildings(infantry, vehicles, buildings, turrets)
			}
			;
		}
		
		private function getAvaliableInfantry(_buildings:Array):Object
		{
			var k:String;
			var units:Object = { };
			for(var i:int = 0; i < _buildings.length; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				
				for (k in InfantryStats.dict)
				{
					var curUnit:InfantryStatsObj = InfantryStats.dict[k];
					
					if (curUnit.constructedIn.indexOf(buildingName) != -1)
					{
						if (curUnit.tech <= LevelManager.currentlevelData.tech)
						{
							if (curUnit.owner == "both" || curUnit.owner == teamObj.teamName)
							{
								units[k] = curUnit;
							}
							
						}
					}
				}
			}
			return units;
		}
		
		
		private function getAvaliableVehicles(_buildings:Array):Object
		{
			var k:String;
			var units:Object = { };
			for(var i:int = 0; i < _buildings.length; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				
				for (k in VehicleStats.dict)
				{
					var curVehicle:VehicleStatsObj = VehicleStats.dict[k];
					
					if (curVehicle.dependency)
					{
						if (curVehicle.constructedIn.indexOf(buildingName) != -1)
						{
							if (curVehicle.tech <= LevelManager.currentlevelData.tech)
							{
								if (curVehicle.owner == "both" || curVehicle.owner == teamObj.teamName)
								{
									units[k] = curVehicle;
								}
							}
						}
					}
				}
			}
			return units;
		}
		
		
		
		public function getProducingBuilding(unit:AssetStatsObj, currentTeam:Array):Object 
		{
			
			var o:Object = { };
			var creatingBuildingArr:Array = unit.constructedIn;
			

			outer : for (var i:int = 0; i <  currentTeam.length; i++ )
			{
				if (currentTeam[i] is Building)
				{
					var building:Building = Building(currentTeam[i]);
					
					for (var j:int = 0; j < creatingBuildingArr.length; j++ )
					{
						var creatingBuilding:String = creatingBuildingArr[j];
						if (creatingBuilding == building.name)
						{
							o = { "row" : building.model.row, "col" : building.model.col };
							break outer;
						}
					}
				}
			}
			
			return o;
		}
		
		private function getAvaliableTurrets(_buildings:Array):Object
		{
			var k:String;
			var buildings:Object = { };
			for(var i:int = 0; i < _buildings.length; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				
				
				for (k in TurretStats.dict)
				{
					var curTurret:TurretStatsObj = TurretStats.dict[k];
					
					if (curTurret.dependency.indexOf(buildingName) != -1)
					{
						if (curTurret.tech <= LevelManager.currentlevelData.tech)
						{
							if (curTurret.owner == "both" || curTurret.owner == teamObj.teamName)
							{
								buildings[k] = curTurret;
							}
						}
					}
				}
				
				
			}
			return buildings;
		}
		
		private function getAvaliableBuildings(_buildings:Array):Object
		{
			var k:String;
			var buildings:Object = { };
			for(var i:int = 0; i < _buildings.length; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				
				
				for (k in BuildingsStats.dict)
				{
					var curBuilding:BuildingsStatsObj = BuildingsStats.dict[k];
					
					if (curBuilding.dependency)
					{
						if (curBuilding.dependency.indexOf(buildingName) != -1)
						{
							if (curBuilding.tech <= LevelManager.currentlevelData.tech)
							{
								if (curBuilding.owner == "both" || curBuilding.owner == teamObj.teamName)
								{
									buildings[k] = curBuilding;
								}
							}
						}
					}
				}
			}
			return buildings;
		}
		
		private function onBuildingSelected(e:Event):void 
		{
			if(view.buildingsContainer.selectedSlot != null)
			{
				var selectedSlot:SlotHolder = view.buildingsContainer.selectedSlot;
				var buildInProgress:Boolean = selectedSlot.buildInProgress;
				
				if (!buildInProgress)
				{
					if (teamObj.cash - selectedSlot.cost >= 0)
					{
						view.buildingsContainer.disableAllSlotsExceptSelected(selectedSlot);
						selectedSlot.buildMe(onBuildingComplete);
						assetBeingBuilt(selectedSlot.assetName);
					}
				}
				else
				{
					if (selectedSlot.buildingDone)
					{
						buildingPlacementMarker.pupulateTilesSprite(selectedSlot.assetName);

					}
				}
			}
		}
		
		private function onSpotFound(e:Event):void 
		{
			var selectedSlot:SlotHolder = view.buildingsContainer.selectedSlot;
			targetRow = buildingPlacementMarker.targetRow;
			targetCol = buildingPlacementMarker.targetCol;
			
			if (teamObj.agent == Agent.HUMAN)
			{
				view.buildingsContainer.enableAllSlots();
			}
			
			
			dispatchEventWith("ASSET_CONSTRUCTED", false, { "name" : selectedSlot.assetName, "type" : "building" });
		}
		
		
		
		private function onUnitSelected(e:Event):void
		{
			if(view.unitsContainer.selectedSlot != null)
			{
				var selectedSlot:SlotHolder = view.unitsContainer.selectedSlot;
				
				
				if (teamObj.cash - selectedSlot.cost >= 0)
				{
					var buildInProgress:Boolean = selectedSlot.buildInProgress;

					if (!buildInProgress)
					{
						view.unitsContainer.disableAllOtherSlotsBuiltWithSameBuilding(selectedSlot);
						selectedSlot.buildMe(onUnitComplete);
						assetBeingBuilt(selectedSlot.assetName);
					}
				}
			}
		}
		
		private function onBuildingComplete(assetName:String):void
		{
			//assetBuildComplete(assetName);
		}
		
		private function onUnitComplete(completedActor:String, contextType:String, disabledSlots:Array = null):void 
		{
			if (disabledSlots == null)
			{
				view.unitsContainer.enableAllSlots();
			}
			else
			{
				view.unitsContainer.enableSelectedSlots(disabledSlots);
			}
			//assetBuildComplete(completedActor);
			
			dispatchEventWith("ASSET_CONSTRUCTED", false, { "name" : completedActor, "type" : contextType });
		}
		
		public function assetBeingBuilt(assetName:String):void 
		{
			var constructedIn:String = "construction-yard";
			var curBuilding:Building;
			var i:int = 0;
			var stats:Array = [BuildingsStats.dict, VehicleStats.dict, InfantryStats.dict, TurretStats.dict];
			var obj:AssetStatsObj;
			
			for (i = 0; i < stats.length; i++ )
			{
				if (stats[i][assetName])
				{
					obj = stats[i][assetName];
					break;
				}
			}
			
			
			if (obj.constructedIn != null)
			{
				outer : for (i = 0; i < teamObj.team.length; i++ )
				{
					for (var j:int = 0; j < obj.constructedIn.length; j++ )
					{
						if (teamObj.team[i] is Building && teamObj.team[i].name == obj.constructedIn[j]) 
						{
							curBuilding = teamObj.team[i];
							break outer;
						}
					}
					
				}
			}
			else
			{
				for (i = 0; i < teamObj.team.length; i++ )
				{
					if (teamObj.team[i] is Building && teamObj.team[i].name == constructedIn) 
					{
						curBuilding = teamObj.team[i];
					}
				}
			}
			
			
			
			var o:Object = { };
			o[assetName] = assetName;
			
			if (obj.connectedSprites)
			{
				for (i = 0; i < obj.connectedSprites.length; i++ )
				{
					o[obj.connectedSprites[i]] = obj.connectedSprites[i];
				}
			}
			
			GameAtlas.init( o , null);
		}
		
		public function assetBuildComplete(assetName:String):void 
		{
			var constructedIn:String = "construction-yard";
			var curBuilding:Building;
			var i:int = 0;
			var stats:Array = [BuildingsStats.dict, VehicleStats.dict, InfantryStats.dict, TurretStats.dict];
			var types:Array = ["building", "vehicle", "infantry", "turret"];
			var currentType:String;
			var obj:AssetStatsObj;
			
			for (i = 0; i < stats.length; i++ )
			{
				if (stats[i][assetName])
				{
					obj = stats[i][assetName];
					currentType = types[i];
					break;
				}
			}
			
			if (obj.constructedIn != null)
			{
				outer : for (i = 0; i < teamObj.team.length; i++ )
				{
					for (var j:int = 0; j < obj.constructedIn.length; j++ )
					{
						if (teamObj.team[i] is Building && teamObj.team[i].name == obj.constructedIn[j]) 
						{
							curBuilding = teamObj.team[i];
							break outer;
						}
					}
					
				}
			}
			else
			{
				for (i = 0; i < teamObj.team.length; i++ )
				{
					if (teamObj.team[i] is Building && teamObj.team[i].name == constructedIn) 
					{
						curBuilding = teamObj.team[i];
					}
				}
			}

			if (curBuilding)
			{
				BuildingView(curBuilding.view).setConstructAnimation();
			}

		}
	}
}