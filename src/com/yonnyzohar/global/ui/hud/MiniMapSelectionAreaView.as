package com.yonnyzohar.global.ui.hud 
{
	import starling.display.Quad;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class MiniMapSelectionAreaView extends Sprite
	{
		private var bg:Quad;
		
		public function MiniMapSelectionAreaView(w:int, h:int) 
		{
			bg = new Quad(w, h, 0x000000);
			bg.alpha = 0.5;
			addChild(bg);
			var line1:Quad = new Quad(w, 1, 0x00ff00);
			addChild(line1);
			var line2:Quad = new Quad(1, h, 0x00ff00);
			addChild(line2)
			var line3:Quad = new Quad(w, 1, 0x00ff00);
			addChild(line3)
			line3.y = bg.height - 1;
			var line4:Quad = new Quad(1, h, 0x00ff00);
			addChild(line4)
			line4.x = bg.width - 1;
			
			
		}
		
	}

}