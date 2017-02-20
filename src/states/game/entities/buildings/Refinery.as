package  states.game.entities.buildings
{
	import global.enums.UnitStates;
	import global.map.Node;
	import global.Parameters;
	import global.ui.hud.HUD;
	import global.utilities.GameTimer;
	import starling.display.Quad;
	import starling.events.Event;
	import states.game.entities.units.Unit;
	import states.game.stats.BuildingsStatsObj;
	import states.game.stats.VehicleStats;
	import states.game.teamsData.TeamObject;
	import states.game.entities.units.Harvester;;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Refinery extends Building
	{
		private var currentStore:int;
		private var loadCompleteFNCTB:Function;
		
		public function Refinery(_buildingStats:BuildingsStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int) 
		{
			hasBuildingClickFunction = true;
			super(_buildingStats, teamObj , _enemyTeam, myTeam);
			getLoadingLoacation();
		}
		
		override public function placeUnit(_row:int, _col:int):void
		{
			super.placeUnit(_row, _col);

			var harvester:Harvester = Harvester(myTeamObj.handleAtachedUnit("refinery", _row, _col));
			if (harvester)
			{
				harvester.searchForResources(this);
			}
		}
		
		public function beginLoading(_currentStore:int, _loadCompleteFNCTB:Function):void 
		{
			loadCompleteFNCTB = _loadCompleteFNCTB;
			currentStore = _currentStore;
			//////trace("adding " + currentStore + " CASH!")
			//refinery_healthy-docking
			BuildingView(view).state = "-docking";
			BuildingView(view).mc.loop = false;
			BuildingView(view).mc.addEventListener(Event.COMPLETE, onLoadComplete);
			BuildingView(view).playState();
			
		}
		
		private function onLoadComplete(e:Event):void 
		{
			BuildingView(view).mc.removeEventListener(Event.COMPLETE, onLoadComplete);
			GameTimer.getInstance().addUser(this);
			
			
		}
		
		public function update(_pulse:Boolean):void
		{
			if (currentStore > 0)
			{
				myTeamObj.addCash(  1 );
				currentStore--;
			}
			else
			{
				GameTimer.getInstance().removeUser(this);
				BuildingView(view).state = "-undocking";
				BuildingView(view).mc.loop = false;
				BuildingView(view).mc.addEventListener(Event.COMPLETE, onunLoadComplete);
				BuildingView(view).playState();
				
			}
		}
		
		private function onunLoadComplete(e:Event):void 
		{
			BuildingView(view).mc.removeEventListener(Event.COMPLETE, onunLoadComplete);
			BuildingView(view).state = "";
			BuildingView(view).mc.loop = true;
			BuildingView(view).playState();
			loadCompleteFNCTB();
			loadCompleteFNCTB = null;
		}
		
		public function getLoadingLoacation():Node
		{
			var n:Node;
			if (model && model.dead == false)
			{
				var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
			
				var row:int = model.row + int(occupyArray.length);
				var col:int = model.col;
				
				var n:Node = Parameters.boardArr[row][col];
				
				removeBlockingUnits(n);
			}
			
			
			return n;
			
		}
		
		private function removeBlockingUnits(node:Node):void 
		{
			var n:Node;
			for (var row:int = -1; row <= 1; row ++  )
			{
				for (var col:int = -1; col <= 1; col ++  )
				{
					if (Parameters.boardArr[node.row + row] && Parameters.boardArr[node.row + row][node.col + col])
					{
						n = Parameters.boardArr[node.row + row][node.col + col];
						if (n.occupyingUnit &&  n.occupyingUnit is Unit && n.occupyingUnit.name != "harvester")
						{
							
							var unit:Unit = Unit(n.occupyingUnit);
							if (unit.teamNum == teamNum)
							{
								//trace("unit blocking harvester, moving unit")
								unit.getWalkPath(n.row + int(Math.random()*10), n.col + int(Math.random()*10));
								unit.setState(UnitStates.WALK);
							}
						}
					}
				}
			}
			
			
			
		}
		
		
		public function onBuildingClickedFNCTN():Object
		{
			
			var locNode:Node = getLoadingLoacation();
			if (locNode)
			{
				BuildingView(view).highlightBuilding();
				return { row : locNode.row, col : locNode.col, assetName: "harvester" };
			}
			else
			{
				return null;
			}
			
		}
		
		override public function dispose():void
		{
			GameTimer.getInstance().removeUser(this);
			BuildingView(view).mc.removeEventListener(Event.COMPLETE, onunLoadComplete);
			BuildingView(view).mc.removeEventListener(Event.COMPLETE, onLoadComplete);
			if (loadCompleteFNCTB)
			{
				loadCompleteFNCTB();
			}
			super.dispose()
		}
	}
}