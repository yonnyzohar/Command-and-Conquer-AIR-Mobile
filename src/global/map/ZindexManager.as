package global.map
{
	import global.Parameters;
	import states.game.entities.GameEntity;

	public class ZindexManager
	{
		public static function setIndices(allUnits:Array):void
		{
			/*var i:int = 0;
			var len:int = 0;
			for (i = 0; i < arrays.length; i++)
			{
				len += arrays[i].length;
			}
			
			if (len != allUnits.length)
			{
				allUnits.splice(0);
			
				for(i=0;i<arrays.length;i++)
				{
					allUnits = allUnits.concat(arrays[i]);
				}
			}*/

			
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
							trace(ent.row)
							Parameters.mapHolder.addChild(ent.view);
						}
					}
					
					
				}
				else
				{
					if(allUnits[i].view.parent)Parameters.mapHolder.addChild(allUnits[i].view);
				}
			}
			
			trace("==")
			
			
		}
	}
}