package  states.game.entities.units
{
	import global.GameAtlas;
	import global.Methods;
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
		
		public function Vehicle(_unitStats:VehicleStatsObj, teamObj:TeamObject, _enemyTeams:Array, myTeam:int) 
		{
			super(_unitStats, teamObj, _enemyTeams, myTeam);
			model.enemyTeams = _enemyTeams;
			if (_unitStats.weapon)
			{
				UnitModel(model).shootCount = UnitModel(model).stats.weapon.rateOfFire;
			}
			
			if (_unitStats.hasTurret)
			{
				turretMC = new GunTurretView( GameAtlas.getTextures(_unitStats.name + "_turret", teamObj.teamColor) );
				FullCircleView(view).addTurret(turretMC);
			}
		}
		
		override protected function handleDeath(_pulse:Boolean):void
		{
			if (!Methods.isOnScreen(model.row, model.col))
			{
				return;
			}
			
			if (view.visible == false )
			{
				return;
			}
			
			var deathAnimation:String = VehicleStatsObj(model.stats).deathAnimation;
			playExplosion(deathAnimation);
			clearTile(model.row, model.col);
			super.handleDeath(_pulse);
		}
		
		override public function stopMovingAndSplicePath(_startShooting:Boolean = false):void
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

