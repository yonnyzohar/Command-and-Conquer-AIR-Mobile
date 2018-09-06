package com.dynamicTaMaker.views 
{
	import starling.textures.Texture;
	import starling.text.TextField;
	import starling.text.BitmapFont;

	public class GameBitmapTextField extends TextField
	{
		//[Embed(source="../../../../bin/assets/Helvetica.fnt", mimeType="application/octet-stream")]
		public static const FontXml:Class;
		 
		//[Embed(source="../../../../bin/assets/Helvetica_0.png")]
		public static const FontTexture:Class;
		
		private static var texture:Texture; 
		private  static var xml:XML; 

		public function GameBitmapTextField(_text:String, obj:Object, _width:int, _height:int )
		{
			//{font: child.size + "px " + child.font,align: 'center' };
			super( _width, _height, _text, obj.font, obj.font, 0x000000, false);
		}
		
		
		public static function initGameBitmapFont() :void
		{
			texture = Texture.fromBitmap(new FontTexture());
			xml = XML(new FontXml());
			
			TextField.registerBitmapFont(new BitmapFont(texture, xml));
		}
		
	}

}