package com.yonnyzohar.global.utilities
{
	import flash.events.AccelerometerEvent;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TransformGestureEvent;
	import flash.sensors.Accelerometer;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import com.yonnyzohar.global.map.Node;
	
	import com.yonnyzohar.global.Methods;
	import com.yonnyzohar.global.Parameters;

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class KeyboardController extends EventDispatcher
	{
		public  static var up:Boolean = false;
		public static  var down:Boolean = false;
		public  static var left:Boolean = false;
		public  static var right:Boolean = false;
		public static var ctrl:Boolean = false;
		
		private var my_acc:Accelerometer;
		
		
		
		private static var instance:KeyboardController = new KeyboardController();
		
		public function KeyboardController()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():KeyboardController
		{
			return instance;
		}
		
		public function init():void 
		{
			//Multitouch.inputMode = MultitouchInputMode.GESTURE;

			enable();
		}
		
		public function enable():void
		{
			if(Methods.isMobile())
			{
				//my_acc = new Accelerometer();
				//my_acc.setRequestedUpdateInterval(50);
				//my_acc.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);
			}
			else
			{
				//Parameters.flashStage.addEventListener(TransformGestureEvent.GESTURE_SWIPE , onSwipe);
				
			}
			
			Parameters.flashStage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			Parameters.flashStage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
		}
		
		
		
		
		
		public function disable():void
		{
			Parameters.flashStage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			Parameters.flashStage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode==(Keyboard.RIGHT))
			{
				right = true;
			}
			if (event.keyCode==(Keyboard.LEFT))
			{
				left = true;
			}
			if (event.keyCode==(Keyboard.UP))
			{
				up = true;
			}
			if (event.keyCode==(Keyboard.DOWN))
			{
				down = true;
			}
			if (event.keyCode == (Keyboard.CONTROL))
			{
				ctrl = true;
			}
		}

		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode==(Keyboard.RIGHT))
			{
				right = false;
			}
			if (event.keyCode==(Keyboard.LEFT))
			{
				left = false;
			}
			
			if (event.keyCode==(Keyboard.UP))
			{
				up = false;
			}
			if (event.keyCode==(Keyboard.DOWN))
			{
				down = false;
			}
			if (event.keyCode == (Keyboard.CONTROL))
			{
				ctrl = false;
			}
		}
		
		/////////////////////////////////////////
		
		private function onSwipe (e:TransformGestureEvent):void
		{
			if (e.offsetX == 1) 
			{ 
				//User swiped towards right
			}
			if (e.offsetX == -1) 
			{ 
				//User swiped towards left
			} 
			if (e.offsetY == 1)
			{ 
				//User swiped towards bottom
			}
			if (e.offsetY == -1) 
			{ 
				//User swiped towards top
			} 
		}
	}
}