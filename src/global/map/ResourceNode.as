package global.map
{
	import global.utilities.GameTimer;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class ResourceNode extends Node
	{
		public var totalQuantity:int = 300;
		public var quantity:int;
		
		public function ResourceNode() 
		{
			quantity = totalQuantity;
		}
		
		public function initResource(resourceTextures:Vector.<Texture>, textureFrame:int):void
		{
			obstacleTile = new MovieClip( resourceTextures);
			obstacleTile.stop();
			walkable = true;
			isResource = true;
			obstacleTile.currentFrame = (obstacleTile.numFrames-1);
			obstacleTile.touchable = false;
			obstacleTile.visible = true;
			GameTimer.getInstance().addUser(this);
		}
		
		public function update(_pulse:Boolean):void
		{
			if (_pulse && (Math.random() < 0.5))
			{
				if (quantity < totalQuantity)
				{
					reduceResource(-1);
				}
			}
		}
		
		public function setLowerStartPoint(_reduce:int):void
		{
			var totalFrames:int = (obstacleTile.numFrames - 1) ;
			var newFrame:int = totalFrames - _reduce;
			if (newFrame < 0)
			{
				newFrame = 0;
			}
			
			var per:Number = newFrame / totalFrames;
			quantity = totalQuantity * per;
			obstacleTile.currentFrame = int(newFrame );
		}
		
		public function reduceResource(_harvestAmount:int):void
		{
			if(!obstacleTile)
			{
				return;
			}
			quantity -=_harvestAmount;
			var totalFrames:int = (obstacleTile.numFrames-1)
			if (quantity > 0)
			{
				if (quantity <= totalQuantity)
				{
					var decreased:int = totalQuantity - (totalQuantity - quantity);
					var decreasedPer:Number = decreased / totalQuantity;
					var frame:int  = totalFrames  * decreasedPer;
					isResource = true;
					//////trace(frame)
					obstacleTile.currentFrame = int(frame );
					if (obstacleTile.alpha == 0)
					{
						obstacleTile.alpha = 1;
					}
				}
			}
			else
			{
				quantity = 0;
				obstacleTile.alpha = 0;
				isResource = false;
			}
		}
		override public function dispose():void 
		{
			GameTimer.getInstance().removeUser(this);
			super.dispose();
		}
	}

}