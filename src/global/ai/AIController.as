package global.ai 
{
	import flash.utils.setTimeout;
	import global.assets.GameAssets;
	import global.enums.AiBehaviours;
	import global.Methods;
	import global.ui.hud.slotIcons.BuildingSlotHolder;
	import global.ui.hud.slotIcons.SlotHolder;
	import global.utilities.GameTimer;
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.units.Harvester;
	import states.game.entities.units.Unit;
	import states.game.stats.AssetStatsObj;
	import states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class AIController 
	{
		
		private var aiJSON:Object;
		private var pcTeamObj:TeamObject;
		private var buildCount:int = 0;
		private var myBuildSlot:SlotHolder;
		
		private var myUnitSlotbj:Object;
		
		
		private var infantryArr:Array = [];
		private var vehiclesArr:Array = [];
		private var minNumOfAttackParty:Array;
		
		private var infantryBeingBuilt:Boolean = false;
		private var vehicleBeingBuilt:Boolean = false;
		private var buildingBeingBuilt:Boolean = false;
		
		private var currentAttackPartyCount:int = 0;
		
		public function AIController() 
		{
			aiJSON = JSON.parse(new GameAssets.AIJson());
		}
		
		public function applyAI(teamObj:TeamObject):void 
		{
			pcTeamObj = teamObj;
			
			createProbabilityArr();
			
			//buildQueue
			buildBuilding(true);
			
			buildUnits();
			
			
			minNumOfAttackParty = aiJSON.minNumOfAttackParty;
			
			GameTimer.getInstance().addUser(this);
		}
		
		
		
		
		
		private function createProbabilityArr():void 
		{
			var allInfantry:Object = aiJSON.infantryQueue
			var currentObj:AssetStatsObj;
			
			for (var k:String in allInfantry)
			{
				currentObj = Methods.getCurretStatsObj(k);
				if (currentObj.owner == "both" ||  currentObj.owner ==pcTeamObj.teamName)
				{
					var probabilityNum:int = allInfantry[k];
					
					for (var i:int = 0; i <  probabilityNum; i++ )
					{
						infantryArr.push(k);
					}
				}
			}
			
			
			var allVehicles:Object = aiJSON.vehicleQueue
			
			for (k in allVehicles)
			{
				currentObj = Methods.getCurretStatsObj(k);
				if (currentObj.owner == "both" ||  currentObj.owner ==pcTeamObj.teamName)
				{
					var probabilityNum:int = allVehicles[k];
					
					for (var i:int = 0; i < probabilityNum; i++ )
					{
						vehiclesArr.push(k);
					}
				}
			}
			
			//trace("infantryArr: " + infantryArr);
			//trace("vehiclesArr: " + vehiclesArr);
			
		}
		
		
		
		private function buildBuilding(_firstTime:Boolean = false):void 
		{
			myBuildSlot = null;
			//if there are still stuff to build
			if (aiJSON.buildQueue[buildCount] && buildingBeingBuilt == false)
			{
				var currentBuildingObj:AssetStatsObj = Methods.getCurretStatsObj(aiJSON.buildQueue[buildCount]);
				var buildPowerPlant:Boolean = false;
				if (_firstTime || pcTeamObj.powerCtrl.POWER_SHORTAGE)
				{
					buildPowerPlant = true;
				}
				
				
				//if we have power - proceed
				if (!buildPowerPlant)
				{
					//if we have money - build, on complete come back to here
					if (pcTeamObj.cash >= currentBuildingObj.cost)
					{
						myBuildSlot = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
						if (myBuildSlot)
						{
							myBuildSlot.simulateClickOnBuild();
							myBuildSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
							buildingBeingBuilt = true;
							pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
						}
						else
						{
							//trace(currentBuildingObj.name + " slot does not exist");
							buildCount++;
							buildBuilding();
						}
					}
					else
					{
						//if no money, wait x seconds then check again
					}
				}
				else
				{
					//build power station, on complete - build
					currentBuildingObj = Methods.getCurretStatsObj("power-plant");
					if (pcTeamObj.cash >= currentBuildingObj.cost)
					{
						myBuildSlot = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
						if (myBuildSlot)
						{
							myBuildSlot.simulateClickOnBuild();
							myBuildSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
							pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
						}
						else
						{
							//trace(currentBuildingObj.name + " slot does not exist");
						}
					}
					else
					{
						//if no money, wait x seconds then check again
					}
					
				}
			}
			else
			{
				if (buildCount < aiJSON.buildQueue.length)
				{
					buildCount++;
					buildBuilding();
				}
				else
				{
					//trace("NOTHING MORE TO BUILD")
				}
				
			}
		}
		
		
		private function placeBuilding(e:Event):void 
		{
			//trace("BUILDING_CONSTRUCTION_COMPLETED - now let's place it");
			pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
			pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTED", onBuildingContructed);
			pcTeamObj.buildManager.buildingPlacementMarker.pupulateTilesSprite(myBuildSlot.assetName);
			pcTeamObj.buildManager.buildingPlacementMarker.getValidPlacement()
		}
		

		
		private function onBuildingContructed(e:Event = null):void 
		{
			//trace("ASSET_CONSTRUCTED, move on");
			pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTED", onBuildingContructed);
			if (myBuildSlot.assetName != "power-plant")
			{
				buildCount++;
			}
			buildingBeingBuilt = false;
			buildBuilding();
		}
		
		////////////////////////////////////////////////////////////////////////////////////
		
		
		private function buildUnits():void 
		{
			var infantry:Boolean = false;
			var vehicles:Boolean = false;
			
			if (pcTeamObj.doesBuildingExist(["hand-of-nod", "barracks"]) && infantryBeingBuilt == false)
			{
				infantry = true;
			}
			
			if (pcTeamObj.doesBuildingExist(["weapons-factory", "airstrip"]) && vehicleBeingBuilt == false)
			{
				vehicles = true;
			}
			
			if (myUnitSlotbj == null)
			{
				if (infantry && vehicles) 
				{
					if (pcTeamObj.getHarvester() == null)
					{
						buildVehicles();
					}
					else 
					{
						if (Math.random() < 0.4 )
						{
							buildInfantry();
						}
						else
						{
							buildVehicles();
						}
					}
					
				}
				else if(infantry && !vehicles)
				{
					buildInfantry();
				}
				else if (!infantry && vehicles)
				{
					buildVehicles()
				}
				else
				{
					//trace("no barracks or vehicle factory, try again soon");
					setTimeout(buildUnits, 2000);
				}
			}
			else
			{
				//we saved on to a desired unit, try to build it
				//trace("trying to build saved unit " + myUnitSlotbj.name);
				if (pcTeamObj.cash >= myUnitSlotbj.cost)
				{
					if (myUnitSlotbj.type == "vehicle" )
					{
						if (vehicles == true)
						{
							vehicleBeingBuilt = true;
							myUnitSlotbj.slot = pcTeamObj.buildManager.hud.getSlot(myUnitSlotbj.name);
							myUnitSlotbj.slot.simulateClickOnBuild();
							myUnitSlotbj.slot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
							pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
						}
						else
						{
							myUnitSlotbj = null;
							buildUnits();
						}
						
					}
					
					if (myUnitSlotbj.type == "infantry")
					{
						if (infantry == true)
						{
							infantryBeingBuilt = true;
							myUnitSlotbj.slot = pcTeamObj.buildManager.hud.getSlot(myUnitSlotbj.name);
							myUnitSlotbj.slot.simulateClickOnBuild();
							myUnitSlotbj.slot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
							pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
						}
						else
						{
							myUnitSlotbj = null;
							buildUnits();
						}
					}
				}
				else
				{
					//trace("no money!, trying again")
					setTimeout(buildUnits, 2000);
				}
			}
		}
		
		
		private function buildInfantry(e:Event = null):void 
		{
			var myInfantrySlot:SlotHolder;
			
			if (pcTeamObj.doesBuildingExist(["hand-of-nod", "barracks"]))
			{
				var rnd:int = Math.random() * infantryArr.length;
				var randomInfantry:String = infantryArr[rnd];
				var currentInfantrygObj:AssetStatsObj = Methods.getCurretStatsObj(randomInfantry);
				
				myInfantrySlot = pcTeamObj.buildManager.hud.getSlot(randomInfantry);
				
				if (myInfantrySlot)
				{
					
					if ( pcTeamObj.cash >= currentInfantrygObj.cost)
					{
						//trace("building a " + randomInfantry)
						myInfantrySlot.simulateClickOnBuild();
						myInfantrySlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
						infantryBeingBuilt = true;
						pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
					}
					else
					{
						myUnitSlotbj = { slot : pcTeamObj.buildManager.hud.getSlot(randomInfantry), cost : currentInfantrygObj.cost , type : "infantry" , name : randomInfantry};
						//trace("no money!, trying again")
						setTimeout(buildUnits, 2000);
					}
				}
				else
				{
					
				}
			}
			else
			{
				setTimeout(buildUnits, 1000);
			}
		}
		
		private function onInfantryComplete(e:Event):void 
		{
			pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
			infantryBeingBuilt = false;
			myUnitSlotbj = null;
			buildUnits();
		}
		
		private function buildVehicles():void 
		{
			var myVehicleSlot:SlotHolder;

				
			if (pcTeamObj.doesBuildingExist(["weapons-factory", "airstrip"]))
			{
				var rnd:int = Math.random() * vehiclesArr.length;
				var randomVehicle:String = vehiclesArr[rnd];
				
				if (pcTeamObj.getHarvester() == null)
				{
					randomVehicle = "harvester";
				}
				else
				{
					var numHarvesters:int = pcTeamObj.getNumOfHarvesters();
					if (numHarvesters < 4)
					{
						if (Math.random() < 0.15)
						{
							randomVehicle = "harvester";
						}
					}
					
				}
				
				var currentVehicleObj:AssetStatsObj = Methods.getCurretStatsObj(randomVehicle);
				myVehicleSlot = pcTeamObj.buildManager.hud.getSlot(randomVehicle);
				
				if ( myVehicleSlot )
				{
					
					if (pcTeamObj.cash >= currentVehicleObj.cost)
					{
						//trace("building a " + randomVehicle)
						vehicleBeingBuilt = true;
						myVehicleSlot.simulateClickOnBuild();
						myVehicleSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
						pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
					}
					else
					{
						//trace("COULD NOT FIND VEHICLE SLOT!!!")
						myUnitSlotbj = { slot : pcTeamObj.buildManager.hud.getSlot(randomVehicle), cost : currentVehicleObj.cost , type : "vehicle", name : randomVehicle };
						//trace("no money!, trying again")
						setTimeout(buildUnits, 2000);
					}
				}
				else
				{
					
				}
			}
			else
			{
				setTimeout(buildUnits, 1000);
			}
			
			
		}
		
		private function onBuildCancelledAbruptly(e:Event):void 
		{
			var slot:SlotHolder = SlotHolder(e.target);
			slot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
			if (slot is BuildingSlotHolder)
			{
				onBuildingContructed()
			}
			else
			{
				pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
				infantryBeingBuilt = false;
				vehicleBeingBuilt = false;
				myUnitSlotbj = null;
				buildUnits();
			}
		}
		
		private function onVehicleComplete(e:Event):void 
		{
			pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
			vehicleBeingBuilt = false;
			myUnitSlotbj = null;
			buildUnits();
		}
		
		public function update(_pulse:Boolean):void
		{
			if (_pulse)
			{
				var numUnits:int = 0;
				var myTeam:Array = [];
				for (var i:int = 0; i < pcTeamObj.team.length; i++ )
				{
					var p:GameEntity = pcTeamObj.team[i];
					if (p is Unit && p != null && p.model != null && p.model.dead == false && !(p is Harvester))
					{
						if (p.aiBehaviour != AiBehaviours.SEEK_AND_DESTROY)
						{
							myTeam.push(p);
						}
					}
				}
				
				if (myTeam.length >= minNumOfAttackParty[currentAttackPartyCount])
				{
					for (i = 0; i < minNumOfAttackParty[currentAttackPartyCount]; i++ )
					{
						var p:GameEntity = myTeam[i];
						p.changeAI(AiBehaviours.SEEK_AND_DESTROY);
					}
					//trace("sendin " + minNumOfAttackParty[currentAttackPartyCount] + " to attack!")
					currentAttackPartyCount++;
					
					if (currentAttackPartyCount > minNumOfAttackParty.length)
					{
						currentAttackPartyCount = 0;
					}
				}
			}
		}
	}
}