package global.utilities
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	import com.greensock.plugins.ThrowPropsPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	

	public class DragScroll
	{
		private var screenSize:Rectangle;
		private var mc:Sprite;
		private var stage:Stage;
		private var t1:uint, t2:uint, y1:Number, y2:Number, yOverlap:Number, yOffset:Number;
		private var y:Number;
		private var x:Number;
		private var t:uint;
		private var x1:int;
		private var x2:int;
		private var xOffset:int;
		private var xOverlap:Number;
		
		
		//private var blitMask:BlitMask;
		private var scrollTimeout:Number;
		private var renderFunction:Function;
		private var totalMapSize:Rectangle;
		
		TweenPlugin.activate([ThrowPropsPlugin]);
		
		public function DragScroll()
		{
			
		}
		//Parameters.mapHolder, Parameters.theStage, totalMapSize,screenSize, mapMover.render
		public function init(_mc:Sprite, _stage:Stage, _totalMapSize:Rectangle,_screenSize:Rectangle, _renderFunction:Function):void
		{
			totalMapSize = _totalMapSize;
			renderFunction = _renderFunction;
			dispose();
			
			screenSize = _screenSize;
			mc = _mc;
			stage = _stage;
			mc.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var startMulti:Vector.<Touch> = e.getTouches(stage, TouchPhase.BEGAN);
			var movingMulti:Vector.<Touch> = e.getTouches(stage, TouchPhase.MOVED);
			var endMulti:Vector.<Touch> = e.getTouches(stage, TouchPhase.ENDED);
			var location:Point;
			
			
			if(startMulti != null && startMulti.length != 0)
			{
				location = startMulti[0].getLocation(stage);
				beginScroll(location.x,location.y );
			}
			
			if(movingMulti != null && movingMulti.length != 0)
			{
				location = movingMulti[0].getLocation(stage);
				
				if(movingMulti.length >= 2)
				{
					mouseMoveHandler(location.x,location.y);
				}
			}
			
			if(endMulti != null && endMulti.length != 0)
			{
				location = endMulti[0].getLocation(stage);
				if(endMulti.length >= 2)
				{
					mouseUpHandler(location.x,location.y);
				}
			}
			
			/*var startMulti:Touch = e.getTouch(stage, TouchPhase.BEGAN);
			var movingMulti:Touch = e.getTouch(stage, TouchPhase.MOVED);
			var endMulti:Touch = e.getTouch(stage, TouchPhase.ENDED);
			var location:Point;
			
			
			if(startMulti != null )
			{
				location = startMulti.getLocation(stage);
				beginScroll(location.x,location.y );
			}
			
			if(movingMulti != null )
			{
				location = movingMulti.getLocation(stage);

				mouseMoveHandler(location.x,location.y);
			}
			
			if(endMulti != null )
			{
				location = endMulti.getLocation(stage);
			
				mouseUpHandler(location.x,location.y);
				
			}*/
			
			
		}		
		
		
		
		private function beginScroll(locX:int, locY:int):void
		{
			TweenLite.killTweensOf(mc);
			x1 = x2 = mc.x;
			xOffset = locX - mc.x;
			//xOverlap = Math.max(0, mc.width - bounds.width);
			y1 = y2 = mc.y;
			yOffset = locY - mc.y;
			//yOverlap = Math.max(0, mc.height - bounds.height);
			t1 = t2 = getTimer();
		}
		
		private function mouseMoveHandler(locX:int, locY:int):void 
		{
			var sticky:Number = 0.5;
			
			if (totalMapSize.height > screenSize.height)
			{
				var y:Number = locY - yOffset;
				//if mc's position exceeds the bounds, make it drag only half as far with each mouse movement (like iPhone/iPad behavior)
				mc.y = y;
				
				if (mc.y > 0) 
				{
					mc.y = 0;
				} 
				if (mc.y + totalMapSize.height < screenSize.height) 
				{
					mc.y = screenSize.height - totalMapSize.height;
				} 
			}
			
			

			
			if (totalMapSize.width > screenSize.width)
			{
				var x:Number = locX - xOffset;
				mc.x = x;
				
				if (mc.x > 0) 
				{
					mc.x = 0;
				} 
				if (mc.x  + totalMapSize.width <screenSize.width)
				{
					mc.x = screenSize.width - totalMapSize.width;
				} 
			}
			

			
			/*var t:uint = getTimer();
			if (t - t2 > 50) 
			{
				x2 = x1;
				x1 = mc.x;
				y2 = y1;
				t2 = t1;
				y1 = mc.y;
				t1 = t;
			}*/
			
			renderFunction();
		}
		
		
		private function mouseUpHandler(locX:int, locY:int):void 
		{
			/*var time:Number = (getTimer() - t2) / 1000;
			var xVelocity:Number = (mc.x - x2) / time;
			var yVelocity:Number = (mc.y - y2) / time;
			ThrowPropsPlugin.to(mc, {throwProps:{
				y:{velocity:yVelocity, max:bounds.top, min:bounds.top - yOverlap, resistance:300},
				x:{velocity:xVelocity, max:bounds.left, min:bounds.left - xOverlap, resistance:300}
			}, ease:Strong.easeOut
			}, 10, 0.3, 1);*/
			

		}


		
		public function dispose():void
		{
			
			clearTimeout(scrollTimeout);
					
			//bounds = null;
			//mc = null;
			//container = null;
			
		}
	}
}




