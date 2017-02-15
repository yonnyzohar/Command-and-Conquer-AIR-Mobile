package states.game.entities.units 
{
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
		
		
		public function Unit(_unitStats:AssetStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int) 
		{
			name = _unitStats.name;
			super(teamObj);
			model = new UnitModel();
			model.teamName = teamObj.teamName;
			UnitModel(model).stats = _unitStats;
			teamNum = myTeam;
			model.enemyTeam = _enemyTeam;
			
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
		

		public function update(_pulse:Boolean):void
		{
			if(model != null && model.dead == false)
			{
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
		
		protected function resetRowCol():void
		{
			if (view.recoilAnimating)
			{
				return;
			}
			//clearTile(model.prevRow, model.prevCol);
			//occupyTile(model.row, model.col);
			
			clearTile(model.row, model.col);
			occupyTile( int(view.y + (Parameters.tileSize/2)) / Parameters.tileSize ,  int(view.x + (Parameters.tileSize/2)) / Parameters.tileSize );
			
		}
		
		protected function handleWalkError(pulse:Boolean):void 
		{
			var model:UnitModel = UnitModel(model);
			var backToRow:int =  model.row;
			var backToCol:int = model.col;
			if (model.path && model.path.length )
			{
				
				finalNodeAfterError = model.path[model.path.length-1]
				
				
				if (UnitModel(model).inWayPoint)
				{
					
				}
				else
				{
					
					//go back one step
					backToRow = model.path[model.moveCounter].row;
					backToCol = model.path[model.moveCounter].col;
					
					var n:Node = Parameters.boardArr[backToRow][backToCol];
				
					model.moveCounter = 0;
					handlingError = true;
					if (n.occupyingUnit == null)
					{
						getWalkPath(backToRow, backToCol);
					}
					else
					{
						var placementsArr:Array = SpiralBuilder.getSpiral(backToRow, backToCol, 1);
						getWalkPath(placementsArr[0].row, placementsArr[0].col);
					}
					
					backToRow = model.path[model.moveCounter].row;
					backToCol = model.path[model.moveCounter].col;
					
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
			var model:UnitModel = UnitModel(model);
			removeEventListener("WAYPOINT_REACHED", onWayPointReachedFromError);
			handlingError = false;
			if (finalNodeAfterError)
			{
				//trace("MOVING TO NEW DEST")
				model.moveCounter = 0;
				var placementsArr:Array = SpiralBuilder.getSpiral(finalNodeAfterError.row, finalNodeAfterError.col, 1);
				getWalkPath(placementsArr[0].row, placementsArr[0].col);
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
				//trace(model.stats.name + " " + this.model.teamName + " is dead!")
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
			if (this is Infantry)
			{
				GameSounds.playSound("infantry-die")
			}
			if (this is Vehicle)
			{
				GameSounds.playSound("vehicle-die")
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
			removeAllTiles();
			removeEventListener("WAYPOINT_REACHED", onWayPointReachedFromError);
			handlingError = false;
			
			if(model.isSelected)
			{
				view.traceView("onDestinationReceived");
				if(_first)playOrderSound();
				
				userPathReached = false;
				userDeterminedRow = targetRow;
				userDeterminedCol = targetCol;
				
				if (UnitModel(model).inWayPoint)
				{
					stopMovingAndSplicePath();
					getWalkPath(targetRow, targetCol);
					setState(UnitStates.WALK);
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
			var model:UnitModel = UnitModel(model);
			
			if(aStar == null)return;
			
			if(Parameters.boardArr == null)return;
			if(Parameters.boardArr[model.row] == undefined ||  Parameters.boardArr[model.row] == null)return;
			if(Parameters.boardArr[model.row][model.col] == undefined ||  Parameters.boardArr[model.row][model.col] == null)return;
			
			if(Parameters.boardArr == null)return;
			if(Parameters.boardArr[targetRow] == undefined ||  Parameters.boardArr[targetRow] == null)return;
			if(Parameters.boardArr[targetRow][targetCol] == undefined ||  Parameters.boardArr[targetRow][targetCol] == null)return;
			
			
			model.path = aStar.getPath( Parameters.boardArr[model.row][model.col], Parameters.boardArr[targetRow][targetCol], uniqueID);
			//after we get the path, we can return the tiles so that others wont come too close to me.
			if(PathTest.showPath)PathTest.createSelectedPath(model.path);


			model.moveCounter = 0;
			model.moving = true;
			model.inWayPoint = true;
			
		}
		
		
		protected function stopMovingAndSplicePath(_startShooting:Boolean = false):void
		{
			if (model == null) return;
			UnitModel(model).path.splice(0);
			UnitModel(model).moving = false;
			UnitModel(model).inWayPoint = true;
			UnitModel(model).moveCounter = 0;
			//resetRowCol();
			if (_startShooting)
			{
				removeAllTiles();
			}
		}
		
		
		private function walk():void
		{
			traceMe( " walk, moving: " + UnitModel(model).moving + " model.inWayPoint " + UnitModel(model).inWayPoint);
			
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
			var model:UnitModel = UnitModel(model);
			traceMe( " calculateNextStep: moveCounter - > " + model.moveCounter + " path.length: " + model.path.length);
			var n:Node;
			
			resetRowCol();
			
			var lastStep:Boolean = false;
			
			if (model.moveCounter < model.path.length-1)
			{
				if(Parameters.DEBUG_MODE)view.drawRange(model.prevRow, model.prevCol, model.row, model.col);

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
				
				if (model.path[model.moveCounter])
				{
					model.prevRow = model.row;
					model.prevCol = model.col;
					
					var nexRow:int;
					var nexCol:int; 
					
					if(model.path[model.moveCounter+1] != undefined)
					{
						nexRow = model.path[model.moveCounter+1].row;
						nexCol = model.path[model.moveCounter + 1].col;
						
						
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
					model.destX = nexCol * Parameters.tileSize;
					model.destY = nexRow * Parameters.tileSize;
					model.inWayPoint = false;
				}
				else
				{
					/*var destNode:Node = model.path[model.path.length-1];
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
				if(Parameters.DEBUG_MODE)view.drawRange(model.prevRow, model.prevCol, model.row, model.col);

				
				if(model.isSelected)
				{
					userPathReached = true;
					traceMe( " finished walking - > IDLE");
				}
				UnitModel(model).inWayPoint = true;
				UnitView(view).stopShootingAndStandIdlly();
				stopMovingAndSplicePath();
				//clearTile(model.row, model.col);
				//occupyTile(  int(view.y / Parameters.tileSize) , int(view.x / Parameters.tileSize) );
				dispatchEvent(new Event("WAYPOINT_REACHED"));
				setState(UnitStates.IDLE);
			}
			//update to next node!
			model.moveCounter++;
		}
		
		
		
		
		
		protected function travel():void 
		{
			var model:UnitModel = UnitModel(model);
			if(!model.inWayPoint)
			{
				var path:Array = UnitModel(model).path;
				var currNode:Node = path[model.moveCounter];
				
				if (currNode.occupyingUnit != null && currNode.occupyingUnit != this && handlingError == false)
				{
					//trace("found the bug in time!!");
					setState(UnitStates.WALK_ERROR);
					return;
				}
				
				
				var dx:Number = model.destX - view.x;
				var dy:Number = model.destY - view.y;
				var angle:Number = Math.atan2(dy, dx);
				var speed:Number = model.stats.speed;
				
				if (speed <= 0)
				{
					speed = .1;
				}
					
				var vx:Number = Math.cos(angle) * speed;
				var vy:Number = Math.sin(angle) * speed;
				view.x += vx;
				view.y += vy;
				
				var distX:Number = Math.abs(model.destX - view.x);
				var distY:Number = Math.abs(model.destY - view.y);
				
					
				if(distX < speed &&distY < speed )
				{
					clearTile(model.row, model.col);
					occupyTile(  currNode.row , currNode.col );
					
					if (!inFirstNodeOfPath())
					{
						//trace( "inWayPoint");

						view.x = model.destX;
						view.y = model.destY;
						
					}
					else
					{
						//trace("bug!")
					}
					
					model.inWayPoint = true;
					dispatchEvent(new Event("WAYPOINT_REACHED"));
					
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
			if(model == null)return;
			if(model.controllingAgent == Agent.HUMAN)
			{
				if(model.isSelected)
				{
					var myMessage:String = "team: " + model.teamName + " state : " +  getCurrentState(currentState) + " msg : " + msg + " / row " + model.row + " , col " + model.col;
					if (prevMsg != myMessage)
					{
						////trace(myMessage);
						prevMsg = myMessage;
					}
					
				}
			}
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
			aStar = null;
			super.dispose();
		}
	}
}