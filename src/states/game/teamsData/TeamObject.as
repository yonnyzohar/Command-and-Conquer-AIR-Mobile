package states.game.teamsData
{
	import com.greensock.TweenLite;
	import flash.net.ObjectEncoding;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.enums.Agent;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.GameAtlas;
	import global.GameSounds;
	import global.map.mapTypes.Board;
	import global.map.SpiralBuilder;
	import global.Methods;
	import global.Parameters;
	import global.ui.hud.PowerController;
	import global.ui.hud.TeamBuildManager;
	import global.utilities.GameTimer;
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
		public var teamNum:int;
		
		public var buildManager:TeamBuildManager;
		public var cash:int;
		public var powerCtrl:PowerController;
		public var startParams:Object;
		private var enemyTeam1Obj:TeamObject;
		public var teamBuildingsDict:Dictionary = new Dictionary();
		
		private var cashToAdd:int = 0;
		
		public var UNITS_COLOR:uint;
		public var BUILDINGS_COLOR:uint;
		private var fromSaveGame:Boolean;
		
		public var currentBaseEnemy:GameEntity;
		
		
		public function TeamObject(_startParams:Object, _teamNum:int, colorsObj:Object, _fromSaveGame:Boolean)
		{
			startParams = _startParams;
			ai = startParams.AiBehaviour;
			agent = startParams.Agent;
			teamName = startParams.teamName;
			cash = startParams.cash;
			fromSaveGame = _fromSaveGame;
			
			teamNum = _teamNum;
			UNITS_COLOR = colorsObj.UNITS;
			BUILDINGS_COLOR = colorsObj.BUILDINGS;
			
		}
		
		public function getSaveObj():Object
		{
			/*{
			"tech":5,
			"numTiles":70,
			
			"team2":{
				"startVehicles":[
				{"name":"light-tank","col":60,"row":56}
				],
			"Agent":1,
			"teamName":"nod",
			"cash":5000,
			"startBuildings":[
			{"name":"construction-yard","col":55,"row":60}
			],
		"AiBehaviour":2,
		"startTurrets":[],
		"startUnits":[
			{"name":"minigunner","col":57,"row":57},
			{"name":"minigunner","col":56,"row":58},
			{"name":"minigunner","col":58,"row":58}
			]
		}*/
		
			var o:Object = { };
			o.AiBehaviour = ai;
			o.Agent = agent;
			o.teamName = teamName;
			o.cash = cash;
			o.teamNum = teamNum;
			var teamLen:int = team.length;
			o.startVehicles = [];
			o.startTurrets = [];
			o.startUnits = [];
			o.startBuildings = [];
			for (var i:int = 0; i < teamLen; i++ )
			{
				var u:GameEntity = team[i];
				var stats:Object = {"row" : u.model.row, "col" : u.model.col, "health" : u.getHealth(), "ai" : u.aiBehaviour, "uniqueID" : u.uniqueID, "name" : u.name}
				if (u is Infantry)
				{
					o.startUnits.push(stats)
				}
				if (u is Vehicle)
				{
					o.startVehicles.push(stats)
				}
				if (u is Building)
				{
					if (u is Turret)
					{
						o.startTurrets.push(stats)
					}
					else
					{
						o.startBuildings.push(stats)
					}
				}
			}
			
			return o;
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
						ent.addEventListener("UNDER_ATTACK", underAttack);
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
					Board.mapContainerArr[Board.UNITS_LAYER].addChild(ent.view);
					
					if (curType == "startBuildings" || curType == "startTurrets")
					{
						ent.addEventListener("SOLD", onSold);
						ent.addEventListener("UNDER_ATTACK", underAttack);
					}
					
					placementsArr = SpiralBuilder.getSpiral(selRow, selCol, 1);
					ent.placeUnit(placementsArr[0].row, placementsArr[0].col, fromSaveGame);
					team.push(ent);
					
					if (obj.health)
					{
						ent.setHealth(obj.health);
					}
					
					
					if (obj.ai)
					{
						ent.changeAI(obj.ai);
					}
					
					if (curType == "startBuildings")
					{
						addBuildingToDict(BuildingsStats.dict[obj.name].buildingType);
						
					}
					
					
					if (curType == "startBuildings" || curType == "startTurrets")
					{
						Building(ent).skipBuild();
					}
				}
				
			}
			
			buildManager = new TeamBuildManager();
			buildManager.init(startParams, this);
			buildManager.addEventListener("UNIT_CONSTRUCTED", onUnitContructed);
			buildManager.addEventListener("BUILDING_PLACED", onBuildingPlaced);
			handleHud();
			fromSaveGame = false;
		}
		
		private function handleHud():void 
		{
			if (agent == Agent.HUMAN)
			{
				var numBuildings:int = Methods.countKeysInDict(teamBuildingsDict);
				if (numBuildings)
				{
					buildManager.hud.enterHud();
				}
				else
				{
					buildManager.hud.exitHud();
				}
			}
		}
		
		private function addBuildingToDict(_buildingType:String):void 
		{
			if (teamBuildingsDict[_buildingType] == undefined)
			{
				teamBuildingsDict[_buildingType] = 1;
			}
			else
			{
				teamBuildingsDict[_buildingType]++;
			}
		}
		
		private function removeBuildingFromDict(_buildingType:String):int
		{
			var numBuildingsOfThisType:int = 0;
			if (teamBuildingsDict[_buildingType])
			{
				teamBuildingsDict[_buildingType]--;
				numBuildingsOfThisType = teamBuildingsDict[_buildingType];
				
				if (teamBuildingsDict[_buildingType] <= 0)
				{
					numBuildingsOfThisType = 0;
					delete teamBuildingsDict[_buildingType];
				}
			}
			return numBuildingsOfThisType;
		}
		
		private var callingForHelp:Boolean = false;
		private var timeoutRunning:Boolean = false;
		
		private function underAttack(e:Event):void 
		{
			if (agent == Agent.PC || Parameters.AI_ONLY_GAME)
			{
				if (callingForHelp)
				{
					if (timeoutRunning == false)
					{
						trace("setting harvester timeout");
						timeoutRunning = true;
						setTimeout(function():void
						{
							timeoutRunning = false;
							callingForHelp = false;
						},5000);
					}
					
					
					return;
				}
				else
				{
					trace("calling for help!")
					callingForHelp = true;
					var attackedEntity:GameEntity = GameEntity(e.currentTarget);
					if (attackedEntity && attackedEntity.model && attackedEntity.model.dead == false)
					{
						var selRow:int = attackedEntity.model.row;
						var selCol:int = attackedEntity.model.col;
						var unit:GameEntity;
						
						var squadSize:int = 5;
						var mySquad:Array = [];
						var teamLength:int = team.length; 
						//send help
						for (var i:int = 0; i < teamLength; i++ )
						{
							unit = team[i];
							if (unit is Building)  
							{
								continue;
							}
							if (unit is Harvester)
							{
								continue;
							}
							if (unit.aiBehaviour == AiBehaviours.HELPLESS || unit.aiBehaviour == AiBehaviours.SEEK_AND_DESTROY)
							{
								continue;
							}
							
							if (mySquad.length <= squadSize)
							{
								mySquad.push(unit);
							}
							
						}
						
						if (mySquad.length)
						{
							//trace("TO THE RESCUE!!!!")
							//var placementsArr:Array = SpiralBuilder.getSpiral(selRow, selCol, mySquad.length);
							var squadLength:int = mySquad.length;
						
							for (i = 0; i < squadLength; i++ )
							{
								unit = mySquad[i];
								Unit(unit).getWalkPath(selRow, selCol);
								unit.setState(UnitStates.WALK);
							}
						}
					}
				}
			}
		}
		
		public function doesBuildingExist(_buildingName:String):Boolean
		{
			var avaliable:Boolean = false;
			if (teamBuildingsDict[_buildingName])
			{
				avaliable = true;
			}

			return avaliable;
		}
		
		public function getRefinery():Refinery 
		{
			var myRefinery:Refinery;
			var teamLength:int = team.length;
			
			for (var i:int = 0; i < teamLength; i++ )
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
			var teamLength:int = team.length;
			
			for (var i:int = 0; i < teamLength; i++ )
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
				curRowCol = buildManager.getProducingBuilding(InfantryStats.dict[assetName], team);
				if (curRowCol)
				{
					placementsArr = SpiralBuilder.getSpiral(curRowCol.row, curRowCol.col, 1);
					p = new Infantry(InfantryStats.dict[assetName], this, enemyTeam, teamNum);
					Infantry(p).placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
			}
			else
			{
				curRowCol = buildManager.getProducingBuilding(VehicleStats.dict[assetName], team);
				placementsArr = SpiralBuilder.getSpiral(curRowCol.row, curRowCol.col, 1);
				if (curRowCol)
				{
					if (assetName == "harvester")
					{
						p = new Harvester(VehicleStats.dict[assetName], this, enemyTeam, teamNum);
						p.addEventListener("UNDER_ATTACK", underAttack);
					}
					else
					{
						p = new Vehicle(VehicleStats.dict[assetName], this, enemyTeam, teamNum);
					}
					
					
					Vehicle(p).placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
				
			}
			
			buildManager.assetBuildComplete(assetName);
			
			if (p)
			{
				p.addEventListener("DEAD", onDead);
				Board.mapContainerArr[Board.UNITS_LAYER].addChild(p.view);
				
				team.push(p);
				p.sayHello();
				dispatchEvent( new Event("ASSET_CONSTRUCTED"))
			}
			
			
		}
		
		private function onBuildingPlaced(e:Event):void
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
				handleHud();
				
			}
			else
			{
				p = new Turret(TurretStats.dict[assetName], this, enemyTeam, teamNum);
			}
			
			p.addEventListener("DEAD", onDead);
			p.addEventListener("SOLD", onSold);
			p.addEventListener("UNDER_ATTACK", underAttack);
			Board.mapContainerArr[Board.UNITS_LAYER].addChild(p.view);
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
						p.addEventListener("UNDER_ATTACK", underAttack);
					}
					else
					{
						p = new Vehicle(VehicleStats.dict[attachedUnit], this, enemyTeam, teamNum);
					}
					
					placementsArr = SpiralBuilder.getSpiral(_buildingRow, _buildingCol, 1);
					p.placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
				p.addEventListener("DEAD", onDead);
				Board.mapContainerArr[Board.UNITS_LAYER].addChild(p.view);
				
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
		
		private function onSold(e:Event):void
		{
			var p:Building = Building(e.target);
			p.removeEventListener("SOLD", onSold);
			var cost:int = BuildingsStatsObj(BuildingModel(p.model).stats).cost;
			cashToAdd = cost / 2;
			GameTimer.getInstance().addUser(this);
			
			onDead(e);
		}
		
		public function beginAddingCash(_cashToAdd:int):void
		{
			cashToAdd +=  _cashToAdd;
			GameTimer.getInstance().addUser(this);
		}
		
		public function update(_pulse:Boolean):void
		{
			if (cashToAdd > 0)
			{
				addCash(  Parameters.CASH_INCREMENT );
				cashToAdd -= Parameters.CASH_INCREMENT;
			}
			else
			{
				GameTimer.getInstance().removeUser(this);
			}
		}
		
		private function onDead(e:Event):void
		{
			var residentSoldiersArr:Array = [];
			var p:GameEntity = GameEntity(e.target);
			var row:int;
			var col:int;
			var currentTeamObj:TeamObject = GameEntity(p).myTeamObj;
			var numResidents:int = 0;
			var i:int = 0;
			p.removeEventListener("DEAD", onDead);
			p.removeEventListener("UNDER_ATTACK", underAttack);
			p.removeEventListener("SOLD", onSold);
			
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
				}
				if (BuildingsStats.dict[p.name])
				{
					var numBuildingsOfThisType:int = removeBuildingFromDict(BuildingsStats.dict[p.name].buildingType);
					if (numBuildingsOfThisType == 0)
					{
						buildManager.removeDependantUnitsAndBuildings(Building(p).name);
					}
				}
				
				handleHud();
				
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
			Board.mapContainerArr[Board.UNITS_LAYER].addChild(soldier.view);
			team.push(soldier);
			soldier.addEventListener("DEAD", onDead);
			if(searchAndDestroy)soldier.changeAI(AiBehaviours.SEEK_AND_DESTROY);
		}
		
		public function reduceCash(_reduceAmount:int):Boolean
		{	
			var moreThanZero:Boolean = true;
			targetBalance = cash - _reduceAmount;
			cash = targetBalance;
			
			if (cash <= 0)
			{
				cash = 0;
				moreThanZero = false;
			}
			
			////trace(cash);
			if (agent == Agent.HUMAN)
			{
				buildManager.hud.updateCashUI(cash);
			}
			
			
			return moreThanZero;
			
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
			var teamLength:int = team.length;
			
			for (var i:int = 0; i < teamLength; i++ )
			{
				if (team[i] is Harvester)
				{
					numOfHarvesters++;
				}
			}
			return numOfHarvesters;
		}
		
		public function dispose():void 
		{
			GameTimer.getInstance().removeUser(this);
			powerCtrl.dispose();
			buildManager.dispose();
			buildManager.removeEventListener("UNIT_CONSTRUCTED", onUnitContructed);
			buildManager.removeEventListener("BUILDING_PLACED", onBuildingPlaced);
			var teamLen:int = team.length;
			
			for (var i:int = 0; i < teamLen; i++ )
			{
				team[i].removeEventListener("DEAD", onDead);
				team[i].removeEventListener("UNDER_ATTACK", underAttack);
				team[i].removeEventListener("SOLD", onSold);
				team[i].dispose();
				team[i] = null;
			}
			
			team = null;
			enemyTeam = null;
			powerCtrl = null;
			enemyTeam1Obj = null;
			teamBuildingsDict = null;
			
		}
	}
}