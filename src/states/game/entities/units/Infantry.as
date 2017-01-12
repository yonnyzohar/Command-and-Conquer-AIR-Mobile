package states.game.entities.units
{
	import global.GameAtlas;
	import global.Parameters;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
	import states.game.stats.InfantryStatsObj;
	import states.game.teamsData.TeamObject;

	public class Infantry extends ShootingUnit
	{
		private var deathMC:MovieClip;
		
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
			playDeathAniamtion(model.stats.name +  "_" + currentInfantryDeath);
			super.handleDeath(_pulse);
			dispatchEvent(new Event("DEAD"));
		}
		
		
		private function playDeathAniamtion(_deathStateName:String):void
		{
			if (deathMC == null)
			{
				trace(_deathStateName)
				deathMC = GameAtlas.createMovieClip(_deathStateName, this.model.teamName);
				deathMC.loop = false;
				deathMC.touchable = false;
				deathMC.addEventListener(Event.COMPLETE, onDeathComplte);
				deathMC.scaleX = deathMC.scaleY = Parameters.gameScale;
				Parameters.mapHolder.addChild(deathMC);
				Starling.juggler.add(deathMC);
				deathMC.x = view.x;// + (width / 2);
				deathMC.y = view.y;// + (height / 2);
				view.visible = false;
			}
			else
			{
				trace("GTO HERE TWICE!!!!");
			}
		}
		
		
		
		private function onDeathComplte(e:Event):void 
		{
			deathMC.removeEventListener(Event.COMPLETE, onDeathComplte);
			Starling.juggler.remove(deathMC);
			deathMC.removeFromParent()
			
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		
	}
}