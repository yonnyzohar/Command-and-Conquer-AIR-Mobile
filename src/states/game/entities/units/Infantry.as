package states.game.entities.units
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
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
		private var shootInterval:int;
		
		public function Infantry(_unitStats:InfantryStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int)
		{
			super(_unitStats, teamObj, _enemyTeam, myTeam);
			model.enemyTeam = _enemyTeam;
			if (UnitModel(model).stats.weapon)
			{
				UnitModel(model).shootCount = UnitModel(model).stats.weapon.rateOfFire;
			}
			
		}
		
		override protected function fireWeaponActual(currentEnemy:GameEntity):void 
		{
			//this is for the grenadier only
			var fnctn:Function = super.fireWeaponActual;
			if (InfantryStatsObj(model.stats).fireIndex)
			{
				if (view && UnitView(view).state == "_fire")
				{
					shootInterval = setInterval(function() 
					{
						if (view && UnitView(view).state == "_fire")
						{
						
							if (view.mc && view.mc.currentFrame == InfantryStatsObj(model.stats).fireIndex)
							{
								if (fnctn)
								{
									fnctn(currentEnemy);
								}
								clearInterval(shootInterval)
								
							}
						}
						else
						{
							clearInterval(shootInterval);
						}
						
					},50);
				}
			}
			else
			{
				super.fireWeaponActual(currentEnemy);
			}
		}
		
		
		
		override protected function handleDeath(_pulse:Boolean):void
		{
			clearInterval(shootInterval)
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
				deathMC.x += ((model.stats.pixelOffsetX*Parameters.gameScale)/2);
				deathMC.y += ((model.stats.pixelOffsetY*Parameters.gameScale)/2);
				
				
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