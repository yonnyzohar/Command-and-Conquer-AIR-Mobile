package  states.game.entities.buildings
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import global.enums.Agent;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.Methods;
	import global.utilities.SightManager;
	import starling.events.Event;
	import states.game.entities.GameEntity;
	import states.game.entities.HealthBar;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
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
				
				currentEnemy = getTargetRange();
				
				
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
						currentEnemy = findClosestTargetOnMap();
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

		protected function findClosestTargetOnMap():GameEntity
		{
			var p:GameEntity;
			var closestEnemny:GameEntity;
			
			if(aiBehaviour != AiBehaviours.SEEK_AND_DESTROY)
			{
				return null;
			}
			
			if(model.enemyTeam == null)
			{
				return null;
			}
			
			if(model.enemyTeam.length == 0)
			{
				return null;
			}
			
			var enemyTeamLength:int = model.enemyTeam.length;
			var shortestDist:int = 100000;
			
			for(var i:int = enemyTeamLength -1; i >= 0; i--)
			{
				p = GameEntity(model.enemyTeam[i]);
				
				if(p.model != null)
				{
					if(p.model.dead == false)
					{
						//var dist:int = int(Math.abs(p.row - model.row) + Math.abs(p.col - model.col));
						var dist:int = Methods.distanceTwoPoints(p.model.col, model.col, p.model.row, model.row);
						if (dist < shortestDist)
						{
							shortestDist = dist;
							closestEnemny = p;
						}
					}
				}
			}
			
			return closestEnemny;
		}
		
		protected function isInRange(currentEnemy:GameEntity):Boolean
		{
			if(aiBehaviour == AiBehaviours.HELPLESS)return false;
			if(currentEnemy == null)return false;
			if(currentEnemy.model == null)return false;
			if(currentEnemy.model.dead == null)return false;
			var shootRange:int = model.stats.weapon.range;
			////trace("shootRange " + shootRange);
			
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
		
		
		private function getTargetRange():GameEntity 
		{
			if (aiBehaviour == AiBehaviours.HELPLESS) return null;
			
			var p:GameEntity;
			var closestEnemny:GameEntity;
			

			if(model.enemyTeam == null)
			{
				return null;
			}
			
			if(model.enemyTeam.length == 0)
			{
				return null;
			}
			
			var sightRange:int = model.stats.weapon.range;
			var enemyTeamLength:int = model.enemyTeam.length;
			var shortestDist:int = 100000;
			
			for(var i:int = enemyTeamLength -1; i >= 0; i--)
			{
				p = GameEntity(model.enemyTeam[i]);
				
				if(p.model != null)
				{
					if(p.model.dead == false)
					{
						var dist:int = Methods.distanceTwoPoints(p.model.col, model.col, p.model.row, model.row);
						//int(Math.abs(p.row - model.row) + Math.abs(p.col - model.col));
						if (dist <= sightRange)
						{
							if (dist < shortestDist)
							{
								shortestDist = dist;
								closestEnemny = p;
							}
						}
					}
				}
			}
			
			return closestEnemny;
			//e = startSpiral(model.row, model.col, sightRange*2);
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
				shootInterval = setInterval(function() 
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