package global.ui.hud
{
	import flash.geom.Point;
	import global.enums.Agent;
	import global.enums.MouseStates;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.Methods;
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
	import states.game.entities.buildings.Building;
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
		static public const FORBID_PADDING:Boolean = true;
		
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
			
			var len:int = occupyArray.length;
			var len1:int = 0;
			for(var i:int = 0; i < len; i++)
			{
				tilesArr[i] = [];
				len1 = occupyArray[i].length;
				for (var j:int = 0; j < len1; j++ )
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
			
			if (teamObj.agent == Agent.HUMAN && Parameters.AI_ONLY_GAME == false)
			{
				Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(view);
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
			var allBaseNodes:Object = teamObj.getBaseNodes();
			var foundValidPlace:Boolean = false;
			var count:int = 0;
			var used:Array = [];

			
			for (var k:String in  allBaseNodes )
			{
				var n:Node = allBaseNodes[k];
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
			
			if (!foundValidPlace)
			{
				//Parameters.loadingScreen.displayMessage("HOLY SHIT!!! " + allBaseNodes.length);
				throw new Error("HOLY SHIT!!!");
			}
			
			//trace("foundValidPlace " + foundValidPlace + " " + used);
		}
		
		//this is for AI!!!
		public function getValidPlacementClosestToEnemy():void
		{
			var randomEnemyBuildingNode:Node = getRandomEneyBuilding();
			var allBaseNodes:Object = teamObj.getBaseNodes();
			var foundValidPlace:Boolean = false;
			var count:int = 0;
			var used:Array = [];
			var shortestDist:int = 100000;
			var closestTile:Node;
			
			for (var k:String in  allBaseNodes )
			{
				var n:Node = allBaseNodes[k];
				var isValidPlacementArea:Boolean = setCorrectColors(n.row, n.col);
				if (isValidPlacementArea)
				{
					var dist:int = Methods.distanceTwoPoints(n.col, randomEnemyBuildingNode.col, n.row, randomEnemyBuildingNode.row);
				
					if (dist < shortestDist)
					{
						shortestDist = dist;
						closestTile = n;
					}
				}
			}
			
			targetCol = closestTile.col;
			targetRow = closestTile.row;
			foundValidPlace = true;
			if(view)view.removeFromParent(true );
			dispatchEvent(new Event(BUILDNG_SPOT_FOUND));

		}
		
		
		private function nodeOutSideBase(node:Node):Boolean 
		{
			var allBaseNodes:Object = teamObj.getBaseNodes();
			if (allBaseNodes[node.name])
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		private function getRandomEneyBuilding():Node 
		{
			var b:Building;
			var n:Node = Parameters.boardArr[0][0];
			
			for (var i:int = 0; i < teamObj.enemyTeam.length; i++ )
			{
				if (teamObj.enemyTeam[i] is Building)
				{
					b = teamObj.enemyTeam[i];
					if (b && b.model && b.model.dead == false)
					{
						break;
					}
					else
					{
						b = null;
					}
				}
			}
			
			if (b)
			{
				n = Parameters.boardArr[b.model.row][b.model.col];
			}
			
			return n;
		}
		
		
		

		
		private function setCorrectColors(startRow:int, startCol:int):Boolean 
		{
			var valid:Boolean = true;
			var len:int = tilesArr.length;
			var len1:int = 0;
			
			for(var i:int = 0; i < len; i++)
			{
				len1 = tilesArr[i].length;
				for (var j:int = 0; j < len1; j++ )
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
			var isOutsideBase:Boolean = nodeOutSideBase(node)
			
			if (node.isResource || node.cliffTile || node.shoreTile || node.occupyingUnit || node.walkable == false || isOutsideBase)
			{
				valid = false;
			}
			else
			{
				if (FORBID_PADDING)
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
				
				
			}
			
			return valid;
		}
		
		
		
		
		public function dispose():void 
		{
			if (view) view.removeFromParent();
			teamObj = null;
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
	}

}