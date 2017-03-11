package  states.game.entities.units
{
	import global.GameAtlas;
	import global.map.mapTypes.Board;
	import global.Parameters;
	import starling.core.Starling;
	import starling.display.MovieClip;
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
		private var explosionMC:MovieClip;
		
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
			var deathAnimation:String = VehicleStatsObj(model.stats).deathAnimation;
			playExplosion(deathAnimation);
			clearTile(model.row, model.col);
			super.handleDeath(_pulse);
		}
		
		override protected function stopMovingAndSplicePath(_startShooting:Boolean = false):void
		{
			super.stopMovingAndSplicePath(_startShooting);
			UnitView(view).shootAnimPlaying = false;
		}
		
		private function playExplosion(deathAnimation:String):void 
		{
			if (explosionMC == null)
			{
				explosionMC = GameAtlas.createMovieClip(deathAnimation);
				explosionMC.touchable = false;
				Board.mapContainerArr[Board.UNITS_LAYER].addChild(explosionMC);
				explosionMC.scaleX = explosionMC.scaleY = Parameters.gameScale;
				explosionMC.x = view.x; 
				explosionMC.y = view.y;
				explosionMC.x += ((model.stats.pixelOffsetX*Parameters.gameScale)/2);
				explosionMC.y += ((model.stats.pixelOffsetY*Parameters.gameScale)/2);
				
				Starling.juggler.add(explosionMC);
				explosionMC.addEventListener(Event.COMPLETE, onExplosionComplete);
				explosionMC.play();
			}
			
		}
		
		private function onExplosionComplete(e:Event):void
		{
			Starling.juggler.remove(explosionMC);
			explosionMC.removeEventListener(Event.COMPLETE, onExplosionComplete);
			explosionMC.removeFromParent();
		}
		
	
	}
}

