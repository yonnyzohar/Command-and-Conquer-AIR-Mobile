package global.pools
{
	import global.GameAtlas;
	import states.game.weapons.ExplodingProjectile;
	import states.game.weapons.FireTrail;
	
	public class PoolsManager
	{
		public static var selectorCirclesPool:Pool;
		/*public static var rocketsPool:Pool;
		public static var fireTrailPool:Pool;
		public static var shellsPool:Pool;
		public static var bulletsPool:Pool;
		public static var gunPool:Pool;
		public static var bigExplosion1:Pool;
		public static var bigExplosion2:Pool;
		public static var bigExplosion3:Pool;
		public static var bigExplosion4:Pool;
		public static var bigExplosion5:Pool;
		
		public static var smallExplosion1:Pool;
		public static var smallExplosion2:Pool;
		
		public static var bigExplosionsArr:Array;
		public static var smallExplosionsArr:Array;*/
		
		public static function init():void
		{
			if (selectorCirclesPool == null)
			{
				selectorCirclesPool = new Pool(PoolElement, GameAtlas.getTextures("selectorCircle") );
			}
			
			/*
			rocketsPool = new Pool("rocket", Rocket);
			fireTrailPool = new Pool("trail", FireTrail);
			shellsPool = new Pool("rocket", ExplodingProjectile);
			bulletsPool = new Pool("rocket", Projectile);
			gunPool = new Pool("piffPiff" , Bullets, true);*/
			
			//explosions
			/*bigExplosion1 = new Pool("bigExplosion1", PoolElement, true);
			bigExplosion2 = new Pool("bigExplosion2", PoolElement, true);
			bigExplosion3 = new Pool("bigExplosion3", PoolElement, true);
			bigExplosion4 = new Pool("bigExplosion4", PoolElement, true);
			bigExplosion5 = new Pool("bigExplosion5", PoolElement, true);
			
			smallExplosion1 = new Pool("smallExplosion1", PoolElement, true);
			smallExplosion2 = new Pool("smallExplosion2", PoolElement, true);
			
			bigExplosionsArr = [bigExplosion1,
                       bigExplosion3,
                       bigExplosion4,
                       bigExplosion5];
					   
			smallExplosionsArr = [smallExplosion1,smallExplosion2];*/
					   
  		}
  	}    
}        