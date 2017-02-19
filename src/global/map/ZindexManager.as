package global.map
{
	import global.Parameters;
	import states.game.entities.GameEntity;

	public class ZindexManager
	{
		public static function setIndices(allUnits:Array):void
		{

			
			allUnits.sortOn(["row"], Array.NUMERIC);
			
			
			var l:int = allUnits.length;
			
			for(var i:int = 0; i < allUnits.length; i++)
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
							Parameters.mapHolder.addChild(ent.view);
						}
					}
					
					
				}
				else
				{
					if(allUnits[i].view.parent)Parameters.mapHolder.addChild(allUnits[i].view);
				}
			}
			
		}
	}
}