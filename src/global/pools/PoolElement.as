package global.pools
{
	import global.GameAtlas;
	import global.Methods;
	import global.Parameters;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import starling.textures.Texture;

	public class PoolElement extends MovieClip
	{
		protected var degrees:int;
		public var inUse:Boolean = false;
		protected var endFrame:int;
		protected var pixelOffsetX:Number;
		protected var pixelOffsetY:Number;
		private var dir:String;
		private var texturesDict:Object = { };
		
		public function PoolElement(tex:Vector.<Texture>, _pixelOffsetX:Number, _pixelOffsetY:Number )
		{
			pixelOffsetX = _pixelOffsetX;
			pixelOffsetY = _pixelOffsetY;
			super(tex);
			//blendMode = BlendMode.NONE;
		}
		//this is for moving projectiles that need a frame facing the right direction
		public function setDirection32(startX:int, startY:int, destX:int, destY:int):void
		{
			degrees = Math.atan2( startY -  destY,  startX - destX) / Math.PI * 180;
			
			while ( degrees >= 360 )
			{
				degrees -= 360;
			}
			while ( degrees < 0 )
			{
				degrees += 360;
			}
			
			degrees = Math.ceil(degrees);
			endFrame = Methods.degreesToFrame(degrees, 0);
			//taking this out of the if statement solved the animation bug...
			
			////trace("shooting at " + degrees + " degrees, frame " + endFrame)
			
			if (endFrame <= numFrames)
			{
				this.currentFrame = endFrame;
				////trace("set at " + this.currentFrame)
			}
			
		}
		
		//this is for static projectiles that need to play an animaton in place facing the right dir
		public function setDirection8(curRow:int, curCol:int, destRow:int, destCol:int, _assetName:String):void
		{
			if(curRow == destRow && curCol == destCol)return;
			
			dir = "";
			
			var firstDir:String = "";
			var secondDir:String = "";
			
			
			var degrees:int = Math.atan2( curRow -  destRow,  curCol - destCol) / Math.PI * 180;
			
			while ( degrees >= 360 )
			{
				degrees -= 360;
			}
			while ( degrees < 0 )
			{
				degrees += 360;
			}
			
			degrees = Math.ceil(degrees);
			
			if(degrees >= 66 && degrees < 112)
			{
				firstDir = "_north";
			}
			if(degrees >= 22 && degrees < 66)
			{
				firstDir = "_north";
				secondDir = "_west";
			}
			
			if(degrees >= 0 && degrees < 22)
			{
				secondDir = "_west";
			}
			
			if(degrees >= 337 && degrees <= 359)
			{
				secondDir = "_west";
			}
			if(degrees >= 292 && degrees < 337)
			{
				firstDir = "_south";
				secondDir = "_west";
			}
			if(degrees >= 247 && degrees < 292)
			{
				firstDir = "_south";
			}
			if(degrees >= 202 && degrees < 247)
			{
				firstDir = "_south";
				secondDir = "_east";
			}
			if(degrees >= 157 && degrees < 202)
			{
				secondDir = "_east";
			}
			
			if(degrees >= 112 && degrees < 157)
			{
				firstDir = "_north";
				secondDir = "_east";
			}
			
			//this is totally wrong!
			/*if(degrees >= 0 && degrees < 22)
			{
				firstDir = "_north";
			}
			if(degrees >= 22 && degrees < 66)
			{
				firstDir = "_north";
				secondDir = "_west";
			}
			if(degrees >= 66 && degrees < 112)
			{
				
				secondDir = "_west";
			}
			if(degrees >= 112 && degrees < 157)
			{
				firstDir = "_south";
				secondDir = "_west";
			}
			if(degrees >= 157 && degrees < 202)
			{
				
				firstDir = "_south";
			}
			if(degrees >= 202 && degrees < 247)
			{
				firstDir = "_south";
				secondDir = "_east";
			}
			if(degrees >= 247 && degrees < 292)
			{
				secondDir = "_east";
			}
			
			if(degrees >= 292 && degrees < 337)
			{
				firstDir = "_north";
				secondDir = "_east";
			}
			if(degrees >= 337 && degrees < 359)
			{
				secondDir = "_west";
			}*/
			
			
			
			if(secondDir != "")
			{
				firstDir = firstDir.toUpperCase();
			}
			
			dir =  firstDir + "" + secondDir;
			
			//trace(_assetName + ": " + dir + " / " + "curRow " + curRow + " curCol " + curCol + " destRow " + destRow + " destCol " + destCol)
			
			animatelayer(_assetName);
			
		}
		
		private var frameName:String;
		private var lastFrame:String;
		
		private function animatelayer(_assetName:String):void
		{
			frameName = _assetName + "" + dir;

			
			if(lastFrame != frameName)
			{
				swapMCTextures(frameName);
			}
			
			currentFrame = 0;
			loop = false;
			play();
			lastFrame = frameName;
		}
		
		private function swapMCTextures(frameName:String):void
		{
			while(numFrames > 1)
			{
				removeFrameAt(0);
			}
			
			if (!texturesDict[frameName])
			{
				texturesDict[frameName] = GameAtlas.getTextures(frameName);
			}

			
			for each (var texture:SubTexture in texturesDict[frameName])
			{
				addFrame(texture);
			}
			
			removeFrameAt(0);
		}
		
		
		
		public function returnMe():void 
		{
			this.currentFrame = 0;
			removeFromParent();
			inUse = false;
		}
	}
}