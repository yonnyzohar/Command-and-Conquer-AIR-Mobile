package  states.game.stats
{
	/**
	 * ...
	 * @author Yonny Zohar
	 */

	import global.Parameters;

	public class BulletStatsObj extends AssetStatsObj 
	{
        public var explosion:String; // "art-exp1",
        public var warhead:WarheadStatsObj;// "highexplosive",
        public var ballisticCurve:Boolean;// true,
        public var rotationSpeed:int;
        public var _bulletSpeed:Number;
        public var count:int;
        public var delay:int;
        public var innacurate:Boolean;
        public var smokeTrail:Boolean;
        public var image:String;// "120mm",
		public var directions:int;
		
		public function BulletStatsObj() 
		{
			
		}


		public function get bulletSpeed():Number{
			return _bulletSpeed * Parameters.UNIT_MOVE_FACTOR;
		}

		public function set bulletSpeed(val:Number):void{
			_bulletSpeed  = val;
		}
		
	}

}