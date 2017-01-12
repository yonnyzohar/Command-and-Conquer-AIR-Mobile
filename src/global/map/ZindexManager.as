package global.map
{
	import global.Parameters;
	import states.game.entities.GameEntity;

	public class ZindexManager
	{
		private static var allUnits:Array = [];
		
		public static function setIndices(arrays:Array):void
		{
			var i:int = 0;
			var len:int = 0;
			for (i = 0; i < arrays.length; i++)
			{
				len += arrays[i].length;
			}
			
			if (len != allUnits.length)
			{
				//trace"new z index array")
				allUnits.splice(0);
			
				for(i=0;i<arrays.length;i++)
				{
					allUnits = allUnits.concat(arrays[i]);
				}
			}

			try 
			{
				//var hudTiles:int = HUDView.hudWidth / Parameters.tileSize;
				
				allUnits.sortOn(["row"], Array.NUMERIC);
			
				for(i = 0; i < allUnits.length; i++)
				{
					if (allUnits[i] is GameEntity)
					{
						var ent:GameEntity = GameEntity(allUnits[i]);
						
						if (ent.model.col >= Parameters.screenDisplayArea.col && 
							ent.model.col < Parameters.screenDisplayArea.col + Parameters.screenDisplayArea.width &&
							ent.model.row >= Parameters.screenDisplayArea.row &&
							ent.model.row < Parameters.screenDisplayArea.row + Parameters.screenDisplayArea.height	)
						{
							Parameters.mapHolder.addChild(allUnits[i].view);
						}
					}
					else
					{
						if(allUnits[i].view.parent)Parameters.mapHolder.addChild(allUnits[i].view);
					}
				}
			}catch (e:Error)
			{
				
			}
			
		}
	}
}