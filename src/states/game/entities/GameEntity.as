package states.game.entities
{
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.Parameters;
	import global.enums.Agent;
	import global.enums.UnitStates;
	import global.map.Node;
	import starling.display.Quad;
	import states.game.teamsData.TeamObject;
	
	import starling.events.EventDispatcher;
	

	public class GameEntity extends EventDispatcher
	{
		public var distanceFromTarget:int;
		protected var healthBar:HealthBar ;
		public var uniqueID:int;
		public static var GLOBAL_UNIQUE_ID:int = 0;
		public var model:EntityModel;
		public var view:EntityView;
		
		public var teamNum:int;
		public var myTeamObj:TeamObject;
		protected var currentInfantryDeath:String;
		
		private var showOccupyTiles:Boolean = false;
		
		private var allTilesDict:Dictionary = new Dictionary();
		protected var aiBehaviour:int;
		
		public function GameEntity(_teamObj:TeamObject)
		{
			myTeamObj = _teamObj;
			
			uniqueID = GLOBAL_UNIQUE_ID;
			GLOBAL_UNIQUE_ID++;
			aiBehaviour = myTeamObj.ai;
			//trace"uniqueID: " + uniqueID);
		}
		
		public function sayHello():void 
		{
			
		}
		

		
		protected function removeAllTiles():void 
		{
			for (var k:String in allTilesDict)
			{
				var o:Object = allTilesDict[k];
				if(showOccupyTiles)o.quad.removeFromParent(true);
				o.node.occupyingUnit = null;
				allTilesDict[k] = null;
				delete allTilesDict[k];
			}
		}
		
		protected function clearTile(proposedRow:int, proposedCol:int):void
		{
			var n:Node;
			
			if(nodeExists(proposedRow, proposedCol))
			{
				n = Node(Parameters.boardArr[proposedRow][proposedCol]);
				if (n.occupyingUnit == this )
				{
					hideTile(proposedRow, proposedCol)
					n.occupyingUnit = null;
				}
			}
		}
		
		protected function occupyTile(proposedRow:int, proposedCol:int):void
		{
			var n:Node;
			
			if(nodeExists(proposedRow, proposedCol))
			{
				n = Node( Parameters.boardArr[proposedRow][proposedCol] );
				if (n.occupyingUnit == null)
				{
					n.occupyingUnit = this;
					if (this.model.controllingAgent == Agent.PC  )
					{
						if (n.seen == false)
						{
							this.view.visible = false;
						}
						else
						{
							this.view.visible = true;
						}
						
					}
					showTile(proposedRow, proposedCol , n)
					
				}
				else
				{
					if (n.occupyingUnit != this)
					{
						////trace("TILE ALREADY OCCUPIED")
					}
				}
			}
		}
		
		private function hideTile(proposedRow:int, proposedCol:int):void 
		{
			if(showOccupyTiles)allTilesDict[proposedRow + "_" + proposedCol].quad.removeFromParent(true);
			delete allTilesDict[proposedRow + "_" + proposedCol];
		}
		
		private function showTile(proposedRow:int, proposedCol:int, n:Node):void 
		{
			var q:Quad;
			if (showOccupyTiles)
			{
				q = new Quad(Parameters.tileSize, Parameters.tileSize);
				q.x = Parameters.tileSize * proposedCol;
				q.y = Parameters.tileSize * proposedRow;
				q.touchable = false;
				q.alpha = 0.1;
				Parameters.upperTilesLayer.addChild(q);
			}

			allTilesDict[proposedRow + "_" + proposedCol] = {quad : q, node : n};
			
		}
		
		protected function nodeExists(_row:int, _col:int):Boolean
		{
			if(_row < 0 || _col < 0)return false;
			if(Parameters.boardArr == null)return false;
			if(_row >  Parameters.boardArr.length)return false;
			if(Parameters.boardArr[_row] == undefined ||  Parameters.boardArr[_row] == null)return false;
			if(_col >  Parameters.boardArr[0].length)return false;
			if(Parameters.boardArr[_row][_col] == undefined ||  Parameters.boardArr[_row][_col] == null)return false;
			return true;
		}

		public function placeUnit(_startRow:int, _startCol:int):void
		{
			model.row = _startRow;
			model.col = _startCol;
			
			model.prevRow = _startRow;
			model.prevCol = _startCol;
			
			view.y = model.row * Parameters.tileSize;
			view.x = model.col * Parameters.tileSize;
			occupyTile(model.row, model.col);
		}
		

		
		public function hurt(_hitVal:int, _currentInfantryDeath:String, projectileName:String = null ):Boolean
		{
			currentInfantryDeath = _currentInfantryDeath;
			var dead:Boolean = false;
			if(model != null)
			{
				//trace"totalHealth: " + model.totalHealth + " _hitVal: " + _hitVal);
				model.totalHealth -= _hitVal;
				var healthScale:Number = healthBar.hurt(_hitVal);
				
				if(model.totalHealth < 0)
				{
					dead = true;
					healthBar.visible = false;
					setState(UnitStates.DIE);
				}
				else
				{
					view.setViewByHealth(healthScale);
					healthBar.visible = true;
					view.addChild(healthBar);
				}
			}
			
			return dead;
		}
		
		
		
		protected function setState(state:int):void
		{
			model.lastState = model.currentState;
			model.currentState = state;
		}
		
		public function hasBeenTouched(_row:int, _col:int):Boolean
		{
			if(model.row == _row && model.col == _col)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function selected(_firstMember:Boolean):void
		{
			if(model.controllingAgent == Agent.HUMAN)
			{
				view.addCircle(_firstMember);
				healthBar.visible  =true;
				model.isSelected = true;
			}
			
		}
		
		public function getSight():Array
		{
			var sightTiles:Array = [];
			if (model)
			{
				var weaponRange:int = 0;
				var sighRange:int = model.stats.sight;
				if (model.stats.weapon)
				{
					weaponRange = model.stats.weapon.range;
				}
				
				//(condition) ? ifTrueDoThis : ifFalseDoThis;
				var sight:int = (weaponRange > sighRange) ? weaponRange : sighRange;
				
				for (var row:int = model.row - sight; row <= model.row + sight; row++ )
				{
					for (var col:int = model.col - sight; col <= model.col + sight; col++ )
					{
						if (nodeExists(row, col))
						{
							sightTiles.push(Parameters.boardArr[row][col]);
						}
					}
				}
			}
			
			return sightTiles;
		}
		
		public function deselect():void
		{
			if(model.controllingAgent == Agent.HUMAN)
			{
				healthBar.visible  =false;
				model.isSelected = false;
			}
			
		}
		
		public function dispose():void
		{
			//trace"dispose game entity");
			healthBar.removeFromParent(true);
			healthBar = null;
			clearTile(model.prevRow, model.prevCol);
			clearTile(model.row, model.col);
			view.dispose();
			view = null;
			model.dead = true;
			model.dispose();
			model = null;
			
		}
		
		public function end():void{}
		
		public function walkToDestination(targetRow:int, targetCol:int):void{}
		
		
	}
}