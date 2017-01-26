package global.ui.hud
{
	import flash.geom.Point;
	import global.enums.Agent;
	import global.enums.MouseStates;
	import global.map.Node;
	import global.Parameters;
	import global.utilities.GlobalEventDispatcher;
	import global.utilities.SightManager;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import states.game.stats.BuildingsStats;
	import states.game.stats.TurretStats;
	import states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class BuidingPlacementMarker extends EventDispatcher
	{
		private var view:Sprite;
		private var lastLoc:Point;
		public var targetRow:int;
		public var targetCol:int;
		private var buildingName:String;
		private var tilesArr:Array = [];
		private var COLLOR_RED:uint = 0xE1360A;
		private var COLLOR_GREEN:uint = 0x00FF00;
		private var isValidPlacementArea:Boolean = false;
		private var teamObj:TeamObject;
		
		public static const BUILDNG_SPOT_FOUND:String = "BUILDNG_SPOT_FOUND"
		
		public function BuidingPlacementMarker(_teamObj:TeamObject) 
		{
			teamObj = _teamObj;
			view = new Sprite();
			view.alpha = 0.5;
		}
		
		public function pupulateTilesSprite(_buildingName:String):void
		{
			buildingName = _buildingName;
			
			while (view.numChildren)
			{
				view.removeChildAt(0);
			}
			
			tilesArr.splice(0);
			
			var q:Quad;
			
			var occupyArray:Array;
			
			if (BuildingsStats.dict[_buildingName])
			{
				occupyArray = BuildingsStats.dict[_buildingName].gridShape;
			}
			else if(TurretStats.dict[_buildingName])
			{
				occupyArray = TurretStats.dict[_buildingName].gridShape;
			}
			
			
			for(var i:int = 0; i < occupyArray.length; i++)
			{
				tilesArr[i] = [];
				for (var j:int = 0; j < occupyArray[i].length; j++ )
				{
					var curTile:int = occupyArray[i][j];
					
					if (curTile == 0) 
					{
						tilesArr[i].push(0);
						continue;//this is only for build indication
					}
					
					q = new Quad(Parameters.tileSize, Parameters.tileSize, COLLOR_GREEN);
					q.alpha = 0.7;
					q.x = Parameters.tileSize * j;
					q.y = Parameters.tileSize * i;
					view.addChild(q)
					
					tilesArr[i].push(q);
				}
			}
			
			if (teamObj.agent == Agent.HUMAN)
			{
				Parameters.upperTilesLayer.addChild(view);
				MouseStates.currentState = MouseStates.PLACE_BUILDING;
				Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			}
			
		}
		
		private function onStageTouch(e:TouchEvent):void
		{
			if (MouseStates.currentState != MouseStates.PLACE_BUILDING) return;
			var begin:Touch    = e.getTouch(Parameters.theStage, TouchPhase.BEGAN);
			var move:Touch    = e.getTouch(Parameters.theStage, TouchPhase.MOVED);
			var end:Touch    = e.getTouch(Parameters.theStage, TouchPhase.ENDED);
			var location:Point;
			
			var boardCoordinates:Point;
			
			if(begin)
			{
				location = begin.getLocation(Parameters.theStage);
			}
			if(move)
			{
				location = move.getLocation(Parameters.theStage);
			}
			if(end)
			{
				location = end.getLocation(Parameters.theStage);
			}
			
			if(view != null)
			{
				if(location != null)
				{
					lastLoc = location;
					
					boardCoordinates = Parameters.mapHolder.globalToLocal(new Point(lastLoc.x, lastLoc.y));
					
					targetCol = (boardCoordinates.x / Parameters.tileSize)
					targetRow = (boardCoordinates.y / Parameters.tileSize)
					
					view.x =  (Parameters.tileSize * targetCol) ;
					view.y =  (Parameters.tileSize * targetRow) ;
					
					setCorrectColors(targetRow, targetCol);
					
				}
				
				if(end)
				{
					if (isValidPlacementArea)
					{
						MouseStates.currentState = MouseStates.REG_PLAY;
						Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
						view.removeFromParent(true );
						dispatchEvent(new Event(BUILDNG_SPOT_FOUND));
					}
					
					
				}
			}
			
			e.stopPropagation();
		}
		
		//this is for AI!!!
		public function getValidPlacement():void
		{
			var allBaseNodes:Array = SightManager.getInstance().getBaseNodes(teamObj.agent);
			var foundValidPlace:Boolean = false;
			var baseNodesLen:int = allBaseNodes.length;
			var count:int = 0;
			var used:Array = [];
			
			/*while (count < baseNodesLen)
			{
				var rnd:int = Math.random() * baseNodesLen;
				if (used.indexOf(rnd) == -1)
				{
					var n:Node = allBaseNodes[rnd];
					var isValidPlacementArea:Boolean = setCorrectColors(n.row, n.col);
					if (isValidPlacementArea)
					{
						targetCol = n.col;
						targetRow = n.row;
						foundValidPlace = true;
						if(view)view.removeFromParent(true );
						dispatchEvent(new Event(BUILDNG_SPOT_FOUND));
						break;
					}
					else
					{
						used.push(rnd);
						count++;
					}
				}
				
			}*/
			
			for (var i:int = 0; i < allBaseNodes.length; i++ )
			{
				var n:Node = allBaseNodes[i];
				var isValidPlacementArea:Boolean = setCorrectColors(n.row, n.col);
				if (isValidPlacementArea)
				{
					targetCol = n.col;
					targetRow = n.row;
					foundValidPlace = true;
					if(view)view.removeFromParent(true );
					dispatchEvent(new Event(BUILDNG_SPOT_FOUND));
					break;
				}
			}
			
			trace("foundValidPlace " + foundValidPlace + " " + used);
		}
		

		
		private function setCorrectColors(startRow:int, startCol:int):Boolean 
		{
			var valid:Boolean = true;
			
			for(var i:int = 0; i < tilesArr.length; i++)
			{
				for (var j:int = 0; j < tilesArr[i].length; j++ )
				{
					if (tilesArr[i][j] is Quad)
					{
						var q:Quad = tilesArr[i][j];
						if (Parameters.boardArr[startRow + i] && Parameters.boardArr[startRow + i][startCol + j])
						{
							var node:Node = Parameters.boardArr[startRow + i][startCol + j];
							if (isValidTile(node))
							{
								q.color = COLLOR_GREEN;
							}
							else
							{
								valid = false;
								q.color = COLLOR_RED;
								
							}
						}
						else
						{
							valid = false;
						}
					}
				}
			}
			isValidPlacementArea = valid;
			return isValidPlacementArea;
			
		}
		
		private function isValidTile(node:Node):Boolean
		{
			var valid:Boolean = true;
			
			if (node.cliffTile || node.shoreTile || node.occupyingUnit || node.walkable == false || nodeOutSideBase(node))
			{
				valid = false;
			}
			else
			{
				var n:Node;
			
				outer : for (var row:int = -1; row <= 1; row ++  )
				{
					for (var col:int = -1; col <= 1; col ++  )
					{
						if (Parameters.boardArr[node.row + row] && Parameters.boardArr[node.row + row][node.col + col])
						{
							n = Parameters.boardArr[node.row + row][node.col + col];
							if ( n.occupyingUnit )
							{
								valid = false;
								break outer;
							}
						}
					}
				}
			}
			
			return valid;
		}
		
		private function nodeOutSideBase(node:Node):Boolean 
		{
			var allBaseNodes:Array = SightManager.getInstance().getBaseNodes(teamObj.agent);
			if (allBaseNodes.indexOf(node) == -1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
	}

}