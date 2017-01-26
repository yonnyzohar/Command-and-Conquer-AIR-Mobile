package global.ai 
{
	import flash.utils.setTimeout;
	import global.assets.GameAssets;
	import global.enums.AiBehaviours;
	import global.Methods;
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
		
		private var infantryArr:Array = [];
		private var vehiclesArr:Array = [];
		private var minNumOfAttackParty:Array;
		
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
			buildBuilding();
			//infantryQueue
			buildInfantry();
			//vehicleQueue
			buildVehicles();
			
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
					
					for (var i:int = 0; i <  probabilityNum; i++ )
					{
						vehiclesArr.push(k);
					}
				}
			}
			
			trace("infantryArr: " + infantryArr);
			trace("vehiclesArr: " + vehiclesArr);
			
		}
		
		
		
		private function buildBuilding():void 
		{
			myBuildSlot = null;
			//if there are still stuff to build
			if (aiJSON.buildQueue[buildCount])
			{
				var currentBuildingObj:AssetStatsObj = Methods.getCurretStatsObj(aiJSON.buildQueue[buildCount]);
				
				//if we have power - proceed
				if (pcTeamObj.powerCtrl.POWER_SHORTAGE == false)
				{
					//if we have money - build, on complete come back to here
					if (pcTeamObj.cash >= currentBuildingObj.cost)
					{
						myBuildSlot = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
						if (myBuildSlot)
						{
							myBuildSlot.simulateClickOnBuild();
							pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
						}
						else
						{
							trace(currentBuildingObj.name + " slot does not exist");
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
							pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
						}
						else
						{
							trace(currentBuildingObj.name + " slot does not exist");
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
					trace("NOTHING MORE TO BUILD")
				}
				
			}
		}
		
		
		private function placeBuilding(e:Event):void 
		{
			trace("BUILDING_CONSTRUCTION_COMPLETED - now let's place it");
			pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
			pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTED", onBuildingContructed);
			pcTeamObj.buildManager.buildingPlacementMarker.pupulateTilesSprite(myBuildSlot.assetName);
			pcTeamObj.buildManager.buildingPlacementMarker.getValidPlacement()
		}
		

		
		private function onBuildingContructed(e:Event):void 
		{
			trace("ASSET_CONSTRUCTED, move on");
			pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTED", onBuildingContructed);
			if (myBuildSlot.assetName != "power-plant")
			{
				buildCount++;
			}
			buildBuilding();
		}
		
		////////////////////////////////////////////////////////////////////////////////////
		
		private function buildInfantry(e:Event = null):void 
		{
			var myInfantrySlot:SlotHolder;
				pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTED", buildInfantry);
				pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", buildInfantry);
				
			if (Math.random() < 0.5 )
			{
				setTimeout(buildInfantry, 2000);
			}
			else
			{
				
				
				if (pcTeamObj.doesBuildingExist(["hand-of-nod", "barracks"]))
				{
					var rnd:int = Math.random() * infantryArr.length;
					var randomInfantry:String = infantryArr[rnd];
					var currentInfantrygObj:AssetStatsObj = Methods.getCurretStatsObj(randomInfantry);
					//var producingBuilding:Object = pcTeamObj.buildManager.getProducingBuilding(currentInfantrygObj, pcTeamObj.team);
					
					if (pcTeamObj.cash >= currentInfantrygObj.cost)
					{
						myInfantrySlot = pcTeamObj.buildManager.hud.getSlot(randomInfantry);
						if (myInfantrySlot)
						{
							trace("building a " + randomInfantry)
							myInfantrySlot.simulateClickOnBuild();
							pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", buildInfantry);
						}
						else
						{
							trace("COULD NOT FIND INFANTRY SLOT!!!")
						}
					}
					else
					{
						trace("no money!, trying again")
						setTimeout(buildInfantry, 2000);
					}
				}
				else
				{
					trace("no barracks!- waiting for it to be built!!!");
					pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTED", buildInfantry);
				}
			}
			
			
		}
		
		private function buildVehicles():void 
		{
			var myVehicleSlot:SlotHolder;
				pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTED", buildVehicles);
				pcTeamObj.buildManager.removeEventListener("UNIT_CONSTRUCTED", buildVehicles);
			if (Math.random() < 0.5 )
			{
				setTimeout(buildVehicles, 2000);
			}
			else
			{
				
				
				if (pcTeamObj.doesBuildingExist(["weapons-factory", "airstrip"]))
				{
					var rnd:int = Math.random() * vehiclesArr.length;
					var randomVehicle:String = vehiclesArr[rnd];
					var currentInfantrygObj:AssetStatsObj = Methods.getCurretStatsObj(randomVehicle);
					
					if (pcTeamObj.cash >= currentInfantrygObj.cost)
					{
						myVehicleSlot = pcTeamObj.buildManager.hud.getSlot(randomVehicle);
						if (myVehicleSlot)
						{
							trace("building a " + randomVehicle)
							myVehicleSlot.simulateClickOnBuild();
							pcTeamObj.buildManager.addEventListener("UNIT_CONSTRUCTED", buildVehicles);
						}
						else
						{
							trace("COULD NOT FIND VEHICLE SLOT!!!")
						}
					}
					else
					{
						trace("no money!, trying again")
						setTimeout(buildVehicles, 2000);
					}
				}
				else
				{
					trace("no war factory- waiting for it to be built!!!");
					pcTeamObj.buildManager.addEventListener("BUILDING_CONSTRUCTED", buildVehicles);
				}
			}
			
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
					trace("sendin " + minNumOfAttackParty[currentAttackPartyCount] + " to attack!")
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