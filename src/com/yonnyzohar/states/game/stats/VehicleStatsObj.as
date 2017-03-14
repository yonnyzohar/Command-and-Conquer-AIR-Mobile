package com.yonnyzohar.states.game.stats
{
	import com.yonnyzohar.global.pools.Pool;
	import com.yonnyzohar.states.game.stats.WeaponStatsObj;
	
	import com.yonnyzohar.states.game.stats.UnitSounds;

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