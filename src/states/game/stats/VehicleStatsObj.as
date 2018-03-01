package states.game.stats
{
	import global.pools.Pool;
	import states.game.stats.WeaponStatsObj;
	import global.Parameters;
	
	import states.game.stats.UnitSounds;

	public class VehicleStatsObj extends AssetStatsObj
	{
		public var hasTurret:Boolean;
		public var _turnSpeed:Number;
		public var idleRotate:Boolean;
		
		//public var occupyArr:Array;
		public var sounds:UnitSounds;
		public var crusher:Boolean;
		
		public var deathAnimation:String;// image animation when dying


		public function get turnSpeed():Number{
			return _turnSpeed * Parameters.UNIT_MOVE_FACTOR * Parameters.gameSpeed;
		}

		public function set turnSpeed(val:Number):void{
			_turnSpeed  = val;
		}

	}
}