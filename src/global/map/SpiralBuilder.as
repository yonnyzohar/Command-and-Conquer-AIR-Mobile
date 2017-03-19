package global.map
{
	import flash.geom.Point;
	
	import global.Parameters;

	public class SpiralBuilder
	{
		private static var currentI:int = 0;
		private static var dir:String = "top";
		private static var squadSize:int;
		private static var tiles:Array = [];
		private static var row:int;
		private static var col:int;
		
		public function SpiralBuilder()
		{
			
		}
		
		public static function getSpiral(_row:int, _col:int, _suadSize:int):Array
		{
			row = _row;
			col = _col;
			squadSize = _suadSize;
			currentI = 0;
			dir = "top";
			tiles.splice(0);
			var i:int = 0;
			var pointExists:Boolean;
			
			outer : while(tiles.length < squadSize)
			{
				//moveUp(row, col);
				currentI++;
				for(i = 0; i <= currentI; i++)
				{
					if(validTile(row - i, col))
					{
						
						pointExists = checkPoint(row - i, col);
						
						if(!pointExists)
						{
							////trace"pushing up");
							tiles.push({"row": row - i, "col" : col});
							if (tiles.length >= squadSize)
							{
								break outer;
							}
						}
					}
					
				}
				row = row - currentI;
				
				//right
				for(i = 1; i <= currentI; i++)
				{
					if(validTile(row, col + i))
					{
						pointExists = checkPoint(row, col + i);
						
						if(!pointExists)
						{
							tiles.push({"row" : row, "col" : col + i});
							if (tiles.length >= squadSize)
							{
								break outer;
							}
						}
					}				
				}
				col = col + currentI;
				
				//down
				currentI++;
				
				for(i = 1; i <= currentI; i++)
				{
					if(validTile(row + i, col))
					{
						pointExists = checkPoint(row + i, col);
						
						if(!pointExists)
						{
							//trace"pushing down");
							tiles.push({"row" : row + i, "col" : col});
							if (tiles.length >= squadSize)
							{
								break outer;
							}
						}
					}				
				}
				
				row = row + currentI;
				
				//left
				for(i = 1; i <= currentI; i++)
				{
					if(validTile(row, col - i))
					{
						pointExists = checkPoint(row, col - i);
						
						if(!pointExists)
						{
							//trace"pushing left");
							tiles.push({"row" : row,  "col" : col - i});
							if (tiles.length >= squadSize)
							{
								break outer;
							}
						}
					}				
				}
				col = col - currentI;
				
			}
			
			return tiles;
		}
		
		private static function checkPoint(row:int, col:int):Boolean
		{
			var pointExists:Boolean = false;
			var l:int = tiles.length;
			for(var i:int = 0; i < l; i++)
			{
				if(tiles[i].row == row && tiles[i].col == col)
				{
					pointExists = true;
					break;
				}
			}
			return pointExists;
		}
		
				
		private static function validTile(row:int, col:int):Boolean
		{
			if (Parameters.boardArr[row] == undefined)return false;
			if (Parameters.boardArr[row] == null)return false;
			if (Parameters.boardArr[row][col] == undefined)return false;
			if (Parameters.boardArr[row][col] == null)return false;
			if (Parameters.boardArr[row][col].walkable == false) return false;
			if (Parameters.boardArr[row][col].occupyingUnit != null)return false;
			return true;
		}
	}
}