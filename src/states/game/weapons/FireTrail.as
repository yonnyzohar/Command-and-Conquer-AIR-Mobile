package states.game.weapons
{
	import com.greensock.TweenLite;
	import global.Parameters;
	
	import global.pools.PoolElement;
	
	import starling.textures.Texture;

	public class FireTrail extends PoolElement
	{
		public function FireTrail(tex:Vector.<Texture>, _isMovieClip:Boolean) 
		{
			super(tex, _isMovieClip);
			this.scaleX = this.scaleY = Parameters.gameScale;
			this.pivotX = this.width *  (0.5/Parameters.gameScale);
			this.pivotY = this.height *  (0.5/Parameters.gameScale);
		}
		
		public function init():void
		{
			TweenLite.to(this, 0.5, {alpha:0, scaleX:1.1 * Parameters.gameScale, scaleY:1.1 * Parameters.gameScale, onComplete:returnMe})
		}
		

	}
}