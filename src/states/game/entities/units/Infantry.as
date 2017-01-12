package states.game.entities.units
{
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
	import states.game.stats.InfantryStatsObj;
	import states.game.teamsData.TeamObject;

	public class Infantry extends ShootingUnit
	{
		public function Infantry(_unitStats:InfantryStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int)
		{
			super(_unitStats, teamObj, _enemyTeam, myTeam);
			model.enemyTeam = _enemyTeam;
			if (UnitModel(model).stats.weapon)
			{
				UnitModel(model).shootCount = UnitModel(model).stats.weapon.rateOfFire;//UnitModel(model).unitStats.shootCycleInterval);
			}
			
		}
		
		override protected function handleDeath(_pulse:Boolean):void
		{
			super.handleDeath(_pulse);
			UnitView(view).state = "_" + currentInfantryDeath;
			view.mc.addEventListener(Event.COMPLETE, onDeathComp);
			view.mc.loop = false;
			UnitView(view).animatelayer();
		}
		
		private function onDeathComp(e:Event):void 
		{
			view.mc.removeEventListener(Event.COMPLETE, onDeathComp);
			dispatchEvent(new Event("DEAD"));
		}
	}
}