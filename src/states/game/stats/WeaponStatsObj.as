package states.game.stats
{
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class WeaponStatsObj extends AssetStatsObj
	{
        public var damage:int  =  8;
        public var projectile:BulletStatsObj;
        public var rateOfFire:int = 20;
        public var range:int =  2;
        public var sound:String = "mgun2";
		public var secondaryRateOfFire:int = 0;
		public var canAttackAir:Boolean = true;
		public var muzzleFlash:String;
		
		public function WeaponStatsObj() 
		{
			
		}
		
	}

}