package states.game.uiTests
{
	
	import global.map.mapTypes.Board;
	import global.Parameters;
	
	import starling.display.Quad;

	public class PlacementTest
	{
		public static var showPlacement:Boolean = true;
		private static var list:Array = new Array();

		public static function createPlacement(row:int, col:int):void
		{
			var found:Boolean = false;
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].row == row && list[i].col == col)
				{
					found = true;
					break;
				}
			}
			
			if(found)
			{
				return;	
			}
			var q:Quad = new Quad(Parameters.tileSize, Parameters.tileSize, 0xffff00);
			Board.mapContainerArr[Board.GROUND_LAYER].addChild(q);
			q.x = Parameters.tileSize * col;
			q.y = Parameters.tileSize * row;
			q.alpha = 0.2;
			list.push({row: row, col: col, q: q});
		}
		
		public static function removePlacement(row:int, col:int):void
		{
			var found:Boolean = false;
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].row == row && list[i].col == col)
				{
					found = true;
					break;
				}
			}
			
			if(found)
			{
				list[i].q.removeFromParent(true);
				list.splice(i, 1);
			}
		}
	}
}