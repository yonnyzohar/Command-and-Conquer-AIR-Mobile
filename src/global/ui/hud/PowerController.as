package global.ui.hud
{
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
		private var team:Array;
		public var POWER_SHORTAGE:Boolean = false;
		
		public function PowerController(_team:Array)
		{
			team = _team;
			
		}
		

		public function updatePower():Object
		{
			var totalPowerIn:int = 0;//how much it takes
			var totalPowerOut:int = 0;//how much it gives
			var i:int = 0;
			var p:GameEntity;
			
			for (i = 0; i < team.length; i++ )
			{
				p = team[i];
				if (p is Building)
				{
					totalPowerIn  += BuildingsStatsObj(BuildingModel(p.model).stats).powerIn;
					totalPowerOut += BuildingsStatsObj(BuildingModel(p.model).stats).powerOut;
				}
			}
			
			//trace("totalPowerIn " + totalPowerIn);
			//trace("totalPowerOut " + totalPowerOut);
			
			if (totalPowerIn > totalPowerOut)
			{
				POWER_SHORTAGE = true;
			}
			else
			{
				POWER_SHORTAGE = false;
			}
			
			return {totalPowerIn : totalPowerIn , totalPowerOut : totalPowerOut}
			
		}
	}
}