package states.game.entities.units 
{
	import global.GameSounds;
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
		
		
	
		
		protected function resetRowCol():void
		{
			clearTile(model.row, model.col);
			model.row = int((view.y ) / Parameters.tileSize);
			model.col = int((view.x ) / Parameters.tileSize);
			occupyTile(model.row, model.col);
		}
		
		public function update(_pulse:Boolean):void
		{
			if(model != null && model.dead == false)
			{
				
				resetRowCol();
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
			stopMovingAndSplicePath();
			UnitView(view).stand();
			traceMe("handleIdleState");
			
		}
		
		
		protected function handleDeath(_pulse:Boolean):void
		{
			if (model)
			{
				trace(model.stats.name + " " + this.model.teamName + " is dead!")
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

		override public function walkToDestination(targetRow:int, targetCol:int, _first:Boolean = true):void
		{
			////trace"override walk to dest!!!");
			removeAllTiles();
			if(model.isSelected)
			{
				view.traceView("walkToDestination");
				if(_first)playOrderSound();
				
				userPathReached = false;
				userDeterminedRow = targetRow;
				userDeterminedCol = targetCol;
				
				stopMovingAndSplicePath();
				
				getWalkPath(targetRow, targetCol);
				setState(UnitStates.WALK);
			}
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
		
		
		
		protected function lookAround():void{}		
		
		
		public function getWalkPath(targetRow:int, targetCol:int):void 
		{
			//traceMe( "getWalkPath aStar: " + aStar + " targetRow: " + targetRow + " targetCol: " + targetCol);
			
			if(aStar == null)return;
			
			if(Parameters.boardArr == null)return;
			if(Parameters.boardArr[model.row] == undefined ||  Parameters.boardArr[model.row] == null)return;
			if(Parameters.boardArr[model.row][model.col] == undefined ||  Parameters.boardArr[model.row][model.col] == null)return;
			
			if(Parameters.boardArr == null)return;
			if(Parameters.boardArr[targetRow] == undefined ||  Parameters.boardArr[targetRow] == null)return;
			if(Parameters.boardArr[targetRow][targetCol] == undefined ||  Parameters.boardArr[targetRow][targetCol] == null)return;
			
			
			//i'm surrounded by tiles that cannot be steeped on, i need to clear them in order to be able to move!
			//clearTile(model.prevRow, model.prevCol);
			//clearTile(model.row, model.col);
			
			UnitModel(model).path = aStar.getPath( Parameters.boardArr[model.row][model.col], Parameters.boardArr[targetRow][targetCol], uniqueID);
			//after we get the path, we can return the tiles so that others wont come too close to me.
			if(PathTest.showPath)PathTest.createSelectedPath(UnitModel(model).path);

			
			traceMe(" onPathFound");
			UnitModel(model).moveCounter = 0;
			UnitModel(model).moving = true;
			UnitModel(model).inWayPoint = true;
			
		}
		
		var oldVersion:Boolean = true;
		
		protected function stopMovingAndSplicePath(_startShooting:Boolean = false):void
		{
			if (model == null) return;
			UnitModel(model).path.splice(0);
			UnitModel(model).moving = false;
			UnitModel(model).inWayPoint = true;
			UnitModel(model).moveCounter = 0;
			
			if (_startShooting)
			{
				removeAllTiles();
				/*var row:int = view.y / Parameters.tileSize;
				var col:int = view.x / Parameters.tileSize;
				model.row = row;
				model.col = col;
				occupyTile(row, col);*/
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
			
			var lastStep:Boolean = false;
			
			if (model.moveCounter < model.path.length)
			{
				if(Parameters.DEBUG_MODE)view.drawRange(model.prevRow, model.prevCol, model.row, model.col);

				UnitView(view).run();
				traceMe("run");
				
				
				var nextNodeWalkable:Boolean = true;
				
				if (model.path[model.moveCounter])
				{
					model.prevRow = model.row;
					model.prevCol = model.col;
					
					model.row = model.path[model.moveCounter].row;//this starts at 0
					model.col = model.path[model.moveCounter].col;
					var nexRow:int;
					var nexCol:int; 
					
					if(model.path[model.moveCounter+1] != undefined)
					{
						nexRow = model.path[model.moveCounter+1].row;
						nexCol = model.path[model.moveCounter+1].col;
						
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
					
					model.destX = model.col * Parameters.tileSize; //model.col
					model.destY = model.row * Parameters.tileSize; //model.row
					model.inWayPoint = false;
				}
				else
				{
					
					
					
					var destNode:Node = model.path[model.path.length -1];
					UnitView(view).stopShootingAndStandIdlly();
					stopMovingAndSplicePath();
					getWalkPath(destNode.row, destNode.col);
					//currentState = UnitStates.IDLE;
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
				UnitView(view).stopShootingAndStandIdlly();
				stopMovingAndSplicePath();
				setState(UnitStates.IDLE);
			}
			//update to next node!
			model.moveCounter++;
		}
		
		
		
		
		
		protected function travel():void 
		{
			if(!UnitModel(model).inWayPoint)
			{
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
				
					
				if(distX < speed &&distY < speed)
				{
					traceMe( "inWayPoint");
					clearTile(model.prevRow, model.prevCol);
					clearTile(model.row, model.col);	
					view.x = UnitModel(model).destX;
					view.y = UnitModel(model).destY;
					UnitModel(model).inWayPoint = true;
				}
			}
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
						//trace(myMessage);
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