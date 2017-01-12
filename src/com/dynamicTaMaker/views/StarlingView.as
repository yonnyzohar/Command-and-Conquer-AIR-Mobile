package com.dynamicTaMaker.views
{
	import starling.display.Image;
	import starling.display.Sprite;

	public class StarlingView extends Sprite
	{
		
		public function StarlingView()
		{
			super();
		}
		
		override public function dispose():void
		{
			completeKill(this);
			
			
		}
		private function completeKill(_starlingView:StarlingView):void 
		
		{
			for (var k:* in _starlingView)
			{
				if (_starlingView[k] is Image)
				{
					//trace"removing image");
					var img:Image = Image(_starlingView[k]);
					img.dispose();
					img.removeFromParent(true);
				}
				else 
				{
					if (_starlingView[k] is StarlingView)
					{
						completeKill(_starlingView[k]);
						if (_starlingView[k].removeFromParent)
						{
							_starlingView[k].removeFromParent(true);
						}
					}
					
				}
			}
		}
		
	}
}



