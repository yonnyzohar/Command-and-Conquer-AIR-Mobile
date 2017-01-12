package global.map
{
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
			walkable = true;
			isResource = true;
			obstacleTile.currentFrame = (obstacleTile.numFrames-1);
			obstacleTile.touchable = false;
			obstacleTile.visible = true;
		}
		
		public function reduceResource(_harvestAmount:int):void
		{
			quantity -=_harvestAmount;
			var totalFrames:int = (obstacleTile.numFrames-1)
			if (quantity >= 0)
			{
				var decreased:int = totalQuantity - (totalQuantity - quantity);
				var decreasedPer:Number = decreased / totalQuantity;
				var frame:int  = totalFrames  * decreasedPer;

				////trace(frame)
				obstacleTile.currentFrame = int(frame );
			}
			else
			{
				obstacleTile.removeFromParent();
				isResource = false;
			}
		}
	}

}