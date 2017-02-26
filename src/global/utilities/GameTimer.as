package global.utilities
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import global.Parameters;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import flash.utils.getQualifiedClassName; 
	
	public class GameTimer extends EventDispatcher
	{
		static private var instance:GameTimer = new GameTimer();
		private var updatables:Dictionary = new Dictionary();
		
		private var users:Array = new Array();
		private var interval:Number;
		private var globalI:int = 0;
		
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
		
		
		public function addUser(mc:*):void
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
			if(globalI == Parameters.flashStage.frameRate)
			{
				globalI = 0;
			}
			
			for(var k:* in updatables)
			{
				updatables[k].update(globalI == 0);
			}
			
			globalI++;
		}
		
		
		public function removeUser(mc:*):void
		{
			//trace("removing " + getQualifiedClassName(mc));
			
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
		
		public function dispose():void
		{
			for(var k:* in updatables)
			{
				removeUser(updatables[k]);
			}
			Parameters.theStage.removeEventListener(Event.ENTER_FRAME, update);
			updatables = new Dictionary();
			globalI = 0;
		}
		
		public function freezeTimer():void
		{
			Parameters.theStage.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		public function resumeTimer():void
		{
			Parameters.theStage.addEventListener(Event.ENTER_FRAME, update);
			
		}
	}
}


		
