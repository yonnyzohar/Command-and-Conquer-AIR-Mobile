package states.game.stats
{
	import flash.utils.Dictionary;
	import global.assets.Assets;
	import global.Parameters;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class VehicleStats 
	{
		public static var dict:Dictionary;

		public static function init():void
		{
			dict = new Dictionary();
			for (var vehicle:String in Assets.vehicles.list)
			{
				var curUnit:Object = Assets.vehicles.list[vehicle];
				var vehicleObj:VehicleStatsObj  = new VehicleStatsObj();
				
				vehicleObj.type			  = Assets.vehicles.type;
				vehicleObj.totalHealth    = curUnit.totalHealth;  
				vehicleObj.sight     	  = curUnit.sight;   
				vehicleObj.name       	  = curUnit.name;     
				vehicleObj.speed          = curUnit.speed  * Parameters.UNIT_MOVE_FACTOR;      
				vehicleObj.turnSpeed      = curUnit.turnSpeed  * Parameters.UNIT_MOVE_FACTOR;  
				vehicleObj.idleRotate     = curUnit.idleRotate ;  
				vehicleObj.rotationType   = curUnit.rotationType ;
				vehicleObj.sounds         = curUnit.sounds ;      
				vehicleObj.weapon         = WeaponStats.dict[curUnit.primaryWeapon] ;      
				vehicleObj.dependency     = curUnit.dependency  ; 
				vehicleObj.constructedIn  = curUnit.constructedIn;
				vehicleObj.owner 		  = curUnit.owner 	;	
				vehicleObj.cost 		  = curUnit.cost	;	
				vehicleObj.crusher 		  = curUnit.crusher 	;	
				vehicleObj.numOfCannons   = 1;
				vehicleObj.hasTurret	  = curUnit.hasTurret;
				vehicleObj.totalHealth 	  = curUnit.hitPoints;//done
				
				vehicleObj.pixelOffsetX  = curUnit.pixelOffsetX;
				vehicleObj.pixelOffsetY  = curUnit.pixelOffsetY;
				vehicleObj.selectOffsetX = curUnit.selectOffsetX;
				vehicleObj.selectOffsetY = curUnit.selectOffsetY;
				vehicleObj.pixelHeight   = curUnit.pixelHeight;
				vehicleObj.pixelWidth    = curUnit.pixelWidth;
				vehicleObj.tech			 = curUnit.tech;
				vehicleObj.connectedSprites = curUnit.connectedSprites;
				
				if (curUnit.firesTwice == true)
				{
					vehicleObj.numOfCannons = 2;
				}
				 	
				vehicleObj.deathAnimation = curUnit.deathAnimation;// "napalm3",
				
				dict[curUnit.name] = vehicleObj;
			}
		}
		
	}

}