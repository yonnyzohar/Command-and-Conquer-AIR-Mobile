package states.game.entities.buildings
{
	import com.greensock.TweenLite;
	import global.Methods;
	import global.Parameters;
	import global.enums.UnitStates;
	import global.map.Node;
	import global.sounds.GameSounds;
	import global.utilities.GlobalEventDispatcher;
	
	import starling.events.Event;
	
	import states.game.entities.GameEntity;
	import states.game.entities.HealthBar;
	import states.game.stats.BuildingsStatsObj;
	import states.game.teamsData.TeamObject;

	public class Building extends GameEntity
	{
		
		public var hasBuildingClickFunction:Boolean = false;
		
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
			GameSounds.playSound("BuildingCreate");
		}
		
		
		
		override protected function setState(state:int):void
		{
			super.setState(state);
			if(state == UnitStates.DIE)
			{
				
				if (!model.dead)
				{
					BuildingView(view).playExplosion();
					dispatchEvent(new Event("DEAD"));
				}
				
				if(model)model.dead = true;
				
			}
		}
		
		private function onExplosionComplete(e:Event):void 
		{
			view.removeEventListener("EXPLOSION_COMPLETE", onExplosionComplete);
			
		}
		
		override public function getSight():Array
		{
			var sightTiles:Array = [];
			if (model && model.stats.sight)
			{
				var sight:int = model.stats.sight;
				
				var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
				for(var i:int = -sight; i <= occupyArray.length + sight; i++)
				{
					for (var j:int = -sight; j <= occupyArray[0].length + sight; j++ )
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
			
			return sightTiles;
		}
		
		override protected function occupyTile(proposedRow:int, proposedCol:int):void
		{
			var n:Node;
			var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			for(var i:int = 0; i < occupyArray.length; i++)
			{
				for (var j:int = 0; j < occupyArray[i].length; j++ )
				{
					var curTile:int = occupyArray[i][j];
					
					if (curTile == 0) continue;//this is only for build indication
					
					proposedRow = model.row + j;
					proposedCol = model.col + i;
						
					if(nodeExists(proposedRow, proposedCol))
					{
						n = Node( Parameters.boardArr[proposedRow][proposedCol] );
						n.occupyingUnit = this;
					}
				}
			}
		}
		
		public function getBuildingTiles():Array
		{
			var n:Node;
			var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			var buildingTiles:Array = [];
			for(var i:int = 0; i < occupyArray.length; i++)
			{
				for (var j:int = 0; j < occupyArray[i].length; j++ )
				{
					var curTile:int = occupyArray[i][j];
					
					if (curTile == 0) continue;//this is only for build indication
					n = Node( Parameters.boardArr[model.row + j][model.col + i] );
					buildingTiles.push(n);
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
			if (Methods.assetIsOnScreen(model.row, model.col) && projectileName.indexOf("invisible") == -1 )
			{
				var origPosX:int = Parameters.gameHolder.x;
				var origPosY:int = Parameters.gameHolder.y;
				
				TweenLite.to(Parameters.gameHolder, 0.1, 
				{
					x:origPosX + (Math.random() /2), 
					y:origPosY + (Math.random() /2 ), 
					onComplete:function()
					{
						TweenLite.to(Parameters.gameHolder, 0.1, 
						{ 
							x:origPosX - (Math.random() /2 ), 
							y: origPosY - (Math.random() /2 ), 
							onComplete:function()
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
			}
			
			
			
			return super.hurt(_hitVal, _currentInfantryDeath, projectileName)
		}
		
		
		
		override protected function clearTile(proposedRow:int, proposedCol:int):void
		{
			var n:Node;
			var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			
			for(var i:int = 0; i < occupyArray.length; i++)
			{
				for (var j:int = 0; j < occupyArray[i].length; j++ )
				{
					var curTile:int = occupyArray[i][j];
					
					
						proposedRow = model.row + j;
						proposedCol = model.col + i;
						
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