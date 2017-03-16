package global.pools
{
	import global.GameAtlas;
	
	public class PoolsManager
	{
		public static var selectorCirclesPool:Pool;
		
		
		public static function init():void
		{
			if (selectorCirclesPool == null)
			{
				selectorCirclesPool = new Pool(PoolElement, GameAtlas.getTextures("selectorCircle") );
			}
			
			
					   
  		}
  	}    
}        