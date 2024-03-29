package states.game.entities
{
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.enums.AiBehaviours;
	import global.map.mapTypes.Board;
	import global.Parameters;
	import global.enums.Agent;
	import global.enums.UnitStates;
	import global.map.Node;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import states.game.entities.units.Harvester;
	import states.game.entities.units.Unit;
	import states.game.teamsData.TeamObject;
	
	import starling.events.EventDispatcher;
	

	public class GameEntity extends EventDispatcher
	{
		public var distanceFromTarget:int;
		public var healthBar:HealthBar ;
		public var uniqueID:int;
		public static var GLOBAL_UNIQUE_ID:int = 0;
		public var model:EntityModel;
		public var view:EntityView;
		private var q:Quad;
		
		public var teamNum:int;
		
		public var myTeamObj:TeamObject;
		protected var currentInfantryDeath:String;
		
		private var showOccupyTiles:Boolean = false;
		
		private var allTilesDict:Dictionary = new Dictionary();
		public var aiBehaviour:int;
		public var name:String;
		private var myColor:uint; 
		public var ENTITY_BEING_REPAIRED:Boolean = false;
		public var underAttack:Boolean = false;
		
		public function GameEntity(_teamObj:TeamObject)
		{
			myTeamObj = _teamObj;
			
			
			uniqueID = GLOBAL_UNIQUE_ID;
			GLOBAL_UNIQUE_ID++;
			aiBehaviour = myTeamObj.ai;
			myColor = Math.random() * 0xFFFFFF;
			//trace"uniqueID: " + uniqueID);
		}
		
		public function changeAI(_newAi:int):void
		{
			aiBehaviour = _newAi;
		}
		
		public function getHealth():int
		{
			return model.totalHealth;
		}
		
		public function setHealth(health:int):void 
		{
			var helathDelta:int = (model.totalHealth - health);
			trace(model.totalHealth, health);
			model.totalHealth = health;
			healthBar.hurt(helathDelta);
		}
		
		
		
		public function sayHello():void 
		{
			
		}
		
		public function get row():int
		{
			if (model)
			{
				return model.row;
			}
			else
			{
				return 0;
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
					if (this.model.controllingAgent == Agent.HUMAN  )
					{
						n.seen = true;
					}
					
					if (n.seen == false)
					{
						this.view.visible = false;
					}
					else
					{
						this.view.visible = true;
					}
					model.row = proposedRow;
					model.col = proposedCol;	
					
					//showTile(proposedRow, proposedCol , n)
					
				}
				else
				{
					if (n.occupyingUnit != this)
					{
						//trace("TILE ALREADY OCCUPIED " + uniqueID);
						//setState(UnitStates.WALK_ERROR)
					}
				}
			}
		}
		

		
		private function showTile(proposedRow:int, proposedCol:int, n:Node):void 
		{
			if (q == null)
			{
				q = new Quad(Parameters.tileSize, Parameters.tileSize, myColor);
			}
			
			
			q.x = Parameters.tileSize * proposedCol;
			q.y = Parameters.tileSize * proposedRow;
			q.touchable = false;
			q.alpha = 0.2;
			Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(q);
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

		public function placeUnit(_startRow:int, _startCol:int, fromSavedGame:Boolean = false):void
		{
			model.row = _startRow;
			model.col = _startCol;
			
			model.prevRow = _startRow;
			model.prevCol = _startCol;
			
			view.y = model.row * Parameters.tileSize;
			view.x = model.col * Parameters.tileSize;
			view.visible = false;
			occupyTile(model.row, model.col);
		}
		
		
		public function update(_pulse:Boolean):void
		{
			if (model != null && model.dead == false)
			{
				if (ENTITY_BEING_REPAIRED)
				{
					var moreTHanZero:Boolean = myTeamObj.reduceCash(1);
					if (moreTHanZero)
					{
						model.totalHealth += 1;
						var healthScale:Number = healthBar.hurt(-1);
						view.setViewByHealth(healthScale);
						
						if (healthScale >= 1)
						{
							ENTITY_BEING_REPAIRED = false;
						}
					}
					else
					{
						ENTITY_BEING_REPAIRED = false;
					}
					
				}
			}
			else
			{
				ENTITY_BEING_REPAIRED = false;
			}
		}

		
		public function hurt(_hitVal:int, _currentInfantryDeath:String, projectileName:String = null ):Boolean
		{
			currentInfantryDeath = _currentInfantryDeath;
			
			var dead:Boolean = false;
			if(model != null)
			{
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
					underAttack = true;
					view.setViewByHealth(healthScale);
					healthBar.visible = true;
					view.addChild(healthBar);
				}
			}
			else
			{
				dead = true;
				if(healthBar)healthBar.visible = false;
				setState(UnitStates.DIE);
			}
			
			return dead;
		}
		
		
		
		public function setState(state:int):void
		{
			if (model.currentState != state)
			{
				model.lastState = model.currentState;
				model.currentState = state;
			}
			
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
			if(model && model.controllingAgent == Agent.HUMAN)
			{
				healthBar.visible  =false;
				model.isSelected = false;
			}
			
		}
		
		public function dispose():void
		{
			if (healthBar)
			{
				healthBar.removeFromParent(true);
			}
			
			healthBar = null;
			
			
			if (view)
			{
				view.dispose();
			}
			
			view = null;
			
			if (model)
			{
				clearTile(model.prevRow, model.prevCol);
				clearTile(model.row, model.col);
				model.dead = true;
				model.dispose();
			}
			
			
			model = null;
			myTeamObj = null;
			allTilesDict = null;
			
			if (q != null)
			{
				q.removeFromParent(true);
				q = null;
			}
		}
		
		public function end():void{}
		
		public function onDestinationReceived(targetRow:int, targetCol:int,_first:Boolean = true):void{}
		
		public function addMeToBoard(container:Sprite):void 
		{
			container.addChild(view);
		}
	}
}