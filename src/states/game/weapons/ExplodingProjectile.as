package states.game.weapons
{
	import global.map.mapTypes.Board;
	import global.Parameters;
	import global.GameAtlas;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.Texture;

	public class ExplodingProjectile extends Projectile
	{
		private var explosionMC:MovieClip;
		private static var expArr:Array = ["smallExplosion1", "smallExplosion2"];
		
		public function ExplodingProjectile(tex:Vector.<Texture>, _isMovieClip:Boolean) 
		{
			var rnd:int = Math.random() * expArr.length;
			explosionMC = GameAtlas.createMovieClip(expArr[rnd]);
			explosionMC.scaleY = explosionMC.scaleX = Parameters.gameScale;
			explosionMC.loop = false;
			explosionMC.stop();
			super(tex, _isMovieClip);
		}
		
		override protected function doneShot():void 
		{
			Board.mapContainerArr[Board.UNITS_LAYER].addChild(explosionMC);
			explosionMC.x = targetX;
			explosionMC.x -= explosionMC.width / 2;
			explosionMC.y = targetY;
			explosionMC.y -= explosionMC.height;
			explosionMC.currentFrame = 1;
			explosionMC.addEventListener(Event.COMPLETE, explosionDone);
			explosionMC.play();
			Starling.juggler.add(explosionMC);
			super.doneShot();
		}
		
		private function explosionDone(e:Event):void
		{
			explosionMC.removeEventListener(Event.COMPLETE, explosionDone);
			explosionMC.removeFromParent();
			Starling.juggler.remove(explosionMC);
		}
	}
}