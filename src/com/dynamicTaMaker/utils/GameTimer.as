package com.dynamicTaMaker.utils
{
	import flash.utils.Dictionary;
	import global.Parameters;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class  GameTimer extends EventDispatcher
	{
		static private var instance:GameTimer = new GameTimer();
		
		private var updatables:Dictionary = new Dictionary();
		
		public function GameTimer()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():GameTimer
		{
			return instance;
		}
		
		
		public function addUpdateAble(mc:*):void
		{
			updatables[mc] = mc;
			
			var len:int = 0;
			
			for(var k:* in updatables)
			{
				len++;
			}
			
			if(len != 0)
			{
				Parameters.theStage.addEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		private function update(e:Event):void
		{
			for(var k:* in updatables)
			{
				updatables[k].update();
			}
		}
		
		
		public function removeUpdateAble(mc:*):void
		{
			updatables[mc] = null;
			delete updatables[mc];
			
			var len:int = 0;
			
			for(var k:String in updatables)
			{
				len++;
			}
			
			if(len == 0)
			{
				Parameters.theStage.removeEventListener(Event.ENTER_FRAME, update);
			}
				
		}
	}
}