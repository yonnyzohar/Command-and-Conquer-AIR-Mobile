package global.ai 
{
	import global.assets.GameAssets;
	import global.Methods;
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
			build();
		}
		
		private function build():void 
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
						pcTeamObj.buildManager.assetBeingBuilt(currentBuildingObj.name)
					}
					else
					{
						//if no money, wait x seconds then check again
					}
				}
				else
				{
					//build power station, on complete - build
				}
			}
		}
		
	}

}