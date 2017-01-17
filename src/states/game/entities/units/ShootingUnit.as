package  states.game.entities.units
{
	import starling.events.Event;
	import flash.geom.Point;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.Methods;
	import global.Parameters;
	import global.utilities.SightManager;
	import states.game.entities.buildings.Building;
	import states.game.entities.EntityModel;
	import states.game.entities.GameEntity;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
	import flash.utils.getTimer;
	import global.Methods;
	import global.Parameters;
	import global.enums.Agent;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.map.Node;
	import states.game.stats.AssetStatsObj;
	import states.game.teamsData.TeamObject;
	import states.game.weapons.Weapon;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class ShootingUnit extends Unit
	{
		protected var dontShootCounter:int = 0;
		protected var closestEnemyArr:Array = [];
		protected var findTargetTimer:int = 0;
		protected var enemiesInSight:Array = [];
		protected var globalI:int = 0;
		protected var currentEnemy:GameEntity;
		protected var currentI:int = 0;
		protected var dir:String = "top";
		protected var tileFound:Boolean = false;
		protected var foundEnemy:GameEntity;
		private var weapon:Weapon;
		
		
		
		public function ShootingUnit(_unitStats:AssetStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int) 
		{
			super(_unitStats, teamObj, _enemyTeam, myTeam);
			
			if (_unitStats.weapon)
			{
				weapon = new Weapon(_unitStats.weapon, model);
			}
		}
		
		override protected function setState(state:int):void
		{
			if (state != UnitStates.SHOOT)
			{
				if (view)
				{
					view.removeEventListener("DONE_ROTATING", onDoneRotating);
				}
			}
			super.setState(state);
		}
		
		
		
		//main find target loop
		protected function findATarget(_pulse:Boolean):void
		{

			if(UnitModel(model).userOverrideAutoShoot)
			{
				////trace"user override shoot");
				dontShootCounter++;
				
				if(dontShootCounter > 50)
				{
					UnitModel(model).userOverrideAutoShoot = false;
				}
				else
				{
					return;
				}
			}
			
			if (aiBehaviour == AiBehaviours.HELPLESS || model.stats.weapon == null) return;
			
			
			if(model.enemyTeam == null || model.enemyTeam.length == 0)
			{
				return;
			}
			
			
			if(Methods.isValidEnemy(currentEnemy, teamNum))
			{
				if(isInRange(currentEnemy) && UnitModel(model).inWayPoint)
				{
					stopMovingAndSplicePath(true);
					setState(UnitStates.SHOOT);
				}
				else
				{
					//currentEnemy = getTargetsInSight();
					
					//yes
					if(currentEnemy != null)
					{
						if(isInRange(currentEnemy) && UnitModel(model).inWayPoint)
						{
							//switch to close guy
							stopMovingAndSplicePath(true);
							setState(UnitStates.SHOOT);
						}
						else
						{
							if (aiBehaviour == AiBehaviours.SEEK_AND_DESTROY || aiBehaviour == AiBehaviours.BASE_DEFENSE)
							{
								var possibleEnemy:GameEntity = getTargetRange();
								if (possibleEnemy)
								{
									currentEnemy = possibleEnemy;
								}
							}
							else
							{
								//run to him, he's still closeer
								setState(UnitStates.WALK);
							}
							
							
						}
					}
					else
					{
						//no one closer in sight - pursue!!!
						//walk towards the enemy!!!
						if(aiBehaviour != AiBehaviours.SEEK_AND_DESTROY)currentEnemy = null;
						setState(UnitStates.WALK);
					}
				}
			}
			else
			{
				//if no current enenmy
				//is there a target in range?
				
				currentEnemy = getTargetRange();
				
				
				if(currentEnemy != null && UnitModel(model).inWayPoint)
				{
					stopMovingAndSplicePath(true);
					setState(UnitStates.SHOOT);
				}
				else
				{
					////trace"there is no target in range!");
					//if i'm in seek and destroy, and i'm a computer
					if(aiBehaviour == AiBehaviours.SEEK_AND_DESTROY && model.controllingAgent == Agent.PC)
					{
						currentEnemy = findClosestTargetOnMap();
						if(currentEnemy != null)setState(UnitStates.WALK);
					}
					else if (aiBehaviour == AiBehaviours.BASE_DEFENSE)
					{
						currentEnemy = findEnemyWithinBase();
						if(currentEnemy != null)setState(UnitStates.WALK);
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
			var shootRange:int = UnitModel(model).stats.weapon.range;
			////trace("shootRange " + shootRange);
			
			var rowDiff:int;
			var colDiff:int;
			
			var dist:int = Methods.distanceTwoPoints(currentEnemy.model.col, model.col, currentEnemy.model.row, model.row);
			if (dist <= shootRange)
			{
				return true;
			}
			else
			{
				if (currentEnemy is Building)
				{
					var buildingTiles:Array = Building(currentEnemy).getBuildingTiles();
					var n:Node;
					var inRange:Boolean = false;
					for (var j:int = 0; j < buildingTiles.length; j++ )
					{
						n = buildingTiles[j];
						dist = Methods.distanceTwoPoints(n.col, model.col, n.row, model.row);
						if (dist <= shootRange)
						{
							inRange = true;
							break;
						}
					}
					return inRange;
				}
				else
				{
					return false;
				}
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
			
			var sightRange:int = UnitModel(model).stats.weapon.range;
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
						
						if (p is Building)
						{
							var buildingTiles:Array = Building(p).getBuildingTiles();
							var n:Node;
							for (var j:int = 0; j < buildingTiles.length; j++ )
							{
								n = buildingTiles[j];
								dist = Methods.distanceTwoPoints(n.col, model.col, n.row, model.row);
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
		
		override protected function lookAround():void
		{
			traceMe("lookAround");
			if(aiBehaviour != AiBehaviours.HELPLESS)
			{
				if(Methods.isValidEnemy(currentEnemy, teamNum))
				{
					getWalkPath(currentEnemy.model.row, currentEnemy.model.col);
				}
				else
				{
					stopMovingAndSplicePath();
					setState(UnitStates.IDLE);
				}
			}
		}	
		
		override public function walkToDestination(targetRow:int, targetCol:int):void
		{
			if(model == null)return;
			
			if(model.isSelected)
			{
				dontShootCounter = 0;
				UnitView(view).standCount = 0;
				UnitModel(model).userOverrideAutoShoot = true;
				currentEnemy = null;
			}
			super.walkToDestination(targetRow, targetCol);
		}
		
		override protected function handleIdleState(_pulse:Boolean):void
		{
			super.handleIdleState(_pulse);
			findATarget(_pulse);
		}
		
		override protected function handleWalkState(_pulse:Boolean):void
		{
			if(view is FullCircleView)
			{
				if(UnitModel(model).rotating)
				{
					return;
				}
			}
			super.handleWalkState(_pulse);
			findATarget(_pulse);
		}
		
		override protected function handleShootState(_pulse:Boolean):void
		{
			//if(model.userOverrideAutoShoot || model.moving)return;
			super.handleShootState(_pulse);
			shoot();
			traceMe( " shoot");
		}

		private function shoot():void 
		{
			if (model.dead == false)
			{
				if (Methods.isValidEnemy(currentEnemy, teamNum) && isInRange(currentEnemy))
				{
					
					var rateOfFire:int = UnitModel(model).stats.weapon.rateOfFire;
					if(UnitModel(model).shootCount == rateOfFire)
					{
						UnitView(view).shoot(currentEnemy , currentEnemy.model.row, currentEnemy.model.col);
						
						if(UnitModel(model).stats.weapon != null && UnitModel(model).rotating == false)
						{
							fireWeaponActual(currentEnemy)
						}
						else
						{
							view.addEventListener("DONE_ROTATING", onDoneRotating);
						}
						
					}
					else
					{
						if (UnitView(view).shootAnimPlaying == false)
						{
							UnitView(view).stopShootingAndStandIdlly();
						}
					}
					UnitModel(model).shootCount++;
				}
				else
				{
					doNothing();
				}
			}
			
		}
		
		private function onDoneRotating(e:Event):void 
		{
			view.removeEventListener("DONE_ROTATING", onDoneRotating);
			if (model.currentState == UnitStates.SHOOT)
			{
				UnitModel(model).shootCount = 0;// UnitModel(model).stats.weapon.rateOfFire;
			}
		}
		
		protected function fireWeaponActual(currentEnemy):void 
		{
			weapon.shoot(currentEnemy, view);
			if (Methods.isValidEnemy(currentEnemy, teamNum))
			{
				UnitView(view).recoil( currentEnemy);
			}
			UnitModel(model).shootCount = 0;
		}
		
		override protected function doNothing():void
		{
			currentEnemy = null;
			UnitModel(model).shootCount = 0;
			super.doNothing();
		}
		
		////////////////////////////////////////////----SPIRAL---/////////////////////////////////
		
		
		
		public function startSpiral(row:int, col:int, _range:int):GameEntity
		{
			foundEnemy = null;
			tileFound = false;
			currentI = 0;
			dir = "top";
			
			while (!tileFound)
			{
				var i:int = 0;
				dir = "top";
				currentI++;
				var e:GameEntity;
				var n:Node;
				
				////trace("moveUp " + currentI);
				for (i = 0; i <= currentI; i++)
				{
					if (Methods.validTile(row - i, col))
					{
						n =  Node(Parameters.boardArr[row - i][col] );
						e = GameEntity(n.occupyingUnit);
						//n.groundTile.removeFromParent();
						
						if (Methods.isValidEnemy(e, teamNum))
						{
							foundEnemy = e;
							tileFound = true;
							break;
						}
					}
				}
				
				if (!tileFound )
				{
					if (currentI < _range)
					{
						row = row - currentI;
						//moveRight
						dir = "right";
						for (i = 0; i < currentI; i++)
						{
							if (Methods.validTile(row, col + i))
							{
								n = Node(Parameters.boardArr[row][col + i] );
								e = GameEntity( n.occupyingUnit);
								//n.groundTile.removeFromParent();
								
								if (Methods.isValidEnemy(e, teamNum))
								{
									foundEnemy = e;
									tileFound = true;
									break;
								}
							}
						}
						
						if (!tileFound )
						{
							if (currentI < _range)
							{
								col = col + currentI;
								//moveDown(row, col, _range);
								dir = "down";
								currentI++;
								////trace("moveDown " + currentI);
								for (i = 0; i < currentI; i++)
								{
									if (Methods.validTile(row + i, col))
									{
										n =  Node(Parameters.boardArr[row + i][col] );
										e = GameEntity(n.occupyingUnit);
										//n.groundTile.removeFromParent();
										
										if (Methods.isValidEnemy(e, teamNum))
										{
											foundEnemy = e;
											tileFound = true;
											break;
										}
									}
								}
								
								
								if (!tileFound )
								{
									if (currentI <= _range)
									{
										row = row + currentI;
										//moveLeft(row, col, _range);
										dir = "left";
										////trace("moveLeft " + currentI);
										for (i = 0; i <= currentI; i++)
										{
											if (Methods.validTile(row, col - i))
											{
												n = Node(Parameters.boardArr[row][col - i] );
												e = GameEntity( n.occupyingUnit);
												
												//n.groundTile.removeFromParent();
												
												if (Methods.isValidEnemy(e, teamNum))
												{
													foundEnemy = e;
													tileFound = true;
													break;
												}
											}
										}
										
										
										if (!tileFound )
										{
											if (currentI <= _range)
											{
												col = col - currentI;
												//moveUp(row, col, _range);
											}
										}
									}
									else
									{
										tileFound = true;
										break;
									}
								}
							}
							else
							{
								tileFound = true;
								break;
							}
						}
						
					}
					else
					{
						tileFound = true;
						break;
					}
				}
			}

			return foundEnemy;
		}
		


		
		
		
		override public function dispose():void
		{
			if (view)
			{
				view.removeEventListener("DONE_ROTATING", onDoneRotating);
			}
			weapon = null;
			super.dispose();
		}
		
	}

}
