package states.game.entities.buildings
{
	import com.greensock.TweenLite;
	import global.enums.Agent;
	import global.GameSounds;
	import global.Methods;
	import global.Parameters;
	import global.enums.UnitStates;
	import global.map.Node;
	import global.utilities.GlobalEventDispatcher;
	
	import starling.events.Event;
	
	import states.game.entities.GameEntity;
	import states.game.entities.HealthBar;
	import states.game.stats.BuildingsStatsObj;
	import states.game.teamsData.TeamObject;

	public class Building extends GameEntity
	{
		
		public var hasBuildingClickFunction:Boolean = false;
		private var buildingTiles:Array;
		private var sightTiles:Array;
		
		
		public function Building(_buildingStats:BuildingsStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int)
		{
			super(teamObj);
			teamNum = myTeam;
			name = _buildingStats.name;
			
			initModel();
			
			model.teamName = teamObj.teamName;
			model.enemyTeam = _enemyTeam;
			model.controllingAgent = teamObj.agent;
			BuildingModel(model).stats = _buildingStats;
			model.totalHealth = _buildingStats.totalHealth;
			initView();
			
			healthBar = new HealthBar(model.totalHealth, view.width);
			view.addHealthBar(healthBar);
			healthBar.visible = false;
		}
		
		public function skipBuild():void 
		{
			BuildingView(view).skipBuild();
		}
		

		override public function get row():int
		{
			if (model)
			{
				return model.row + BuildingsStatsObj(model.stats).gridShape.length;
			}
			else
			{
				return 0;
			}
			
		}
		
		protected function initModel():void 
		{
			model = new BuildingModel();
		}
		
		protected function initView():void 
		{
			view = new BuildingView(BuildingModel(model), BuildingModel(model).stats.name);
		}
		
		override public function sayHello():void 
		{
			if (model.controllingAgent == Agent.HUMAN)
			{
				GameSounds.playSound("BuildingCreate");
			}
			
		}
		
		
		
		override public function setState(state:int):void
		{
			super.setState(state);
			if(state == UnitStates.DIE)
			{
				
				if (!model.dead)
				{
					BuildingView(view).playExplosion();
					GameSounds.playSound("building_destroyed");
					dispatchEvent(new Event("DEAD"));
				}
				
				if (model)
				{
					model.dead = true;
				}
				
			}
		}
		
		private function onExplosionComplete(e:Event):void 
		{
			view.removeEventListener("EXPLOSION_COMPLETE", onExplosionComplete);
			
		}
		
		override public function getSight():Array
		{
			if (sightTiles == null)
			{
				if (model && model.stats.sight)
				{
					sightTiles = [];
					var sight:int = model.stats.sight;
					var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
					var occupyArrayLen:int = occupyArray.length + sight;
					var occuPyArrayLenZero:int = occupyArray[0].length;
					for(var i:int = -sight; i <=occupyArrayLen + sight; i++)
					{
						for (var j:int = -sight; j <= occuPyArrayLenZero + sight; j++ )
						{
							//i don't care about the building itself
							/*if (i >= 0 && i < occupyArray.length && j >= 0 && j < occupyArray[0].length )
							{
								continue;
							}*/
							
							if(nodeExists(model.row + j, model.col + i))
							{
								sightTiles.push(Parameters.boardArr[model.row + j][model.col + i]);
							}
						}
					}
				}
			}
			
			
			return sightTiles;
		}
		
		
		
		public function getBuildingTiles():Array
		{
			if (buildingTiles == null)
			{
				buildingTiles = [];
				var n:Node;
				var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
				var occupyArrayRowsLength:int = occupyArray.length;
				var occupyArrayColsLength:int = occupyArray[0].length;
				for(var i:int = 0; i < occupyArrayRowsLength; i++)
				{
					for (var j:int = 0; j < occupyArrayColsLength; j++ )
					{
						var curTile:int = occupyArray[i][j];
						
						if (curTile == 0) continue;//this is only for build indication
						n = Node( Parameters.boardArr[model.row + j][model.col + i] );
						buildingTiles.push(n);
					}
				}
			}
			
			
			return buildingTiles;
		}
		
		override public function hasBeenTouched(_row:int, _col:int):Boolean
		{
			var n:Node;
			var touched:Boolean = false;
			
			if(nodeExists(_row, _col))
			{
				n = Node( Parameters.boardArr[_row][_col] );
				
				if(n.occupyingUnit == this)
				{
					touched =  true;
				}
			}
			
			return touched;
		}
		
		override public function hurt(_hitVal:int, _currentInfantryDeath:String , projectileName:String = null):Boolean
		{
			/*if (Methods.assetIsOnScreen(model.row, model.col) && projectileName.indexOf("invisible") == -1 )
			{
				var origPosX:int = Parameters.gameHolder.x;
				var origPosY:int = Parameters.gameHolder.y;
				
				TweenLite.to(Parameters.gameHolder, 0.1, 
				{
					x:origPosX + (Math.random() /2), 
					y:origPosY + (Math.random() /2 ), 
					onComplete:function():void
					{
						TweenLite.to(Parameters.gameHolder, 0.1, 
						{ 
							x:origPosX - (Math.random() /2 ), 
							y: origPosY - (Math.random() /2 ), 
							onComplete:function():void
							{
								TweenLite.to(Parameters.gameHolder, 0.1, 
								{ 
									x:origPosX, 
									y: origPosY 
								})
							}
						})
					}
				})
			}*/
			
			dispatchEvent(new Event("UNDER_ATTACK"));
			
			return super.hurt(_hitVal, _currentInfantryDeath, projectileName)
		}
		
		public function onBuildingClickedFNCTN(o:Object):Object{return null}
		
		override protected function occupyTile(proposedRow:int, proposedCol:int):void
		{
			var n:Node;
			var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			var rowLen:int = occupyArray.length;
			var colLen:int = occupyArray[0].length;
			
			for(var _row:int = 0; _row < rowLen; _row++)
			{
				for (var _col:int = 0; _col < colLen; _col++ )
				{
					var curTile:int = occupyArray[_row][_col];
					
					if (curTile == 0) continue;//this is only for build indication
					
					proposedRow = model.row + _row;
					proposedCol = model.col + _col;
						
					if(nodeExists(proposedRow, proposedCol))
					{
						n = Node( Parameters.boardArr[proposedRow][proposedCol] );
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
					}
				}
			}
		}
		
		public function buildingSold():void
		{
			view.addEventListener("SELL_ANIM_COMPLETE", onSellAnimComplete);
			BuildingView(view).playSellAnimation();
		}
		
		private function onSellAnimComplete(e:Event):void 
		{
			
			view.removeEventListener("SELL_ANIM_COMPLETE", onSellAnimComplete);
			if (model)
			{
				model.dead = true;
			}
			dispatchEvent(new Event("SOLD"));
		}
		
		
		override public function dispose():void
		{
			if(view)view.removeEventListener("SELL_ANIM_COMPLETE", onSellAnimComplete);
			super.dispose()
		}
		
		public function buildingRepaired():void 
		{
			BuildingView(view).highlightBuilding();
			ENTITY_BEING_REPAIRED = !ENTITY_BEING_REPAIRED;
		}
		
		
		override protected function clearTile(proposedRow:int, proposedCol:int):void
		{
			var n:Node;
			var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			
			var rowLen:int = occupyArray.length;
			var colLen:int = occupyArray[0].length;
			
			for(var _row:int = 0; _row < rowLen; _row++)
			{
				for (var _col:int = 0; _col < colLen; _col++ )
				{
					var curTile:int = occupyArray[_row][_col];

					proposedRow = model.row + _row;
					proposedCol = model.col + _col;
					
					if(nodeExists(proposedRow, proposedCol))
					{
						n = Node( Parameters.boardArr[proposedRow][proposedCol] );
						//not the unit's tile itself

						//n.withinUnitRange = 0;
						n.occupyingUnit = null;
					}
				}
			}
		}
	}
}