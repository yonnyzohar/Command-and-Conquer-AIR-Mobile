package com.yonnyzohar.global.utilities 
{
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class GlobalEventDispatcher extends EventDispatcher
	{
		
		private static var instance:GlobalEventDispatcher = new GlobalEventDispatcher();
		
		public function GlobalEventDispatcher()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():GlobalEventDispatcher
		{
			return instance;
		}

		
	}

}