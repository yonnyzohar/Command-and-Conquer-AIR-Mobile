package states.game.stats
{
	import flash.utils.Dictionary;
	import global.assets.Assets;
	import global.Parameters;
	import states.game.stats.WeaponStats;
	
	import global.assets.GameAssets;
	import global.pools.PoolsManager;
	import states.game.stats.UnitSounds;

	public class InfantryStats
	{
		//private static var xml:XML;
		//public static var units:XMLList;
		
		//public static var units:Object;
		public static var dict:Dictionary = new Dictionary();
		
		
		//these are default values
		public static function init():void
		{
			//xml = XML(new GameAssets.UnitsXml());
			//units = xml.units.unit;
			
			//var unitsJson:Object= JSON.parse(new GameAssets.UnitsAndBuildingsJson());
			
			//units = unitsJson.units;
			
			for (var infantry:String in Assets.infantry.list)
			{
				var curUnit:Object = Assets.infantry.list[infantry];
				var infantryObj:InfantryStatsObj  = new InfantryStatsObj();
				
				infantryObj.type				= Assets.infantry.type;
				infantryObj.name 				= curUnit.name;//done
				infantryObj.totalHealth 	    = curUnit.hitPoints;//done
				infantryObj.sight 		    	= curUnit.sight;//done
				infantryObj.speed 				= curUnit.speed * Parameters.divisionFactor;   
				//infantryObj.idleRotate 		    = curUnit.idleRotate; -- this is for units turning when idle, change this 
				//infantryObj.occupyArr			= curUnit.occupyArr; -- try to live withut this
				infantryObj.rotationType		= curUnit.directions;
				infantryObj.weapon				= WeaponStats.dict[curUnit.primaryWeapon];
				infantryObj.sounds = new UnitSounds();
				
				if (curUnit.sounds)
				{
					infantryObj.sounds.dieSounds    = curUnit.sounds.dieSounds;
					infantryObj.sounds.orderSounds  = curUnit.sounds.orderSounds;
					infantryObj.sounds.selectSounds = curUnit.sounds.selectSounds;
					infantryObj.sounds.shootSounds  = curUnit.sounds.shootSounds;
				}
				
				infantryObj.dependency			= curUnit.dependency;//what buildiings in need to build this unit
                infantryObj.constructedIn		= curUnit.constructedIn; // what buildings can build this unit
                infantryObj.owner				= curUnit.owner; // gdi, nod or both
				infantryObj.cost				= curUnit.cost;
				
				infantryObj.pixelOffsetX  = curUnit.pixelOffsetX;
				infantryObj.pixelOffsetY  = curUnit.pixelOffsetY;
				infantryObj.selectOffsetX = curUnit.selectOffsetX;
				infantryObj.selectOffsetY = curUnit.selectOffsetY;
				infantryObj.pixelHeight   = curUnit.pixelHeight;
				infantryObj.pixelWidth    = curUnit.pixelWidth;
				infantryObj.tech		  = curUnit.tech;
				infantryObj.connectedSprites = curUnit.connectedSprites;
				
				dict[curUnit.name] = infantryObj;
			}
		}
	}
}