package com.yonnyzohar.states.game.teamsData
{
	import com.yonnyzohar.global.enums.Agent;
	import com.yonnyzohar.global.GameSounds;
	import starling.events.EventDispatcher;
	import com.yonnyzohar.states.game.entities.buildings.Building;
	import com.yonnyzohar.states.game.entities.buildings.BuildingModel;
	import com.yonnyzohar.states.game.entities.GameEntity;
	import com.yonnyzohar.states.game.stats.BuildingsStatsObj;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class PowerController extends EventDispatcher
	{
		public var POWER_SHORTAGE:Boolean = false;
		
		public function PowerController()
		{
			
		}
		

		public function updatePower(_agent:int, totalPowerIn:int, totalPowerOut:int):Object
		{
			var prevPower:Boolean = POWER_SHORTAGE;
			
			if (totalPowerIn > totalPowerOut)
			{
				POWER_SHORTAGE = true;
				if (_agent == Agent.HUMAN && prevPower == false)
				{
					GameSounds.playSound("low_power", "vo" );
					GameSounds.playSound("PowerDown");
				}
			}
			else
			{
				POWER_SHORTAGE = false;
				
			}
			
			return {totalPowerIn : totalPowerIn , totalPowerOut : totalPowerOut}
		}
	}
}