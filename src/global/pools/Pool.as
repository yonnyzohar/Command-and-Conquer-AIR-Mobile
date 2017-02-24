package global.pools
{
	
	import global.GameAtlas;
	import global.Parameters;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	

	public class Pool
	{
		private var pool:Array = [];
		private var assetImg:String;
		private var CLS:Class;
		private var textures:Vector.<Texture>;
		private var offsetX:int = 0;
		private var offsetY:int = 0;
		
		public function Pool(_CLS:Class, _textures:Vector.<Texture>, _offsetX:int = 0, _offsetY:int = 0)
		{
			offsetX = _offsetX;
			offsetY = _offsetY;
			CLS = _CLS;
			textures = _textures;
			var b:PoolElement = new CLS(textures, offsetX, offsetY);
			b.inUse = false;
			pool.push(b);
		}
		
		
		public function getAsset():PoolElement
		{
			var b:PoolElement = null;
			var found:Boolean = false;
			var poolLen:int = pool.length;
			for (var i:int = 0; i < poolLen; i++ )
			{
				b = pool[i];
				
				if (CLS(pool[i]).inUse == false)
				{
					b = pool[i];
					b.inUse = true;
					found = true;
					break;
				}
			}
			
			if (!found)
			{
				b = new CLS(textures, offsetX, offsetY);
				b.inUse = true;
				pool.push(b);
			}
			
			b.x = 0;
			b.y = 0;
			b.visible = true;
			b.alpha = 1;
			b.scaleX = b.scaleY = Parameters.gameScale;
			b.rotation = 0;
			return b;
		}
		
		public function returnAsset(b:PoolElement):void
		{
			b.inUse = false;
			b.removeFromParent();
		}
		
		public function returnAllAssets():void
		{
			var b:PoolElement;
			var poolLen:int = pool.length;
			for (var i:int = 0; i < poolLen; i++ )
			{
				b = pool[i];
				b.inUse = false;
				b.removeFromParent();
				b = null;
			}
			
		}
	}
}

