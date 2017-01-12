package  states.game.entities.units
{
	import global.GameAtlas;
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.GunTurretView;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
	import states.game.stats.VehicleStatsObj;
	import states.game.teamsData.TeamObject;
	
	public class Vehicle extends ShootingUnit
	{
		private var turretMC:GunTurretView;
		
		public function Vehicle(_unitStats:VehicleStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int) 
		{
			super(_unitStats, teamObj, _enemyTeam, myTeam);
			model.enemyTeam = _enemyTeam;
			if (_unitStats.weapon)
			{
				UnitModel(model).shootCount = UnitModel(model).stats.weapon.rateOfFire;
			}
			
			if (_unitStats.hasTurret)
			{
				turretMC = new GunTurretView( GameAtlas.getTextures(_unitStats.name + "_turret", teamObj.teamName) );
				FullCircleView(view).addTurret(turretMC);
			}
		}
		
		override protected function handleDeath(_pulse:Boolean):void
		{
			super.handleDeath(_pulse);
			var deathAnimation:String = VehicleStatsObj(model.stats).deathAnimation;
			FullCircleView(view).playExplosion(deathAnimation);
			clearTile(model.row, model.col);
			dispatchEvent(new Event("DEAD"));
			
		}
	
	}
		
		
	

}

