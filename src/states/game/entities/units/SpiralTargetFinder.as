package states.game.entities.units
{
	import global.map.Node;
	import global.Parameters;
	import states.game.entities.GameEntity;
	
	public class SpiralTargetFinder
	{
	
		private static var currentI:int = 0;
		private static var dir:String = "top";
		private static var tileFound:Boolean = false;
		private static var myTeam:int = 0;
		private static var foundEnemy:GameEntity;
		
		private static function isValidEnemy(e:GameEntity):Boolean
		{
			if (e == null)return false;
			if ( e.model == null ) return false;
			if (e.model.dead) return false;
			if (e.teamNum == myTeam) return false;
			if (e == null) return false;
			if (e == null)return false;
			return true;
		}
		
		public static function startSpiral(row:int, col:int, _range:int, _myTeam:int):GameEntity
		{
			myTeam = _myTeam;
			foundEnemy = null;
			tileFound = false;
			currentI = 0;
			dir = "top";
			
			moveUp(row, col, _range);
			
			return foundEnemy;
		}
		
		private static function moveUp(row:int, col:int, _range:int):void
		{
			var i:int = 0;
			dir = "top";
			currentI++;
			var e:GameEntity;
			
			for (i = 0; i <= currentI; i++)
			{
				if (validTile(row - i, col))
				{
					e = GameEntity( Node(Parameters.boardArr[row - i][col] ).occupyingUnit);
					
					if (isValidEnemy(e))
					{
						foundEnemy = e;
						tileFound = true;
						break;
					}
				}
			}
			
			if (!tileFound )
			{
				if (currentI < _range)
				{
					row = row - currentI;
					moveRight(row, col, _range);
				}
			}

		}
		
		private static function moveRight(row:int, col:int, _range:int):void
		{
			//go right 1
			dir = "right";
			var i:int = 0;
			var e:GameEntity;
			
			for (i = 0; i <= currentI; i++)
			{
				if (validTile(row, col + i))
				{
					e = GameEntity( Node(Parameters.boardArr[row][col + 1] ).occupyingUnit);
					
					if (isValidEnemy(e))
					{
						foundEnemy = e;
						tileFound = true;
						break;
					}
				}
			}
			
			if (!tileFound )
			{
				if (currentI < _range)
				{
					col = col + currentI;
					moveDown(row, col, _range);
				}
			}

		}
		
		private static function moveDown(row:int, col:int, _range:int):void
		{
			
			dir = "down";
			var i:int = 0;
			currentI++;
			var e:GameEntity;
			
			for (i = 0; i <= currentI; i++)
			{
				if (validTile(row + i, col))
				{
					e = GameEntity( Node(Parameters.boardArr[row + i][col] ).occupyingUnit);
					
					if (isValidEnemy(e))
					{
						foundEnemy = e;
						tileFound = true;
						break;
					}
				}
			}
			
			
			if (!tileFound )
			{
				if (currentI < _range)
				{
					row = row + currentI;
					moveLeft(row, col, _range);
				}
			}

		}
		
		private static function moveLeft(row:int, col:int, _range:int):void
		{
			
			dir = "left";
			var i:int = 0;
			var e:GameEntity;
			
			for (i = 0; i <= currentI; i++)
			{
				if (validTile(row, col - i))
				{
					e = GameEntity( Node(Parameters.boardArr[row][col - i] ).occupyingUnit);
					
					if (isValidEnemy(e))
					{
						foundEnemy = e;
						tileFound = true;
						break;
					}
				}
			}
			
			
			if (!tileFound )
			{
				if (currentI < _range)
				{
					col = col - currentI;
					moveUp(row, col, _range);
				}
			}
		}
		
		private static function validTile(row:int, col:int):Boolean
		{
			if (Parameters.boardArr[row] == undefined)
				return false;
			if (Parameters.boardArr[row] == null)
				return false;
			if (Parameters.boardArr[row][col] == undefined)
				return false;
			if (Parameters.boardArr[row][col] == null)
				return false;
			
			return true;
		
		}
	
	}

}

