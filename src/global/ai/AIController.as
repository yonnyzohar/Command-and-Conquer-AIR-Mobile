package global.ai 
{
	import global.assets.GameAssets;
	import global.Methods;
	import global.ui.hud.slotIcons.SlotHolder;
	import starling.events.Event;
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
		
		public function AIController() 
		{
			aiJSON = JSON.parse(new GameAssets.AIJson());
		}
		
		public function applyAI(teamObj:TeamObject):void 
		{
			pcTeamObj = teamObj;
			
			//buildQueue
			buildBuilding();
		}
		
		private function buildBuilding():void 
		{
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
						var myBuildSlot:SlotHolder = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
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
				else
				{
					//build power station, on complete - build
					currentBuildingObj = Methods.getCurretStatsObj("power-plant");
					if (pcTeamObj.cash >= currentBuildingObj.cost)
					{
						var myBuildSlot:SlotHolder = pcTeamObj.buildManager.hud.getSlot(currentBuildingObj.name);
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
		}
		
		private function placeBuilding(e:Event):void 
		{
			trace("BUILDING_CONSTRUCTION_COMPLETED - now let's place it");
			pcTeamObj.buildManager.removeEventListener("BUILDING_CONSTRUCTION_COMPLETED", placeBuilding);
			pcTeamObj.buildManager.addEventListener("ASSET_CONSTRUCTED", onBuildingContructed);
			pcTeamObj.buildManager.buildingPlacementMarker.getValidPlacement()
		}
		
		private function onBuildingContructed(e:Event):void 
		{
			trace("ASSET_CONSTRUCTED, move on");
			pcTeamObj.buildManager.removeEventListener("ASSET_CONSTRUCTED", onBuildingContructed);
			buildCount++;
			buildBuilding();
		}
		
	}

}