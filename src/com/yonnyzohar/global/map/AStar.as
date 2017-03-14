package com.yonnyzohar.global.map
{
	import com.yonnyzohar.global.Parameters;

	public class AStar
	{
		private var path : Array;
		private var closedList : Array;
		private var openList : Array;
		public var visitedList : Array;
		private var selectedUnitID:int;
		
		public function AStar() 
		{
			path = [];
			visitedList = [];
		}
		
		public function getPath( startNode : Node, endNode : Node , _selectedUnitID:int) : Array 
		{
			selectedUnitID = _selectedUnitID;
			
			if ( Node(endNode).walkable == false || Node(endNode).occupyingUnit != null  ) 
			{
				var placementsArr:Array = SpiralBuilder.getSpiral(endNode.row, endNode.col, 1);
				endNode = Parameters.boardArr[placementsArr[0].row][placementsArr[0].col];
			}
			
			openList = [];
			closedList = [];
			startNode.g = 0;
			startNode.h = int(Math.abs(endNode.row - startNode.row) + Math.abs(endNode.col - startNode.col));//estimateDistance(startNode, endNode);
			startNode.f = startNode.g + startNode.h;
			openList.push(startNode);
			
			while ( openList.length > 0 ) 
			{
				
				openList.sortOn(["f"], [Array.NUMERIC]);
				var curNode:Node = openList.shift();
				
				closedList.push(curNode);
				
				if ( curNode == endNode ) 
				{
					return createPath( startNode, endNode );
				}
				else 
				{
					for each ( var neighbor : Node in getNeighbors( Parameters.boardArr, curNode ) ) 
					{
						visitedList.push(neighbor);
						
						var g: Number = curNode.g + getCost( curNode, neighbor );
						
						if ( closedList.indexOf(neighbor) >= 0 || openList.indexOf(neighbor) >= 0 ) 
						{
							if ( neighbor.g > g ) 
							{
								 neighbor.g = g;
								 neighbor.f = neighbor.h + g;
								 neighbor.parent = curNode;
							}
						}
						else 
						{
							neighbor.g = g;
							neighbor.h = int(Math.abs(endNode.row - neighbor.row) + Math.abs(endNode.col - neighbor.col));//estimateDistance( neighbor, endNode );
							neighbor.f = neighbor.h + g;
							neighbor.parent = curNode;
							openList.push(neighbor);
						}
					}
				}
			}
			path = [];
			return path;
		}
		
		private function createPath(startNode:Node, endNode:Node):Array
		{
			path = [];
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
		
		
		
		private function getNeighbors(grid:Array, curNode:Node):Array
		{
			var neighbors : Array = [];
			var startRow : uint = Math.max( 0, curNode.row - 1 );
			var startCol : uint = Math.max( 0, curNode.col - 1 );
			var endRow : uint = Math.min( Parameters.numRows - 1, curNode.row + 1 );
			var endCol : uint = Math.min( Parameters.numCols - 1, curNode.col + 1 );
			var neighbor:Node;
			
			for ( var r : uint = startRow; r <= endRow; r++ ) 
			{
				for ( var c : uint = startCol; c <= endCol; c++ ) 
				{
					neighbor = Parameters.boardArr[r][c];
					if ( neighbor.walkable == true && neighbor.regionNum == curNode.regionNum && neighbor.occupyingUnit == null  ) 
					{
						neighbors.push( neighbor );
					}
				}
			}
			return neighbors;
		}
		
		private function estimateDistance(curNode:Node, endNode:Node):Number
		{
			return int(Math.abs(endNode.row - curNode.row) + Math.abs(endNode.col - curNode.col));
			
			/*var distX : uint = Math.abs( curNode.col - endNode.col );
			var distY : uint = Math.abs( curNode.row - endNode.row );
			
			var numDiagSteps : uint = Math.min( distX, distY );
			
			var numStraightSteps : uint = distX + distY - ( numDiagSteps << 1 );
			var diagLength : Number = 1.414 * numDiagSteps;
			return diagLength + numStraightSteps;*/
		}
		
		private function removeSmallest(array:Array):Node
		{
			array.sortOn(["f"], [Array.NUMERIC]);
			return array.shift();
		}
		
	}

}