package global.ai 
{
	import flash.utils.setTimeout;
	import global.assets.GameAssets;
	import global.enums.AiBehaviours;
	import global.Methods;
	import global.Parameters;
	import global.ui.hud.slotIcons.BuildingSlotHolder;
	import global.ui.hud.slotIcons.SlotHolder;
	import global.utilities.GameTimer;
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.units.Harvester;
	import states.game.entities.units.Unit;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.BuildingsStatsObj;
	import states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class AIController 
	{
		
		private var aiJSON:Object;
		private var pcTeamObj:TeamObject;
		public var buildCount:int  = 0;
		public var turretCount:int = 0;
		
		
		private var myUnitSlotbj:Object;
		
		
		private var infantryArr:Array = [];
		private var vehiclesArr:Array = [];
		private var minNumOfAttackParty:Array;
		
		private var infantryBeingBuilt:Boolean = false;
		private var vehicleBeingBuilt:Boolean = false;
		private var buildingBeingBuilt:Boolean = false;
		
		private var currentAttackPartyCount:int = 0;
		private var PRINT_AI_FLOW:Boolean = true;
		
		private var myInfantrySlot:SlotHolder;
		private var myVehicleSlot:SlotHolder;
		private var myBuildSlot:SlotHolder;
		private var myTurretSlot:SlotHolder
		
		public function AIController() 
		{
			aiJSON = {
					"buildQueue":[
						"refinery",
						"barracks",
						"hand-of-nod",
						"airstrip",
						"weapons-factory",
						"communications-center"
					],
					"turretQueue":[
						"gun-turret",
						"guard-tower",
						"obelisk",
						"advanced-guard-tower"
					],
					"infantryQueue":{
						"minigunner" : 10,
						"bazooka": 6,
						"grenadier": 6,
						"flame-thrower": 3
					},
					"vehicleQueue":{
						"buggy":10,
						"jeep":9,
						"recon-bike":8,
						"light-tank":7,
						"medium-tank":7,
						"flame-tank":6,
						"stealth-tank":5,
						"mammoth-tank":3,
						"artillery":1,
						"mobile-rocket-launch-system":1,
						"ssm-launcher":1
					}
				};

			//JSON.parse(new GameAssets.AIJson());
		}
		
		public function applyAI(teamObj:TeamObject, savedObject:Object = null):void 
		{
			
			//o.aiData
			pcTeamObj = teamObj;
			
			if (savedObject)
			{
				buildCount = savedObject.aiData.buildCount;
				turretCount = savedObject.aiData.turretCount;
			}
			
			
			
			createProbabilityArr();
			
			//buildQueue
			buildBuilding(true);
			
			buildUnits();
			
			minNumOfAttackParty = [];
			for (var i:int = 0; i < 10; i++ )
			{
				var rnd:int = 3 + int(Math.random() * 15)
				minNumOfAttackParty.push(rnd);
			}
			//minNumOfAttackParty = aiJSON.minNumOfAttackParty;
			
			GameTimer.getInstance().addUser(this);
			//Parameters.loadingScreen.init();
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
					probabilityNum = allVehicles[k];
					
					for (i = 0; i < probabilityNum; i++ )
					{
						vehiclesArr.push(k);
					}
				}
			}
			
		}
		
		////////////////////////////////////////////--turrets----------///////////////////////////////
		private function buildTurrets():void 
		{
			if (buildingBeingBuilt)
			{
				return;
			}
			
			if (pcTeamObj.doesBuildingExist("barracks") == false)
			{
				return;
			}
			
			if (pcTeamObj.doesBuildingExist("vehicle-factory") == false)
			{
				if (Math.random() > 0.3)
				{
					return;
				}
			}
			
			if (aiJSON.turretQueue[turretCount])
			{
				var currentTurretObj:AssetStatsObj = Methods.getCurretStatsObj(aiJSON.turretQueue[turretCount]);
				if (pcTeamObj.powerCtrl.POWER_SHORTAGE)
				{
					return;
				}
				if (pcTeamObj.doesBuildingExist("refinery") == false)
				{
					return;
				}
				if (pcTeamObj.cashManager.cash < currentTurretObj.cost)
				{
					return;
				}
				myTurretSlot = pcTeamObj.buildManager.hud.getSlot(currentTurretObj.name);
				if (myTurretSlot)
				{
					myTurretSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onTurretCancelledAbruptly);
					buildingBeingBuilt = true;
					pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeTurret);
					myTurretSlot.simulateClickOnBuild();		
				
				}
				else
				{
					turretCount++;
				}
			}
			else
			{
				turretCount = 0;
			}
		}
		
		private function placeTurret(e:Event):void 
		{
			printAI(myTurretSlot.assetName + " CONSTRUCTION_COMPLETED - now let's place it");
			if (pcTeamObj)
			{
				pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeTurret);
				pcTeamObj.buildManager.addEventListener("BUILDING_PLACED", onTurretContructed);
				pcTeamObj.buildManager.buildingPlacementMarker.pupulateTilesSprite(myTurretSlot.assetName);
				pcTeamObj.buildManager.buildingPlacementMarker.getValidPlacementClosestToEnemy();
			}
			
		}
		
		private function onTurretContructed(e:Event = null):void 
		{
			printAI("onTurretContructed");
			if (pcTeamObj)
			{
				pcTeamObj.buildManager.removeEventListener("BUILDING_PLACED", onTurretContructed);
			}
			turretCount++;
			buildingBeingBuilt = false;
		}
		
		private function onTurretCancelledAbruptly(e:Event):void 
		{
			var slot:SlotHolder = SlotHolder(e.target);
			slot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onTurretCancelledAbruptly);
			if (pcTeamObj)
			{
				pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeTurret);
				pcTeamObj.buildManager.removeEventListener("BUILDING_PLACED", onTurretContructed);
			}
			
			printAI("onBuildCancelledAbruptly - building");
			buildingBeingBuilt = false;
		}
		
		////////////////////////////////////////////---BUILDINGS---------/////////////////////////////////////
		
		private function buildBuilding(_firstTime:Boolean = false):void 
		{
			
			//if there are still stuff to build
			
			if (buildingBeingBuilt)
			{
				if (myBuildSlot == null)
				{
					buildingBeingBuilt = false;
					return;
				}
				
				if (myBuildSlot.currentBuildState == SlotHolder.BUILD_DONE )
				{
					myBuildSlot.forceFinishBuild();
				}
				
				return;
			}
			var currentBuildingObj:AssetStatsObj;
			var buildPowerPlant:Boolean = false;
			if (_firstTime || pcTeamObj.powerCtrl.POWER_SHORTAGE)
			{
				buildPowerPlant = true;
				currentBuildingObj = Methods.getCurretStatsObj("power-plant");
			}
			else
			{
				if (aiJSON.buildQueue[buildCount])
				{
					currentBuildingObj = Methods.getCurretStatsObj(aiJSON.buildQueue[buildCount]);
				}
				else
				{
					buildCount = 0;
				}
				
				if (pcTeamObj.doesBuildingExist("barracks") == false)
				{
					currentBuildingObj = Methods.getCurretStatsObj("barracks");
					
					if (currentBuildingObj.owner != pcTeamObj.teamName)
					{
						currentBuildingObj = Methods.getCurretStatsObj("hand-of-nod");
					}
				}
				
				if (pcTeamObj.doesBuildingExist("refinery") == false)
				{
					currentBuildingObj = Methods.getCurretStatsObj("refinery");
				}
			}

			if (currentBuildingObj)
			{

				//if we have power - proceed
				if (!buildPowerPlant)
				{
					
					if (pcTeamObj.doesBuildingExist(BuildingsStatsObj(currentBuildingObj).buildingType))
					{
						buildCount++;
						return;
					}
					
					//if we have money - build, on complete come back to here
					if (pcTeamObj.cashManager.cash >= currentBuildingObj.cost)
					{
						myBuildSlot = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
						if (myBuildSlot)
						{
							printAI("building " + currentBuildingObj.name);
							myBuildSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
							buildingBeingBuilt = true;
							pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
							myBuildSlot.simulateClickOnBuild();
							
						}
						else
						{
							printAI(currentBuildingObj.name + " slot does not exist");
							buildCount++;
						}
					}
				}
				else
				{
					//build power station, on complete - build
					if (pcTeamObj.cashManager.cash >= currentBuildingObj.cost)
					{
						myBuildSlot = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
						if (myBuildSlot)
						{
							printAI("building " + currentBuildingObj.name);
							buildingBeingBuilt = true;
							myBuildSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
							pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
							myBuildSlot.simulateClickOnBuild();
							
							
						}
						else
						{
							printAI(currentBuildingObj.name + " slot does not exist");
						}
					}
				}
			}
		}
		
		
		private function placeBuilding(e:Event):void 
		{
			printAI(myBuildSlot.assetName + " BUILDING_CONSTRUCTION_COMPLETED - now let's place it");
			if (pcTeamObj)
			{
				myBuildSlot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
				pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
				pcTeamObj.buildManager.addEventListener("BUILDING_PLACED", onBuildingPlaced);
				pcTeamObj.buildManager.buildingPlacementMarker.pupulateTilesSprite(myBuildSlot.assetName);
				pcTeamObj.buildManager.buildingPlacementMarker.getValidPlacement()
			}
		}
		

		private function onBuildingPlaced(e:Event = null):void 
		{
			if (pcTeamObj)
			{
				printAI("onBuildingPlaced " + myBuildSlot.assetName);
				pcTeamObj.buildManager.removeEventListener("BUILDING_PLACED", onBuildingPlaced);
			}
			if (myBuildSlot.assetName != "power-plant")
			{
				buildCount++;
			}
			buildingBeingBuilt = false;
		}
		
		
		private function onBuildCancelledAbruptly(e:Event):void 
		{
			var slot:SlotHolder = SlotHolder(e.target);
			slot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
			if (pcTeamObj)
			{
				pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
				pcTeamObj.buildManager.removeEventListener("BUILDING_PLACED", onBuildingPlaced);
			}
			
			printAI("onBuildCancelledAbruptly - building");
			buildingBeingBuilt = false;
		}
		
		//////////////////////////////////////////--------------------UNITS------//////////////////////////////////////////
		
		
		private function buildUnits():void 
		{
			printAI("buildUnits " + infantryBeingBuilt + " " + vehicleBeingBuilt);
			if (pcTeamObj.powerCtrl.POWER_SHORTAGE)
			{
				return;
			}
			if (pcTeamObj.doesBuildingExist("refinery") == false)
			{
				return;
			}
			
			if (infantryBeingBuilt && vehicleBeingBuilt)
			{
				return;
			}
			
			if (pcTeamObj.doesBuildingExist("vehicle-factory") == false)
			{
				if (Math.random() > 0.3)
				{
					return;
				}
			}
			
			var infantry:Boolean = false;
			var vehicles:Boolean = false;
			
			if (infantryBeingBuilt)
			{
				infantry = true;
			}
			if (vehicleBeingBuilt)
			{
				vehicles = true;
			}
			
			
			if (pcTeamObj.doesBuildingExist("barracks") && infantryBeingBuilt == false)
			{
				infantry = true;
			}
			
			if (pcTeamObj.doesBuildingExist("vehicle-factory") && vehicleBeingBuilt == false)
			{
				vehicles = true;
			}
			
			if (myUnitSlotbj == null)
			{
				if (infantry && vehicles) 
				{
					if (pcTeamObj.getHarvester() == null)
					{
						if (!vehicleBeingBuilt)
						{
							buildVehicles();
						}
					}
					else 
					{
						if (Math.random() < 0.4 )
						{
							if (!infantryBeingBuilt)
							{
								buildInfantry();
							}
						}
						else
						{
							if (!vehicleBeingBuilt)
							{
								buildVehicles();
							}
						}
					}
					
				}
				else if(infantry && !vehicles)
				{
					if (!infantryBeingBuilt)
					{
						buildInfantry();
					}
				}
				else if (!infantry && vehicles)
				{
					if (!vehicleBeingBuilt)
					{
						buildVehicles()
					}
				}
				else
				{
					printAI("no barracks or vehicle factory, try again soon " + Math.random());
				}
			}
			else
			{
				//we saved on to a desired unit, try to build it
				printAI("trying to build saved unit " + myUnitSlotbj.name);
				if (pcTeamObj.cashManager.cash >= myUnitSlotbj.cost)
				{
					if (myUnitSlotbj && myUnitSlotbj.type == "vehicle" )
					{
						if (vehicles == true && !vehicleBeingBuilt)
						{
							vehicleBeingBuilt = true;
							myUnitSlotbj.slot = pcTeamObj.buildManager.hud.getSlot(myUnitSlotbj.name);
							myUnitSlotbj.slot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onVehicleBuildCancelledAbruptly);
							pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
							myUnitSlotbj.slot.simulateClickOnBuild();
							printAI("training " + myUnitSlotbj.name);
							
						}
						else
						{
							myUnitSlotbj = null;
						}
					}
					
					if (myUnitSlotbj && myUnitSlotbj.type == "infantry")
					{
						if (infantry == true && !infantryBeingBuilt)
						{
							
							myUnitSlotbj.slot = pcTeamObj.buildManager.hud.getSlot(myUnitSlotbj.name);
							infantryBeingBuilt = true;
							
							myUnitSlotbj.slot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onInfantryBuildCancelledAbruptly);
							pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
							myUnitSlotbj.slot.simulateClickOnBuild();
							printAI("training " + myUnitSlotbj.name);
							
						}
						else
						{
							myUnitSlotbj = null;
						}
					}
				}
				else
				{
					printAI("no money for " + myUnitSlotbj.name + "!, trying again")
				}
			}
		}
		
		
		
		
		
		private function buildInfantry(e:Event = null):void 
		{
			myInfantrySlot = null;
			
			if (pcTeamObj.doesBuildingExist("barracks"))
			{
				var rnd:int = Math.random() * infantryArr.length;
				var randomInfantry:String = infantryArr[rnd];
				var currentInfantrygObj:AssetStatsObj = Methods.getCurretStatsObj(randomInfantry);
				
				myInfantrySlot = pcTeamObj.buildManager.hud.getSlot(randomInfantry);
				
				if (myInfantrySlot)
				{
					
					if ( pcTeamObj.cashManager.cash >= currentInfantrygObj.cost)
					{
						infantryBeingBuilt = true;
						myInfantrySlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onInfantryBuildCancelledAbruptly);
						pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
						myInfantrySlot.simulateClickOnBuild();
						printAI("training " + randomInfantry);
						
					}
					else
					{
						myUnitSlotbj = { slot : pcTeamObj.buildManager.hud.getSlot(randomInfantry), cost : currentInfantrygObj.cost , type : "infantry" , name : randomInfantry};
						printAI("no money for " + randomInfantry + " trying again");
					}
				}
				else
				{
					printAI(randomInfantry + " does not exist");
				}
			}
			else
			{
				printAI("no barracks");
			}
		}
		
		private function onInfantryComplete(e:Event):void 
		{
			pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
			myUnitSlotbj = null;
			infantryBeingBuilt = false;
			
			printAI("	onInfantryComplete");
		}
		
		private function onInfantryBuildCancelledAbruptly(e:Event):void 
		{
			var slot:SlotHolder = SlotHolder(e.target);
			slot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onInfantryBuildCancelledAbruptly);
			if (pcTeamObj)
			{
				pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
			}
			
			infantryBeingBuilt = false;
			myUnitSlotbj = null;
		}
		
		
		/////////////////////////////-----------------------VEHICLES-------////////////////////////
		
		
		
		
		private function buildVehicles():void 
		{
			myVehicleSlot = null;

				
			if (pcTeamObj.doesBuildingExist("vehicle-factory"))
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
					if (numHarvesters < 3)
					{
						if (Math.random() < 0.05)
						{
							randomVehicle = "harvester";
						}
					}
					
				}
				
				var currentVehicleObj:AssetStatsObj = Methods.getCurretStatsObj(randomVehicle);
				myVehicleSlot = pcTeamObj.buildManager.hud.getSlot(randomVehicle);
				
				if ( myVehicleSlot )
				{
					
					if (pcTeamObj.cashManager.cash >= currentVehicleObj.cost)
					{
						myVehicleSlot.addEventListener("BUILD_CANCELLED_ABRUPTLY", onVehicleBuildCancelledAbruptly);
						pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
						myVehicleSlot.simulateClickOnBuild();
						vehicleBeingBuilt = true;
						printAI("training " + randomVehicle);
						
					}
					else
					{
						myUnitSlotbj = { slot : pcTeamObj.buildManager.hud.getSlot(randomVehicle), cost : currentVehicleObj.cost , type : "vehicle", name : randomVehicle };
						printAI("no money for " + randomVehicle + " trying again");
					}
				}
				else
				{
					printAI(randomVehicle + " does not exist");
				}
			}
			else
			{
				printAI("no weapons-factory");
			}

		}
		
		private function onVehicleComplete(e:Event):void 
		{
			pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
			vehicleBeingBuilt = false;
			myUnitSlotbj = null;
			printAI("	onVehicleComplete");
		}
		
		private function onVehicleBuildCancelledAbruptly(e:Event):void 
		{
			var slot:SlotHolder = SlotHolder(e.target);
			slot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onVehicleBuildCancelledAbruptly);
			if (pcTeamObj)
			{
				pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
			}
			
			vehicleBeingBuilt = false;
			myUnitSlotbj = null;
		}
		
		
		///////////////////////////////----------UPDATE-------//////////////////////////////
		
		
		public function update(_pulse:Boolean):void
		{
			if (_pulse)
			{
				
				
				
				if (Math.random() > 0.5)
				{
					buildUnits();
				}
				else
				{
					if (Math.random() > 0.5)
					{
						buildBuilding();
					}
					else
					{
						buildTurrets();
					}
				}
				
				if (pcTeamObj.doesBuildingExist("vehicle-factory") == false)
				{
					if (Math.random() > 0.5) 
					{
						return;
					}	
				}

				
				var numUnits:int = 0;
				var myTeam:Array = [];
				var teamLen:int = pcTeamObj.team.length;
				for (var i:int = 0; i < teamLen; i++ )
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
						p = myTeam[i];
						p.changeAI(AiBehaviours.SEEK_AND_DESTROY);
					}
					printAI("sendin " + minNumOfAttackParty[currentAttackPartyCount] + " to attack!")
					currentAttackPartyCount++;
					
					if (minNumOfAttackParty[currentAttackPartyCount+1] == undefined)
					{
						currentAttackPartyCount = 0;
					}
					
				}
				
			}
		}
		
		
		
		
		private function printAI(_str:String):void
		{
			if (PRINT_AI_FLOW)
			{
				//trace(pcTeamObj.teamName + " : " + _str);
				//Parameters.loadingScreen.displayMessage(_str);
			}
		}
		
		public function dispose():void 
		{
			GameTimer.getInstance().removeUser(this);
			if (myVehicleSlot)
			{
				myVehicleSlot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onVehicleBuildCancelledAbruptly);
			}
			myVehicleSlot = null;
			
			if (myInfantrySlot)
			{
				myInfantrySlot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onInfantryBuildCancelledAbruptly);
			}
			myInfantrySlot = null;
			
			if (myBuildSlot)
			{
				myBuildSlot.removeEventListener("BUILD_CANCELLED_ABRUPTLY", onBuildCancelledAbruptly);
			}
			myBuildSlot = null;
			
			
			pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
			pcTeamObj.buildManager.removeEventListener("BUILDING_PLACED", onBuildingPlaced);
			pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onInfantryComplete);
			pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", onVehicleComplete);
			
			pcTeamObj = null;
			
			infantryArr = null;
            vehiclesArr = null;
			myUnitSlotbj = null;

		}
	}
}