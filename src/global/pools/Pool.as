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
		private var counter:int = 0;
		private var default_pool_size:int = 10;
		
		public function Pool(_CLS:Class, _textures:Vector.<Texture>, _offsetX:int = 0, _offsetY:int = 0)
		{
			offsetX = _offsetX;
			offsetY = _offsetY;
			CLS = _CLS;
			textures = _textures;
			var b:PoolElement;
			for(var i:int = 0; i < default_pool_size; i++)
			{
				b = new CLS(textures, offsetX, offsetY);
				b.inUse = false;
				pool.push(b);
			}

			counter = default_pool_size;
			
			
		}
		
		
		public function getAsset():PoolElement
		{
			var b:PoolElement = null;

			if ( counter > 0 ){
				b = pool[--counter];
				b.inUse = true;
				b.x = 0;
				b.y = 0;
				b.visible = true;
				b.alpha = 1;
				b.touchable = false;
				b.scaleX = b.scaleY = Parameters.gameScale;
				b.rotation = 0;
				return b;
			}
			
			var GROWTH_VALUE:int = 1;
			
			var i:uint = GROWTH_VALUE;
			while( --i > -1 ){
				pool.unshift ( new CLS(textures, offsetX, offsetY) );
			}
			
			counter = GROWTH_VALUE;
			return getAsset();
		}
		
		public function returnAsset(b:PoolElement):void
		{
			pool[counter++] = b;
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

