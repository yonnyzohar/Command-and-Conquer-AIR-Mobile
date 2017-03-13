package  states.game.entities.buildings
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import global.enums.Agent;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.Methods;
	import global.Parameters;
	import global.utilities.SightManager;
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.HealthBar;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
	import states.game.stats.BuildingsStatsObj;
	import states.game.stats.TurretStatsObj;
	import states.game.teamsData.TeamObject;
	import states.game.weapons.Weapon;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Turret extends Building
	{
		private var currentEnemy:GameEntity;
		private var weapon:Weapon;
		private var shootInterval:int;
		
		public function Turret(_turretStats:TurretStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int)
		{
			super(_turretStats, teamObj,_enemyTeam, myTeam );
			teamNum = myTeam;
			name = _turretStats.name;
			
			if (_turretStats.weapon)
			{
				weapon = new Weapon(_turretStats.weapon, model);
			}
		}
		
		override protected function initModel():void 
		{
			model = new TurretModel();
		}
		
		override protected function initView():void 
		{
			if (model.stats.rotationType == 32)
			{
				view = new TurretFullCircleView(model);
			}
			else
			{
				view = new TurretView(model, model.stats.name);
			}
			
			var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			view.mc.y -= Parameters.tileSize * (occupyArray.length-1);
			
			
		}
		
		
		override public function update(_pulse:Boolean):void
		{
			super.update(_pulse);
			
			if(model != null && model.dead == false)
			{
				switch(model.currentState)
				{
					case UnitStates.IDLE:
						handleIdleState(_pulse);
						break;
					case UnitStates.SHOOT:
						handleShootState(_pulse);
						break;
					case UnitStates.DIE:
						//handleDeath(_pulse);
						break;
				}
			}
		}
		
		//main find target loop
		protected function findATarget(_pulse:Boolean):void
		{
			
			if (aiBehaviour == AiBehaviours.HELPLESS || model.stats.weapon == null) return;
			
			
			if(model.enemyTeam == null || model.enemyTeam.length == 0)
			{
				return;
			}
			
			
			if(Methods.isValidEnemy(currentEnemy, teamNum))
			{
				if(Methods.isInRange(this, currentEnemy))
				{
					setState(UnitStates.SHOOT);
				}
				else
				{
					currentEnemy = Methods.findClosestTargetinSight2(this);
				}
			}
			else
			{
				currentEnemy = Methods.findClosestTargetinSight2(this);
			}
		}
		

		protected function handleIdleState(_pulse:Boolean):void
		{
			doNothing();
			findATarget(_pulse);
		}
		
		
		protected function handleShootState(_pulse:Boolean):void
		{
			if (myTeamObj.powerCtrl.POWER_SHORTAGE)
			{
				return;
			}
			shoot();
		}
		

		private function shoot():void 
		{
			if (model.dead == false && BuildingView(view).state != "_build")
			{
				if (Methods.isValidEnemy(currentEnemy, teamNum) && Methods.isInRange(this, currentEnemy))
				{
					
					var rateOfFire:int = TurretModel(model).stats.weapon.rateOfFire;
					
					if(TurretModel(model).shootCount == rateOfFire)
					{
						view.shoot(currentEnemy , currentEnemy.model.row, currentEnemy.model.col);
						
						if(TurretModel(model).stats.weapon != null && TurretModel(model).rotating == false)
						{
							fireWeaponActual(currentEnemy)
						}
						else
						{
							view.addEventListener("DONE_ROTATING", onDoneRotating);
						}
					}

					TurretModel(model).shootCount++;
				}
				else
				{
					findATarget(false);
				}
			}
		}
		
		private function onDoneRotating(e:Event):void 
		{
			view.removeEventListener("DONE_ROTATING", onDoneRotating);
			if (model.currentState == UnitStates.SHOOT)
			{
				TurretModel(model).shootCount = 0;
			}
		}
		
		//////////////
		
		protected function fireWeaponActual(currentEnemy:GameEntity):void 
		{
			if (TurretStatsObj(model.stats).fireIndex)
			{
				shootInterval = setInterval(function():void
				{
					if (view && TurretView(view).state == "_fire")
					{
						if (view.mc && view.mc.currentFrame == TurretStatsObj(model.stats).fireIndex)
						{
							weapon.shoot(currentEnemy, view);
							if (Methods.isValidEnemy(currentEnemy, teamNum))
							{
								view.recoil( currentEnemy);
							}
							TurretModel(model).shootCount = 0;
							
							clearInterval(shootInterval)
							
						}
					}
					else
					{
						clearInterval(shootInterval);
					}
					
				},50);
			}
			else
			{
				weapon.shoot(currentEnemy, view);
				if (Methods.isValidEnemy(currentEnemy, teamNum))
				{
					view.recoil( currentEnemy);
				}
				TurretModel(model).shootCount = 0;
			}
		}
		//////////////
		
		protected function doNothing():void
		{
			TurretModel(model).shootCount = 0;
		}
		
	}
}