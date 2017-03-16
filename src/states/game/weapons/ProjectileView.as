package states.game.weapons
{
	import global.Parameters;
	import global.pools.PoolElement;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	
	public class ProjectileView extends PoolElement
	{
		private var textures:Vector.<Texture>;
		
		
		
		public function ProjectileView(tex:Vector.<Texture>, pixelOffsetX:Number, pixelOffsetY:Number) 
		{
			textures = tex;
			super(tex, pixelOffsetX, pixelOffsetY);
			touchable = false;
			scaleX = scaleY = Parameters.gameScale;
			
		}
		
		
		
		public function addTrail(_x:int, _y:int):void 
		{
			
		}
		
		
		
		
	}

}