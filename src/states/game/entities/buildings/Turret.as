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
		
		
		public function update(_pulse:Boolean):void
		{
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
				if(isInRange(currentEnemy))
				{
					setState(UnitStates.SHOOT);
				}
				else
				{
					//yes
					if(currentEnemy != null)
					{
						if(isInRange(currentEnemy))
						{
							setState(UnitStates.SHOOT);
						}
					}
					else
					{
						//no one closer in sight - pursue!!!
						//walk towards the enemy!!!
						if (aiBehaviour != AiBehaviours.SEEK_AND_DESTROY)
						{
							currentEnemy = null;
						}
					}
				}
			}
			else
			{
				//if no current enenmy
				//is there a target in range?
				
				currentEnemy = Methods.findClosestTargetOnMap(this, false);
				
				
				if(currentEnemy != null)
				{
					setState(UnitStates.SHOOT);
				}
				else
				{
					////trace"there is no target in range!");
					//if i'm in seek and destroy, and i'm a computer
					if(aiBehaviour == AiBehaviours.SEEK_AND_DESTROY && model.controllingAgent == Agent.PC)
					{
						currentEnemy = Methods.findClosestTargetOnMap(this, true);
					}
					else if (aiBehaviour == AiBehaviours.BASE_DEFENSE)
					{
						currentEnemy = findEnemyWithinBase();
					}
					else
					{
						setState(UnitStates.IDLE);
					}
				}
			}
		}
		
		private function findEnemyWithinBase():GameEntity 
		{
			return SightManager.getInstance().getTargetWithinBase(model.controllingAgent, myTeamObj.teamName);
		}

		
		
		protected function isInRange(currentEnemy:GameEntity):Boolean
		{
			if(aiBehaviour == AiBehaviours.HELPLESS)return false;
			if(currentEnemy == null)return false;
			if(currentEnemy.model == null)return false;
			if(currentEnemy.model.dead == true)return false;
			var shootRange:int = model.stats.weapon.range;
			//////trace("shootRange " + shootRange);
			
			var rowDiff:int;
			var colDiff:int;
			
			//var dist:int = int(Math.abs(currentEnemy.row - model.row) + Math.abs(currentEnemy.col - model.col));
			var dist:int = Methods.distanceTwoPoints(currentEnemy.model.col, model.col, currentEnemy.model.row, model.row);
			if (dist <= shootRange)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		
		
		
		
		

		protected function handleIdleState(_pulse:Boolean):void
		{
			findATarget(_pulse);
		}
		
		
		protected function handleShootState(_pulse:Boolean):void
		{
			shoot();
		}
		

		private function shoot():void 
		{
			if (model.dead == false && BuildingView(view).state != "_build")
			{
				if (Methods.isValidEnemy(currentEnemy, teamNum) && isInRange(currentEnemy))
				{
					var model:TurretModel = TurretModel(model)
					
					var rateOfFire:int = model.stats.weapon.rateOfFire;
					
					if(model.shootCount == rateOfFire)
					{
						view.shoot(currentEnemy , currentEnemy.model.row, currentEnemy.model.col);
						
						if(model.stats.weapon != null && model.rotating == false)
						{
							fireWeaponActual(currentEnemy)
						}
						else
						{
							view.addEventListener("DONE_ROTATING", onDoneRotating);
						}
					}

					model.shootCount++;
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
			currentEnemy = null;
			TurretModel(model).shootCount = 0;
		}
		
	}
}