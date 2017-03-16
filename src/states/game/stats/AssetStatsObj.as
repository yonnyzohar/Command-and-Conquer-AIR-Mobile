package states.game.stats 
{
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class AssetStatsObj 
	{
		public var type:String;
		public var name:String;
		public var totalHealth:int;
		public var sight:int;
		private var _cost:int;
		public var dependency:Array;
		public var owner:String;
		public var rotationType:int = 8;
		public var constructedIn:Array;
		
		//this is vehicle specific but there is no multiple inheritence in flash so fuck it
		public var numOfCannons:int = 1;//firesTwice
		public var speed:Number;
		public var singleAnimState:Boolean = false;//means there is no walk, shoot etc..
		public var weapon:WeaponStatsObj;
		public var connectedSprites:Array;
		
		public var pixelOffsetX:int;
		public var pixelOffsetY:int;
		public var selectOffsetX:int;
		public var selectOffsetY:int;
		public var pixelHeight:int;
		public var pixelWidth:int;
		public var tech:int = 0;
		
		public function get cost():int 
		{
			return _cost;
		}
		
		public function set cost(value:int):void 
		{
			_cost = value ;
		}
		
		
		
	}

}