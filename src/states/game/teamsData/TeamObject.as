package states.game.teamsData
{
	import com.greensock.TweenLite;
	import global.enums.Agent;
	import global.GameAtlas;
	import global.map.SpiralBuilder;
	import global.Methods;
	import global.Parameters;
	import global.ui.hud.PowerController;
	import global.ui.hud.TeamBuildManager;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.filters.ColorMatrixFilter;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.BuildingModel;
	import states.game.entities.buildings.BuildingView;
	import states.game.entities.buildings.Refinery;
	import states.game.entities.buildings.Turret;
	import states.game.entities.GameEntity;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.BuildingsStats;
	import states.game.stats.BuildingsStatsObj;
	import states.game.stats.InfantryStats;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;
	import states.game.entities.units.*;
	import states.game.stats.VehicleStatsObj;
	
	public class TeamObject extends EventDispatcher
	{
		public var ai:int;
		public var agent:int;
		public var teamName:String;
		
		public var team:Array;
		public var enemyTeam:Array;
		private var teamNum:int;
		
		public var buildManager:TeamBuildManager;
		public var cash:int;
		public var powerCtrl:PowerController;
		private var startParams:Object;
		
		public function TeamObject(_startParams:Object, _teamNum:int)
		{
			startParams = _startParams;
			ai = startParams.AiBehaviour;
			agent = startParams.Agent;
			teamName = startParams.teamName;
			cash = startParams.cash;
			
			teamNum = _teamNum;
			
			buildManager = new TeamBuildManager();
			buildManager.init(startParams, this);
			buildManager.addEventListener("ASSET_CONSTRUCTED", onAssetContructed);
			
		}
		
		public function init(_myTeam:Array, _enemyTeam:Array):void
		{
			team = _myTeam;
			enemyTeam =  _enemyTeam;
			
			createStartAssets();
			updatePower();
		}
		
		private function updatePower():void
		{
			powerCtrl = new PowerController(team)
			powerCtrl.updatePower();
		}
		
		public function createStartAssets():void
		{
			var i:int = 0;
			var selRow:int;
			var selCol:int;
			//var p:Unit;
			var teamStatsObj:TeamObject;
			var teamsData:Object;
			//var b:Building;
			var obj:Object;
			var ent:GameEntity;
			//var startBuilding:Object;
			var placementsArr:Array;
			var typesArr:Array = ["startVehicles", "startUnits", "startBuildings", "startTurrets" ];
			var classes:Array = [Vehicle, Infantry, Building, Turret];
			//team 1
			var len:int = typesArr.length;
			for (var g:int = 0; g < len; g++ )
			{
				var curType:String = typesArr[g];
				var CLS:Class = classes[g];
				var len2:int = startParams[curType].length;
				
				for(i = 0; i < len2; i++ )
				{
					obj = startParams[curType][i];
					
					selRow = obj.row;
					selCol = obj.col;
					
					var statsObj:AssetStatsObj = Methods.getCurretStatsObj(obj.name);
					
					if (obj.name == "harvester")
					{
						ent = new Harvester(VehicleStatsObj(statsObj), this, enemyTeam, teamNum);
					}
					else if (obj.name == "refinery")
					{
						ent = new Refinery(BuildingsStatsObj(statsObj), this, enemyTeam, teamNum);
					}
					else
					{
						ent = new CLS(statsObj, this, enemyTeam, teamNum);
					}
					
					ent.addEventListener("DEAD", onDead);
					Parameters.mapHolder.addChild(ent.view);
					
					placementsArr = SpiralBuilder.getSpiral(selRow, selCol, 1);
					ent.placeUnit(placementsArr[0].row, placementsArr[0].col);
					team.push(ent);
					
					//handleAtachedUnit(obj.name, placementsArr[0].row, placementsArr[0].col);
				}
			}
		}
		
		public function getRefinery():Refinery 
		{
			var myRefinery:Refinery;
			
			for (var i:int = 0; i < team.length; i++ )
			{
				if (team[i] is Refinery)
				{
					myRefinery = team[i];
					break;
				}
			}
			return myRefinery;
		}
		
		private function onAssetContructed(e:Event):void
		{
			var assetName:String = e.data.name;
			var assetType:String = e.data.type;
			var p:GameEntity;
			var teamObject:TeamObject;
			var currenteamNum:int = 0;
			
			
			if (assetType == "infantry" || assetType == "vehicle" )
			{
				var curRowCol:Object;
				var placementsArr:Array;
				//is this infantry?
				if (InfantryStats.dict[assetName])
				{
					p = new Infantry(InfantryStats.dict[assetName], this, enemyTeam, teamNum);
					curRowCol = buildManager.getProducingBuilding(InfantryStats.dict[assetName], team);
					placementsArr = SpiralBuilder.getSpiral(curRowCol.row, curRowCol.col, 1);
					Infantry(p).placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				else
				{
					if (assetName == "harvester")
					{
						p = new Harvester(VehicleStats.dict[assetName], this, enemyTeam, teamNum);
					}
					else
					{
						p = new Vehicle(VehicleStats.dict[assetName], this, enemyTeam, teamNum);
					}
					
					curRowCol = buildManager.getProducingBuilding(VehicleStats.dict[assetName], team);
					placementsArr = SpiralBuilder.getSpiral(curRowCol.row, curRowCol.col, 1);
					Vehicle(p).placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
				p.addEventListener("DEAD", onDead);
				Parameters.mapHolder.addChild(p.view);
				
				team.push(p);
				p.sayHello();
			}
			else
			{
				if (BuildingsStats.dict[assetName])
				{
					if (assetName == "refinery")
					{
						p = new Refinery(BuildingsStats.dict[assetName], this, enemyTeam, teamNum);
					}
					else
					{
						p = new Building(BuildingsStats.dict[assetName], this, enemyTeam, teamNum);
					}
					
				}
				else
				{
					p = new Turret(TurretStats.dict[assetName], this, enemyTeam, teamNum);
				}
				
				p.addEventListener("DEAD", onDead);
				Parameters.mapHolder.addChild(p.view);
				team.push(p);
				p.placeUnit(buildManager.targetRow, buildManager.targetCol);
				buildManager.updateUnitsAndBuildings(assetName);
				p.sayHello();
				powerCtrl.updatePower();
				//handleAtachedUnit(assetName , buildManager.targetRow, buildManager.targetCol);

			}
			
			buildManager.assetBuildComplete(assetName);
			
			dispatchEvent( new Event("ASSET_CONSTRUCTED"))
			
		}
		
		public function handleAtachedUnit(assetName:String, _buildingRow:int, _buildingCol:int):GameEntity 
		{
			var p:GameEntity;
			var curRowCol:Object;
			var placementsArr:Array;
			
			if (BuildingsStats.dict[assetName] && BuildingsStats.dict[assetName].attachedUnit)
			{
				var attachedUnit:String = BuildingsStats.dict[assetName].attachedUnit;
				
				if (InfantryStats.dict[attachedUnit])
				{
					p = new Infantry(InfantryStats.dict[attachedUnit], this, enemyTeam, teamNum);
					curRowCol = buildManager.getProducingBuilding(InfantryStats.dict[attachedUnit], team);
					placementsArr = SpiralBuilder.getSpiral(buildManager.targetRow, buildManager.targetCol, 1);
					p.placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				else
				{
					if (attachedUnit == "harvester")
					{
						p = new Harvester(VehicleStats.dict[attachedUnit], this, enemyTeam, teamNum);
					}
					else
					{
						p = new Vehicle(VehicleStats.dict[attachedUnit], this, enemyTeam, teamNum);
					}
					
					placementsArr = SpiralBuilder.getSpiral(_buildingRow, _buildingCol, 1);
					p.placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
				p.addEventListener("DEAD", onDead);
				Parameters.mapHolder.addChild(p.view);
				
				team.push(p);
				p.sayHello();
			}
			
			return p;
		}
		
		private function onDead(e:Event):void
		{
			var residentSoldiersArr:Array = [];
			var p = e.target;
			var row:int;
			var col:int;
			var currentTeamObj:TeamObject = GameEntity(p).myTeamObj;
			var numResidents:int = 0;
			var i:int = 0;
			p.removeEventListener("DEAD", onDead);
			
			if (p is Building)
			{
				row = p.model.row;
				col = p.model.col;
				
				if (BuildingsStatsObj(BuildingModel(p.model).stats).residents)
				{
					numResidents = BuildingsStatsObj(BuildingModel(p.model).stats).residents;
					
					for (i = 0; i < numResidents; i++)
					{
						var soldier:Infantry = new Infantry(InfantryStats.dict["minigunner"], p.myTeamObj, BuildingModel(p.model).enemyTeam, p.teamNum);
						residentSoldiersArr.push(soldier);
					}
					
					//this is temporary until the pc can build its own
					if (team == Parameters.humanTeam)
					{
						buildManager.removeDependantUnitsAndBuildings(Building(p).name);
					}
					
				}
				
				
				
				for (i = 0; i < residentSoldiersArr.length; i++)
				{
					var soldier:Infantry = residentSoldiersArr[i];
					var placementsArr:Array = SpiralBuilder.getSpiral(row, col, 1);
					soldier.placeUnit(placementsArr[0].row, placementsArr[0].col);
					Parameters.mapHolder.addChild(soldier.view);
					team.push(soldier);
					soldier.addEventListener("DEAD", onDead);
				}
				
				//this is temporary until the pc can build its own
				if (team == Parameters.humanTeam)
				{
					powerCtrl.updatePower();
				}
			}
			
			
			if (team != null)
			{
				if (team.indexOf(p) != -1)
				{
					team.splice(team.indexOf(p), 1);
					p.dispose();
					p = null;
				}
			}
			
			dispatchEventWith("ASSET_DESTROYED", false, {numResidents: numResidents});
		}
		
		
	}
}