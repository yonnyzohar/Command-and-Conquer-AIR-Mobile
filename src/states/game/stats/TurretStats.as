package states.game.stats 
{
	import flash.utils.Dictionary;
	import global.assets.Assets;
	import global.Parameters;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class TurretStats 
	{
		public static var dict:Dictionary;
		
		public static function init():void
		{
			dict = new Dictionary();
			
			for (var turret:String in Assets.turrets.list)
			{
				var curTurret:Object = Assets.turrets.list[turret];
				var turretObj:TurretStatsObj  = new TurretStatsObj();
				
				turretObj.type			= Assets.turrets.type;
				turretObj.name 			= curTurret.name;
				turretObj.totalHealth 	= curTurret.hitPoints;
				turretObj.dependency  	= curTurret.dependency;
				turretObj.owner 		= curTurret.owner;
				turretObj.cost			= curTurret.cost;
				turretObj.powerIn		= curTurret.powerIn;
				turretObj.powerOut		= curTurret.powerOut;
				turretObj.sight			= curTurret.sight;
				turretObj.gridShape		= curTurret.gridBuild;
				turretObj.weapon = WeaponStats.dict[curTurret.primaryWeapon];
				turretObj.turnSpeed		= curTurret.turnSpeed * Parameters.UNIT_MOVE_FACTOR;
				turretObj.rotationType  = curTurret.directions;
				
				turretObj.pixelOffsetX  = curTurret.pixelOffsetX;
				turretObj.pixelOffsetY  = curTurret.pixelOffsetY;
				turretObj.selectOffsetX = curTurret.selectOffsetX;
				turretObj.selectOffsetY = curTurret.selectOffsetY;
				turretObj.pixelHeight   = curTurret.pixelHeight;
				turretObj.pixelWidth    = curTurret.pixelWidth;
				turretObj.tech			= curTurret.tech;
				turretObj.connectedSprites = curTurret.connectedSprites;
				turretObj.fireIndex = curTurret.fireIndex;
				
				dict[curTurret.name] = turretObj;
			}
		}
	}
}