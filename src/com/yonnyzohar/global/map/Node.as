package com.yonnyzohar.global.map
{
	import com.yonnyzohar.global.enums.Agent;
	import com.yonnyzohar.global.map.mapTypes.Board;
	import com.yonnyzohar.global.Parameters;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import com.yonnyzohar.states.game.entities.units.Unit;
	import com.yonnyzohar.states.game.entities.GameEntity;

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Node 
	{
		protected var _seen:Boolean = false;
		public var groundTile:Image
		public var obstacleTile:MovieClip;
		public var shoreTile:Image;
		public var cliffTile:Image;
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
		private var debugTile:Quad;
		
		public function Node() 
		{
			
		}
		
		public function showDebugTile():void
		{
			if (debugTile == null)
			{
				debugTile = new Quad(Parameters.tileSize, Parameters.tileSize);
				debugTile.x = Parameters.tileSize * col;
				debugTile.y = Parameters.tileSize * row;
				debugTile.touchable = false;
				debugTile.alpha = 0.1;
				Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(debugTile);
			}
		}
		
		public function hideDebugTile():void
		{
			if (debugTile) 
			{
				debugTile.removeFromParent(true);
				debugTile = null;
			}
		}
		

		
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
				if (prevSeen == false && shoreTile)
				{
					Board.mapContainerArr[Board.OBSTACLE_LAYER].addChildAt(shoreTile,0);
				}
				if (prevSeen == false && cliffTile)
				{
					Board.mapContainerArr[Board.OBSTACLE_LAYER].addChildAt(cliffTile,0);
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
		
		public function dispose():void 
		{
			if (groundTile)
			{
				groundTile.dispose();
				groundTile.removeFromParent();
				groundTile = null;
			}
			
			if (obstacleTile)
			{
				obstacleTile.dispose();
				obstacleTile.removeFromParent();
				obstacleTile = null;
			}
			
			if (shoreTile)
			{
				shoreTile.dispose();
				shoreTile.removeFromParent();
				shoreTile = null;
			}
			
			if (cliffTile)
			{
				cliffTile.dispose();
				cliffTile.removeFromParent();
				cliffTile = null;
			}
			

			occupyingUnit = null;
		}
		
	}

}