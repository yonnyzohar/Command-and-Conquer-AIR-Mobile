package  com.dynamicTaMaker.atlases
{
	import flash.display.BitmapData;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	
	public class MyTA 
	{
		public static var ta:TextureAtlas;
		
		public static function init(bmp:BitmapData, xml:XML):void
		{
			ta = new TextureAtlas(Texture.fromBitmapData(bmp), XML(xml));
			bmp.dispose();
			bmp = null;
			
		}
		
		public static function seTAToNull():void
		{
			if (ta != null)
			{
				if (ta.texture)
				{
					ta.texture.dispose();
				}
				ta.dispose();
			}
			ta = null;
		}
		
		public static function dispose():void
		{
			if (ta)
			{
				ta.dispose();
			}
			ta = null;
		}
	}
}