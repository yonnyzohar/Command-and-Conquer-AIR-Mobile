package states.game.entities.units 
{
	import global.Methods;
	import global.enums.AiBehaviours;
	import global.GameSounds;
	import global.map.SpiralBuilder;
	import global.Parameters;
	import global.enums.Agent;
	import global.enums.UnitStates;
	import global.map.AStar;
	import global.map.Node;
	import states.game.stats.AssetStatsObj;
	
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Event;
	
	import states.game.entities.HealthBar;
	import states.game.entities.units.views.EightWayView;
	import states.game.entities.units.views.FullCircleView;
	import states.game.entities.units.views.UnitView;
	import states.game.teamsData.TeamObject;
	import states.game.uiTests.PathTest;
	import states.game.entities.GameEntity;

	public class Unit extends GameEntity
	{
		
		protected var aStar:AStar = new AStar();
		
		private var userDeterminedRow:int;
		private var userDeterminedCol:int;
		private var userPathReached:Boolean = false;
		private var handlingError:Boolean = false;
		private var finalNodeAfterError:Node;
		private static var WAYPOINT_REACHED_EVENT:starling.events.Event = new Event("WAYPOINT_REACHED");
		
		
		public function Unit(_unitStats:AssetStatsObj, teamObj:TeamObject, _enemyTeams:Array, myTeam:int) 
		{
			name = _unitStats.name;
			super(teamObj);
			model = new UnitModel();
			model.teamColor = teamObj.teamColor;
			model.teamName = teamObj.teamName;
			UnitModel(model).stats = _unitStats;
			teamNum = myTeam;
			model.enemyTeams = _enemyTeams;
			
			model.totalHealth = _unitStats.totalHealth;
			
			//UnitModel(model).sounds = _unitStats.sounds;
			
			model.controllingAgent = teamObj.agent;
			
			
			//if the unit can only look in 8 directions
			if(_unitStats.rotationType == 8)
			{
				view = new EightWayView(UnitModel(model));
			}
			else
			{
				view = new FullCircleView(UnitModel(model));
			}

			
			healthBar = new HealthBar(model.totalHealth, -model.stats.pixelOffsetX);
			view.addHealthBar(healthBar);
			
		}
		
		
		
		override public function sayHello():void
		{
			if (model.controllingAgent == Agent.HUMAN)
			{
				UnitView(view).playSelectSound();
			}
		}
		

		override public function update(_pulse:Boolean):void
		{
			super.update(_pulse);
			if(model != null && model.dead == false)
			{
				if (model.totalHealth < 0)
				{
					setState(UnitStates.DIE);
				}

				resetRowCol()
				switch(model.currentState)
				{
					case UnitStates.IDLE:
						handleIdleState(_pulse);
						break;
					case UnitStates.WALK:
						handleWalkState(_pulse);
						break;
					case UnitStates.SHOOT:
						
						handleShootState(_pulse);
						break;
					case UnitStates.WALK_ERROR:
						handleWalkError(_pulse);
						break;
					case UnitStates.DIE:
						handleDeath(_pulse);
						break;
				}
			}
			else
			{
				handleDeath(_pulse);
			}
		}
		
		public function resetRowCol():void
		{
			if (view.recoilAnimating)
			{
				return;
			}

			
			clearTile(model.row, model.col);
			occupyTile( int(view.y + (Parameters.tileSize/2)) / Parameters.tileSize ,  int(view.x + (Parameters.tileSize/2)) / Parameters.tileSize );
			
		}
		
		
		
		protected function handleWalkError(pulse:Boolean):void 
		{
			var backToRow:int =  UnitModel(model).row;
			var backToCol:int = UnitModel(model).col;
			if (UnitModel(model).path && UnitModel(model).path.length )
			{
				
				finalNodeAfterError = UnitModel(model).path[UnitModel(model).path.length-1]
				
				
				if (UnitModel(model).inWayPoint)
				{
					
				}
				else
				{
					
					//go back one step
					backToRow = UnitModel(model).path[UnitModel(model).moveCounter].row;
					backToCol = UnitModel(model).path[UnitModel(model).moveCounter].col;
					
					var n:Node = Parameters.boardArr[backToRow][backToCol];
				
					UnitModel(model).moveCounter = 0;
					handlingError = true;
					if (n.occupyingUnit == null)
					{
						getWalkPath(backToRow, backToCol);
					}
					else
					{
						//var placementsArr:Array = SpiralBuilder.getSpiral(backToRow, backToCol, 1);
						getWalkPath(backToRow, backToCol);
					}
					
					if (UnitModel(model).path && UnitModel(model).path.length)
					{
						backToRow = UnitModel(model).path[UnitModel(model).moveCounter].row;
						backToCol = UnitModel(model).path[UnitModel(model).moveCounter].col;
					}
					
					
					
					UnitView(view).run();

					addEventListener("WAYPOINT_REACHED", onWayPointReachedFromError);
					//trace("TRYING TO HANDLE ERROR")
				}
				
				
				
				
				setState(UnitStates.WALK);
			}

		}
	
		
		private function onWayPointReachedFromError(e:Event):void 
		{
			//trace("REACHED WAYPOINT ERROR")
			removeEventListener("WAYPOINT_REACHED", onWayPointReachedFromError);
			handlingError = false;
			if (finalNodeAfterError)
			{
				//trace("MOVING TO NEW DEST")
				UnitModel(model).moveCounter = 0;
				//var placementsArr:Array = SpiralBuilder.getSpiral(finalNodeAfterError.row, finalNodeAfterError.col, 1);
				getWalkPath(finalNodeAfterError.row, finalNodeAfterError.col);
				setState(UnitStates.WALK);
			}
		}
		
		
		
		protected function handleShootState(_pulse:Boolean):void
		{
			stopMovingAndSplicePath();
		}
		
		protected function handleWalkState(_pulse:Boolean):void
		{
			if(view is FullCircleView)
			{
				if(UnitModel(model).rotating)
				{
					return;
				}
			}
			
			walk();
		}
		
		protected function handleIdleState(_pulse:Boolean):void
		{
			//resetRowCol();
			stopMovingAndSplicePath();
			UnitView(view).stand();
			traceMe("handleIdleState");
			
		}
		
		
		protected function handleDeath(_pulse:Boolean):void
		{
			if (model)
			{
				model.dead = true;
				UnitModel(model).moving = false;
			}
			
			stopMovingAndSplicePath();
			if (view)
			{
				UnitView(view).dir = "";
				playDeathSound();
			}
		}
		
		public function playDeathSound():void
		{
			var vol:Number = 1;
			if (!Methods.isOnScreen(model.row, model.col))
			{
				vol = 0.1;
			}
			
			if (this is Infantry)
			{
				GameSounds.playSound("infantry-die", null, vol)
			}
			if (this is Vehicle)
			{
				GameSounds.playSound("vehicle-die", null, vol)
			}
			
			
		}
		
		
		
		protected function doNothing():void
		{
			UnitModel(model).shootCount = 0;
			UnitView(view).stopShootingAndStandIdlly();
			setState(UnitStates.IDLE);
		}
		
		override public function end():void
		{
			stopMovingAndSplicePath();
			doNothing();
		}

		override public function onDestinationReceived(targetRow:int, targetCol:int, _first:Boolean = true):void
		{
			////trace"override walk to dest!!!");
			//removeAllTiles();
			removeEventListener("WAYPOINT_REACHED", onWayPointReachedFromError);
			handlingError = false;
			
			if(model.isSelected)
			{
				//a unit which has been shot will go after it's attacker and it's up to us to get it back in line
				if(model.controllingAgent == Agent.HUMAN)
				{
					if (aiBehaviour == AiBehaviours.SEEK_AND_DESTROY)
					{
						aiBehaviour = AiBehaviours.SELF_DEFENSE;
					}
					
				}
				
				view.traceView("onDestinationReceived");
				if(_first)playOrderSound();
				
				userPathReached = false;
				userDeterminedRow = targetRow;
				userDeterminedCol = targetCol;
				
				
				if (UnitModel(model).inWayPoint)
				{
					if(model.controllingAgent == Agent.HUMAN)
					{
						stopMovingAndSplicePath();
						UnitView(view).shootAnimPlaying = false;
						resetRowCol()
						getWalkPath(targetRow, targetCol);
						setState(UnitStates.WALK);
					}
					else 
					{
						stopMovingAndSplicePath();
						getWalkPath(targetRow, targetCol);
						setState(UnitStates.WALK);
					}
					
				}
				else
				{
					addEventListener("WAYPOINT_REACHED", onWayPointReached);
				}
			}
		}
		
		private function onWayPointReached(e:Event):void 
		{
			removeEventListener("WAYPOINT_REACHED", onWayPointReached);
			stopMovingAndSplicePath();
			getWalkPath(userDeterminedRow, userDeterminedCol);
			setState(UnitStates.WALK);
		}
		
		private function playOrderSound():void
		{
			if (model.controllingAgent == Agent.HUMAN)
			{
				if (this is Infantry)
				{
					GameSounds.playSound("infantry-move")
				}
				if (this is Vehicle)
				{
					GameSounds.playSound("vehicle-move")
				}
			}
		}
		
		protected function onDoneRotating(e:Event):void 
		{
			view.removeEventListener("DONE_ROTATING", onDoneRotating);
			
			if (model.currentState == UnitStates.WALK)
			{
				stopMovingAndSplicePath();
				getWalkPath(userDeterminedRow, userDeterminedCol);
			}
		}
		
		protected function lookAround():void{}		
		
		
		public function getWalkPath(targetRow:int, targetCol:int):void 
		{
			var _row:int = UnitModel(model).row;
			var _col:int = UnitModel(model).col;
			var n:Node;
			if(aStar == null)return;
			
			if(Parameters.boardArr == null)return;
			if(Parameters.boardArr[_row] == undefined ||  Parameters.boardArr[_row] == null)return;
			if(Parameters.boardArr[_row][_col] == undefined ||  Parameters.boardArr[_row][_col] == null)return;
			
			if(Parameters.boardArr[targetRow] == undefined ||  Parameters.boardArr[targetRow] == null)return;
			if (Parameters.boardArr[targetRow][targetCol] == undefined ||  Parameters.boardArr[targetRow][targetCol] == null) return;
			
			var allBlocked:Boolean = true;
			
			outer : for (var i:int = -1; i <= 1; i++ )
			{
				for (var j:int = -1; j <= 1; j++ )
				{
					if (i == 0 && j == 0 )
					{
						continue;
					}
					
					if (Parameters.boardArr[_row + i] && Parameters.boardArr[_row + i][_col + j])
					{
						n = Node(Parameters.boardArr[_row + i][_col + j]);
						if (n.walkable && n.occupyingUnit == null)
						{
							allBlocked = false;
							break outer;
						}
					}
				}
			}
			
			if (allBlocked)
			{
				setState(UnitStates.IDLE);
				return;
			}
			
			
			UnitModel(model).path = aStar.getPath( Parameters.boardArr[_row][_col], Parameters.boardArr[targetRow][targetCol], uniqueID);
			//after we get the path, we can return the tiles so that others wont come too close to me.
			if (PathTest.showPath)
			{
				PathTest.createSelectedPath(UnitModel(model).path);
			}


			UnitModel(model).moveCounter = 0;
			UnitModel(model).moving = true;
			UnitModel(model).inWayPoint = true;
			
		}
		
		
		public function stopMovingAndSplicePath(_startShooting:Boolean = false):void
		{
			if (model == null) return;
			if (UnitModel(model).path && UnitModel(model).path.length)
			{
				UnitModel(model).path.splice(0);
			}
			
			UnitModel(model).moving = false;
			UnitModel(model).inWayPoint = true;
			UnitModel(model).moveCounter = 0;
			UnitModel(model).destX = model.col * Parameters.tileSize;
			UnitModel(model).destY = model.row * Parameters.tileSize;

		}
		
		
		private function walk():void
		{
			//traceMe( " walk, moving: " + UnitModel(model).moving + " model.inWayPoint " + UnitModel(model).inWayPoint);
			
			if(!UnitModel(model).moving)
			{
				UnitModel(model).moving = true;
				
				if(model.isSelected && !userPathReached)
				{
					getWalkPath(userDeterminedRow, userDeterminedCol);
					return;
				}
				
				lookAround();
			}
			else
			{
				if(UnitModel(model).inWayPoint)
				{
					calculateNextStep();
				}
				else
				{
					travel();
				}
			}
		}
		
		private function calculateNextStep():void
		{
			traceMe( " calculateNextStep: moveCounter - > " + UnitModel(model).moveCounter + " path.length: " + UnitModel(model).path.length);
			var n:Node;
			
			resetRowCol();
			
			var lastStep:Boolean = false;
			
			if (UnitModel(model).moveCounter < UnitModel(model).path.length-1)
			{
				if(Parameters.DEBUG_MODE)view.drawRange(UnitModel(model).prevRow, UnitModel(model).prevCol, UnitModel(model).row, UnitModel(model).col);

				UnitView(view).run();
				//in case this is a rotating unit we need to make sure the path is still valid after rotation is done
				//this should ONLY happen with USER SELECTED UNITS!
				if (view is FullCircleView)
				{
					if (UnitModel(model).rotating)
					{
						view.addEventListener("DONE_ROTATING", onDoneRotating);
					}
					
				}
				traceMe("run");
				
				
				var nextNodeWalkable:Boolean = true;
				
				if (UnitModel(model).path[UnitModel(model).moveCounter])
				{
					UnitModel(model).prevRow = UnitModel(model).row;
					UnitModel(model).prevCol = UnitModel(model).col;
					
					var nexRow:int;
					var nexCol:int; 
					
					if(UnitModel(model).path[UnitModel(model).moveCounter+1] != undefined)
					{
						nexRow = UnitModel(model).path[UnitModel(model).moveCounter+1].row;
						nexCol = UnitModel(model).path[UnitModel(model).moveCounter + 1].col;
						
						
						n = Node(Parameters.boardArr[nexRow][nexCol]);
						
						if(n.occupyingUnit != null ||n.walkable == false )
						{
							nextNodeWalkable = false;
						}
					}
				}
				else
				{
					nextNodeWalkable = false;
				}
				

				if(nextNodeWalkable)
				{
					UnitModel(model).destX = nexCol * Parameters.tileSize;
					UnitModel(model).destY = nexRow * Parameters.tileSize;
					UnitModel(model).inWayPoint = false;
				}
				else
				{
					/*var destNode:Node = UnitModel(model).path[UnitModel(model).path.length-1];
					UnitView(view).stopShootingAndStandIdlly();
					stopMovingAndSplicePath();
					getWalkPath(destNode.row, destNode.col);
					setState(UnitStates.WALK);*/
				}
			}
			else
			{
				lastStep = true;
			}
			
			if(lastStep)
			{
				if(Parameters.DEBUG_MODE)view.drawRange(UnitModel(model).prevRow, UnitModel(model).prevCol, UnitModel(model).row, UnitModel(model).col);

				
				if(UnitModel(model).isSelected)
				{
					userPathReached = true;
					traceMe( " finished walking - > IDLE");
				}
				UnitModel(model).inWayPoint = true;
				UnitView(view).stopShootingAndStandIdlly();
				stopMovingAndSplicePath();
				//clearTile(model.row, model.col);
				//occupyTile(  int(view.y / Parameters.tileSize) , int(view.x / Parameters.tileSize) );
				dispatchEvent(WAYPOINT_REACHED_EVENT);
				setState(UnitStates.IDLE);
			}
			//update to next node!
			UnitModel(model).moveCounter++;
		}
		
		
		
		private var errorCount:int = 0;
		
		protected function travel():void 
		{
			if(!UnitModel(model).inWayPoint)
			{
				var path:Array = UnitModel(model).path;
				var currNode:Node = path[UnitModel(model).moveCounter];
				
				if (currNode.occupyingUnit != null && currNode.occupyingUnit != this && handlingError == false)
				{
					if (errorCount < 20)
					{
						errorCount++;
						UnitView(view).stopShootingAndStandIdlly();
					}
					else
					{
						errorCount = 0;
						setState(UnitStates.WALK_ERROR);
					}

					return;
				}
				else
				{
					UnitView(view).runIfNoAready()
				}
				
				
				var dx:Number = UnitModel(model).destX - view.x;
				var dy:Number = UnitModel(model).destY - view.y;
				var angle:Number = Math.atan2(dy, dx);
				var speed:Number = UnitModel(model).stats.speed;
				
				if (speed <= 0)
				{
					speed = .1;
				}
					
				var vx:Number = Math.cos(angle) * speed;
				var vy:Number = Math.sin(angle) * speed;
				view.x += vx;
				view.y += vy;
				
				var distX:Number = Math.abs(UnitModel(model).destX - view.x);
				var distY:Number = Math.abs(UnitModel(model).destY - view.y);
				
					
				if(distX < speed &&distY < speed )
				{
					clearTile(model.row, model.col);
					occupyTile(  currNode.row , currNode.col );
					
					if (!inFirstNodeOfPath())
					{
						view.x = UnitModel(model).destX;
						view.y = UnitModel(model).destY;
						
					}
					
					UnitModel(model).inWayPoint = true;
					dispatchEvent(WAYPOINT_REACHED_EVENT);
					
				}
			}
		}
		
		private function inFirstNodeOfPath():Boolean 
		{
			var inFirstNodeOfPath:Boolean = false;
			var firstNode:Node = UnitModel(model).path[0];
			if (model.row == firstNode.row && model.col == firstNode.col)
			{
				inFirstNodeOfPath = true;
			}
			return inFirstNodeOfPath
		}
		
		private var prevMsg:String = "";

		protected function traceMe(msg:String):void
		{
			return;
			
		}
		

		private function getCurrentState(_currentState:int):String
		{
			var str:String;
			
			switch(_currentState)
			{
				case UnitStates.IDLE:
					str = "IDLE";
					break;
				case UnitStates.WALK:
					str = "WALK";
					break;
				case UnitStates.SHOOT:
					str = "SHOOT";
					break;
				case UnitStates.DIE:
					str = "DIE";
					break;
			}
			
			return str;
		}	
		
		override public function dispose():void
		{
			removeEventListener("WAYPOINT_REACHED", onWayPointReachedFromError);
			if (view)
			{
				view.removeEventListener("DONE_ROTATING", onDoneRotating);
			}
			aStar = null;
			finalNodeAfterError = null;
			super.dispose();
		}
	}
}