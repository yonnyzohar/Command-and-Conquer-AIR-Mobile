package states.game.stats
{
	import flash.utils.Dictionary;
	import global.assets.Assets;
	
	import global.assets.GameAssets;
	

	public class BuildingsStats
	{
		public static var dict:Dictionary = new Dictionary();
		
		public static function init():void
		{
			//var buildingsJson:Object= JSON.parse(new GameAssets.UnitsAndBuildingsJson());
			//buildings = buildingsJson.buildings;
			
			for (var building:String in Assets.buildings.list)
			{
				var curBuilding:Object = Assets.buildings.list[building];
				var buildingObj:BuildingsStatsObj  = new BuildingsStatsObj();
				
				buildingObj.type		= Assets.buildings.type;
				buildingObj.name 		= curBuilding.name;
				buildingObj.totalHealth = curBuilding.hitPoints;
				buildingObj.dependency  = curBuilding.dependency;
				buildingObj.owner 		= curBuilding.owner;
				buildingObj.cost		= curBuilding.cost;
				buildingObj.powerIn		= curBuilding.powerIn;
				buildingObj.powerOut	= curBuilding.powerOut;
				buildingObj.sight		= curBuilding.sight;
				buildingObj.gridShape	= curBuilding.gridBuild;
				buildingObj.pixelWidth  = curBuilding.pixelWidth;
				buildingObj.pixelHeight = curBuilding.pixelHeight;
				buildingObj.tech		= curBuilding.tech;
				buildingObj.connectedSprites = curBuilding.connectedSprites;
				buildingObj.attachedUnit= curBuilding.attachedUnit;
				
				if (curBuilding.residents)
				{
					buildingObj.residents = curBuilding.residents;
				}
				
				dict[curBuilding.name] = buildingObj;
			}
			
		}
		
		
	}
}