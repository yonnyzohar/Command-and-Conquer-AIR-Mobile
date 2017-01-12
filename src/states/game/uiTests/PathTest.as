package states.game.uiTests
{
	import global.Parameters;
	
	import starling.display.Quad;

	public class PathTest
	{
		public static var showPath:Boolean = false;
		private static var arr:Array = [];
		
		public static function createSelectedPath(path:Array):void
		{
			var i:int = 0;
			
			for(i = 0; i < arr.length; i++)
			{
				arr[i].removeFromParent(true);
			}
			
			arr.splice(0);
			
			for(i = 0; i < path.length; i++)
			{
				var q:Quad = new Quad(Parameters.tileSize, Parameters.tileSize, 0x000000);
				Parameters.upperTilesLayer.addChild(q);
				q.x = Parameters.tileSize * path[i].col;
				q.y = Parameters.tileSize * path[i].row;
				q.alpha = 0.5;
				arr.push(q);
			}
		}
	}
}