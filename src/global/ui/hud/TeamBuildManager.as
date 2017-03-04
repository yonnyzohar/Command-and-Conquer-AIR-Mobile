package global.ui.hud
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.enums.Agent;
	import global.enums.MouseStates;
	import global.GameAtlas;
	import global.GameSounds;
	import global.map.Node;
	import global.Parameters;
	import global.ui.hud.HUD;
	import global.ui.hud.slotIcons.SlotHolder;
	import global.utilities.DragScroll;
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
	import states.game.entities.buildings.Turret;
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
		public var hud:HUD;
		public var completedAsset:Object;
		public var buildingPlacementMarker:BuidingPlacementMarker;
		
		
		public function TeamBuildManager()
		{
			
		}
		
		public function init(teamStartParams:Object, _teamObj:TeamObject):void
		{
			//get starting buildings
			//turn into dictionary for build que
			teamObj = _teamObj;
			
			
			var infantry:Object = getAvaliableInfantry(teamStartParams.startBuildings, "add");
			var vehicles:Object = getAvaliableVehicles(teamStartParams.startBuildings, "add");
			
			var buildings:Object = getAvaliableBuildings(teamStartParams.startBuildings, "add");
			var turrets:Object   = getAvaliableTurrets(teamStartParams.startBuildings, "add");
			
			
			
			hud = new HUD(teamObj.agent == Agent.HUMAN, teamObj);
			
			hud.init();
			
			hud.setHUD(infantry, vehicles, buildings, turrets);
			hud.unitsContainer.addEventListener("SLOT_SELECTED", onUnitSelected);
			hud.buildingsContainer.addEventListener("SLOT_SELECTED", onBuildingSelected);
			

			buildingPlacementMarker = new BuidingPlacementMarker(teamObj);
			buildingPlacementMarker.addEventListener(BuidingPlacementMarker.BUILDNG_SPOT_FOUND, onSpotFound);
			
			
		}
		
		public function updateUnitsAndBuildings(_assetName:String):Boolean
		{
			if (BuildingsStats.dict[_assetName])
			{
				var infantry:Object =  getAvaliableInfantry([ { name : _assetName } ] , "add");
				var vehicles:Object =  getAvaliableVehicles([ { name : _assetName } ], "add");
				var buildings:Object = getAvaliableBuildings([{name : _assetName}] , "add");
				var turrets:Object   = getAvaliableTurrets([ { name : _assetName } ], "add");
				var newConstriuctionOptions:Boolean = hud.updateUnitsAndBuildings(infantry, vehicles, buildings, turrets);
				
				return newConstriuctionOptions;
			}
			else
			{
				return false; 
			}
			
			
		}
		
		public function removeDependantUnitsAndBuildings(_assetName:String):void 
		{
			if (BuildingsStats.dict[_assetName])
			{
				var infantry:Object = getAvaliableInfantry([ { name : _assetName } ], "remove");
				var vehicles:Object = getAvaliableVehicles([ { name : _assetName } ], "remove");
				var buildings:Object = getAvaliableBuildings([{name : _assetName}], "remove");
				var turrets:Object   = getAvaliableTurrets([ { name : _assetName } ], "remove");
				hud.removeUnitsAndBuildings(infantry, vehicles, buildings, turrets)
			}
			
		}
		
		private function getAvaliableInfantry(_buildings:Array, addOrRemove:String):Object
		{
			var k:String;
			var units:Object = { };
			var buildingsLen:int = _buildings.length;
			for(var i:int = 0; i < buildingsLen; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				var type:String = BuildingsStats.dict[buildingName].buildingType;
				
				for (k in InfantryStats.dict)
				{
					var curUnit:InfantryStatsObj = InfantryStats.dict[k];
					
					//if current unit is constructed in hand of mod
					if (curUnit.constructedIn.indexOf(buildingName) != -1)
					{
						//and this is the right tech level
						if (curUnit.tech <= LevelManager.currentlevelData.tech)
						{
							var allBuildingsExist:Boolean = true;
							
							for (var j:int = 0; j < curUnit.dependency.length; j++ )
							{
								var buildingDependencyName:String = curUnit.dependency[j];
								
								if (teamObj.teamBuildingsDict[buildingDependencyName])
								{
									
								}
								else
								{
									allBuildingsExist = false;
									break;
								}
							}
							
							if (addOrRemove == "add")
							{
								if (allBuildingsExist)
								{
									if (curUnit.owner == "both" || curUnit.owner == teamObj.teamName)
									{
										units[k] = curUnit;
									}
								}
							}
							if (addOrRemove == "remove")
							{
								if (!allBuildingsExist)
								{
									if (curUnit.owner == "both" || curUnit.owner == teamObj.teamName)
									{
										units[k] = curUnit;
									}
								}
							}
						}
					}
				}
			}
			return units;
		}
		
		
		private function getAvaliableVehicles(_buildings:Array, addOrRemove:String):Object
		{
			var k:String;
			var units:Object = { };
			var buildingsLen:int = _buildings.length;
			for(var i:int = 0; i < buildingsLen; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				var type:String = BuildingsStats.dict[buildingName].buildingType;
				
				for (k in VehicleStats.dict)
				{
					var curVehicle:VehicleStatsObj = VehicleStats.dict[k];
					
					if (curVehicle.dependency)
					{
						if (curVehicle.constructedIn.indexOf(type) != -1)
						{
							if (curVehicle.tech <= LevelManager.currentlevelData.tech)
							{
								var allBuildingsExist:Boolean = true;
							
								for (var j:int = 0; j < curVehicle.dependency.length; j++ )
								{
									var buildingDependencyName:String = curVehicle.dependency[j];
								
									if (teamObj.teamBuildingsDict[buildingDependencyName])
									{
										
									}
									else
									{
										allBuildingsExist = false;
										break;
									}
								}
								
								
								if (addOrRemove == "add")
								{
									if (allBuildingsExist)
									{
										if (curVehicle.owner == "both" || curVehicle.owner == teamObj.teamName)
										{
											units[k] = curVehicle;
										}
									}
								}
								if (addOrRemove == "remove")
								{
									if (!allBuildingsExist)
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
				}
			}
			return units;
		}
		
		
		
		
		
		private function getAvaliableTurrets(_buildings:Array, addOrRemove:String):Object
		{
			var k:String;
			var buildings:Object = { };
			var buildingsLen:int = _buildings.length;
			
			for(var i:int = 0; i < buildingsLen; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				var type:String = BuildingsStats.dict[buildingName].buildingType;
				
				
				for (k in TurretStats.dict)
				{
					var curTurret:TurretStatsObj = TurretStats.dict[k];
					
					if (curTurret.dependency.indexOf(type) != -1)
					{
						if (curTurret.tech <= LevelManager.currentlevelData.tech)
						{
							var allBuildingsExist:Boolean = true;
							
							for (var j:int = 0; j < curTurret.dependency.length; j++ )
							{
								var buildingDependencyName:String = curTurret.dependency[j];
								
								if (teamObj.teamBuildingsDict[buildingDependencyName])
								{
									
								}
								else
								{
									allBuildingsExist = false;
									break;
								}
							}
							
							if (addOrRemove == "add")
							{
								if (allBuildingsExist)
								{
									if (curTurret.owner == "both" || curTurret.owner == teamObj.teamName)
									{
										buildings[k] = curTurret;
									}
								}
							}
							if (addOrRemove == "remove")
							{
								if (!allBuildingsExist)
								{
									if (curTurret.owner == "both" || curTurret.owner == teamObj.teamName)
									{
										buildings[k] = curTurret;
									}
								}
							}
						}
					}
				}
				
				
			}
			return buildings;
		}
		
		private function getAvaliableBuildings(_buildings:Array, addOrRemove:String):Object
		{
			var k:String;
			var buildings:Object = { };
			var buildingsLen:int = _buildings.length;
			
			for(var i:int = 0; i <buildingsLen; i++)
			{
				var obj:Object = _buildings[i];
				var buildingName:String = obj["name"];
				var type:String = BuildingsStats.dict[buildingName].buildingType;
				
				
				for (k in BuildingsStats.dict)
				{
					var curBuilding:BuildingsStatsObj = BuildingsStats.dict[k];
					
					if (curBuilding.dependency)
					{
						if (curBuilding.dependency.indexOf(type) != -1)
						{
							if (curBuilding.tech <= LevelManager.currentlevelData.tech)
							{
								var allBuildingsExist:Boolean = true;
							
								for (var j:int = 0; j < curBuilding.dependency.length; j++ )
								{
									var buildingDependencyName:String = curBuilding.dependency[j];
									
									if (teamObj.teamBuildingsDict[buildingDependencyName])
									{
										
									}
									else
									{
										allBuildingsExist = false;
										break;
									}
								}
								
								if (addOrRemove == "add")
								{
									if (allBuildingsExist)
									{
										if (curBuilding.owner == "both" || curBuilding.owner == teamObj.teamName)
										{
											buildings[k] = curBuilding;
										}
									}
								}
								if (addOrRemove == "remove")
								{
									if (!allBuildingsExist)
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
				}
			}
			return buildings;
		}
		
		
		public function getProducingBuilding(unit:AssetStatsObj, currentTeam:Array):Object 
		{
			
			var o:Object;
			var constructedInArr:Array = unit.constructedIn;
			var currentTeamLen:int = currentTeam.length;
			var building:Building;

			outer : for (var i:int = 0; i < currentTeamLen; i++ )
			{
				if (currentTeam[i] is Building && (currentTeam[i] is Turret) == false)
				{
					building = Building(currentTeam[i]);
					
					for (var j:int = 0; j < constructedInArr.length; j++ )
					{
						var creatingBuilding:String = constructedInArr[j];
						var type:String = BuildingsStats.dict[building.name].buildingType;
						if (creatingBuilding == type)
						{
							o = { "row" : building.model.row, "col" : building.model.col };
							break outer;
						}
					}
				}
			}
			
			return o;
		}
		
		private function onBuildingSelected(e:Event):void 
		{
			if(hud.buildingsContainer.selectedSlot != null)
			{
				var selectedSlot:SlotHolder = hud.buildingsContainer.selectedSlot;
				var currentBuildState:int = selectedSlot.currentBuildState; 
				
				if (currentBuildState == SlotHolder.IDLE)
				{
					if (teamObj.cash - selectedSlot.cost >= 0)
					{
						hud.buildingsContainer.disableAllSlotsExceptSelected(selectedSlot);
						selectedSlot.buildMe(onBuildingComplete);
						assetBeingBuilt(selectedSlot.assetName);
					}
					else
					{
						if (teamObj.agent == Agent.HUMAN)
						{
							GameSounds.playSound("insufficient_funds", "vo");
						}
						
					}
				}
				else
				{
					if (selectedSlot.currentBuildState == SlotHolder.BUILD_DONE)
					{
						buildingPlacementMarker.pupulateTilesSprite(selectedSlot.assetName);

					}
					else
					{
						//this will never happen with AI
						hud.buildingsContainer.selectedSlot.cancelBuild();
						var cashRefund:int = hud.buildingsContainer.selectedSlot.currentPerNum;
						teamObj.beginAddingCash(cashRefund);
						hud.buildingsContainer.enableAllSlots();
						if (teamObj.agent == Agent.HUMAN)
						{
							GameSounds.playSound("cancelled", "vo");
						}
					}
				}
			}
		}
		
		private function onSpotFound(e:Event):void 
		{
			var selectedSlot:SlotHolder = hud.buildingsContainer.selectedSlot;
			targetRow = buildingPlacementMarker.targetRow;
			targetCol = buildingPlacementMarker.targetCol;
			
			
			hud.buildingsContainer.enableAllSlots();
			dispatchEventWith("BUILDING_PLACED", false, { "name" : selectedSlot.assetName, "type" : "building" });
		}
		
		
		
		private function onUnitSelected(e:Event):void
		{
			if(hud.unitsContainer.selectedSlot != null)
			{
				var selectedSlot:SlotHolder = hud.unitsContainer.selectedSlot;
				
				
				if (teamObj.cash - selectedSlot.cost >= 0)
				{
					var buildInProgress:Boolean = (selectedSlot.currentBuildState == SlotHolder.BUILD_IN_PROGRESS);

					if (!buildInProgress)
					{
						hud.unitsContainer.disableAllOtherSlotsBuiltWithSameBuilding(selectedSlot);
						selectedSlot.buildMe(onUnitComplete);
						assetBeingBuilt(selectedSlot.assetName);
					}
					else
					{
						//this will never happen with AI
						hud.unitsContainer.selectedSlot.cancelBuild();
						var cashRefund:int = hud.unitsContainer.selectedSlot.currentPerNum;
						teamObj.beginAddingCash(cashRefund);
						hud.unitsContainer.enableSelectedSlots(hud.unitsContainer.selectedSlot.disabledSlots);
						if (teamObj.agent == Agent.HUMAN)
						{
							GameSounds.playSound("cancelled", "vo");
						}
					}
				}
				else
				{
					if (teamObj.agent == Agent.HUMAN)
					{
						GameSounds.playSound("insufficient_funds", "vo");
					}
					
				}
			}
			
		}
		
		private function onBuildingComplete(assetName:String):void
		{
			if (GameAtlas.loadingInProgress)
			{
				setTimeout(function():void 
				{
				
					onBuildingComplete(assetName);
				},1000);
			}
			else
			{
				dispatchEvent(new Event("BUILDING_CONSTRUCTION_COMPLETED"))
			}
			
		}
		
		private function onUnitComplete(completedActor:String, contextType:String, disabledSlots:Array = null):void 
		{
			if (disabledSlots == null)
			{
				hud.unitsContainer.enableAllSlots();
			}
			else
			{
				hud.unitsContainer.enableSelectedSlots(disabledSlots);
			}
			
			dispatchUnitContructed(completedActor, contextType);
			
			
		}
		
		private function dispatchUnitContructed(completedActor:String, contextType:String):void 
		{
			if (GameAtlas.loadingInProgress)
			{
				setTimeout(function():void {
				
					dispatchUnitContructed(completedActor, contextType);
				},1000);
			}
			else
			{
				dispatchEventWith("UNIT_CONSTRUCTED", false, { "name" : completedActor, "type" : contextType });
			}
			
			
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
			var teamLen:int = teamObj.team.length;
			
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
				outer : for (i = 0; i < teamLen; i++ )
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
				for (i = 0; i < teamLen; i++ )
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
		
		public function dispose():void 
		{
			hud.unitsContainer.removeEventListener("SLOT_SELECTED", onUnitSelected);
			hud.buildingsContainer.removeEventListener("SLOT_SELECTED", onBuildingSelected);
			buildingPlacementMarker.removeEventListener(BuidingPlacementMarker.BUILDNG_SPOT_FOUND, onSpotFound);
			
			buildingPlacementMarker.dispose();
			hud.dispose();
			teamObj = null;
			hud = null;
			buildingPlacementMarker = null;
		}
	}
}