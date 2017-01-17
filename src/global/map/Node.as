package  global.map
{
	import global.enums.Agent;
	import global.Parameters;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import states.game.entities.units.Unit;
	import states.game.entities.GameEntity;

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Node 
	{
		protected var _seen:Boolean = false;
		public var groundTile:Image
		public var obstacleTile:MovieClip;
		public var shoreCliffTile:Image;
		public var isWater:Boolean = false;
		public var isResource:Boolean = false;
		public var type:int = 0;
		public var g:int = 0;
		public var h:int = 0;
		public var f:int = 0;
		public var parent:Node;
		public var row:int;
		public var col:int;
		public var walkable:Boolean = true;
		public var regionNum:int = 1;
		public var occupyingUnit:GameEntity = null;
		public var withinUnitRange:int = 0;//if zero- then this tile is not within the range of any unit, else it will get the unique id of the unit
		public static var CHANGE_MADE_TO_MAP:Boolean = true;
		public var num:int = 0;
		
		public function Node() 
		{
			
		}
		
		/*public function listenTile():void
		{
			obstacleTile.touchable = true;
			obstacleTile.addEventListener(TouchEvent.TOUCH, onTiberiumClicked);
		}
		
		private function onTiberiumClicked(e:TouchEvent):void 
		{
			var end:Touch    = e.getTouch(obstacleTile, TouchPhase.ENDED);
			
			if(end)
			{
				//trace("isResource " + isResource);
				//trace("regionNum " + regionNum);
				//trace("walkable " + walkable);
				//trace("occupyingUnit " + occupyingUnit)
			}
		}*/
		
		public function get seen():Boolean 
		{
			return _seen;
		}
		
		public function set seen(value:Boolean):void 
		{
			var prevSeen:Boolean = _seen;
			_seen = value;
			
			if (_seen == true)
			{
				if (prevSeen == false && shoreCliffTile)
				{
					Parameters.mapHolder.addChild(shoreCliffTile);
				}
				
				if (groundTile)
				{
					if(groundTile.visible == false)groundTile.visible = true;
				}
				if (obstacleTile)
				{
					if(obstacleTile.visible == false)obstacleTile.visible = true;
				}
				
				if (occupyingUnit)
				{
					if (occupyingUnit.myTeamObj)
					{
						if (occupyingUnit.myTeamObj.agent == Agent.PC)
						{
							if (occupyingUnit.view)
							{
								if (occupyingUnit.view.visible == false)
								{
									occupyingUnit.view.visible = true;
								}
							}
						}
					}
				}

			}
			else 
			{
				if (groundTile)
				{
					if(groundTile.visible == true)groundTile.visible = false;
				}
				if (obstacleTile)
				{
					if(obstacleTile.visible == true)obstacleTile.visible = false;
				}
				if (occupyingUnit)
				{
					if (occupyingUnit.myTeamObj)
					{
						if (occupyingUnit.myTeamObj.agent == Agent.PC)
						{
							if (occupyingUnit.view)
							{
								if (occupyingUnit.view.visible == true)
								{
									occupyingUnit.view.visible = false;
								}
							}
						}
					}
				}
			}
			
			if (prevSeen != _seen)
			{
				Node.CHANGE_MADE_TO_MAP = true;
			}
		}
		
	}

}