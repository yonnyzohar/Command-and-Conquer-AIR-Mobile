package com.dynamicTaMaker.utils
{
	import com.dynamicTaMaker.views.GameButton;
	import com.dynamicTaMaker.views.GameSprite;
	
	import flash.utils.Dictionary;
	
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class ButtonManager
	{
		private static var dict:Dictionary = new Dictionary();
		
		public static function setButton(btn:GameSprite, event:String, fnctn:Function):void
		{
			if(event == "TOUCH")
			{
				if(dict[btn] == undefined)
				{
					dict[btn] = {"TOUCH":[]};
				}
				if(dict[btn]["TOUCH"].indexOf(fnctn) == -1)
				{
					//trace"adding " + btn.name);
					dict[btn]["TOUCH"].push(fnctn);
				}
				
				
				btn.addEventListener(TouchEvent.TOUCH, onTouched);
			}
			
		}
		
		private static function onTouched(e:TouchEvent):void
		{
			var begin:Touch = e.getTouch(GameSprite(e.currentTarget), TouchPhase.BEGAN);
			var end:Touch = e.getTouch(GameSprite(e.currentTarget), TouchPhase.ENDED);
			
			if(begin)
			{
				////trace"begin "  + begin.id + " " + GameSprite(e.currentTarget).name);
				GameSprite(e.currentTarget).startCount();
			}
			
			if (end)
			{
				////trace"end "  + end.id + " " + GameSprite(e.currentTarget).name);
				var functionArray:Array = dict[(e.currentTarget)]["TOUCH"]; 
				
				if(functionArray)
				{
					if(GameSprite(e.currentTarget).userTapped())
					{
						for(var i:int = 0; i < functionArray.length; i++)
						{
							var fnctn:Function = functionArray[i];
							fnctn((e.currentTarget));
						}
					}
				}
			}
			
			e.stopPropagation();
		}
			
		public static function removeButtonEvents(btn:GameSprite):void
		{
			if(btn)btn.removeEventListener(TouchEvent.TOUCH, onTouched);
			dict[btn] = null;
			
		}
	}
}

