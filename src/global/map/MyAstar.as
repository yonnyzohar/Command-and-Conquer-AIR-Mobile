package global.map
{
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class MyAstar extends EventDispatcher
	{
		private var board:Array = [];
		private var endTile:Node;
		
		public var closedTiles:Array = [];
		private var openList:Array = [];
		
		private var startTile:Node;
		
		public static const PATH_FOUND:String = "PATH_FOUND";
		public static const PATH_ERROR:String = "PATH_ERROR";
		public var ready:Boolean = false;
		
		public function findPath(_startTile:Node, _endTile:Node, _board:Array ):void 
		{
			closedTiles.splice(0);
			openList.splice(0);
			
			startTile = _startTile;
			endTile = _endTile;
			board = _board;
			
			startTile.g = 0;
			startTile.h = heuristic(startTile, endTile);
			startTile.f = startTile.g + startTile.h;
			openList.push(startTile);
			
			getPath();
		}
		
		private function getPath():void 
		{
			var i:int = 0;
			
			
			var currentTile:Node = getLowestTileFromOpenList();
			closedTiles.push(currentTile);
			
			if ( currentTile == endTile ) 
			{
				closedTiles = createPath( startTile, endTile );
				dispatchEvent(new Event(PATH_FOUND));
			}
			else
			{
				var adjecantTiles:Array = findAdjecantTiles(currentTile);
				
				if(adjecantTiles == null) 
				{
					dispatchEvent(new Event(PATH_ERROR));
					return;
				}
				else
				{
					for (i = 0; i <  adjecantTiles.length; i++ )
					{
						var neighbor:Node = adjecantTiles[i];
						var g: Number = currentTile.g + getCost( currentTile, neighbor );
						
						if ( closedTiles.indexOf(neighbor) != -1 || openList.indexOf(neighbor) != -1 ) 
						{
							if ( neighbor.g > g ) 
							{
								neighbor.g = g;
								neighbor.f = neighbor.h + g;
								neighbor.parent = currentTile;
							}
						}
						else 
						{
							neighbor.g = g;
							neighbor.h = heuristic( neighbor, endTile );
							neighbor.f = neighbor.h + g;
							neighbor.parent = currentTile;
							openList.push(neighbor);
						}
						
						
					}
					//setTimeout(getPath, 50);
					getPath();
				}
				
				
			}
		}
		
		private function createPath(startNode:Node, endNode:Node):Array
		{
			var path:Array = [];
			var curNode : Node = endNode;
			path.push( endNode );
			
			while (curNode != startNode) 
			{
				curNode = curNode.parent;
				path.push(curNode);
			}
			path.reverse();
			return path;
		}
		
		private function getCost(curNode:Node, neighbor:Node):Number
		{
			var cost : Number = 1.0;
			if (( curNode.row != neighbor.row ) && ( curNode.col != neighbor.col ) ) 
			{
				cost = 1.414;
			}
			return cost;
		}
		
		private function getLowestTileFromOpenList():Node 
		{
			openList.sortOn("f", Array.NUMERIC);
			return openList.shift();
		}
		

		private function heuristic(node:Node, destinationNode:Node):Number 
		{
			return int(Math.abs(destinationNode.row - node.row) + Math.abs(destinationNode.col - node.col));
		}
		
		private function findAdjecantTiles(currentNode:Node):Array 
		{
			if(currentNode == null)return null;
			
			var relevantTiles:Array = [];
			var col:int = currentNode.row;
			var row:int = currentNode.col;
			var iteratedTile:Node;
			
			////trace"col: " + col  + " row: " + row);

			for (var i:int = - 1; i <= 1; i++ )
			{
				if (board[col + i])
				{
					for (var j:int = - 1; j <= 1; j++ )
					{
						if (board[col + i][row +  j])
						{
							iteratedTile = board[col + i][row +  j];
							
							if (notAWall(iteratedTile) )
							{
								relevantTiles.push(iteratedTile);
							}
						}
					}
				}
			}
			
			return relevantTiles;
		}
		
		private function notAWall(node:Node):Boolean
		{
			if (node.walkable == true )
			{
				return true;
			}
			else 
			{
				return false;
			}
		}
		
		public function dispose():void
		{
			board = null;
			endTile = null;
			closedTiles = null;
			openList = null;
			startTile = null;
		}
	}
}