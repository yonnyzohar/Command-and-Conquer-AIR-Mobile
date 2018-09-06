package com.rectanglePacker.utils
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author 
	 */
	public class CTextureData 
	{
		public static const BLEED_RIGHT : int  = 1;
		public static const BLEED_BOTTOM : int  = 2;
		public static const BLEED_LEFT : int  = 4;
		public static const BLEED_TOP : int  = 8;
		public static const BLEED_BOTTOM_RIGHT : int = BLEED_RIGHT + BLEED_BOTTOM;
		public static const BLEED_ALL : int = BLEED_RIGHT + BLEED_BOTTOM + BLEED_LEFT + BLEED_TOP;
		
		public var img : BitmapData;
		public var parentLikage:String;
		
		public var m_textureRect : Rectangle;
		public var m_source : String;
		public var m_extraData : Object;
		// bleeding flags - 0 is no bleeding
		public var m_bleedingFlags : int;
		
		public function CTextureData(_img:BitmapData, _parentLikage:String) 
		{
			img = _img;
			parentLikage = _parentLikage;
		}
		
	}

}