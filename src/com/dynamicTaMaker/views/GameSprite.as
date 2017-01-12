package  com.dynamicTaMaker.views
{
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import flash.utils.getTimer;
	
	import starling.display.*;
	import starling.events.*;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureSmoothing;

	public dynamic class GameSprite extends StarlingView
	{
		//private var soundManager:SoundManager = SoundManager.getInstance();
		private var touchStartTime:Number;
		private var touchEndTime:Number;
		
		public function GameSprite() 
		{
			
		}

		public function setImageBlendModeToNone():void
		{
			//myImage.blendMode = BlendMode.NONE;
				
		}
		
		public function startCount():void
		{
			touchStartTime = 0;
			touchEndTime = 0;
			touchStartTime = getTimer();
			
		}
		
		public function userTapped():Boolean
		{
			touchEndTime = getTimer();
			var duration:Number = (touchEndTime - touchStartTime)
			//trace"duration " + duration);
			if(duration < 200)
			{
				return true
			}
			else
			{
				return false
			}
		}

	}

}