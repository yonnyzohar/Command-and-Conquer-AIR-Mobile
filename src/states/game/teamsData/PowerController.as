package states.game.teamsData
{
	import global.enums.Agent;
	import global.GameSounds;
	import starling.events.EventDispatcher;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.BuildingModel;
	import states.game.entities.GameEntity;
	import states.game.stats.BuildingsStatsObj;
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