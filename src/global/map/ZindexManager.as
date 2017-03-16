package global.map
{
	import global.map.mapTypes.Board;
	import global.Parameters;
	import states.game.entities.GameEntity;

	public class ZindexManager
	{
		public static function setIndices(allUnits:Array):void
		{

			
			allUnits.sortOn(["row"], Array.NUMERIC);
			
			
			var l:int = allUnits.length;
			
			for(var i:int = 0; i < l; i++)
			{
				if (allUnits[i] is GameEntity)
				{
					
					var ent:GameEntity = GameEntity(allUnits[i]);
					if (ent && ent.model && ent.model.dead == false)
					{
						if (ent.model.col >= Parameters.screenDisplayArea.col && 
						ent.model.col < Parameters.screenDisplayArea.col + Parameters.screenDisplayArea.width &&
						ent.model.row >= Parameters.screenDisplayArea.row &&
						ent.model.row < Parameters.screenDisplayArea.row + Parameters.screenDisplayArea.height	)
						{
							Board.mapContainerArr[Board.UNITS_LAYER].addChild(ent.view);
						}
					}
					
					
				}
				else
				{
					if (allUnits[i].view.parent)
					{
						Board.mapContainerArr[Board.OBSTACLE_LAYER].addChild(allUnits[i].view);
					}
				}
			}
			
		}
	}
}