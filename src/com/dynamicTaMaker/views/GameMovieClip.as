package  com.dynamicTaMaker.views
{
	import starling.display.*;
	import starling.textures.TextureAtlas;
	import starling.events.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;

	public class GameMovieClip extends GameSprite
	{
		protected var myMC:MovieClip;
		
		
		public function GameMovieClip() 
		{
			
		}
	
		
		
		public function killMe():void
		{
			super.killMe();
			removeFromParent(true);
		}
		
	}

}