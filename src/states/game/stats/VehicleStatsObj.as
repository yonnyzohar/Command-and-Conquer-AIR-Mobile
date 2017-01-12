package states.game.stats
{
	import global.pools.Pool;
	import states.game.stats.WeaponStatsObj;
	
	import states.game.stats.UnitSounds;

	public class VehicleStatsObj extends AssetStatsObj
	{
		public var hasTurret:Boolean;
		public var turnSpeed:Number;
		public var idleRotate:Boolean;
		
		//public var occupyArr:Array;
		public var sounds:UnitSounds;
		public var crusher:Boolean;
		
		public var deathAnimation:String;// image animation when dying
		
	}
}