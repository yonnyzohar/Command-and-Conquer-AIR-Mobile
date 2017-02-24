package states.game.stats
{
	import flash.utils.Dictionary;
	import global.assets.Assets;
	import global.Parameters;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class BulletStats 
	{
		
		public static var dict:Dictionary = new Dictionary();

		public static function init():void
		{
			for (var bullet:String in Assets.bullets.list)
			{
				var curBullet:Object = Assets.bullets.list[bullet];
				var bulletObj:BulletStatsObj  = new BulletStatsObj();
				
				bulletObj.name 			 = curBullet.name 		;	                  //:String; // "ballistic",
				bulletObj.explosion 	 = curBullet.explosion 	;                  //:String; // "art-exp1",
				bulletObj.warhead 		 = WarheadStats.dict[curBullet.warhead]	;	                  //:WarheadStatsObj;// "highexplosive",
				if (bulletObj.warhead == null)
				{
					//////trace("yo");
				}
				
				bulletObj.ballisticCurve = curBullet.ballisticCurve  ;                //:Boolean;// true,
				bulletObj.rotationSpeed  = curBullet.rotationSpeed  ;                 //:int;
				bulletObj.bulletSpeed    = curBullet.bulletSpeed    * Parameters.UNIT_MOVE_FACTOR;                  //:int;
				bulletObj.count 		 = curBullet.count 		 ;                 //:int;
				bulletObj.delay 		 = curBullet.delay 		;                  //:int;
				bulletObj.innacurate 	 = curBullet.innacurate ;	                  //:Boolean;
				bulletObj.smokeTrail 	 = curBullet.smokeTrail ;	                  //:Boolean;
				bulletObj.image 		 = curBullet.image 		;                  //:String;// "120mm",
				bulletObj.directions	 = curBullet.directions;
				
				/*name: "cannon",
				 explosion: "vehhit3",
				 warhead: "armorpiercing",
				 rotationSpeed: 0,
				 bulletSpeed: 100,
				 count: 1,
				 innacurate: false,
				 smokeTrail: false,
				 image: "120mm",*/
				
				//vehicleObj.occupyArr      = curUnit.
				dict[curBullet.name] = bulletObj;
			}
		}
		
	}

}