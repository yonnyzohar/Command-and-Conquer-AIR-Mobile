package com.yonnyzohar.states.game.stats
{
	import flash.utils.Dictionary;
	import com.yonnyzohar.global.assets.Assets;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class WarheadStats 
	{
		public static var dict:Dictionary = new Dictionary();

		public static function init():void
		{
			for (var warhead:String in Assets.warheads)
			{
				var curWarhead:Object = Assets.warheads[warhead];
				var warheadObj:WarheadStatsObj  = new WarheadStatsObj();
				
				warheadObj.name = 			curWarhead.name;// "smallarms",
				warheadObj.spread = 		curWarhead.spread;
				warheadObj.wood = 			curWarhead.wood;
				warheadObj.walls = 			curWarhead.walls;
				warheadObj.infantryDeath =  curWarhead.infantryDeath;
				dict[curWarhead.name] = warheadObj;
			}
			////trace("fsdfsdf");
		}
		
	}

}