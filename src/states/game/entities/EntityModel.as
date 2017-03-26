package states.game.entities
{
	import global.enums.UnitStates;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.UnitSounds;
	public class EntityModel
	{
		public var controllingAgent:int;
		public var dead:Boolean = false;
		public var teamName:String;
		public var enemyTeams:Array;
		public var isSelected:Boolean;
		public var row:int;
		public var col:int;
		public var prevRow:int;
		public var prevCol:int;
		public var totalHealth:int;
		public var stats:AssetStatsObj;
		public var sounds:UnitSounds;
		public var currentState:int = UnitStates.IDLE;
		public var lastState:int;
		public var teamColor:String;
		
		public function EntityModel()
		{
			
		}
		
		public function dispose():void
		{
			enemyTeams = null;
			stats = null;
		}
	}
}