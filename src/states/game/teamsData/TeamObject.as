package states.game.teamsData
{
	import com.greensock.TweenLite;
	import flash.utils.Dictionary;
	import global.enums.Agent;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.GameAtlas;
	import global.GameSounds;
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
		private var targetBalance:int;
		public var team:Array;
		public var enemyTeam:Array;
		private var teamNum:int;
		
		public var buildManager:TeamBuildManager;
		public var cash:int;
		public var powerCtrl:PowerController;
		private var startParams:Object;
		private var enemyTeam1Obj:TeamObject;
		public var teamBuildingsDict:Dictionary = new Dictionary();
		
		public function TeamObject(_startParams:Object, _teamNum:int)
		{
			startParams = _startParams;
			ai = startParams.AiBehaviour;
			agent = startParams.Agent;
			teamName = startParams.teamName;
			cash = startParams.cash;
			
			teamNum = _teamNum;
			
			
			
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
			if (!powerCtrl)
			{
				powerCtrl = new PowerController(team)
			}
			
			var powerObj:Object = powerCtrl.updatePower(agent);
			buildManager.hud.updatePower(powerObj.totalPowerIn, powerObj.totalPowerOut);
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
						ent.addEventListener("UNDER_ATTACK", harvesterUnderAttack);
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
					
					if (curType == "startBuildings")
					{
						addBuildingToDict(BuildingsStats.dict[obj.name].buildingType);
					}
					
					
					//handleAtachedUnit(obj.name, placementsArr[0].row, placementsArr[0].col);
				}
			}
			
			buildManager = new TeamBuildManager();
			buildManager.init(startParams, this);
			buildManager.addEventListener("UNIT_CONSTRUCTED", onUnitContructed);
			buildManager.addEventListener("BUILDING_CONSTRUCTED", onBuildingContructed);
		}
		
		private function addBuildingToDict(_buildingName:String):void 
		{
			if (teamBuildingsDict[_buildingName] == undefined)
			{
				teamBuildingsDict[_buildingName] = 1;
			}
			else
			{
				teamBuildingsDict[_buildingName]++;
			}
		}
		
		private function removeBuildingFromDict(_buildingName:String):void 
		{
			if (teamBuildingsDict[_buildingName])
			{
				teamBuildingsDict[_buildingName]--;
				
				if (teamBuildingsDict[_buildingName] <= 0)
				{
					delete teamBuildingsDict[_buildingName];
				}
			}
		}
		
		private function harvesterUnderAttack(e:Event):void 
		{
			if (agent == Agent.PC)
			{
				var harvester:Harvester = Harvester(e.currentTarget);
				if (harvester && harvester.model && harvester.model.dead == false)
				{
					var selRow:int = harvester.model.row;
					var selCol:int = harvester.model.col;
					var unit:GameEntity;
					
					var squadSize:int = 5;
					var mySquad:Array = [];
					//send help
					for (var i:int = 0; i < team.length; i++ )
					{
						unit = team[i];
						if ((!unit is Building) && !(unit is Harvester) && unit.aiBehaviour != AiBehaviours.HELPLESS)
						{
							if (mySquad.length <= squadSize)
							{
								mySquad.push(unit);
							}
						}
					}
					
					if (mySquad.length)
					{
						//trace("TO THE RESCUE!!!!")
						var placementsArr:Array = SpiralBuilder.getSpiral(selRow, selCol, mySquad.length);
					
						for (i = 0; i < mySquad.length; i++ )
						{
							unit = mySquad[i];
							Unit(unit).getWalkPath(placementsArr[i].row, placementsArr[i].col);
							unit.setState(UnitStates.WALK);
						}
					}
					
					
				}
			}

		}
		
		public function doesBuildingExist(arr:Array):Boolean
		{
			var avaliable:Boolean = false;
			outer : for (var i:int = 0; i < arr.length; i++ )
			{
				var name:String = arr[i];
				for (var j:int = 0; j < team.length; j++ )
				{
					if (team[j].name == name)
					{
						avaliable = true;
						break outer;
					}
				}
			}
			
			return avaliable;
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
		
		public function getHarvester():Harvester 
		{
			var myHarvester:Harvester;
			
			for (var i:int = 0; i < team.length; i++ )
			{
				if (team[i] is Harvester)
				{
					myHarvester = team[i];
					break;
				}
			}
			return myHarvester;
		}
		
		private function onUnitContructed(e:Event):void
		{
			var assetName:String = e.data.name;
			var assetType:String = e.data.type;
			var p:GameEntity;
			var teamObject:TeamObject;
			var currenteamNum:int = 0;
			
			
			
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
					p.addEventListener("UNDER_ATTACK", harvesterUnderAttack);
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
			
			
			buildManager.assetBuildComplete(assetName);
			
			dispatchEvent( new Event("ASSET_CONSTRUCTED"))
		}
		
		private function onBuildingContructed(e:Event):void
		{
			var assetName:String = e.data.name;
			var assetType:String = e.data.type;
			var p:GameEntity;
			var teamObject:TeamObject;
			var currenteamNum:int = 0;
			
			
			
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
				
				addBuildingToDict(BuildingsStats.dict[assetName].buildingType);
				
			}
			else
			{
				p = new Turret(TurretStats.dict[assetName], this, enemyTeam, teamNum);
			}
			
			p.addEventListener("DEAD", onDead);
			Parameters.mapHolder.addChild(p.view);
			team.push(p);
			p.placeUnit(buildManager.targetRow, buildManager.targetCol);
			
			var newConstructionOptions:Boolean = buildManager.updateUnitsAndBuildings(assetName);
			if (newConstructionOptions && agent == Agent.HUMAN)
			{
				GameSounds.playSound("new_construction_options", "vo");
			}
			
			p.sayHello();
			//this is temporary until the pc can build its own
			updatePower();
			
			
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
						p.addEventListener("UNDER_ATTACK", harvesterUnderAttack);
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
		
		public function setEnemyTeamObj(_enemyTeam1Obj:TeamObject):void 
		{
			enemyTeam1Obj = _enemyTeam1Obj;
		}
		
		public function spawnEnemyUnit(row:int, col:int, searchAndDestroy:Boolean = true):void 
		{
			enemyTeam1Obj.spawnSoldier(row, col, searchAndDestroy);
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
			p.removeEventListener("UNDER_ATTACK", harvesterUnderAttack);
			
			if (p is Building)
			{
				row = p.model.row;
				col = p.model.col;
				
				if (BuildingsStatsObj(BuildingModel(p.model).stats).residents)
				{
					numResidents = BuildingsStatsObj(BuildingModel(p.model).stats).residents;
					
					for (i = 0; i < numResidents; i++)
					{
						spawnSoldier(row, col);
						
					}
					
					//this is temporary until the pc can build its own
					if (team == Parameters.humanTeam)
					{
						buildManager.removeDependantUnitsAndBuildings(Building(p).name);
					}
					
				}

				removeBuildingFromDict(BuildingsStats.dict[p.name].buildingType);
				
				//this is temporary until the pc can build its own
				updatePower();
			}
			
			var removed:Boolean = false;
			if (team != null)
			{
				if (team.indexOf(p) != -1)
				{
					removed = true;
					team.splice(team.indexOf(p), 1);
				}
			}
			//trace(p.model.stats.name + " " + p.model.teamName + " is removed: " + removed)
			p.dispose();
			p = null;
			
			dispatchEventWith("ASSET_DESTROYED", false, {numResidents: numResidents});
		}
		
		
		
		public function spawnSoldier(row:int, col:int, searchAndDestroy:Boolean = true):void 
		{
			var soldier:Infantry = new Infantry(InfantryStats.dict["minigunner"], this, enemyTeam, teamNum);
			var placementsArr:Array = SpiralBuilder.getSpiral(row, col, 1);
			soldier.placeUnit(placementsArr[0].row, placementsArr[0].col);
			Parameters.mapHolder.addChild(soldier.view);
			team.push(soldier);
			soldier.addEventListener("DEAD", onDead);
			if(searchAndDestroy)soldier.changeAI(AiBehaviours.SEEK_AND_DESTROY);
		}
		
		public function reduceCash(_reduceAmount:int):void
		{	
			
			targetBalance = cash - _reduceAmount;
			cash = targetBalance;
			////trace(cash);
			if (agent == Agent.HUMAN)
			{
				buildManager.hud.updateCashUI(cash);
			}
			
		}
		
		public function addCash(_amount:int):void
		{	
			targetBalance = cash + _amount;
			cash = targetBalance;
			if (agent == Agent.HUMAN)
			{
				buildManager.hud.updateCashUI(cash);
			}
		}
		
		public function getBalance():int
		{
			return cash;
		}
		
		public function getNumOfHarvesters():int 
		{
			var numOfHarvesters:int = 0;
			
			for (var i:int = 0; i < team.length; i++ )
			{
				if (team[i] is Harvester)
				{
					numOfHarvesters++;
				}
			}
			return numOfHarvesters;
		}
	}
}