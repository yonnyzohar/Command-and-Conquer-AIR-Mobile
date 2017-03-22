package states.game.entities.units
{
	import states.game.entities.EntityModel;
	import states.game.stats.UnitSounds;
	import states.game.stats.AssetStatsObj;

	public class UnitModel extends EntityModel
	{
		public var rotating:Boolean = false;
		public var lockedOnTarget:Boolean = false;
		public var path:Array = [];
		public var moveCounter:int = 0;
		
		public var userOverrideAutoShoot:Boolean = false;
		
		
		public var moving:Boolean = false;
		public var inWayPoint:Boolean = true;
		
		public var destX:Number;
		public var destY:Number;
		
		//shoot
		public var shootCount:int = 0;

		
		
		
		
		public function UnitModel()
		{
			
		}
		
		
		override public function dispose():void
		{
			path = null;
			enemyTeams = null;
			
			
		}
	}
}