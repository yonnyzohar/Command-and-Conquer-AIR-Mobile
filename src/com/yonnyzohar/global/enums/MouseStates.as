package com.yonnyzohar.global.enums
{
	import com.yonnyzohar.global.utilities.GlobalEventDispatcher;
	import starling.events.Event;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class MouseStates 
	{
		
		public static const REG_PLAY:int = 0;
		public static const PLACE_BUILDING:int = 1;
		public static const SELECT:int = 2;
		public static const SELL:int = 3;
		public static const REPAIR:int = 4;
		
		private static var _currentState:int;
		
		static public function get currentState():int 
		{
			return _currentState;
		}
		
		static public function set currentState(value:int):void 
		{
			_currentState = value;
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event("GAME_STATE_CHANGED"));
		}
		
	}

}