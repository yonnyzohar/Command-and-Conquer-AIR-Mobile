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
	import states.game.entities.buildings.Turret;
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
		private var shootCount:int;
		
		
		public function ShootingUnit(_unitStats:AssetStatsObj, teamObj:TeamObject, _enemyTeams:Array, myTeam:int) 
		{
			super(_unitStats, teamObj, _enemyTeams, myTeam);
			
			if (_unitStats.weapon)
			{
				weapon = new Weapon(_unitStats.weapon, model);
				weapon.addEventListener("TARGET_DEAD", onTargetDead);
			}
			
			shootCount = UnitModel(model).shootCount;
		}
		
		private function onTargetDead(e:Event):void 
		{
			stopMovingAndSplicePath();
			setState(UnitStates.IDLE);
		}
		
		override public function setState(state:int):void
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
			
			if (uniqueID == 1)
			{
				//trace("bob");
			}

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
			
			
			if(model.enemyTeams == null || model.enemyTeams.length == 0)
			{
				return;
			}
			
			var search:Boolean = false;
			var possibleEnemy:GameEntity;
			var isValidEnemy:Boolean = false;
			//if valid enemy
			if(Methods.isValidEnemy(currentEnemy, teamNum))
			{
				isValidEnemy = true;
				//in range
				if(Methods.isInRange(this, currentEnemy) )
				{
					if (UnitModel(model).inWayPoint)
					{
						stopMovingAndSplicePath(true);
						setState(UnitStates.SHOOT);
						return;
					}
				}
				else
				{
					if (_pulse)
					{
						search = true;
					}
				}
			}
			else
			{
				search = true;
			}
				
			if (search )
			{
				possibleEnemy = Methods.findClosestTargetinSight2(this);
				
				if(Methods.isValidEnemy(possibleEnemy, teamNum))
				{
					if(currentEnemy && currentEnemy.uniqueID == possibleEnemy.uniqueID)
					{
						if (Math.random() > 0.1)
						{
							return;
						}
					}
					
					currentEnemy = possibleEnemy;
					
					getWalkPath(currentEnemy.model.row, currentEnemy.model.col);
					if(Methods.isInRange(this, currentEnemy) )
					{
						if (UnitModel(model).inWayPoint)
						{
							stopMovingAndSplicePath(true);
							setState(UnitStates.SHOOT);
							return;
						}
						else
						{
							setState(UnitStates.WALK);
							return;
						}
					}
					else
					{
						setState(UnitStates.WALK);
						return;
					}
					
				}
				
				
				if(aiBehaviour == AiBehaviours.SEEK_AND_DESTROY )
				{
					possibleEnemy = Methods.findClosestTargetOnMap(this);
					

					if(Methods.isValidEnemy(possibleEnemy, teamNum))
					{
					
						if(currentEnemy && currentEnemy.uniqueID == possibleEnemy.uniqueID)
						{
							
							if (model.currentState == UnitStates.WALK && Math.random() > 0.1)
							{
								return;
							}
							
						}
					
						currentEnemy = possibleEnemy;
						getWalkPath(currentEnemy.model.row, currentEnemy.model.col);
						setState(UnitStates.WALK);
						return;
					}
				}
			}
			
			if (isValidEnemy)
			{
				setState(UnitStates.WALK);
			}
		}
		
		
		
		override public function hurt(_hitVal:int, _currentInfantryDeath:String, projectileName:String = null ):Boolean
		{
			if (model.stats.weapon)
			{
				if (currentEnemy == null)
				{
					currentEnemy = Methods.findClosestTargetOnMap(this, true)
				}
				else
				{
					if (currentEnemy is Building && ((currentEnemy is Turret) == false))
					{
						currentEnemy = Methods.findClosestTargetOnMap(this, true);
					}
				}
				
			}
			return super.hurt(_hitVal, _currentInfantryDeath, projectileName);
		}

		
		
		
		
		
		
		
		
		
		override public function onDestinationReceived(targetRow:int, targetCol:int, _first:Boolean = true):void
		{
			if (model == null) return;
			
			
			if(model.isSelected)
			{
				
				dontShootCounter = 0;
				UnitView(view).standCount = 0;
				UnitModel(model).userOverrideAutoShoot = true;
			}
			super.onDestinationReceived(targetRow, targetCol,_first);
		}
		
		override protected function handleIdleState(_pulse:Boolean):void
		{
			super.handleIdleState(_pulse);
			findATarget(_pulse);
		}
		
		override protected function handleWalkState(_pulse:Boolean):void
		{
			//if unit is shooting let the animation finish
			if (model && model.currentState != UnitStates.DIE && UnitView(view).shootAnimPlaying)
			{
				return;
			}
			else
			{
				shootCount = 0;
			}
			if(view is FullCircleView)
			{
				if(UnitModel(model).rotating)
				{
					return;
				}
			}
			if (UnitView(view).shootAnimPlaying)
			{
				return;
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
				
				if (Methods.isValidEnemy(currentEnemy, teamNum) && Methods.isInRange(this, currentEnemy))
				{
					
					var rateOfFire:int = UnitModel(model).stats.weapon.rateOfFire;
					if(shootCount == rateOfFire)
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
						else
						{
							////trace("shoot anim is playing")
						}
					}
					
					shootCount++;
					//trace(shootCount)
				}
				else
				{
					doNothing();
				}
			}
			
		}
		

		
		
		override protected function onDoneRotating(e:Event):void 
		{
			super.onDoneRotating(e);
			if (model.currentState == UnitStates.SHOOT)
			{
				shootCount = 0;
				//trace("shootCount 0 done rotating")
			}
		}
		
		protected function fireWeaponActual(currentEnemy:GameEntity):void 
		{
			weapon.shoot(currentEnemy, view);
			if (Methods.isValidEnemy(currentEnemy, teamNum))
			{
				UnitView(view).recoil( currentEnemy);
			}
			shootCount = 0;
			//trace("shootCount 0 fireWeaponActual")
		}
		
		override protected function doNothing():void
		{
			currentEnemy = null;
			if (UnitView(view).shootAnimPlaying == false)
			{
				shootCount = 0;
				//trace("shootCount 0 doNothing")
			}
			
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
				
				//////trace("moveUp " + currentI);
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
								//////trace("moveDown " + currentI);
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
										//////trace("moveLeft " + currentI);
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
			closestEnemyArr = null;
			enemiesInSight = null;

			foundEnemy = null;
			if (weapon)
			{
				weapon.removeEventListener("TARGET_DEAD", onTargetDead);
				weapon.dispose();
			}
			
			
			if (view)
			{
				view.removeEventListener("DONE_ROTATING", onDoneRotating);
			}
			weapon = null;
			super.dispose();
		}
		
	}

}
