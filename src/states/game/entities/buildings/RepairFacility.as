package states.game.entities.buildings 
{
	import global.enums.Agent;
	import global.enums.UnitStates;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.Parameters;
	import starling.display.Sprite;
	import states.game.entities.GameEntity;
	import states.game.entities.units.Unit;
	import states.game.entities.units.UnitModel;
	import states.game.entities.units.Vehicle;
	import states.game.stats.BuildingsStatsObj;
	import states.game.teamsData.TeamObject;
	import states.game.entities.units.Vehicle;
	import states.game.stats.BuildingsStatsObj;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class RepairFacility extends Building
	{
		private var dockedVehicle:Vehicle;
		private var loadingLocation:Node;
		private var centerNode:Node;

		
		public function RepairFacility(_buildingStats:BuildingsStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int) 
		{
			hasBuildingClickFunction = true;
			super(_buildingStats, teamObj , _enemyTeam, myTeam);
		}
		
		
		public function checkVehicle():void 
		{
			var locNode:Node = getLoadingLoacation();
			if (locNode.occupyingUnit && locNode.occupyingUnit is Vehicle && locNode.occupyingUnit.teamNum == teamNum && GameEntity(locNode.occupyingUnit).healthBar.getHealthPer() < 1 && myTeamObj.cashManager.cash > 0)
			{
				if (centerNode == null)
				{
					centerNode = Parameters.boardArr[model.row + 1][model.col + 1];
				}
				
				
				dockedVehicle = Vehicle(locNode.occupyingUnit);
				dockedVehicle.stopMovingAndSplicePath();
				dockedVehicle.placeUnit(centerNode.row, centerNode.col);
				dockedVehicle.model.row = centerNode.row;
				dockedVehicle.model.col = centerNode.col;
				centerNode.occupyingUnit = dockedVehicle;
				dockedVehicle.model.currentState = UnitStates.IDLE;
				dockedVehicle.healthBar.visible = true;
				dockedVehicle.ENTITY_BEING_REPAIRED = true;
				
				BuildingView(view).state = "_repair";
				BuildingView(view).mc.loop = true;
				BuildingView(view).playState();
				
			}
		}
		
		override public function addMeToBoard(container:Sprite):void 
		{
			container.addChildAt(view,0);
		}
		
		
		override public function update(_pulse:Boolean):void
		{
			super.update(_pulse);
			if (dockedVehicle)
			{
				if (dockedVehicle.ENTITY_BEING_REPAIRED == false || (dockedVehicle.model.row != centerNode.row && dockedVehicle.model.col != centerNode.col) || myTeamObj.cashManager.cash <= 0)
				{
					unloadVehilce();
				}
			}
			else
			{
				checkVehicle();
				
			}
		}
		
		private function unloadVehilce():void 
		{
			var locNode:Node = getLoadingLoacation();
			if (dockedVehicle)
			{
				/*dockedVehicle.model.row = model.row;
				dockedVehicle.model.col = model.col;
				dockedVehicle.placeUnit(dockedVehicle.model.row, dockedVehicle.model.col);
				dockedVehicle.stopMovingAndSplicePath();*/
				dockedVehicle.healthBar.visible = false;
				dockedVehicle.ENTITY_BEING_REPAIRED = false;
				//centerNode.occupyingUnit = this;
				dockedVehicle = null;
				BuildingView(view).state = "";
				BuildingView(view).mc.loop = true;
				BuildingView(view).playState();
			}

		}
		
		public function getLoadingLoacation():Node
		{
			if (loadingLocation == null)
			{
				if (model && model.dead == false)
				{
					var occupyArray:Array = BuildingsStatsObj(model.stats).gridShape;
				
					var row:int = model.row+1;// + int(occupyArray.length);
					var col:int = model.col+1;
					
					loadingLocation = Parameters.boardArr[row][col];
				}
			}
			
			
			return loadingLocation;
		}
		

		
		override public function onBuildingClickedFNCTN(o:Object):Object
		{
			
			var locNode:Node = getLoadingLoacation();
			if (locNode && o is Vehicle)
			{
				BuildingView(view).highlightBuilding();
				return { row : locNode.row, col : locNode.col, assetName: o.name };
			}
			else
			{
				return null;
			}
			
		}
		
	}

}

			
